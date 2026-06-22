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

@WebServlet("/ViewEnrolledStudentsServlet")
public class ViewEnrolledStudentsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String courseCode = request.getParameter("courseCode");
        List<Map<String, String>> studentRoster = new ArrayList<>();

        String sql = "SELECT sc.matricNo, u.fullName, u.email FROM studentcourse sc "
                + "JOIN users u ON sc.matricNo = u.matricNo "
                + "WHERE sc.courseCode = ? ORDER BY u.fullName ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseCode);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new HashMap<>();
                    row.put("matricNo", rs.getString("matricNo"));
                    row.put("fullName", rs.getString("fullName"));
                    row.put("email", rs.getString("email"));
                    studentRoster.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("courseCode", courseCode);
        request.setAttribute("studentRoster", studentRoster);
        request.getRequestDispatcher("viewEnrolledStudents.jsp").forward(request, response);
    }
}
