package Model;

public class LeaveApplication {

    private int leaveId;
    private String courseCode;
    private String courseName;
    private String sessionDate;
    private String reason;
    private String submittedDate;
    private String approvalStatus;
    private String remarks;

    public LeaveApplication(int leaveId, String courseCode, String courseName,
            String sessionDate, String reason, String submittedDate,
            String approvalStatus, String remarks) {
        this.leaveId = leaveId;
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.sessionDate = sessionDate;
        this.reason = reason;
        this.submittedDate = submittedDate;
        this.approvalStatus = approvalStatus;
        this.remarks = remarks;
    }

    // Getters mapped exactly to your JSP Expression Language variable configurations
    public int getLeaveId() {
        return leaveId;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public String getCourseName() {
        return courseName;
    }

    public String getSessionDate() {
        return sessionDate;
    }

    public String getReason() {
        return reason;
    }

    public String getSubmittedDate() {
        return submittedDate;
    }

    public String getApprovalStatus() {
        return approvalStatus;
    }

    public String getRemarks() {
        return remarks;
    }
}
