<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Dashboard</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Dashboard</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div class="kpi-container admin-grid">
                <div class="kpi-card">
                    <h3>${not empty totalStudentsCount ? totalStudentsCount : "0"}</h3>
                    <p>TOTAL STUDENTS</p>
                </div>

                <div class="kpi-card">
                    <h3>${not empty totalLecturersCount ? totalLecturersCount : "0"}</h3>
                    <p>TOTAL LECTURERS</p>
                </div>

                <div class="kpi-card">
                    <h3>${not empty totalFacultyCount ? totalFacultyCount : "0"}</h3>
                    <p>TOTAL FACULTIES</p>
                </div>

                <div class="kpi-card">
                    <h3>${not empty totalCoursesCount ? totalCoursesCount : "0"}</h3>
                    <p>TOTAL COURSES</p>
                </div>
            </div>

            <h2 class="section-subheading">FACULTY ATTENDANCE OVERVIEW</h2>
            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th>FACULTY CODE</th>
                        <th>FACULTY FULL NAME</th>
                        <th>TOTAL LECTURERS</th>
                        <th>TOTAL STUDENTS</th>
                        <th>TOTAL COURSES</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="faculty" items="${facultyOverviewList}">
                        <tr>
                            <td><strong>${faculty.name}</strong></td>
                            <td>${faculty.fullName}</td>
                            <td>${faculty.totalLecturers}</td>
                            <td>${faculty.totalStudents}</td>
                            <td><strong>${faculty.totalCourses}</strong></td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty facultyOverviewList}">
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 30px; color: #888888; font-style: italic;">
                                No active faculty configuration profiles could be retrieved from database registries.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>

        </div>
    </body>
</html>