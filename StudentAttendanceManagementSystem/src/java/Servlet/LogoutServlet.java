package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    // Support both GET and POST requests for logging out
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    private void processLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get the current session if it exists (pass 'false' so a new one isn't created)
        HttpSession session = request.getSession(false);

        if (session != null) {
            // 2. Clear all data currently stored inside the session
            session.removeAttribute("userId");
            session.removeAttribute("fullName");
            session.removeAttribute("role");

            // 3. Destroy the session container completely on the server
            session.invalidate();
        }

        // 4. Redirect the browser straight back to the login screen
        response.sendRedirect("login.jsp");
    }
}
