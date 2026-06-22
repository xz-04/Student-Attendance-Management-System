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

@WebServlet("/LeaveServlet")
public class LeaveServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Validation Gatekeeper
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

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
        studentMatricNo = studentMatricNo.trim();

        // 2. Extract active filter tab status parameters (?status=all, pending, approved, rejected)
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.trim().isEmpty()) {
            statusFilter = "all";
        }
        statusFilter = statusFilter.trim().toLowerCase();

        List<Map<String, String>> leaveList = new ArrayList<>();

        // Counters for the dashboard tab badges
        int pendingCount = 0;
        int approvedCount = 0;
        int rejectedCount = 0;

        // 3. Database Query Architecture
        // JOINs with the course table to pull the courseName for your updated dashboard columns
        StringBuilder queryBuilder = new StringBuilder(
                "SELECT al.leaveId, al.courseCode, c.courseName, al.date, al.approvalStatus "
                + "FROM absenceleave al "
                + "LEFT JOIN course c ON al.courseCode = c.courseCode "
                + "WHERE LOWER(al.matricNo) = LOWER(?)"
        );

        // Append conditional SQL constraints matching filter tabs
        if ("pending".equals(statusFilter)) {
            queryBuilder.append(" AND LOWER(al.approvalStatus) = 'pending'");
        } else if ("approved".equals(statusFilter)) {
            queryBuilder.append(" AND LOWER(al.approvalStatus) = 'approved'");
        } else if ("rejected".equals(statusFilter)) {
            queryBuilder.append(" AND LOWER(al.approvalStatus) = 'rejected'");
        }

        // Sort items by date order sequence
        queryBuilder.append(" ORDER BY al.date DESC");

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // A. Execute Main Filtered Record Fetch Loop
                try (PreparedStatement ps = conn.prepareStatement(queryBuilder.toString())) {
                    ps.setString(1, studentMatricNo);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, String> leaveRecord = new HashMap<>();

                            // Notice: leaveId is now extracted cleanly as a String format (e.g. csf3023-s001-01)
                            leaveRecord.put("leaveId", rs.getString("leaveId"));
                            leaveRecord.put("courseCode", rs.getString("courseCode"));
                            leaveRecord.put("courseName", rs.getString("courseName") != null ? rs.getString("courseName") : "N/A");
                            leaveRecord.put("sessionDate", rs.getString("date")); // Maps to your form date field

                            // Format status values to maintain standard capitalized badges
                            String rawStatus = rs.getString("approvalStatus");
                            String formattedStatus = rawStatus.substring(0, 1).toUpperCase() + rawStatus.substring(1).toLowerCase();
                            leaveRecord.put("approvalStatus", formattedStatus);

                            leaveList.add(leaveRecord);
                        }
                    }
                }

                // B. COMPUTE TAB COUNTERS dynamically for UI metrics
                String counterSql = "SELECT approvalStatus, COUNT(*) AS cnt FROM absenceleave WHERE LOWER(matricNo) = LOWER(?) GROUP BY approvalStatus";
                try (PreparedStatement psCounter = conn.prepareStatement(counterSql)) {
                    psCounter.setString(1, studentMatricNo);
                    try (ResultSet rsCounter = psCounter.executeQuery()) {
                        while (rsCounter.next()) {
                            String status = rsCounter.getString("approvalStatus").toLowerCase();
                            int count = rsCounter.getInt("cnt");
                            if ("pending".equals(status)) {
                                pendingCount = count;
                            } else if ("approved".equals(status)) {
                                approvedCount = count;
                            } else if ("rejected".equals(status)) {
                                rejectedCount = count;
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("SAMS Dashboard Loader Engine Failure: " + e.getMessage());
            e.printStackTrace();
        }

        // 4. Pass Request Context Scope Attributes to match your JSTL dashboard loops
        request.setAttribute("leaveApplicationsList", leaveList);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);

        // 5. Forward request along with loaded lists straight into your dashboard overview view layer
        // Ensure this exactly matches the filename of your dashboard view (e.g., absenceLeave.jsp)
        request.getRequestDispatcher("absenceLeave.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
