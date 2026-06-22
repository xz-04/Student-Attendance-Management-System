<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Leave Evaluation Details</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <%@ include file="lecturerSidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1>Evaluate Leave Application</h1>
                <a href="LecturerLeaveApprovalServlet" class="logout-link" style="background-color: #777;">Back to List</a>
            </div>

            <div style="display: flex; gap: 30px; margin-top: 20px; align-items: flex-start;">

                <div style="flex: 1; background: #ffffff; padding: 25px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); border: 1px solid #e0e0e0;">
                    <h2 style="margin-top: 0; color: #333; border-bottom: 2px solid #00897b; padding-bottom: 10px;">Application Summary</h2>

                    <table style="width: 100%; border-collapse: collapse; margin-top: 15px;">
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 12px 0; color: #666; font-weight: bold; width: 130px;">Reference ID:</td>
                            <td style="padding: 12px 0; font-family: monospace; font-weight: bold; color: #111;">${leave.leaveId.toUpperCase()}</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 12px 0; color: #666; font-weight: bold;">Student Name:</td>
                            <td style="padding: 12px 0; color: #111; font-weight: bold;">${leave.fullName}</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 12px 0; color: #666; font-weight: bold;">Matric No:</td>
                            <td style="padding: 12px 0; font-family: monospace; color: #111;">${leave.matricNo}</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 12px 0; color: #666; font-weight: bold;">Course Code:</td>
                            <td style="padding: 12px 0; font-family: monospace; font-weight: bold; color: #00897b;">${leave.courseCode}</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 12px 0; color: #666; font-weight: bold;">Absence Date:</td>
                            <td style="padding: 12px 0; color: #111;">${leave.leaveDate}</td>
                        </tr>
                        <tr>
                            <td style="padding: 12px 0; color: #666; font-weight: bold; vertical-align: top;">Reason:</td>
                            <td style="padding: 12px 0; color: #333; line-height: 1.5; font-style: italic;">"${leave.reason}"</td>
                        </tr>
                    </table>

                    <div style="margin-top: 30px; padding-top: 20px; border-top: 2px solid #eee; text-align: center;">
                        <c:choose>
                            <c:when test="${leave.approvalStatus == 'Pending'}">
                                <p style="font-weight: bold; color: #666; margin-bottom: 15px;">Assign Evaluation Decision:</p>
                                <div style="display: flex; gap: 15px; justify-content: center;">

                                    <form action="ProcessLeaveApproval" method="POST" onsubmit="return confirm('Approve this absence application?');">
                                        <input type="hidden" name="leaveId" value="${leave.leaveId}">
                                        <input type="hidden" name="action" value="approve">
                                        <button type="submit" class="leave-btn-approve" style="cursor: pointer;">APPROVE</button>
                                    </form>

                                    <button type="button" class="leave-btn-reject" style="cursor: pointer;" onclick="executeRejectionPrompt('${leave.leaveId}')">REJECT</button>

                                </div>
                            </c:when>
                            <c:otherwise>
                                <div style="padding: 15px; border-radius: 6px; font-weight: bold; display: inline-block;
                                     background-color: ${leave.approvalStatus == 'Approved' ? '#e8f8f8' : '#fadbd8'};
                                     color: ${leave.approvalStatus == 'Approved' ? '#2ecc71' : '#e74c3c'}; font-size: 14px;">
                                    APPLICATION STATUS: ${leave.approvalStatus.toUpperCase()}
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div style="flex: 1.2; background: #ffffff; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); min-height: 500px;">
                    <h2 style="margin-top: 0; color: #333; border-bottom: 2px solid #ccc; padding-bottom: 10px;">Document Preview</h2>

                    <c:choose>
                        <c:when test="${not empty leave.evidencePath}">
                            <c:set var="filePathLower" value="${leave.evidencePath.toLowerCase()}" />

                            <c:choose>
                                <c:when test="${filePathLower.endsWith('.png') || filePathLower.endsWith('.jpg') || filePathLower.endsWith('.jpeg') || filePathLower.endsWith('.gif')}">
                                    <div style="width: 100%; height: 480px; border: 1px solid #ddd; border-radius: 4px; margin-top: 10px; display: flex; align-items: center; justify-content: center; background: #fdfdfd; overflow: auto;">
                                        <img src="${pageContext.request.contextPath}/${leave.evidencePath}" 
                                             alt="Student Absence Supporting Evidence Document Image" 
                                             style="max-width: 100%; max-height: 100%; object-fit: contain; box-shadow: 0 1px 3px rgba(0,0,0,0.15);">
                                    </div>
                                </c:when>

                                <c:otherwise>
                                    <iframe src="${pageContext.request.contextPath}/${leave.evidencePath}" 
                                            style="width: 100%; height: 480px; border: 1px solid #ddd; border-radius: 4px; margin-top: 10px;" 
                                            frameborder="0">
                                    </iframe>
                                </c:otherwise>
                            </c:choose>

                            <div style="margin-top: 12px; text-align: right;">
                                <a href="${pageContext.request.contextPath}/${leave.evidencePath}" style="color: #00897b; font-weight: bold; text-decoration: none; font-size: 13px;">
                                    Open asset attachment file fullscreen ↗
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div style="display: flex; align-items: center; justify-content: center; height: 400px; color: #999; font-style: italic; background: #fafafa; border: 1px dashed #ccc; border-radius: 4px;">
                                No supporting evidence uploaded for this application.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </div>

        <form id="hiddenRejectionForm" action="ProcessLeaveApproval" method="POST" style="display: none;">
            <input type="hidden" id="rejectLeaveId" name="leaveId" value="">
            <input type="hidden" id="rejectAction" name="action" value="reject">
            <input type="hidden" id="rejectReasonField" name="rejectReason" value="">
        </form>

        <script type="text/javascript">
            // Captures dynamic text explanation details instantly from the reviewer
            function executeRejectionPrompt(leaveId) {
                var promptComment = prompt("REJECTION REMARKS COMPULSORY:\n\nPlease supply a brief reason or context details regarding why this absence request is being rejected. This will print out on the student status history log:");

                if (promptComment === null) {
                    return; // Abort workflow safely if cancel option is hit
                }

                if (promptComment.trim() === "") {
                    alert("Action Aborted: A physical explanation comment is required to complete file rejections.");
                    return;
                }

                // Route components smoothly down into hidden parameters and execute form delivery
                document.getElementById('rejectLeaveId').value = leaveId;
                document.getElementById('rejectReasonField').value = promptComment.trim();
                document.getElementById('hiddenRejectionForm').submit();
            }
        </script>
    </body>
</html>