package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SaveRulesServlet")
public class SaveRulesServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        int targetThreshold = 80; // Default fallback

        if ("SAVE".equalsIgnoreCase(action)) {
            String inputPct = request.getParameter("minAttendance");
            if (inputPct != null && !inputPct.trim().isEmpty()) {
                targetThreshold = Integer.parseInt(inputPct.trim());
            }
        }

        // Upsert query specific to your systemrule schema
        String sql = "INSERT INTO systemrule (ruleId, attendanceThreshold) VALUES (1, ?) "
                + "ON DUPLICATE KEY UPDATE attendanceThreshold = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, targetThreshold);
            ps.setInt(2, targetThreshold);
            ps.executeUpdate();

        } catch (SQLException e) {
            System.err.println("--> [SAMS CRITICAL] Failed updating systemrule table parameters!");
            e.printStackTrace();
        }

        // Redirect back through your data loader to refresh the form
        response.sendRedirect("LoadRulesServlet?success=true");
    }
}
