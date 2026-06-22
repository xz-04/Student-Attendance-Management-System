package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RemoveAssignmentServlet")
public class RemoveAssignmentServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String courseCode = request.getParameter("courseCode");
        String matricNo = request.getParameter("matricNo");

        String sql = "DELETE FROM lecturercourse WHERE courseCode = ? AND matricNo = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, courseCode);
            ps.setString(2, matricNo);
            ps.executeUpdate();

            HttpSession session = request.getSession();
            session.setAttribute("msgSuccess", "Assignment removed successfully.");

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Redirect back to the view page for this specific lecturer
        response.sendRedirect("ViewLecturerCoursesServlet?matricNo=" + matricNo);
    }
}
