package Servlet;

import Model.StudentAttendance;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoadAttendance")
public class LoadAttendanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Extract selected Session ID from query parameter
        String sessionId = request.getParameter("sessionId");
        if (sessionId == null || sessionId.isEmpty()) {
            sessionId = "SES-090"; // Fallback to preserve view integrity
        }

        // 3. Set Banner Data Variables based on Session
        request.setAttribute("sessionId", sessionId);
        request.setAttribute("sessionDate", "11 Jun 2026, 08:00 AM");
        request.setAttribute("sessionVenue", "DK3");
        request.setAttribute("courseCode", "CSF3023");
        request.setAttribute("courseName", "Web Technology");
        request.setAttribute("presentCount", 50);
        request.setAttribute("absentCount", 10);
        request.setAttribute("totalStudentsCount", 5);

        // 4. Generate the dynamic live tracking list data
        List<StudentAttendance> rosterList = new ArrayList<>();

        /* DATABASE INTEGRATION MOCK DATA:
           Replace this loop block with your actual DAO data pull statement later:
           rosterList = attendanceDAO.getLiveSessionRoster(sessionId);
         */
        rosterList.add(new StudentAttendance("A20EC1001", "Ahmad Faris", "08:03:21", "192.168.1.10", "PRESENT"));
        rosterList.add(new StudentAttendance("A20EC1002", "Siti Aisyah", "08:05:47", "192.168.1.11", "PRESENT"));
        rosterList.add(new StudentAttendance("A20EC1003", "Rajan Kumar", "", "", "ABSENT"));
        rosterList.add(new StudentAttendance("A20EC1004", "Lee Mei Ling", "08:09:12", "192.168.1.13", "PRESENT"));
        rosterList.add(new StudentAttendance("A20EC1005", "Nurul Ain", "", "", "LEAVE"));

        // 5. Bind the collection parameter directly to the request scope
        request.setAttribute("liveAttendanceList", rosterList);

        // 6. Forward cleanly to your live tracking presentation page
        request.getRequestDispatcher("liveAttendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
