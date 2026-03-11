package com.sellingticket.util;

/**
 * Centralized input validation and sanitization utilities.
 * Prevents XSS, validates common formats.
 */
public final class ValidationUtil {

    private ValidationUtil() {}

    /**
     * Sanitize user input for safe HTML output.
     * Escapes &lt;, &gt;, &amp;, &quot; characters.
     */
    public static String sanitize(String input) {
        if (input == null) return null;
        return input.trim()
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    /**
     * Validate email format.
     */
    public static boolean isValidEmail(String email) {
        if (email == null || email.isBlank()) return false;
        return email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    /**
     * Validate Vietnamese phone number format.
     */
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.isBlank()) return false;
        return phone.matches("^(\\+84|0)\\d{9,10}$");
    }

    /**
     * Validate positive monetary amount within reasonable bounds.
     */
    public static boolean isPositiveAmount(double amount) {
        return amount > 0 && amount < 1_000_000_000;
    }

    /**
     * Check if a string is null or blank.
     */
    public static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    /**
     * Check if a string is not null and not blank.
     */
    public static boolean isNotBlank(String value) {
        return value != null && !value.isBlank();
    }

    /**
     * Null-safe trim.
     */
    public static String trim(String value) {
        return value == null ? null : value.trim();
    }

    /**
     * Truncate string to max length.
     */
    public static String truncate(String value, int maxLength) {
        if (value == null) return null;
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }
}
