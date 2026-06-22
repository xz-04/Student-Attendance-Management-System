package DBConnection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection — singleton utility for getting a MySQL connection. Place this
 * file at: src/java/DBConnection/DBConnection.java
 */
public class DBConnection {

    // -------------------------------------------------------
    // Update these three values to match your database setup
    // -------------------------------------------------------
    private static final String URL = "jdbc:mysql://localhost:3306/STUDENTATTENDANCEMANAGEMENTSYSTEM";
    private static final String USER = "root";
    private static final String PASSWORD = "";           

    private static Connection conn = null;

    /**
     * Returns a shared Connection instance. Creates a new one if it doesn't
     * exist or was closed.
     */
    public static Connection getConnection() {
        try {
            if (conn == null || conn.isClosed()) {
                Class.forName("com.mysql.cj.jdbc.Driver"); // MySQL 8+
                // For MySQL 5.x use: com.mysql.jdbc.Driver
                conn = DriverManager.getConnection(URL, USER, PASSWORD);
            }
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] MySQL JDBC driver not found. "
                    + "Add mysql-connector-j.jar to your project libraries.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("[DBConnection] Failed to connect to database: "
                    + e.getMessage());
            e.printStackTrace();
        }
        return conn;
    }
}
//
//private Connection getConnection() throws SQLException {
//        return DBConnection.getConnection();
//    }