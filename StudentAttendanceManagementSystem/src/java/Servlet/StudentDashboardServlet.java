package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/StudentDashboardServlet")
public class StudentDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper - Verify Student Login Status
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String studentMatricNo = (String) session.getAttribute("userId");
        studentMatricNo = studentMatricNo.trim();

        int enrolledCount = 0;
        int attendedCount = 0;
        int absentCount = 0;
        int pendingLeaveCount = 0;

        List<Map<String, Object>> todayAttendanceList = new ArrayList<>();

        // 2. Calculate Today's Date in Java to avoid Database Timezone mismatch bugs
        String todayString = LocalDate.now().toString(); // Formats cleanly to "YYYY-MM-DD"

        // 3. Database Pipeline - Populate Metrics & Table Dynamically
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // KPI 1: Fetch total number of enrolled courses
                String enrolledSql = "SELECT COUNT(*) FROM studentcourse WHERE matricNo = ?";
                try (PreparedStatement psEnrolled = conn.prepareStatement(enrolledSql)) {
                    psEnrolled.setString(1, studentMatricNo);
                    try (ResultSet rsEnrolled = psEnrolled.executeQuery()) {
                        if (rsEnrolled.next()) {
                            enrolledCount = rsEnrolled.getInt(1);
                        }
                    }
                }

                // KPI 2: Total Sessions Attended
                String attendedSql = "SELECT COUNT(*) FROM attendancerecord WHERE matricNo = ?";
                try (PreparedStatement psAttended = conn.prepareStatement(attendedSql)) {
                    psAttended.setString(1, studentMatricNo);
                    try (ResultSet rsAttended = psAttended.executeQuery()) {
                        if (rsAttended.next()) {
                            attendedCount = rsAttended.getInt(1);
                        }
                    }
                }

                // KPI 3: Absent Sessions Calculation Logic
                String absentSql = "SELECT COUNT(*) FROM attendancesession s "
                        + "INNER JOIN studentcourse sc ON s.courseCode = sc.courseCode "
                        + "WHERE sc.matricNo = ? AND s.date <= CURDATE() "
                        + "AND s.sessionId NOT IN (SELECT sessionId FROM attendancerecord WHERE matricNo = ?)";
                try (PreparedStatement psAbsent = conn.prepareStatement(absentSql)) {
                    psAbsent.setString(1, studentMatricNo);
                    psAbsent.setString(2, studentMatricNo);
                    try (ResultSet rsAbsent = psAbsent.executeQuery()) {
                        if (rsAbsent.next()) {
                            absentCount = rsAbsent.getInt(1);
                        }
                    }
                }

                // KPI 4: Fetch total pending leave applications
                String leaveSql = "SELECT COUNT(*) FROM absenceleave "
                        + "WHERE matricNo = ? AND UPPER(approvalStatus) = 'PENDING'";
                try (PreparedStatement psLeave = conn.prepareStatement(leaveSql)) {
                    psLeave.setString(1, studentMatricNo);
                    try (ResultSet rsLeave = psLeave.executeQuery()) {
                        if (rsLeave.next()) {
                            pendingLeaveCount = rsLeave.getInt(1);
                        }
                    }
                }

                // ==========================================================================
                // MODIFIED DATA TABLE RETRIEVAL: FETCH TODAY'S CLASSES ONLY (TIMEZONE SAFE)
                // ==========================================================================
                String todayAttSql = "SELECT r.sessionId, c.courseName, "
                        + "DATE_FORMAT(s.startTime, '%H:%i') AS startT, "
                        + "DATE_FORMAT(s.endTime, '%H:%i') AS endT "
                        + "FROM attendancerecord r "
                        + "INNER JOIN attendancesession s ON r.sessionId = s.sessionId "
                        + "INNER JOIN course c ON s.courseCode = c.courseCode "
                        + "WHERE r.matricNo = ? "
                        + "AND DATE(r.checkinTime) = ? " // Using safe prepared statement parameter matching
                        + "ORDER BY r.checkinTime DESC";

                try (PreparedStatement psToday = conn.prepareStatement(todayAttSql)) {
                    psToday.setString(1, studentMatricNo);
                    psToday.setString(2, todayString); // Binds Java's precise local system date token

                    try (ResultSet rsToday = psToday.executeQuery()) {
                        while (rsToday.next()) {
                            Map<String, Object> item = new HashMap<>();
                            item.put("sessionId", rsToday.getString("sessionId"));
                            item.put("courseName", rsToday.getString("courseName"));
                            item.put("startTime", rsToday.getString("startT"));
                            item.put("endTime", rsToday.getString("endT"));
                            todayAttendanceList.add(item);
                        }
                    }
                }

            }
        } catch (SQLException e) {
            System.err.println("SAMS Dashboard Engine Exception Error: " + e.getMessage());
            e.printStackTrace();
        }

        // 4. Bind variables to request context
        request.setAttribute("enrolledCount", enrolledCount);
        request.setAttribute("attendedCount", attendedCount);
        request.setAttribute("absentCount", absentCount);
        request.setAttribute("pendingLeaveCount", pendingLeaveCount);
        request.setAttribute("recentAttendance", todayAttendanceList);

        // 5. Forward execution to presentation layer
        request.getRequestDispatcher("studentDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
