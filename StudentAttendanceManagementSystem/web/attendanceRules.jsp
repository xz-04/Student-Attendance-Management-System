<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Attendance Rules</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Attendance Rules & Settings</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div class="admin-rules-notice-banner">
                <span class="notice-info-icon">i</span>
                <p class="notice-text-content">Changes apply system-wide and affect all faculties and courses immediately.</p>
            </div>

            <form action="SaveRulesServlet" method="POST" class="leave-application-form" style="max-width: 1000px;">

                <h2 class="section-subheading" style="margin-top: 25px;">ATTENDANCE THRESHOLDS</h2>
                <div class="form-group-block">
                    <label class="form-field-label">MINIMUM ATTENDANCE PERCENTAGE (%)</label>
                    <div class="rules-input-with-helper-row">
                        <input type="number" name="minAttendance" min="0" max="100" class="admin-rules-numeric-input" 
                               value="${rules.minAttendance != null ? rules.minAttendance : '80'}" required>
                        <span class="rules-field-helper-desc">Students below this % will receive an alert</span>
                    </div>
                </div>


                <div class="form-actions-footer" style="margin-top: 35px; justify-content: flex-start; gap: 15px;">
                    <button type="submit" name="action" value="SAVE" class="report-btn-generate" style="padding: 14px 35px;">
                        SAVE CHANGES
                    </button>

                    <button type="submit" name="action" value="RESET" class="report-btn-preview" style="padding: 14px 35px;">
                        RESET TO DEFAULT
                    </button>
                </div>

            </form>
        </div>

    </body>
</html>