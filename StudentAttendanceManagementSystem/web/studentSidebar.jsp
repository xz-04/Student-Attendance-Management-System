<%-- 
    Document   : studentSidebar
    Created on : May 24, 2026, 12:52:21 PM
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
        <li class="<%= request.getRequestURI().contains("ProfileServlet") || request.getRequestURI().contains("profile.jsp") || currentPage.contains("changePassword.jsp") ? "active" : ""%>">
            <a href="ProfileServlet" class="nav-btn">Profile</a>
        </li>
        <li class="<%= request.getRequestURI().contains("StudentDashboardServlet") || request.getRequestURI().contains("studentDashboard.jsp") ? "active" : ""%>">
            <a href="StudentDashboardServlet" class="nav-btn">Dashboard</a>
        </li>
        <li class="<%= currentPage.contains("studentCheckIn.jsp") || currentPage.contains("StudentCheckinServlet") || currentPage.contains("attendanceSuccess.jsp") ? "active" : ""%>">
            <a href="studentCheckIn.jsp" class="nav-btn">Check In</a>
        </li>
        <li class="<%= request.getRequestURI().contains("CourseAttendanceServlet") || request.getRequestURI().contains("courseAttendance.jsp") || request.getRequestURI().contains("enrollElective.jsp") ? "active" : ""%>">
            <a href="CourseAttendanceServlet" class="nav-btn">Course Attendance</a>
        </li>
        <li class="<%= request.getRequestURI().contains("LeaveServlet") || request.getRequestURI().contains("absenceLeave.jsp") || request.getRequestURI().contains("applyLeave.jsp") ? "active" : ""%>">
            <a href="LeaveServlet?status=all" class="nav-btn">Absence Leave</a>
        </li>
    </ul>
</div>