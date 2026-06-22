<%@page import="DBConnection.DBConnection"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Add New User</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>Add New User Account</h1>
                <a href="AdminUsersServlet" class="logout-link" style="color: #333333; text-decoration: underline;">&larr; Back to Users</a>
            </div>

            <c:if test="${not empty requestScope.error}">
                <div class="admin-rules-notice-banner" style="background-color: #f2dede; border-color: #ebccd1; color: #a94442; padding: 15px; margin-bottom: 20px; border-radius: 4px;">
                    <p class="notice-text-content"><strong>Error:</strong> <c:out value="${requestScope.error}" /></p>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/AddUserServlet" method="POST" class="leave-application-form">

                <div class="form-group-block">
                    <label class="form-field-label">ACCOUNT TYPE / ROLE</label>
                    <select id="roleDropdown" name="role" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px;" required>
                        <option value="" disabled ${empty param.roleType ? 'selected' : ''}>-- Select System Role --</option>
                        <option value="student" ${param.roleType == 'student' ? 'selected' : ''}>Student</option>
                        <option value="lecturer" ${param.roleType == 'lecturer' ? 'selected' : ''}>Lecturer</option>
                        <option value="admin" ${param.roleType == 'admin' ? 'selected' : ''}>Admin</option>
                    </select>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">FACULTY</label>
                    <select id="facultyDropdown" name="facultyName" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px;" required>
                        <option value="" disabled selected>-- Select Faculty Branch --</option>
                        <%                            Connection conn = null;
                            Statement stmt = null;
                            ResultSet rs = null;
                            try {
                                conn = DBConnection.getConnection();
                                stmt = conn.createStatement();
                                String query = "SELECT facultyName, facultyFullname FROM faculty ORDER BY facultyName ASC";
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
                                e.printStackTrace();
                            }
                        %>
                    </select>
                </div>

                <div id="studentFieldsContainer" style="display: none;">
                    <div class="form-group-block" style="margin-top: 20px;">
                        <label class="form-field-label">PROGRAMME</label>
                        <select id="programmeDropdown" name="programme" class="form-dropdown-input" style="height: 44px; width: 100%; padding: 10px;">
                            <option value="" disabled selected>-- Select Faculty First --</option>
                        </select>
                    </div>

                    <div class="form-group-block" style="margin-top: 20px;">
                        <label class="form-field-label">INTAKE DATE</label>
                        <input type="date" id="intakeDateInput" name="intakeDate" class="form-text-layout-input" style="width: 100%; padding: 10px;">
                    </div>
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">MATRIC NO</label>
                    <input type="text" name="matricNo" class="form-text-layout-input" placeholder="e.g., A001, L001, S001" required style="width: 100%; padding: 10px;">
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">FULL NAME</label>
                    <input type="text" name="fullName" class="form-text-layout-input" placeholder="e.g., ASIF" required style="width: 100%; padding: 10px;">
                </div>

                <div class="form-group-block" style="margin-top: 20px;">
                    <label class="form-field-label">EMAIL ADDRESS</label>
                    <input type="email" name="email" class="form-text-layout-input" placeholder="e.g., username@domain.com" required style="width: 100%; padding: 10px;">
                </div>


                <div class="form-actions-footer" style="margin-top: 35px; display: flex; justify-content: flex-start; gap: 15px;">
                    <button type="submit" class="report-btn-generate" style="padding: 14px 45px; background-color: #00897b; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer;">
                        CREATE USER PROFILE
                    </button>
                    <a href="AdminUsersServlet" class="report-btn-preview" style="padding: 14px 35px; text-decoration: none; text-align: center; background-color: #eeeeee; color: #333333; border-radius: 4px; font-weight: bold;">
                        CANCEL
                    </a>
                </div>

            </form>
        </div>

        <script type="text/javascript">
            // Build a dynamic relational map of programs group sorted by faculty codes directly out of database records
            var programMap = {
            <%
                    try {
                        if (conn == null || conn.isClosed()) {
                            conn = DBConnection.getConnection();
                        }
                        stmt = conn.createStatement();
                        String progQuery = "SELECT programmeId, programmeName, facultyName FROM programme ORDER BY programmeName ASC";
                        rs = stmt.executeQuery(progQuery);

                        java.util.Map<String, java.util.List<String[]>> mapData = new java.util.HashMap<>();
                        while (rs.next()) {
                            String fName = rs.getString("facultyName");
                            String pId = rs.getString("programmeId");
                            String pName = rs.getString("programmeName");

                            mapData.putIfAbsent(fName, new java.util.ArrayList<>());
                            mapData.get(fName).add(new String[]{pId, pName});
                        }

                        for (java.util.Map.Entry<String, java.util.List<String[]>> entry : mapData.entrySet()) {
                            out.print("\"" + entry.getKey() + "\": [");
                            java.util.List<String[]> list = entry.getValue();
                            for (int i = 0; i < list.size(); i++) {
                                String[] item = list.get(i);
                                out.print("{ id: \"" + item[0] + "\", name: \"" + item[1] + "\" }");
                                if (i < list.size() - 1) {
                                    out.print(",");
                                }
                            }
                            out.println("],");
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
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
            };

            document.addEventListener('DOMContentLoaded', function () {
                var roleDropdown = document.getElementById('roleDropdown');
                var facultyDropdown = document.getElementById('facultyDropdown');
                var studentFieldsContainer = document.getElementById('studentFieldsContainer');
                var proDropdown = document.getElementById('programmeDropdown');
                var intakeInput = document.getElementById('intakeDateInput');

                // Swaps and rebuilds the options inside the Programme dropdown when the selected Faculty changes
                function updateProgrammeOptions() {
                    var selectedFaculty = facultyDropdown.value;

                    proDropdown.innerHTML = '';

                    if (!selectedFaculty || !programMap[selectedFaculty]) {
                        proDropdown.innerHTML = '<option value="" disabled selected>-- No Programme Available --</option>';
                        return;
                    }

                    var optionsList = programMap[selectedFaculty];
                    var defaultOpt = document.createElement('option');
                    defaultOpt.value = "";
                    defaultOpt.disabled = true;
                    defaultOpt.selected = true;
                    defaultOpt.textContent = "-- Select System Programme --";
                    proDropdown.appendChild(defaultOpt);

                    optionsList.forEach(function (prog) {
                        var opt = document.createElement('option');
                        opt.value = prog.id;
                        opt.textContent = prog.id + " - " + prog.name;
                        proDropdown.appendChild(opt);
                    });
                }

                // MODIFIED METHOD: Manages visibility of both the student fields and the PPPA option block
                function handleRoleFormState() {
                    var currentRole = roleDropdown.value;

                    // 1. Toggle visibility of Student specializing fields container
                    if (currentRole === 'student') {
                        studentFieldsContainer.style.display = 'block';
                        proDropdown.setAttribute('required', 'required');
                        intakeInput.setAttribute('required', 'required');
                    } else {
                        studentFieldsContainer.style.display = 'none';
                        proDropdown.removeAttribute('required');
                        intakeInput.removeAttribute('required');
                        proDropdown.value = '';
                        intakeInput.value = '';
                    }

                    // 2. Loop through options inside Faculty dropdown to conditionally hide/show PPPA
                    for (var i = 0; i < facultyDropdown.options.length; i++) {
                        var option = facultyDropdown.options[i];
                        if (option.value === 'PPPA') {
                            if (currentRole === 'student' || currentRole === 'lecturer') {
                                // If PPPA is currently selected, reset dropdown selection to avoid data conflict errors
                                if (facultyDropdown.value === 'PPPA') {
                                    facultyDropdown.value = "";
                                    updateProgrammeOptions();
                                }
                                option.style.display = 'none'; // Hides option block from view visually
                            } else {
                                option.style.display = 'block'; // Restore full visible view access context for Admin roles
                            }
                        }
                    }
                }

                facultyDropdown.addEventListener('change', updateProgrammeOptions);
                roleDropdown.addEventListener('change', handleRoleFormState);

                // Run fallback initializations immediately upon loading layout framework
                handleRoleFormState();
            });
        </script>
    </body>
</html>