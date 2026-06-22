<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Dashboard</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="studentSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Dashboard</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <c:if test="${not empty atRiskCourses}">
                <div class="alert-box">
                    <c:forEach var="course" items="${atRiskCourses}">
                        <p>⚠ ATTENDANCE ALERT: ${course.name} - Current: ${course.percentage}%</p>
                    </c:forEach>
                </div>
            </c:if>

            <div class="kpi-container">
                <div class="kpi-card"><h3>${enrolledCount}</h3><p>ENROLLED COURSES</p></div>
                <div class="kpi-card"><h3>${attendedCount}</h3><p>SESSIONS ATTENDED</p></div>
                <div class="kpi-card"><h3>${absentCount}</h3><p>ABSENT SESSIONS</p></div>
                <div class="kpi-card"><h3>${pendingLeaveCount}</h3><p>LEAVE PENDING</p></div>
            </div>

            <h2>TODAY'S ATTENDED CLASSES</h2>
            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th>SESSION ID</th>
                        <th>COURSE NAME</th>
                        <th>START TIME</th>
                        <th>END TIME</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${recentAttendance}">
                        <tr>
                            <td class="monospace-text"><strong>${item.sessionId}</strong></td>
                            <td>${item.courseName}</td>
                            <td><span class="time-badge start-time">${item.startTime}</span></td>
                            <td><span class="time-badge end-time">${item.endTime}</span></td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty recentAttendance}">
                        <tr>
                            <td colspan="4" style="text-align: center; color: #888888; padding: 35px; font-style: italic; background-color: #fafafa;">
                                You have not checked into any learning sessions using QR codes today.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </body>
</html>