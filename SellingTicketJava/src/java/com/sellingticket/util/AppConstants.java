package com.sellingticket.util;

/**
 * Centralized constants for the application.
 * Replaces scattered magic strings with type-safe enums.
 */
public final class AppConstants {

    private AppConstants() {}

    // ========================
    // EVENT STATUS
    // ========================
    public enum EventStatus {
        PENDING("pending"),
        APPROVED("approved"),
        REJECTED("rejected"),
        CANCELLED("cancelled");

        private final String value;
        EventStatus(String value) { this.value = value; }
        public String getValue() { return value; }

        @Override
        public String toString() { return value; }
    }

    // ========================
    // ORDER STATUS
    // ========================
    public enum OrderStatus {
        PENDING("pending"),
        PAID("paid"),
        CHECKED_IN("checked_in"),
        CANCELLED("cancelled"),
        REFUND_REQUESTED("refund_requested"),
        REFUNDED("refunded");

        private final String value;
        OrderStatus(String value) { this.value = value; }
        public String getValue() { return value; }

        @Override
        public String toString() { return value; }
    }

    // ========================
    // USER ROLE
    // ========================
    public enum UserRole {
        CUSTOMER("customer"),
        SUPPORT_AGENT("support_agent"),
        ADMIN("admin");

        private final String value;
        UserRole(String value) { this.value = value; }
        public String getValue() { return value; }

        @Override
        public String toString() { return value; }
    }

    // ========================
    // JWT SECRET
    // ========================
    public static final String JWT_SECRET = loadSecret();

    // ========================
    // ADMIN PRIVATE KEY (for role upgrade to admin)
    // ========================
    public static final String ADMIN_PRIVATE_KEY = loadAdminKey();

    private static String loadSecret() {
        String env = System.getenv("TICKETBOX_JWT_SECRET");
        if (env != null && !env.isEmpty()) return env;
        return "TkB0x_S3cR3t_K3y_2026!@#HMAC256_AntiF0rg3ry";
    }

    private static String loadAdminKey() {
        String env = System.getenv("TICKETBOX_ADMIN_KEY");
        if (env != null && !env.isEmpty()) return env;
        return "AdminMasterKey@2026!Prv";
    }

    // ========================
    // PAYMENT METHOD
    // ========================
    public enum PaymentMethod {
        SEEPAY("seepay"),
        BANK_TRANSFER("bank_transfer"),
        CASH("cash");

        private final String value;
        PaymentMethod(String value) { this.value = value; }
        public String getValue() { return value; }

        @Override
        public String toString() { return value; }
    }
}
