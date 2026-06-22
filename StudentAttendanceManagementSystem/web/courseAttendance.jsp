<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Course Attendance & Enrollment</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="studentSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Course Attendance Overview</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <c:if test="${not empty sessionScope.success}">
                <div class="admin-rules-notice-banner" style="background-color: #d9edf7; border-color: #bce8f1; color: #31708f; margin-bottom: 20px; padding: 12px; border-radius: 4px;">
                    <p class="notice-text-content"><strong>Success:</strong> ${sessionScope.success}</p>
                </div>
                <% session.removeAttribute("success"); %>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="admin-rules-notice-banner" style="background-color: #f2dede; border-color: #ebccd1; color: #a94442; margin-bottom: 20px; padding: 12px; border-radius: 4px;">
                    <p class="notice-text-content"><strong>Error:</strong> ${sessionScope.error}</p>
                </div>
                <% session.removeAttribute("error");%>
            </c:if>

            <div class="admin-control-filter-bar" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 15px; flex-wrap: wrap;">

                <form action="CourseAttendanceServlet" method="GET" style="display: flex; margin: 0;">
                    <div class="admin-search-group">
                        <input type="text" name="searchQuery" placeholder="Search course name or code..." value="${param.searchQuery}" style="width: 320px;">
                        <button type="submit">Search</button>
                    </div>
                </form>

                <a href="StudentElectiveEnrollServlet?action=viewCatalog" class="admin-action-btn" style="height: 40px; display: inline-flex; align-items: center; text-decoration: none; padding: 0 20px; background-color: #00897b; color: white; font-weight: bold; border-radius: 4px; box-shadow: 0 2px 5px rgba(0,137,123,0.2);">
                    + SELF-ENROLL ELECTIVE
                </a>
            </div>

            <table class="attendance-summary-table">
                <thead>
                    <tr>
                        <th style="width: 140px;">COURSE CODE</th>
                        <th>COURSE NAME</th>
                        <th style="width: 90px; text-align: center;">ATTENDED</th>
                        <th style="width: 90px; text-align: center;">TOTAL</th>
                        <th style="width: 180px;">ATTENDANCE %</th>
                        <th style="width: 160px; text-align: center;">STATUS</th>
                        <th style="width: 130px; text-align: center;">MANAGEMENT</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="course" items="${courseAttendanceList}">
                        <tr style="${course.isBelowThreshold ? 'border-left: 4px solid #a94442;' : ''}">
                            <td class="monospace-text"><strong>${course.courseCode}</strong></td>
                            <td>
                                ${course.courseName}
                                <%-- FIXED FIXED: Stripped away the broken 'var' assignment track --%>
                                <c:choose>
                                    <c:when test="${course.courseStatus eq 'Elective'}">
                                        <span style="font-size: 10px; background-color: #e3f2fd; color: #0d47a1; padding: 2px 6px; border-radius: 3px; margin-left: 8px; font-weight: bold;">ELECTIVE</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="font-size: 10px; background-color: #eaeaea; color: #555555; padding: 2px 6px; border-radius: 3px; margin-left: 8px; font-weight: bold;">CORE</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: center;">${course.attendedSessions}</td>
                            <td style="text-align: center;">${course.totalSessions}</td>
                            <td>
                                <div class="percentage-display-group">
                                    <span class="percentage-value" style="color: ${course.isBelowThreshold ? '#a94442' : '#00897b'}; font-weight: bold;">
                                        ${course.attendancePercentage}%
                                    </span>
                                    <div class="progress-track-bar">
                                        <div class="progress-fill-indicator" style="width: ${course.attendancePercentage}%;
                                             background-color: ${course.isBelowThreshold ? '#a94442' : '#00897b'};"></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="action-cell-container" style="display: flex; flex-direction: column; gap: 4px; align-items: center;">
                                    <c:choose>
                                        <c:when test="${course.isBelowThreshold}">
                                            <span class="status-badge alert-badge" style="background-color: #f2dede; color: #a94442; padding: 4px 8px; font-size: 11px; font-weight: bold; border-radius: 4px; text-align: center; display: inline-block; width: 110px;">
                                                AT RISK (&lt; ${currentSystemThreshold}%)
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge satisfactory-badge" style="background-color: #e2f2f0; color: #00897b; padding: 4px 8px; font-size: 11px; font-weight: bold; border-radius: 4px; text-align: center; display: inline-block; width: 110px;">
                                                SATISFACTORY
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>

                            <td style="text-align: center;">
                                <c:choose>
                                    <%-- FIXED: Evaluating the object criteria property directly here --%>
                                    <c:when test="${course.courseStatus eq 'Elective'}">
                                        <a href="StudentElectiveEnrollServlet?action=dropElective&courseCode=${course.courseCode}" 
                                           class="table-inline-link" 
                                           style="color: #a94442; font-weight: bold; text-decoration: none; font-size: 13px; background-color: #fdf2f2; padding: 5px 10px; border: 1px solid #f5c6cb; border-radius: 4px; display: inline-block;"
                                           onclick="return confirm('WARNING: UNENROLLMENT CONFIRMATION\n\nAre you sure you want to completely drop and remove the elective module [ ${course.courseCode} - ${course.courseName} ] from your active course registration profile?');">
                                            Drop Course
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: #999999; font-size: 12px; font-style: italic;" title="Core program requirements are systematically locked and cannot be dropped by students.">
                                            Core Locked
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty courseAttendanceList}">
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 40px; color: #888; font-style: italic;">
                                No active, enrolled class module attendance statistics verified for your profile tracking key.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </body>
</html>