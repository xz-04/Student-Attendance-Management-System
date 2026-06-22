<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Attendance Session</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Sessions History - ${selectedCourseCode != null ? selectedCourseCode : 'CSF3023'}</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div class="session-management-bar" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px;">
                <h2 class="section-subheading" style="margin:0;">PAST CREATED SESSIONS</h2>
                <a href="startSession.jsp?courseCode=${selectedCourseCode != null ? selectedCourseCode : 'CSF3023'}" class="admin-action-btn" style="background-color: #333333; color: white; border: none;">
                    + START NEW SESSION
                </a>
            </div>

            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th>SESSION ID</th>
                        <th>DATE / TIME</th>
                        <th>VENUE</th>
                        <th>PRESENT METRICS</th>
                        <th style="text-align: center;">ACTION</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="sessionItem" items="${historicalSessions}">
                        <tr>
                            <td class="monospace-text">${sessionItem.sessionId}</td>
                            <td>${sessionItem.dateString}</td>
                            <td>${sessionItem.venue}</td>
                            <td class="monospace-text">${sessionItem.presentCount} / ${sessionItem.totalStudents}</td>
                            <td style="text-align: center;">
                                <a href="LoadAttendance?sessionId=${sessionItem.sessionId}" class="table-row-action-btn">
                                    VIEW LIVE
                                </a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty historicalSessions}">
                        <tr>
                            <td class="monospace-text">SES-090</td>
                            <td>11 Jun 2026, 08:00 AM</td>
                            <td>DK3</td>
                            <td class="monospace-text">50 / 60</td>
                            <td style="text-align: center;">
                                <a href="LoadAttendance?sessionId=${sessionItem.sessionId}" class="table-row-action-btn">VIEW LIVE</a>
                            </td>
                        </tr>
                        <tr>
                            <td class="monospace-text">SES-089</td>
                            <td>10 Jun 2026, 10:00 AM</td>
                            <td>DK3</td>
                            <td class="monospace-text">58 / 60</td>
                            <td style="text-align: center;">
                                <a href="LoadAttendance?sessionId=${sessionItem.sessionId}" class="table-row-action-btn">VIEW LIVE</a>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </body>
</html>