package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/GetCoursesByFacultyServlet")
public class GetCoursesByFacultyServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String faculty = request.getParameter("faculty");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement("SELECT courseCode, courseName FROM course WHERE facultyName = ? ORDER BY courseName ASC")) {
            ps.setString(1, faculty);
            ResultSet rs = ps.executeQuery();

            StringBuilder json = new StringBuilder("[");
            while (rs.next()) {
                json.append("{\"code\":\"").append(rs.getString("courseCode"))
                        .append("\", \"name\":\"").append(rs.getString("courseName")).append("\"},");
            }
            if (json.length() > 1) {
                json.setLength(json.length() - 1);
            }
            json.append("]");
            response.getWriter().write(json.toString());
        } catch (SQLException e) {
            response.getWriter().write("[]");
        }
    }
}
