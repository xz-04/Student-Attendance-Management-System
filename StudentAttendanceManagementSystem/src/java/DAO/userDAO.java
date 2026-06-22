package DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import DBConnection.DBConnection;

public class userDAO {

    // =========================
    // LOGIN VALIDATION
    // =========================
    public String validateUser(String matricNo, String password, String role) {

        String fullName = null;

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT fullName FROM Users WHERE matricNo=? AND password=? AND role=?";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, matricNo);
            ps.setString(2, password);
            ps.setString(3, role);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                fullName = rs.getString("fullName");
            }

            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return fullName;
    }

    // =========================
    // REGISTER USER
    // =========================
    public boolean registerUser(String matricNo, String password, String fullName, String role) {

        try {
            Connection conn = DBConnection.getConnection();

            // check duplicate
            String checkSql = "SELECT matricNo FROM Users WHERE matricNo=?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, matricNo);

            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                conn.close();
                return false;
            }

            // insert into Users
            String insertUser
                    = "INSERT INTO Users (matricNo, password, fullName, role) VALUES (?, ?, ?, ?)";

            PreparedStatement ps = conn.prepareStatement(insertUser);
            ps.setString(1, matricNo);
            ps.setString(2, password);
            ps.setString(3, fullName);
            ps.setString(4, role);

            ps.executeUpdate();

            // insert subtype table
            if ("Student".equals(role)) {

                PreparedStatement ps2 = conn.prepareStatement(
                        "INSERT INTO Student (matricNo, overallAttendance) VALUES (?, 0)"
                );
                ps2.setString(1, matricNo);
                ps2.executeUpdate();
            }

            if ("Lecturer".equals(role)) {

                PreparedStatement ps2 = conn.prepareStatement(
                        "INSERT INTO Lecturer (matricNo, department) VALUES (?, NULL)"
                );
                ps2.setString(1, matricNo);
                ps2.executeUpdate();
            }

            conn.close();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
