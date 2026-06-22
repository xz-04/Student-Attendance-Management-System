<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Session Student List</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>
        <div class="main-content">
            <div class="dashboard-header">
                <h1>Session Attendance Sheet</h1>
                <a href="LoadCourseSessionsServlet?courseCode=${sessionMeta.courseCode}" class="logout-link" style="background-color: #555;">Back to Sessions</a>
            </div>

            <table class="dashboard-records-table" style="margin-top: 15px; width: 100%;">
                <thead>
                    <tr>
                        <th style="width: 60px; text-align: center;">NO.</th>
                        <th style="width: 150px;">MATRIC NO</th>
                        <th>STUDENT NAME</th>
                        <th style="width: 150px; text-align: center;">IP ADDRESS</th>
                        <th style="width: 150px; text-align: center;">STATUS</th>
                        <th style="width: 150px; text-align: center;">LOGGED TIME</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="student" items="${rosterList}" varStatus="status">
                        <tr style="${student.status eq 'PRESENT' ? 'background-color: #f4fff6;' : 'background-color: #ffffff;'}">
                            <td style="text-align: center; color: #666;">${status.count}</td>
                            <td class="monospace-text"><strong>${student.matricNo}</strong></td>
                            <td><strong>${student.fullName}</strong></td>
                            <td style="text-align: center; font-family: monospace;">${student.ipAddress}</td>
                            <td style="text-align: center;">
                                <c:choose>
                                    <c:when test="${student.status eq 'PRESENT'}">
                                        <span style="background-color: #d1e7dd; color: #0f5132; padding: 4px 12px; border-radius: 4px; font-size: 11px; font-weight: bold;">PRESENT</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="background-color: #f8d7da; color: #842029; padding: 4px 12px; border-radius: 4px; font-size: 11px; font-weight: bold;">ABSENT</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: center;">${student.checkTime}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </body>
</html>