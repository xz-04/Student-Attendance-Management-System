package Servlet;

import DBConnection.DBConnection;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SaveProfileServlet")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 5, // Max 5MB
        maxRequestSize = 1024 * 1024 * 25 // Max 25MB overall request limits
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

        if (phoneNo != null) {
            phoneNo = phoneNo.trim();
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. EXTRACT AND CONVERT IMAGE DATA INTO AN EXPLICIT BYTE ARRAY
            Part photoPart = request.getPart("profilePhoto");
            byte[] rawImageBytes = null;

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

            // 2. PASSWORD CHANGE CHECK PIPELINE
            boolean changePassword = (currentPassword != null && !currentPassword.isEmpty()
                    && newPassword != null && !newPassword.isEmpty());

            if (changePassword) {
                if (!newPassword.equals(confirmPassword)) {
                    session.setAttribute("msgError", "Profile Update Failed: New passwords do not match!");
                    response.sendRedirect("ProfileServlet");
                    return;
                }

                String pwdVerifySql = "SELECT password FROM users WHERE matricNo = ?";
                try (PreparedStatement psVerify = conn.prepareStatement(pwdVerifySql)) {
                    psVerify.setString(1, userId);
                    try (ResultSet rs = psVerify.executeQuery()) {
                        if (rs.next()) {
                            String dbPassword = rs.getString("password");
                            if (!dbPassword.equals(currentPassword)) {
                                session.setAttribute("msgError", "Profile Update Failed: Current password entry is incorrect!");
                                response.sendRedirect("ProfileServlet");
                                return;
                            }
                        }
                    }
                }
            }

            // 3. CONSTRUCT DYNAMIC SAFE PARAMETERIZED SQL STATEMENT
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
                ps.setString(paramIdx++, phoneNo);

                if (changePassword) {
                    ps.setString(paramIdx++, newPassword);
                }
                if (rawImageBytes != null) {
                    // Injecting as a direct raw byte stream array bypasses JDBC stream mapping bugs entirely!
                    ps.setBytes(paramIdx++, rawImageBytes);
                }
                ps.setString(paramIdx, userId);

                ps.executeUpdate();
            }

            conn.commit();
            session.setAttribute("msgSuccess", "Profile data changes and photo saved completely!");

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            session.setAttribute("msgError", "Critical Error: Failed updating database data layers.");
            System.err.println("--> [SAMS BACKEND EXCEPTION ENCOUNTERED]:");
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }

        response.sendRedirect("ProfileServlet");
    }
}
