package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminSessionsServlet")
public class AdminSessionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Authenticate Session Gatekeeper Context
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Capture Filter Arguments
        String search = request.getParameter("searchQuery");
        String customDate = request.getParameter("customDate");
        List<Map<String, Object>> sessionsList = new ArrayList<>();

        // 3. Formulate Streamlined Data Query (Removed heavy GROUP_CONCAT subqueries)
        StringBuilder sql = new StringBuilder(
                "SELECT s.sessionId, s.courseCode, u.fullName AS lecturerName, s.date, s.startTime, s.endTime, s.venue "
                + "FROM attendancesession s "
                + "JOIN users u ON s.matricNo = u.matricNo "
                + "WHERE 1=1 "
        );

        // 4. Inject Dynamic Date Isolation Constraint Rules
        if (customDate != null && !customDate.trim().isEmpty()) {
            sql.append(" AND s.date = ? ");
        } else {
            sql.append(" AND s.date = CURDATE() ");
        }

        // 5. Inject Wildcard Text Filter Constraints
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (s.sessionId LIKE ? OR s.courseCode LIKE ? OR s.venue LIKE ? OR u.fullName LIKE ?)");
        }

        // Always sort chronologically by session start time
        sql.append(" ORDER BY s.startTime ASC");

        // 6. Execute Dynamic Prepared Statement Parameter Binding Pipelines
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            // Bind targeted Date parameter value context if explicitly chosen
            if (customDate != null && !customDate.trim().isEmpty()) {
                ps.setString(paramIndex++, customDate.trim());
            }

            // Bind wildcard parameter criteria trackers
            if (search != null && !search.trim().isEmpty()) {
                String wildCardPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, wildCardPattern);
                ps.setString(paramIndex++, wildCardPattern);
                ps.setString(paramIndex++, wildCardPattern);
                ps.setString(paramIndex++, wildCardPattern);
            }

            // 7. Parse Data Results into UI Presentation Model Objects
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("sessionId", rs.getString("sessionId"));
                    item.put("courseCode", rs.getString("courseCode"));
                    item.put("lecturerName", rs.getString("lecturerName"));
                    item.put("dateString", rs.getString("date"));
                    item.put("venue", rs.getString("venue"));

                    // Extract separate database time field metrics
                    String start = rs.getString("startTime");
                    String end = rs.getString("endTime");

                    // Clean up trailing timestamp seconds formats if applicable (e.g., "14:00:00" -> "14:00")
                    if (start != null && start.length() > 5) {
                        start = start.substring(0, 5);
                    }
                    if (end != null && end.length() > 5) {
                        end = end.substring(0, 5);
                    }

                    item.put("startTime", start != null ? start : "");
                    item.put("endTime", end != null ? end : "");

                    sessionsList.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 8. Bind response payloads and safely forward back onto your view interface
        request.setAttribute("adminSessionsList", sessionsList);
        request.getRequestDispatcher("session.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
