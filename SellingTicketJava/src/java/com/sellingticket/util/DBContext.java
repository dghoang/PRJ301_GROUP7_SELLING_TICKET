package com.sellingticket.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBContext - Database connection manager with lightweight connection pooling.
 * 
 * <p>Loads configuration from {@code db.properties} on the classpath.
 * Maintains a pool of reusable connections to avoid the overhead
 * of creating a new TCP connection for every query.</p>
 * 
 * <p>Thread-safe. Pool size is configurable via properties.</p>
 */
public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());

    // Pool
    private static final LinkedBlockingQueue<Connection> pool = new LinkedBlockingQueue<>();
    private static final AtomicInteger activeCount = new AtomicInteger(0);

    // Config (loaded once)
    private static final String URL;
    private static final String USER;
    private static final String PASS;
    private static final int MAX_POOL_SIZE;
    private static final long CONNECTION_TIMEOUT_MS;

    static {
        Properties props = new Properties();
        try (InputStream is = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (is == null) {
                throw new RuntimeException("db.properties not found on classpath! "
                        + "Create src/java/db.properties with server/port/name/user/password.");
            }
            props.load(is);
        } catch (IOException e) {
            throw new RuntimeException("Failed to load db.properties", e);
        }

        String server = props.getProperty("db.server", "localhost");
        String port = props.getProperty("db.port", "1433");
        String dbName = props.getProperty("db.name", "SellingTicketDB");

        URL = "jdbc:sqlserver://" + server + ":" + port
                + ";databaseName=" + dbName
                + ";encrypt=true;trustServerCertificate=true";
        USER = props.getProperty("db.user", "sa");
        PASS = props.getProperty("db.password", "");
        MAX_POOL_SIZE = Integer.parseInt(props.getProperty("db.pool.maxSize", "20"));
        CONNECTION_TIMEOUT_MS = Long.parseLong(props.getProperty("db.pool.connectionTimeoutMs", "30000"));

        LOGGER.log(Level.INFO, "DBContext initialized: {0} (pool max={1})",
                new Object[]{dbName, MAX_POOL_SIZE});
    }

    /**
     * Get a connection from the pool, or create a new one if the pool is empty
     * and we haven't reached the maximum size.
     */
    public Connection getConnection() throws SQLException {
        // 1. Try to reuse a pooled connection
        Connection conn = pool.poll();
        if (conn != null) {
            try {
                if (!conn.isClosed() && conn.isValid(1)) {
                    return conn;
                }
                // Stale connection — discard and decrement
                activeCount.decrementAndGet();
                conn.close();
            } catch (SQLException e) {
                activeCount.decrementAndGet();
            }
        }

        // 2. Create a new connection if under limit
        if (activeCount.get() < MAX_POOL_SIZE) {
            activeCount.incrementAndGet();
            try {
                Connection newConn = DriverManager.getConnection(URL, USER, PASS);
                return newConn;
            } catch (SQLException e) {
                activeCount.decrementAndGet();
                throw e;
            }
        }

        // 3. Pool exhausted — wait for a returned connection
        try {
            conn = pool.poll(CONNECTION_TIMEOUT_MS, java.util.concurrent.TimeUnit.MILLISECONDS);
            if (conn != null && !conn.isClosed() && conn.isValid(2)) {
                return conn;
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        throw new SQLException("Connection pool exhausted (max=" + MAX_POOL_SIZE + ")");
    }

    /**
     * Return a connection to the pool for reuse.
     * Call this in a {@code finally} block instead of {@code conn.close()}.
     */
    public static void returnConnection(Connection conn) {
        if (conn == null) return;
        try {
            if (!conn.isClosed() && conn.isValid(1)) {
                conn.setAutoCommit(true); // Reset state
                pool.offer(conn);
            } else {
                activeCount.decrementAndGet();
                conn.close();
            }
        } catch (SQLException e) {
            activeCount.decrementAndGet();
            try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Close a connection permanently (e.g. after transaction rollback).
     */
    public static void closeConnection(Connection conn) {
        if (conn == null) return;
        activeCount.decrementAndGet();
        try { conn.close(); } catch (SQLException ignored) {}
    }

    /**
     * Get current pool statistics (for monitoring/debugging).
     */
    public static String getPoolStats() {
        return "Pool[active=" + activeCount.get() + ", idle=" + pool.size()
                + ", max=" + MAX_POOL_SIZE + "]";
    }
}
