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

            <%-- Unified Banner for Warnings and Errors --%>
            <div id="validationBanner" class="admin-rules-notice-banner" 
                 style="display: ${not empty requestScope.error ? 'block' : 'none'};
                 background-color: ${not empty requestScope.error ? '#f2dede' : '#fff3cd'};
                 border-color: ${not empty requestScope.error ? '#ebccd1' : '#ffeeba'};
                 color: ${not empty requestScope.error ? '#a94442' : '#856404'};
                 padding: 12px 20px; margin-bottom: 20px; border-radius: 4px; border-left: 5px solid ${not empty requestScope.error ? '#e74c3c' : '#ffc107'};">
                <p style="margin: 0;" id="bannerTextContent">
                    <c:if test="${not empty requestScope.error}">
                        <strong>Submission Failure:</strong> ${requestScope.error}
                    </c:if>
                </p>
            </div>

            <form id="leaveApplicationForm" action="SubmitLeaveServlet" method="POST" enctype="multipart/form-data" 
                  class="leave-application-form" onsubmit="return validateForm()">

                <div class="form-group-block">
                    <label class="form-field-label">COURSE</label>
                    <select name="courseCode" class="form-dropdown-input" required>
                        <option value="" disabled selected>Select an enrolled course...</option>
                        <c:forEach var="course" items="${enrolledCoursesList}">
                            <option value="${course.courseCode}">${course.courseCode} ${course.courseName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group-block">
                    <label class="form-field-label">CLASS DATE</label>
                    <input type="date" id="sessionDateField" name="sessionDate" class="form-date-input" onchange="validateSubmissionTimeline()" required>
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
                            <input type="file" id="fileAttachment" name="supportingDoc" accept=".pdf,.png,.jpg,.jpeg" class="real-file-input">
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
            const banner = document.getElementById('validationBanner');
            const bannerText = document.getElementById('bannerTextContent');

            // Client-side File Validation
            function validateForm() {
                if (fileInput.files.length === 0) {
                    bannerText.innerHTML = "<strong>Missing Evidence:</strong> Please upload a supporting document to proceed.";
                    banner.style.display = "block";
                    banner.style.backgroundColor = "#f2dede";
                    banner.style.borderColor = "#ebccd1";
                    banner.style.color = "#a94442";
                    banner.style.borderLeft = "5px solid #e74c3c";
                    window.scrollTo(0, 0);
                    return false;
                }
                return true;
            }

            // Existing Timeline Logic
            function validateSubmissionTimeline() {
                const category = document.getElementById('leaveCategorySelect').value;
                const dateValue = document.getElementById('sessionDateField').value;

                if (category === "Event" && dateValue) {
                    const chosenDate = new Date(dateValue);
                    const today = new Date();
                    today.setHours(0, 0, 0, 0);
                    const diffDays = Math.ceil((chosenDate - today) / (1000 * 60 * 60 * 24));

                    if (diffDays < 14) {
                        bannerText.innerHTML = "<strong>Late Submission Warning:</strong> Event leaves require 2 weeks notice.";
                        banner.style.display = "block";
                        return;
                    }
                }
                banner.style.display = "none";
            }

            // File Preview Logic
            fileInput.addEventListener('change', function () {
                if (this.files.length > 0) {
                    document.getElementById('file-name-preview').innerHTML = "<strong>Selected:</strong> " + this.files[0].name;
                }
            });
        </script>
    </body>
</html>