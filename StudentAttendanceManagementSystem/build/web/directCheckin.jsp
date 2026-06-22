<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Check-In</title>
        <link rel="stylesheet" href="style.css">
        <style>
            body {
                display: block;
                background-color: #f4f6f9;
                padding: 15px;
            }
            .mobile-card-frame {
                background: #ffffff;
                padding: 25px;
                border-radius: 8px;
                box-shadow: 0 4px 10px rgba(0,0,0,0.06);
                max-width: 420px;
                margin: 40px auto;
                border-top: 5px solid #00897b;
                box-sizing: border-box; /* CRITICAL: Prevents inputs from stretching outside padding bounds */
            }
            .input-box {
                width: 100%;
                padding: 12px;
                margin: 10px 0 20px 0;
                border: 1px solid #cccccc;
                border-radius: 4px;
                font-size: 16px;
                box-sizing: border-box; /* Ensures padding stays within the width boundaries */
            }
            .submit-action-btn {
                width: 100%;
                background: #00897b;
                color: white;
                border: none;
                padding: 14px;
                font-size: 16px;
                font-weight: bold;
                border-radius: 4px;
                cursor: pointer;
                box-sizing: border-box;
            }
            .alert-box {
                background: #fadbd8;
                color: #e74c3c;
                padding: 12px;
                border-radius: 4px;
                font-weight: bold;
                margin-bottom: 20px;
                text-align: center;
                font-family: sans-serif;
                font-size: 14px;
                border: 1px solid #f5c6cb;
            }
        </style>
    </head>
    <body>

        <div class="mobile-card-frame">
            <h2 style="color: #333; margin-bottom: 5px; text-align: center;">SAMS Mobile Check-In</h2>
            <p style="color: #666; font-size: 14px; text-align: center; margin-bottom: 25px;">
                Target Session: <strong style="color: #00897b;"><c:out value="${param.sessionId}"/></strong>
            </p>

            <c:if test="${not empty sessionScope.msgError}">
                <div class="alert-box">
                    ⚠ <c:out value="${sessionScope.msgError}"/>
                </div>
                <c:remove var="msgError" scope="session" />
            </c:if>

            <form action="StudentCheckinServlet" method="POST">
                <input type="hidden" name="sessionId" value="<c:out value="${param.sessionId}"/>">

                <label style="font-weight: bold; color: #555;">MATRIC NUMBER</label>
                <input type="text" name="matricNo" class="input-box" placeholder="e.g., B032110043" required autocomplete="off" style="text-transform: uppercase;">

                <label style="font-weight: bold; color: #555;">SAMS PASSWORD</label>
                <input type="password" name="password" class="input-box" placeholder="••••••••" required>

                <button type="submit" class="submit-action-btn">CONFIRM MY ATTENDANCE</button>
            </form>
        </div>

    </body>
</html>