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

@WebServlet("/CourseServlet")
public class CourseServlet extends HttpServlet {

    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action.toLowerCase()) {
                case "delete":
                    deleteCourse(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "list":
                default:
                    listCourses(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            switch (action.toLowerCase()) {
                case "add":
                    addCourse(request, response);
                    break;
                case "update":
                    updateCourse(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    // 1. ACTION: RENDER MASTER COURSE RECORD GRID
    private void listCourses(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String searchCourse = request.getParameter("searchCourse");
        List<Course> courseList = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT facultyName, courseCode, courseName, yearOfStudy, semesterTarget, courseStatus FROM course WHERE 1=1");

        if (searchCourse != null && !searchCourse.trim().isEmpty()) {
            sql.append(" AND (facultyName LIKE ? OR courseCode LIKE ? OR courseName LIKE ?)");
        }
        sql.append(" ORDER BY facultyName ASC, courseCode ASC");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (searchCourse != null && !searchCourse.trim().isEmpty()) {
                String wildSearch = "%" + searchCourse.trim() + "%";
                ps.setString(1, wildSearch);
                ps.setString(2, wildSearch);
                ps.setString(3, wildSearch);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String courseStatus = rs.getString("courseStatus");
                    if (courseStatus == null) {
                        courseStatus = "Core";
                    }

                    // FIXED: Passed courseStatus as the 4th argument to clear compilation errors
                    Course c = new Course(
                            rs.getString("facultyName"),
                            rs.getString("courseCode"),
                            rs.getString("courseName"),
                            courseStatus
                    );

                    request.setAttribute("year_" + rs.getString("courseCode"), rs.getInt("yearOfStudy"));
                    request.setAttribute("sem_" + rs.getString("courseCode"), rs.getInt("semesterTarget"));
                    request.setAttribute("status_" + rs.getString("courseCode"), courseStatus);

                    courseList.add(c);
                }
            }
        }
        request.setAttribute("adminCoursesList", courseList);
        request.getRequestDispatcher("adminCourses.jsp").forward(request, response);
    }

    // 2. ACTION: ADD NEW COURSE ENTRY MODULE
    private void addCourse(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String facultyName = request.getParameter("facultyName").trim().toUpperCase();
        String courseCode = request.getParameter("courseCode").trim().toUpperCase();
        String courseName = request.getParameter("courseName").trim();

        String courseStatus = request.getParameter("courseStatus");
        if (courseStatus == null) {
            courseStatus = "Core";
        }

        int semesterTarget = Integer.parseInt(request.getParameter("semesterTarget"));

        int yearOfStudy = 0;
        if ("Core".equalsIgnoreCase(courseStatus)) {
            String yearParam = request.getParameter("yearOfStudy");
            if (yearParam != null && !yearParam.isEmpty()) {
                yearOfStudy = Integer.parseInt(yearParam);
            }
        }

        try (Connection conn = getConnection()) {
            String checkSql = "SELECT COUNT(*) FROM course WHERE courseCode = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, courseCode);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        request.setAttribute("error", "Course code " + courseCode + " already exists.");
                        request.getRequestDispatcher("addCourse.jsp").forward(request, response);
                        return;
                    }
                }
            }

            String insertSql = "INSERT INTO course (facultyName, courseCode, courseName, yearOfStudy, semesterTarget, courseStatus) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setString(1, facultyName);
                insertPs.setString(2, courseCode);
                insertPs.setString(3, courseName);
                insertPs.setInt(4, yearOfStudy);
                insertPs.setInt(5, semesterTarget);
                insertPs.setString(6, courseStatus);
                insertPs.executeUpdate();
            }
            response.sendRedirect("CourseServlet?action=list");
        }
    }

    // 3. ACTION: FETCH COURSE DATA FOR EDIT VIEW
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String courseCode = request.getParameter("courseCode");
        Course existingCourse = null;

        String sql = "SELECT facultyName, courseCode, courseName, yearOfStudy, semesterTarget, courseStatus FROM course WHERE courseCode = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String courseStatus = rs.getString("courseStatus");
                    if (courseStatus == null) {
                        courseStatus = "Core";
                    }

                    // FIXED: Passed courseStatus as the 4th constructor argument to fix line 178
                    existingCourse = new Course(
                            rs.getString("facultyName"),
                            rs.getString("courseCode"),
                            rs.getString("courseName"),
                            courseStatus
                    );

                    request.setAttribute("yearOfStudy", rs.getInt("yearOfStudy"));
                    request.setAttribute("semesterTarget", rs.getInt("semesterTarget"));
                    request.setAttribute("courseStatus", courseStatus);
                }
            }
        }
        request.setAttribute("course", existingCourse);
        request.getRequestDispatcher("editCourse.jsp").forward(request, response);
    }

    // 4. ACTION: UPDATE EXISTING RECORD EXECUTOR
    private void updateCourse(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String facultyName = request.getParameter("facultyName").trim().toUpperCase();
        String courseCode = request.getParameter("courseCode").trim().toUpperCase();
        String courseName = request.getParameter("courseName").trim();

        String courseStatus = request.getParameter("courseStatus");
        if (courseStatus == null) {
            courseStatus = "Core";
        }

        int semesterTarget = Integer.parseInt(request.getParameter("semesterTarget"));

        int yearOfStudy = 0;
        if ("Core".equalsIgnoreCase(courseStatus)) {
            String yearParam = request.getParameter("yearOfStudy");
            if (yearParam != null && !yearParam.isEmpty()) {
                yearOfStudy = Integer.parseInt(yearParam);
            }
        }

        String sql = "UPDATE course SET facultyName = ?, courseName = ?, yearOfStudy = ?, semesterTarget = ?, courseStatus = ? WHERE courseCode = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, facultyName);
            ps.setString(2, courseName);
            ps.setInt(3, yearOfStudy);
            ps.setInt(4, semesterTarget);
            ps.setString(5, courseStatus);
            ps.setString(6, courseCode);
            ps.executeUpdate();
        }
        response.sendRedirect("CourseServlet?action=list");
    }

    // 5. ACTION: CASCADE REMOVE SYSTEM COURSE RECORD
    private void deleteCourse(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String courseCode = request.getParameter("courseCode");

        if (courseCode != null && !courseCode.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement psChild1 = null;
            PreparedStatement psChild2 = null;
            PreparedStatement psParent = null;

            try {
                conn = getConnection();
                conn.setAutoCommit(false);

                String deleteSessionsSql = "DELETE FROM attendancesession WHERE courseCode = ?";
                psChild1 = conn.prepareStatement(deleteSessionsSql);
                psChild1.setString(1, courseCode);
                psChild1.executeUpdate();

                String deleteEnrollmentsSql = "DELETE FROM studentcourse WHERE courseCode = ?";
                psChild2 = conn.prepareStatement(deleteEnrollmentsSql);
                psChild2.setString(1, courseCode);
                psChild2.executeUpdate();

                String deleteCourseSql = "DELETE FROM course WHERE courseCode = ?";
                psParent = conn.prepareStatement(deleteCourseSql);
                psParent.setString(1, courseCode);
                psParent.executeUpdate();

                conn.commit();
                request.getSession().setAttribute("success", "Course and all associated records deleted successfully.");

            } catch (Exception e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
                e.printStackTrace();
                request.getSession().setAttribute("error", "Failed to delete course: " + e.getMessage());
            } finally {
                if (psChild1 != null) try {
                    psChild1.close();
                } catch (SQLException e) {
                }
                if (psChild2 != null) try {
                    psChild2.close();
                } catch (SQLException e) {
                }
                if (psParent != null) try {
                    psParent.close();
                } catch (SQLException e) {
                }
                if (conn != null) try {
                    conn.close();
                } catch (SQLException e) {
                }
            }
        }
        response.sendRedirect("CourseServlet?action=list");
    }
}
