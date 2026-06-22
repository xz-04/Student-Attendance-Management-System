<%-- 
    Document   : adminSidebar
    Created on : May 25, 2026, 3:05:55?PM
    Author     : chiaying
--%>

<%
    // Security Gatekeeper: Clear cache and force an immediate logout redirection loop if session drops
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Capture the current executing path URI string
    String currentPage = request.getRequestURI();
%>

<div class="sidebar">
    <div class="sidebar-logo">SAMS</div>

    <ul class="nav-menu">
        <li class="<%= currentPage.contains("ProfileServlet") || currentPage.contains("profile.jsp") || currentPage.contains("changePassword.jsp") ? "active" : ""%>">
            <a href="ProfileServlet" class="nav-btn">Profile</a>
        </li>
        <li class="<%= currentPage.contains("AdminDashboardServlet") || currentPage.contains("adminDashboard.jsp") ? "active" : ""%>">
            <a href="AdminDashboardServlet" class="nav-btn">Dashboard</a>
        </li>
        <li class="<%= (currentPage.contains("session.jsp") || currentPage.contains("AdminSessionsServlet") || currentPage.contains("viewSessionAttendance.jsp") || currentPage.contains("AdminViewSessionServlet")) ? "active" : ""%>">
            <a href="AdminSessionsServlet" class="nav-btn">Sessions</a>
        </li>
        <li class="<%= currentPage.contains("AdminUsersServlet") || currentPage.contains("users.jsp") || currentPage.contains("addCourseAssignment.jsp") || currentPage.contains("assignCourse.jsp") || currentPage.contains("addUser.jsp") || currentPage.contains("addCourseAssignment.jsp") || currentPage.contains("assignLecturerCourse.jsp") ? "active" : ""%>">
            <a href="AdminUsersServlet?roleTab=student" class="nav-btn">Users</a>
        </li>

        <li class="<%= currentPage.contains("CourseServlet") || currentPage.contains("adminCourses.jsp") || currentPage.contains("addCourse.jsp") ? "active" : ""%>">
            <a href="CourseServlet?action=list" class="nav-btn">Courses</a>
        </li>
        <li class="<%= (currentPage.contains("attendanceRules.jsp")
                || currentPage.contains("LoadRulesServlet")
                || currentPage.contains("SaveRulesServlet")
                || currentPage.toLowerCase().contains("rules")) ? "active" : ""%>">
            <a href="LoadRulesServlet" class="nav-btn">Att. Rules</a>
        </li>
        <li class="<%= (currentPage.contains("LoadAdminReportsServlet") || currentPage.contains("adminReports.jsp") || currentPage.contains("AdminReportsServlet") || currentPage.contains("adminReportPreview.jsp")) ? "active" : ""%>">
            <a href="LoadAdminReportsServlet" class="nav-btn">Reports</a>
        </li>
    </ul>
</div>