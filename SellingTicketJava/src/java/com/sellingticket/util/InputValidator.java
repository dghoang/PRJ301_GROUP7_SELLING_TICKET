package com.sellingticket.util;

import java.util.regex.Pattern;

/**
 * InputValidator — Centralized validation utility for form inputs.
 * <p>Provides reusable validation methods for common field types
 * (email, phone, text length, numeric range, etc.).</p>
 */
public final class InputValidator {

    // Prevent instantiation
    private InputValidator() {}

    // ========================
    // PATTERNS
    // ========================

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^\\+?[0-9]{8,15}$");

    private static final Pattern SLUG_PATTERN =
            Pattern.compile("^[a-z0-9]+(-[a-z0-9]+)*$");

    // ========================
    // STRING VALIDATION
    // ========================

    /** Check if a string is null, empty, or blank. */
    public static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    /** Check if a string is not blank. */
    public static boolean isNotBlank(String value) {
        return !isBlank(value);
    }

    /** Check if a string is within allowed length (inclusive). */
    public static boolean isLengthBetween(String value, int min, int max) {
        if (value == null) return min == 0;
        int len = value.trim().length();
        return len >= min && len <= max;
    }

    /** Require non-blank string within length range. */
    public static boolean isValidText(String value, int minLen, int maxLen) {
        return isNotBlank(value) && isLengthBetween(value, minLen, maxLen);
    }

    // ========================
    // FORMAT VALIDATION
    // ========================

    /** Validate email format. */
    public static boolean isValidEmail(String email) {
        return isNotBlank(email) && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    /** Validate phone format (8-15 digits, optional + prefix). */
    public static boolean isValidPhone(String phone) {
        if (isBlank(phone)) return true; // phone is optional
        return PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    /** Validate slug format (lowercase alphanumeric with hyphens). */
    public static boolean isValidSlug(String slug) {
        return isNotBlank(slug) && SLUG_PATTERN.matcher(slug).matches();
    }

    // ========================
    // NUMERIC VALIDATION
    // ========================

    /** Check if an integer is within allowed range (inclusive). */
    public static boolean isInRange(int value, int min, int max) {
        return value >= min && value <= max;
    }

    /** Check if a double is positive (> 0). */
    public static boolean isPositive(double value) {
        return value > 0;
    }

    /** Check if a double is non-negative (>= 0). */
    public static boolean isNonNegative(double value) {
        return value >= 0;
    }

    /** Safely parse int with default, returning -1 on invalid input. */
    public static int parseIntSafe(String value) {
        if (isBlank(value)) return -1;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    // ========================
    // DOMAIN VALIDATION
    // ========================

    /** Validate event title (3-200 chars). */
    public static boolean isValidEventTitle(String title) {
        return isValidText(title, 3, 200);
    }

    /** Validate event description (10-500000 chars). */
    public static boolean isValidDescription(String description) {
        return isValidText(description, 10, 500000);
    }

    /** Validate user full name (2-100 chars). */
    public static boolean isValidFullName(String name) {
        return isValidText(name, 2, 100);
    }

    /** Validate password (8-100 chars). */
    public static boolean isValidPasswordLength(String password) {
        return isValidText(password, 8, 100);
    }

    /** Validate ticket quantity for purchase (1-10). */
    public static boolean isValidPurchaseQuantity(int quantity) {
        return isInRange(quantity, 1, 10);
    }

    /** Validate voucher code (1-50 chars, alphanumeric + underscore/hyphen). */
    public static boolean isValidVoucherCode(String code) {
        if (isBlank(code)) return false;
        return code.trim().length() <= 50
                && Pattern.matches("^[A-Za-z0-9_-]+$", code.trim());
    }

    /** Validate ticket type name (1-100 chars). */
    public static boolean isValidTicketTypeName(String name) {
        return isValidText(name, 1, 100);
    }

    /** Validate category name (1-100 chars). */
    public static boolean isValidCategoryName(String name) {
        return isValidText(name, 1, 100);
    }

    /** Check if value is one of allowed options (whitelist). */
    public static boolean isOneOf(String value, String... allowed) {
        if (isBlank(value)) return false;
        for (String a : allowed) {
            if (a.equals(value.trim())) return true;
        }
        return false;
    }
}
