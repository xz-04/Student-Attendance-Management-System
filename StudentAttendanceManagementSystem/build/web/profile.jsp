<%@page import="DBConnection.DBConnection"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Security Gatekeeper Check - Prevent browser caching sensitive data layers
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SAMS - My Account Profile</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>

        <%
            // Fetch the role we saved in LoginServlet context tracking parameters
            String userRole = (String) session.getAttribute("userRole");
            if (userRole != null) {
                userRole = userRole.trim().toLowerCase();
            } else {
                userRole = "student"; // Fallback default
            }
        %>

        <% if ("admin".equals(userRole)) {%>
        <%@ include file="adminSidebar.jsp" %>
        <% } else if ("lecturer".equals(userRole)) {%>
        <%@ include file="lecturerSidebar.jsp" %>
        <% } else {%>
        <%@ include file="studentSidebar.jsp" %>
        <% } %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Profile Settings</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <c:if test="${not empty sessionScope.msgSuccess}">
                <div style="background-color: #e8f8f5; color: #2ecc71; padding: 15px; border-radius: 4px; margin-bottom: 25px; font-weight: bold; border-left: 5px solid #2ecc71;">
                    ${sessionScope.msgSuccess}
                </div>
                <% session.removeAttribute("msgSuccess"); %>
            </c:if>

            <c:if test="${not empty sessionScope.msgError}">
                <div style="background-color: #fadbd8; color: #e74c3c; padding: 15px; border-radius: 4px; margin-bottom: 25px; font-weight: bold; border-left: 5px solid #e74c3c;">
                    ${sessionScope.msgError}
                </div>
                <% session.removeAttribute("msgError");%>
            </c:if>

            <form action="SaveProfileServlet" method="POST" enctype="multipart/form-data" class="profile-layout-container-form">

                <div class="profile-upper-flex-body" style="display: flex; gap: 40px; align-items: flex-start; margin-bottom: 30px;">

                    <div class="profile-avatar-uploader-card" style="display: flex; flex-direction: column; gap: 15px; width: 140px; align-items: center;">
                        <div class="avatar-preview-box" style="width: 130px; height: 130px; border: 2px solid #00897b; background-color: #e8e6e0; display: flex; align-items: center; justify-content: center; border-radius: 4px; overflow: hidden;">
                            <c:choose>
                                <c:when test="${not empty userProfile.avatarPath}">
                                    <img src="${userProfile.avatarPath}" alt="Profile Avatar" style="width: 100%; height: 100%; object-fit: cover;">
                                </c:when>
                                <c:otherwise>
                                    <svg width="70" height="70" viewBox="0 0 24 24" fill="#00897b">
                                    <path d="M12 2c2.21 0 4 1.79 4 4s-1.79 4-4 4-4-1.79-4-4 1.79-4 4-4zm0 10c4.42 0 8 1.79 8 4v2H4v-2c0-2.21 3.58-4 8-4z"/>
                                    </svg>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <label class="report-btn-generate" style="padding: 6px 12px; font-size: 11px; width: 100%; box-sizing: border-box; text-align: center; cursor: pointer; background-color: #00897b; color: white; border-radius: 4px; font-weight: bold;">
                            CHANGE PHOTO
                            <input type="file" name="profilePhoto" accept="image/*" style="display: none;">
                        </label>
                    </div>

                    <div class="profile-input-fields-matrix-grid" style="flex: 1; display: grid; grid-template-columns: 1fr 1fr; gap: 20px 25px;">

                        <div class="form-group-block">
                            <label class="form-field-label">MATRIC NO</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; border: 1px solid #999999; color: #666666; width: 100%; padding: 10px;" value="${userProfile.identifier}" readonly>
                        </div>  

                        <div class="form-group-block">
                            <label class="form-field-label">FULL NAME</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; border: 1px solid #999999; color: #666666; width: 100%; padding: 10px;" value="${userProfile.name}" readonly>
                        </div>

                        <%-- MODIFIED: Displays Programme ID for students and Faculty for Lecturers/Admins --%>
                        <div class="form-group-block">
                            <label class="form-field-label"><%= "student".equals(userRole) ? "PROGRAMME ID" : "FACULTY"%></label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; border: 1px solid #999999; color: #666666; width: 100%; padding: 10px; font-weight: <%= "student".equals(userRole) ? "bold" : "normal"%>;" value="${userProfile.faculty}" readonly>
                        </div>

                        <div class="form-group-block">
                            <label class="form-field-label">EMAIL</label>
                            <input type="email" class="form-text-layout-input" style="background-color: #e8e6e0; border: 1px solid #999999; color: #666666; width: 100%; padding: 10px;" value="${userProfile.email}" readonly>
                        </div>

                        <% if ("student".equals(userRole)) { %>
                        <div class="form-group-block">
                            <label class="form-field-label">PROGRAMME FULL NAME</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; border: 1px solid #999999; color: #666666; width: 100%; padding: 10px;" value="${userProfile.programme}" readonly>
                        </div>

                        <div class="form-group-block">
                            <label class="form-field-label">ACADEMIC BATCH</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; border: 1px solid #999999; color: #666666; width: 100%; padding: 10px;" value="${userProfile.batchSession}" readonly>
                        </div>

                        <div class="form-group-block" style="grid-column: span 2;">
                            <label class="form-field-label">CURRENT PROGRESSION LEVEL (YEAR & SEMESTER)</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8f4f2; border: 1px solid #00897b; width: 100%; padding: 10px; font-weight: bold; color: #00897b;" value="${userProfile.academicYearSem}" readonly>
                        </div>
                        <% }%>

                        <div class="form-group-block" <%= !"student".equals(userRole) ? "style=\"grid-column: span 2;\"" : ""%>>
                            <label class="form-field-label">PHONE NUMBER</label>
                            <input type="text" name="phoneNo" class="form-text-layout-input" style="width: 100%; padding: 10px; border: 1px solid #cccccc;" value="${userProfile.phone}" placeholder="Enter phone number" required>
                        </div>

                    </div>
                </div>

                <div style="margin-top: 35px; border-top: 1px solid #e0e0e0; padding-top: 25px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px;">
                    <div class="form-actions-footer" style="display: flex; gap: 15px; margin: 0;">
                        <button type="submit" class="report-btn-generate" style="padding: 14px 35px; background-color: #00897b; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer;">
                            SAVE CHANGES
                        </button>
                        <a href="javascript:window.history.back();" class="report-btn-preview" style="padding: 14px 35px; text-decoration: none; text-align: center; background-color: #eeeeee; color: #333333; border-radius: 4px; font-weight: bold; display: inline-block;">
                            CANCEL
                        </a>
                    </div>

                    <div>
                        <a href="changePassword.jsp" class="report-btn-preview" style="padding: 14px 25px; text-decoration: none; text-align: center; background-color: #34495e; color: #ffffff; border-radius: 4px; font-weight: bold; display: inline-block;">
                            🔒 SECURITY & CHANGE PASSWORD
                        </a>
                    </div>
                </div>

            </form>
        </div>
    </body>
</html>