package Servlet;

import DBConnection.DBConnection;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = ((String) session.getAttribute("userId")).trim();
        String userRole = (String) session.getAttribute("userRole");
        if (userRole != null) {
            userRole = userRole.trim().toLowerCase();
        } else {
            userRole = "student";
        }

        Map<String, String> userProfile = new HashMap<>();

        // 1. REFACTORED SQL: Accommodates database structural mapping changes
        String sql = "";
        if ("student".equals(userRole)) {
            // Selecting s.programmeId to map into the third slot, and p.programmeName to get the full name description
            sql = "SELECT u.matricNo, u.fullName, s.programmeId AS displayFacultyOrProgId, u.email, u.phoneNo, u.profilePhoto, "
                    + "p.programmeName AS programmeNameField, s.intakeDate, v.currentSession, v.currentLevel "
                    + "FROM users u "
                    + "JOIN student s ON u.matricNo = s.matricNo "
                    + "JOIN programme p ON s.programmeId = p.programmeId "
                    + "LEFT JOIN v_student_current_status v ON u.matricNo = v.matricNo "
                    + "WHERE u.matricNo = ?";
        } else {
            // Lecturers and Admins keep their standard facultyName parameter string
            sql = "SELECT u.matricNo, u.fullName, u.facultyName AS displayFacultyOrProgId, u.email, u.phoneNo, u.profilePhoto "
                    + "FROM users u "
                    + "WHERE u.matricNo = ?";
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    userProfile.put("identifier", rs.getString("matricNo"));
                    userProfile.put("name", rs.getString("fullName"));
                    userProfile.put("faculty", rs.getString("displayFacultyOrProgId")); // Overridden to match JSP token loop updates
                    userProfile.put("email", rs.getString("email"));

                    String phone = rs.getString("phoneNo");
                    userProfile.put("phone", (phone != null) ? phone.trim() : "");

                    // 2. Read Image Profile Photo BLOB and transform into Base64 URI
                    Blob blob = rs.getBlob("profilePhoto");
                    String base64ImageStr = "";
                    if (blob != null && blob.length() > 0) {
                        try (InputStream is = blob.getBinaryStream(); ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
                            byte[] buffer = new byte[4096];
                            int bytesRead;
                            while ((bytesRead = is.read(buffer)) != -1) {
                                bos.write(buffer, 0, bytesRead);
                            }
                            base64ImageStr = "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(bos.toByteArray());
                        }
                    }
                    userProfile.put("avatarPath", base64ImageStr);

                    // 3. STUDENT MODULE: Maps programmatic metadata labels dynamically
                    if ("student".equals(userRole)) {
                        userProfile.put("programme", rs.getString("programmeNameField"));

                        String batchSession = rs.getString("currentSession");
                        String currentLevel = rs.getString("currentLevel");

                        userProfile.put("batchSession", batchSession != null ? batchSession : "-");

                        // Formats string value directly to update progression status box text labels
                        if (batchSession != null && currentLevel != null) {
                            userProfile.put("academicYearSem", "Batch " + batchSession + " | " + currentLevel);
                        } else {
                            userProfile.put("academicYearSem", "No Registration Log Found");
                        }
                    } else {
                        userProfile.put("programme", "-");
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("--> [CRITICAL ERROR] SAMS Profile Data Retrieval pipeline failed execution.");
            e.printStackTrace();
        }

        request.setAttribute("userProfile", userProfile);
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
