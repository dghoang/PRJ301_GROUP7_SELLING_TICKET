package com.sellingticket.dao;

import com.sellingticket.model.PageResult;
import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Abstract base for all DAOs. Provides template methods for common
 * query patterns, eliminating boilerplate try/catch/close in subclasses.
 *
 * <p>Usage: extend this class, call {@code queryList()} or {@code querySingle()}
 * with a SQL string, a parameter setter, and a row mapper.</p>
 *
 * <pre>
 * public List&lt;Event&gt; getAllApproved() {
 *     return queryList(
 *         "SELECT * FROM Events WHERE status = ?",
 *         ps -> ps.setString(1, "approved"),
 *         this::mapEvent
 *     );
 * }
 * </pre>
 */
public abstract class BaseDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(BaseDAO.class.getName());

    // ========================
    // FUNCTIONAL INTERFACES
    // ========================

    /** Sets parameters on a PreparedStatement. */
    @FunctionalInterface
    protected interface ParamSetter {
        void setParams(PreparedStatement ps) throws SQLException;
    }

    /** Maps a single ResultSet row to a domain object. */
    @FunctionalInterface
    protected interface RowMapper<T> {
        T map(ResultSet rs) throws SQLException;
    }

    /** No-op param setter for queries without parameters. */
    protected static final ParamSetter NO_PARAMS = ps -> {};

    // ========================
    // QUERY TEMPLATES
    // ========================

    /**
     * Execute a SELECT query and return a list of mapped objects.
     *
     * @param sql    SQL SELECT statement
     * @param setter lambda to bind parameters
     * @param mapper lambda to map each row to an object
     * @return list of mapped objects (never null, empty list on error)
     */
    protected <T> List<T> queryList(String sql, ParamSetter setter, RowMapper<T> mapper) {
        List<T> results = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setter.setParams(ps);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(mapper.map(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Query failed: " + sql, e);
        }
        return results;
    }

    /**
     * Execute a SELECT query and return the first result, or null.
     *
     * @param sql    SQL SELECT statement
     * @param setter lambda to bind parameters
     * @param mapper lambda to map the row to an object
     * @return the mapped object, or null if no rows / error
     */
    protected <T> T querySingle(String sql, ParamSetter setter, RowMapper<T> mapper) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setter.setParams(ps);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapper.map(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Query failed: " + sql, e);
        }
        return null;
    }

    /**
     * Execute a single-value aggregate query (COUNT, SUM, MAX, etc.).
     *
     * @param sql    SQL with a single numeric result column
     * @param setter lambda to bind parameters
     * @param defaultValue value to return on error or no results
     * @return the aggregate value
     */
    protected int queryScalar(String sql, ParamSetter setter, int defaultValue) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setter.setParams(ps);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Scalar query failed: " + sql, e);
        }
        return defaultValue;
    }

    /**
     * Execute a paginated query returning both items and total count.
     * The dataSql must already include OFFSET/FETCH placeholders as the
     * last two parameters. The countSql returns a single COUNT(*) value.
     *
     * @param dataSql  SQL with OFFSET ? ROWS FETCH NEXT ? ROWS ONLY at end
     * @param countSql SQL that returns COUNT(*) with same WHERE conditions
     * @param setter   lambda to bind WHERE parameters (NOT offset/fetch)
     * @param mapper   lambda to map each row to an object
     * @param page     1-based page number
     * @param pageSize number of items per page
     * @return PageResult with items and pagination metadata
     */
    protected <T> PageResult<T> queryPaged(String dataSql, String countSql,
                                           ParamSetter setter, RowMapper<T> mapper,
                                           int page, int pageSize) {
        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(100, pageSize));

        int totalItems = queryScalar(countSql, setter, 0);

        List<T> items = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(dataSql)) {
            setter.setParams(ps);
            // Set OFFSET and FETCH as the last two parameters
            int paramCount = ps.getParameterMetaData().getParameterCount();
            ps.setInt(paramCount - 1, (safePage - 1) * safeSize);
            ps.setInt(paramCount, safeSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapper.map(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Paged query failed: " + dataSql, e);
        }

        return new PageResult<>(items, totalItems, safePage, safeSize);
    }

    /**
     * Execute an INSERT/UPDATE/DELETE statement.
     *
     * @param sql    SQL DML statement
     * @param setter lambda to bind parameters
     * @return number of affected rows, or 0 on error
     */
    protected int executeUpdate(String sql, ParamSetter setter) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setter.setParams(ps);
            return ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Update failed: " + sql, e);
        }
        return 0;
    }

    /**
     * Execute an INSERT and return the generated key (auto-increment ID).
     *
     * @param sql    SQL INSERT statement
     * @param setter lambda to bind parameters
     * @return generated key, or 0 on error
     */
    protected int executeInsertReturnKey(String sql, ParamSetter setter) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setter.setParams(ps);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Insert failed: " + sql, e);
        }
        return 0;
    }
}
