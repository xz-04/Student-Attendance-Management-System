<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Live Sessions Monitor</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Real-Time Sessions Monitor</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <form action="AdminSessionsServlet" method="GET" style="display: flex; gap: 20px; align-items: flex-end; margin-bottom: 25px; background-color: #ffffff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 6px; box-sizing: border-box; width: 100%;">
                <div style="flex: 1; min-width: 200px; display: flex; flex-direction: column; gap: 6px;">
                    <label for="adminDateFilter" style="font-size: 11px; font-weight: bold; color: #555555; letter-spacing: 0.5px;">FILTER BY DATE</label>
                    <%                        String customDate = request.getParameter("customDate");
                        if (customDate == null || customDate.trim().isEmpty()) {
                            customDate = java.time.LocalDate.now().toString();
                        }
                    %>
                    <input type="date" id="adminDateFilter" name="customDate" value="<%= customDate%>" 
                           onchange="this.form.submit()" 
                           style="height: 42px; width: 100%; padding: 0 12px; border: 1px solid #cccccc; border-radius: 4px; box-sizing: border-box; font-family: inherit; font-size: 14px; background-color: #ffffff;">
                </div>

                <div style="flex: 2; min-width: 300px; display: flex; flex-direction: column; gap: 6px;">
                    <label style="font-size: 11px; font-weight: bold; color: #555555; letter-spacing: 0.5px;">SEARCH BY KEYWORD</label>
                    <input type="text" name="searchQuery" placeholder="Search by Session ID, Course Code, Venue..." 
                           value="${param.searchQuery}" 
                           style="height: 42px; width: 100%; padding: 0 12px; border: 1px solid #cccccc; border-radius: 4px; box-sizing: border-box; font-family: inherit; font-size: 14px;">
                </div>

                <div>
                    <button type="submit" class="admin-search-execute-btn" style="height: 42px; padding: 0 35px; font-size: 14px; border-radius: 4px; margin: 0; display: inline-flex; align-items: center; justify-content: center; font-weight: bold; background-color: #34495e; color: white; border: none; cursor: pointer;">
                        Apply Filter
                    </button>
                </div>
            </form>

            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th>SESSION ID</th>
                        <th>COURSE CODE</th>
                        <th>LECTURER</th>
                        <th>DATE</th>
                        <th>START TIME</th>
                        <th>END TIME</th>
                        <th>VENUE</th>
                        <th style="width: 100px; text-align: center;">ACTION</th> </tr>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="sessionItem" items="${adminSessionsList}">
                        <tr>
                            <td class="monospace-text"><strong>${sessionItem.sessionId}</strong></td>
                            <td class="monospace-text">${sessionItem.courseCode}</td>
                            <td>${sessionItem.lecturerName}</td>
                            <td>${sessionItem.dateString}</td>
                            <td><strong>${sessionItem.startTime}</strong></td>
                            <td><strong>${sessionItem.endTime}</strong></td>
                            <td>${sessionItem.venue}</td>
                            <td style="text-align: center;">
                                <a href="AdminViewSessionServlet?sessionId=${sessionItem.sessionId}" class="admin-search-execute-btn">VIEW</a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty adminSessionsList}">
                        <tr>
                            <td colspan="8" style="text-align: center; color: #888888; padding: 40px; font-style: italic;">
                                No active learning sessions found matching the selected parameters.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>

        </div>
    </body>
</html>