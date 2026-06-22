package Servlet;

import DBConnection.DBConnection;
import Model.User;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminUsersServlet")
public class AdminUsersServlet extends HttpServlet {

    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper Verification
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Fetch Selection Context Tab and Filter String Parameters
        String roleTab = request.getParameter("roleTab");
        if (roleTab == null || roleTab.trim().isEmpty()) {
            roleTab = "student";
        }
        roleTab = roleTab.trim().toLowerCase();

        String searchUser = request.getParameter("searchUser");
        boolean hasSearch = (searchUser != null && !searchUser.trim().isEmpty());
        List<User> userList = new ArrayList<>();

        StringBuilder sql = new StringBuilder();

        // 3. Construct Dynamic Queries aligning to updated UI column assignments
        if ("student".equals(roleTab)) {
            // Select s.programmeId to map into the table's Programme ID slot
            sql.append("SELECT u.matricNo, u.fullName, s.programmeId AS programmeIdField, u.role, v.currentSession, v.currentLevel ")
                    .append("FROM users u ")
                    .append("JOIN student s ON u.matricNo = s.matricNo ")
                    .append("JOIN v_student_current_status v ON u.matricNo = v.matricNo WHERE 1=1");

            if (hasSearch) {
                sql.append(" AND (u.matricNo LIKE ? OR u.fullName LIKE ? OR s.programmeId LIKE ? OR v.currentSession LIKE ? OR v.currentLevel LIKE ?)");
            }

        } else if ("lecturer".equals(roleTab)) {
            sql.append("SELECT u.matricNo, u.fullName, u.facultyName AS programmeIdField, u.role, NULL AS currentSession, NULL AS currentLevel ")
                    .append("FROM users u ")
                    .append("JOIN lecturer l ON u.matricNo = l.matricNo WHERE 1=1");

            if (hasSearch) {
                sql.append(" AND (u.matricNo LIKE ? OR u.fullName LIKE ? OR u.facultyName LIKE ?)");
            }

        } else if ("admin".equals(roleTab)) {
            sql.append("SELECT u.matricNo, u.fullName, 'N/A' AS programmeIdField, u.role, NULL AS currentSession, NULL AS currentLevel ")
                    .append("FROM users u ")
                    .append("WHERE u.role = 'Admin'");

            if (hasSearch) {
                sql.append(" AND (u.matricNo LIKE ? OR u.fullName LIKE ?)");
            }
        }

        // Order results alphabetically by name
        sql.append(" ORDER BY u.fullName ASC");

        // 4. Bind parameters dynamically based on selected role tab rules
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (hasSearch) {
                String wildCardSearch = "%" + searchUser.trim() + "%";

                if ("student".equals(roleTab)) {
                    ps.setString(1, wildCardSearch);
                    ps.setString(2, wildCardSearch);
                    ps.setString(3, wildCardSearch);
                    ps.setString(4, wildCardSearch);
                    ps.setString(5, wildCardSearch);
                } else if ("lecturer".equals(roleTab)) {
                    ps.setString(1, wildCardSearch);
                    ps.setString(2, wildCardSearch);
                    ps.setString(3, wildCardSearch);
                } else if ("admin".equals(roleTab)) {
                    ps.setString(1, wildCardSearch);
                    ps.setString(2, wildCardSearch);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String firstDisplayColumn = rs.getString("programmeIdField");
                    String secondDisplayColumn = "";

                    if ("student".equals(roleTab)) {
                        String sessionYear = rs.getString("currentSession");
                        String levelSem = rs.getString("currentLevel");

                        if (firstDisplayColumn == null) {
                            firstDisplayColumn = "N/A";
                        }
                        if (sessionYear == null) {
                            sessionYear = "Unknown Batch";
                        }
                        if (levelSem == null) {
                            levelSem = "Unknown Semester";
                        }

                        // MODIFIED: Generates format "Batch: 2026/2027 | 1st Year (Sem 1)" into the tracking variable
                        secondDisplayColumn = levelSem;
                    }

                    // Constructor argument mapping matching users.jsp attribute loops
                    userList.add(new User(
                            rs.getString("matricNo"),
                            rs.getString("fullName"),
                            firstDisplayColumn, // Maps to ${userItem.facultyName} on JSP
                            rs.getString("role"),
                            secondDisplayColumn, // Maps to ${userItem.programme} on JSP
                            "",
                            ""
                    ));
                }
            }
        } catch (Exception e) {
            System.err.println("--> [CRITICAL] Admin Users grid collection payload matching failed.");
            e.printStackTrace();
        }

        request.setAttribute("adminUsersList", userList);
        request.setAttribute("activeTab", roleTab);

        request.getRequestDispatcher("users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
