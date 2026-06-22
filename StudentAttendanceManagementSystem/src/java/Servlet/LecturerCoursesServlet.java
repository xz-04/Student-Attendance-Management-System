package Servlet;

import DBConnection.DBConnection;
import Model.LecturerCourse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LecturerCoursesServlet")
public class LecturerCoursesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Protection Gatekeeper
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String lecturerMatricNo = (String) session.getAttribute("userId");

        // === CONSOLE DEBUGGING TRACER BLOCK ===
        System.out.println("=================================================");
        System.out.println("SAMS DB TRACKER: Querying lecturercourse for ID: [" + lecturerMatricNo + "]");
        System.out.println("=================================================");

        List<LecturerCourse> courseList = new ArrayList<>();

        // 2. QUERY MATCHING YOUR EXACT DATABASE SCHEMA
        // Finds rows assigned to the lecturer in 'lecturercourse', grabs names from 'course',
        // and uses a subquery to count the enrolled student totals from 'studentcourse'.
        String sql = "SELECT lc.courseCode, c.courseName, "
                + "  (SELECT COUNT(*) FROM studentcourse sc WHERE sc.courseCode = lc.courseCode) AS enrolled_count "
                + "FROM lecturercourse lc "
                + "JOIN course c ON lc.courseCode = c.courseCode "
                + "WHERE lc.matricNo = ? "
                + "ORDER BY lc.courseCode ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, lecturerMatricNo.trim());

            try (ResultSet rs = ps.executeQuery()) {
                int rowCounter = 0;
                while (rs.next()) {
                    rowCounter++;
                    String code = rs.getString("courseCode");
                    String name = rs.getString("courseName");
                    int count = rs.getInt("enrolled_count");

                    System.out.println("SAMS DB FOUND ROW " + rowCounter + ": " + code + " - " + name + " (" + count + " students)");

                    courseList.add(new LecturerCourse(code, name, count));
                }

                if (rowCounter == 0) {
                    System.out.println("SAMS DB WARNING: Query executed successfully but returned 0 rows for " + lecturerMatricNo);
                }
            }
        } catch (Exception e) {
            System.err.println("SAMS DB EXCEPTION CRASH:");
            e.printStackTrace();
        }

        // 3. Forward to display presentation layer
        request.setAttribute("lecturerCourses", courseList);
        request.getRequestDispatcher("attendanceSession.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
