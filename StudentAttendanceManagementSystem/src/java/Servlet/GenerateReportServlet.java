package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/GenerateReportServlet")
public class GenerateReportServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Authenticate Session Gatekeeper Context
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        // 2. Capture Form Configuration Parameters
        String courseCode = request.getParameter("courseCode");
        String reportScope = request.getParameter("reportScope"); // "SINGLE" or "RANGE"
        String startDate = request.getParameter("startDate");     // "YYYY-MM-DD"
        String endDate = request.getParameter("endDate");         // "YYYY-MM-DD"

        boolean incSummary = "true".equals(request.getParameter("contentSummary"));
        boolean incThreshold = "true".equals(request.getParameter("contentThreshold"));
        boolean incBreakdown = "true".equals(request.getParameter("contentBreakdown"));

        String exportFormat = request.getParameter("exportFormat"); // "PDF", "EXCEL", "CSV"
        String actionType = request.getParameter("actionType");     // "GENERATE" or "PREVIEW"

        if (courseCode == null || courseCode.trim().isEmpty() || startDate == null || startDate.trim().isEmpty()) {
            response.sendRedirect("LoadReportGenerationServlet?error=MissingParameters");
            return;
        }

        courseCode = courseCode.trim();
        reportScope = (reportScope != null) ? reportScope.trim() : "RANGE";

        Map<String, Object> reportMetadata = new HashMap<>();
        List<Map<String, Object>> studentAttendanceReport = new ArrayList<>();
        List<String> activeSessionsList = new ArrayList<>();

        reportMetadata.put("courseCode", courseCode);
        reportMetadata.put("reportScope", reportScope);
        reportMetadata.put("startDate", startDate);
        reportMetadata.put("exportFormat", exportFormat);

        // 3. Database Retrieval Processing Engine
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // STEP A: Fetch Course Name metadata header
                String courseNameSql = "SELECT courseName FROM course WHERE courseCode = ?";
                try (PreparedStatement psCourse = conn.prepareStatement(courseNameSql)) {
                    psCourse.setString(1, courseCode);
                    try (ResultSet rs = psCourse.executeQuery()) {
                        if (rs.next()) {
                            reportMetadata.put("courseName", rs.getString("courseName"));
                        }
                    }
                }

                // STEP B: Dynamically determine session filtering criteria depending on Scope selection
                StringBuilder sessionDiscoverySql = new StringBuilder(
                        "SELECT sessionId, DATE_FORMAT(date, '%Y-%m-%d') AS sDate FROM attendancesession WHERE courseCode = ? "
                );

                if ("SINGLE".equals(reportScope)) {
                    sessionDiscoverySql.append("AND date = ? ");
                } else {
                    sessionDiscoverySql.append("AND date BETWEEN ? AND ? ");
                }
                sessionDiscoverySql.append("ORDER BY date ASC, startTime ASC");

                try (PreparedStatement psSessions = conn.prepareStatement(sessionDiscoverySql.toString())) {
                    psSessions.setString(1, courseCode);
                    psSessions.setString(2, startDate.trim());
                    if (!"SINGLE".equals(reportScope)) {
                        psSessions.setString(3, endDate.trim());
                        reportMetadata.put("endDate", endDate);
                    } else {
                        reportMetadata.put("endDate", startDate);
                    }

                    try (ResultSet rsSessions = psSessions.executeQuery()) {
                        while (rsSessions.next()) {
                            activeSessionsList.add(rsSessions.getString("sessionId"));
                        }
                    }
                }

                int totalSessionsCount = activeSessionsList.size();
                reportMetadata.put("totalSessions", totalSessionsCount);

                // STEP C: Process Master Analytics rows if sessions exist
                if (totalSessionsCount > 0) {
                    String rosterSql = "SELECT sc.matricNo, u.fullName FROM studentcourse sc "
                            + "JOIN users u ON sc.matricNo = u.matricNo "
                            + "WHERE sc.courseCode = ? ORDER BY u.fullName ASC";

                    try (PreparedStatement psRoster = conn.prepareStatement(rosterSql)) {
                        psRoster.setString(1, courseCode);

                        try (ResultSet rsRoster = psRoster.executeQuery()) {
                            while (rsRoster.next()) {
                                String studentMatric = rsRoster.getString("matricNo");
                                String studentName = rsRoster.getString("fullName");

                                Map<String, Object> studentRow = new HashMap<>();
                                studentRow.put("matricNo", studentMatric);
                                studentRow.put("fullName", studentName);

                                StringBuilder checkinCountSql = new StringBuilder(
                                        "SELECT COUNT(*) FROM attendancerecord WHERE matricNo = ? AND sessionId IN ("
                                );
                                for (int i = 0; i < totalSessionsCount; i++) {
                                    checkinCountSql.append("?");
                                    if (i < totalSessionsCount - 1) {
                                        checkinCountSql.append(",");
                                    }
                                }
                                checkinCountSql.append(")");

                                int presentCount = 0;
                                try (PreparedStatement psCount = conn.prepareStatement(checkinCountSql.toString())) {
                                    psCount.setString(1, studentMatric);
                                    for (int i = 0; i < totalSessionsCount; i++) {
                                        psCount.setString(i + 2, activeSessionsList.get(i));
                                    }
                                    try (ResultSet rsCount = psCount.executeQuery()) {
                                        if (rsCount.next()) {
                                            presentCount = rsCount.getInt(1);
                                        }
                                    }
                                }

                                int absentCount = totalSessionsCount - presentCount;
                                double attendancePercentage = ((double) presentCount / totalSessionsCount) * 100.0;

                                studentRow.put("presentCount", presentCount);
                                studentRow.put("absentCount", absentCount);
                                studentRow.put("percentage", Math.round(attendancePercentage * 10.0) / 10.0);
                                studentRow.put("isBelowThreshold", attendancePercentage < 80.0);

                                if (incBreakdown) {
                                    Map<String, String> logsMap = new HashMap<>();
                                    String detailSql = "SELECT sessionId, DATE_FORMAT(checkinTime, '%H:%i') AS cTime "
                                            + "FROM attendancerecord WHERE matricNo = ? AND sessionId = ?";

                                    for (String sId : activeSessionsList) {
                                        try (PreparedStatement psDetail = conn.prepareStatement(detailSql)) {
                                            psDetail.setString(1, studentMatric);
                                            psDetail.setString(2, sId);
                                            try (ResultSet rsDetail = psDetail.executeQuery()) {
                                                if (rsDetail.next()) {
                                                    logsMap.put(sId, "PRESENT (" + rsDetail.getString("cTime") + ")");
                                                } else {
                                                    logsMap.put(sId, "ABSENT");
                                                }
                                            }
                                        }
                                    }
                                    studentRow.put("sessionLogs", logsMap);
                                }

                                if (incThreshold && !incSummary) {
                                    if (attendancePercentage < 80.0) {
                                        studentAttendanceReport.add(studentRow);
                                    }
                                } else {
                                    studentAttendanceReport.add(studentRow);
                                }
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("--> [SAMS CRITICAL REPORT GENERATOR EXCEPTION]");
            e.printStackTrace();
        }

        // 4. Determine Routing Destination Action Mode Pathways
        request.setAttribute("reportMeta", reportMetadata);
        request.setAttribute("reportRoster", studentAttendanceReport);
        request.setAttribute("sessionsHeaderList", activeSessionsList);

        request.setAttribute("incSummary", incSummary);
        request.setAttribute("incThreshold", incThreshold);
        request.setAttribute("incBreakdown", incBreakdown);

        String courseName = (String) reportMetadata.getOrDefault("courseName", "Module");
        String safeFilename = (courseCode + "_" + startDate).replaceAll("\\s+", "_");

        if ("PREVIEW".equalsIgnoreCase(actionType)) {
            request.getRequestDispatcher("previewReportDetails.jsp").forward(request, response);
        } else {
            if ("PDF".equalsIgnoreCase(exportFormat)) {
                // =================================================================
                // MODIFIED DIRECT PRINT PIPELINE WITH INTEGRATED LIFE CYCLE CHART
                // =================================================================
                response.setContentType("text/html;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>" + safeFilename + "</title>");
                    out.println("<script src='https://cdn.jsdelivr.net/npm/chart.js'></script>");
                    out.println("<style>");
                    out.println("  body { font-family: Arial, sans-serif; padding: 20px; }");
                    out.println("  .meta-card { border: 1px solid #e0e0e0; padding: 20px; background: #fafafa; margin-bottom: 25px; border-radius: 6px; }");
                    out.println("  table { width: 100%; border-collapse: collapse; margin-top: 20px; }");
                    out.println("  th { background-color: #00897b!important; color: white; padding: 12px; border: 1px solid #333; }");
                    out.println("  td { border: 1px solid #333; padding: 10px; text-align: center; }");
                    out.println("  .left { text-align: left!important; }");
                    out.println("  .chart-box { width: 550px; height: 280px; margin: 20px auto; display: block; position: relative; }");
                    out.println("  @media print { * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; } }");
                    out.println("</style></head>");

                    out.println("<body onload='renderPrintChart();'><div>");
                    out.println("<div class='meta-card'><h2 style='color:#00897b; margin:0 0 10px 0;'>" + courseCode + " — " + courseName + "</h2>");
                    out.println("<p style='margin:4px 0;'><strong>Scope Mode:</strong> " + ("SINGLE".equals(reportScope) ? "Single Class Session" : "Date Range Summary") + "</p>");
                    out.println("<p style='margin:4px 0;'><strong>Timeframe Selector:</strong> " + startDate + ("SINGLE".equals(reportScope) ? "" : " to " + endDate) + "</p>");
                    out.println("<p style='margin:4px 0;'><strong>Total Classes Discovered:</strong> " + activeSessionsList.size() + " Session(s)</p></div>");

                    // Embed Canvas Node right above table sheet grid
                    out.println("<div class='chart-box'><canvas id='pdfRosterChartCanvas' width='550' height='280'></canvas></div>");

                    out.println("<table><thead><tr>");
                    out.println("  <th style='width: 60px;'>NO.</th>");
                    out.println("  <th style='width: 120px;'>MATRIC NO</th>");
                    out.println("  <th>STUDENT FULL NAME</th>");

                    if ("SINGLE".equals(reportScope)) {
                        out.println("  <th style='width: 150px;'>STATUS</th>");
                    } else {
                        out.println("  <th style='width: 100px;'>PRESENT</th>");
                        out.println("  <th style='width: 100px;'>ABSENT</th>");
                        out.println("  <th style='width: 120px;'>PERCENTAGE</th>");
                    }
                    out.println("</tr></thead><tbody>");

                    int idx = 1;
                    int totalPresentSum = 0;
                    int totalAbsentSum = 0;

                    for (Map<String, Object> student : studentAttendanceReport) {
                        int pCount = (Integer) student.get("presentCount");
                        int aCount = (Integer) student.get("absentCount");
                        totalPresentSum += pCount;
                        totalAbsentSum += aCount;

                        out.println("<tr><td>" + idx++ + "</td>");
                        out.println("  <td><b>" + student.get("matricNo") + "</b></td>");
                        out.println("  <td class='left'>" + student.get("fullName") + "</td>");

                        if ("SINGLE".equals(reportScope)) {
                            if (pCount > 0) {
                                out.println("  <td style='background-color:#d1e7dd; color:#0f5132; font-weight:bold;'>PRESENT</td>");
                            } else {
                                out.println("  <td style='background-color:#f8d7da; color:#842029; font-weight:bold;'>ABSENT</td>");
                            }
                        } else {
                            out.println("  <td style='color:#2e7d32; font-weight:bold;'>" + pCount + "</td>");
                            out.println("  <td style='color:#c62828; font-weight:bold;'>" + aCount + "</td>");

                            int pct = Math.round(Float.parseFloat(student.get("percentage").toString()));
                            String clr = (pct < 80) ? "#c62828" : "#2e7d32";
                            out.println("  <td style='font-weight:bold;color:" + clr + ";'>" + pct + "%</td>");
                        }
                        out.println("</tr>");
                    }
                    out.println("</tbody>");

                    out.println("<tfoot style='background-color:#fafafa; font-weight:bold;'><tr>");
                    out.println("  <td colspan='3' style='text-align:right; font-size:13px;'>SUMMARY METRICS MATRIX COUNTER:</td>");
                    int totalSlots = totalPresentSum + totalAbsentSum;
                    double globalRate = (totalSlots > 0) ? ((double) totalPresentSum / totalSlots) * 100.0 : 0.0;

                    if ("SINGLE".equals(reportScope)) {
                        out.println("  <td style='text-align:left; font-size:12px; line-height:1.4;'>");
                        out.println("    <div>• Present: <span style='color:#2e7d32;'>" + totalPresentSum + "</span></div>");
                        out.println("    <div>• Absent: <span style='color:#c62828;'>" + totalAbsentSum + "</span></div>");
                        out.println("    <div style='border-top:1px dashed #ccc; margin-top:2px;'>• Rate: " + String.format("%.1f", globalRate) + "%</div>");
                        out.println("  </td>");
                    } else {
                        out.println("  <td style='color:#2e7d32;'>" + totalPresentSum + "</td>");
                        out.println("  <td style='color:#c62828;'>" + totalAbsentSum + "</td>");
                        out.println("  <td style='color:#00897b;'>" + String.format("%.1f", globalRate) + "%</td>");
                    }
                    out.println("</tr></tfoot></table></div>");

                    // INJECT ASYNCHRONOUS LIFE CYCLE ENGAGEMENT LAYER FOR PDF PLOTS
                    out.println("<script type='text/javascript'>");
                    out.println("function renderPrintChart() {");
                    out.println("  var ctx = document.getElementById('pdfRosterChartCanvas').getContext('2d');");
                    out.println("  new Chart(ctx, {");
                    out.println("    type: 'doughnut',");
                    out.println("    data: {");
                    out.println("      labels: ['Present Slots', 'Absent Slots'],");
                    out.println("      datasets: [{");
                    out.println("        data: [" + totalPresentSum + ", " + totalAbsentSum + "],");
                    out.println("        backgroundColor: ['#2ecc71', '#e74c3c'],");
                    out.println("        borderColor: ['#27ae60', '#c0392b'],");
                    out.println("        borderWidth: 1");
                    out.println("      }]");
                    out.println("    },");
                    out.println("    options: {");
                    out.println("      responsive: false,");
                    out.println("      plugins: {");
                    out.println("        legend: { position: 'bottom' },");
                    out.println("        title: { display: true, text: 'Overall Attendance Share Distribution Matrix', font: { size: 14, weight: 'bold' } }");
                    out.println("      }");
                    out.println("    },");
                    out.println("    plugins: [{");
                    out.println("      afterRender: function(chart) {");
                    out.println("        setTimeout(function() { window.print(); }, 400);");
                    out.println("      }");
                    out.println("    }]");
                    out.println("  });");
                    out.println("}");
                    out.println("</script></body></html>");
                    out.flush();
                }
            } else if ("EXCEL".equalsIgnoreCase(exportFormat)) {
                request.getRequestDispatcher("ExportExcelReportHelper").forward(request, response);
            } else {
                String safeCsvName = (courseCode + "_" + startDate + "_to_" + endDate).replaceAll("\\s+", "_");
                response.setContentType("text/csv");
                response.setCharacterEncoding("UTF-8");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + safeCsvName + ".csv\"");

                try (PrintWriter csvOut = response.getWriter()) {
                    csvOut.println("MatricNo,FullName,PresentSessions,AbsentSessions,Percentage");
                    for (Map<String, Object> row : studentAttendanceReport) {
                        csvOut.println(row.get("matricNo") + "," + row.get("fullName") + ","
                                + row.get("presentCount") + "," + row.get("absentCount") + "," + row.get("percentage") + "%");
                    }
                    csvOut.flush();
                }
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        response.sendRedirect("LoadReportGenerationServlet");
    }
}
