package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/GenerateSessionServlet")
public class GenerateSessionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("LecturerCoursesServlet");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String matricNo = (String) session.getAttribute("userId");

        String courseCode = request.getParameter("courseCode");
        String dateStr = request.getParameter("date");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        String venue = request.getParameter("venue");

        if (courseCode == null || dateStr == null || startTimeStr == null || endTimeStr == null || venue == null
                || courseCode.trim().isEmpty() || venue.trim().isEmpty()) {

            request.getSession().setAttribute("msgError", "Validation Failed: Missing Form Parameters.");
            response.sendRedirect("startSession.jsp?courseCode=" + (courseCode != null ? courseCode.trim() : ""));
            return;
        }

        courseCode = courseCode.trim();
        String generatedSessionId = "";
        String qrToken = UUID.randomUUID().toString();

        // Standardize time formatting inputs to 8-character strings (HH:mm:ss) before handling database operations
        if (startTimeStr.length() == 5) {
            startTimeStr += ":00";
        }
        if (endTimeStr.length() == 5) {
            endTimeStr += ":00";
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // ==========================================================================
                // OVERLAP DETECTION ENGINE PIPELINE
                // ==========================================================================
                String overlapCheckSql = "SELECT sessionId, courseCode, DATE_FORMAT(startTime, '%H:%i') AS startShort, "
                        + "DATE_FORMAT(endTime, '%H:%i') AS endShort FROM attendancesession "
                        + "WHERE matricNo = ? AND date = ? "
                        + "AND (? < endTime AND ? > startTime) LIMIT 1";

                try (PreparedStatement psOverlap = conn.prepareStatement(overlapCheckSql)) {
                    psOverlap.setString(1, matricNo.trim());
                    psOverlap.setString(2, dateStr.trim());
                    psOverlap.setString(3, startTimeStr);
                    psOverlap.setString(4, endTimeStr);

                    try (ResultSet rsOverlap = psOverlap.executeQuery()) {
                        if (rsOverlap.next()) {
                            String activeConflictId = rsOverlap.getString("sessionId");
                            String activeConflictCourse = rsOverlap.getString("courseCode");
                            String activeConflictStart = rsOverlap.getString("startShort");
                            String activeConflictEnd = rsOverlap.getString("endShort");

                            // FIXED: Removed all <strong> and </strong> tags for clean, raw text rendering
                            String formattedErrorMessage = "Schedule Conflict: The requested slot ("
                                    + startTimeStr.substring(0, 5) + " - " + endTimeStr.substring(0, 5)
                                    + ") falls within an existing session [" + activeConflictId.toUpperCase()
                                    + "] scheduled for " + activeConflictCourse.toUpperCase()
                                    + " from " + activeConflictStart + " to " + activeConflictEnd + " today.";

                            request.getSession().setAttribute("msgError", formattedErrorMessage);
                            response.sendRedirect("startSession.jsp?courseCode=" + courseCode);
                            return;
                        }
                    }
                }

                // STEP A: Calculate sequence number
                String sequenceSql = "SELECT COUNT(*) FROM attendancesession WHERE courseCode = ?";
                int sequenceCounter = 1;

                try (PreparedStatement psCount = conn.prepareStatement(sequenceSql)) {
                    psCount.setString(1, courseCode);
                    try (ResultSet rs = psCount.executeQuery()) {
                        if (rs.next()) {
                            sequenceCounter = rs.getInt(1) + 1;
                        }
                    }
                }

                // STEP B: Generate customized code
                generatedSessionId = courseCode + "-" + String.format("%02d", sequenceCounter);

                // STEP C: Clean 8-Column Option B Insert Query Mapping
                String insertSql = "INSERT INTO attendancesession (sessionId, courseCode, matricNo, date, startTime, endTime, venue, qrToken) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    psInsert.setString(1, generatedSessionId);
                    psInsert.setString(2, courseCode);
                    psInsert.setString(3, matricNo.trim());
                    psInsert.setDate(4, java.sql.Date.valueOf(dateStr));
                    psInsert.setTime(5, java.sql.Time.valueOf(startTimeStr));
                    psInsert.setTime(6, java.sql.Time.valueOf(endTimeStr));
                    psInsert.setString(7, venue.trim());
                    psInsert.setString(8, qrToken);

                    int rowsAffected = psInsert.executeUpdate();

                    if (rowsAffected > 0) {
                        request.getSession().setAttribute("msgSuccess", "Session " + generatedSessionId + " generated successfully!");
                        response.sendRedirect("LoadCourseSessionsServlet?courseCode=" + courseCode);
                        return;
                    } else {
                        request.getSession().setAttribute("msgError", "Database error: The session insertion was rejected.");
                        response.sendRedirect("startSession.jsp?courseCode=" + courseCode);
                        return;
                    }
                }
            }
        } catch (Exception e) {
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("<h2>SAMS Database Error Diagnostics</h2>");
            out.println("<p><strong>Error Message:</strong> " + e.getMessage() + "</p>");
            out.println("<p><strong>Active Session User ID (matricNo):</strong> " + matricNo + "</p>");
            out.println("<p><strong>Course Code used:</strong> " + courseCode + "</p>");
            out.println("<hr><pre>");
            e.printStackTrace(out);
            out.println("</pre>");
            return;
        }
    }
}
