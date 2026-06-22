package DAO;

import DBConnection.DBConnection;
import Model.Attendance;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {

    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    // Assumes an 'Enrollment' table exists. Update table name if different.
    public int getEnrolledCourseCount(String matricNo) {
        String sql = "SELECT COUNT(*) FROM Enrollment WHERE matricNo = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, matricNo);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalAttendedSessions(String matricNo) {
        String sql = "SELECT COUNT(*) FROM AttendanceRecord WHERE matricNo = ? AND status = 'PRESENT'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, matricNo);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalAbsentSessions(String matricNo) {
        String sql = "SELECT COUNT(*) FROM AttendanceRecord WHERE matricNo = ? AND status = 'ABSENT'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, matricNo);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getPendingLeaveCount(String matricNo) {
        // Joins AbsenceLeave with AttendanceRecord to filter by specific student
        String sql = "SELECT COUNT(*) FROM AbsenceLeave al "
                + "JOIN AttendanceRecord ar ON al.recordId = ar.recordId "
                + "WHERE ar.matricNo = ? AND al.approvalStatus = 'Pending'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, matricNo);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<String> getAtRiskCourses(String matricNo) {
        List<String> atRisk = new ArrayList<>();
        String sql = "SELECT c.courseName FROM Course c "
                + "JOIN AttendanceSession s ON c.courseCode = s.courseCode "
                + "JOIN AttendanceRecord r ON s.sessionId = r.sessionId "
                + "WHERE r.matricNo = ? "
                + "GROUP BY c.courseName "
                + "HAVING (SUM(CASE WHEN r.status = 'PRESENT' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) < 80";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, matricNo);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                atRisk.add(rs.getString("courseName"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return atRisk;
    }

    public List<Attendance> getRecentAttendance(String matricNo) {
        List<Attendance> list = new ArrayList<>();
        // Joins tables to get Course Name instead of just code
        String sql = "SELECT c.courseName, s.date, s.startTime, r.status "
                + "FROM AttendanceRecord r "
                + "JOIN AttendanceSession s ON r.sessionId = s.sessionId "
                + "JOIN Course c ON s.courseCode = c.courseCode "
                + "WHERE r.matricNo = ? ORDER BY s.date DESC LIMIT 5";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, matricNo);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Attendance a = new Attendance();
                a.setCourseName(rs.getString("courseName"));
                a.setDate(rs.getString("date"));
                a.setTime(rs.getString("startTime")); // Matches AttendanceSession.startTime
                a.setStatus(rs.getString("status"));
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
