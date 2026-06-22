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
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Session Attendance Sheet</h1>
                <a href="AdminViewSessionServlet" class="logout-link" style="background-color: #555; text-decoration: none; padding: 10px 20px; color: white; border-radius: 4px; font-weight: bold;">BACK TO SESSIONS</a>
            </div>

            <div style="background-color: #fff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 6px; margin-bottom: 25px; display: flex; gap: 40px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); flex-wrap: wrap;">
                <div><strong>SESSION ID:</strong> <span class="monospace-text">${sessionMeta.sessionId}</span></div>
                <div><strong>COURSE:</strong> <span class="monospace-text" style="color:#00897b; font-weight:bold;">${sessionMeta.courseCode} — ${sessionMeta.courseName}</span></div>
                <div><strong>DATE:</strong> ${sessionMeta.date}</div>
                <div><strong>VENUE:</strong> ${sessionMeta.venue}</div>
            </div>

            <div style="background: #ffffff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 6px;">
                <h3 style="margin-top: 0; color: #2c3e50; border-bottom: 2px solid #00897b; padding-bottom: 10px; display: flex; justify-content: space-between; align-items: center;">
                    <span>Attendance Status Roster</span>
                    <span style="background: #00897b; color: white; padding: 4px 12px; font-size: 13px; border-radius: 12px; font-weight: bold;">
                        Present Count: ${not empty sessionMeta.presentCount ? sessionMeta.presentCount : '0'} / ${rosterList.size()} Students
                    </span>
                </h3>

                <table class="dashboard-records-table" style="margin-top: 15px; width: 100%;">
                    <thead>
                        <tr>
                            <th style="width: 60px; text-align: center;">NO.</th>
                            <th style="width: 140px;">MATRIC NO</th>
                            <th>STUDENT NAME</th>
                            <th style="width: 180px; text-align: center;">ATTENDANCE STATUS</th>
                            <th style="width: 140px; text-align: center;">LOGGED TIME</th>

                            <th style="width: 150px; text-align: center;">IP ADDRESS</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="student" items="${rosterList}" varStatus="status">
                            <tr style="${student.status eq 'PRESENT' ? 'background-color: #f4fff6;' : 'background-color: #ffffff;'}">
                                <td style="text-align: center; color: #666;">${status.count}</td>
                                <td class="monospace-text"><strong>${student.matricNo}</strong></td>
                                <td>${student.fullName}</td>
                                <td style="text-align: center;">
                                    <c:choose>
                                        <c:when test="${student.status eq 'PRESENT'}">
                                            <span class="status-badge satisfactory-badge" style="background-color: #d1e7dd; color: #0f5132; padding: 4px 10px; border-radius: 4px; font-size: 11px; font-weight: bold; display: inline-block; width: 80px; text-align: center;">
                                                PRESENT
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge alert-badge" style="background-color: #f8d7da; color: #842029; padding: 4px 10px; border-radius: 4px; font-size: 11px; font-weight: bold; display: inline-block; width: 80px; text-align: center;">
                                                ABSENT
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align: center; font-weight: ${student.status eq 'PRESENT' ? 'bold' : 'normal'}; color: ${student.status eq 'PRESENT' ? '#1b5e20' : '#777'};">
                                    ${student.checkTime}
                                </td>

                                <td class="monospace-text" style="text-align: center; font-size: 12px; color: ${student.status eq 'PRESENT' ? '#1b5e20' : '#bbb'};">
                                    <c:choose>
                                        <%-- Trim the string to handle potential whitespace issues --%>
                                        <c:when test="${not empty student.ipAddress}">
                                            <c:out value="${student.ipAddress.trim()}" />
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #bbb;">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty rosterList}">
                            <tr>
                                <td colspan="6" style="text-align: center; color: #888888; padding: 40px; font-style: italic;">
                                    No registered students found enrolled inside this course roster.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>