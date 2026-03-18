package com.sellingticket.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * JWT utility using HMAC-SHA256 (pure Java, no external libraries).
 * Generates and verifies signed tokens for QR ticket authentication.
 */
public final class JwtUtil {

    private static final Logger LOGGER = Logger.getLogger(JwtUtil.class.getName());
    private static final String ALGORITHM = "HmacSHA256";
    private static final String SECRET = AppConstants.JWT_SECRET;
    private static final long DEFAULT_EXPIRY_MS = 365L * 24 * 60 * 60 * 1000; // 1 year

    /** Access token lifetime: 7 days. */
    public static final long ACCESS_TOKEN_EXPIRY_SEC = 7L * 24 * 60 * 60;
    /** Refresh token lifetime: 30 days. */
    public static final long REFRESH_TOKEN_EXPIRY_SEC = 30L * 24 * 60 * 60;

    private JwtUtil() {}

    /**
     * Generate a JWT token for a ticket QR code with a specific expiry time.
     * Payload: sub=ticketCode, tid=ticketId, eid=eventId, iat, exp
     */
    public static String generateTicketToken(int ticketId, String ticketCode, int eventId, long expireTimeMillis) {
        long now = System.currentTimeMillis() / 1000;
        long exp = expireTimeMillis / 1000;

        String header = base64Url("{\"alg\":\"HS256\",\"typ\":\"JWT\"}");
        String payload = base64Url("{\"sub\":\"" + escapeJson(ticketCode)
                + "\",\"tid\":" + ticketId
                + ",\"eid\":" + eventId
                + ",\"iat\":" + now
                + ",\"exp\":" + exp + "}");

        String signature = sign(header + "." + payload);
        return header + "." + payload + "." + signature;
    }

