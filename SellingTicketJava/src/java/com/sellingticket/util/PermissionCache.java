package com.sellingticket.util;

import com.sellingticket.dao.EventStaffDAO;
import jakarta.servlet.http.HttpSession;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * HMAC-signed permission cache stored in HTTP session.
 *
 * <p>Each cached entry is signed with the JWT secret so that
 * session tampering cannot forge permission data. Entries
 * auto-expire after {@link #TTL_MS} milliseconds.
 *
 * <p>Format: {@code eventId -> SignedEntry(role, userId, timestamp, hmac)}
 */
public final class PermissionCache {

    private static final Logger LOGGER = Logger.getLogger(PermissionCache.class.getName());
    private static final String SESSION_KEY = "permissionCache";
    private static final String HMAC_ALGO = "HmacSHA256";
    private static final long TTL_MS = 10 * 60 * 1000; // 10 minutes
    private static final EventStaffDAO staffDAO = new EventStaffDAO();

    private PermissionCache() {}

    /**
     * Get cached + verified role for a user on an event.
     * Loads from DB on cache miss or expired/tampered entry.
     *
     * @return staff role string or null if no permission
     */
    @SuppressWarnings("unchecked")
    public static String getRole(HttpSession session, int eventId, int userId) {
        Map<Integer, String[]> cache = (Map<Integer, String[]>) session.getAttribute(SESSION_KEY);
        if (cache == null) {
            cache = new ConcurrentHashMap<>();
            session.setAttribute(SESSION_KEY, cache);
        }

        String[] entry = cache.get(eventId);
        if (entry != null && verifyEntry(entry, eventId, userId)) {
            return "__NONE__".equals(entry[0]) ? null : entry[0];
        }

        // Cache miss or invalid — load from DB
        String role = staffDAO.getStaffRole(eventId, userId);
        String storedRole = role != null ? role : "__NONE__";
        cache.put(eventId, signEntry(storedRole, eventId, userId));
        return role;
    }

    /**
     * Check if user has any permission on an event (cached).
     */
    public static boolean hasPermission(HttpSession session, int eventId, int userId) {
        return getRole(session, eventId, userId) != null;
    }

    /**
     * Invalidate entire cache (call after team membership changes).
     */
    public static void invalidate(HttpSession session) {
        session.removeAttribute(SESSION_KEY);
    }

    /**
     * Create a signed entry: [role, eventId, userId, timestamp, hmac].
     */
    private static String[] signEntry(String role, int eventId, int userId) {
        long ts = System.currentTimeMillis();
        String data = role + ":" + eventId + ":" + userId + ":" + ts;
        String hmac = hmacSign(data);
        return new String[]{role, String.valueOf(eventId), String.valueOf(userId), String.valueOf(ts), hmac};
    }

    /**
     * Verify entry: check HMAC signature + TTL expiry + matching ids.
     */
    private static boolean verifyEntry(String[] entry, int eventId, int userId) {
        if (entry.length != 5) return false;

        try {
            int cachedEventId = Integer.parseInt(entry[1]);
            int cachedUserId = Integer.parseInt(entry[2]);
            long ts = Long.parseLong(entry[3]);

            // Check IDs match
            if (cachedEventId != eventId || cachedUserId != userId) return false;

            // Check TTL
            if (System.currentTimeMillis() - ts > TTL_MS) return false;

            // Verify HMAC
            String data = entry[0] + ":" + entry[1] + ":" + entry[2] + ":" + entry[3];
            String expected = hmacSign(data);
            return constantTimeEquals(expected, entry[4]);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Invalid permission cache entry", e);
            return false;
        }
    }

    private static String hmacSign(String data) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGO);
            String secret = AppConstants.JWT_SECRET;
            SecretKeySpec keySpec = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), HMAC_ALGO);
            mac.init(keySpec);
            byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException("HMAC signing failed", e);
        }
    }

    private static boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null || a.length() != b.length()) return false;
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }
}
