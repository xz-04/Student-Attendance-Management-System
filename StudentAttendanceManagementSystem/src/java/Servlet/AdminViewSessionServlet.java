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

@WebServlet("/AdminViewSessionServlet")
public class AdminViewSessionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sessionId = request.getParameter("sessionId");
        if (sessionId == null || sessionId.trim().isEmpty()) {
            response.sendRedirect("AdminSessionsServlet");
            return;
        }

        sessionId = sessionId.trim();
        Map<String, String> sessionMetadata = new HashMap<>();
        List<Map<String, Object>> masterRosterList = new ArrayList<>();

        // QUERY 1: Fetch session core metadata details
        String sessionSql = "SELECT s.sessionId, s.courseCode, u.fullName AS lecturerName, s.date, s.venue "
                + "FROM attendancesession s "
                + "JOIN users u ON s.matricNo = u.matricNo WHERE s.sessionId = ?";

        // OPTIMIZED COMBINED QUERY: Fetch all enrolled students and LEFT JOIN their attendance status for this specific session
        String rosterSql = "SELECT sc.matricNo, u.fullName, "
                + "  DATE_FORMAT(ar.checkinTime, '%H:%i:%s') AS checkTime, "
                + "  ar.ipAddress, "
                + "  IF(ar.matricNo IS NOT NULL, 'PRESENT', 'ABSENT') AS attendanceStatus "
                + "FROM studentcourse sc "
                + "JOIN users u ON sc.matricNo = u.matricNo "
                + "LEFT JOIN attendancerecord ar ON sc.matricNo = ar.matricNo AND ar.sessionId = ? "
                + "WHERE sc.courseCode = ? "
                + "ORDER BY u.fullName ASC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // STEP A: Fetch Session Metadata Headers
                try (PreparedStatement psSession = conn.prepareStatement(sessionSql)) {
                    psSession.setString(1, sessionId);
                    try (ResultSet rsSession = psSession.executeQuery()) {
                        if (rsSession.next()) {
                            sessionMetadata.put("sessionId", rsSession.getString("sessionId"));
                            sessionMetadata.put("courseCode", rsSession.getString("courseCode"));
                            sessionMetadata.put("lecturerName", rsSession.getString("lecturerName"));
                            sessionMetadata.put("date", rsSession.getString("date"));
                            sessionMetadata.put("venue", rsSession.getString("venue"));
                        }
                    }
                }

                // STEP B: Fetch Unified Master Attendance Roster
                String courseCode = sessionMetadata.get("courseCode");
                if (courseCode != null) {
                    try (PreparedStatement psRoster = conn.prepareStatement(rosterSql)) {
                        psRoster.setString(1, sessionId);
                        psRoster.setString(2, courseCode);

                        try (ResultSet rsRoster = psRoster.executeQuery()) {
                            int totalPresent = 0;

                            while (rsRoster.next()) {
                                Map<String, Object> row = new HashMap<>();
                                row.put("matricNo", rsRoster.getString("matricNo"));
                                row.put("fullName", rsRoster.getString("fullName"));

                                String checkTime = rsRoster.getString("checkTime");
                                row.put("checkTime", checkTime != null ? checkTime : "-");

                                String ipAddress = rsRoster.getString("ipAddress");
                                row.put("ipAddress", ipAddress != null ? ipAddress : "-");

                                String status = rsRoster.getString("attendanceStatus");
                                row.put("status", status);

                                if ("PRESENT".equals(status)) {
                                    totalPresent++;
                                }

                                masterRosterList.add(row);
                            }
                            // Save the total count dynamically for the top right badge widget
                            sessionMetadata.put("presentCount", String.valueOf(totalPresent));
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Forward unified data payload to the view
        request.setAttribute("sessionMeta", sessionMetadata);
        request.setAttribute("rosterList", masterRosterList);
        request.getRequestDispatcher("viewSessionAttendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
