package com.sellingticket.util;

/**
 * Shared JSON string escaping utility.
 * Eliminates duplicated esc() methods across API servlets.
 */
public final class JsonUtil {

    private JsonUtil() {}

    /**
     * Escape a string for safe JSON embedding.
     * Handles backslash, quotes, and all control characters.
     */
    public static String esc(String v) {
        if (v == null) return "";
        return v.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
