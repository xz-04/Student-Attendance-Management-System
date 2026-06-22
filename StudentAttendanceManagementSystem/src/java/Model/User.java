package Model;

public class User {

    private String matricNo;
    private String fullName;
    private String facultyName;
    private String role;
    private String programme;
    private String batchSession;
    private String currentLevel;

    // Constructor
    public User(String matricNo, String fullName, String facultyName, String role, String programme, String batchSession, String currentLevel) {
        this.matricNo = matricNo;
        this.fullName = fullName;
        this.facultyName = facultyName;
        this.role = role;
        this.programme = programme;
        this.batchSession = batchSession;
        this.currentLevel = currentLevel;
    }

    // Getters (Required for JSP Expression Language access)
    public String getMatricNo() {
        return matricNo;
    }

    public String getFullName() {
        return fullName;
    }

    public String getFacultyName() {
        return facultyName;
    }

    public String getRole() {
        return role;
    }

    public String getProgramme() {
        return programme;
    }

    public String getBatchSession() {
        return batchSession;
    }

    public String getCurrentLevel() {
        return currentLevel;
    }
}
