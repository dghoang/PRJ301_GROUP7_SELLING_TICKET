package com.sellingticket.util;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Fluent builder for consistent JSON API responses.
 *
 * <p>Usage:</p>
 * <pre>
 * JsonResponse.ok()
 *     .put("userId", user.getUserId())
 *     .put("email", user.getEmail())
 *     .send(response);
 *
 * JsonResponse.error(404, "Event not found").send(response);
 *
 * JsonResponse.ok()
 *     .putArray("events", eventsJsonArray)
 *     .put("total", totalCount)
 *     .send(response);
 * </pre>
 */
public final class JsonResponse {

    private final int status;
    private final StringBuilder json;
    private boolean hasFields = false;

    private JsonResponse(int status) {
        this.status = status;
        this.json = new StringBuilder("{");
    }

    // ========================
    // FACTORY METHODS
    // ========================

    /** Create a 200 OK response. */
    public static JsonResponse ok() {
        return new JsonResponse(200).put("success", true);
    }

    /** Create an error response with status and message. */
    public static JsonResponse error(int status, String message) {
        return new JsonResponse(status)
                .put("success", false)
                .put("error", message);
    }

    /** Create a 400 Bad Request error. */
    public static JsonResponse badRequest(String message) {
        return error(400, message);
    }

    /** Create a 401 Unauthorized error. */
    public static JsonResponse unauthorized() {
        return error(401, "Authentication required");
    }

    /** Create a 403 Forbidden error. */
    public static JsonResponse forbidden(String message) {
        return error(403, message);
    }

    /** Create a 404 Not Found error. */
    public static JsonResponse notFound(String resource) {
        return error(404, resource + " not found");
    }

    /** Create a 500 Internal Server Error. */
    public static JsonResponse serverError() {
        return error(500, "Internal server error");
    }

    // ========================
    // KEY-VALUE SETTERS
    // ========================

    /** Add a string key-value pair. */
    public JsonResponse put(String key, String value) {
        appendComma();
        json.append("\"").append(escapeJson(key)).append("\":");
        if (value == null) {
            json.append("null");
        } else {
            json.append("\"").append(escapeJson(value)).append("\"");
        }
        return this;
    }

    /** Add an integer key-value pair. */
    public JsonResponse put(String key, int value) {
        appendComma();
        json.append("\"").append(escapeJson(key)).append("\":").append(value);
        return this;
    }

    /** Add a long key-value pair. */
    public JsonResponse put(String key, long value) {
        appendComma();
        json.append("\"").append(escapeJson(key)).append("\":").append(value);
        return this;
    }

    /** Add a double key-value pair. */
    public JsonResponse put(String key, double value) {
        appendComma();
        json.append("\"").append(escapeJson(key)).append("\":").append(value);
        return this;
    }

    /** Add a boolean key-value pair. */
    public JsonResponse put(String key, boolean value) {
        appendComma();
        json.append("\"").append(escapeJson(key)).append("\":").append(value);
        return this;
    }

    /** Add a raw JSON value (pre-formatted array or object). */
    public JsonResponse putRaw(String key, String rawJson) {
        appendComma();
        json.append("\"").append(escapeJson(key)).append("\":");
        json.append(rawJson != null ? rawJson : "null");
        return this;
    }

    /** Start a nested JSON object for the given key. Returns this for chaining. */
    public JsonResponse startObject(String key) {
        appendComma();
        json.append("\"").append(escapeJson(key)).append("\":{");
        hasFields = false;
        return this;
    }

    /** End a nested JSON object. */
    public JsonResponse endObject() {
        json.append("}");
        hasFields = true;
        return this;
    }

    /** Start a JSON array for the given key. */
    public JsonResponse startArray(String key) {
        appendComma();
        json.append("\"").append(escapeJson(key)).append("\":[");
        hasFields = false;
        return this;
    }

    /** Append a raw JSON element to current array. */
    public JsonResponse arrayElement(String rawJson) {
        if (hasFields) json.append(",");
        json.append(rawJson);
        hasFields = true;
        return this;
    }

    /** End a JSON array. */
    public JsonResponse endArray() {
        json.append("]");
        hasFields = true;
        return this;
    }

    // ========================
    // OUTPUT
    // ========================

    /** Build the final JSON string. */
    public String build() {
        return json.toString() + "}";
    }

    /** Send the response to the client. */
    public void send(HttpServletResponse response) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(build());
            out.flush();
        }
    }

    // ========================
    // INTERNAL
    // ========================

    private void appendComma() {
        if (hasFields) {
            json.append(",");
        }
        hasFields = true;
    }

    private static String escapeJson(String value) {
        if (value == null) return "";
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
