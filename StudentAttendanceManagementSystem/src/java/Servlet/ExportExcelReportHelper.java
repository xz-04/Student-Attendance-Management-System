package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ExportExcelReportHelper")
public class ExportExcelReportHelper extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. Retrieve calculated report payloads from the previous request context scope
        Map<String, Object> reportMeta = (Map<String, Object>) request.getAttribute("reportMeta");
        List<Map<String, Object>> reportRoster = (List<Map<String, Object>>) request.getAttribute("reportRoster");
        List<String> sessionsHeaderList = (List<String>) request.getAttribute("sessionsHeaderList");

        boolean incBreakdown = Boolean.TRUE.equals(request.getAttribute("incBreakdown"));

        String courseCode = (String) reportMeta.get("courseCode");
        String courseName = (String) reportMeta.get("courseName");
        String reportScope = (String) reportMeta.get("reportScope");
        String startDate = (String) reportMeta.get("startDate");
        String endDate = (String) reportMeta.get("endDate");

        // 2. Construct the Dynamic Filename Token based on the Report Scope
        String safeFilename;
        if ("SINGLE".equals(reportScope)) {
            safeFilename = courseCode + "_" + startDate;
        } else {
            safeFilename = courseCode + "_" + startDate + "_to_" + endDate;
        }
        safeFilename = safeFilename.replaceAll("\\s+", "_");

        // 3. Configure HTTP response rules to stream an Excel-Compliant HTML format
        response.setContentType("application/vnd.ms-excel");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + safeFilename + ".xls\"");

        // 4. PREPARE THE DYNAMIC QUICKCHART GRAPH URL
        StringBuilder chartLabels = new StringBuilder();
        StringBuilder chartPresents = new StringBuilder();
        StringBuilder chartAbsents = new StringBuilder();

        if (reportRoster != null && !reportRoster.isEmpty()) {
            for (int i = 0; i < reportRoster.size(); i++) {
                Map<String, Object> student = reportRoster.get(i);
                // Use Matric No as X-Axis Label
                chartLabels.append("'").append(student.get("matricNo")).append("'");
                chartPresents.append(student.get("presentCount"));
                chartAbsents.append(student.get("absentCount"));

                if (i < reportRoster.size() - 1) {
                    chartLabels.append(",");
                    chartPresents.append(",");
                    chartAbsents.append(",");
                }
            }
        }

        // Build ChartJS JSON configuration string for the QuickChart API
        String chartJson = "{"
                + "  type: 'bar',"
                + "  data: {"
                + "    labels: [" + chartLabels.toString() + "],"
                + "    datasets: ["
                + "      { label: 'Present', data: [" + chartPresents.toString() + "], backgroundColor: '#2ecc71' },"
                + "      { label: 'Absent', data: [" + chartAbsents.toString() + "], backgroundColor: '#e74c3c' }"
                + "    ]"
                + "  },"
                + "  options: {"
                + "    title: { display: true, text: 'Student Attendance Summary Records' }"
                + "  }"
                + "}";

        String graphUrl = "https://quickchart.io/chart?width=550&height=280&bkg=white&c=" + URLEncoder.encode(chartJson, "UTF-8");

        // 5. STREAM THE EXCEL-COMPLIANT HTML MARKUP WITH GRAPH EMBEDDED
        try (PrintWriter out = response.getWriter()) {
            out.println("<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:x='urn:schemas-microsoft-com:office:excel' xmlns='http://www.w3.org/TR/REC-html40'>");
            out.println("<head><meta charset='UTF-8'>");
            out.println("<style>");
            out.println("  body { font-family: Arial, sans-serif; }");
            out.println("  .title { font-size: 16pt; font-weight: bold; color: #00897B; }");
            out.println("  .meta-info { font-size: 10pt; color: #555555; font-weight: bold; }");
            out.println("  th { background-color: #00897B; color: #FFFFFF; font-weight: bold; text-align: center; border: 0.5pt solid #CCCCCC; }");
            out.println("  td { border: 0.5pt solid #CCCCCC; text-align: center; }");
            out.println("  .left { text-align: left; }");
            out.println("  .present-bg { background-color: #D1E7DD; color: #0F5132; font-weight: bold; }");
            out.println("  .absent-bg { background-color: #F8D7DA; color: #842029; font-weight: bold; }");
            out.println("</style>");
            out.println("</head><body>");

            // Header info
            out.println("<table>");
            out.println("  <tr><td class='left title' colspan='4'>" + courseCode + " — " + courseName + "</td></tr>");
            out.println("  <tr><td class='left meta-info' colspan='4'>Report Type: " + ("SINGLE".equals(reportScope) ? "Single Class Session Audit" : "Date Range Summary") + "</td></tr>");
            out.println("  <tr><td class='left meta-info' colspan='4'>Timeframe: " + startDate + ("SINGLE".equals(reportScope) ? "" : " to " + endDate) + "</td></tr>");
            out.println("  <tr><td class='left meta-info' colspan='4'>Total Scheduled Classes: " + reportMeta.get("totalSessions") + " Session(s)</td></tr>");
            out.println("  <tr><td colspan='4'></td></tr>");

            // Embed Chart Image inside Excel Rows
            out.println("  <tr><td colspan='6' style='text-align: left; height: 290px;'>");
            out.println("    <img src=\"" + graphUrl + "\" width=\"550\" height=\"280\" />");
            out.println("  </td></tr>");
            out.println("  <tr><td colspan='4'></td></tr>");
            out.println("</table>");

            // Main Performance Grid Table
            out.println("<table border='1'>");
            out.println("  <thead><tr>");
            out.println("    <th style='width: 40px;'>NO.</th>");
            out.println("    <th style='width: 100px;'>MATRIC NO</th>");
            out.println("    <th style='width: 200px;'>STUDENT FULL NAME</th>");

            if ("SINGLE".equals(reportScope)) {
                out.println("    <th style='width: 120px;'>STATUS</th>");
            } else {
                out.println("    <th style='width: 90px;'>PRESENT</th>");
                out.println("    <th style='width: 90px;'>ABSENT</th>");
                out.println("    <th style='width: 100px;'>PERCENTAGE</th>");

                if (incBreakdown && sessionsHeaderList != null) {
                    for (String sId : sessionsHeaderList) {
                        out.println("    <th style='width: 90px;'>" + sId + "</th>");
                    }
                }
            }
            out.println("  </tr></thead><tbody>");

            int counter = 1;
            int totalPresentStudentsCount = 0;
            int totalAbsentStudentsCount = 0;

            if (reportRoster != null) {
                for (Map<String, Object> student : reportRoster) {
                    out.println("  <tr>");
                    out.println("    <td>" + counter++ + "</td>");
                    out.println("    <td style='mso-number-format:\"\\@\";'>" + student.get("matricNo") + "</td>");
                    out.println("    <td class='left'>" + student.get("fullName") + "</td>");

                    int pCount = (Integer) student.get("presentCount");
                    int aCount = (Integer) student.get("absentCount");

                    totalPresentStudentsCount += pCount;
                    totalAbsentStudentsCount += aCount;

                    if ("SINGLE".equals(reportScope)) {
                        if (pCount > 0) {
                            out.println("    <td class='present-bg'>PRESENT</td>");
                        } else {
                            out.println("    <td class='absent-bg'>ABSENT</td>");
                        }
                    } else {
                        out.println("    <td>" + pCount + "</td>");
                        out.println("    <td>" + aCount + "</td>");

                        int pct = Integer.parseInt(student.get("percentage").toString());
                        String pctColor = (pct < 80) ? "#c62828" : "#00897b";
                        out.println("    <td style='font-weight: bold; color: " + pctColor + ";'>" + pct + "%</td>");

                        if (incBreakdown && sessionsHeaderList != null) {
                            Map<String, String> logsMap = (Map<String, String>) student.get("sessionLogs");
                            for (String sId : sessionsHeaderList) {
                                String statusLog = (logsMap != null) ? logsMap.get(sId) : "ABSENT";
                                if (statusLog.startsWith("PRESENT")) {
                                    out.println("    <td class='present-bg'>✔️</td>");
                                } else {
                                    out.println("    <td class='absent-bg'>❌</td>");
                                }
                            }
                        }
                    }
                    out.println("  </tr>");
                }
            }
            out.println("  </tbody>");

            // Summary Footer Metrics
            out.println("  <tfoot>");
            int totalRosterRecords = totalPresentStudentsCount + totalAbsentStudentsCount;
            double attendanceRatePercentage = (totalRosterRecords > 0) ? ((double) totalPresentStudentsCount / totalRosterRecords) * 100.0 : 0.0;
            String formattedRateStr = String.format("%.1f", attendanceRatePercentage) + "%";

            int colSpanLeft = 3;
            if ("SINGLE".equals(reportScope)) {
                out.println("    <tr><td class='left meta-info' colspan='" + colSpanLeft + "'>Total Present Students Count:</td><td>" + totalPresentStudentsCount + "</td></tr>");
                out.println("    <tr><td class='left meta-info' colspan='" + colSpanLeft + "'>Total Absent Students Count:</td><td>" + totalAbsentStudentsCount + "</td></tr>");
                out.println("    <tr><td class='left meta-info' colspan='" + colSpanLeft + "'>Class Session Attendance Rate:</td><td style='font-weight: bold; color: #00897b;'>" + formattedRateStr + "</td></tr>");
            } else {
                out.println("    <tr><td class='left meta-info' colspan='3'>Summary Totals Summary:</td><td>" + totalPresentStudentsCount + "</td><td>" + totalAbsentStudentsCount + "</td><td style='font-weight: bold; color: #00897b;'>" + formattedRateStr + "</td>" + (incBreakdown && sessionsHeaderList != null ? "<td colspan='" + sessionsHeaderList.size() + "'></td>" : "") + "</tr>");
            }
            out.println("  </tfoot>");
            out.println("</table>");
            out.println("</body></html>");
            out.flush();
        }
    }
}
