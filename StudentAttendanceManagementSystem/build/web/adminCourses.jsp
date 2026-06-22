<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Course Management</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Course Management</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div class="admin-control-filter-bar" style="display: flex; justify-content: space-between; margin-top: 20px;">

                <form action="CourseServlet" method="GET" style="display: flex; margin: 0;">
                    <input type="hidden" name="action" value="list">
                    <div class="admin-search-group">
                        <input type="text" name="searchCourse" placeholder="Search by Course Code or Name..." value="${param.searchCourse}" class="admin-filter-search-input" style="width: 380px;">
                        <button type="submit" class="admin-search-execute-btn">Search</button>
                    </div>
                </form>

                <a href="addCourse.jsp" class="admin-action-btn" style="height: 40px; display: inline-flex; align-items: center; text-decoration: none; padding: 0 20px;">
                    + ADD NEW COURSE
                </a>
            </div>

            <c:if test="${not empty error}">
                <div class="admin-rules-notice-banner" style="background-color: #f2dede; border-color: #ebccd1; color: #a94442; margin-bottom: 20px; padding: 12px; border-radius: 4px;">
                    <p class="notice-text-content"><strong>Error:</strong> ${error}</p>
                </div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="admin-rules-notice-banner" style="background-color: #d9edf7; border-color: #bce8f1; color: #31708f; margin-bottom: 20px; padding: 12px; border-radius: 4px;">
                    <p class="notice-text-content"><strong>Success:</strong> ${success}</p>
                </div>
            </c:if>

            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th>FACULTY NAME</th>
                        <th>COURSE CODE</th>
                        <th>COURSE NAME</th>
                            <%-- MODIFIED: Added explicit targeting headers to make auto-assignment visibility completely clear --%>
                        <th style="width: 140px; text-align: center;">TARGET YEAR</th>
                        <th style="width: 140px; text-align: center;">TARGET SEMESTER</th>
                        <th style="width: 120px; text-align: center;">ACTIONS</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="course" items="${adminCoursesList}">
                        <tr>
                            <td><strong><c:out value="${course.facultyName}" /></strong></td>
                            <td class="monospace-text"><c:out value="${course.courseCode}" /></td>
                            <td><c:out value="${course.courseName}" /></td>

                            <%-- MODIFIED: Reads the dynamic standalone request scoped integer mapping variables --%>
                            <td style="text-align: center;">
                                <c:set var="yearKey" value="year_${course.courseCode}"/>
                                <span class="inline-user-badge" style="background-color: #e8f5e9; color: #2e7d32; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 13px;">
                                    Year <c:out value="${requestScope[yearKey]}" default="1"/>
                                </span>
                            </td>
                            <td style="text-align: center;">
                                <c:set var="semKey" value="sem_${course.courseCode}"/>
                                <span class="inline-user-badge" style="background-color: #e3f2fd; color: #1565c0; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 13px;">
                                    Semester <c:out value="${requestScope[semKey]}" default="1"/>
                                </span>
                            </td>

                            <td style="text-align: center;">
                                <a href="CourseServlet?action=delete&courseCode=${course.courseCode}" class="delete-action-btn" onclick="return confirm('Are you sure you want to delete this course? This will cascade remove all associated sessions and enrollments.');" style="color: #a94442; font-weight: bold; text-decoration: none;">Delete</a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty adminCoursesList}">
                        <tr>
                            <%-- MODIFIED: Adjusted colspan up from 4 to 6 to account for the new programmatic columns seamlessly --%>
                            <td colspan="6" style="text-align: center; color: #888; font-style: italic; padding: 20px;">
                                No operational course registration items recorded.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>

        </div>
    </body>
</html>