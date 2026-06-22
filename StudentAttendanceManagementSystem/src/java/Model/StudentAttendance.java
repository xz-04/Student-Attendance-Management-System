package Model;

public class StudentAttendance {

    private String matricNo;
    private String name;
    private String checkInTime;
    private String ipAddress;
    private String status;

    // Constructor
    public StudentAttendance(String matricNo, String name, String checkInTime, String ipAddress, String status) {
        this.matricNo = matricNo;
        this.name = name;
        this.checkInTime = checkInTime;
        this.ipAddress = ipAddress;
        this.status = status;
    }

    // Getters (Required by JSTL tags to read values)
    public String getMatricNo() {
        return matricNo;
    }

    public String getName() {
        return name;
    }

    public String getCheckInTime() {
        return checkInTime;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public String getStatus() {
        return status;
    }
}
