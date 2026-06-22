<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Absence Leave Applications</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="studentSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Application of Absence Leave</h1>
                <a href="LogoutServlet" class="logout-link">Logout</a>
            </div>

            <div class="filter-tabs-row">
                <a href="LeaveServlet?status=all" class="tab-item ${param.status == 'all' || empty param.status ? 'active' : ''}">All Applications</a>
                <a href="LeaveServlet?status=pending" class="tab-item ${param.status == 'pending' ? 'active' : ''}">Pending (${pendingCount != null ? pendingCount : 0})</a>
                <a href="LeaveServlet?status=approved" class="tab-item ${param.status == 'approved' ? 'active' : ''}">Approved (${approvedCount != null ? approvedCount : 0})</a>
                <a href="LeaveServlet?status=rejected" class="tab-item ${param.status == 'rejected' ? 'active' : ''}">Rejected (${rejectedCount != null ? rejectedCount : 0})</a>
            </div>

            <table class="leave-records-table">
                <thead>
                    <tr>
                        <th style="width: 60px;">NO.</th>
                        <th style="width: 150px;">COURSE CODE</th>
                        <th>COURSE NAME</th>
                        <th style="width: 140px;">DATE</th>
                        <th style="width: 130px; text-align: center;">STATUS</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="leave" items="${leaveApplicationsList}" varStatus="loop">
                        <tr>
                            <td>${loop.index + 1}</td>

                            <td class="monospace-text"><strong>${leave.courseCode}</strong></td>
                            <td>${leave.courseName}</td>
                            <td>${leave.sessionDate}</td>

                            <td style="text-align: center;">
                                <c:choose>
                                    <c:when test="${leave.approvalStatus == 'Pending'}">
                                        <span class="badge-status jsp-pending" style="background-color: #fef5e7; color: #f39c12; padding: 4px 8px; font-weight: bold; border-radius: 4px; font-size: 11px;">PENDING</span>
                                    </c:when>
                                    <c:when test="${leave.approvalStatus == 'Approved'}">
                                        <span class="badge-status jsp-approved" style="background-color: #e8f8f5; color: #2ecc71; padding: 4px 8px; font-weight: bold; border-radius: 4px; font-size: 11px;">APPROVED</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status jsp-rejected" style="background-color: #fadbd8; color: #e74c3c; padding: 4px 8px; font-weight: bold; border-radius: 4px; font-size: 11px;">REJECTED</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty leaveApplicationsList}">
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 45px; color: #888888; font-style: italic;">
                                No leave requests recorded matching this filter view.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>

            <div class="action-footer-row" style="margin-top: 25px;">
                <a href="LoadApplyLeaveServlet" class="theme-btn-action" style="text-decoration: none; padding: 12px 25px; display: inline-block; font-weight: bold;">
                    + NEW LEAVE APPLICATION
                </a>
            </div>
        </div>
    </body>
</html>