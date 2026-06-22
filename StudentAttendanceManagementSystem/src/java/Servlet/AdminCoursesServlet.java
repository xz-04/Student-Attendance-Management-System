package Servlet;

import DBConnection.DBConnection;
import Model.Course;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminCoursesServlet")
public class AdminCoursesServlet extends HttpServlet {

    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Safety Gatekeeper Guard Verification Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String searchCourse = request.getParameter("searchCourse");
        List<Course> courseList = new ArrayList<>();

        // 2. Form basic database query selection statement criteria rule
        StringBuilder sql = new StringBuilder("SELECT facultyName, courseCode, courseName, yearOfStudy, semesterTarget, courseStatus FROM course WHERE 1=1");

        if (searchCourse != null && !searchCourse.trim().isEmpty()) {
            sql.append(" AND (facultyName LIKE ? OR courseCode LIKE ? OR courseName LIKE ?)");
        }

        sql.append(" ORDER BY facultyName ASC, courseCode ASC");

        // 3. Populate parameters and query your schema
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (searchCourse != null && !searchCourse.trim().isEmpty()) {
                String wildSearch = "%" + searchCourse.trim() + "%";
                ps.setString(1, wildSearch);
                ps.setString(2, wildSearch);
                ps.setString(3, wildSearch);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String courseCode = rs.getString("courseCode");

                    // Extract the classification status string safely
                    String courseStatus = rs.getString("courseStatus");
                    if (courseStatus == null) {
                        courseStatus = "Core"; // Safe default fallback
                    }

                    // FIXED: Using the 4-argument constructor signature layout
                    Course c = new Course(
                            rs.getString("facultyName"),
                            courseCode,
                            rs.getString("courseName"),
                            courseStatus
                    );

                    // Bind the raw programmatic parameters onto request attributes for your JSP page rows to read
                    request.setAttribute("year_" + courseCode, rs.getInt("yearOfStudy"));
                    request.setAttribute("sem_" + courseCode, rs.getInt("semesterTarget"));
                    request.setAttribute("status_" + courseCode, courseStatus);

                    courseList.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database failure: " + e.getMessage());
        }

        // 4. Bind variables to request attributes and route to display interface container
        request.setAttribute("adminCoursesList", courseList);
        request.getRequestDispatcher("adminCourses.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
