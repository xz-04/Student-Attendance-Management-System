package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ViewLeaveDetailsServlet")
public class ViewLeaveDetailsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Authenticate user session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String leaveId = request.getParameter("leaveId");
        if (leaveId == null || leaveId.trim().isEmpty()) {
            response.sendRedirect("LecturerLeaveApprovalServlet");
            return;
        }

        Map<String, String> leaveDetails = null;

        // 2. Database Lookup Engine
        String sql = "SELECT al.leaveId, u.fullName, al.matricNo, al.courseCode, "
                + "DATE_FORMAT(al.date, '%Y-%m-%d') AS leaveDate, al.reason, al.evidencePath, al.approvalStatus "
                + "FROM absenceleave al "
                + "JOIN users u ON al.matricNo = u.matricNo "
                + "WHERE al.leaveId = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, leaveId.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    leaveDetails = new HashMap<>();
                    leaveDetails.put("leaveId", rs.getString("leaveId"));
                    leaveDetails.put("fullName", rs.getString("fullName"));
                    leaveDetails.put("matricNo", rs.getString("matricNo"));
                    leaveDetails.put("courseCode", rs.getString("courseCode"));
                    leaveDetails.put("leaveDate", rs.getString("leaveDate"));
                    leaveDetails.put("reason", rs.getString("reason"));
                    leaveDetails.put("evidencePath", rs.getString("evidencePath"));
                    leaveDetails.put("approvalStatus", rs.getString("approvalStatus"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 3. Routing Control
        if (leaveDetails != null) {
            request.setAttribute("leave", leaveDetails);
            request.getRequestDispatcher("viewLeaveDetails.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "The requested leave application record could not be found.");
            request.getRequestDispatcher("LecturerLeaveApprovalServlet").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
