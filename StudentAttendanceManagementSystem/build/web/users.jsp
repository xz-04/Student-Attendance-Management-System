<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>User Management | SAMS</title>
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
                if (currentRoleTab == null || currentRoleTab.isEmpty())
                    currentRoleTab = "student";
            %>

            <%-- Modern Segmented Tab Navigation --%>
            <div class="admin-user-role-tabs-row">
                <a href="AdminUsersServlet?roleTab=student" class="role-toggle-tab-btn <%= currentRoleTab.equals("student") ? "active-tab" : ""%>">STUDENTS</a>
                <a href="AdminUsersServlet?roleTab=lecturer" class="role-toggle-tab-btn <%= currentRoleTab.equals("lecturer") ? "active-tab" : ""%>">LECTURERS</a>
                <a href="AdminUsersServlet?roleTab=admin" class="role-toggle-tab-btn <%= currentRoleTab.equals("admin") ? "active-tab" : ""%>">ADMINS</a>
            </div>

            <div id="userManagementContainer">
                <div class="admin-control-filter-bar">
                    <div class="admin-search-group">
                        <input type="text" id="searchUserInput" placeholder="Search by name or ID..." value="${param.searchUser}" class="admin-filter-search-input">
                        <button type="button" class="admin-search-execute-btn" onclick="executeSearchRedirect()">SEARCH</button>
                    </div>
                    <a href="addUser.jsp?roleType=<%= currentRoleTab%>" class="admin-action-btn">+ ADD NEW <%= currentRoleTab.toUpperCase()%></a>
                </div>

                <table class="dashboard-records-table">
                    <thead>
                        <tr>
                            <th>NO.</th>
                            <th>MATRIC NO</th>
                            <th>FULL NAME</th>
                                <% if ("student".equalsIgnoreCase(currentRoleTab)) { %>
                            <th>PROGRAMME</th>
                            <th>YEAR</th>
                                <% } else if ("lecturer".equalsIgnoreCase(currentRoleTab)) { %>
                            <th>FACULTY</th>
                                <% } %>
                            <th style="text-align: center;">ACTIONS</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="userItem" items="${adminUsersList}" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td class="monospace-text">${userItem.matricNo}</td>
                                <td><strong>${userItem.fullName}</strong></td>

                                <% if ("student".equalsIgnoreCase(currentRoleTab)) { %>
                                <td><c:out value="${userItem.facultyName}" default="N/A" /></td>
                                <td><c:out value="${userItem.programme}" default="N/A" /></td>
                                <% } else if ("lecturer".equalsIgnoreCase(currentRoleTab)) { %>
                                <td>${userItem.facultyName}</td>
                                <% } %>

                                <td style="text-align: center;">
                                    <div class="table-action-btn-group">
                                        <%-- Lecturer Specific Actions --%>
                                        <% if ("lecturer".equalsIgnoreCase(currentRoleTab)) { %>
                                        <a href="assignLecturerCourse.jsp?matricNo=${userItem.matricNo}" class="table-inline-link" style="color: #00897b;">Assign</a>
                                        <a href="ViewLecturerCoursesServlet?matricNo=${userItem.matricNo}" class="table-inline-link" style="color: #3498db;">View Courses</a>
                                        <% }%>

                                        <a href="DeleteUserServlet?matricNo=${userItem.matricNo}&roleTab=<%= currentRoleTab%>" 
                                           class="table-inline-link" style="color: #a94442;"
                                           onclick="return confirm('Remove this user?');">Delete</a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <script>
            function executeSearchRedirect() {
                var queryVal = encodeURIComponent(document.getElementById('searchUserInput').value.trim());
                window.location.href = "AdminUsersServlet?roleTab=<%= currentRoleTab%>&searchUser=" + queryVal;
            }
        </script>
    </body>
</html>