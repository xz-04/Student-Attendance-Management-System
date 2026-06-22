<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Dashboard</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Dashboard</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div class="kpi-container">
                <div class="kpi-card">
                    <h3>${coursesTeachingCount}</h3>
                    <p>COURSES TEACHING</p>
                </div>
                <div class="kpi-card">
                    <h3>${totalSessionsCount}</h3>
                    <p>TOTAL SESSIONS CREATED</p>
                </div>
                <div class="kpi-card">
                    <h3>${pendingLeavesCount}</h3>
                    <p>PENDING LEAVES</p>
                </div>
            </div>

            <h2>RECENT SESSIONS</h2>
            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th>SESSION ID</th>
                        <th>COURSE NAME</th>
                        <th>DATE</th>
                        <th>START TIME</th>
                        <th>END TIME</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${recentSessions}">
                        <tr>
                            <td class="monospace-text"><strong>${item.sessionId}</strong></td>
                            <td>${item.courseName}</td>
                            <td>${item.date}</td>
                            <td><span class="time-badge start-time">${item.startTime}</span></td>
                            <td><span class="time-badge end-time">${item.endTime}</span></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty recentSessions}">
                        <tr>
                            <td colspan="5" style="text-align: center; color: #777777; padding: 25px; font-style: italic;">
                                No recent attendance history sessions found inside logs.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>

        </div>
    </body>
</html>