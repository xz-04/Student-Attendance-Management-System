package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LecturerDashboardServlet")
public class LecturerDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper - Verify Lecturer Authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String lecturerMatricNo = (String) session.getAttribute("userId");
        lecturerMatricNo = lecturerMatricNo.trim();

        int coursesTeachingCount = 0;
        int totalSessionsCount = 0;
        int pendingLeavesCount = 0;
        List<Map<String, Object>> recentSessionsList = new ArrayList<>();

        // FIXED: Extract today's date from the local system clock to ensure timezone alignment
        LocalDate todayLocal = LocalDate.now();
        String systemTodayStr = todayLocal.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

        System.out.println("--> [SAMS DEBUG] Running Dashboard Queries for Lecturer: " + lecturerMatricNo + " | Date: " + systemTodayStr);

        // 2. Query KPIs according to your exact Database Schema
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // KPI 1: Total Courses assigned to this Lecturer from lecturercourse
                String coursesSql = "SELECT COUNT(*) FROM lecturercourse WHERE TRIM(matricNo) = ?";
                try (PreparedStatement ps = conn.prepareStatement(coursesSql)) {
                    ps.setString(1, lecturerMatricNo);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            coursesTeachingCount = rs.getInt(1);
                        }
                    }
                }

                // KPI 2: Retrieve ALL sessions created by this lecturer from attendancesession (across all time)
                String totalSessionsSql = "SELECT COUNT(*) FROM attendancesession WHERE TRIM(matricNo) = ?";
                try (PreparedStatement ps = conn.prepareStatement(totalSessionsSql)) {
                    ps.setString(1, lecturerMatricNo);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            totalSessionsCount = rs.getInt(1);
                        }
                    }
                }

                // KPI 3: Pending leaves for courses assigned to this lecturer
                String leavesSql = "SELECT COUNT(*) FROM absenceleave al "
                        + "JOIN lecturercourse lc ON al.courseCode = lc.courseCode "
                        + "WHERE TRIM(lc.matricNo) = ? AND UPPER(al.approvalStatus) = 'PENDING'";
                try (PreparedStatement ps = conn.prepareStatement(leavesSql)) {
                    ps.setString(1, lecturerMatricNo);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            pendingLeavesCount = rs.getInt(1);
                        }
                    }
                }

                // FETCH SESSIONS CREATED ON THE SAME DAY BY THAT LECTURER ONLY
                // MODIFIED: Re-added 'asess.date = ?' constraint filter to isolate today's logs
                String todaySessionsListSql = "SELECT asess.sessionId, asess.courseCode, c.courseName, "
                        + "DATE_FORMAT(asess.date, '%Y-%m-%d') AS formattedDate, "
                        + "DATE_FORMAT(asess.startTime, '%H:%i') AS startT, "
                        + "DATE_FORMAT(asess.endTime, '%H:%i') AS endT "
                        + "FROM attendancesession asess "
                        + "LEFT JOIN course c ON TRIM(LOWER(asess.courseCode)) = TRIM(LOWER(c.courseCode)) "
                        + "WHERE TRIM(asess.matricNo) = ? AND asess.date = ? "
                        + "ORDER BY asess.startTime DESC";

                try (PreparedStatement ps = conn.prepareStatement(todaySessionsListSql)) {
                    ps.setString(1, lecturerMatricNo);
                    ps.setString(2, systemTodayStr); // Bind the Java system date string dynamically

                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> sessionItem = new HashMap<>();

                            sessionItem.put("sessionId", rs.getString("sessionId"));

                            // Fallback strategy: if description is missing, fall back to raw courseCode
                            String courseNameValue = rs.getString("courseName");
                            if (courseNameValue == null || courseNameValue.trim().isEmpty()) {
                                courseNameValue = rs.getString("courseCode");
                            }
                            sessionItem.put("courseName", courseNameValue);

                            sessionItem.put("date", rs.getString("formattedDate"));
                            sessionItem.put("startTime", rs.getString("startT"));
                            sessionItem.put("endTime", rs.getString("endT"));

                            recentSessionsList.add(sessionItem);
                        }
                    }
                }
                System.out.println("--> [SAMS DEBUG] Today's Sessions List Count loaded: " + recentSessionsList.size());
            }
        } catch (Exception e) {
            System.err.println("--> [SAMS ERROR] Dashboard retrieval failure!");
            e.printStackTrace();
        }

        // 3. Bind calculations back to request scope attributes for JSTL inside lecturerDashboard.jsp
        request.setAttribute("coursesTeachingCount", coursesTeachingCount);
        request.setAttribute("totalSessionsCount", totalSessionsCount); // Maintained for all-time stats card lookups
        request.setAttribute("pendingLeavesCount", pendingLeavesCount);
        request.setAttribute("recentSessions", recentSessionsList);

        // 4. Forward execution payload straight to your view template
        request.getRequestDispatcher("lecturerDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
