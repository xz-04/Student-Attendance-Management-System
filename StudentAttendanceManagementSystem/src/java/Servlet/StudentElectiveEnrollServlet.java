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

@WebServlet("/StudentElectiveEnrollServlet")
public class StudentElectiveEnrollServlet extends HttpServlet {

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
            action = "viewCatalog";
        }

        try {
            if ("viewCatalog".equalsIgnoreCase(action)) {
                renderElectiveCatalog(request, response, session);
            } else if ("enroll".equalsIgnoreCase(action)) {
                enrollInElective(request, response, session);
            } else if ("dropElective".equalsIgnoreCase(action)) {
                dropStudentElective(request, response, session);
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    // 1. ROUTE: FETCH AVAILABLE ELECTIVES MATCHING STUDENT'S RUNNING SEMESTER
    private void renderElectiveCatalog(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws Exception {
        String studentMatric = (String) session.getAttribute("userId");
        List<Map<String, String>> electiveList = new ArrayList<>();

        // Query to get the student's dynamic semester value out of the view
        String studentStatusSql = "SELECT currentLevel FROM v_student_current_status WHERE matricNo = ?";
        int currentSemTarget = 1; // Default fallback

        try (Connection conn = getConnection(); PreparedStatement psStatus = conn.prepareStatement(studentStatusSql)) {
            psStatus.setString(1, studentMatric);
            try (ResultSet rs = psStatus.executeQuery()) {
                if (rs.next()) {
                    String levelString = rs.getString("currentLevel");
                    if (levelString != null && levelString.contains("Sem 2")) {
                        currentSemTarget = 2;
                    }
                }
            }
        }

        // Query all electives for this semester that the student hasn't enrolled in yet
        // Updated Query: Ignore semesterTarget for Electives since they are 'open'
        String catalogSql = "SELECT courseCode, courseName, facultyName FROM course "
                + "WHERE courseStatus = 'Elective' "
                + "AND courseCode NOT IN (SELECT courseCode FROM studentcourse WHERE matricNo = ?) "
                + "ORDER BY courseCode ASC";

        try (Connection conn = getConnection(); PreparedStatement psCatalog = conn.prepareStatement(catalogSql)) {
            // We only set the matricNo now, so index 1 is for matricNo
            psCatalog.setString(1, studentMatric);

            try (ResultSet rs = psCatalog.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new HashMap<>();
                    row.put("courseCode", rs.getString("courseCode"));
                    row.put("courseName", rs.getString("courseName"));
                    row.put("facultyName", rs.getString("facultyName"));
                    electiveList.add(row);
                }
            }
        }

        request.setAttribute("availableElectives", electiveList);
        request.getRequestDispatcher("enrollElective.jsp").forward(request, response);
    }

    // 2. ROUTE: ENROLL STUDENT INTO ELECTIVE
    private void enrollInElective(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws Exception {
        String studentMatric = (String) session.getAttribute("userId");
        String courseCode = request.getParameter("courseCode");

        if (courseCode != null && !courseCode.trim().isEmpty()) {
            String insertSql = "INSERT INTO studentcourse (matricNo, courseCode) VALUES (?, ?)";
            try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, studentMatric);
                ps.setString(2, courseCode.trim());
                ps.executeUpdate();
                session.setAttribute("success", "Successfully self-enrolled in elective module " + courseCode);
            } catch (Exception e) {
                session.setAttribute("error", "Enrollment failed. You might already be registered in this elective.");
            }
        }
        response.sendRedirect("CourseAttendanceServlet"); // Send back to the main overview page
    }

    // 3. ROUTE: DROP ELECTIVE MODULE (STUDENT INITIATED)
    private void dropStudentElective(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws Exception {
        String studentMatric = (String) session.getAttribute("userId");
        String courseCode = request.getParameter("courseCode");

        if (courseCode != null && !courseCode.trim().isEmpty()) {
            // Extra safety checkpoint: Verify this is actually an elective before deleting
            String verifySql = "SELECT courseStatus FROM course WHERE courseCode = ?";
            boolean isElective = false;

            try (Connection conn = getConnection(); PreparedStatement psVerify = conn.prepareStatement(verifySql)) {
                psVerify.setString(1, courseCode);
                try (ResultSet rs = psVerify.executeQuery()) {
                    if (rs.next() && "Elective".equalsIgnoreCase(rs.getString("courseStatus"))) {
                        isElective = true;
                    }
                }
            }

            if (isElective) {
                String deleteSql = "DELETE FROM studentcourse WHERE matricNo = ? AND courseCode = ?";
                try (Connection conn = getConnection(); PreparedStatement psDelete = conn.prepareStatement(deleteSql)) {
                    psDelete.setString(1, studentMatric);
                    psDelete.setString(2, courseCode);
                    psDelete.executeUpdate();
                    session.setAttribute("success", "Successfully dropped elective module: " + courseCode);
                }
            } else {
                session.setAttribute("error", "Security Exception: You cannot manually drop core requirement parameters!");
            }
        }
        response.sendRedirect("CourseAttendanceServlet");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
