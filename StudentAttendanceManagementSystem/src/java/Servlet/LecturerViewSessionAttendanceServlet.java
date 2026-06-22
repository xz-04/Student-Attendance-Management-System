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

@WebServlet("/LecturerViewSessionAttendanceServlet")
public class LecturerViewSessionAttendanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sessionId = request.getParameter("sessionId");
        if (sessionId == null || sessionId.trim().isEmpty()) {
            response.sendRedirect("LecturerCoursesServlet");
            return;
        }

        sessionId = sessionId.trim();
        Map<String, String> sessionMetadata = new HashMap<>();
        List<Map<String, Object>> attendanceRosterList = new ArrayList<>();

        String sessionSql = "SELECT s.sessionId, s.courseCode, c.courseName, s.date, s.venue "
                + "FROM attendancesession s "
                + "JOIN course c ON s.courseCode = c.courseCode WHERE s.sessionId = ?";

        // SQL join to include ipAddress from attendancerecord
        String rosterSql = "SELECT sc.matricNo, u.fullName, ar.ipAddress, "
                + "  DATE_FORMAT(ar.checkinTime, '%H:%i:%s') AS checkTime, "
                + "  IF(ar.matricNo IS NOT NULL, 'PRESENT', 'ABSENT') AS attendanceStatus "
                + "FROM studentcourse sc "
                + "JOIN users u ON sc.matricNo = u.matricNo "
                + "LEFT JOIN attendancerecord ar ON sc.matricNo = ar.matricNo AND ar.sessionId = ? "
                + "WHERE sc.courseCode = ? "
                + "ORDER BY sc.matricNo ASC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                try (PreparedStatement psSession = conn.prepareStatement(sessionSql)) {
                    psSession.setString(1, sessionId);
                    try (ResultSet rsSession = psSession.executeQuery()) {
                        if (rsSession.next()) {
                            sessionMetadata.put("sessionId", rsSession.getString("sessionId"));
                            sessionMetadata.put("courseCode", rsSession.getString("courseCode"));
                            sessionMetadata.put("courseName", rsSession.getString("courseName"));
                            sessionMetadata.put("date", rsSession.getString("date"));
                            sessionMetadata.put("venue", rsSession.getString("venue"));
                        }
                    }
                }

                String courseCode = sessionMetadata.get("courseCode");
                if (courseCode != null) {
                    try (PreparedStatement psRoster = conn.prepareStatement(rosterSql)) {
                        psRoster.setString(1, sessionId);
                        psRoster.setString(2, courseCode);

                        try (ResultSet rsRoster = psRoster.executeQuery()) {
                            int totalPresent = 0;
                            while (rsRoster.next()) {
                                Map<String, Object> studentRow = new HashMap<>();
                                studentRow.put("matricNo", rsRoster.getString("matricNo"));
                                studentRow.put("fullName", rsRoster.getString("fullName"));
                                studentRow.put("checkTime", rsRoster.getString("checkTime") != null ? rsRoster.getString("checkTime") : "-");
                                studentRow.put("status", rsRoster.getString("attendanceStatus"));

                                // Mapping the IP Address
                                String ip = rsRoster.getString("ipAddress");
                                studentRow.put("ipAddress", (ip != null && !ip.isEmpty()) ? ip : "-");

                                if ("PRESENT".equals(studentRow.get("status"))) {
                                    totalPresent++;
                                }
                                attendanceRosterList.add(studentRow);
                            }
                            sessionMetadata.put("presentCount", String.valueOf(totalPresent));
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("sessionMeta", sessionMetadata);
        request.setAttribute("rosterList", attendanceRosterList);
        request.getRequestDispatcher("lecturerViewSessionAttendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
