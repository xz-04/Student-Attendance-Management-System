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

@WebServlet("/LoadReportGenerationServlet")
public class LoadReportGenerationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Authenticate Session Gatekeeper Context
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String lecturerMatricNo = (String) session.getAttribute("userId");
        List<Map<String, String>> assignedCourses = new ArrayList<>();

        // Baseline fallback threshold value if the database row isn't found
        int systemThreshold = 80;

        // 2. Queries to pull assigned courses and the active system rule threshold
        String courseSql = "SELECT DISTINCT c.courseCode, c.courseName "
                + "FROM attendancesession s "
                + "JOIN course c ON s.courseCode = c.courseCode "
                + "WHERE s.matricNo = ? ORDER BY c.courseCode ASC";

        String thresholdSql = "SELECT attendanceThreshold FROM systemrule WHERE ruleId = 1";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // STEP A: Fetch the custom global threshold limit from database
                try (PreparedStatement psThreshold = conn.prepareStatement(thresholdSql); ResultSet rsThreshold = psThreshold.executeQuery()) {
                    if (rsThreshold.next()) {
                        systemThreshold = rsThreshold.getInt("attendanceThreshold");
                    }
                }

                // STEP B: Fetch the courses assigned to this specific lecturer
                try (PreparedStatement psCourse = conn.prepareStatement(courseSql)) {
                    psCourse.setString(1, lecturerMatricNo.trim());
                    try (ResultSet rs = psCourse.executeQuery()) {
                        while (rs.next()) {
                            Map<String, String> course = new HashMap<>();
                            course.put("courseCode", rs.getString("courseCode"));
                            course.put("courseName", rs.getString("courseName"));
                            assignedCourses.add(course);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("--> [SAMS CRITICAL] Failed loading reporter dropdown dependencies!");
            e.printStackTrace();
        }

        // 3. Bind properties data payload to request scope and forward to form view
        request.setAttribute("lecturerCourses", assignedCourses);
        request.setAttribute("currentSystemThreshold", systemThreshold); // Pass threshold to JSP
        request.getRequestDispatcher("report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
