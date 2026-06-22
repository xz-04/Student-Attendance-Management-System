package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ProcessLeaveApproval")
public class ProcessLeaveApproval extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. Session Authentication Gatekeeper
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // MODIFIED: Extracting form parameters sent from the frontend overlay pipeline layout
        String leaveId = request.getParameter("leaveId");
        String action = request.getParameter("action"); // Expected values: 'approve' or 'reject'

        // Log diagnostics to NetBeans output console
        System.out.println("--> [SAMS LEAVE ACTION] Processing Key: " + leaveId + " | Action Intent: " + action);

        if (leaveId == null || action == null || leaveId.trim().isEmpty()) {
            response.sendRedirect("LecturerLeaveApprovalServlet");
            return;
        }

        String updateSql = "";
        boolean isRejection = "reject".equalsIgnoreCase(action.trim());
        String rejectReason = null;

        // 2. MODIFIED: Constructing safe SQL update statements contextually depending on action metrics
        if (isRejection) {
            updateSql = "UPDATE absenceleave SET approvalStatus = 'Rejected', rejectReason = ? WHERE leaveId = ?";
            rejectReason = request.getParameter("rejectReason");
            if (rejectReason == null || rejectReason.trim().isEmpty()) {
                rejectReason = "No explanation provided by reviewer.";
            }
        } else {
            // Approval track clears any previous rejection logs out cleanly to prevent state pollution
            updateSql = "UPDATE absenceleave SET approvalStatus = 'Approved', rejectReason = NULL WHERE leaveId = ?";
        }

        // 3. Database Transaction Execution
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(updateSql)) {

            if (isRejection) {
                ps.setString(1, rejectReason.trim());
                ps.setString(2, leaveId.trim());
            } else {
                ps.setString(1, leaveId.trim());
            }

            int rowsUpdated = ps.executeUpdate();
            String finalizedStatusText = isRejection ? "rejected" : "approved";

            if (rowsUpdated > 0) {
                // Store a flash message in the session to render as a banner on the redirect page
                request.getSession().setAttribute("approvalSuccessMsg",
                        "Application " + leaveId.toUpperCase() + " has been successfully " + finalizedStatusText + ".");
            } else {
                request.getSession().setAttribute("error", "Failed to update status. Record may no longer exist.");
            }

        } catch (SQLException e) {
            System.err.println("--> [SAMS SQL ERROR] Failure updating absenceleave status!");
            e.printStackTrace();
            request.getSession().setAttribute("error", "Database Error: " + e.getMessage());
        }

        // 4. Redirect safely back to the main leave list (loads in the same tab)
        response.sendRedirect("LecturerLeaveApprovalServlet");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect standard GET requests directly back to the secure list menu
        response.sendRedirect("LecturerLeaveApprovalServlet");
    }
}
