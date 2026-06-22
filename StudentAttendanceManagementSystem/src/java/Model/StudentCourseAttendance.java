package Model;

public class StudentCourseAttendance {

    private String courseCode;
    private String courseName;
    private int attendedSessions;
    private int totalSessions;
    private int attendancePercentage;

    public StudentCourseAttendance(String courseCode, String courseName, int attendedSessions, int totalSessions) {
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.attendedSessions = attendedSessions;
        this.totalSessions = totalSessions;
        // Prevent division-by-zero errors if a course has no sessions generated yet
        this.attendancePercentage = (totalSessions > 0) ? (int) Math.round(((double) attendedSessions / totalSessions) * 100) : 100;
    }

    // Getters for Expression Language access
    public String getCourseCode() {
        return courseCode;
    }

    public String getCourseName() {
        return courseName;
    }

    public int getAttendedSessions() {
        return attendedSessions;
    }

    public int getTotalSessions() {
        return totalSessions;
    }

    public int getAttendancePercentage() {
        return attendancePercentage;
    }
}
