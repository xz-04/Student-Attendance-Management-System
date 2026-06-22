package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CourseAttendanceServlet")
public class CourseAttendanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper - Verify Student Authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String studentMatricNo = (String) session.getAttribute("userId");
        String searchQuery = request.getParameter("searchQuery");

        List<Map<String, Object>> courseAttendanceList = new ArrayList<>();

        // Default threshold value to use as a backup if the database is empty
        int dynamicThresholdLimit = 80;

        // 2. Fetch the Dynamic Administrative Rule Rule first
        String thresholdSql = "SELECT attendanceThreshold FROM systemrule WHERE ruleId = 1";

        // MODIFIED: Added c.courseStatus to the selection targets list
        String sql = "SELECT c.courseCode, c.courseName, c.courseStatus, "
                + "  (SELECT COUNT(*) FROM attendancesession s "
                + "   WHERE s.courseCode = c.courseCode) AS total_sessions, "
                + "  (SELECT COUNT(*) FROM attendancerecord r "
                + "   JOIN attendancesession s2 ON r.sessionId = s2.sessionId "
                + "   WHERE s2.courseCode = c.courseCode AND r.matricNo = ?) AS attended_sessions "
                + "FROM studentcourse sc "
                + "JOIN course c ON sc.courseCode = c.courseCode "
                + "WHERE sc.matricNo = ? ";

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql += "AND (c.courseCode LIKE ? OR c.courseName LIKE ?) ";
        }

        sql += "ORDER BY c.courseCode ASC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // STEP A: Query the dynamic threshold value set by the admin
                try (PreparedStatement psThreshold = conn.prepareStatement(thresholdSql); ResultSet rsThreshold = psThreshold.executeQuery()) {
                    if (rsThreshold.next()) {
                        dynamicThresholdLimit = rsThreshold.getInt("attendanceThreshold");
                    }
                }

                // STEP B: Process master calculations matrix loop
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, studentMatricNo);
                    ps.setString(2, studentMatricNo);

                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        String searchPattern = "%" + searchQuery.trim() + "%";
                        ps.setString(3, searchPattern);
                        ps.setString(4, searchPattern);
                    }

                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> courseData = new HashMap<>();
                            String courseCode = rs.getString("courseCode");
                            String courseName = rs.getString("courseName");

                            // MODIFIED: Read the text field directly out of the cursor record row
                            String courseStatus = rs.getString("courseStatus");
                            if (courseStatus == null) {
                                courseStatus = "Core"; // Fallback safeguard descriptor
                            }

                            int totalSessions = rs.getInt("total_sessions");
                            int attendedSessions = rs.getInt("attended_sessions");

                            // Division-by-zero structural safety checks guard
                            int percentage = 0;
                            if (totalSessions > 0) {
                                percentage = (int) Math.round(((double) attendedSessions / totalSessions) * 100);
                            } else {
                                percentage = 100; // Keep bar green if no classes are active yet
                            }

                            courseData.put("courseCode", courseCode);
                            courseData.put("courseName", courseName);
                            courseData.put("attendedSessions", attendedSessions);
                            courseData.put("totalSessions", totalSessions);
                            courseData.put("attendancePercentage", percentage);

                            // MODIFIED: Put status string into the Map data container for JSTL tag access
                            courseData.put("courseStatus", courseStatus.trim());

                            // Dynamically flag if student falls below the database-defined threshold limit
                            courseData.put("isBelowThreshold", percentage < dynamicThresholdLimit);

                            courseAttendanceList.add(courseData);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("SAMS Course Summary Engine Exception Trace: " + e.getMessage());
            e.printStackTrace();
        }

        // 3. Bind properties back onto page scopes and share the rule value with the view
        request.setAttribute("courseAttendanceList", courseAttendanceList);
        request.setAttribute("currentSystemThreshold", dynamicThresholdLimit);

        // 4. Forward context layout parameters seamlessly onto view template
        request.getRequestDispatcher("courseAttendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
