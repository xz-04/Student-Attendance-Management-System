<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Password</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body class="recovery-page-body">

        <div class="reset-container-card">
            <div class="reset-header">
                <h1>Account Recovery</h1>
                <p id="stepDescription">Verify identity details below to request a security pin</p>
            </div>

            <div id="errorNotificationBox" style="display: none; background-color: #fadbd8; color: #e74c3c; padding: 12px; border-radius: 4px; margin-bottom: 20px; font-size: 13px; font-weight: bold; border-left: 4px solid #e74c3c;"></div>

            <div id="step1_identityPanel">
                <div class="form-group-block">
                    <label class="form-field-label">MATRIC NO / USER IDENTIFIER</label>
                    <input type="text" id="matricNoField" class="form-text-layout-input" placeholder="e.g., s75063" onkeydown="checkKeyEntry(event);" required>
                </div>

                <div class="form-group-block">
                    <label class="form-field-label">REGISTERED EMAIL ADDRESS</label>
                    <input type="email" id="emailField" class="form-text-layout-input" placeholder="s75063@ocean.umt.edu.my" onkeydown="checkKeyEntry(event);" required>
                </div>

                <button type="button" onclick="requestSecurityOTP();" class="report-btn-generate" style="margin-top: 10px;">
                    SEND VERIFICATION CODE &rarr;
                </button>
            </div>

            <div id="step2_otpPanel" class="hidden-step-panel">
                <div style="background-color: #e8f8f5; color: #16a085; padding: 10px; border-radius: 4px; margin-bottom: 20px; font-size: 12px; font-weight: bold; text-align: center;">
                    📩 A 4-digit security code has been generated. Check server console logs!
                </div>

                <div class="form-group-block">
                    <label class="form-field-label">ENTER 4-DIGIT CODE</label>
                    <input type="text" id="otpField" maxlength="4" class="form-text-layout-input" placeholder="e.g., 1234" style="text-align: center; font-size: 20px; letter-spacing: 8px; font-weight: bold;" onkeydown="checkKeyEntry(event);">
                </div>

                <button type="button" onclick="verifySecurityOTP();" class="report-btn-generate" style="background-color: #34495e; margin-top: 10px;">
                    VERIFY CODE &rarr;
                </button>
            </div>

            <div id="step3_passwordPanel" class="hidden-step-panel">
                <div style="background-color: #e8f8f5; color: #2ecc71; padding: 10px; border-radius: 4px; margin-bottom: 20px; font-size: 12px; font-weight: bold; text-align: center;">
                    ✓ Identity Authenticated! Enter your new password details.
                </div>

                <form action="ForgetPasswordServlet" method="POST" id="recoveryFormEngine" onsubmit="return validatePasswordFormat();">                    <input type="hidden" name="actionStep" value="UPDATE_PASSWORD">
                    <input type="hidden" name="verifiedMatricNo" id="hiddenMatricField">

                    <div class="form-group-block">
                        <label class="form-field-label">NEW SECURE PASSWORD</label>
                        <input type="password" name="newPassword" id="newPwdField" class="form-text-layout-input" placeholder="Minimum 6 characters">
                    </div>

                    <div class="form-group-block">
                        <label class="form-field-label">CONFIRM NEW PASSWORD</label>
                        <input type="password" name="confirmPassword" id="confirmPwdField" class="form-text-layout-input" placeholder="Re-type password">
                    </div>

                    <button type="submit" class="report-btn-generate" style="background-color: #2c3e50; margin-top: 10px;">
                        🔒 UPDATE ACCOUNT PASSWORD
                    </button>
                </form>
            </div>

            <a href="login.jsp" class="auth-back-link">&larr; Back to Login Gateway</a>
        </div>

        <script type="text/javascript">
            function showError(msg) {
                var box = document.getElementById('errorNotificationBox');
                box.innerText = msg;
                box.style.display = 'block';
            }

            function clearError() {
                document.getElementById('errorNotificationBox').style.display = 'none';
            }

            function checkKeyEntry(event) {
                if (event.key === "Enter" || event.keyCode === 13) {
                    event.preventDefault();

                    var panel1 = document.getElementById('step1_identityPanel');
                    var panel2 = document.getElementById('step2_otpPanel');

                    if (window.getComputedStyle(panel1).display !== 'none') {
                        requestSecurityOTP();
                    } else if (window.getComputedStyle(panel2).display !== 'none') {
                        verifySecurityOTP();
                    }
                }
            }

            function requestSecurityOTP() {
                var mNo = document.getElementById('matricNoField').value.trim();
                var mail = document.getElementById('emailField').value.trim();

                if (!mNo || !mail) {
                    alert("Please fill out both Matric No and Email fields.");
                    return;
                }

                var xhr = new XMLHttpRequest();
                xhr.open("POST", "ForgetPasswordServlet", true);
                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

                xhr.onreadystatechange = function () {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        var res = xhr.responseText.trim();
                        if (res === "OTP_SENT") {
                            clearError();
                            document.getElementById('hiddenMatricField').value = mNo;

                            document.getElementById('step1_identityPanel').style.display = 'none';
                            document.getElementById('step2_otpPanel').style.display = 'block';
                            document.getElementById('stepDescription').innerText = "Enter the 4-digit verification code visible on the server log.";
                        } else {
                            showError("Identity Conflict: The credentials entered do not match our database records.");
                        }
                    }
                };
                xhr.send("actionStep=REQUEST_OTP&matricNo=" + encodeURIComponent(mNo) + "&email=" + encodeURIComponent(mail));
            }

            function verifySecurityOTP() {
                var code = document.getElementById('otpField').value.trim();
                if (code.length !== 4) {
                    alert("Please provide a complete 4-digit code.");
                    return;
                }

                var xhr = new XMLHttpRequest();
                xhr.open("POST", "ForgetPasswordServlet", true);
                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

                xhr.onreadystatechange = function () {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        var res = xhr.responseText.trim();
                        if (res === "OTP_VALID") {
                            clearError();
                            document.getElementById('step2_otpPanel').style.display = 'none';
                            document.getElementById('step3_passwordPanel').style.display = 'block';
                            document.getElementById('stepDescription').innerText = "Set your new account password credentials.";
                            document.getElementById('newPwdField').setAttribute('required', 'required');
                            document.getElementById('confirmPwdField').setAttribute('required', 'required');
                        } else if (res === "OTP_EXPIRED") {
                            showError("Code Expired: This 4-digit PIN session has expired. Please request a new one.");
                        } else {
                            showError("Invalid Pin: The token entry does not match the generated code.");
                        }
                    }
                };
                xhr.send("actionStep=VERIFY_OTP&otpCode=" + encodeURIComponent(code));
            }

            function validatePasswordFormat() {
                var newPwd = document.getElementById('newPwdField').value;
                var confPwd = document.getElementById('confirmPwdField').value;

                // Regex: At least 6 chars, containing at least one letter and one number
                var regex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/;

                if (newPwd !== confPwd) {
                    alert("Passwords do not match.");
                    return false;
                }
                if (!regex.test(newPwd)) {
                    alert("Password must be at least 6 characters long and include both letters and numbers.");
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>