<%-- 
    Document   : lecturerSidebar
    Created on : May 25, 2026, 2:51:43 PM
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

        <li class="<%= currentPage.contains("lecturerDashboard.jsp") ? "active" : ""%>">
            <a href="LecturerDashboardServlet" class="nav-btn">Dashboard</a>
        </li>

        <li class="<%= (currentPage.contains("attendanceSession.jsp")
                || currentPage.contains("courseSessionsList.jsp")
                || currentPage.contains("LoadCourseSessions")
                || currentPage.contains("LoadCourseSessionsServlet")
                || currentPage.contains("viewCourseSessions.jsp")
                || currentPage.contains("startSession.jsp")
                || currentPage.contains("liveAttendance.jsp")
                || currentPage.contains("LoadAttendance")
                || currentPage.contains("viewQR.jsp")
                || currentPage.contains("LecturerCoursesServlet")
                || currentPage.contains("viewCourseRoster.jsp")
                || currentPage.contains("ViewEnrolledStudentsServlet")
                || currentPage.contains("viewEnrolledStudents.jsp")
                || currentPage.contains("lecturerViewSessionAttendance.jsp")
                || currentPage.contains("LecturerViewSessionAttendanceServlet")) ? "active" : ""%>">
            <a href="LecturerCoursesServlet" class="nav-btn">Attendance Session</a>
        </li>

        <li class="<%= (currentPage.contains("approvalLeave.jsp")
                || currentPage.contains("viewLeaveDetails.jsp")
                || currentPage.contains("LecturerLeaveApprovalServlet")
                || currentPage.contains("ViewLeaveDetailsServlet")) ? "active" : ""%>">
            <a href="LecturerLeaveApprovalServlet" class="nav-btn">Approval of Leave</a>
        </li>

        <li class="<%= (currentPage.contains("generateReport.jsp")
                || currentPage.contains("GenerateReportServlet")
                || currentPage.contains("LoadReportGenerationServlet")
                || currentPage.contains("previewReportDetails.jsp")
                || currentPage.toLowerCase().contains("report")) ? "active" : ""%>">
            <a href="LoadReportGenerationServlet" class="nav-btn">Reports</a>
        </li>
    </ul>
</div>