package com.sellingticket.controller.api;

import com.sellingticket.service.UserService;
import com.sellingticket.util.JsonResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Public endpoint to check if an email is already registered.
 * GET /api/auth/check-email?email=user@example.com
 */
@WebServlet(name = "EmailAvailabilityApiServlet", urlPatterns = {"/api/auth/check-email"})
public class EmailAvailabilityApiServlet extends HttpServlet {

    private static final int MAX_EMAIL_LENGTH = 255;
    private static final long CACHE_TTL_MS = 2 * 60 * 1000;
    private static final int MAX_CACHE_SIZE = 2048;
    private static final Map<String, CacheEntry> CACHE = new ConcurrentHashMap<>();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String rawEmail = request.getParameter("email");
        if (rawEmail == null || rawEmail.trim().isEmpty()) {
            JsonResponse.ok()
                    .put("valid", false)
                    .put("exists", false)
                    .put("message", "Vui lòng nhập email")
                    .send(response);
            return;
        }

        String email = rawEmail.trim().toLowerCase();
        boolean formatValid = isValidEmail(email);
        if (!formatValid) {
            JsonResponse.ok()
                    .put("valid", false)
                    .put("exists", false)
                    .put("message", "Email không hợp lệ")
                    .send(response);
            return;
        }

        CacheEntry cached = getCached(email);
        if (cached != null) {
            response.setHeader("X-Email-Check-Cache", "HIT");
            JsonResponse.ok()
                    .put("valid", true)
                    .put("exists", cached.exists)
                    .put("message", cached.message)
                    .send(response);
            return;
        }

        boolean exists = userService.isEmailExists(email);
        String message = exists ? "Email đã tồn tại" : "Email có thể sử dụng";
        cache(email, exists, message);

        response.setHeader("X-Email-Check-Cache", "MISS");
        JsonResponse.ok()
                .put("valid", true)
                .put("exists", exists)
                .put("message", message)
                .send(response);
    }

    private static CacheEntry getCached(String email) {
        CacheEntry entry = CACHE.get(email);
        if (entry == null) {
            return null;
        }
        if (System.currentTimeMillis() > entry.expiresAt) {
            CACHE.remove(email);
            return null;
        }
        return entry;
    }

    private static void cache(String email, boolean exists, String message) {
        CACHE.put(email, new CacheEntry(exists, message, System.currentTimeMillis() + CACHE_TTL_MS));

        if (CACHE.size() <= MAX_CACHE_SIZE) {
            return;
        }

        // Remove expired entries first.
        long now = System.currentTimeMillis();
        for (Map.Entry<String, CacheEntry> e : CACHE.entrySet()) {
            if (now > e.getValue().expiresAt) {
                CACHE.remove(e.getKey());
            }
        }

        // Still too large: remove a few oldest-like arbitrary keys to keep memory bounded.
        if (CACHE.size() > MAX_CACHE_SIZE) {
            int removeCount = CACHE.size() - MAX_CACHE_SIZE;
            for (String key : CACHE.keySet()) {
                CACHE.remove(key);
                if (--removeCount <= 0) {
                    break;
                }
            }
        }
    }

    private boolean isValidEmail(String email) {
        if (email == null || email.isEmpty() || email.length() > MAX_EMAIL_LENGTH) {
            return false;
        }
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    private static final class CacheEntry {
        private final boolean exists;
        private final String message;
        private final long expiresAt;

        private CacheEntry(boolean exists, String message, long expiresAt) {
            this.exists = exists;
            this.message = message;
            this.expiresAt = expiresAt;
        }
    }
}
