package Model;

public class Course {

    private String facultyName;
    private String courseCode;
    private String courseName;
    private String courseStatus;

    // Updated Constructor to support the added column entity parameter rule
    public Course(String facultyName, String courseCode, String courseName, String courseStatus) {
        this.facultyName = facultyName;
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.courseStatus = courseStatus; // ◄--- INITIALIZE IT
    }

    public Course(String courseCode, String courseName) {
        this.courseCode = courseCode;
        this.courseName = courseName;
    }

    // Getters and Setters
    public String getFacultyName() {
        return facultyName;
    }

    public void setFacultyName(String facultyName) {
        this.facultyName = facultyName;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getCourseStatus() {
        return this.courseStatus;
    }
}
