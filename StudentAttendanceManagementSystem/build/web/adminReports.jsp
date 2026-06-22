<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>System Reports</title>
        <link rel="stylesheet" href="style.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Reports</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <form id="adminReportForm" action="AdminReportsServlet" method="POST" class="leave-application-form">

                <div class="form-group-block">
                    <label class="form-field-label">SELECT FACULTY</label>
                    <select name="facultyFilter" id="facultyFilterSelect" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px;" required>
                        <option value="All" selected>All Faculties & Departments</option>
                        <c:forEach var="fac" items="${facultiesList}">
                            <option value="${fac.facultyName}">${fac.facultyName} (${fac.facultyFullname})</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group-block" id="reportTypeSection" style="margin-top: 20px;">
                    <label class="form-field-label">SELECT REPORT TYPE</label>
                    <select name="reportType" id="reportTypeSelect" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px;" required>
                        <option value="Course" selected>Course Session Attendance Analytics</option>
                        <option value="Lecturer">Lecturer Information Roster</option>
                        <option value="Student">Student Information Roster</option>
                    </select>
                </div>

                <div id="classSessionSection" class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">TIMEFRAME SELECTOR</label>
                    <div class="datetime-input-row" style="display: flex; gap: 20px; flex-wrap: wrap; align-items: center; margin-top: 5px;">
                        <div class="time-input-group">
                            <span class="input-inline-label" style="font-weight: bold; color: #555;">From Date:</span>
                            <input type="date" name="startDate" id="startDateInput" class="form-date-input" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px;" required>
                        </div>
                        <div class="time-input-group">
                            <span class="input-inline-label" style="font-weight: bold; color: #555;">To Date:</span>
                            <input type="date" name="endDate" id="endDateInput" class="form-date-input" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px;" required>
                        </div>
                    </div>
                </div>

                <div id="systemMetricsSection" class="form-group-block" style="gap: 12px; margin-top: 25px; display: flex; flex-direction: column;">
                    <label class="form-field-label">SYSTEM METRICS TO INCLUDE</label>
                    <label class="form-checkbox-label-wrapper" style="cursor: pointer; display: flex; align-items: center; gap: 8px;">
                        <input type="checkbox" name="includeAllCourses" value="true" checked class="real-custom-checkbox">
                        <span class="checkbox-mock-label-text">All Courses Based on the Faculty Selected</span>
                    </label>
                    <label class="form-checkbox-label-wrapper" style="cursor: pointer; display: flex; align-items: center; gap: 8px;">
                        <input type="checkbox" name="includeSessionsCreated" value="true" checked class="real-custom-checkbox">
                        <span class="checkbox-mock-label-text">Sessions Created</span>
                    </label>
                    <label class="form-checkbox-label-wrapper" style="cursor: pointer; display: flex; align-items: center; gap: 8px;">
                        <input type="checkbox" name="includeStudentsPresent" value="true" checked class="real-custom-checkbox">
                        <span class="checkbox-mock-label-text">Total Student Present</span>
                    </label>
                    <label class="form-checkbox-label-wrapper" style="cursor: pointer; display: flex; align-items: center; gap: 8px;">
                        <input type="checkbox" name="includePercentage" value="true" checked class="real-custom-checkbox">
                        <span class="checkbox-mock-label-text">Percentage</span>
                    </label>
                </div>

                <div class="form-group-block" style="gap: 12px; margin-top: 25px;">
                    <label class="form-field-label">EXPORT FORMAT</label>
                    <div class="radio-options-inline-row" style="display: flex; gap: 25px; margin-top: 5px;">
                        <label class="form-radio-label-wrapper" for="admFmtPdf" style="cursor: pointer;">
                            <input type="radio" name="exportFormat" value="PDF" id="admFmtPdf" checked class="real-custom-radio">
                            <span class="radio-mock-label-text" style="margin-left: 4px; font-weight: bold;">PDF Document (.pdf)</span>
                        </label>
                        <label class="form-radio-label-wrapper" for="admFmtExcel" style="cursor: pointer;">
                            <input type="radio" name="exportFormat" value="EXCEL" id="admFmtExcel" class="real-custom-radio">
                            <span class="radio-mock-label-text" style="margin-left: 4px; font-weight: bold;">Excel Spreadsheet (.xlsx)</span>
                        </label>
                        <label class="form-radio-label-wrapper" for="admFmtCsv" style="cursor: pointer;">
                            <input type="radio" name="exportFormat" value="CSV" id="admFmtCsv" class="real-custom-radio">
                            <span class="radio-mock-label-text" style="margin-left: 4px; font-weight: bold;">CSV Plain Text (.csv)</span>
                        </label>
                    </div>
                </div>

                <div class="form-actions-footer" style="margin-top: 40px; display: flex; gap: 15px;">
                    <button type="submit" name="actionType" value="GENERATE" onclick="configureAdminFormTarget('GENERATE');" class="report-btn-generate" style="padding: 12px 30px; background-color: #00897b; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                        &darr; GENERATE SYSTEM REPORT
                    </button>
                    <button type="submit" name="actionType" value="PREVIEW" id="previewLiveBtn" onclick="configureAdminFormTarget('PREVIEW');" class="report-btn-preview" style="padding: 12px 30px; background-color: #34495e; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                        PREVIEW LIVE METRICS
                    </button>
                </div>
            </form>

            <c:if test="${not empty reportDataPreview}">
                <div class="leave-application-form" style="margin-top: 35px; padding: 25px; background-color: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                    <h2 style="color: #2c3e50; font-size: 18px; border-bottom: 2px solid #eaeaea; padding-bottom: 10px; margin-top: 0;">
                        📊 Attendance Metrics Visualization Summary
                    </h2>

                    <div style="width: 100%; max-width: 700px; margin: 20px auto;">
                        <canvas id="attendanceChartCanvas"></canvas>
                    </div>
                </div>
            </c:if>
        </div>

        <script type="text/javascript">
            document.addEventListener('DOMContentLoaded', function () {
                var facultySelect = document.getElementById('facultyFilterSelect');
                var reportTypeSelect = document.getElementById('reportTypeSelect');
                var reportTypeSection = document.getElementById('reportTypeSection');
                var classSessionSection = document.getElementById('classSessionSection');
                var systemMetricsSection = document.getElementById('systemMetricsSection');
                var startDateInput = document.getElementById('startDateInput');
                var endDateInput = document.getElementById('endDateInput');
                var previewLiveBtn = document.getElementById('previewLiveBtn');

                function updateFormLayout() {
                    var faculty = facultySelect.value.toUpperCase().trim();
                    var reportType = reportTypeSelect.value;

                    if (faculty === 'JSM') {
                        reportTypeSection.style.display = 'none';
                        classSessionSection.style.display = 'none';
                        systemMetricsSection.style.display = 'none';
                        previewLiveBtn.style.display = 'inline-block';

                        startDateInput.removeAttribute('required');
                        endDateInput.removeAttribute('required');
                        startDateInput.value = '';
                        endDateInput.value = '';
                    } else {
                        reportTypeSection.style.display = 'block';

                        if (reportType === 'Course') {
                            classSessionSection.style.display = 'block';
                            systemMetricsSection.style.display = 'flex';
                            startDateInput.setAttribute('required', 'required');
                            endDateInput.setAttribute('required', 'required');
                        } else {
                            classSessionSection.style.display = 'none';
                            systemMetricsSection.style.display = 'none';
                            startDateInput.removeAttribute('required');
                            endDateInput.removeAttribute('required');
                            startDateInput.value = '';
                            endDateInput.value = '';
                        }
                        previewLiveBtn.style.display = 'inline-block';
                    }
                }

                startDateInput.addEventListener('change', function () {
                    if (startDateInput.value)
                        endDateInput.min = startDateInput.value;
                });

                facultySelect.addEventListener('change', updateFormLayout);
                reportTypeSelect.addEventListener('change', updateFormLayout);
                updateFormLayout();

                // ----------------------------------------------------
                // DYNAMIC CHART.JS GRAPH BUILDER LAYER
                // ----------------------------------------------------
            <c:if test="${not empty reportDataPreview}">
                var ctx = document.getElementById('attendanceChartCanvas').getContext('2d');

                // Arrays containing database attributes supplied from AdminReportsServlet
                var courseLabels = [];
                var totalPresentData = [];
                var totalAbsentData = [];

                <c:forEach var="row" items="${reportDataPreview}">
                courseLabels.push("${row.courseCode}");
                totalPresentData.push(${row.totalPresent});
                totalAbsentData.push(${row.totalAbsent});
                </c:forEach>

                new Chart(ctx, {
                    type: 'bar', // Using grouped bar chart layout metrics
                    data: {
                        labels: courseLabels,
                        datasets: [
                            {
                                label: 'Students Present',
                                data: totalPresentData,
                                backgroundColor: '#2ecc71', // Green tint
                                borderColor: '#27ae60',
                                borderWidth: 1
                            },
                            {
                                label: 'Students Absent',
                                data: totalAbsentData,
                                backgroundColor: '#e74c3c', // Red tint
                                borderColor: '#c0392b',
                                borderWidth: 1
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            legend: {position: 'top'}
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                title: {display: true, text: 'Number of Students'}
                            },
                            x: {
                                title: {display: true, text: 'Course Codes'}
                            }
                        }
                    }
                });
            </c:if>
            });

            function configureAdminFormTarget(mode) {
                var formElement = document.getElementById('adminReportForm');
                var selectedFormat = document.querySelector('input[name="exportFormat"]:checked').value;
                if (mode === 'GENERATE' && selectedFormat === 'PDF') {
                    formElement.setAttribute('target', '_blank');
                } else {
                    formElement.removeAttribute('target');
                }
            }
        </script>
    </body>
</html>