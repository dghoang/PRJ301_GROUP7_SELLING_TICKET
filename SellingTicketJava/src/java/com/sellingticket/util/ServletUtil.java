package com.sellingticket.util;

import com.sellingticket.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;

/**
 * Shared servlet utility methods.
 * Eliminates duplicate parseInt/parseDouble/parseDate/auth helpers across controllers.
 *
 * <p>All date formatters use immutable {@code DateTimeFormatter} — thread-safe
 * in servlet singletons (unlike {@code SimpleDateFormat}).</p>
 */
public final class ServletUtil {

    private static final int MAX_RETURN_URL_LENGTH = 1000;

    /** Thread-safe date formatter (yyyy-MM-dd). */
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    /** Thread-safe datetime formatter (yyyy-MM-dd'T'HH:mm). */
    private static final DateTimeFormatter DATETIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private static final ZoneId ZONE_VN = ZoneId.of("Asia/Ho_Chi_Minh");

    private ServletUtil() {}

    // ========================
    // PARSING
    // ========================

    /** Parse int from string, returning defaultValue on null/empty/invalid input. */
    public static int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.isEmpty()) return defaultValue;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** Parse double from string, returning defaultValue on null/empty/invalid input. */
    public static double parseDoubleOrDefault(String value, double defaultValue) {
        if (value == null || value.isEmpty()) return defaultValue;
        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * Parse a date string, trying "yyyy-MM-dd'T'HH:mm" first, then "yyyy-MM-dd".
     * Thread-safe. Returns null on null/empty/invalid input.
     */
    public static Date parseDateOrNull(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        String trimmed = value.trim();
        // Try datetime first
        try {
            LocalDateTime ldt = LocalDateTime.parse(trimmed, DATETIME_FORMAT);
            return Date.from(ldt.atZone(ZONE_VN).toInstant());
        } catch (DateTimeParseException e) {
            // Fall through to date-only
        }
        // Try date-only
        try {
            LocalDate ld = LocalDate.parse(trimmed, DATE_FORMAT);
            return Date.from(ld.atStartOfDay(ZONE_VN).toInstant());
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    // ========================
    // PATH HELPERS
    // ========================

    /** Extract first numeric segment from pathInfo (e.g. "/123/edit" → 123). */
    public static int getIdFromPath(String pathInfo) {
        if (pathInfo == null) return -1;
        for (String part : pathInfo.split("/")) {
            if (part.matches("\\d+")) {
                return Integer.parseInt(part);
            }
        }
        return -1;
    }

    // ========================
    // SESSION & AUTH
    // ========================

    /** Get logged-in user from session (checks both "user" and "account" keys). */
    public static User getSessionUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = (User) session.getAttribute("account");
        }
        return user;
    }

    /** Set a toast message + type on the session for flash display after redirect. */
    public static void setToast(HttpServletRequest request, String message, String type) {
        HttpSession session = request.getSession();
        session.setAttribute("toastMessage", message);
        session.setAttribute("toastType", type);
    }

    /** Build app-relative path with query string from the current request URI. */
    public static String getRequestPathWithQuery(HttpServletRequest request) {
        String path = request.getRequestURI();
        String contextPath = request.getContextPath();
        if (path.startsWith(contextPath)) {
            path = path.substring(contextPath.length());
        }
        if (path.isEmpty()) {
            path = "/";
        }

        String queryString = request.getQueryString();
        if (queryString != null && !queryString.isEmpty()) {
            String sanitizedQuery = removeNestedReturnUrl(queryString);
            if (!sanitizedQuery.isEmpty()) {
                path += "?" + sanitizedQuery;
            }
        }

        if (path.length() > MAX_RETURN_URL_LENGTH) {
            path = path.substring(0, MAX_RETURN_URL_LENGTH);
        }
        return path;
    }

    /** Redirect unauthenticated users to login while preserving the current path. */
    public static void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String currentUri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String loginPath = contextPath + "/login";

        // Guard against redirect loops and runaway returnUrl growth.
        if (currentUri != null && currentUri.equals(loginPath)) {
            response.sendRedirect(loginPath);
            return;
        }

        String returnUrl = getRequestPathWithQuery(request);
        String encoded = URLEncoder.encode(returnUrl, StandardCharsets.UTF_8);
        response.sendRedirect(loginPath + "?returnUrl=" + encoded);
    }

    private static String removeNestedReturnUrl(String queryString) {
        String[] parts = queryString.split("&");
        StringBuilder sb = new StringBuilder();
        for (String p : parts) {
            if (p == null || p.isEmpty()) {
                continue;
            }
            String lower = p.toLowerCase();
            if (lower.startsWith("returnurl=")) {
                continue;
            }
            if (sb.length() > 0) {
                sb.append("&");
            }
            sb.append(p);
        }
        return sb.toString();
    }

    // ========================
    // JSON RESPONSE
    // ========================

    /** Write a JSON string response with correct content type and encoding. */
    public static void sendJson(HttpServletResponse response, String json) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(json);
            out.flush();
        }
    }

    /** Write a JSON string response with a specific HTTP status code. */
    public static void sendJson(HttpServletResponse response, int status, String json) throws IOException {
        response.setStatus(status);
        sendJson(response, json);
    }

    // ========================
    // SLUG GENERATION
    // ========================

    /** Generate URL-friendly slug from Vietnamese title. */
    public static String generateSlug(String title) {
        if (title == null) return "";
        String slug = title.toLowerCase().trim()
                .replaceAll("[àáạảãâầấậẩẫăằắặẳẵ]", "a")
                .replaceAll("[èéẹẻẽêềếệểễ]", "e")
                .replaceAll("[ìíịỉĩ]", "i")
                .replaceAll("[òóọỏõôồốộổỗơờớợởỡ]", "o")
                .replaceAll("[ùúụủũưừứựửữ]", "u")
                .replaceAll("[ỳýỵỷỹ]", "y")
                .replaceAll("[đ]", "d")
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("[\\s-]+", "-")
                .replaceAll("^-|-$", "");
        return slug + "-" + System.currentTimeMillis();
    }
}
