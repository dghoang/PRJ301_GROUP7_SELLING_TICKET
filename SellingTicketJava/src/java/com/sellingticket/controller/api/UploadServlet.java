package com.sellingticket.controller.api;

import com.sellingticket.model.User;
import com.sellingticket.util.CloudinaryUtil;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

/**
 * UploadServlet — Secure server-side file upload to Cloudinary.
 *
 * URL: POST /api/upload
 * Auth: Requires logged-in user
 * Params:
 *   - file: the uploaded file (multipart)
 *   - folder: Cloudinary folder (e.g., "ticketbox/events/5")
 *
 * Response JSON: {"url":"...","publicId":"..."} or {"error":"..."}
 */
@WebServlet(name = "UploadServlet", urlPatterns = {"/api/upload"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,     // 1 MB
    maxFileSize       = 10 * 1024 * 1024, // 10 MB
    maxRequestSize    = 12 * 1024 * 1024  // 12 MB
)
public class UploadServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UploadServlet.class.getName());

    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final String[] ALLOWED_IMAGE_TYPES = {
        "image/jpeg", "image/png", "image/gif", "image/webp"
    };
    private static final String[] ALLOWED_VIDEO_TYPES = {
        "video/mp4", "video/webm"
    };
    /** Whitelist of allowed Cloudinary folder prefixes to prevent path traversal. */
    private static final Set<String> ALLOWED_FOLDER_PREFIXES = Set.of(
        "ticketbox/events", "ticketbox/users", "ticketbox/uploads",
        "ticketbox/categories", "ticketbox/banners"
    );

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Auth check
        User user = getSessionUser(request);
        if (user == null) {
            response.setStatus(401);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        // Cloudinary check
        CloudinaryUtil cloudinary = CloudinaryUtil.getInstance();
        if (!cloudinary.isConfigured()) {
            response.setStatus(500);
            response.getWriter().write("{\"error\":\"Cloudinary not configured\"}");
            return;
        }

        try {
            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                response.setStatus(400);
                response.getWriter().write("{\"error\":\"No file uploaded\"}");
                return;
            }

            // Validate file size
            if (filePart.getSize() > MAX_FILE_SIZE) {
                response.setStatus(400);
                response.getWriter().write("{\"error\":\"File too large (max 10MB)\"}");
                return;
            }

            // Validate content type
            String contentType = filePart.getContentType();
            if (!isAllowedType(contentType)) {
                response.setStatus(400);
                response.getWriter().write("{\"error\":\"File type not allowed: " + contentType + "\"}");
                return;
            }

            // Get folder param (default: ticketbox/uploads)
            String folder = request.getParameter("folder");
            if (folder == null || folder.isEmpty()) {
                folder = "ticketbox/uploads";
            }

            // ===== SECURITY: Block path traversal and validate folder whitelist =====
            if (folder.contains("..") || folder.contains("\\") || folder.startsWith("/")) {
                LOGGER.log(Level.WARNING, "Upload blocked: path traversal attempt by user {0}, folder={1}",
                        new Object[]{user.getUserId(), folder});
                response.setStatus(400);
                response.getWriter().write("{\"error\":\"Invalid folder path\"}");
                return;
            }
            // Normalize and check against allowed prefixes
            folder = folder.replaceAll("/+", "/").replaceAll("/$", "");
            boolean folderAllowed = false;
            for (String prefix : ALLOWED_FOLDER_PREFIXES) {
                if (folder.equals(prefix) || folder.startsWith(prefix + "/")) {
                    folderAllowed = true;
                    break;
                }
            }
            if (!folderAllowed) {
                LOGGER.log(Level.WARNING, "Upload blocked: unauthorized folder by user {0}, folder={1}",
                        new Object[]{user.getUserId(), folder});
                response.setStatus(403);
                response.getWriter().write("{\"error\":\"Folder not allowed\"}");
                return;
            }

            // Read file bytes
            byte[] fileBytes;
            try (InputStream is = filePart.getInputStream()) {
                fileBytes = is.readAllBytes();
            }

            String fileName = getFileName(filePart);

            // Upload to Cloudinary
            Map<String, Object> result = cloudinary.upload(fileBytes, folder, fileName);
            if (result == null) {
                response.setStatus(500);
                response.getWriter().write("{\"error\":\"Upload failed\"}");
                return;
            }

            String url = (String) result.get("url");
            String publicId = (String) result.get("public_id");

            LOGGER.log(Level.INFO, "Upload success: user={0}, file={1}, url={2}",
                    new Object[]{user.getUserId(), fileName, url});

            response.getWriter().write(String.format(
                "{\"url\":\"%s\",\"publicId\":\"%s\"}",
                escapeJson(url), escapeJson(publicId)
            ));

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Upload error", e);
            response.setStatus(500);
            response.getWriter().write("{\"error\":\"Upload failed: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private boolean isAllowedType(String contentType) {
        if (contentType == null) return false;
        for (String t : ALLOWED_IMAGE_TYPES) if (t.equals(contentType)) return true;
        for (String t : ALLOWED_VIDEO_TYPES) if (t.equals(contentType)) return true;
        return false;
    }

    private String getFileName(Part part) {
        String disposition = part.getHeader("content-disposition");
        if (disposition != null) {
            for (String token : disposition.split(";")) {
                if (token.trim().startsWith("filename")) {
                    return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                }
            }
        }
        return "upload";
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
