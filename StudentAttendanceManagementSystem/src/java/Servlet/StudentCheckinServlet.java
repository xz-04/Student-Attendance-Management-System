package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/StudentCheckinServlet")
public class StudentCheckinServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Fallback safety redirection to prevent direct manual GET access errors
        response.sendRedirect("StudentDashboardServlet");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. Extract credentials from the directCheckin mobile form payload
        String sessionId = request.getParameter("sessionId");
        String inputMatricNo = request.getParameter("matricNo");
        String inputPassword = request.getParameter("password");

        // Extracts the authentic client IP address using routing header checks
        String ipAddress = getClientRealIpAddress(request);

        if (sessionId == null || inputMatricNo == null || inputPassword == null
                || sessionId.trim().isEmpty() || inputMatricNo.trim().isEmpty() || inputPassword.trim().isEmpty()) {

            request.getSession().setAttribute("msgError", "All submission fields are strictly required.");
            response.sendRedirect("directCheckin.jsp?sessionId=" + sessionId);
            return;
        }

        sessionId = sessionId.trim();
        inputMatricNo = inputMatricNo.trim();
        String generatedRecordId = "";

        // 2. Database Pipeline Authentication and Session Validation
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // STEP A: Authenticate matric number and password credentials directly against the user table registry
                String authSql = "SELECT COUNT(*) FROM users WHERE matricNo = ? AND password = ?";
                boolean isAuthenticated = false;

                try (PreparedStatement psAuth = conn.prepareStatement(authSql)) {
                    psAuth.setString(1, inputMatricNo);
                    psAuth.setString(2, inputPassword);
                    try (ResultSet rsAuth = psAuth.executeQuery()) {
                        if (rsAuth.next() && rsAuth.getInt(1) > 0) {
                            isAuthenticated = true;
                        }
                    }
                }

                if (!isAuthenticated) {
                    request.getSession().setAttribute("msgError", "Invalid Matric Number or Password credential entry mismatch.");
                    response.sendRedirect("directCheckin.jsp?sessionId=" + sessionId);
                    return;
                }

                // ==========================================================================
                // NEW SECURITY GATEWAY MODIFICATION: VERIFY SESSION TIME WINDOW CONSTRAINTS
                // ==========================================================================
                String timeCheckSql = "SELECT date, startTime, endTime FROM attendancesession WHERE sessionId = ?";
                boolean isSessionExpired = false;

                try (PreparedStatement psTime = conn.prepareStatement(timeCheckSql)) {
                    psTime.setString(1, sessionId);
                    try (ResultSet rsTime = psTime.executeQuery()) {
                        if (rsTime.next()) {
                            String sessionDate = rsTime.getString("date");
                            String endTime = rsTime.getString("endTime");
                            String startTime = rsTime.getString("startTime");

                            // Concatenate date and time targets to check strict system timestamps
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                            java.util.Date sessionEndDateTime = sdf.parse(sessionDate + " " + endTime);
                            java.util.Date sessionStartDateTime = sdf.parse(sessionDate + " " + startTime);
                            java.util.Date rightNow = new java.util.Date();

                            if (rightNow.after(sessionEndDateTime)) {
                                isSessionExpired = true;
                            } else if (rightNow.before(sessionStartDateTime)) {
                                request.getSession().setAttribute("msgError", "Check-in Refused: This attendance session has not started yet.");
                                response.sendRedirect("directCheckin.jsp?sessionId=" + sessionId);
                                return;
                            }
                        } else {
                            request.getSession().setAttribute("msgError", "Check-in Error: Active session identity key not verified.");
                            response.sendRedirect("directCheckin.jsp?sessionId=" + sessionId);
                            return;
                        }
                    }
                }

                if (isSessionExpired) {
                    request.getSession().setAttribute("msgError", "Attendance Link Expired: The registration window for this session is closed.");
                    response.sendRedirect("directCheckin.jsp?sessionId=" + sessionId);
                    return;
                }

                // ==========================================================================
                // STEP B: PREVENT DUPLICATE CHECK-INS FOR THE SAME SESSION
                // ==========================================================================
                String checkDuplicateSql = "SELECT COUNT(*) FROM attendancerecord WHERE sessionId = ? AND matricNo = ?";
                boolean alreadyCheckedIn = false;

                try (PreparedStatement psCheck = conn.prepareStatement(checkDuplicateSql)) {
                    psCheck.setString(1, sessionId);
                    psCheck.setString(2, inputMatricNo);
                    try (ResultSet rsCheck = psCheck.executeQuery()) {
                        if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                            alreadyCheckedIn = true;
                        }
                    }
                }

                if (alreadyCheckedIn) {
                    request.getSession().setAttribute("msgError", "You have already checked into this class session.");
                    response.sendRedirect("directCheckin.jsp?sessionId=" + sessionId);
                    return;
                }

                // ==========================================================================
                // STEP C: Count entries to establish the sequence number
                // ==========================================================================
                String countSql = "SELECT COUNT(*) FROM attendancerecord WHERE sessionId = ?";
                int sequenceCounter = 1;

                try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                    psCount.setString(1, sessionId);
                    try (ResultSet rs = psCount.executeQuery()) {
                        if (rs.next()) {
                            sequenceCounter = rs.getInt(1) + 1;
                        }
                    }
                }

                // STEP D: Format the custom Alphanumeric Record ID string (e.g., CSE3023-01-01)
                generatedRecordId = sessionId + "-" + String.format("%02d", sequenceCounter);

                // STEP E: Save the transaction to the attendancerecord table log
                String insertSql = "INSERT INTO attendancerecord (recordId, sessionId, matricNo, checkinTime, ipAddress) "
                        + "VALUES (?, ?, ?, CURRENT_TIMESTAMP(), ?)";

                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    psInsert.setString(1, generatedRecordId);
                    psInsert.setString(2, sessionId);
                    psInsert.setString(3, inputMatricNo);
                    psInsert.setString(4, ipAddress); // Saves actual real-time external user IP address

                    int rowsAffected = psInsert.executeUpdate();

                    if (rowsAffected > 0) {
                        request.setAttribute("recordHash", generatedRecordId);
                        request.getRequestDispatcher("attendanceSuccess.jsp").forward(request, response);
                        return;
                    } else {
                        request.getSession().setAttribute("msgError", "Record logging was rejected by architectural database constraints.");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("msgError", "Critical Database Error Context Exception: " + e.getMessage());
        }

        response.sendRedirect("directCheckin.jsp?sessionId=" + sessionId);
    }

    /**
     * Helper utility method that scans common HTTP gateway proxy routing
     * headers to accurately bypass proxy nodes and pinpoint the student's
     * direct client hardware IP address.
     */
    private String getClientRealIpAddress(HttpServletRequest request) {
        String ipAddress = request.getHeader("X-Forwarded-For");

        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("Proxy-Client-IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getRemoteAddr();
        } else {
            if (ipAddress.contains(",")) {
                ipAddress = ipAddress.split(",")[0].trim();
            }
        }

        if ("0:0:0:0:0:0:0:1".equals(ipAddress)) {
            ipAddress = "127.0.0.1";
        }

        return ipAddress;
    }
}
