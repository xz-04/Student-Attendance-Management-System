<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Report Generation</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Report Generation Hub</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <%-- FIXED: Added id="reportForm" so the JavaScript target routing can find this element --%>
            <form id="reportForm" action="${pageContext.request.contextPath}/GenerateReportServlet" method="POST" class="leave-application-form">

                <div class="form-group-block">
                    <label class="form-field-label">SELECT COURSE MODULE</label>
                    <select name="courseCode" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px;" required>
                        <option value="" disabled selected>-- Select an Active Course --</option>
                        <c:forEach var="course" items="${lecturerCourses}">
                            <option value="${course.courseCode}">${course.courseCode} — ${course.courseName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">REPORT SCOPE TYPE</label>
                    <div class="radio-options-inline-row" style="display: flex; gap: 30px; margin-top: 5px;">
                        <label class="form-radio-label-wrapper" style="cursor: pointer;">
                            <input type="radio" name="reportScope" value="RANGE" checked id="scopeRange" class="real-custom-radio">
                            <span class="radio-mock-label-text" style="font-weight: bold; margin-left: 5px;">Date Range Summary (Multiple Sessions)</span>
                        </label>
                        <label class="form-radio-label-wrapper" style="cursor: pointer;">
                            <input type="radio" name="reportScope" value="SINGLE" id="scopeSingle" class="real-custom-radio">
                            <span class="radio-mock-label-text" style="font-weight: bold; margin-left: 5px;">Single Class Session Audit</span>
                        </label>
                    </div>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label" id="dateSectionHeader">TIMEFRAME SELECTOR</label>
                    <div class="datetime-input-row" style="display: flex; gap: 20px; flex-wrap: wrap; align-items: center; margin-top: 5px;">
                        <div class="time-input-group">
                            <span class="input-inline-label" id="startDateLabel" style="font-weight: bold; color: #555;">From Date:</span>
                            <input type="date" name="startDate" id="startDateInput" class="form-date-input" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px;" required>
                        </div>
                        <div class="time-input-group" id="endDateContainer">
                            <span class="input-inline-label" style="font-weight: bold; color: #555;">To Date:</span>
                            <input type="date" name="endDate" id="endDateInput" class="form-date-input" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px;" required>
                        </div>
                    </div>
                </div>

                <div class="form-group-block" style="gap: 12px; margin-top: 25px; display: flex; flex-direction: column;">
                    <label class="form-field-label">REPORT ANALYTICS CONTENT</label>
                    <label class="form-checkbox-label-wrapper" style="cursor: pointer; display: flex; align-items: center; gap: 8px;">
                        <input type="checkbox" name="contentSummary" value="true" checked class="real-custom-checkbox">
                        <span class="checkbox-mock-label-text">All Students General Percentage Summary</span>
                    </label>
                    <label class="form-checkbox-label-wrapper" style="cursor: pointer; display: flex; align-items: center; gap: 8px;">
                        <input type="checkbox" name="contentThreshold" value="true" checked class="real-custom-checkbox">
                        <span class="checkbox-mock-label-text" style="color: #c62828; font-weight: bold;">
                            Flag Barred/Below Threshold Students (<c:out value="${not empty currentSystemThreshold ? currentSystemThreshold : 80}"/>% Attendance)
                        </span>
                    </label>
                    <label class="form-checkbox-label-wrapper" style="cursor: pointer; display: flex; align-items: center; gap: 8px;">
                        <input type="checkbox" name="contentBreakdown" value="true" class="real-custom-checkbox">
                        <span class="checkbox-mock-label-text">Detailed Session-by-Session Arrival Log Matrix</span>
                    </label>
                </div>

                <div class="form-group-block" style="gap: 12px; margin-top: 25px;">
                    <label class="form-field-label">DOWNLOAD EXPORT FORMAT</label>
                    <div class="radio-options-inline-row" style="display: flex; gap: 25px; margin-top: 5px;">
                        <label class="form-radio-label-wrapper" for="fmtPdf" style="cursor: pointer;">
                            <input type="radio" name="exportFormat" value="PDF" id="fmtPdf" checked class="real-custom-radio">
                            <span class="radio-mock-label-text" style="margin-left: 4px; font-weight: bold;">PDF Document (.pdf)</span>
                        </label>
                        <label class="form-radio-label-wrapper" for="fmtExcel" style="cursor: pointer;">
                            <input type="radio" name="exportFormat" value="EXCEL" id="fmtExcel" class="real-custom-radio">
                            <span class="radio-mock-label-text" style="margin-left: 4px; font-weight: bold;">Excel Sheet (.xlsx)</span>
                        </label>
                        <label class="form-radio-label-wrapper" for="fmtCsv" style="cursor: pointer;">
                            <input type="radio" name="exportFormat" value="CSV" id="fmtCsv" class="real-custom-radio">
                            <span class="radio-mock-label-text" style="margin-left: 4px; font-weight: bold;">Comma Separated CSV (.csv)</span>
                        </label>
                    </div>
                </div>

                <div class="form-actions-footer" style="margin-top: 40px; display: flex; gap: 15px;">
                    <button type="submit" name="actionType" value="GENERATE" onclick="configureFormTarget('GENERATE');" class="report-btn-generate" style="padding: 12px 30px; background-color: #00897b; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                        &darr; GENERATE & EXPORT
                    </button>
                    <button type="submit" name="actionType" value="PREVIEW" onclick="configureFormTarget('PREVIEW');" class="report-btn-preview" style="padding: 12px 30px; background-color: #34495e; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 14px;">
                        LIVE PREVIEW
                    </button>
                </div>

            </form>
        </div>

        <script type="text/javascript">
            // FIXED: Consolidated duplicate functions into one global handler
            function configureFormTarget(mode) {
                var formElement = document.getElementById('reportForm');
                if (!formElement)
                    return;

                var checkedRadio = document.querySelector('input[name="exportFormat"]:checked');
                var selectedFormat = checkedRadio ? checkedRadio.value : 'PDF';

                if (mode === 'GENERATE' && selectedFormat === 'PDF') {
                    // For PDF: open a blank tab so rendering doesn't freeze the session
                    formElement.setAttribute('target', '_blank');
                } else {
                    // For Excel, CSV, or Preview: maintain local stream
                    formElement.removeAttribute('target');
                }
            }

            document.addEventListener('DOMContentLoaded', function () {
                var scopeRange = document.getElementById('scopeRange');
                var scopeSingle = document.getElementById('scopeSingle');
                var endDateContainer = document.getElementById('endDateContainer');
                var startDateLabel = document.getElementById('startDateLabel');
                var endDateInput = document.getElementById('endDateInput');

                function updateFormInputsLayout() {
                    if (scopeSingle && scopeSingle.checked) {
                        if (startDateLabel)
                            startDateLabel.textContent = "Session Date:";
                        if (endDateContainer)
                            endDateContainer.style.display = "none";
                        if (endDateInput) {
                            endDateInput.removeAttribute("required");
                            endDateInput.value = "";
                        }
                    } else {
                        if (startDateLabel)
                            startDateLabel.textContent = "From Date:";
                        if (endDateContainer)
                            endDateContainer.style.display = "block";
                        if (endDateInput)
                            endDateInput.setAttribute("required", "required");
                    }
                }

                if (scopeRange)
                    scopeRange.addEventListener('change', updateFormInputsLayout);
                if (scopeSingle)
                    scopeSingle.addEventListener('change', updateFormInputsLayout);

                updateFormInputsLayout();
            });
        </script>
    </body>
</html>