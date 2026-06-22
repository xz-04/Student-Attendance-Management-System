<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>System Report Preview</title>
        <link rel="stylesheet" href="style.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <style type="text/css">
            @media print {
                .no-print, .admin-sidebar, .sidebar-container, nav, ul, li, .logout-link, button, a {
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
                    box-shadow: none !important;
                }
                body {
                    background: #ffffff !important;
                    color: #000000 !important;
                }
                .report-preview-table {
                    width: 100% !important;
                    border: 1px solid #333333 !important;
                    border-collapse: collapse !important;
                }
                .report-preview-table th, .report-preview-table td {
                    border: 1px solid #333333 !important;
                    padding: 8px !important;
                }

                /* Keep background color fills active during paper output rendering */
                * {
                    -webkit-print-color-adjust: exact !important;
                    print-color-adjust: exact !important;
                }
                .chart-print-box {
                    max-width: 600px !important;
                    margin: 10px auto !important;
                    display: block !important;
                }
            }
            .report-preview-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 15px;
            }
            .report-preview-table th {
                background-color: #00897b;
                color: white;
                padding: 12px;
                font-weight: bold;
                text-align: center;
                border: 1px solid #e0e0e0;
                font-size: 13px;
            }
            .report-preview-table td {
                padding: 10px;
                border: 1px solid #e0e0e0;
                text-align: center;
                font-size: 13px;
            }
            .left-align {
                text-align: left !important;
            }
            .chart-print-box {
                width: 100%;
                max-width: 650px;
                margin: 25px auto;
                background: #ffffff;
                padding: 15px;
                border: 1px solid #e0e0e0;
                border-radius: 6px;
            }
        </style>
    </head>
    <body>

        <div class="no-print">
            <%@ include file="adminSidebar.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>System Report Preview</h1>
                <a href="LoadAdminReportsServlet" class="logout-link no-print" style="background-color: #555;">Back to Hub</a>
            </div>

            <div style="background-color: #fff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 6px; margin-bottom: 25px; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
                <h2 style="margin: 0 0 12px 0; color: #00897b;">Faculty Target Segment: ${param.facultyFilter}</h2>
                <div style="display: flex; gap: 40px; flex-wrap: wrap; font-size: 14px; color: #555;">
                    <c:choose>
                        <c:when test="${param.facultyFilter eq 'JSM'}">
                            <%-- Intentionally left empty --%>
                        </c:when>
                        <c:otherwise>
                            <c:if test="${param.reportType eq 'Course'}">
                                <div><strong>Timeframe Window:</strong> ${param.startDate} to ${param.endDate}</div>
                            </c:if>
                            <c:if test="${param.reportType ne 'Course'}">
                                <div><strong>Report Type Profile:</strong> ${param.reportType} Information Records Roll</div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <c:if test="${param.reportType eq 'Course' && param.facultyFilter ne 'JSM' && not empty generatedReportRows}">
                <div class="chart-print-box">
                    <canvas id="previewAnalyticsChart" style="width:100%; height:300px;"></canvas>
                </div>
            </c:if>

            <div style="background: #ffffff; padding: 25px; border: 1px solid #e0e0e0; border-radius: 6px;">
                <c:choose>
                    <%-- CONDITIONAL MATRIX A: USER SYSTEM ROSTERS (JSM, Lecturer Info, Student Info) --%>
                    <c:when test="${param.facultyFilter eq 'JSM' || param.reportType eq 'Lecturer' || param.reportType eq 'Student'}">
                        <h3 style="margin-top: 0; color: #2c3e50; border-bottom: 2px solid #00897b; padding-bottom: 10px;">
                            System Accounts Master Roll Matrix: ${param.facultyFilter} 
                            <c:if var="notJsm" test="${param.facultyFilter ne 'JSM'}">(${param.reportType} List)</c:if>
                            </h3>

                            <table class="report-preview-table">
                                <thead>
                                    <tr>
                                        <th style="width: 60px;">INDEX</th>
                                        <th style="width: 140px;">MATRIC NO</th>
                                        <th class="left-align">NAME</th>
                                        <th class="left-align">EMAIL</th>
                                        <th style="width: 160px;">PHONE NO</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="row" items="${generatedReportRows}" varStatus="status">
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <td><b><c:out value="${row.jsmMatricNo}"/></b></td>
                                        <td class="left-align"><c:out value="${row.jsmFullName}"/></td>
                                        <td class="left-align"><c:out value="${row.jsmEmail}"/></td>
                                        <td><c:out value="${row.jsmPhoneNo}"/></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty generatedReportRows}">
                                    <tr>
                                        <td colspan="5" style="color: #888; font-style: italic; padding: 20px;">No registered accounts found matching current query boundaries.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </c:when>

                    <%-- CONDITIONAL MATRIX B: DYNAMIC ATTENDANCE ANALYTICS CORES --%>
                    <c:otherwise>
                        <h3 style="margin-top: 0; color: #2c3e50; border-bottom: 2px solid #00897b; padding-bottom: 10px;">Enrolled Session Analytics Sheets</h3>

                        <table class="report-preview-table">
                            <thead>
                                <tr>
                                    <th style="width: 70px;">INDEX</th>
                                    <c:if test="${param.includeAllCourses eq 'true'}"><th>ALL COURSES BASED ON FACULTY</th></c:if>
                                    <c:if test="${param.includeSessionsCreated eq 'true'}"><th style="width: 150px;">SESSIONS CREATED</th></c:if>
                                    <c:if test="${param.includeStudentsPresent eq 'true'}"><th style="width: 190px;">TOTAL STUDENT PRESENT</th></c:if>
                                    <c:if test="${param.includePercentage eq 'true'}"><th style="width: 130px;">PERCENTAGE</th></c:if>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="row" items="${generatedReportRows}" varStatus="status">
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <c:if test="${param.includeAllCourses eq 'true'}">
                                            <td class="left-align"><b>${row.courseCode}</b> — ${row.courseName}</td>
                                                </c:if>
                                                <c:if test="${param.includeSessionsCreated eq 'true'}">
                                            <td>${row.sessionsCreated}</td>
                                        </c:if>
                                        <c:if test="${param.includeStudentsPresent eq 'true'}">
                                            <td>${row.studentsPresent}</td>
                                        </c:if>
                                        <c:if test="${param.includePercentage eq 'true'}">
                                            <c:choose>
                                                <c:when test="${row.attendancePercentage < (currentSystemThreshold != null ? currentSystemThreshold : 80)}">
                                                    <td style="font-weight: bold; color: #c62828;">${row.attendancePercentage}%</td>
                                                </c:when>
                                                <c:otherwise>
                                                    <td style="font-weight: bold; color: #00897b;">${row.attendancePercentage}%</td>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty generatedReportRows}">
                                    <tr>
                                        <td colspan="5" style="color: #888; font-style: italic; padding: 20px;">No course metadata entries recorded inside chosen limits.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>

            <div style="margin-top: 25px; display: flex; justify-content: flex-end; gap: 15px; margin-bottom: 40px;" class="no-print">
                <a href="LoadAdminReportsServlet" class="report-btn-preview" style="padding: 12px 30px; text-decoration: none; text-align: center; background-color: #eeeeee; color: #333333; border-radius: 4px; font-weight: bold; font-size: 14px; display: inline-block;">
                    ← ADJUST REPORT SELECTIONS
                </a>

                <form action="AdminReportsServlet" method="POST" style="margin: 0;">
                    <input type="hidden" name="facultyFilter" value="${param.facultyFilter}">
                    <input type="hidden" name="reportType" value="${param.reportType}">
                    <input type="hidden" name="startDate" value="${param.startDate}">
                    <input type="hidden" name="endDate" value="${param.endDate}">

                    <input type="hidden" name="includeAllCourses" value="${param.includeAllCourses}">
                    <input type="hidden" name="includeSessionsCreated" value="${param.includeSessionsCreated}">
                    <input type="hidden" name="includeStudentsPresent" value="${param.includeStudentsPresent}">
                    <input type="hidden" name="includePercentage" value="${param.includePercentage}">

                    <input type="hidden" name="actionType" value="GENERATE">
                    <input type="hidden" name="exportFormat" value="${param.exportFormat}">

                    <c:choose>
                        <c:when test="${param.exportFormat eq 'EXCEL'}">
                            <button type="submit" class="report-btn-generate" style="padding: 12px 35px; background-color: #2e7d32; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                                📥 DOWNLOAD WORKBOOK SPREADSHEET
                            </button>
                        </c:when>
                        <c:when test="${param.exportFormat eq 'CSV'}">
                            <button type="submit" class="report-btn-generate" style="padding: 12px 35px; background-color: #fbc02d; color: #333; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                                📥 DOWNLOAD TEXT RECORD CSV
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" onclick="triggerSynchronizedPrint();" class="report-btn-generate" style="padding: 12px 35px; background-color: #00897b; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                                🖨️ PRINT SYSTEM SUMMARY PDF
                            </button>
                        </c:otherwise>
                    </c:choose>
                </form>
            </div>
        </div>

        <script type="text/javascript">
            var previewChartObj = null;

            document.addEventListener('DOMContentLoaded', function () {
            <c:if test="${param.reportType eq 'Course' && param.facultyFilter ne 'JSM' && not empty generatedReportRows}">
                var canvasEl = document.getElementById('previewAnalyticsChart');
                if (canvasEl) {
                    var ctx = canvasEl.getContext('2d');
                    var labels = [];
                    var presentDataset = [];
                    var absentDataset = [];

                <c:forEach var="row" items="${generatedReportRows}">
                    labels.push("${row.courseCode}");
                    presentDataset.push(parseInt("${row.totalPresent}") || 0);
                    absentDataset.push(parseInt("${row.totalAbsent}") || 0);
                </c:forEach>

                    previewChartObj = new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: labels,
                            datasets: [
                                {label: 'Students Present', data: presentDataset, backgroundColor: '#2ecc71', borderWidth: 1},
                                {label: 'Students Absent', data: absentDataset, backgroundColor: '#e74c3c', borderWidth: 1}
                            ]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            animation: false,
                            scales: {y: {beginAtZero: true}}
                        }
                    });
                }
            </c:if>
            });

            function triggerSynchronizedPrint() {
                setTimeout(function () {
                    window.print();
                }, 200);
            }
        </script>
    </body>
</html>