package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ExportPdfReportHelper")
public class ExportPdfReportHelper extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Retrieve calculated report payloads from request scope context
        Map<String, Object> reportMeta = (Map<String, Object>) request.getAttribute("reportMeta");
        List<Map<String, Object>> reportRoster = (List<Map<String, Object>>) request.getAttribute("reportRoster");
        List<String> sessionsHeaderList = (List<String>) request.getAttribute("sessionsHeaderList");

        boolean incBreakdown = Boolean.TRUE.equals(request.getAttribute("incBreakdown"));

        String courseCode = (String) reportMeta.get("courseCode");
        String courseName = (String) reportMeta.get("courseName");
        String reportScope = (String) reportMeta.get("reportScope");
        String startDate = (String) reportMeta.get("startDate");
        String endDate = (String) reportMeta.get("endDate");

        // 2. Generate case-insensitive file parameters
        String safeFilename;
        if ("SINGLE".equals(reportScope)) {
            safeFilename = courseCode + "_" + startDate;
        } else {
            safeFilename = courseCode + "_" + startDate + "_to_" + endDate;
        }
        safeFilename = safeFilename.replaceAll("\\s+", "_");

        // 3. Configure headers to serve a printable viewport stream
        response.setContentType("text/html;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println(" <meta charset='UTF-8'>");
            out.println(" <title>" + safeFilename + "</title>");
            out.println(" <style type='text/css'>");
            out.println("   body { background: #ffffff !important; color: #000000 !important; font-family: Arial, sans-serif; padding: 20px; margin: 0; }");
            out.println("   .print-container { width: 100%; max-width: 1000px; margin: 0 auto; }");
            out.println("   .meta-card { border: 1px solid #e0e0e0; padding: 20px; border-radius: 6px; margin-bottom: 25px; background: #fafafa; }");
            out.println("   .report-table { width: 100%; border-collapse: collapse; margin-top: 15px; }");
            out.println("   .report-table th { background-color: #00897b !important; color: #ffffff !important; font-weight: bold; text-align: center; border: 1px solid #333333; padding: 10px; }");
            out.println("   .report-table td { border: 1px solid #333333; padding: 8px; font-size: 13px; }");
            out.println("   .badge-present { background-color: #d1e7dd; color: #0f5132; padding: 3px 10px; border-radius: 4px; font-weight: bold; font-size: 11px; display: inline-block; }");
            out.println("   .badge-absent { background-color: #f8d7da; color: #842029; padding: 3px 10px; border-radius: 4px; font-weight: bold; font-size: 11px; display: inline-block; }");
            out.println("   @media print { body { padding: 0; } }");
            out.println(" </style>");
            out.println("</head>");

            // Auto-triggers native OS print menu layout, then immediately closes the tab to return to the form
            out.println("<body onload='window.print(); setTimeout(function(){ window.close(); }, 500);'>");
            out.println("<div class='print-container'>");

            // Meta Information Block
            out.println(" <div class='meta-card'>");
            out.println("   <h2 style='margin: 0 0 10px 0; color: #00897b;'>" + courseCode + " — " + courseName + "</h2>");
            out.println("   <p style='margin: 5px 0;'><strong>Scope Mode:</strong> " + ("SINGLE".equals(reportScope) ? "Single Class Session" : "Date Range Summary") + "</p>");
            out.println("   <p style='margin: 5px 0;'><strong>Timeframe Selector:</strong> " + startDate + ("SINGLE".equals(reportScope) ? "" : " to " + endDate) + "</p>");
            out.println("   <p style='margin: 5px 0;'><strong>Total Classes Discovered:</strong> " + reportMeta.get("totalSessions") + " Session(s)</p>");
            out.println(" </div>");

            // Main Data Grid Element
            out.println(" <table class='report-table'>");
            out.println("   <thead>");
            out.println("     <tr>");
            out.println("       <th style='width: 50px;'>NO.</th>");
            out.println("       <th style='width: 120px;'>MATRIC NO</th>");
            out.println("       <th>STUDENT FULL NAME</th>");

            if ("SINGLE".equals(reportScope)) {
                out.println("       <th style='width: 150px;'>STATUS</th>");
            } else {
                out.println("       <th style='width: 90px;'>PRESENT</th>");
                out.println("       <th style='width: 90px;'>ABSENT</th>");
                out.println("       <th style='width: 110px;'>PERCENTAGE</th>");
                if (incBreakdown && sessionsHeaderList != null) {
                    for (String sId : sessionsHeaderList) {
                        out.println("       <th style='font-size:10px;'>" + sId + "</th>");
                    }
                }
            }
            out.println("     </tr>");
            out.println("   </thead>");
            out.println("   <tbody>");

            int counter = 1;
            int totalPresentSum = 0;
            int totalAbsentSum = 0;

            if (reportRoster != null) {
                for (Map<String, Object> student : reportRoster) {
                    int pCount = (Integer) student.get("presentCount");
                    int aCount = (Integer) student.get("absentCount");
                    totalPresentSum += pCount;
                    totalAbsentSum += aCount;

                    out.println("     <tr>");
                    out.println("       <td style='text-align:center;'>" + counter++ + "</td>");
                    out.println("       <td style='font-family:monospace;'><b>" + student.get("matricNo") + "</b></td>");
                    out.println("       <td>" + student.get("fullName") + "</td>");

                    if ("SINGLE".equals(reportScope)) {
                        out.println("       <td style='text-align:center;'>");
                        if (pCount > 0) {
                            out.println("         <span class='badge-present'>PRESENT</span>");
                        } else {
                            out.println("         <span class='badge-absent'>ABSENT</span>");
                        }
                        out.println("       </td>");
                    } else {
                        out.println("       <td style='text-align:center; color:#2e7d32; font-weight:bold;'>" + pCount + "</td>");
                        out.println("       <td style='text-align:center; color:#c62828; font-weight:bold;'>" + aCount + "</td>");
                        out.println("       <td style='text-align:center; font-weight:bold;'>" + student.get("percentage") + "%</td>");

                        if (incBreakdown && sessionsHeaderList != null) {
                            Map<String, String> logsMap = (Map<String, String>) student.get("sessionLogs");
                            for (String sId : sessionsHeaderList) {
                                String statusLog = (logsMap != null) ? logsMap.get(sId) : "ABSENT";
                                out.println("       <td style='text-align:center;'>");
                                out.println(statusLog.startsWith("PRESENT") ? "<span style='color:#2e7d32;'>✔️</span>" : "<span style='color:#c62828;'>❌</span>");
                                out.println("       </td>");
                            }
                        }
                    }
                    out.println("     </tr>");
                }
            }
            out.println("   </tbody>");

            int totalRecords = totalPresentSum + totalAbsentSum;
            double globalPercentage = totalRecords > 0 ? ((double) totalPresentSum / totalRecords) * 100.0 : 0.0;
            String formattedRateStr = String.format("%.1f", globalPercentage) + "%";

            out.println("   <tfoot style='background:#f9f9f9; font-weight:bold;'>");
            out.println("     <tr>");
            out.println("       <td colspan='3' style='text-align:right; padding:12px;'>SUMMARY METRICS MATRIX COUNTER:</td>");

            if ("SINGLE".equals(reportScope)) {
                out.println("       <td style='padding:10px; line-height:1.5;'>");
                out.println("         <div>• Total Present: <span style='color:#2e7d32;'>" + totalPresentSum + "</span></div>");
                out.println("         <div>• Total Absent: <span style='color:#c62828;'>" + totalAbsentSum + "</span></div>");
                out.println("         <div style='border-top:1px dashed #ccc; margin-top:3px; padding-top:3px;'>• Attendance Rate: <span style='color:#00897b;'>" + formattedRateStr + "</span></div>");
                out.println("       </td>");
            } else {
                out.println("       <td style='text-align:center; color:#2e7d32;'>" + totalPresentSum + "</td>");
                out.println("       <td style='text-align:center; color:#c62828;'>" + totalAbsentSum + "</td>");
                out.println("       <td style='text-align:center; color:#00897b;'>" + formattedRateStr + "</td>");
                if (incBreakdown && sessionsHeaderList != null) {
                    out.println("       <td colspan='" + sessionsHeaderList.size() + "'></td>");
                }
            }
            out.println("     </tr>");
            out.println("   </tfoot>");
            out.println(" </table>");

            out.println("</div>");
            out.println("</body>");
            out.println("</html>");
            out.flush();
        }
    }
}
