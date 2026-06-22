<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Available Elective Modules</title>
        <link rel="stylesheet" href="style.css">
        <style>
            /* Custom highlight badge styles for elective marketplace categorization rules */
            .elective-market-badge {
                background-color: #e3f2fd;
                color: #1565c0;
                padding: 4px 8px;
                border-radius: 4px;
                font-weight: bold;
                font-size: 12px;
                display: inline-block;
                border: 1px solid #bbdefb;
            }
        </style>
    </head>
    <body>
        <%@ include file="studentSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Available Electives</h1>
                <a href="CourseAttendanceServlet" class="logout-link" style="color: #333333; text-decoration: underline;">&larr; Back to Dashboard</a>
            </div>

            <p style="color: #666666; margin: 10px 0 25px 0; font-style: italic;">
                The items listed below are active Elective modules running this semester that match your faculty tracking path.
            </p>

            <table class="dashboard-records-table">
                <thead>
                    <tr>
                        <th style="width: 180px;">FACULTY</th>
                        <th style="width: 180px;">COURSE CODE</th>
                        <th>COURSE NAME</th>
                        <th style="width: 120px; text-align: center;">CLASSIFICATION</th>
                        <th style="width: 160px; text-align: center;">ACTION</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="elective" items="${availableElectives}">
                    <tr>
                        <td><strong><c:out value="${elective.facultyName}" /></strong></td>
                        <td class="monospace-text"><c:out value="${elective.courseCode}" /></td>
                    <td><c:out value="${elective.courseName}" /></td>
                    <td style="text-align: center;">
                        <span class="elective-market-badge">Elective</span>
                    </td>
                    <td style="text-align: center;">
                        <a href="StudentElectiveEnrollServlet?action=enroll&courseCode=${elective.courseCode}" 
                           class="admin-action-btn" 
                           style="padding: 8px 20px; border-radius: 4px; text-decoration: none; color: white; font-size: 12px; font-weight: bold; background-color: #00897b; display: inline-flex; align-items: center; height: auto;"
                           onclick="return confirm('Confirm Selection:\n\nDo you want to add this elective module into your current class calendar list layout?');">
                            Enroll Module
                        </a>
                    </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty availableElectives}">
                    <tr>
                        <td colspan="5" style="text-align: center; color: #888888; font-style: italic; padding: 40px;">
                            No additional open electives are currently available for registration during this running term.
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </body>
</html>