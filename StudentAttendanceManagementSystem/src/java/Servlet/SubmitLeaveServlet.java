package Servlet;

import DBConnection.DBConnection;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.*;
import java.util.stream.Collectors;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SubmitLeaveServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 5, // 5MB
        maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class SubmitLeaveServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads" + File.separator + "leave_evidence";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session Gatekeeper Validation
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String studentMatricNo = null;
        if (session.getAttribute("userId") != null) {
            studentMatricNo = (String) session.getAttribute("userId");
        } else if (session.getAttribute("matricNo") != null) {
            studentMatricNo = (String) session.getAttribute("matricNo");
        }

        if (studentMatricNo == null || studentMatricNo.trim().isEmpty()) {
            response.sendRedirect("login.jsp");
            return;
        }
        studentMatricNo = studentMatricNo.trim();

        // 2. Multipart Parameter Extraction
        String courseCode = request.getParameter("courseCode");
        String sessionDate = request.getParameter("sessionDate");

        // MODIFIED: Capture the new leave category classification parameter
        String leaveCategory = request.getParameter("leaveCategory");

        String absenceReason = request.getParameter("absenceReason");

        // Multipart parsing fallbacks if container leaves standard stream blocks empty
        if (courseCode == null && request.getPart("courseCode") != null) {
            courseCode = getValueFromPart(request.getPart("courseCode"));
        }
        if (sessionDate == null && request.getPart("sessionDate") != null) {
            sessionDate = getValueFromPart(request.getPart("sessionDate"));
        }
        if (leaveCategory == null && request.getPart("leaveCategory") != null) {
            leaveCategory = getValueFromPart(request.getPart("leaveCategory"));
        }
        if (absenceReason == null && request.getPart("absenceReason") != null) {
            absenceReason = getValueFromPart(request.getPart("absenceReason"));
        }

        // Sanitization and structural verification fallback defaults
        if (courseCode == null || courseCode.trim().isEmpty()) {
            request.setAttribute("error", "Validation Error: Course code cannot be empty.");
            request.getRequestDispatcher("LoadApplyLeaveServlet").forward(request, response);
            return;
        }
        courseCode = courseCode.trim();
        String finalSessionDate = (sessionDate != null) ? sessionDate.trim() : "";

        if (leaveCategory == null || leaveCategory.trim().isEmpty()) {
            leaveCategory = "Others"; // Safeguard descriptor fallback
        }
        leaveCategory = leaveCategory.trim();

        // 3. Database Execution Flow
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // A. DUPLICATE GATEKEEPER CHECK: Guard against same day + same course assignments
                String checkDuplicateSql = "SELECT COUNT(*) AS existing_count FROM absenceleave "
                        + "WHERE LOWER(matricNo) = LOWER(?) "
                        + "AND LOWER(courseCode) = LOWER(?) "
                        + "AND date = ?";

                try (PreparedStatement psCheck = conn.prepareStatement(checkDuplicateSql)) {
                    psCheck.setString(1, studentMatricNo);
                    psCheck.setString(2, courseCode);
                    psCheck.setString(3, finalSessionDate);

                    try (ResultSet rsCheck = psCheck.executeQuery()) {
                        if (rsCheck.next() && rsCheck.getInt("existing_count") > 0) {
                            request.setAttribute("error", "You have already submitted an absence leave application for this course ("
                                    + courseCode.toUpperCase() + ") on this specific date (" + finalSessionDate + ").");
                            request.getRequestDispatcher("LoadApplyLeaveServlet").forward(request, response);
                            return;
                        }
                    }
                }

                // B. SEQUENCE ENGINE LOOKUP: Generate incremental index suffix tags
                String countSql = "SELECT COUNT(*) AS total FROM absenceleave WHERE LOWER(matricNo) = LOWER(?) AND LOWER(courseCode) = LOWER(?)";
                int nextSequenceNum = 1;

                try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                    psCount.setString(1, studentMatricNo);
                    psCount.setString(2, courseCode);
                    try (ResultSet rsCount = psCount.executeQuery()) {
                        if (rsCount.next()) {
                            nextSequenceNum = rsCount.getInt("total") + 1;
                        }
                    }
                }

                String paddedSequence = String.format("%02d", nextSequenceNum);
                String customLeaveId = (courseCode + "-" + studentMatricNo + "-" + paddedSequence).toLowerCase();
                System.out.println("--> [SAMS GENERATED ID] Target Reference Key: " + customLeaveId);

                // C. FILE SYSTEMS SAVER MANAGEMENT
                String savedDbFilePath = "";
                Part filePart = request.getPart("supportingDoc");

                if (filePart != null && filePart.getSize() > 0) {
                    String appPath = request.getServletContext().getRealPath("");
                    File baseAppDir = new File(appPath);
                    File uploadSubDir = new File(baseAppDir, UPLOAD_DIR);

                    if (!uploadSubDir.exists()) {
                        uploadSubDir.mkdirs();
                    }

                    String originalFileName = extractFileName(filePart);
                    String uniqueFileName = studentMatricNo + "_" + System.currentTimeMillis() + "_" + originalFileName;

                    File fileToSave = new File(uploadSubDir, uniqueFileName);
                    filePart.write(fileToSave.getAbsolutePath());

                    savedDbFilePath = "uploads/leave_evidence/" + uniqueFileName;
                }

                // D. MODIFIED: Insert transaction SQL string structured to record the category token
                String insertSql = "INSERT INTO absenceleave (leaveId, matricNo, courseCode, category, date, reason, evidencePath, approvalStatus) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, 'Pending')";

                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    psInsert.setString(1, customLeaveId);
                    psInsert.setString(2, studentMatricNo);
                    psInsert.setString(3, courseCode);
                    psInsert.setString(4, leaveCategory); // ◄--- NEW BINDING
                    psInsert.setString(5, finalSessionDate);
                    psInsert.setString(6, absenceReason != null ? absenceReason.trim() : "");
                    psInsert.setString(7, savedDbFilePath);

                    psInsert.executeUpdate();
                }

                // E. SYSTEM SUCCESS REDIRECT DISPATCH ROUTE
                request.getSession().setAttribute("leaveSuccessMsg", "Your request has been logged successfully under reference ID: " + customLeaveId.toUpperCase());
                response.sendRedirect("LeaveServlet?status=all");
                return;
            }
        } catch (SQLException e) {
            System.err.println("Database Write Failure inside SubmitLeaveServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Database Error encountered while writing profile records: " + e.getMessage());
            request.getRequestDispatcher("LoadApplyLeaveServlet").forward(request, response);
            return;
        }
    }

    private String getValueFromPart(Part part) throws IOException {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"))) {
            return reader.lines().collect(Collectors.joining("\n")).trim();
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "unknown_file";
    }
}
