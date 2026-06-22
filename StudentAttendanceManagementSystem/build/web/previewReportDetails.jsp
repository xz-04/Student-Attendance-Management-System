<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Report Preview</title>
        <link rel="stylesheet" href="style.css">
        <!-- Include Chart.js via official secure CDN network link -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <style type="text/css">
            /* Master Print Document Styling Rules overrides */
            @media print {
                .no-print, .lecturer-sidebar, .sidebar-container, nav, ul, li, .logout-link, button, a {
                    display: none !important;
                    visibility: hidden !important;
                }
                .main-content {
                    margin: 0 !important;
                    padding: 0 !important;
                    position: absolute !important;
                    left: 0 !important;
                    top: 0 !important;
                    width: 100% !important;
                }
                body {
                    background: #ffffff !important;
                    color: #000000 !important;
                }
                .dashboard-records-table {
                    width: 100% !important;
                    border: 1px solid #333333 !important;
                    border-collapse: collapse !important;
                }
                .dashboard-records-table th, .dashboard-records-table td {
                    border: 1px solid #333333 !important;
                    padding: 8px !important;
                }

                /* FIXED: Forces the browser to preserve canvas colors, fills, and charts on print */
                * {
                    -webkit-print-color-adjust: exact !important;
                    print-color-adjust: exact !important;
                }

                .chart-print-wrapper {
                    max-width: 320px !important;
                    margin: 10px auto !important;
                    display: block !important;
                }
            }
        </style>
    </head>
    <body>

        <div class="no-print">
            <%@ include file="lecturerSidebar.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Attendance Report Preview</h1>
                <a href="LoadReportGenerationServlet" class="logout-link no-print" style="background-color: #555;">Back to Hub</a>
            </div>

            <div style="background-color: #fff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 6px; margin-bottom: 25px; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
                <h2 style="margin: 0 0 15px 0; color: #00897b;">${reportMeta.courseCode} — ${reportMeta.courseName}</h2>
                <div style="display: flex; gap: 40px; flex-wrap: wrap; font-size: 14px;">
                    <div><strong>Scope Mode:</strong> ${reportMeta.reportScope eq 'SINGLE' ? 'Single Class Session' : 'Date Range Summary'}</div>
                    <div><strong>Timeframe:</strong> ${reportMeta.startDate} ${reportMeta.reportScope ne 'SINGLE' ? ' to '.concat(reportMeta.endDate) : ''}</div>
                    <div><strong>Total Classes Discovered:</strong> <span style="background: #333; color: #fff; padding: 2px 8px; border-radius: 10px; font-weight: bold;">${reportMeta.totalSessions} Sessions</span></div>
                </div>
            </div>

            <!-- GRAPH VISUALIZATION PANEL WRAPPER -->
            <div class="chart-print-wrapper" style="background: #ffffff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 6px; margin-bottom: 25px; display: flex; justify-content: center; align-items: center; max-height: 360px;">
                <div style="width: 100%; max-width: 300px; height: 300px; position: relative;">
                    <canvas id="rosterSummaryDoughnutChart"></canvas>
                </div>
            </div>

            <div style="background: #ffffff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 6px;">
                <h3 style="margin-top: 0; color: #2c3e50; border-bottom: 2px solid #00897b; padding-bottom: 10px;">Student Attendance Performance Records</h3>

                <c:set var="globalPresentSum" value="0" />
                <c:set var="globalAbsentSum" value="0" />

                <table class="dashboard-records-table" style="margin-top: 15px; width: 100%;">
                    <thead>
                        <tr>
                            <th style="width: 60px; text-align: center;">NO.</th>
                            <th style="width: 140px;">MATRIC NO</th>
                            <th>STUDENT FULL NAME</th>

                            <c:choose>
                                <c:when test="${reportMeta.reportScope eq 'SINGLE'}">
                                    <th style="width: 160px; text-align: center;">STATUS</th>
                                    </c:when>
                                    <c:otherwise>
                                    <th style="width: 100px; text-align: center;">PRESENT</th>
                                    <th style="width: 100px; text-align: center;">ABSENT</th>
                                    <th style="width: 120px; text-align: center;">PERCENTAGE</th>
                                    </c:otherwise>
                                </c:choose>

                            <c:if test="${incBreakdown && reportMeta.reportScope ne 'SINGLE'}">
                                <c:forEach var="sessId" items="${sessionsHeaderList}">
                                    <th style="font-size: 11px; text-align: center;" class="monospace-text">${sessId}</th>
                                    </c:forEach>
                                </c:if>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="student" items="${reportRoster}" varStatus="status">
                            <c:set var="globalPresentSum" value="${globalPresentSum + student.presentCount}" />
                            <c:set var="globalAbsentSum" value="${globalAbsentSum + student.absentCount}" />

                            <tr style="${student.isBelowThreshold && reportMeta.reportScope ne 'SINGLE' ? 'background-color: #fff5f5;' : 'background-color: #ffffff;'}">
                                <td style="text-align: center; color: #777;">${status.count}</td>
                                <td class="monospace-text"><strong>${student.matricNo}</strong></td>
                                <td>${student.fullName}</td>

                                <c:choose>
                                    <c:when test="${reportMeta.reportScope eq 'SINGLE'}">
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${student.presentCount gt 0}">
                                                    <span style="background-color: #d1e7dd; color: #0f5132; padding: 4px 14px; border-radius: 4px; font-size: 11px; font-weight: bold; display: inline-block; width: 75px; text-align: center;">PRESENT</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="background-color: #f8d7da; color: #842029; padding: 4px 14px; border-radius: 4px; font-size: 11px; font-weight: bold; display: inline-block; width: 75px; text-align: center;">ABSENT</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </c:when>
                                    <c:otherwise>
                                        <td style="text-align: center; font-weight: bold; color: #2e7d32;">${student.presentCount}</td>
                                        <td style="text-align: center; font-weight: bold; color: #c62828;">${student.absentCount}</td>
                                        <td style="text-align: center;">
                                            <span style="font-weight: bold; color: ${student.isBelowThreshold ? '#c62828' : '#2e7d32'};">${student.percentage}%</span>
                                        </td>
                                    </c:otherwise>
                                </c:choose>

                                <c:if test="${incBreakdown && reportMeta.reportScope ne 'SINGLE'}">
                                    <c:forEach var="sessId" items="${sessionsHeaderList}">
                                        <td style="text-align: center; font-size: 11px;">
                                            <span style="color: ${student.sessionLogs[sessId] eq 'ABSENT' ? '#c62828' : '#2e7d32'}; font-weight: bold;">
                                                ${student.sessionLogs[sessId] eq 'ABSENT' ? '❌' : '✔️'}
                                            </span>
                                        </td>
                                    </c:forEach>
                                </c:if>
                            </tr>
                        </c:forEach>
                    </tbody>

                    <c:if test="${not empty reportRoster}">
                        <c:set var="totalRecords" value="${globalPresentSum + globalAbsentSum}" />
                        <c:set var="globalPercentage" value="${totalRecords gt 0 ? (globalPresentSum / totalRecords) * 100.0 : 0.0}" />

                        <tfoot style="border-top: 3px double #00897b; background-color: #fafafa; font-weight: bold;">
                            <tr>
                                <td colspan="3" style="text-align: right; padding: 15px; color: #333; font-size: 13px;">SUMMARY METRICS SUMMARY:</td>
                                <c:choose>
                                    <c:when test="${reportMeta.reportScope eq 'SINGLE'}">
                                        <td colspan="1" style="padding: 12px; font-size: 13px; color: #2c3e50; line-height: 1.6;">
                                            <div style="display: flex; flex-direction: column; gap: 4px; text-align: left; padding-left: 10px;">
                                                <div>• Total Present: <span style="color: #2e7d32;">${globalPresentSum}</span></div>
                                                <div>• Total Absent: <span style="color: #c62828;">${globalAbsentSum}</span></div>
                                                <div style="border-top: 1px dashed #ccc; margin-top: 4px; padding-top: 4px;">
                                                    • Attendance Rate: <span style="color: #00897b;"><c:out value="${fn:substringBefore(globalPercentage + 0.05, '.')}" />.<c:out value="${fn:substring(fn:substringAfter(globalPercentage + 0.05, '.'), 0, 1)}" />%</span>
                                                </div>
                                            </div>
                                        </td>
                                    </c:when>
                                    <c:otherwise>
                                        <td style="text-align: center; color: #2e7d32; font-size: 14px;">${globalPresentSum}</td>
                                        <td style="text-align: center; color: #c62828; font-size: 14px;">${globalAbsentSum}</td>
                                        <td style="text-align: center; color: #00897b; font-size: 14px;">
                                            <c:out value="${fn:substringBefore(globalPercentage + 0.05, '.')}" />.<c:out value="${fn:substring(fn:substringAfter(globalPercentage + 0.05, '.'), 0, 1)}" />%
                                        </td>
                                        <c:if test="${incBreakdown}"><td colspan="${sessionsHeaderList.size()}"></td></c:if>
                                    </c:otherwise>
                                </c:choose>
                            </tr>
                        </tfoot>
                    </c:if>
                </table>
            </div>

            <div style="margin-top: 25px; display: flex; justify-content: flex-end; gap: 15px; margin-bottom: 40px;" class="no-print">
                <a href="LoadReportGenerationServlet" class="report-btn-preview" style="padding: 12px 30px; text-decoration: none; text-align: center; background-color: #eeeeee; color: #333333; border-radius: 4px; font-weight: bold; font-size: 14px; display: inline-block;">
                    ← CONFIGURE NEW REPORT
                </a>

                <form action="${pageContext.request.contextPath}/GenerateReportServlet" method="POST" style="margin: 0;">
                    <input type="hidden" name="courseCode" value="${reportMeta.courseCode}">
                    <input type="hidden" name="reportScope" value="${reportMeta.reportScope}">
                    <input type="hidden" name="startDate" value="${reportMeta.startDate}">
                    <input type="hidden" name="endDate" value="${reportMeta.endDate}">
                    <input type="hidden" name="contentSummary" value="${incSummary ? 'true' : 'false'}">
                    <input type="hidden" name="contentThreshold" value="${incThreshold ? 'true' : 'false'}">
                    <input type="hidden" name="contentBreakdown" value="${incBreakdown ? 'true' : 'false'}">
                    <input type="hidden" name="exportFormat" value="${reportMeta.exportFormat}">
                    <input type="hidden" name="actionType" value="GENERATE">

                    <c:choose>
                        <c:when test="${reportMeta.exportFormat eq 'EXCEL'}">
                            <button type="submit" class="report-btn-generate" style="padding: 12px 35px; background-color: #2e7d32; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                                📥 DOWNLOAD EXCEL SPREADSHEET
                            </button>
                        </c:when>
                        <c:when test="${reportMeta.exportFormat eq 'CSV'}">
                            <button type="submit" class="report-btn-generate" style="padding: 12px 35px; background-color: #fbc02d; color: #333; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                                📥 DOWNLOAD CSV DOCUMENT
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" onclick="triggerPrintWithChart();" class="report-btn-generate" style="padding: 12px 35px; background-color: #00897b; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                                🖨️ PRINT / SAVE AS PDF
                            </button>
                        </c:otherwise>
                    </c:choose>
                </form>
            </div>
        </div>

        <!-- SCRIPT GENERATOR FOR DRAWING THE GRAPH -->
        <script type="text/javascript">
            var reportChartInstance = null;

            document.addEventListener('DOMContentLoaded', function () {
                var ctx = document.getElementById('rosterSummaryDoughnutChart').getContext('2d');

                var presentSum = parseInt("${globalPresentSum}") || 0;
                var absentSum = parseInt("${globalAbsentSum}") || 0;

                reportChartInstance = new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Present Slots', 'Absent Slots'],
                        datasets: [{
                                data: [presentSum, absentSum],
                                backgroundColor: ['#2ecc71', '#e74c3c'],
                                borderColor: ['#27ae60', '#c0392b'],
                                borderWidth: 1
                            }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        // Disabled animation completely so it's fully painted for print engine instantly
                        animation: false,
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: {boxWidth: 12, font: {size: 12}}
                            },
                            title: {
                                display: true,
                                text: 'Aggregate Attendance Share Summary',
                                font: {size: 14, weight: 'bold'}
                            }
                        }
                    }
                });
            });

            function triggerPrintWithChart() {
                window.print();
            }
        </script>
    </body>
</html>