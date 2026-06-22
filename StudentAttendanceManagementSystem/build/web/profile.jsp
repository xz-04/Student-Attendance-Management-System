<%@page import="DBConnection.DBConnection"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userRole = (String) session.getAttribute("userRole");
    userRole = (userRole != null) ? userRole.trim().toLowerCase() : "student";
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

            <form id="profileForm" action="SaveProfileServlet" method="POST" enctype="multipart/form-data" class="profile-layout-container-form">

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
                        <label class="report-btn-generate" style="padding: 6px 12px; font-size: 11px; width: 100%; text-align: center; cursor: pointer; background-color: #00897b; color: white; border-radius: 4px; font-weight: bold;">
                            CHANGE PHOTO
                            <input type="file" name="profilePhoto" id="photoInput" accept="image/*" style="display: none;">
                        </label>
                    </div>

                    <div class="profile-input-fields-matrix-grid" style="flex: 1; display: grid; grid-template-columns: 1fr 1fr; gap: 20px 25px;">
                        <div class="form-group-block">
                            <label class="form-field-label">MATRIC NO</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; width: 100%; padding: 10px;" value="${userProfile.identifier}" readonly>
                        </div>  
                        <div class="form-group-block">
                            <label class="form-field-label">FULL NAME</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; width: 100%; padding: 10px;" value="${userProfile.name}" readonly>
                        </div>
                        <div class="form-group-block">
                            <label class="form-field-label"><%= "student".equals(userRole) ? "PROGRAMME ID" : "FACULTY"%></label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; width: 100%; padding: 10px;" value="${userProfile.faculty}" readonly>
                        </div>
                        <div class="form-group-block">
                            <label class="form-field-label">EMAIL</label>
                            <input type="email" class="form-text-layout-input" style="background-color: #e8e6e0; width: 100%; padding: 10px;" value="${userProfile.email}" readonly>
                        </div>

                        <% if ("student".equals(userRole)) { %>
                        <div class="form-group-block">
                            <label class="form-field-label">PROGRAMME FULL NAME</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; width: 100%; padding: 10px;" value="${userProfile.programme}" readonly>
                        </div>
                        <div class="form-group-block">
                            <label class="form-field-label">ACADEMIC BATCH</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8e6e0; width: 100%; padding: 10px;" value="${userProfile.batchSession}" readonly>
                        </div>
                        <div class="form-group-block" style="grid-column: span 2;">
                            <label class="form-field-label">CURRENT PROGRESSION LEVEL</label>
                            <input type="text" class="form-text-layout-input" style="background-color: #e8f4f2; border: 1px solid #00897b; width: 100%; padding: 10px;" value="${userProfile.academicYearSem}" readonly>
                        </div>
                        <% }%>

                        <div class="form-group-block" <%= !"student".equals(userRole) ? "style=\"grid-column: span 2;\"" : ""%>>
                            <label class="form-field-label">PHONE NUMBER</label>
                            <input type="text" name="phoneNo" class="form-text-layout-input" style="width: 100%; padding: 10px; border: 1px solid #cccccc;" value="${userProfile.phone}" required>
                        </div>
                    </div>
                </div>

                <div style="margin-top: 35px; border-top: 1px solid #e0e0e0; padding-top: 25px; display: flex; justify-content: space-between; align-items: center;">

                    <button type="submit" class="btn-action btn-save">
                        <span>💾</span> SAVE CHANGES
                    </button>

                    <a href="changePassword.jsp" class="btn-action btn-pass">
                        <span>🔒</span> CHANGE PASSWORD
                    </a>

                </div>
            </form>
        </div>

        <script>
            // Auto-submit form when a new photo file is selected
            document.getElementById('photoInput').addEventListener('change', function () {
                if (this.files && this.files[0]) {
                    document.getElementById('profileForm').submit();
                }
            });
        </script>
    </body>
</html>