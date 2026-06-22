package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ViewLecturerCoursesServlet")
public class ViewLecturerCoursesServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String matricNo = request.getParameter("matricNo");

        // Query to join course table with lecturercourse bridge table
        String sql = "SELECT c.courseCode, c.courseName, c.facultyName "
                + "FROM course c "
                + "JOIN lecturercourse lc ON c.courseCode = lc.courseCode "
                + "WHERE lc.matricNo = ?";

        List<Map<String, String>> assignedCourses = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, matricNo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> course = new HashMap<>();
                    course.put("code", rs.getString("courseCode"));
                    course.put("name", rs.getString("courseName"));
                    course.put("faculty", rs.getString("facultyName"));
                    assignedCourses.add(course);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("assignedCourses", assignedCourses);
        request.setAttribute("lecturerMatric", matricNo);
        request.getRequestDispatcher("viewLecturerCourses.jsp").forward(request, response);
    }
}
