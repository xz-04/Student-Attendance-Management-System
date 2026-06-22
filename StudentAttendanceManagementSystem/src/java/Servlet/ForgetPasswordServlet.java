package Servlet;

import DBConnection.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;
import java.util.Random;
import javax.mail.*;
import javax.mail.internet.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ForgetPasswordServlet")
public class ForgetPasswordServlet extends HttpServlet {

    // TOGGLE GATEWAY: Set to true when you want to use real internet SMTP. Set to false for safe server log testing.
    private static final boolean ENABLE_LIVE_SMTP = false;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String actionStep = request.getParameter("actionStep");
        HttpSession session = request.getSession();

        // -----------------------------------------------------------------
        // STAGE 1: VALIDATE USER ID & DISPATCH 4-DIGIT PIN
        // -----------------------------------------------------------------
        if ("REQUEST_OTP".equalsIgnoreCase(actionStep)) {
            String matricNo = request.getParameter("matricNo");
            String email = request.getParameter("email");

            if (matricNo != null) {
                matricNo = matricNo.trim();
            }
            if (email != null) {
                email = email.trim();
            }

            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();

            try {
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                } catch (Throwable dbEx) {
                    response.setStatus(500);
                    out.print("CRASH_INFO: Database Connection failed to initialize. Details: " + dbEx.getMessage());
                    dbEx.printStackTrace();
                    return;
                }

                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE matricNo = ? AND email = ?")) {
                    ps.setString(1, matricNo);
                    ps.setString(2, email);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {

                            int pinCode = 1000 + new Random().nextInt(9000);
                            String strOtp = String.valueOf(pinCode);

                            session.setAttribute("recoveryOtp", strOtp);
                            session.setAttribute("recoveryOtpExpiry", System.currentTimeMillis() + (5 * 60 * 1000));

                            boolean emailDispatched = false;
                            try {
                                emailDispatched = processOTPDelivery(email, strOtp);
                            } catch (Throwable mailLibraryEx) {
                                response.setStatus(500);
                                out.print("CRASH_INFO: Outbound mail dispatch failure context. Details: " + mailLibraryEx.getMessage());
                                mailLibraryEx.printStackTrace();
                                return;
                            }

                            response.setContentType("text/plain");
                            if (emailDispatched) {
                                out.print("OTP_SENT");
                            } else {
                                out.print("EMAIL_FAILED");
                            }
                        } else {
                            response.setContentType("text/plain");
                            out.print("IDENTITY_INVALID");
                        }
                    }
                } finally {
                    if (conn != null && !conn.isClosed()) {
                        conn.close();
                    }
                }

            } catch (Throwable e) {
                response.setStatus(500);
                StringWriter sw = new StringWriter();
                PrintWriter pw = new PrintWriter(sw);
                e.printStackTrace(pw);
                out.print("CRASH_INFO: Servlet crashed completely. StackTrace:<br><pre>" + sw.toString() + "</pre>");
            }
            return;
        }

        // -----------------------------------------------------------------
        // STAGE 2: VALIDATE THE 4-DIGIT CODE
        // -----------------------------------------------------------------
        if ("VERIFY_OTP".equalsIgnoreCase(actionStep)) {
            String inputOtp = request.getParameter("otpCode");
            response.setContentType("text/plain");
            PrintWriter out = response.getWriter();

            String savedOtp = (String) session.getAttribute("recoveryOtp");
            Long expiryTime = (Long) session.getAttribute("recoveryOtpExpiry");

            if (savedOtp == null || expiryTime == null) {
                out.print("OTP_INVALID");
                return;
            }

            if (System.currentTimeMillis() > expiryTime) {
                out.print("OTP_EXPIRED");
                session.removeAttribute("recoveryOtp");
                session.removeAttribute("recoveryOtpExpiry");
                return;
            }

            if (savedOtp.equals(inputOtp != null ? inputOtp.trim() : "")) {
                session.setAttribute("otpVerifiedPassed", "TRUE");
                out.print("OTP_VALID");
            } else {
                out.print("OTP_INVALID");
            }
            return;
        }

        // -----------------------------------------------------------------
        // STAGE 3: COMMIT SECURE NEW ACCESS KEYS TO THE DATA LAYER
        // -----------------------------------------------------------------
        if ("UPDATE_PASSWORD".equalsIgnoreCase(actionStep)) {
            String matricNo = request.getParameter("verifiedMatricNo");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
            String statusPassed = (String) session.getAttribute("otpVerifiedPassed");

            // Server-side regex validation
            String passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$";
            boolean isFormatValid = (newPassword != null && newPassword.matches(passwordRegex));

            if (!"TRUE".equals(statusPassed) || matricNo == null
                    || newPassword == null || !newPassword.equals(confirmPassword) || !isFormatValid) {

                session.setAttribute("msgError", "Security violation: Password must be 6+ characters with letters and numbers.");
                response.sendRedirect("forgetPassword.jsp");
                return;
            }

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement("UPDATE users SET password = ? WHERE matricNo = ?")) {

                ps.setString(1, newPassword.trim());
                ps.setString(2, matricNo);
                ps.executeUpdate();

                session.removeAttribute("recoveryOtp");
                session.removeAttribute("recoveryOtpExpiry");
                session.removeAttribute("otpVerifiedPassed");

                session.setAttribute("msgSuccess", "Account recovery successful! Please sign in using your new password.");
                response.sendRedirect("login.jsp");
                return;
            } catch (Exception e) {
                session.setAttribute("msgError", "Database Error: Could not overwrite password parameters.");
                e.printStackTrace();
            }
            response.sendRedirect("forgetPassword.jsp");
        }
    }

    /**
     * Managed Delivery Selector Engine. Routes verification streams seamlessly
     * based on project environment constraints.
     */
    private boolean processOTPDelivery(String targetEmail, String pinCode) throws Exception {

        // Print clean layout directly onto the Local NetBeans Terminal Console Log instantly
        System.out.println("\n======================================================");
        System.out.println("--> [SAMS MAIL SYSTEM LOG INTERCEPTOR]");
        System.out.println("--> TO INBOX: " + targetEmail);
        System.out.println("--> GENERATED PIN CODE: " + pinCode);
        System.out.println("--> STATUS: Intercepted and written to local server records.");
        System.out.println("======================================================\n");

        if (!ENABLE_LIVE_SMTP) {
            // Safe Mode: Return true immediately without attempting network initialization
            return true;
        }

        // --- PRODUCTION SMTP BACKEND UTILITY ENGINE ---
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        final String senderEmail = "your-actual-email@gmail.com";
        final String appPassword = "xxxx xxxx xxxx xxxx";

        Session mailSession = Session.getInstance(props, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, appPassword);
            }
        });

        Message message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(senderEmail, "SAMS Security Gate"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(targetEmail));
        message.setSubject("SAMS Account Access Security Reset Code");

        String htmlLayout = "<div style=\"font-family: Arial, sans-serif; padding: 25px; max-width: 500px; border-top: 5px solid #00897b; background-color: #fafafa; border-radius: 4px; border: 1px solid #ddd;\">"
                + "<h2 style=\"color: #2c3e50; margin-top: 0;\">Account Recovery PIN</h2>"
                + "<p style=\"color: #555; font-size: 14px;\">Use the 4-digit verification code below to authorize your password modification request:</p>"
                + "<div style=\"font-size: 28px; font-weight: bold; color: #00897b; letter-spacing: 5px; background-color: #eaeaea; padding: 12px; margin: 20px 0; width: 130px; text-align: center; border-radius: 4px; border: 1px solid #ccc;\">"
                + pinCode + "</div>"
                + "</div>";

        message.setContent(htmlLayout, "text/html; charset=utf-8");
        Transport.send(message);
        return true;
    }
}
