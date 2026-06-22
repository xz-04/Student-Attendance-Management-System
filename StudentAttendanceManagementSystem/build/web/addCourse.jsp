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
                <a href="CourseServlet?action=list" class="logout-link">← Back to Courses</a>
            </div>

            <form action="${pageContext.request.contextPath}/CourseServlet?action=add" method="POST" class="leave-application-form">

                <div class="form-group-block">
                    <label class="form-field-label">FACULTY OWNERSHIP</label>
                    <select name="facultyName" class="form-dropdown-input" required>
                        <option value="" disabled selected>-- Select Faculty Assignment --</option>
                        <% try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery("SELECT facultyName, facultyFullname FROM faculty ORDER BY facultyName ASC")) {
                            while (rs.next()) {%>
                        <option value="<%= rs.getString("facultyName")%>"><%= rs.getString("facultyName")%> - <%= rs.getString("facultyFullname")%></option>
                        <% }
                        } catch (Exception e) {
                            out.println("<option disabled>Error loading</option>");
                        }%>
                    </select>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">COURSE STATUS</label>
                    <select id="courseStatusSelect" name="courseStatus" class="form-dropdown-input" onchange="toggleFields()" required>
                        <option value="Core" selected>Programme Core</option>
                        <option value="Elective">Elective Course</option>
                    </select>
                </div>

                <div id="yearWrapper" class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">YEAR OF STUDY</label>
                    <select id="yearField" name="yearOfStudy" class="form-dropdown-input" required>
                        <option value="" disabled selected>-- Select Year --</option>
                        <option value="1">1st Year</option>
                        <option value="2">2nd Year</option>
                        <option value="3">3rd Year</option>
                        <option value="4">4th Year+</option>
                    </select>
                </div>

                <div id="semWrapper" class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">TARGET SEMESTER</label>
                    <select id="semField" name="semesterTarget" class="form-dropdown-input" required>
                        <option value="" disabled selected>-- Select Semester --</option>
                        <option value="1">Semester 1</option>
                        <option value="2">Semester 2</option>
                    </select>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">COURSE CODE</label>
                    <input type="text" name="courseCode" class="form-text-layout-input" required style="text-transform: uppercase;">
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">COURSE NAME</label>
                    <input type="text" name="courseName" class="form-text-layout-input" required>
                </div>

                <button type="submit" class="submit-application-btn" style="margin-top: 20px;">REGISTER COURSE</button>
            </form>
        </div>

        <script>
            function toggleFields() {
                var status = document.getElementById("courseStatusSelect").value;
                var isElective = (status === "Elective");

                var wrappers = [document.getElementById("yearWrapper"), document.getElementById("semWrapper")];
                var fields = [document.getElementById("yearField"), document.getElementById("semField")];

                wrappers.forEach((w, i) => {
                    w.style.display = isElective ? "none" : "block";
                    isElective ? fields[i].removeAttribute("required") : fields[i].setAttribute("required", "required");
                });
            }
        </script>
    </body>
</html>