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

@WebServlet("/LoadCourseSessionsServlet")
public class LoadCourseSessionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String courseCode = request.getParameter("courseCode");

        if (courseCode == null || courseCode.trim().isEmpty()) {
            response.sendRedirect("LecturerCoursesServlet");
            return;
        }

        courseCode = courseCode.trim();
        List<Map<String, Object>> sessionsList = new ArrayList<>();
        String courseName = "";

        // Query to get course name
        String infoSql = "SELECT courseName FROM course WHERE courseCode = ?";

        // MODIFIED: Removed 'asess.matricNo = ?' to fetch ALL sessions for the course
        String sessionsSql = "SELECT asess.sessionId, asess.date, "
                + "DATE_FORMAT(asess.startTime, '%H:%i') AS startT, "
                + "DATE_FORMAT(asess.endTime, '%H:%i') AS endT, "
                + "asess.venue, asess.qrToken, "
                + "(SELECT COUNT(*) FROM attendancerecord ar WHERE ar.sessionId = asess.sessionId) AS present_count, "
                + "(SELECT COUNT(*) FROM studentcourse sc WHERE sc.courseCode = asess.courseCode) AS total_students "
                + "FROM attendancesession asess "
                + "WHERE asess.courseCode = ? "
                + "ORDER BY asess.date DESC, asess.startTime DESC";

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Fetch Course Full Name
            try (PreparedStatement ps = conn.prepareStatement(infoSql)) {
                ps.setString(1, courseCode);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        courseName = rs.getString("courseName");
                    }
                }
            }

            // 2. Fetch ALL Session Records
            try (PreparedStatement ps = conn.prepareStatement(sessionsSql)) {
                ps.setString(1, courseCode); // Only one parameter needed now

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("sessionId", rs.getString("sessionId"));
                        row.put("date", rs.getDate("date"));
                        row.put("startTime", rs.getString("startT"));
                        row.put("endTime", rs.getString("endT"));
                        row.put("venue", rs.getString("venue"));
                        row.put("presentCount", rs.getInt("present_count"));
                        row.put("totalStudents", rs.getInt("total_students"));
                        row.put("qrToken", rs.getString("qrToken"));

                        sessionsList.add(row);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Bind attributes
        request.setAttribute("courseCode", courseCode);
        request.setAttribute("courseName", courseName);
        request.setAttribute("sessionList", sessionsList);

        request.getRequestDispatcher("viewCourseSessions.jsp").forward(request, response);
    }
}
