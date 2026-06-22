<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Change Account Password</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>

        <%
            String userRole = (String) session.getAttribute("userRole");
            if (userRole != null) {
                userRole = userRole.trim().toLowerCase();
            } else {
                userRole = "student";
            }
        %>

        <% if ("admin".equals(userRole)) {%>
        <%@ include file="adminSidebar.jsp" %>
        <% } else if ("lecturer".equals(userRole)) {%>
        <%@ include file="lecturerSidebar.jsp" %>
        <% } else {%>
        <%@ include file="studentSidebar.jsp" %>
        <% }%>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Security Management</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div style="background: #ffffff; padding: 30px; border: 1px solid #e0e0e0; border-radius: 6px; max-width: 600px; margin-top: 20px;">
                <h2 style="margin-top: 0; color: #2c3e50; border-bottom: 2px solid #00897b; padding-bottom: 10px; font-size: 18px;">UPDATE ACCOUNT PASSWORD</h2>

                <form action="SavePasswordServlet" method="POST" style="margin-top: 25px; display: flex; flex-direction: column; gap: 20px;">

                    <div class="form-group-block">
                        <label class="form-field-label" style="font-weight: bold; display: block; margin-bottom: 5px; color: #555555;">NEW PASSWORD</label>
                        <input type="password" name="newPassword" class="form-text-layout-input" 
                               placeholder="Min 6 chars, must include letters and numbers" 
                               style="width: 100%; padding: 11px; border: 1px solid #cccccc; border-radius: 4px;" 
                               required pattern="^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$"
                               title="Password must be at least 6 characters long and include both letters and numbers.">
                    </div>

                    <div class="form-group-block">
                        <label class="form-field-label" style="font-weight: bold; display: block; margin-bottom: 5px; color: #555555;">CONFIRM NEW PASSWORD</label>
                        <input type="password" name="confirmPassword" class="form-text-layout-input" placeholder="Re-type new password" style="width: 100%; padding: 11px; border: 1px solid #cccccc; border-radius: 4px;" required>
                    </div>

                    <div class="form-actions-footer" style="margin-top: 15px; display: flex; gap: 15px; justify-content: flex-start;">
                        <button type="submit" class="report-btn-generate" style="padding: 13px 30px; background-color: #00897b; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer;">
                            🔐 COMMIT PASSWORD CHANGE
                        </button>
                        <a href="ProfileServlet" class="report-btn-preview" style="padding: 13px 30px; text-decoration: none; text-align: center; background-color: #eeeeee; color: #333333; border-radius: 4px; font-weight: bold; display: inline-block;">
                            RETURN TO PROFILE
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>