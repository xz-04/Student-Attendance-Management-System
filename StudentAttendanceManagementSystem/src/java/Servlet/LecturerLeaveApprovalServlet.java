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

@WebServlet("/LecturerLeaveApprovalServlet")
public class LecturerLeaveApprovalServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper - Verify Lecturer Authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String lecturerMatricNo = (String) session.getAttribute("userId");
        lecturerMatricNo = lecturerMatricNo.trim();

        List<Map<String, Object>> leaveApplicationsList = new ArrayList<>();
        List<Map<String, String>> assignedCoursesList = new ArrayList<>();

        // 2. Query Pipeline Execution
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // SUB-QUERY A: Fetch all courses assigned to this lecturer for the dropdown filter option matrix
                String coursesSql = "SELECT courseCode FROM lecturercourse WHERE TRIM(matricNo) = ? ORDER BY courseCode ASC";
                try (PreparedStatement psCourses = conn.prepareStatement(coursesSql)) {
                    psCourses.setString(1, lecturerMatricNo);
                    try (ResultSet rsCourses = psCourses.executeQuery()) {
                        while (rsCourses.next()) {
                            Map<String, String> courseItem = new HashMap<>();
                            courseItem.put("courseCode", rsCourses.getString("courseCode"));
                            assignedCoursesList.add(courseItem);
                        }
                    }
                }

                // SUB-QUERY B: Fetch leave applications for students in this lecturer's assigned courses
                // FIXED: Replaced DATE_FORMAT(al.leaveId) with DATE_FORMAT(al.date) to extract the true application target date
                String leavesSql = "SELECT al.leaveId, u.fullName, al.matricNo, al.courseCode, "
                        + "DATE_FORMAT(al.date, '%Y-%m-%d') AS actualLeaveDate, "
                        + "al.reason, al.evidencePath, al.approvalStatus "
                        + "FROM absenceleave al "
                        + "JOIN users u ON al.matricNo = u.matricNo "
                        + "JOIN lecturercourse lc ON al.courseCode = lc.courseCode "
                        + "WHERE TRIM(lc.matricNo) = ? "
                        + "ORDER BY al.approvalStatus DESC, al.date DESC"; // Ordered by latest application dates first

                try (PreparedStatement psLeaves = conn.prepareStatement(leavesSql)) {
                    psLeaves.setString(1, lecturerMatricNo);
                    try (ResultSet rsLeaves = psLeaves.executeQuery()) {
                        while (rsLeaves.next()) {
                            Map<String, Object> appItem = new HashMap<>();

                            appItem.put("leaveId", rsLeaves.getString("leaveId"));
                            appItem.put("fullName", rsLeaves.getString("fullName"));
                            appItem.put("matricNo", rsLeaves.getString("matricNo"));
                            appItem.put("courseCode", rsLeaves.getString("courseCode"));
                            appItem.put("reason", rsLeaves.getString("reason"));
                            appItem.put("evidencePath", rsLeaves.getString("evidencePath"));

                            // Normalize approval status text casing (e.g., 'Pending', 'Approved', 'Rejected')
                            String rawStatus = rsLeaves.getString("approvalStatus");
                            if (rawStatus != null && !rawStatus.isEmpty()) {
                                String formattedStatus = rawStatus.substring(0, 1).toUpperCase() + rawStatus.substring(1).toLowerCase();
                                appItem.put("approvalStatus", formattedStatus);
                            } else {
                                appItem.put("approvalStatus", "Pending");
                            }

                            // FIXED: Mapped the verified date string into sessionDate for your approval page view rows
                            appItem.put("sessionDate", rsLeaves.getString("actualLeaveDate"));

                            leaveApplicationsList.add(appItem);
                        }
                    }
                }
                System.out.println("--> [SAMS DEBUG] Total Absence Leave Requests loaded for lecturer: " + leaveApplicationsList.size());
            }
        } catch (SQLException e) {
            System.err.println("--> [SAMS SQL ERROR] Failure loading lecturer leave approval list records!");
            e.printStackTrace();
        }

        // 3. Bind objects to request context attributes
        request.setAttribute("lecturerAssignedCourses", assignedCoursesList);
        request.setAttribute("leaveApplicationsList", leaveApplicationsList);

        // 4. Dispatch straight to your approvalLeave.jsp view layout page
        request.getRequestDispatcher("approvalLeave.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
