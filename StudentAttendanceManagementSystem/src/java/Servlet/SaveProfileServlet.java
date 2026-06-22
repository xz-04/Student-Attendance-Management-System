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
@MultipartConfig(maxFileSize = 1024 * 1024 * 5, maxRequestSize = 1024 * 1024 * 25)
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

        // Declare Connection outside to keep it in scope for the entire method
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Password handling
            boolean changePassword = (currentPassword != null && !currentPassword.isEmpty()
                    && newPassword != null && !newPassword.isEmpty());

            if (changePassword) {
                if (!newPassword.equals(confirmPassword)) {
                    session.setAttribute("msgError", "Passwords do not match!");
                    response.sendRedirect("ProfileServlet");
                    return;
                }

                String pwdVerifySql = "SELECT password FROM users WHERE matricNo = ?";
                try (PreparedStatement psVerify = conn.prepareStatement(pwdVerifySql)) {
                    psVerify.setString(1, userId);
                    try (ResultSet rs = psVerify.executeQuery()) {
                        if (rs.next() && !rs.getString("password").equals(currentPassword)) {
                            session.setAttribute("msgError", "Incorrect current password!");
                            response.sendRedirect("ProfileServlet");
                            return;
                        }
                    }
                }
            }

            // Build dynamic update
            StringBuilder sql = new StringBuilder("UPDATE users SET phoneNo = ?");
            if (changePassword) {
                sql.append(", password = ?");
            }
            if (rawImageBytes != null) {
                sql.append(", profilePhoto = ?");
            }
            sql.append(" WHERE matricNo = ?");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int i = 1;
                ps.setString(i++, phoneNo != null ? phoneNo.trim() : "");
                if (changePassword) {
                    ps.setString(i++, newPassword);
                }
                if (rawImageBytes != null) {
                    ps.setBytes(i++, rawImageBytes);
                }
                ps.setString(i, userId);
                ps.executeUpdate();
            }

            conn.commit();
            session.setAttribute("msgSuccess", "Profile updated successfully!");

        } catch (SQLException e) {
            if (conn != null) try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            session.setAttribute("msgError", "Database error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (conn != null) try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("ProfileServlet");
    }
}
