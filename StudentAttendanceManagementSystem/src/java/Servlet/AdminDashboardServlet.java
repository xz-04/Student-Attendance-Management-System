package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper Verification
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Initialize values
        int totalStudents = 0;
        int totalLecturers = 0;
        int totalFaculties = 0;
        int totalCourses = 0;
        List<Map<String, Object>> facultyOverviewList = new ArrayList<>();

        // SQL queries for KPI Summary Metrics
        String studentsCountSql = "SELECT COUNT(*) FROM users WHERE role = 'student'";
        String lecturersCountSql = "SELECT COUNT(*) FROM users WHERE role = 'lecturer'";
        String facultyCountSql = "SELECT COUNT(*) FROM faculty WHERE facultyName != 'PPPA'";
        String coursesCountSql = "SELECT COUNT(*) FROM course";

        // Main Query: Retrieves core faculty info alongside aggregated student and course counts (EXCLUDING PPPA)
        String overviewSql = "SELECT f.facultyName, f.facultyFullname, "
                + "  (SELECT COUNT(*) FROM users u WHERE u.facultyName = f.facultyName AND u.role = 'lecturer') AS total_lecturers, "
                + "  (SELECT COUNT(*) FROM users u WHERE u.facultyName = f.facultyName AND u.role = 'student') AS total_students, "
                + "  (SELECT COUNT(*) FROM course c WHERE c.facultyName = f.facultyName) AS total_courses "
                + "FROM faculty f "
                + "WHERE f.facultyName != 'PPPA' "
                + "ORDER BY f.facultyName ASC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                // 1. Execute KPI Counts
                try (PreparedStatement ps = conn.prepareStatement(studentsCountSql); ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalStudents = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(lecturersCountSql); ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalLecturers = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(facultyCountSql); ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalFaculties = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(coursesCountSql); ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalCourses = rs.getInt(1);
                    }
                }

                // 2. Execute Dynamic Faculty Matrix Calculations
                try (PreparedStatement ps = conn.prepareStatement(overviewSql); ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> facRow = new HashMap<>();
                        facRow.put("name", rs.getString("facultyName"));
                        facRow.put("fullName", rs.getString("facultyFullname")); // ADDED: Captures the long-form descriptive name
                        facRow.put("totalLecturers", rs.getInt("total_lecturers"));
                        facRow.put("totalStudents", rs.getInt("total_students"));
                        facRow.put("totalCourses", rs.getInt("total_courses"));  // ADDED: Tracks course counts instead of active sessions

                        facultyOverviewList.add(facRow);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Pass statistics arrays back to JSP Request context boundaries
        request.setAttribute("totalStudentsCount", totalStudents);
        request.setAttribute("totalLecturersCount", totalLecturers);
        request.setAttribute("totalFacultyCount", totalFaculties);
        request.setAttribute("totalCoursesCount", totalCourses);
        request.setAttribute("facultyOverviewList", facultyOverviewList);

        // Forward execution pipeline back to display layers
        request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
