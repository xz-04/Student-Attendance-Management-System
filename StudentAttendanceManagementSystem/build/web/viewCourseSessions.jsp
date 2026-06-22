<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Date, java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Course History</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <%-- 1. Initialize a server-side timestamp to evaluate expiration states --%>
        <%            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String currentDateTimeStr = sdf.format(new Date());
            request.setAttribute("currentDateTimeStr", currentDateTimeStr);
        %>

        <div class="main-content">

            <div class="dashboard-header">
                <div>
                    <h1 style="margin: 5px 0 0 0;">${courseCode} — ${courseName}</h1>
                </div>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 40px; margin-bottom: 15px;">
                <h2 class="section-subheading" style="margin: 0; padding: 0; border: none;">PAST ATTENDANCE SESSIONS</h2>

                <a href="startSession.jsp?courseCode=${courseCode}" class="theme-btn-action" 
                   style="background-color: #00897b; color: white; padding: 10px 20px; text-decoration: none; font-weight: bold; border-radius: 4px; font-size: 14px; display: inline-block; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    + START NEW SESSION
                </a>
            </div>

            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th>SESSION ID</th>
                        <th>DATE</th>
                        <th>START TIME</th> 
                        <th>END TIME</th>   
                        <th>VENUE</th>
                        <th>PRESENT STUDENTS</th>
                        <th style="text-align: center;">STUDENT LIST</th>
                            <%-- MODIFIED: Split into two distinct column headers --%>
                        <th style="text-align: center; width: 140px;">QR STATUS</th>
                        <th style="text-align: center; width: 130px;">QR CODE</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="sessionItem" items="${sessionList}">

                        <%-- 2. Concatenate Date & Time boundaries to build complete comparable ISO-like string representations --%>
                        <c:set var="sessionStartStr" value="${sessionItem.date} ${sessionItem.startTime}" />
                        <c:set var="sessionEndStr" value="${sessionItem.date} ${sessionItem.endTime}" />

                        <%-- 3. Determine if the current clock time is within or past boundaries --%>
                        <c:set var="isExpired" value="${currentDateTimeStr > sessionEndStr}" />
                        <c:set var="isActive" value="${currentDateTimeStr >= sessionStartStr && currentDateTimeStr <= sessionEndStr}" />

                        <tr style="${isExpired ? 'background-color: #fafafa; color: #888888;' : ''}">
                            <td class="monospace-text"><strong>${sessionItem.sessionId}</strong></td>
                            <td>${sessionItem.date}</td>
                            <td><span class="time-badge start-time" style="${isExpired ? 'background-color: #e0e0e0; color: #777;' : ''}">${sessionItem.startTime}</span></td>
                            <td><span class="time-badge end-time" style="${isExpired ? 'background-color: #e0e0e0; color: #777;' : ''}">${sessionItem.endTime}</span></td>
                            <td>${sessionItem.venue}</td>
                            <td>
                                <strong>${sessionItem.presentCount}</strong> / ${sessionItem.totalStudents}
                            </td>

                            <td style="text-align: center;">
                                <a href="LecturerViewSessionAttendanceServlet?sessionId=${sessionItem.sessionId}" class="admin-action-btn" style="background-color: #34495e; color: white; text-decoration: none; padding: 6px 12px; border-radius: 4px; font-size: 12px; font-weight: bold; display: inline-block;">
                                    VIEW
                                </a>
                            </td>

                            <%-- COLUMN 1: QR Status Badges --%>
                            <td style="text-align: center;">
                                <c:choose>
                                    <c:when test="${isExpired}">
                                        <span class="status-badge alert-badge" style="background-color: #f2dede; color: #a94442; padding: 6px 12px; font-size: 11px; font-weight: bold; border-radius: 4px; display: inline-block; border: 1px solid #ebccd1; width: 100px; text-align: center;">
                                            EXPIRED
                                        </span>
                                    </c:when>
                                    <c:when test="${isActive}">
                                        <span class="status-badge satisfactory-badge" style="background-color: #e2f2f0; color: #00897b; padding: 6px 12px; font-size: 11px; font-weight: bold; border-radius: 4px; display: inline-block; border: 1px solid #b2dfdb; width: 100px; text-align: center;">
                                            ACTIVE
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge standard-badge" style="background-color: #fff3cd; color: #856404; padding: 6px 12px; font-size: 11px; font-weight: bold; border-radius: 4px; display: inline-block; border: 1px solid #ffeeba; width: 100px; text-align: center;">
                                            SCHEDULED
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <%-- COLUMN 2: Context-Aware QR Link Button --%>
                            <td style="text-align: center;">
                                <c:choose>
                                    <c:when test="${isActive}">
                                        <a href="viewQR.jsp?sessionId=${sessionItem.sessionId}" class="admin-action-btn" style="background-color: #00897b; color: white; text-decoration: none; padding: 6px 12px; border-radius: 4px; font-size: 12px; font-weight: bold; display: inline-block; box-shadow: 0 1px 3px rgba(0,137,123,0.3);">
                                            VIEW QR
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: #999999; font-size: 12px; font-style: italic;">Locked</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty sessionList}">
                        <tr>
                            <%-- MODIFIED: Incremented colspan to 9 to preserve grid balance across split cells --%>
                            <td colspan="9" style="text-align: center; color: #888888; padding: 35px; font-style: italic; background-color: #fafafa;">
                                No tracking sessions have been launched for this course module yet.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </body>
</html>