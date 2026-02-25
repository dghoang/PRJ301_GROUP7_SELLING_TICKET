package com.sellingticket.controller;

import com.sellingticket.model.Media;
import com.sellingticket.model.User;
import com.sellingticket.service.MediaService;
import java.io.IOException;
import java.io.PrintWriter;
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
 * MediaUploadServlet — Handles multipart file uploads to Cloudinary.
 *
 * POST /media/upload
 *   Parameters:
 *     - file          (Part)    : The file to upload
 *     - entityType    (String)  : "user", "event", "ticket_type"
 *     - entityId      (int)     : ID of the parent entity
 *     - purpose       (String)  : "avatar", "banner", "gallery", "inline", "ticket_design"
 *     - altText       (String)  : Optional accessibility text
 *
 *   Response: JSON
 *     Success: {"success": true, "mediaId": 1, "url": "https://..."}
 *     Error:   {"success": false, "error": "message"}
 *
 * DELETE /media/upload?mediaId=123
 *   Response: JSON
 *     Success: {"success": true}
 *     Error:   {"success": false, "error": "message"}
 */
@WebServlet(name = "MediaUploadServlet", urlPatterns = {"/media/upload"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1MB in memory
    maxFileSize       = 52_428_800,         // 50MB per file
    maxRequestSize    = 52_428_800 + 1024   // 50MB + form fields
)
public class MediaUploadServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MediaUploadServlet.class.getName());
    private MediaService mediaService;

    @Override
    public void init() throws ServletException {
        mediaService = new MediaService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // Auth check
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"error\":\"Unauthorized\"}");
            return;
        }

        try {
            // Get file part
            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"error\":\"No file provided\"}");
                return;
            }

            // Get parameters
            String entityType = request.getParameter("entityType");
            String entityIdStr = request.getParameter("entityId");
            String purpose = request.getParameter("purpose");
            String altText = request.getParameter("altText");

            if (entityType == null || entityIdStr == null || purpose == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"error\":\"Missing required parameters: entityType, entityId, purpose\"}");
                return;
            }

            int entityId = Integer.parseInt(entityIdStr);

            // Read file bytes
            byte[] fileBytes = filePart.getInputStream().readAllBytes();
            String fileName = extractFileName(filePart);
            String mimeType = filePart.getContentType();

            // Upload via service
            Media media = mediaService.uploadMedia(
                    fileBytes, fileName, mimeType,
                    entityType, entityId, purpose,
                    user.getUserId(), altText
            );

            if (media != null) {
                out.print("{\"success\":true,\"mediaId\":" + media.getMediaId() +
                          ",\"url\":\"" + escapeJson(media.getCloudinaryUrl()) + "\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"error\":\"Upload failed. Check file type/size limits.\"}");
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Invalid entityId\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Upload failed", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"error\":\"Server error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // Auth check
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"error\":\"Unauthorized\"}");
            return;
        }

        try {
            String mediaIdStr = request.getParameter("mediaId");
            if (mediaIdStr == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"error\":\"Missing mediaId\"}");
                return;
            }

            int mediaId = Integer.parseInt(mediaIdStr);
            boolean deleted = mediaService.deleteMedia(mediaId, user.getUserId());

            if (deleted) {
                out.print("{\"success\":true}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"error\":\"Media not found or already deleted\"}");
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Invalid mediaId\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Delete failed", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"error\":\"Server error\"}");
        }
    }

    /**
     * Extract file name from the Content-Disposition header of a Part.
     */
    private String extractFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header != null) {
            for (String token : header.split(";")) {
                if (token.trim().startsWith("filename")) {
                    String name = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                    // Handle browser quirks (IE sends full path)
                    int lastSlash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
                    return lastSlash >= 0 ? name.substring(lastSlash + 1) : name;
                }
            }
        }
        return "unknown";
    }

    /**
     * Simple JSON string escaper.
     */
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\").replace("\"", "\\\"")
                   .replace("\n", "\\n").replace("\r", "\\r");
    }
}
