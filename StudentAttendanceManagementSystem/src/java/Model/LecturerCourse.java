package Model;

public class LecturerCourse {

    private String courseCode;
    private String courseName;
    private int totalStudents;

    public LecturerCourse(String courseCode, String courseName, int totalStudents) {
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.totalStudents = totalStudents;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public String getCourseName() {
        return courseName;
    }

    public int getTotalStudents() {
        return totalStudents;
    }
}
