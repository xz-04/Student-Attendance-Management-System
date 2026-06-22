package DAO;

import DBConnection.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class AdminDAO {

    // Helper method to establish your standard Database Connection
    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    // 1. Retrieve total count where role = 'student'
    public int getTotalStudentsCount() {
        int count = 0;
        String query = "SELECT COUNT(*) FROM users WHERE role = 'student'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 2. Retrieve total count of courses found in database
    public int getTotalCoursesCount() {
        int count = 0;
        String query = "SELECT COUNT(*) FROM courses";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 3. Retrieve total count where role = 'lecturer'
    public int getLecturersCount() {
        int count = 0;
        String query = "SELECT COUNT(*) FROM users WHERE role = 'lecturer'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 4. Retrieve Active Live Sessions based on Current System Date and Time Bounds
    public int getActiveLiveSessionsCount() {
        int count = 0;

        // Formats your check parameters precisely to match SQL Date/Time types
        LocalDateTime now = LocalDateTime.now();
        String currentDate = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        String currentTime = now.format(DateTimeFormatter.ofPattern("HH:mm:ss"));

        // Checks if the session date matches today, and the current clock sits between start and end times
        String query = "SELECT COUNT(*) FROM attendance_sessions WHERE session_date = ? AND ? BETWEEN start_time AND end_time";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, currentDate);
            ps.setString(2, currentTime);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }
}
