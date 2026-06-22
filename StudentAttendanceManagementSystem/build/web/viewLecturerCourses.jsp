<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Assigned Courses | SAMS</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <div>
                    <h1>Assigned Courses</h1>
                    <p style="color: #666; margin: 5px 0 0 0;">Viewing assignments for Lecturer: <strong>${lecturerMatric}</strong></p>
                </div>
                <a href="AdminUsersServlet?roleTab=lecturer" class="logout-link" style="background-color: #333333;">&larr; BACK TO LIST</a>
            </div>

            <div style="background: white; border-radius: 15px; padding: 25px; box-shadow: 0 10px 30px rgba(0,0,0,0.04);">
                <c:choose>
                    <c:when test="${not empty assignedCourses}">
                        <table class="dashboard-records-table">
                            <thead>
                                <tr>
                                    <th>NO.</th>
                                    <th>COURSE CODE</th>
                                    <th>COURSE NAME</th>
                                    <th>FACULTY</th>
                                    <th style="text-align: center;">ACTIONS</th> </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="course" items="${assignedCourses}" varStatus="loop">
                                    <tr>
                                        <td>${loop.index + 1}</td>
                                        <td class="monospace-text">${course.code}</td>
                                        <td>${course.name}</td>
                                        <td>${course.faculty}</td>
                                        <td style="text-align: center;">
                                            <%-- Remove Action --%>
                                            <a href="RemoveAssignmentServlet?courseCode=${course.code}&matricNo=${lecturerMatric}" 
                                               class="delete-action-btn" 
                                               onclick="return confirm('Are you sure you want to remove this assignment?');">
                                                Remove
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div style="padding: 40px; text-align: center; color: #777;">
                            <p>No courses have been assigned to this lecturer yet.</p>
                            <a href="assignLecturerCourse.jsp?matricNo=${lecturerMatric}" class="admin-action-btn" style="margin-top: 15px;">ASSIGN A COURSE NOW</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </body>
</html>