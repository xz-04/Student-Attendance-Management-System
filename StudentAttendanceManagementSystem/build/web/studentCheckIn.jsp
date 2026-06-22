<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Attendance Check-In</title>
        <link rel="stylesheet" href="style.css">

        <script src="https://cdnjs.cloudflare.com/ajax/libs/html5-qrcode/2.3.8/html5-qrcode.min.js" type="text/javascript"></script>

        <style>
            /* THE RELATIVE OUTER BOUNDING BOX */
            .scanner-view-wrapper {
                position: relative !important;
                display: block !important;
                width: 320px !important;
                height: 320px !important;
                min-width: 320px !important;
                min-height: 320px !important;
                background-color: #111111 !important;
                border: 4px solid #333333 !important;
                border-radius: 12px !important;
                overflow: hidden !important;
                box-shadow: 0 6px 25px rgba(0,0,0,0.2) !important;
                visibility: visible !important;
                opacity: 1 !important;
            }

            /* FORCE OVERRIDE ANY INJECTED VIDEO FROM HTML5-QRCODE */
            #webcamPreview video {
                width: 100% !important;
                height: 100% !important;
                object-fit: cover !important; /* Force crop into 1:1 view window */
                transform: scaleX(-1) !important; /* Standard mirrored selfie feedback layout */
            }

            /* THE SCANNER CORNER AIM BRACKETS */
            .aim-bracket {
                position: absolute !important;
                width: 26px !important;
                height: 26px !important;
                border: 4px solid #00897b !important;
            }
            .top-left     {
                top: 20px !important;
                left: 20px !important;
                border-right: none !important;
                border-bottom: none !important;
            }
            .top-right    {
                top: 20px !important;
                right: 20px !important;
                left: auto !important;
                border-left: none !important;
                border-bottom: none !important;
            }
            .bottom-left  {
                bottom: 20px !important;
                left: 20px !important;
                border-right: none !important;
                border-top: none !important;
            }
            .bottom-right {
                bottom: 20px !important;
                right: 20px !important;
                left: auto !important;
                border-left: none !important;
                border-top: none !important;
            }

            @keyframes laserMove {
                0%   {
                    top: 15% !important;
                }
                50%  {
                    top: 85% !important;
                }
                100% {
                    top: 15% !important;
                }
            }
        </style>
    </head>
    <body>
        <%@ include file="studentSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header" style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #333333; padding-bottom: 15px; margin-bottom: 30px;">
                <h1 style="margin: 0; font-size: 24px; font-weight: bold;">Check-In Attendance</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div style="display: flex; justify-content: center; align-items: center; margin-top: 15px;">
                <div style="background: #ffffff; border: 1px solid #e0e0e0; padding: 40px; border-radius: 8px; box-shadow: 0 4px 20px rgba(0,0,0,0.04); text-align: center; width: 100%; max-width: 500px; box-sizing: border-box;">

                    <p style="font-size: 12px; font-weight: bold; color: #666666; letter-spacing: 0.5px; margin-bottom: 25px; text-transform: uppercase;">
                        Point your camera at the QR code displayed by your lecturer
                    </p>

                    <div style="margin: 25px 0; display: flex !important; justify-content: center !important; align-items: center !important; width: 100% !important; visibility: visible !important; opacity: 1 !important;">
                        <div class="scanner-view-wrapper">

                            <div id="webcamPreview" style="width: 100% !important; height: 100% !important; display: block !important; border: none !important; background: transparent !important;"></div>

                            <div class="scanner-overlay-hud" style="position: absolute !important; top: 0 !important; left: 0 !important; width: 100% !important; height: 100% !important; z-index: 999 !important; pointer-events: none !important; box-sizing: border-box !important;">
                                <div class="aim-bracket top-left"></div>
                                <div class="aim-bracket top-right"></div>
                                <div class="aim-bracket bottom-left"></div>
                                <div class="aim-bracket bottom-right"></div>
                            </div>

                        </div>
                    </div>

                    <div>
                        <button type="button" id="toggleCamBtn" class="admin-search-execute-btn" style="background-color: #e74c3c; padding: 12px 40px; border-radius: 4px; font-weight: bold; color: white; border: none; font-size: 14px; height: auto; cursor: pointer; display: inline-flex; justify-content: center; box-shadow: 0 2px 6px rgba(231,76,60,0.25);">
                            STOP CAMERA
                        </button>
                    </div>

                </div>
            </div>

        </div>

        <script>
            let html5QrcodeScanner = null;
            const toggleButton = document.getElementById('toggleCamBtn');
            let isScanning = true;

            function onScanSuccess(decodedText, decodedResult) {
                console.log("QR Code Decoded successfully: " + decodedText);

                if (html5QrcodeScanner) {
                    html5QrcodeScanner.stop().then(() => {
                        let finalSessionId = decodedText;

                        // NETWORK PATH EXTRACTION SAFETY LAYER:
                        // If the QR contains an full HTTP link (potentially using an old/wrong IP address)
                        if (decodedText.startsWith("http://") || decodedText.startsWith("https://")) {
                            try {
                                const urlObj = new URL(decodedText);
                                const paramSessionId = urlObj.searchParams.get("sessionId");
                                if (paramSessionId) {
                                    finalSessionId = paramSessionId;
                                }
                            } catch (e) {
                                console.error("URL Parsing error, attempting fallback text processing:", e);
                                if (decodedText.includes("sessionId=")) {
                                    finalSessionId = decodedText.split("sessionId=")[1];
                                }
                            }
                        }

                        // SECURE DOMAIN INJECTION:
                        // Construct the redirect URL using the exact host IP address the student is currently browsed into!
                        const currentOrigin = window.location.origin; // Dynamically gets http://10.139.42.177:8080
                        const pathName = window.location.pathname;    // Gets /StudentAttendanceManagementSystem/studentCheckin.jsp
                        const projectContext = pathName.substring(0, pathName.indexOf('/', 1)); // Extracts /StudentAttendanceManagementSystem

                        const dynamicRedirectUrl = currentOrigin + projectContext + "/directCheckin.jsp?sessionId=" + encodeURIComponent(finalSessionId);

                        console.log("Redirecting to safe network target location: " + dynamicRedirectUrl);
                        window.location.href = dynamicRedirectUrl;
                    });
                }
            }

            function onScanFailure(error) {
                // Passive searching mode silence
            }

            function startScanner() {
                html5QrcodeScanner = new Html5Qrcode("webcamPreview");

                const config = {
                    fps: 15,
                    aspectRatio: 1.0
                };

                html5QrcodeScanner.start(
                        {facingMode: "user"},
                        config,
                        onScanSuccess,
                        onScanFailure
                        ).catch(err => {
                    console.error("Scanner tracking error exception root trace: ", err);
                });
            }

            toggleButton.addEventListener('click', () => {
                if (isScanning) {
                    if (html5QrcodeScanner) {
                        html5QrcodeScanner.stop().then(() => {
                            toggleButton.textContent = "START CAMERA";
                            toggleButton.style.backgroundColor = "#00897b";
                            toggleButton.style.boxShadow = "0 2px 6px rgba(0,137,123,0.25)";
                            isScanning = false;
                        });
                    }
                } else {
                    startScanner();
                    toggleButton.textContent = "STOP CAMERA";
                    toggleButton.style.backgroundColor = "#e74c3c";
                    toggleButton.style.boxShadow = "0 2px 6px rgba(231,76,60,0.25)";
                    isScanning = true;
                }
            });

            window.addEventListener('DOMContentLoaded', startScanner);
        </script>
    </body>
</html>