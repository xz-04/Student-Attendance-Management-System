package Servlet;

import DBConnection.DBConnection;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SaveProfileServlet")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 5, // Max 5MB
        maxRequestSize = 1024 * 1024 * 25 // Max 25MB overall
)
public class SaveProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = ((String) session.getAttribute("userId")).trim();
        String phoneNo = request.getParameter("phoneNo");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // --- NEW: MALAYSIAN PHONE VALIDATION ---
        // Matches: 01x-xxxxxxx, 01xxxxxxxx, +601xxxxxxxxx, 601xxxxxxxxx
        String phoneRegex = "^(\\+?6?01)[0-46-9]-?[0-9]{7,8}$";
        if (phoneNo != null && !phoneNo.trim().isEmpty()) {
            phoneNo = phoneNo.trim();
            if (!phoneNo.matches(phoneRegex)) {
                session.setAttribute("msgError", "Update Failed: Please enter a valid Malaysian mobile number (e.g., 0123456789).");
                response.sendRedirect("ProfileServlet");
                return;
            }
        }

        // 1. EXTRACT IMAGE DATA
        byte[] rawImageBytes = null;
        Part photoPart = request.getPart("profilePhoto");
        if (photoPart != null && photoPart.getSize() > 0) {
            try (InputStream is = photoPart.getInputStream(); ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = is.read(buffer)) != -1) {
                    bos.write(buffer, 0, bytesRead);
                }
                rawImageBytes = bos.toByteArray();
            }
        }

        // 2. DATABASE TRANSACTION
        // Use try-with-resources to manage connection lifecycle
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Start transaction

            // PASSWORD VALIDATION
            boolean changePassword = (currentPassword != null && !currentPassword.isEmpty()
                    && newPassword != null && !newPassword.isEmpty());

            if (changePassword) {
                if (!newPassword.equals(confirmPassword)) {
                    session.setAttribute("msgError", "Update Failed: Passwords do not match!");
                    response.sendRedirect("ProfileServlet");
                    return;
                }

                // Verify current password
                String pwdVerifySql = "SELECT password FROM users WHERE matricNo = ?";
                try (PreparedStatement psVerify = conn.prepareStatement(pwdVerifySql)) {
                    psVerify.setString(1, userId);
                    try (ResultSet rs = psVerify.executeQuery()) {
                        if (rs.next() && !rs.getString("password").equals(currentPassword)) {
                            session.setAttribute("msgError", "Update Failed: Incorrect current password!");
                            response.sendRedirect("ProfileServlet");
                            return;
                        }
                    }
                }
            }

            // DYNAMIC UPDATE SQL
            StringBuilder sql = new StringBuilder("UPDATE users SET phoneNo = ?");
            if (changePassword) {
                sql.append(", password = ?");
            }
            if (rawImageBytes != null) {
                sql.append(", profilePhoto = ?");
            }
            sql.append(" WHERE matricNo = ?");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int paramIdx = 1;
                ps.setString(paramIdx++, phoneNo != null ? phoneNo.trim() : "");
                if (changePassword) {
                    ps.setString(paramIdx++, newPassword);
                }
                if (rawImageBytes != null) {
                    ps.setBytes(paramIdx++, rawImageBytes);
                }
                ps.setString(paramIdx, userId);
                ps.executeUpdate();
            }

            conn.commit(); // Finalize transaction
            session.setAttribute("msgSuccess", "Profile updated successfully!");

        } catch (SQLException e) {
            session.setAttribute("msgError", "Database error: " + e.getMessage());
            e.printStackTrace();
        }

        response.sendRedirect("ProfileServlet");
    }
}
