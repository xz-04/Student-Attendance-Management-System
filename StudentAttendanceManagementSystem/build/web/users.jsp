<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>User Management</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="adminSidebar.jsp" %>

        <div class="main-content">

            <div class="dashboard-header">
                <h1>User Management Dashboard</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <%                String currentRoleTab = request.getParameter("roleTab");
                if (currentRoleTab == null || currentRoleTab.isEmpty()) {
                    currentRoleTab = "student";
                }
            %>

            <div class="admin-user-role-tabs-row">
                <a href="AdminUsersServlet?roleTab=student" class="role-toggle-tab-btn <%= currentRoleTab.equals("student") ? "active-tab" : ""%>">STUDENTS</a>
                <a href="AdminUsersServlet?roleTab=lecturer" class="role-toggle-tab-btn <%= currentRoleTab.equals("lecturer") ? "active-tab" : ""%>">LECTURERS</a>
                <a href="AdminUsersServlet?roleTab=admin" class="role-toggle-tab-btn <%= currentRoleTab.equals("admin") ? "active-tab" : ""%>">ADMINS</a>
            </div>

            <div id="userManagementContainer">
                <input type="hidden" name="roleTab" value="<%= currentRoleTab%>">

                <div class="admin-control-filter-bar" style="display: flex; justify-content: space-between; align-items: center; gap: 15px; flex-wrap: wrap;">
                    <div style="display: flex; gap: 15px; align-items: center;">
                        <div class="admin-search-group">
                            <input type="text" id="searchUserInput" placeholder="Search..." value="${param.searchUser}" class="admin-filter-search-input" style="width: 380px;">
                            <button type="button" class="admin-search-execute-btn" onclick="executeSearchRedirect()">Search</button>
                        </div>
                    </div>

                    <div style="display: flex; gap: 10px; align-items: center;">
                        <a href="addUser.jsp?roleType=<%= currentRoleTab%>" class="admin-action-btn" style="height: 40px; display: inline-flex; align-items: center; text-decoration: none; padding: 0 20px;">
                            + ADD NEW <%= currentRoleTab.toUpperCase()%>
                        </a>
                    </div>
                </div>

                <table class="dashboard-records-table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">NO.</th>
                            <th style="width: 140px;">MATRIC NO</th>
                            <th>FULL NAME</th>

                            <% if ("student".equalsIgnoreCase(currentRoleTab)) { %>
                            <th>PROGRAMME ID</th>
                            <th>YEAR</th>
                                <% } else if ("lecturer".equalsIgnoreCase(currentRoleTab)) { %>
                            <th>FACULTY NAME</th>
                                <% } %>

                            <%-- MODIFIED: Added a wider header for the expanded action columns --%>
                            <th style="width: 180px; text-align: center;">ACTIONS</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="userItem" items="${adminUsersList}" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td class="monospace-text">${userItem.matricNo}</td>
                                <td><strong>${userItem.fullName}</strong></td>

                                <% if ("student".equalsIgnoreCase(currentRoleTab)) { %>
                                <td class="monospace-text" style="font-weight: bold; color: #00897b;">
                                    <c:out value="${userItem.facultyName}" default="N/A" />
                                </td>
                                <td style="font-size: 13px; color: #333333; font-weight: 500;">
                                    <c:out value="${userItem.programme}" default="N/A" />
                                </td>
                                <% } else if ("lecturer".equalsIgnoreCase(currentRoleTab)) { %>
                                <td>${userItem.facultyName}</td>
                                <% } %>

                                <td style="text-align: center;">
                                    <div class="table-action-btn-group" style="justify-content: center; display: flex; gap: 10px;">

                                        <%-- If Lecturer, add the "Assign Course" link here --%>
                                        <% if ("lecturer".equalsIgnoreCase(currentRoleTab)) { %>
                                        <a href="assignLecturerCourse.jsp?matricNo=${userItem.matricNo}" 
                                           class="table-inline-link" style="color: #00897b; font-weight: bold; text-decoration: none;">
                                            Assign Course
                                        </a>
                                        <% }%>

                                        <a href="DeleteUserServlet?matricNo=${userItem.matricNo}&roleTab=<%= currentRoleTab%>" 
                                           class="table-inline-link" style="color: #a94442; font-weight: bold; text-decoration: none;"
                                           onclick="return confirm('Are you sure you want to remove this user?');">
                                            Delete
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <script type="text/javascript">
            function executeSearchRedirect() {
                var queryVal = encodeURIComponent(document.getElementById('searchUserInput').value.trim());
                window.location.href = "AdminUsersServlet?roleTab=<%= currentRoleTab%>&searchUser=" + queryVal;
            }
        </script>
    </body>
</html>