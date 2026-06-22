<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="DBConnection.DBConnection" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Add New Course</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Add New Course Module</h1>
                <a href="CourseServlet?action=list" class="logout-link" style="color: #333333; text-decoration: underline;">&larr; Back to Courses</a>
            </div>

            <c:if test="${not empty requestScope.error}">
                <div class="admin-rules-notice-banner" style="background-color: #f2dede; border-color: #ebccd1; color: #a94442; margin-top: 20px; padding: 15px; border-radius: 4px;">
                    <p class="notice-text-content"><strong>Error:</strong> ${requestScope.error}</p>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/CourseServlet?action=add" method="POST" class="leave-application-form" style="max-width: 700px; margin-top: 20px;">

                <div class="form-group-block">
                    <label class="form-field-label">FACULTY OWNERSHIP</label>
                    <select name="facultyName" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px; border: 1px solid #cccccc; border-radius: 4px;" required>
                        <option value="" disabled selected>-- Select Faculty Assignment --</option>
                        <%                            Connection conn = null;
                            Statement stmt = null;
                            ResultSet rs = null;
                            try {
                                conn = DBConnection.getConnection();
                                stmt = conn.createStatement();
                                String query = "SELECT facultyName, facultyFullname FROM faculty WHERE facultyName != 'JSM' ORDER BY facultyName ASC";
                                rs = stmt.executeQuery(query);
                                while (rs.next()) {
                                    String facCode = rs.getString("facultyName");
                                    String facFullName = rs.getString("facultyFullname");
                        %>
                        <option value="<%= facCode%>"><%= facCode%> - <%= facFullName%></option>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<option value=''>Error retrieving faculties from database</option>");
                            } finally {
                                if (rs != null) try {
                                    rs.close();
                                } catch (SQLException e) {
                                }
                                if (stmt != null) try {
                                    stmt.close();
                                } catch (SQLException e) {
                                }
                                if (conn != null) try {
                                    conn.close();
                                } catch (SQLException e) {
                                }
                            }
                        %>
                    </select>
                </div>

                <%-- COURSE STATUS SELECTION METRIC --%>
                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">COURSE STATUS CLASSIFICATION</label>
                    <select id="courseStatusSelect" name="courseStatus" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px; border: 1px solid #cccccc; border-radius: 4px;" onchange="toggleYearFieldLayout()" required>
                        <option value="Core" selected>Programme Core</option>
                        <option value="Elective">Elective Course</option>
                    </select>
                </div>

                <%-- YEAR OF STUDY WRAPPER PANEL --%>
                <div id="yearOfStudyWrapper" class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">YEAR OF STUDY</label>
                    <select id="yearOfStudyField" name="yearOfStudy" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px; border: 1px solid #cccccc; border-radius: 4px;" required>
                        <option id="yearPlaceholderOption" value="" disabled selected>-- Select Academic Year --</option>
                        <option value="1">1st Year Student Requirement</option>
                        <option value="2">2nd Year Student Requirement</option>
                        <option value="3">3rd Year Student Requirement</option>
                        <option value="4">4th Year+ Student Requirement</option>
                    </select>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">TARGET SEMESTER</label>
                    <select name="semesterTarget" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px; border: 1px solid #cccccc; border-radius: 4px;" required>
                        <option value="" disabled selected>-- Select Running Semester --</option>
                        <option value="1">Semester 1</option>
                        <option value="2">Semester 2</option>
                    </select>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">COURSE CODE</label>
                    <input type="text" name="courseCode" class="form-text-layout-input" placeholder="e.g., SECR2033" style="text-transform: uppercase; width: 100%; padding: 10px;" required>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">COURSE NAME</label>
                    <input type="text" name="courseName" class="form-text-layout-input" placeholder="e.g., Software Engineering" style="width: 100%; padding: 10px;" required>
                </div>

                <div class="form-actions-footer" style="margin-top: 35px; display: flex; justify-content: flex-start; gap: 15px;">
                    <button type="submit" class="report-btn-generate" style="padding: 14px 45px; background-color: #00897b; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer;">
                        REGISTER COURSE
                    </button>
                    <a href="CourseServlet?action=list" class="report-btn-preview" style="padding: 14px 35px; text-decoration: none; text-align: center; background-color: #eeeeee; color: #333333; border-radius: 4px; font-weight: bold;">
                        CANCEL
                    </a>
                </div>

            </form>
        </div>

        <script type="text/javascript">
            function toggleYearFieldLayout() {
                var status = document.getElementById("courseStatusSelect").value;
                var yearWrapper = document.getElementById("yearOfStudyWrapper");
                var yearField = document.getElementById("yearOfStudyField");
                var placeholderOption = document.getElementById("yearPlaceholderOption");

                if (status === "Elective") {
                    yearWrapper.style.display = "none";
                    yearField.removeAttribute("required");
                    yearField.value = ""; // Strip parameters completely on submission
                } else {
                    yearWrapper.style.display = "block";
                    yearField.setAttribute("required", "required");

                    // Reset to unselected placeholder view context if toggling back
                    if (yearField.value === "") {
                        placeholderOption.selected = true;
                    }
                }
            }

            window.addEventListener('DOMContentLoaded', toggleYearFieldLayout);
        </script>
    </body>
</html>