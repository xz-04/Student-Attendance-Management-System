package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LecturerAssignmentServlet")
public class LecturerAssignmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        // 1. Session Gatekeeper
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Capture parameters
        String lecturerMatricNo = request.getParameter("lecturerMatricNo");
        String courseCode = request.getParameter("courseCode");

        // Validate incoming data
        if (lecturerMatricNo == null || courseCode == null || lecturerMatricNo.trim().isEmpty() || courseCode.trim().isEmpty()) {
            session.setAttribute("error", "Invalid assignment selection. Please choose both a lecturer and a course.");
            response.sendRedirect("assignLecturerCourse.jsp");
            return;
        }

        String matric = lecturerMatricNo.trim();
        String code = courseCode.trim();

        try (Connection conn = DBConnection.getConnection()) {
            // 3. Checkpoint Guard: Prevent duplicate assignments
            String checkSql = "SELECT COUNT(*) FROM lecturercourse WHERE matricNo = ? AND courseCode = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, matric);
                checkPs.setString(2, code);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        session.setAttribute("error", "The lecturer (" + matric + ") is already assigned to module: " + code);
                        response.sendRedirect("assignLecturerCourse.jsp?matricNo=" + matric);
                        return;
                    }
                }
            }

            // 4. Persistence: Insert into bridge table
            String insertSql = "INSERT INTO lecturercourse (matricNo, courseCode) VALUES (?, ?)";
            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setString(1, matric);
                insertPs.setString(2, code);
                insertPs.executeUpdate();

                // 5. Success Feedback
                session.setAttribute("success", "Successfully assigned course " + code + " to the selected lecturer.");
            }

            // Redirect back to dashboard
            response.sendRedirect("AdminUsersServlet?roleTab=lecturer");

        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database fault: Unable to process assignment. " + e.getMessage());
            response.sendRedirect("assignLecturerCourse.jsp?matricNo=" + matric);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect invalid GET attempts to the assignment page
        response.sendRedirect("assignLecturerCourse.jsp");
    }
}
