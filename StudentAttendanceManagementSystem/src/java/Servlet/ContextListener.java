package Servlet;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Enumeration;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class ContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Executed when the web application starts up
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Executed when you click Redeploy / Stop inside NetBeans

        // 1. Manually shutdown the MySQL Abandoned Connection thread
        try {
            AbandonedConnectionCleanupThread.checkedShutdown();
            System.out.println("--> [SAMS SHUTDOWN] MySQL cleanup thread terminated successfully.");
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2. Deregister the JDBC Driver cleanly from the DriverManager registry
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            try {
                DriverManager.deregisterDriver(driver);
                System.out.println("--> [SAMS SHUTDOWN] Deregistered JDBC driver: " + driver.toString());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
