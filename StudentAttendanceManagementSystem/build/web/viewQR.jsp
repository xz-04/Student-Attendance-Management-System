<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Attendance QR</title>
        <link rel="stylesheet" href="style.css">
        
        <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js" type="text/javascript"></script>
        
        <style>
            .qr-card-container {
                display: flex;
                justify-content: center;
                align-items: center;
                margin-top: 30px;
            }
            .qr-display-box {
                background: #ffffff;
                border: 1px solid #e0e0e0;
                padding: 40px;
                border-radius: 8px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.04);
                text-align: center;
                width: 100%;
                max-width: 460px;
                box-sizing: border-box;
            }
            .qr-graphic-canvas-wrapper {
                background-color: #fafafa;
                border: 2px dashed #00897b;
                padding: 25px;
                border-radius: 12px;
                display: inline-block;
                margin: 20px 0;
                box-shadow: inset 0 2px 6px rgba(0,0,0,0.02);
            }
            .qr-graphic-canvas-wrapper img {
                display: block;
                margin: 0 auto;
            }

            @keyframes liveBroadcastPulse {
                0% { transform: scale(0.8); opacity: 0.5; }
                50% { transform: scale(1.2); opacity: 1; }
                100% { transform: scale(0.8); opacity: 0.5; }
            }
            .action-back-btn {
                background-color: #f5f7f8;
                color: #333333;
                border: 1px solid #cccccc;
                padding: 10px 24px;
                border-radius: 4px;
                font-weight: bold;
                font-size: 14px;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.2s;
            }
            .action-back-btn:hover {
                background-color: #eef0f1;
                border-color: #b5b5b5;
            }
        </style>
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header" style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #333333; padding-bottom: 15px; margin-bottom: 30px;">
                <h1 style="margin: 0; font-size: 24px; font-weight: bold;">Class Attendance QR Code</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div class="qr-card-container">
                <div class="qr-display-box">

                    <p style="font-size: 12px; font-weight: bold; color: #777777; letter-spacing: 0.5px; margin: 0 0 5px 0; text-transform: uppercase;">
                        TARGET LOG RUNTIME IDENTIFIER
                    </p>
                    <h2 style="margin: 0 0 20px 0; font-family: monospace; color: #333333; font-size: 22px; font-weight: bold; letter-spacing: -0.5px;">
                        <c:out value="${param.sessionId}"/>
                    </h2>

                    <div class="qr-graphic-canvas-wrapper">
                        <div id="qrcodeCanvas"></div>
                    </div>


                    <div>
                        <a href="javascript:history.back();" class="action-back-btn">
                            ← Return to Sessions List
                        </a>
                    </div>

                </div>
            </div>

        </div>

        <script type="text/javascript">
            window.addEventListener('DOMContentLoaded', function() {
                // 1. Extract the raw safe URL parameter value token straight via Expression Language Injection
                var targetSessionId = "${param.sessionId}";
                
                if(targetSessionId && targetSessionId.trim() !== "") {
                    
                    // 2. CONSTRUCT YOUR SYSTEM'S FULL FAST-CHECKIN MOBILE WEB LINK:
                    // This generates the absolute connection string URL.
                    // For example: http://10.139.42.177:8080/StudentAttendanceManagementSystem/directCheckin.jsp?sessionId=CSF3023-01
                    var currentOrigin = window.location.origin;
                    var pathName = window.location.pathname;
                    var projectContext = pathName.substring(0, pathName.indexOf('/', 1));
                    
                    var embeddedPayloadUrl = currentOrigin + projectContext + "/directCheckin.jsp?sessionId=" + encodeURIComponent(targetSessionId);
                    
                    console.log("QR Engine output payload mapping address: " + embeddedPayloadUrl);

                    // 3. Initialize and compile the vector graphic data matrix output onto the DOM Node block element
                    new QRCode(document.getElementById("qrcodeCanvas"), {
                        text: embeddedPayloadUrl,
                        width: 220,
                        height: 220,
                        colorDark : "#111111",
                        colorLight : "#ffffff",
                        correctLevel : QRCode.CorrectLevel.H // High fault tolerance recovery calculation algorithm tracking rules
                    });
                } else {
                    document.getElementById("qrcodeCanvas").innerHTML = "<p style='color:#e74c3c; font-weight:bold; padding:20px;'>Error: Session ID target token identifier is invalid or completely missing.</p>";
                }
            });
        </script>
    </body>
</html>