<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Attendance Session</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Attendance Session</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <h2 class="section-subheading">YOUR ASSIGNED COURSES</h2>

            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th style="width: 180px;">COURSE CODE</th>
                        <th>COURSE NAME</th>
                        <th style="width: 250px;">TOTAL STUDENTS ENROLLED</th>
                        <th style="width: 200px; text-align: center;">ACTION</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="course" items="${lecturerCourses}">
                        <tr>
                            <td class="monospace-text"><strong>${course.courseCode}</strong></td>
                            <td>${course.courseName}</td>
                            <td>
                                <div style="display: flex; align-items: center; justify-content: space-between; width: 100%; box-sizing: border-box;">
                                    <span>${course.totalStudents} Students</span>
                                    <a href="ViewEnrolledStudentsServlet?courseCode=${course.courseCode}" class="table-inline-link" style="font-size: 11px; font-weight: bold; padding: 4px 10px; background-color: #00897b; color: white; text-decoration: none; border-radius: 4px; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">
                                        VIEW STUDENT
                                    </a>
                                </div>
                            </td>
                            <td style="text-align: center;">
                                <a href="LoadCourseSessionsServlet?courseCode=${course.courseCode}" class="table-row-action-btn" style="text-decoration: none; font-weight: bold; padding: 6px 15px; background: #333; color: #fff; border-radius: 4px;">
                                    VIEW
                                </a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty lecturerCourses}">
                        <tr>
                            <td colspan="4" style="text-align: center; color: #777777; padding: 35px; font-style: italic;">
                                You currently have no course modules assigned to your profile inside the master database registry.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </body>
</html>