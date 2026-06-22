package Model;

public class AttendanceSession {

    private String sessionId;
    private String courseCode;
    private String lecturerName;
    private String dateString;
    private String timeString;
    private String venue;
    private String status;

    // Constructor
    public AttendanceSession(String sessionId, String courseCode, String lecturerName,
            String dateString, String timeString, String venue, String status) {
        this.sessionId = sessionId;
        this.courseCode = courseCode;
        this.lecturerName = lecturerName;
        this.dateString = dateString;
        this.timeString = timeString;
        this.venue = venue;
        this.status = status;
    }

    // Getters (Essential for Expression Language tags in your JSP)
    public String getSessionId() {
        return sessionId;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public String getLecturerName() {
        return lecturerName;
    }

    public String getDateString() {
        return dateString;
    }

    public String getTimeString() {
        return timeString;
    }

    public String getVenue() {
        return venue;
    }

    public String getStatus() {
        return status;
    }
}
