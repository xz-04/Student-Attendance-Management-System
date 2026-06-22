package Servlet;

import DAO.userDAO; // Ensure this matches your exact package structure
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Fetch and sanitize input parameters to prevent NullPointerException
        String rawId = request.getParameter("userid");
        String rawPassword = request.getParameter("user_password");
        String rawRole = request.getParameter("role");

        // If inputs are null, treat as empty strings
        String id = (rawId != null) ? rawId.trim() : "";
        String password = (rawPassword != null) ? rawPassword.trim() : "";
        String role = (rawRole != null) ? rawRole.trim() : "";

        // 2. Simple field validation
        if (id.isEmpty() || password.isEmpty() || role.isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // 3. Authenticate
        userDAO dao = new userDAO();
        String fullName = dao.validateUser(id, password, role);

        if (fullName != null) {
            // 4. Create Session
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", id);

            // --- FIXED COMPATIBILITY BINDINGS ---
            // Binding both key variations handles both profile.jsp and your older pages seamlessly!
            session.setAttribute("role", role);
            session.setAttribute("userRole", role);

            session.setAttribute("fullName", fullName);
            session.setAttribute("userName", fullName);

            // 5. Role-based Redirection
            switch (role.toLowerCase()) {
                case "student":
                    response.sendRedirect("StudentDashboardServlet");
                    break;
                case "lecturer":
                    response.sendRedirect("LecturerDashboardServlet");
                    break;
                case "admin":
                    response.sendRedirect("AdminDashboardServlet");
                    break;
                default:
                    // Fallback for unknown roles
                    response.sendRedirect("login.jsp");
                    break;
            }
        } else {
            // 6. Handle Invalid Login
            request.setAttribute("error", "Invalid ID, password, or role selected.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
