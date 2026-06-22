<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Enrolled Student</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Course Enrolled</h1>
                <a href="LecturerCoursesServlet" class="logout-link" style="background-color: #555555;">Back to Sessions</a>
            </div>

            <div style="background-color: #fff; padding: 18px 22px; border: 1px solid #e0e0e0; border-radius: 6px; margin-bottom: 25px; display: flex; gap: 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); align-items: center;">
                <div><strong>COURSE HUB CODE:</strong> <span class="monospace-text" style="color:#00897b; font-weight:bold; font-size: 15px;">${courseCode}</span></div>
                <div style="margin-left: auto; background-color: #e0f2f1; color: #004d40; padding: 4px 12px; border-radius: 12px; font-weight: bold; font-size: 13px;">
                    Total Registrations: ${studentRoster.size()} Students
                </div>
            </div>

            <div style="background: #ffffff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 6px;">
                <table class="dashboard-records-table" style="width: 100%;">
                    <thead>
                        <tr>
                            <th style="width: 70px; text-align: center;">NO.</th>
                            <th style="width: 180px;">MATRIC NO</th>
                            <th>STUDENT FULL NAME</th>
                            <th>EMAIL ADDRESS</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="student" items="${studentRoster}" varStatus="status">
                        <tr>
                            <td style="text-align: center; color: #666666;">${status.count}</td>
                            <td class="monospace-text"><strong>${student.matricNo}</strong></td>
                            <td><strong>${student.fullName}</strong></td>
                            <td style="color: #555555;">${student.email}</td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty studentRoster}">
                        <tr>
                            <td colspan="4" style="text-align: center; color: #888888; padding: 40px; font-style: italic; background-color: #fafafa;">
                                There are currently no students registered or enrolled inside this course code module.
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>