<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="DBConnection.DBConnection" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Assign Course to Lecturer</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Assign Course to Lecturer</h1>
                <a href="AdminUsersServlet?roleTab=lecturer" class="logout-link" style="color: #333333; text-decoration: underline;">&larr; Back to Lecturers</a>
            </div>

            <c:if test="${not empty sessionScope.error}">
                <div class="admin-rules-notice-banner" style="background-color: #f2dede; border-color: #ebccd1; color: #a94442; margin-top: 20px; padding: 15px; border-radius: 4px;">
                    <p class="notice-text-content"><strong>Error:</strong> ${sessionScope.error}</p>
                </div>
                <% session.removeAttribute("error"); %>
            </c:if>

            <form action="LecturerAssignmentServlet" method="POST" class="leave-application-form" style="max-width: 700px; margin-top: 20px;">

                <div class="form-group-block">
                    <label class="form-field-label">TARGET LECTURER</label>
                    <% String preSelectedMatric = request.getParameter("matricNo");%>
                    <select name="lecturerMatricNo" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px; border: 1px solid #cccccc; border-radius: 4px;" required>
                        <option value="" disabled <%= preSelectedMatric == null ? "selected" : ""%>>-- Select Lecturer Profile --</option>
                        <%
                            try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery("SELECT matricNo, fullName FROM users WHERE role = 'lecturer' ORDER BY fullName ASC")) {
                                while (rs.next()) {
                                    String matric = rs.getString("matricNo");
                                    String isSelected = matric.equals(preSelectedMatric) ? "selected" : "";
                        %>
                        <option value="<%= matric%>" <%= isSelected%>><%= rs.getString("fullName")%> (<%= matric%>)</option>
                        <% }
                } catch (Exception e) {
                    e.printStackTrace();
                } %>
                    </select>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">SELECT FACULTY</label>
                    <select id="facultySelect" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px; border: 1px solid #cccccc; border-radius: 4px;" onchange="loadCourses()">
                        <option value="" selected disabled>-- Select Faculty --</option>
                        <%
                            try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery("SELECT DISTINCT facultyName FROM course ORDER BY facultyName ASC")) {
                                while (rs.next()) {
                        %>
                        <option value="<%= rs.getString("facultyName")%>"><%= rs.getString("facultyName")%></option>
                        <% }
                } catch (Exception e) {
                    e.printStackTrace();
                }%>
                    </select>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">ASSIGN COURSE MODULE</label>
                    <select name="courseCode" id="courseSelect" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px; border: 1px solid #cccccc; border-radius: 4px;" required>
                        <option value="" disabled selected>-- Select Faculty First --</option>
                    </select>
                </div>

                <script>
                    function loadCourses() {
                        var faculty = document.getElementById("facultySelect").value;
                        var courseSelect = document.getElementById("courseSelect");

                        fetch('GetCoursesByFacultyServlet?faculty=' + encodeURIComponent(faculty))
                                .then(response => response.json())
                                .then(data => {
                                    courseSelect.innerHTML = '<option value="" disabled selected>-- Select Course --</option>';
                                    data.forEach(course => {
                                        var option = document.createElement("option");
                                        option.value = course.code;
                                        option.text = course.code + " - " + course.name;
                                        courseSelect.add(option);
                                    });
                                });
                    }
                </script>
                
                <div class="form-actions-footer" style="margin-top: 35px; display: flex; justify-content: flex-start; gap: 15px;">
                    <button type="submit" class="report-btn-generate" style="padding: 14px 45px; background-color: #00897b; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer;">
                        EXECUTE ASSIGNMENT
                    </button>
                    <a href="AdminUsersServlet?roleTab=lecturer" class="report-btn-preview" style="padding: 14px 35px; text-decoration: none; text-align: center; background-color: #eeeeee; color: #333333; border-radius: 4px; font-weight: bold;">
                        CANCEL
                    </a>
                </div>
            </form>
        </div>
    </body>
</html>

