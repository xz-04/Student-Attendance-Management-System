<%-- 
    Document   : applyLeave
    Created on : May 25, 2026, 3:49:34 PM
    Author     : chiaying
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Absence Leave Application</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="studentSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Application of Absence Leave</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <%-- MODIFIED: Soft warning block notification banner (Styled orange/yellow for warning state) --%>
            <div id="validationWarningBanner" class="admin-rules-notice-banner" style="display: none; background-color: #fff3cd; border-color: #ffeeba; color: #856404; padding: 12px 20px; margin-bottom: 20px; border-radius: 4px; border-left: 5px solid #ffc107;">
                <p style="margin: 0;" id="warningTextContent"></p>
            </div>

            <c:if test="${not empty requestScope.error}">
                <div class="admin-rules-notice-banner" style="background-color: #f2dede; border-color: #ebccd1; color: #a94442; padding: 12px 20px; margin-bottom: 20px; border-radius: 4px;">
                    <p style="margin: 0;"><strong>Submission Failure:</strong> <c:out value="${requestScope.error}" /></p>
                </div>
            </c:if>

            <form id="leaveApplicationForm" action="SubmitLeaveServlet" method="POST" enctype="multipart/form-data" class="leave-application-form">

                <div class="form-group-block">
                    <label class="form-field-label">COURSE</label>
                    <select name="courseCode" class="form-dropdown-input" required>
                        <option value="" disabled selected>Select an enrolled course...</option>
                        <c:forEach var="course" items="${enrolledCoursesList}">
                            <option value="${course.courseCode}">
                                ${course.courseCode} ${course.courseName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group-block">
                    <label class="form-field-label">CLASS DATE</label>
                    <div class="datetime-input-row">
                        <input type="date" id="sessionDateField" name="sessionDate" class="form-date-input" onchange="validateSubmissionTimeline()" required>
                    </div>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">LEAVE CATEGORY</label>
                    <select id="leaveCategorySelect" name="leaveCategory" class="form-dropdown-input" onchange="validateSubmissionTimeline()" required>
                        <option value="" disabled selected>-- Select Reason Classification --</option>
                        <option value="Sick">Sick (Medical / Health Leave)</option>
                        <option value="Event">Event (Official / Co-curricular / Match)</option>
                        <option value="Others">Others</option>
                    </select>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">REASON FOR ABSENCE</label>
                    <textarea name="absenceReason" class="form-textarea-input" placeholder="Describe your reason for absence here..." required></textarea>
                </div>

                <div class="form-group-block">
                    <label class="form-field-label">SUPPORTING EVIDENCE</label>
                    <div class="file-dropzone-container" id="dropzone">
                        <div class="dropzone-inner-content">
                            <p class="dropzone-text">Drag & drop file or</p>

                            <label for="fileAttachment" class="file-mock-btn">UPLOAD FILE</label>
                            <input type="file" id="fileAttachment" name="supportingDoc" accept=".pdf,.png,.jpg,.jpeg" class="real-file-input" required>

                            <p id="file-name-preview" class="file-spec-info">Accepted: PDF, JPG, PNG - Max 5MB</p>
                        </div>
                    </div>
                </div>

                <div class="form-actions-footer">
                    <button type="submit" class="submit-application-btn">SUBMIT APPLICATION</button>
                    <a href="LeaveServlet?status=all" class="cancel-application-btn">CANCEL</a>
                </div>

            </form>
        </div>

        <script>
            const fileInput = document.getElementById('fileAttachment');
            const fileNamePreview = document.getElementById('file-name-preview');
            const dropzone = document.getElementById('dropzone');

            const categorySelect = document.getElementById('leaveCategorySelect');
            const dateField = document.getElementById('sessionDateField');
            const warningBanner = document.getElementById('validationWarningBanner');
            const warningText = document.getElementById('warningTextContent');

            // MODIFIED: Real-time soft timeline warning engine
            function validateSubmissionTimeline() {
                const category = categorySelect.value;
                const dateValue = dateField.value;

                if (category === "Event" && dateValue) {
                    const chosenDate = new Date(dateValue);
                    chosenDate.setHours(0, 0, 0, 0);

                    const today = new Date();
                    today.setHours(0, 0, 0, 0);

                    // Compute physical difference in calendar day count metrics
                    const diffTime = chosenDate - today;
                    const diffDays = Math.ceil(diffTime / (1024 * 60 * 60 * 24));

                    if (diffDays < 14) {
                        // Displaying a soft warning notice, but always returning true to allow standard form progression
                        warningText.innerHTML = "<strong>Late Submission Warning:</strong> Official event leaves should be submitted at least <strong>2 weeks (14 days) in advance</strong>. You may still proceed with this submission, but it will be flagged as late for reviewer consideration.";
                        warningBanner.style.display = "block";
                        return true;
                    }
                }

                // Hide banner smoothly if requirements are checked or rectified safely
                warningBanner.style.display = "none";
                return true;
            }

            fileInput.addEventListener('change', function () {
                if (this.files.length > 0) {
                    fileNamePreview.innerHTML = "<strong>Selected:</strong> " + this.files[0].name + " (" + (this.files[0].size / 1024 / 1024).toFixed(2) + " MB)";
                    fileNamePreview.style.color = "#00897b";
                }
            });

            // Add classic visual drag over tracking
            ['dragenter', 'dragover'].forEach(eventName => {
                dropzone.addEventListener(eventName, (e) => {
                    e.preventDefault();
                    dropzone.style.borderColor = "#00897b";
                    dropzone.style.backgroundColor = "rgba(0, 150, 136, 0.05)";
                }, false);
            });

            ['dragleave', 'drop'].forEach(eventName => {
                dropzone.addEventListener(eventName, (e) => {
                    e.preventDefault();
                    dropzone.style.borderColor = "#333333";
                    dropzone.style.backgroundColor = "#e8e6e0";
                }, false);
            });

            dropzone.addEventListener('drop', (e) => {
                const dt = e.dataTransfer;
                const files = dt.files;

                if (files.length > 0) {
                    fileInput.files = files;
                    fileNamePreview.innerHTML = "<strong>Dropped:</strong> " + files[0].name + " (" + (files[0].size / 1024 / 1024).toFixed(2) + " MB)";
                    fileNamePreview.style.color = "#00897b";
                }
            });
        </script>
    </body>
</html>