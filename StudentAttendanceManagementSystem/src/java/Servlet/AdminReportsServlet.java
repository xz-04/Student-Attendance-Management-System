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

@WebServlet("/AdminReportsServlet")
public class AdminReportsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Authentication Gatekeeper
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Extract Input Fields Parameters
        String actionType = request.getParameter("actionType");
        String facultyFilter = request.getParameter("facultyFilter");
        String reportType = request.getParameter("reportType");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String exportFormat = request.getParameter("exportFormat");

        boolean incAllCourses = "true".equals(request.getParameter("includeAllCourses"));
        boolean incSessionsCreated = "true".equals(request.getParameter("includeSessionsCreated"));
        boolean incStudentsPresent = "true".equals(request.getParameter("includeStudentsPresent"));
        boolean incPercentage = "true".equals(request.getParameter("includePercentage"));

        List<Map<String, Object>> reportDataList = new ArrayList<>();
        int threshold = 80;

        // Fetch active warning threshold configuration from system rules
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement("SELECT attendanceThreshold FROM systemrule WHERE ruleId = 1"); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                threshold = rs.getInt("attendanceThreshold");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        boolean isJSM = "JSM".equalsIgnoreCase(facultyFilter != null ? facultyFilter.trim() : "");
        if (isJSM) {
            reportType = "UserInformation";
        }

        // 3. DATABASE ACCESS AND CALCULATION FLOW PIPELINE
        if ("Lecturer".equalsIgnoreCase(reportType) || "Student".equalsIgnoreCase(reportType) || isJSM) {
            // ROSTER TYPE QUERIES
            String userSql = isJSM
                    ? "SELECT matricNo, fullName, email, phoneNo FROM users WHERE facultyName = 'JSM' ORDER BY matricNo ASC"
                    : "SELECT matricNo, fullName, email, phoneNo FROM users WHERE facultyName = ? AND role = ? ORDER BY matricNo ASC";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(userSql)) {
                if (!isJSM) {
                    ps.setString(1, facultyFilter);
                    ps.setString(2, reportType);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("jsmMatricNo", rs.getString("matricNo"));
                        row.put("jsmFullName", rs.getString("fullName"));
                        row.put("jsmEmail", rs.getString("email"));
                        String ph = rs.getString("phoneNo");
                        row.put("jsmPhoneNo", (ph != null && !ph.trim().isEmpty()) ? ph : "-");
                        reportDataList.add(row);
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            // COURSE ATTENDANCE METRICS QUERIES
            String sD = (startDate != null && !startDate.isEmpty()) ? startDate : "1970-01-01";
            String eD = (endDate != null && !endDate.isEmpty()) ? endDate : "2099-12-31";

            String querySql = "SELECT c.courseCode, c.courseName, "
                    + "  (SELECT COUNT(*) FROM attendancesession s WHERE s.courseCode = c.courseCode AND s.date BETWEEN ? AND ?) as total_sessions, "
                    + "  (SELECT COUNT(*) FROM attendancerecord r JOIN attendancesession s2 ON r.sessionId = s2.sessionId WHERE s2.courseCode = c.courseCode AND s2.date BETWEEN ? AND ?) as present_count, "
                    + "  (SELECT COUNT(*) FROM studentcourse sc WHERE sc.courseCode = c.courseCode) as total_students "
                    + "FROM course c WHERE ? = 'All' OR c.facultyName = ? ORDER BY c.courseCode ASC";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(querySql)) {
                ps.setString(1, sD);
                ps.setString(2, eD);
                ps.setString(3, sD);
                ps.setString(4, eD);
                ps.setString(5, facultyFilter);
                ps.setString(6, facultyFilter);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        int sessions = rs.getInt("total_sessions");
                        int presents = rs.getInt("present_count");
                        int totalStudents = rs.getInt("total_students");
                        int totalExpectedSlots = sessions * totalStudents;

                        int percentage = 100;
                        int absents = 0;

                        if (totalExpectedSlots > 0) {
                            percentage = (int) Math.round(((double) presents / totalExpectedSlots) * 100);
                            absents = totalExpectedSlots - presents;
                        } else if (sessions > 0) {
                            percentage = 0;
                            absents = 0;
                        }

                        row.put("courseCode", rs.getString("courseCode"));
                        row.put("courseName", rs.getString("courseName"));
                        row.put("sessionsCreated", sessions);
                        row.put("studentsPresent", presents + " / " + totalExpectedSlots);
                        row.put("attendancePercentage", percentage);

                        row.put("totalPresent", presents);
                        row.put("totalAbsent", absents);

                        reportDataList.add(row);
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // -----------------------------------------------------------------
        // CONTEXT WORKER ROUTING BRANCH A: PREVIEW STAGE
        // -----------------------------------------------------------------
        if ("PREVIEW".equalsIgnoreCase(actionType)) {
            request.setAttribute("currentSystemThreshold", threshold);
            // FIXED MAPPING: Set key to generatedReportRows to match adminReportPreview.jsp token references
            request.setAttribute("generatedReportRows", reportDataList);
            request.getRequestDispatcher("adminReportPreview.jsp").forward(request, response);
            return;
        }

        // -----------------------------------------------------------------
        // CONTEXT WORKER ROUTING BRANCH B: EXPORT / GENERATE DISPATCH
        // -----------------------------------------------------------------
        String baseFileName = facultyFilter + "_" + (reportType != null ? reportType : "Course") + "_Report";
        baseFileName = baseFileName.replaceAll("\\s+", "_");

        if ("EXCEL".equalsIgnoreCase(exportFormat)) {
            response.setContentType("application/vnd.ms-excel");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + baseFileName + ".xls\"");

            try (PrintWriter out = response.getWriter()) {
                out.println("<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:x='urn:schemas-microsoft-com:office:excel' xmlns='http://www.w3.org/TR/REC-html40'>");
                out.println("<head><meta charset='UTF-8'><style>table{border-collapse:collapse;} th{background-color:#00897b;color:#ffffff;font-weight:bold;border:1px solid #cccccc;} td{border:1px solid #cccccc;text-align:center;}</style></head><body>");
                out.println("<h3>SAMS Management Export - " + facultyFilter + " (" + reportType + ")</h3>");
                out.println("<table><thead><tr>");

                if (!"Course".equalsIgnoreCase(reportType)) {
                    out.println("<th>INDEX</th><th>MATRIC NO</th><th>NAME</th><th>EMAIL</th><th>PHONE NO</th></tr></thead><tbody>");
                    int counter = 1;
                    for (Map<String, Object> row : reportDataList) {
                        out.println("<tr><td>" + counter++ + "</td><td>" + row.get("jsmMatricNo") + "</td><td style='text-align:left;'>" + row.get("jsmFullName") + "</td><td style='text-align:left;'>" + row.get("jsmEmail") + "</td><td>" + row.get("jsmPhoneNo") + "</td></tr>");
                    }
                } else {
                    out.println("<th>INDEX</th>");
                    if (incAllCourses) {
                        out.println("<th>ALL COURSES BASED ON FACULTY</th>");
                    }
                    if (incSessionsCreated) {
                        out.println("<th>SESSIONS CREATED</th>");
                    }
                    if (incStudentsPresent) {
                        out.println("<th>TOTAL STUDENT PRESENT</th>");
                    }
                    if (incPercentage) {
                        out.println("<th>PERCENTAGE</th>");
                    }
                    out.println("</tr></thead><tbody>");

                    int counter = 1;
                    for (Map<String, Object> row : reportDataList) {
                        out.println("<tr><td>" + counter++ + "</td>");
                        if (incAllCourses) {
                            out.println("<td style='text-align:left;'>" + row.get("courseCode") + " - " + row.get("courseName") + "</td>");
                        }
                        if (incSessionsCreated) {
                            out.println("<td>" + row.get("sessionsCreated") + "</td>");
                        }
                        if (incStudentsPresent) {
                            out.println("<td>" + row.get("studentsPresent") + "</td>");
                        }
                        if (incPercentage) {
                            int pct = (Integer) row.get("attendancePercentage");
                            String clr = (pct < threshold) ? "#c62828" : "#00897b";
                            out.println("<td style='font-weight:bold;color:" + clr + ";'>" + pct + "%</td>");
                        }
                        out.println("</tr>");
                    }
                }
                out.println("</tbody></table></body></html>");
                out.flush();
            }
        } else if ("CSV".equalsIgnoreCase(exportFormat)) {
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + baseFileName + ".csv\"");

            try (PrintWriter out = response.getWriter()) {
                if (!"Course".equalsIgnoreCase(reportType)) {
                    out.println("INDEX,MATRIC NO,NAME,EMAIL,PHONE NO");
                    int counter = 1;
                    for (Map<String, Object> row : reportDataList) {
                        out.println(counter++ + "," + row.get("jsmMatricNo") + ",\"" + row.get("jsmFullName").toString().replace("\"", "\"\"") + "\",\"" + row.get("jsmEmail") + "\",\"" + row.get("jsmPhoneNo") + "\"");
                    }
                } else {
                    StringBuilder sbHeader = new StringBuilder("INDEX");
                    if (incAllCourses) {
                        sbHeader.append(",COURSE");
                    }
                    if (incSessionsCreated) {
                        sbHeader.append(",SESSIONS CREATED");
                    }
                    if (incStudentsPresent) {
                        sbHeader.append(",TOTAL STUDENT PRESENT");
                    }
                    if (incPercentage) {
                        sbHeader.append(",PERCENTAGE");
                    }
                    out.println(sbHeader.toString());

                    int counter = 1;
                    for (Map<String, Object> row : reportDataList) {
                        StringBuilder sbRow = new StringBuilder(String.valueOf(counter++));
                        if (incAllCourses) {
                            String fullCourseString = row.get("courseCode") + " - " + row.get("courseName");
                            sbRow.append(",\"").append(fullCourseString.replace("\"", "\"\"")).append("\"");
                        }
                        if (incSessionsCreated) {
                            sbRow.append(",").append(row.get("sessionsCreated"));
                        }
                        if (incStudentsPresent) {
                            sbRow.append(",\"").append(row.get("studentsPresent")).append("\"");
                        }
                        if (incPercentage) {
                            sbRow.append(",").append(row.get("attendancePercentage")).append("%");
                        }
                        out.println(sbRow.toString());
                    }
                }
                out.flush();
            }
        } else {
            // =================================================================
            // DIRECT INLINE PRINT MODE (LAUNCHES ON CLICKING GENERATE REPORT)
            // =================================================================
            response.setContentType("text/html;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>" + baseFileName + "</title>");
                out.println("<script src='https://cdn.jsdelivr.net/npm/chart.js'></script>");
                out.println("<style>");
                out.println("body { font-family: Arial, sans-serif; padding: 20px; }");
                out.println(".meta-card { border: 1px solid #e0e0e0; padding: 20px; background: #fafafa; margin-bottom: 25px; }");
                out.println("table { width: 100%; border-collapse: collapse; margin-top: 20px; }");
                out.println("th { background-color: #00897b!important; color: white; padding: 12px; border: 1px solid #333; }");
                out.println("td { border: 1px solid #333; padding: 10px; text-align: center; }");
                out.println(".left { text-align: left!important; }");
                out.println(".chart-box { width: 600px; height: 320px; margin: 20px auto; display: block; position: relative; }");
                out.println("@media print { * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; } }");
                out.println("</style></head>");

                out.println("<body onload='renderPrintChart();'><div>");
                out.println("<div class='meta-card'><h2>SAMS METRICS MANAGEMENT REPORT</h2><p><strong>Faculty Scope:</strong> " + facultyFilter + "</p><p><strong>Report Type:</strong> " + reportType + "</p></div>");

                if ("Course".equalsIgnoreCase(reportType)) {
                    out.println("<div class='chart-box'><canvas id='pdfChartCanvas' width='600' height='320'></canvas></div>");
                }

                out.println("<table><thead><tr>");

                if (!"Course".equalsIgnoreCase(reportType)) {
                    out.println("<th>INDEX</th><th>MATRIC NO</th><th>NAME</th><th>EMAIL</th><th>PHONE NO</th></tr></thead><tbody>");
                    int idx = 1;
                    for (Map<String, Object> r : reportDataList) {
                        out.println("<tr><td>" + idx++ + "</td><td><b>" + r.get("jsmMatricNo") + "</b></td><td class='left'>" + r.get("jsmFullName") + "</td><td class='left'>" + r.get("jsmEmail") + "</td><td>" + r.get("jsmPhoneNo") + "</td></tr>");
                    }
                } else {
                    out.println("<th>INDEX</th>");
                    if (incAllCourses) {
                        out.println("<th>ALL COURSES BASED ON FACULTY</th>");
                    }
                    if (incSessionsCreated) {
                        out.println("<th>SESSIONS CREATED</th>");
                    }
                    if (incStudentsPresent) {
                        out.println("<th>TOTAL STUDENT PRESENT</th>");
                    }
                    if (incPercentage) {
                        out.println("<th>PERCENTAGE</th>");
                    }
                    out.println("</tr></thead><tbody>");

                    int idx = 1;
                    for (Map<String, Object> r : reportDataList) {
                        out.println("<tr><td>" + idx++ + "</td>");
                        if (incAllCourses) {
                            out.println("<td class='left'><b>" + r.get("courseCode") + "</b> — " + r.get("courseName") + "</td>");
                        }
                        if (incSessionsCreated) {
                            out.println("<td>" + r.get("sessionsCreated") + "</td>");
                        }
                        if (incStudentsPresent) {
                            out.println("<td>" + r.get("studentsPresent") + "</td>");
                        }
                        if (incPercentage) {
                            int pct = (Integer) r.get("attendancePercentage");
                            String clr = (pct < threshold) ? "#c62828" : "#00897b";
                            out.println("<td style='font-weight:bold;color:" + clr + ";'>" + pct + "%</td>");
                        }
                        out.println("</tr>");
                    }
                }
                out.println("</tbody></table></div>");

                if ("Course".equalsIgnoreCase(reportType)) {
                    out.println("<script type='text/javascript'>");
                    out.println("function renderPrintChart() {");
                    out.println("  var ctx = document.getElementById('pdfChartCanvas').getContext('2d');");
                    out.println("  var courseLabels = []; var presentData = []; var absentData = [];");

                    for (Map<String, Object> r : reportDataList) {
                        out.println("  courseLabels.push('" + r.get("courseCode") + "');");
                        out.println("  presentData.push(" + r.get("totalPresent") + ");");
                        out.println("  absentData.push(" + r.get("totalAbsent") + ");");
                    }

                    out.println("  new Chart(ctx, {");
                    out.println("    type: 'bar',");
                    out.println("    data: {");
                    out.println("      labels: courseLabels,");
                    out.println("      datasets: [");
                    out.println("        { label: 'Students Present', data: presentData, backgroundColor: '#2ecc71', borderWidth: 1 },");
                    out.println("        { label: 'Students Absent', data: absentData, backgroundColor: '#e74c3c', borderWidth: 1 }");
                    out.println("      ]");
                    out.println("    },");
                    out.println("    options: {");
                    out.println("      responsive: false,");
                    out.println("      scales: { y: { beginAtZero: true } }");
                    out.println("    },");
                    out.println("    plugins: [{");
                    out.println("      afterRender: function(chart) {");
                    out.println("        setTimeout(function() {");
                    out.println("          window.print();");
                    out.println("        }, 400);");
                    out.println("      }");
                    out.println("    }]");
                    out.println("  });");
                    out.println("}");
                    out.println("</script>");
                } else {
                    out.println("<script type='text/javascript'>function renderPrintChart() { window.print(); }</script>");
                }

                out.println("</body></html>");
                out.flush();
            }
        }
    }
}
