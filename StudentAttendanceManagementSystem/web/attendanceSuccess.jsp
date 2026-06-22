<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Check-In Success</title>
        <link rel="stylesheet" href="style.css">

        <style>
            /* Smooth checkmark animation keyframe tracks */
            @keyframes scaleIn {
                0% {
                    transform: scale(0);
                    opacity: 0;
                }
                100% {
                    transform: scale(1);
                    opacity: 1;
                }
            }
            @keyframes drawCheck {
                0% {
                    stroke-dashoffset: 48;
                }
                100% {
                    stroke-dashoffset: 0;
                }
            }

            .success-checkmark-circle {
                width: 80px;
                height: 80px;
                background-color: #e8f8f5;
                border-radius: 50%;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 20px;
                animation: scaleIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
            }

            .checkmark-svg {
                width: 40px;
                height: 40px;
                stroke: #00897b;
                stroke-width: 4;
                stroke-linecap: round;
                stroke-linejoin: round;
                fill: none;
                stroke-dasharray: 48;
                stroke-dashoffset: 48;
                animation: drawCheck 0.5s 0.25s ease-out forwards;
            }
        </style>
    </head>
    <body>
        <%@ include file="studentSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header" style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #333333; padding-bottom: 15px; margin-bottom: 30px;">
                <h1 style="margin: 0; font-size: 24px; font-weight: bold;">Check-In Status</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div style="display: flex; justify-content: center; align-items: center; margin-top: 40px;">
                <div style="background: #ffffff; border: 1px solid #e0e0e0; padding: 45px 40px; border-radius: 8px; box-shadow: 0 4px 20px rgba(0,0,0,0.04); text-align: center; width: 100%; max-width: 480px; box-sizing: border-box;">

                    <div class="success-checkmark-circle">
                        <svg class="checkmark-svg" viewBox="0 0 24 24">
                        <path d="M20 6L9 17l-5-5"></path>
                        </svg>
                    </div>

                    <h2 style="color: #00897b; font-size: 22px; font-weight: bold; margin: 0 0 10px 0; font-family: sans-serif;">
                        Attendance Logged Successfully!
                    </h2>

                    <p style="color: #666666; font-size: 14px; margin: 0 0 30px 0; line-height: 1.5;">
                        Your digital identity presence signature metric validation process has passed system auditing loops safely.
                    </p>

                    <div style="background-color: #f8f9fa; border: 1px solid #eef0f2; border-radius: 6px; padding: 18px 20px; margin-bottom: 35px; text-align: left;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 13px;">
                            <span style="color: #888888; font-weight: bold; text-transform: uppercase;">Log Status</span>
                            <span style="color: #27ae60; font-weight: bold;">✓ VERIFIED</span>
                        </div>
                    </div>

                    <div>
                        <a href="StudentDashboardServlet" class="admin-search-execute-btn" style="background-color: #00897b; color: #ffffff; text-decoration: none; padding: 12px 35px; border-radius: 4px; font-weight: bold; font-size: 14px; display: inline-flex; align-items: center; justify-content: center; box-shadow: 0 2px 6px rgba(0,137,123,0.25); transition: background 0.2s ease;"
                           onmouseover="this.style.backgroundColor = '#00695c';"
                           onmouseout="this.style.backgroundColor = '#00897b';">
                            Return to Dashboard
                        </a>
                    </div>

                </div>
            </div>

        </div>
    </body>
</html>