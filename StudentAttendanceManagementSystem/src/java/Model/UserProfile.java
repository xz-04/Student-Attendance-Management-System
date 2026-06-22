package Model;

public class UserProfile {

    private String name;
    private String identifier;
    private String email;
    private String phone;
    private String faculty;
    private String programme;

    public UserProfile(String name, String identifier, String email, String phone, String faculty, String programme) {
        this.name = name;
        this.identifier = identifier;
        this.email = email;
        this.phone = phone;
        this.faculty = faculty;
        this.programme = programme;
    }

    // Getters for JSP Expression Language access tokens
    public String getName() {
        return name;
    }

    public String getIdentifier() {
        return identifier;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getFaculty() {
        return faculty;
    }

    public String getProgramme() {
        return programme;
    }
}
