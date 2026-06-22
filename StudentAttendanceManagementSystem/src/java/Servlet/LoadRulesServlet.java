package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoadRulesServlet")
public class LoadRulesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Validation
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Map<String, String> systemRules = new HashMap<>();
        systemRules.put("minAttendance", "80"); // Fallback default

        // 2. Query matching the schema in image_0d19a2.png
        String sql = "SELECT attendanceThreshold FROM systemrule WHERE ruleId = 1";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                systemRules.put("minAttendance", String.valueOf(rs.getInt("attendanceThreshold")));
            }
        } catch (SQLException e) {
            System.err.println("--> [SAMS CRITICAL] Failed loading from systemrule table!");
            e.printStackTrace();
        }

        // 3. Forward payload to JSP page
        request.setAttribute("rules", systemRules);
        request.getRequestDispatcher("attendanceRules.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