    /**
     * Verify a JWT token and return the claims as a Map.
     * Returns null if token is invalid, expired, or tampered with.
     */
    public static Map<String, Object> verifyTicketToken(String token) {
        if (token == null || token.isEmpty()) {
            LOGGER.log(Level.WARNING, "JWT token is null or empty");
            return null;
        }

        String[] parts = token.split("\\.");
        if (parts.length != 3) {
            LOGGER.log(Level.WARNING, "JWT token has {0} parts instead of 3", parts.length);
            return null;
        }

        // Defense-in-depth: reject tokens with unexpected algorithm
        if (!isExpectedAlgorithm(parts[0])) {
            LOGGER.log(Level.WARNING, "JWT rejected: unexpected algorithm in header");
            return null;
        }

        // Verify signature
        String expectedSig = sign(parts[0] + "." + parts[1]);
        if (!constantTimeEquals(expectedSig, parts[2])) {
            LOGGER.log(Level.WARNING, "JWT signature mismatch — expected={0} actual={1}",
                    new Object[]{expectedSig.substring(0, Math.min(10, expectedSig.length())),
                                 parts[2].substring(0, Math.min(10, parts[2].length()))});
            return null;
        }

        // Decode payload
        try {
            String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
            Map<String, Object> claims = parseSimpleJson(payloadJson);

            // Check expiration
            Object expObj = claims.get("exp");
            if (expObj != null) {
                long exp = ((Number) expObj).longValue();
                if (System.currentTimeMillis() / 1000 > exp) {
                    LOGGER.log(Level.INFO, "JWT token expired at {0}", exp);
                    return null;
                }
            }

            return claims;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "JWT decode error", e);
            return null;
        }
    }

    // ========================
    // AUTH TOKEN METHODS
    // ========================

    /**
     * Generate an access token for user authentication.
     * Payload: sub=userId, email, role, type=access, iat, exp (7 days).
     */
    public static String generateAccessToken(int userId, String email, String role) {
        long now = System.currentTimeMillis() / 1000;
        long exp = now + ACCESS_TOKEN_EXPIRY_SEC;

        String header = base64Url("{\"alg\":\"HS256\",\"typ\":\"JWT\"}");
        String payload = base64Url("{\"sub\":" + userId
                + ",\"email\":\"" + escapeJson(email)
                + "\",\"role\":\"" + escapeJson(role)
                + "\",\"type\":\"access\""
                + ",\"iat\":" + now
                + ",\"exp\":" + exp + "}");

        String signature = sign(header + "." + payload);
        return header + "." + payload + "." + signature;
    }

    /**
     * Generate a refresh token for session renewal.
     * Payload: sub=userId, jti=unique-id, type=refresh, iat, exp (30 days).
     *
     * @return String[2]: [0]=JWT token, [1]=jti (for DB storage)
     */
    public static String[] generateRefreshToken(int userId) {
        long now = System.currentTimeMillis() / 1000;
        long exp = now + REFRESH_TOKEN_EXPIRY_SEC;
        String jti = UUID.randomUUID().toString();

        String header = base64Url("{\"alg\":\"HS256\",\"typ\":\"JWT\"}");
        String payload = base64Url("{\"sub\":" + userId
                + ",\"jti\":\"" + jti
                + "\",\"type\":\"refresh\""
                + ",\"iat\":" + now
                + ",\"exp\":" + exp + "}");

        String signature = sign(header + "." + payload);
        return new String[]{ header + "." + payload + "." + signature, jti };
    }

    /** Generate a compact opaque token ID for cookie-based refresh flows. */
    public static String generateRefreshTokenId() {
        return UUID.randomUUID().toString();
    }

    /**
     * Verify an auth token (access or refresh) and return claims.
     * Returns null if invalid, expired, or tampered.
     */
    public static Map<String, Object> verifyAuthToken(String token) {
        if (token == null || token.isEmpty()) return null;

        String[] parts = token.split("\\.");
        if (parts.length != 3) return null;

        // Defense-in-depth: reject tokens with unexpected algorithm
        if (!isExpectedAlgorithm(parts[0])) {
            LOGGER.log(Level.WARNING, "Auth JWT rejected: unexpected algorithm in header");
            return null;
        }

        String expectedSig = sign(parts[0] + "." + parts[1]);
        if (!constantTimeEquals(expectedSig, parts[2])) {
            LOGGER.log(Level.WARNING, "Auth JWT signature mismatch");
            return null;
        }

        try {
            String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
            Map<String, Object> claims = parseSimpleJson(payloadJson);

            Object expObj = claims.get("exp");
            if (expObj != null) {
                long exp = ((Number) expObj).longValue();
                if (System.currentTimeMillis() / 1000 > exp) {
                    return null; // expired — silent, not a security event
                }
            }
            return claims;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Auth JWT decode error", e);
            return null;
        }
    }

    // ========================
    // INTERNAL HELPERS
    // ========================

    private static String base64Url(String input) {
        return Base64.getUrlEncoder().withoutPadding()
                .encodeToString(input.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Defense-in-depth: verify the JWT header contains the expected HS256 algorithm.
     * Rejects tokens with alg:none, alg:HS384, or any unexpected algorithm.
     */
    private static boolean isExpectedAlgorithm(String headerBase64) {
        try {
            String headerJson = new String(Base64.getUrlDecoder().decode(headerBase64), StandardCharsets.UTF_8);
            // Quick check: the header must contain "HS256"
            return headerJson.contains("\"HS256\"");
        } catch (Exception e) {
            return false;
        }
    }

    private static String sign(String data) {
        try {
            Mac mac = Mac.getInstance(ALGORITHM);
            SecretKeySpec keySpec = new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            mac.init(keySpec);
            byte[] rawHmac = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(rawHmac);
        } catch (Exception e) {
            throw new RuntimeException("HMAC-SHA256 signing failed", e);
        }
    }

    /** Constant-time comparison to prevent timing attacks (no length leak). */
    private static boolean constantTimeEquals(String a, String b) {
        byte[] aBytes = a.getBytes(StandardCharsets.UTF_8);
        byte[] bBytes = b.getBytes(StandardCharsets.UTF_8);
        return MessageDigest.isEqual(aBytes, bBytes);
    }

    private static String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    /**
     * Minimalist JSON parser for flat JWT payloads (no nested objects).
     * Only handles: strings, numbers, booleans.
     */
    private static Map<String, Object> parseSimpleJson(String json) {
        Map<String, Object> map = new HashMap<>();
        json = json.trim();
        if (json.startsWith("{")) json = json.substring(1);
        if (json.endsWith("}")) json = json.substring(0, json.length() - 1);

        int i = 0;
        while (i < json.length()) {
            // Find key
            int keyStart = json.indexOf('"', i);
            if (keyStart < 0) break;
            int keyEnd = json.indexOf('"', keyStart + 1);
            if (keyEnd < 0) break;
            String key = json.substring(keyStart + 1, keyEnd);

            // Find colon
            int colon = json.indexOf(':', keyEnd + 1);
            if (colon < 0) break;

            // Find value
            int valStart = colon + 1;
            while (valStart < json.length() && json.charAt(valStart) == ' ') valStart++;

            if (valStart >= json.length()) break;

            char firstChar = json.charAt(valStart);
            if (firstChar == '"') {
                // String value — handle escaped quotes
                int valEnd = valStart + 1;
                while (valEnd < json.length()) {
                    char c = json.charAt(valEnd);
                    if (c == '\\') {
                        valEnd += 2; // skip escaped character
                        continue;
                    }
                    if (c == '"') break;
                    valEnd++;
                }
                String raw = json.substring(valStart + 1, valEnd);
                // Unescape basic sequences
                raw = raw.replace("\\\"", "\"").replace("\\\\", "\\");
                map.put(key, raw);
                i = valEnd + 1;
            } else {
                // Number or boolean
                int valEnd = valStart;
                while (valEnd < json.length() && json.charAt(valEnd) != ',' && json.charAt(valEnd) != '}') {
                    valEnd++;
                }
                String valStr = json.substring(valStart, valEnd).trim();
                if ("true".equals(valStr)) {
                    map.put(key, Boolean.TRUE);
                } else if ("false".equals(valStr)) {
                    map.put(key, Boolean.FALSE);
                } else if (valStr.contains(".")) {
                    map.put(key, Double.parseDouble(valStr));
                } else {
                    map.put(key, Long.parseLong(valStr));
                }
                i = valEnd;
            }

            // Skip comma
            int nextComma = json.indexOf(',', i);
            if (nextComma >= 0) {
                i = nextComma + 1;
            } else {
                break;
            }
        }
        return map;
    }
}
