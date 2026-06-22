<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- ADDED: JSTL Core tag library descriptor to support conditional logic evaluation --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Start Attendance Session</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Initialize Attendance Session</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div class="form-container-card" style="max-width: 600px; margin-top: 30px; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">

                <c:if test="${not empty sessionScope.msgError}">
                    <div class="admin-rules-notice-banner" style="background-color: #f2dede; border: 1px solid #ebccd1; color: #a94442; padding: 12px 20px; margin-bottom: 25px; border-radius: 4px; border-left: 5px solid #d9534f;">
                        <p style="margin: 0; font-size: 14px;">
                            <strong>Scheduling Failure:</strong> <c:out value="${sessionScope.msgError}" />
                        </p>
                    </div>
                    <%-- Session flash cleaning variable sweep --%>
                    <% session.removeAttribute("msgError");%>
                </c:if>

                <form action="GenerateSessionServlet" method="POST">

                    <input type="hidden" name="courseCode" value="${param.courseCode}">

                    <div class="form-group-block" style="margin-bottom: 20px;">
                        <label class="form-field-label" style="font-weight: bold; display: block; margin-bottom: 5px;">COURSE CODE (Selected)</label>
                        <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; color: #333;" value="${param.courseCode}" readonly>
                    </div>

                    <div class="form-group-block" style="margin-bottom: 20px;">
                        <label class="form-field-label" style="font-weight: bold; display: block; margin-bottom: 5px;">SESSION DATE</label>
                        <input type="date" name="date" class="form-text-layout-input" required>
                    </div>

                    <div class="form-group-block" style="margin-bottom: 20px; display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                        <div>
                            <label class="form-field-label" style="font-weight: bold; display: block; margin-bottom: 5px;">START TIME</label>
                            <input type="time" name="startTime" class="form-text-layout-input" required>
                        </div>
                        <div>
                            <label class="form-field-label" style="font-weight: bold; display: block; margin-bottom: 5px;">END TIME</label>
                            <input type="time" name="endTime" class="form-text-layout-input" required>
                        </div>
                    </div>

                    <div class="form-group-block" style="margin-bottom: 25px;">
                        <label class="form-field-label" style="font-weight: bold; display: block; margin-bottom: 5px;">VENUE LOCATION</label>
                        <input type="text" name="venue" class="form-text-layout-input" placeholder="e.g., Makmal 2, Blok A" required>
                    </div>

                    <div class="form-actions-footer" style="display: flex; gap: 15px;">
                        <button type="submit" class="theme-btn-action" style="background: #00897b; color: white; border: none; padding: 12px 25px; font-weight: bold; cursor: pointer; border-radius: 4px;">GENERATE QR SESSION</button>
                        <a href="LoadCourseSessionsServlet?courseCode=${param.courseCode}" class="report-btn-preview" style="padding: 12px 25px; text-decoration: none; background: #eee; color: #333; border-radius: 4px; font-weight: bold; text-align: center;">CANCEL</a>
                    </div>

                </form>
            </div>
        </div>
    </body>
</html>