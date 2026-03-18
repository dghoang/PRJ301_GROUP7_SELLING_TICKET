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
        ORGANIZER("organizer"),
        SUPPORT_AGENT("support_agent"),
        ADMIN("admin");

        private final String value;
        UserRole(String value) { this.value = value; }
        public String getValue() { return value; }

        @Override
        public String toString() { return value; }
    }

    // ========================
    // EVENT STAFF ROLE
    // ========================
    public enum EventStaffRole {
        MANAGER("manager"),
        STAFF("staff"),
        SCANNER("scanner");

        private final String value;
        EventStaffRole(String value) { this.value = value; }
        public String getValue() { return value; }

        @Override
        public String toString() { return value; }
    }

    /**
     * Normalize event staff role to canonical values: manager/staff/scanner.
     * Legacy aliases are mapped for backward compatibility.
     */
    public static String normalizeEventStaffRole(String role) {
        if (role == null) return null;
        String value = role.trim().toLowerCase();
        switch (value) {
            case "manager":
                return EventStaffRole.MANAGER.getValue();
            case "staff":
            case "editor":
            case "viewer":
                return EventStaffRole.STAFF.getValue();
            case "scanner":
            case "checkin":
                return EventStaffRole.SCANNER.getValue();
            default:
                return null;
        }
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
        if (env == null || env.isEmpty()) {
            throw new RuntimeException(
                    "TICKETBOX_JWT_SECRET env variable is required. "
                    + "Set it before starting the server.");
        }
        return env;
    }

    private static String loadAdminKey() {
        String env = System.getenv("TICKETBOX_ADMIN_KEY");
        if (env == null || env.isEmpty()) {
            throw new RuntimeException(
                    "TICKETBOX_ADMIN_KEY env variable is required. "
                    + "Set it before starting the server.");
        }
        return env;
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
