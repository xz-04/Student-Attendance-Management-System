<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Leave Approval View</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Absence Leave Approval</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <c:if test="${not empty sessionScope.success}">
                <div class="admin-rules-notice-banner" style="background-color: #d9edf7; border-color: #bce8f1; color: #31708f; margin-bottom: 20px; padding: 12px 20px; border-radius: 4px;">
                    <p style="margin: 0;"><strong>Success:</strong> ${sessionScope.success}</p>
                </div>
                <% session.removeAttribute("success"); %>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="admin-rules-notice-banner" style="background-color: #f2dede; border-color: #ebccd1; color: #a94442; padding: 12px 20px; margin-bottom: 20px; border-radius: 4px;">
                    <p style="margin: 0;"><strong>Error:</strong> ${sessionScope.error}</p>
                </div>
                <% session.removeAttribute("error");%>
            </c:if>

            <div class="leave-filter-bar" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                <div style="display: flex; gap: 15px;">
                    <div class="filter-box-inline">
                        <label for="courseFilter">Course:</label>
                        <select id="courseFilter" name="courseFilter" onchange="applyFilters()" class="filter-dropdown-select">
                            <option value="All" selected>All Assigned Courses</option>
                            <c:forEach var="course" items="${lecturerAssignedCourses}">
                                <option value="${course.courseCode}">${course.courseCode}</option>
                            </c:forEach>
                            <c:if test="${empty lecturerAssignedCourses}">
                                <option value="CSF3023">CSF3023</option>
                                <option value="CSF3433">CSF3433</option>
                            </c:if>
                        </select>
                    </div>

                    <div class="filter-box-inline">
                        <label for="statusFilter">Status Filter:</label>
                        <select id="statusFilter" name="statusFilter" onchange="applyFilters()" class="filter-dropdown-select">
                            <option value="Pending" selected>Pending</option>
                            <option value="Approved">Approved</option>
                            <option value="Rejected">Rejected</option>
                        </select>
                    </div>
                </div>

                <%-- Added status string counter node component safely --%>
                <div id="pendingCounter" style="font-weight: bold; color: #555555; font-size: 14px;"></div>
            </div>

            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th style="width: 60px; text-align: center;">NO.</th>
                        <th>STUDENT NAME</th>
                        <th style="width: 140px;">MATRIC NO</th>
                        <th style="width: 140px;">COURSE</th>
                        <th style="width: 140px;">DATE</th>
                        <th style="width: 180px; text-align: center;">ACTIONS</th>
                    </tr>
                </thead>
                <tbody id="leaveTableBody">
                    <c:forEach var="application" items="${leaveApplicationsList}" varStatus="loop">
                        <tr class="leave-row" data-course="${application.courseCode}" data-status="${application.approvalStatus}">
                            <td style="text-align: center;" class="row-counter-cell"></td>
                            <td><strong>${application.fullName}</strong></td>
                            <td class="monospace-text">${application.matricNo}</td>
                            <td class="monospace-text">${application.courseCode}</td>
                            <td>${application.sessionDate}</td>

                            <td style="text-align: center;">
                                <div style="display: inline-flex; gap: 10px; align-items: center;">
                                    <c:choose>
                                        <c:when test="${not empty application.evidencePath}">
                                            <a href="ViewLeaveDetailsServlet?leaveId=${application.leaveId}" class="table-inline-link" style="font-weight: bold; color: #00897b; text-decoration: none;">
                                                VIEW
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #999; font-style: italic; font-size: 13px;">No Doc</span>
                                        </c:otherwise>
                                    </c:choose>

                                    <%-- MODIFIED: Show quick action processors if the active element context row state is Pending --%>
                                    <c:if test="${application.approvalStatus eq 'Pending'}">
                                        |
                                        <a href="ProcessLeaveServlet?action=approve&leaveId=${application.leaveId}" 
                                           style="color: #2e7d32; font-weight: bold; text-decoration: none; font-size: 13px;"
                                           onclick="return confirm('Approve this absence leave request?');">
                                            Approve
                                        </a>
                                        |
                                        <a href="#" 
                                           style="color: #c62828; font-weight: bold; text-decoration: none; font-size: 13px;"
                                           onclick="triggerRejectionWorkflow('${application.leaveId}'); return false;">
                                            Reject
                                        </a>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>

                    <tr id="emptyStateRow" style="display: none;">
                        <td colspan="6" style="text-align: center; color: #777777; padding: 45px; font-style: italic;">
                            No leave applications matched the selected filter criteria.
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <form id="rejectionFormHidden" action="ProcessLeaveServlet" method="POST" style="display: none;">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" id="rejectLeaveIdField" name="leaveId" value="">
            <input type="hidden" id="rejectCommentField" name="rejectReason" value="">
        </form>

        <script>
            // MODIFIED: Prompts the lecturer for a rejection description reason and posts it programmatically
            function triggerRejectionWorkflow(leaveId) {
                var reason = prompt("REJECTION DESCRIPTION REQUIREMENT:\n\nPlease enter the reason or comments for rejecting this leave application. This note will be shared with the student dashboard immediately:");

                if (reason === null) {
                    return; // Lecturer clicked cancel, abort workflow safely
                }

                if (reason.trim() === "") {
                    alert("Action Aborted: You must provide a brief rejection description to inform the student.");
                    return;
                }

                // Populate hidden values and dispatch form payload execution block matrix
                document.getElementById('rejectLeaveIdField').value = leaveId;
                document.getElementById('rejectCommentField').value = reason.trim();
                document.getElementById('rejectionFormHidden').submit();
            }

            function applyFilters() {
                const courseValue = document.getElementById('courseFilter').value;
                const statusValue = document.getElementById('statusFilter').value;
                const rows = document.querySelectorAll('.leave-row');
                const emptyRow = document.getElementById('emptyStateRow');
                let displayedIndex = 1;

                rows.forEach(row => {
                    const rowCourse = row.getAttribute('data-course');
                    const rowStatus = row.getAttribute('data-status');

                    const matchCourse = (courseValue === 'All' || rowCourse.trim().toUpperCase() === courseValue.trim().toUpperCase());
                    const matchStatus = (rowStatus.trim().toLowerCase() === statusValue.trim().toLowerCase());

                    if (matchCourse && matchStatus) {
                        row.style.display = '';
                        row.querySelector('.row-counter-cell').innerText = displayedIndex;
                        displayedIndex++;
                    } else {
                        row.style.display = 'none';
                    }
                });

                const totalRecordsFound = displayedIndex - 1;

                if (totalRecordsFound === 0) {
                    emptyRow.style.display = '';
                } else {
                    emptyRow.style.display = 'none';
                }

                document.getElementById('pendingCounter').innerText = totalRecordsFound + " " + statusValue.toLowerCase() + " requests found";
            }

            document.addEventListener("DOMContentLoaded", function () {
                applyFilters();
            });
        </script>
    </body>
</html>