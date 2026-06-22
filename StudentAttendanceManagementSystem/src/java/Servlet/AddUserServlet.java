package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AddUserServlet")
public class AddUserServlet extends HttpServlet {

    // Helper database connection management provider
    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. Sanitize incoming form parameters
        String role = request.getParameter("role");
        String matricNo = request.getParameter("matricNo");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String facultyName = request.getParameter("facultyName");
        String programmeId = request.getParameter("programme"); // Receives the selected code value (e.g., 'CS')
        String intakeDateStr = request.getParameter("intakeDate");

        // Automated password assignment strategy matching matric identifier
        String password = (matricNo != null && !matricNo.trim().isEmpty()) ? matricNo.trim() : null;

        // Fail-safe validation check for general attributes
        if (role == null || matricNo == null || fullName == null || password == null || facultyName == null || email == null
                || role.trim().isEmpty() || matricNo.trim().isEmpty() || fullName.trim().isEmpty()
                || facultyName.trim().isEmpty() || email.trim().isEmpty()) {

            request.setAttribute("error", "All fields are required to register an account.");
            request.getRequestDispatcher("addUser.jsp").forward(request, response);
            return;
        }

        // 2. Strict validation matching constraints exclusively for student profiles
        if ("student".equalsIgnoreCase(role.trim())) {
            if (programmeId == null || programmeId.trim().isEmpty() || intakeDateStr == null || intakeDateStr.trim().isEmpty()) {
                request.setAttribute("error", "Registration Error: Student accounts require a valid Programme ID selection and Intake Date.");
                request.getRequestDispatcher("addUser.jsp").forward(request, response);
                return;
            }
        }

        Connection conn = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Enable transactional security boundaries

            // TRANSACTION STEP 1: Insert into core parent 'users' base table
            String insertUserSql = "INSERT INTO users (matricNo, password, fullName, role, facultyName, email) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql)) {
                psUser.setString(1, matricNo.trim());
                psUser.setString(2, password);
                psUser.setString(3, fullName.trim());
                psUser.setString(4, role.trim().toLowerCase());
                psUser.setString(5, facultyName.trim());
                psUser.setString(6, email.trim());
                psUser.executeUpdate();
            }

            // TRANSACTION STEP 2: Insert into corresponding specialization child relationship table
            if ("student".equalsIgnoreCase(role.trim())) {
                String studentSql = "INSERT INTO student (matricNo, programmeId, intakeDate) VALUES (?, ?, ?)";
                try (PreparedStatement psStudent = conn.prepareStatement(studentSql)) {
                    psStudent.setString(1, matricNo.trim());
                    psStudent.setString(2, programmeId.trim().toUpperCase()); // Maps the accurate choice token directly
                    psStudent.setDate(3, java.sql.Date.valueOf(intakeDateStr.trim()));
                    psStudent.executeUpdate();
                }
            } else if ("lecturer".equalsIgnoreCase(role.trim())) {
                String insertLecturerSql = "INSERT INTO lecturer (matricNo) VALUES (?)";
                try (PreparedStatement psLecturer = conn.prepareStatement(insertLecturerSql)) {
                    psLecturer.setString(1, matricNo.trim());
                    psLecturer.executeUpdate();
                }
            }

            conn.commit(); // Finalize database transactions safely

            // Redirect right back to the master table view with an active parameter refresh
            response.sendRedirect("AdminUsersServlet?roleTab=" + role.trim().toLowerCase());

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            e.printStackTrace();
            request.setAttribute("error", "Database error encountered during profiling: " + e.getMessage());
            request.getRequestDispatcher("addUser.jsp").forward(request, response);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
