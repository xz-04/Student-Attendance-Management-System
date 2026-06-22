package Model;

public class FacultyOverview {

    private String name;
    private int totalStudents;
    private double avgAttendance;
    private int belowThresholdCount;
    private int activeSessions;

    // Constructor
    public FacultyOverview(String name, int totalStudents, double avgAttendance, int belowThresholdCount, int activeSessions) {
        this.name = name;
        this.totalStudents = totalStudents;
        this.avgAttendance = avgAttendance;
        this.belowThresholdCount = belowThresholdCount;
        this.activeSessions = activeSessions;
    }

    // Getters (Required for JSTL Expression Language tags)
    public String getName() {
        return name;
    }

    public int getTotalStudents() {
        return totalStudents;
    }

    public double getAvgAttendance() {
        return avgAttendance;
    }

    public int getBelowThresholdCount() {
        return belowThresholdCount;
    }

    public int getActiveSessions() {
        return activeSessions;
    }
}
