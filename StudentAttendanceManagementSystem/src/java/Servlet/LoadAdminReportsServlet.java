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

@WebServlet("/LoadAdminReportsServlet")
public class LoadAdminReportsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper - Verify Admin Authentication Context
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Initialize parameters with safe default fallbacks
        int systemThreshold = 80;
        List<Map<String, String>> dynamicFacultiesList = new ArrayList<>();

        // 2. Define Core SQL Selection Queries
        // Query A: Pulls dynamic warning threshold config metrics
        String thresholdSql = "SELECT attendanceThreshold FROM systemrule WHERE ruleId = 1";

        // Query B: Pulls faculty names and details for your dropdown population loop
        String facultySql = "SELECT facultyName, facultyFullname FROM faculty ORDER BY facultyName ASC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // STEP A: Fetch the live attendance alert configuration threshold limit
                try (PreparedStatement psThreshold = conn.prepareStatement(thresholdSql); ResultSet rsThreshold = psThreshold.executeQuery()) {
                    if (rsThreshold.next()) {
                        systemThreshold = rsThreshold.getInt("attendanceThreshold");
                    }
                }

                // STEP B: Fetch active operational faculties rows from database
                try (PreparedStatement psFaculty = conn.prepareStatement(facultySql); ResultSet rsFaculty = psFaculty.executeQuery()) {
                    while (rsFaculty.next()) {
                        Map<String, String> facultyRow = new HashMap<>();
                        // Maps database columns exactly to match the c:forEach keys inside adminReports.jsp
                        facultyRow.put("facultyName", rsFaculty.getString("facultyName"));
                        facultyRow.put("facultyFullname", rsFaculty.getString("facultyFullname"));
                        dynamicFacultiesList.add(facultyRow);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("--> [SAMS CRITICAL] LoadAdminReportsServlet database read operation exception!");
            e.printStackTrace();
        }

        // 3. Bind data attributes onto the request context scope
        request.setAttribute("currentSystemThreshold", systemThreshold);
        request.setAttribute("facultiesList", dynamicFacultiesList);

        // 4. Forward execution cleanly into your updated selection interface form page
        request.getRequestDispatcher("adminReports.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
