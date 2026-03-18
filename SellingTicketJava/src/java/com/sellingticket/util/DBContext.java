package com.sellingticket.util;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
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
 * <p>Connections returned by {@link #getConnection()} are wrapped in a proxy
 * that intercepts {@code close()} to return the connection to the pool
 * instead of destroying it. This makes the pool compatible with
 * {@code try-with-resources} used in DAOs.</p>
 * 
 * <p>Thread-safe. Pool size is configurable via properties.</p>
 */
public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());

    // Pool stores raw (unwrapped) connections
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

        // Load SQL Server JDBC driver explicitly
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("SQL Server JDBC driver not found! "
                    + "Add mssql-jdbc-*.jar to WEB-INF/lib/", e);
        }

        String server = resolveProperty(props, "db.server", "DB_SERVER", "localhost");
        String port = resolveProperty(props, "db.port", "DB_PORT", "1433");
        String dbName = requireProperty(resolveProperty(props, "db.name", "DB_NAME", null), "db.name");
        String encrypt = resolveProperty(props, "db.encrypt", "DB_ENCRYPT", "true");
        String trustServerCertificate = resolveProperty(props, "db.trustServerCertificate",
            "DB_TRUST_SERVER_CERTIFICATE", "true");

        URL = "jdbc:sqlserver://" + server + ":" + port
                + ";databaseName=" + dbName
            + ";encrypt=" + encrypt
            + ";trustServerCertificate=" + trustServerCertificate;
        USER = requireProperty(resolveProperty(props, "db.user", "DB_USER", null), "db.user");
        PASS = requireProperty(resolveProperty(props, "db.password", "DB_PASSWORD", null), "db.password");
        MAX_POOL_SIZE = Integer.parseInt(props.getProperty("db.pool.maxSize", "20"));
        CONNECTION_TIMEOUT_MS = Long.parseLong(props.getProperty("db.pool.connectionTimeoutMs", "30000"));

        LOGGER.log(Level.INFO, "DBContext initialized: {0} (pool max={1})",
                new Object[]{dbName, MAX_POOL_SIZE});
    }

    /**
     * Get a pool-managed connection. The returned connection is wrapped so that
     * {@code close()} returns it to the pool instead of destroying the TCP link.
     * Safe to use with {@code try-with-resources}.
     */
    public Connection getConnection() throws SQLException {
        // 1. Try to reuse a pooled connection
        Connection raw = pool.poll();
        if (raw != null) {
            try {
                if (!raw.isClosed() && raw.isValid(1)) {
                    return wrapConnection(raw);
                }
                // Stale connection — discard and decrement
                activeCount.decrementAndGet();
                raw.close();
            } catch (SQLException e) {
                activeCount.decrementAndGet();
            }
        }

        // 2. Create a new connection if under limit (atomic slot reservation)
        int current;
        do {
            current = activeCount.get();
            if (current >= MAX_POOL_SIZE) break;
        } while (!activeCount.compareAndSet(current, current + 1));

        if (current < MAX_POOL_SIZE) {
            try {
                Connection newConn = DriverManager.getConnection(URL, USER, PASS);
                return wrapConnection(newConn);
            } catch (SQLException e) {
                activeCount.decrementAndGet();
                throw e;
            }
        }

        // 3. Pool exhausted — wait for a returned connection
        try {
            raw = pool.poll(CONNECTION_TIMEOUT_MS, java.util.concurrent.TimeUnit.MILLISECONDS);
            if (raw != null && !raw.isClosed() && raw.isValid(2)) {
                return wrapConnection(raw);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        throw new SQLException("Connection pool exhausted (max=" + MAX_POOL_SIZE + ")");
    }

    // ========================
    // CONNECTION PROXY
    // ========================

    /**
     * Wrap a raw JDBC connection so that {@code close()} returns it to the pool
     * instead of destroying it. All other method calls delegate to the real connection.
     */
    private static Connection wrapConnection(Connection raw) {
        return (Connection) Proxy.newProxyInstance(
                Connection.class.getClassLoader(),
                new Class<?>[]{Connection.class},
                new PooledConnectionHandler(raw));
    }

    /**
     * Unwrap a proxied connection to get the raw JDBC connection.
     * Used by {@link OrderDAO#createOrderAtomic} and other code that needs
     * direct transaction control (setAutoCommit, commit, rollback).
     */
    public static Connection unwrap(Connection conn) {
        if (Proxy.isProxyClass(conn.getClass())) {
            InvocationHandler handler = Proxy.getInvocationHandler(conn);
            if (handler instanceof PooledConnectionHandler) {
                return ((PooledConnectionHandler) handler).raw;
            }
        }
        return conn;
    }

    /**
     * InvocationHandler that intercepts {@code close()} to return the
     * connection to the pool, and delegates everything else to the raw connection.
     */
    private static class PooledConnectionHandler implements InvocationHandler {
        final Connection raw;
        private boolean returned = false;

        PooledConnectionHandler(Connection raw) {
            this.raw = raw;
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            // Intercept close() → return to pool
            if ("close".equals(method.getName()) && (args == null || args.length == 0)) {
                if (!returned) {
                    returned = true;
                    returnConnectionToPool(raw);
                }
                return null;
            }
            // Intercept isClosed() — report as closed if already returned
            if ("isClosed".equals(method.getName()) && (args == null || args.length == 0)) {
                return returned || raw.isClosed();
            }
            try {
                return method.invoke(raw, args);
            } catch (java.lang.reflect.InvocationTargetException e) {
                throw e.getCause();
            }
        }
    }

    /**
     * Return a raw connection to the pool for reuse.
     */
    private static void returnConnectionToPool(Connection raw) {
        if (raw == null) return;
        try {
            if (!raw.isClosed() && raw.isValid(1)) {
                raw.setAutoCommit(true); // Reset state
                pool.offer(raw);
            } else {
                activeCount.decrementAndGet();
                raw.close();
            }
        } catch (SQLException e) {
            activeCount.decrementAndGet();
            try { raw.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Return a connection to the pool for reuse.
     * @deprecated Use {@code try-with-resources} instead — proxy handles return automatically.
     */
    @Deprecated
    public static void returnConnection(Connection conn) {
        if (conn == null) return;
        // Unwrap proxy before returning to pool
        Connection raw = unwrap(conn);
        returnConnectionToPool(raw);
    }

    /**
     * Close a connection permanently (e.g. after transaction rollback).
     */
    public static void closeConnection(Connection conn) {
        if (conn == null) return;
        Connection raw = unwrap(conn);
        activeCount.decrementAndGet();
        try { raw.close(); } catch (SQLException ignored) {}
    }

    /**
     * Get current pool statistics (for monitoring/debugging).
     */
    public static String getPoolStats() {
        return "Pool[active=" + activeCount.get() + ", idle=" + pool.size()
                + ", max=" + MAX_POOL_SIZE + "]";
    }

    private static String resolveProperty(Properties props, String key, String envKey, String defaultValue) {
        String value = props.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            String env = System.getenv(envKey);
            if (env != null && !env.trim().isEmpty()) {
                value = env;
            }
        }
        if (value == null || value.trim().isEmpty()) {
            value = defaultValue;
        }
        return value != null ? value.trim() : null;
    }

    private static String requireProperty(String value, String key) {
        if (value == null || value.isEmpty()) {
            throw new RuntimeException("Missing required DB config: " + key);
        }

        String normalized = value.toUpperCase();
        if (normalized.startsWith("CHANGE_ME") || "YOUR_VALUE".equals(normalized)) {
            throw new RuntimeException("Unsafe placeholder detected for DB config: " + key);
        }
        return value;
    }
}

