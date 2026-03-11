package com.sellingticket.security;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * In-memory login attempt tracker with progressive lockout.
 *
 * <p>Lockout thresholds:
 * <ul>
 *   <li>5 failures → 1 minute</li>
 *   <li>10 failures → 5 minutes</li>
 *   <li>15 failures → 15 minutes</li>
 *   <li>20+ failures → 60 minutes</li>
 * </ul>
 *
 * <p>Key = email + "|" + ip (blocks per email-ip pair).
 * Also tracks per-IP attempts to block distributed attacks.
 * Expired entries are cleaned up every 10 minutes.
 */
public final class LoginAttemptTracker {

    private static final Logger LOGGER = Logger.getLogger(LoginAttemptTracker.class.getName());

    private static final LoginAttemptTracker INSTANCE = new LoginAttemptTracker();

    private final ConcurrentHashMap<String, AttemptRecord> attempts = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, AttemptRecord> ipAttempts = new ConcurrentHashMap<>();

    /** Max failed logins per IP (across all emails) before IP-level block. */
    private static final int IP_BLOCK_THRESHOLD = 30;
    private static final long IP_BLOCK_DURATION_MS = 15 * 60 * 1000L; // 15 min

    private LoginAttemptTracker() {
        // Cleanup thread: remove expired entries every 10 minutes
        ScheduledExecutorService cleaner = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "LoginAttemptCleaner");
            t.setDaemon(true);
            return t;
        });
        cleaner.scheduleAtFixedRate(this::cleanup, 10, 10, TimeUnit.MINUTES);
    }

    public static LoginAttemptTracker getInstance() {
        return INSTANCE;
    }

    /**
     * Record a failed login attempt for email+ip.
     */
    public void recordFailure(String email, String ip) {
        // Track per email+IP
        String key = buildKey(email, ip);
        attempts.compute(key, (k, existing) -> {
            if (existing == null) {
                return new AttemptRecord(1, System.currentTimeMillis());
            }
            existing.count++;
            existing.lastAttempt = System.currentTimeMillis();
            existing.lockedUntil = System.currentTimeMillis() + getLockoutMs(existing.count);
            return existing;
        });

        // Track per IP (defense against distributed credential stuffing)
        if (ip != null) {
            ipAttempts.compute(ip, (k, existing) -> {
                if (existing == null) {
                    return new AttemptRecord(1, System.currentTimeMillis());
                }
                existing.count++;
                existing.lastAttempt = System.currentTimeMillis();
                if (existing.count >= IP_BLOCK_THRESHOLD) {
                    existing.lockedUntil = System.currentTimeMillis() + IP_BLOCK_DURATION_MS;
                }
                return existing;
            });
        }

        LOGGER.log(Level.WARNING, "Failed login: key={0}, count={1}",
                new Object[]{key, getAttemptCount(email, ip)});
    }

    /**
     * Check if this email+ip is currently blocked.
     */
    public boolean isBlocked(String email, String ip) {
        AttemptRecord record = attempts.get(buildKey(email, ip));
        if (record == null) return false;
        if (record.count < 5) return false;
        return System.currentTimeMillis() < record.lockedUntil;
    }

    /**
     * Check if this IP is blocked regardless of email (distributed attack defense).
     */
    public boolean isIpBlocked(String ip) {
        if (ip == null) return false;
        AttemptRecord record = ipAttempts.get(ip);
        if (record == null) return false;
        if (record.count < IP_BLOCK_THRESHOLD) return false;
        return System.currentTimeMillis() < record.lockedUntil;
    }

    /**
     * Get remaining lockout seconds (for user display).
     */
    public int getRemainingLockSeconds(String email, String ip) {
        AttemptRecord record = attempts.get(buildKey(email, ip));
        if (record == null) return 0;
        long remaining = record.lockedUntil - System.currentTimeMillis();
        return remaining > 0 ? (int) (remaining / 1000) : 0;
    }

    /**
     * Get current attempt count.
     */
    public int getAttemptCount(String email, String ip) {
        AttemptRecord record = attempts.get(buildKey(email, ip));
        return record != null ? record.count : 0;
    }

    /**
     * Reset attempts after successful login.
     */
    public void reset(String email, String ip) {
        attempts.remove(buildKey(email, ip));
        // Note: do NOT reset ipAttempts on successful login
        // IP-level tracking persists to catch distributed attacks
    }

    /**
     * Progressive lockout duration based on failure count.
     */
    private long getLockoutMs(int count) {
        if (count >= 20) return 60 * 60 * 1000L; // 60 min
        if (count >= 15) return 15 * 60 * 1000L;  // 15 min
        if (count >= 10) return 5 * 60 * 1000L;   // 5 min
        if (count >= 5)  return 60 * 1000L;        // 1 min
        return 0;
    }

    private String buildKey(String email, String ip) {
        return (email != null ? email.toLowerCase().trim() : "") + "|" + (ip != null ? ip : "");
    }

    private void cleanup() {
        long now = System.currentTimeMillis();
        long maxAge = 2 * 60 * 60 * 1000L; // Remove entries older than 2 hours
        attempts.entrySet().removeIf(e ->
                (now - e.getValue().lastAttempt) > maxAge);
        ipAttempts.entrySet().removeIf(e ->
                (now - e.getValue().lastAttempt) > maxAge);
    }

    private static class AttemptRecord {
        int count;
        long lastAttempt;
        long lockedUntil;

        AttemptRecord(int count, long lastAttempt) {
            this.count = count;
            this.lastAttempt = lastAttempt;
            this.lockedUntil = 0;
        }
    }
}
