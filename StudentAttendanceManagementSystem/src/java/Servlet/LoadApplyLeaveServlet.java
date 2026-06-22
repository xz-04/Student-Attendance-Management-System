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

@WebServlet("/LoadApplyLeaveServlet")
public class LoadApplyLeaveServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Check Authenticated Session
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Extract student matric number safely based on your authentication system keys
        String studentMatricNo = null;
        if (session.getAttribute("userId") != null) {
            studentMatricNo = (String) session.getAttribute("userId");
        } else if (session.getAttribute("matricNo") != null) {
            studentMatricNo = (String) session.getAttribute("matricNo");
        }

        if (studentMatricNo == null || studentMatricNo.trim().isEmpty()) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Map<String, String>> enrolledCoursesList = new ArrayList<>();

        // 2. Query only the courses the active student is enrolled in
        String sql = "SELECT c.courseCode, c.courseName "
                + "FROM studentcourse sc "
                + "INNER JOIN course c ON sc.courseCode = c.courseCode "
                + "WHERE TRIM(sc.matricNo) = TRIM(?) "
                + "ORDER BY c.courseCode ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, studentMatricNo.trim());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> course = new HashMap<>();
                    course.put("courseCode", rs.getString("courseCode"));
                    course.put("courseName", rs.getString("courseName"));
                    enrolledCoursesList.add(course);
                }
            }
        } catch (SQLException e) {
            System.err.println("SAMS Error preloading active student courses: " + e.getMessage());
            e.printStackTrace();
        }

        // 3. Fallback Registry (Safeguard for clean testing if studentcourse table has no entries yet)
        if (enrolledCoursesList.isEmpty()) {
            System.out.println("SAMS Warning: studentcourse row matrix empty for " + studentMatricNo + ". Loading catalog fallback registry.");
            String fallbackSql = "SELECT courseCode, courseName FROM course ORDER BY courseCode ASC";
            try (Connection conn = DBConnection.getConnection(); PreparedStatement psFallback = conn.prepareStatement(fallbackSql); ResultSet rsFallback = psFallback.executeQuery()) {
                while (rsFallback.next()) {
                    Map<String, String> course = new HashMap<>();
                    course.put("courseCode", rsFallback.getString("courseCode"));
                    course.put("courseName", rsFallback.getString("courseName"));
                    enrolledCoursesList.add(course);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // 4. Bind the data to match your applyLeave.jsp tag items="${enrolledCoursesList}"
        request.setAttribute("enrolledCoursesList", enrolledCoursesList);

        // 5. Forward request right down into the form layout
        request.getRequestDispatcher("applyLeave.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
