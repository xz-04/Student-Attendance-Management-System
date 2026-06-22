package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SavePasswordServlet")
public class SavePasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = ((String) session.getAttribute("userId")).trim();
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // 1. Check if passwords match
        if (!newPassword.equals(confirmPassword)) {
            session.setAttribute("msgError", "Security Update Failed: Passwords do not match!");
            response.sendRedirect("ProfileServlet");
            return;
        }

        // 2. Validate Password Strength (Min 6 chars, at least one letter and one number)
        String passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$";
        if (!newPassword.matches(passwordRegex)) {
            session.setAttribute("msgError", "Security Update Failed: Password must be at least 6 characters and include both letters and numbers.");
            response.sendRedirect("ProfileServlet");
            return;
        }

        // 3. Update directly (Current password check removed as requested)
        try (Connection conn = DBConnection.getConnection()) {
            String updateSql = "UPDATE users SET password = ? WHERE matricNo = ?";
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psUpdate.setString(1, newPassword);
                psUpdate.setString(2, userId);
                psUpdate.executeUpdate();
            }
            session.setAttribute("msgSuccess", "Account password updated successfully!");
        } catch (Exception e) {
            session.setAttribute("msgError", "Critical Error: System failed to update security records.");
            e.printStackTrace();
        }

        response.sendRedirect("ProfileServlet");
    }
}
