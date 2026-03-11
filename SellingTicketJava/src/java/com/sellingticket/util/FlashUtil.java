package com.sellingticket.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * Session-based flash messages — read once then auto-clear.
 *
 * <p>Replaces URL query params (?success=X&amp;error=Y) that leak
 * internal action names to the address bar.
 *
 * <p>Usage in controller:
 * <pre>
 *   FlashUtil.success(request, "Sự kiện đã được duyệt!");
 *   response.sendRedirect(ctx + "/admin/events");
 * </pre>
 *
 * <p>Usage in JSP:
 * <pre>
 *   ${flashSuccess}   — message text (auto-set by FlashUtil.apply)
 *   ${flashError}      — error text
 * </pre>
 */
public final class FlashUtil {

    private static final String SUCCESS_KEY = "_flash_success";
    private static final String ERROR_KEY = "_flash_error";

    private FlashUtil() {}

    /** Store a success message for the next request. */
    public static void success(HttpServletRequest request, String message) {
        request.getSession().setAttribute(SUCCESS_KEY, message);
    }

    /** Store an error message for the next request. */
    public static void error(HttpServletRequest request, String message) {
        request.getSession().setAttribute(ERROR_KEY, message);
    }

    /**
     * Move flash messages from session → request attributes, then clear.
     * Call this at the start of every GET handler (or via a filter).
     */
    public static void apply(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return;

        Object success = session.getAttribute(SUCCESS_KEY);
        if (success != null) {
            request.setAttribute("flashSuccess", success);
            session.removeAttribute(SUCCESS_KEY);
        }

        Object error = session.getAttribute(ERROR_KEY);
        if (error != null) {
            request.setAttribute("flashError", error);
            session.removeAttribute(ERROR_KEY);
        }
    }
}
