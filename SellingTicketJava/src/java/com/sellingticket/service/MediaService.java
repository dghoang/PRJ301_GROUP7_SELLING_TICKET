package com.sellingticket.service;

import com.sellingticket.dao.MediaDAO;
import com.sellingticket.model.Media;
import com.sellingticket.util.CloudinaryUtil;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * MediaService — Business logic for media upload, retrieval, and deletion.
 * Handles validation, Cloudinary interaction, and DB persistence.
 */
public class MediaService {

    private final MediaDAO mediaDAO;
    private final CloudinaryUtil cloudinaryUtil;

    private static final int MAX_FILE_SIZE = 52_428_800; // 50MB
    private static final int MAX_AVATAR_SIZE = 5_242_880; // 5MB
    private static final int MAX_IMAGES_PER_EVENT = 10;

    private static final List<String> ALLOWED_IMAGE_TYPES = Arrays.asList(
            "image/jpeg", "image/png", "image/webp", "image/gif"
    );
    private static final List<String> ALLOWED_VIDEO_TYPES = Arrays.asList(
            "video/mp4", "video/webm"
    );

    public MediaService() {
        this.mediaDAO = new MediaDAO();
        this.cloudinaryUtil = CloudinaryUtil.getInstance();
    }

    // ========================
    // UPLOAD
    // ========================

    /**
     * Upload media file: validate → upload to Cloudinary → save to DB.
     *
     * @param fileBytes   File content
     * @param fileName    Original file name
     * @param mimeType    MIME type (e.g., "image/jpeg")
     * @param entityType  "user", "event", or "ticket_type"
     * @param entityId    ID of the parent entity
     * @param purpose     "avatar", "banner", "gallery", "inline", "ticket_design"
     * @param uploaderId  User performing the upload
     * @param altText     Accessibility text (optional)
     * @return The saved Media object, or null on failure
     */
    public Media uploadMedia(byte[] fileBytes, String fileName, String mimeType,
                             String entityType, int entityId, String purpose,
                             int uploaderId, String altText) {

        // 1. Validate file type
        String mediaType = resolveMediaType(mimeType);
        if (mediaType == null) {
            System.err.println("[MediaService] Invalid file type: " + mimeType);
            return null;
        }

        // 2. Validate file size
        int maxSize = "avatar".equals(purpose) ? MAX_AVATAR_SIZE : MAX_FILE_SIZE;
        if (fileBytes.length > maxSize) {
            System.err.println("[MediaService] File too large: " + fileBytes.length + " bytes (max: " + maxSize + ")");
            return null;
        }

        // 3. Check image count limit for events
        if ("event".equals(entityType)) {
            int existing = mediaDAO.countByEntity(entityType, entityId);
            if (existing >= MAX_IMAGES_PER_EVENT) {
                System.err.println("[MediaService] Event " + entityId + " already has " + existing + " media files (max: " + MAX_IMAGES_PER_EVENT + ")");
                return null;
            }
        }

        // 4. For avatar/banner, replace existing (delete old one first)
        if ("avatar".equals(purpose) || "banner".equals(purpose)) {
            Media existing = mediaDAO.getSingleByEntityAndPurpose(entityType, entityId, purpose);
            if (existing != null) {
                deleteMedia(existing.getMediaId(), uploaderId);
            }
        }

        // 5. Upload to Cloudinary
        String folder = "ticketbox/" + entityType + "s/" + entityId;
        Map<String, Object> result = cloudinaryUtil.upload(fileBytes, folder, fileName);

        if (result == null) {
            System.err.println("[MediaService] Cloudinary upload failed for: " + fileName);
            return null;
        }

        // 6. Save to DB
        Media media = new Media();
        media.setUploaderId(uploaderId);
        media.setCloudinaryUrl((String) result.get("url"));
        media.setCloudinaryPublicId((String) result.get("public_id"));
        media.setFileName(fileName);
        media.setFileSize(fileBytes.length);
        media.setMediaType(mediaType);
        media.setMimeType(mimeType);
        media.setWidth(toInt(result.get("width")));
        media.setHeight(toInt(result.get("height")));
        media.setEntityType(entityType);
        media.setEntityId(entityId);
        media.setMediaPurpose(purpose);
        media.setDisplayOrder(0);
        media.setAltText(altText);

        int id = mediaDAO.insert(media);
        return id > 0 ? media : null;
    }

    // ========================
    // READ
    // ========================

    /**
     * Get all media for an entity, ordered by display_order.
     */
    public List<Media> getMediaForEntity(String entityType, int entityId) {
        return mediaDAO.getByEntity(entityType, entityId);
    }

    /**
     * Get media filtered by purpose (e.g., only gallery images).
     */
    public List<Media> getMediaByPurpose(String entityType, int entityId, String purpose) {
        return mediaDAO.getByEntityAndPurpose(entityType, entityId, purpose);
    }

    /**
     * Get single media (avatar, banner).
     */
    public Media getSingleMedia(String entityType, int entityId, String purpose) {
        return mediaDAO.getSingleByEntityAndPurpose(entityType, entityId, purpose);
    }

    /**
     * Get media by ID.
     */
    public Media getMediaById(int mediaId) {
        return mediaDAO.getById(mediaId);
    }

    // ========================
    // DELETE
    // ========================

    /**
     * Delete a single media: remove from Cloudinary + DB.
     */
    public boolean deleteMedia(int mediaId, int userId) {
        Media media = mediaDAO.getById(mediaId);
        if (media == null) return false;

        // Delete from Cloudinary
        if (media.getCloudinaryPublicId() != null) {
            cloudinaryUtil.delete(media.getCloudinaryPublicId());
        }

        // Delete from DB
        return mediaDAO.deleteById(mediaId);
    }

    /**
     * Delete all media for an entity (e.g., when deleting an event).
     * Removes from Cloudinary first, then from DB.
     */
    public int deleteAllForEntity(String entityType, int entityId) {
        List<String> publicIds = mediaDAO.getPublicIdsByEntity(entityType, entityId);
        for (String pid : publicIds) {
            if (pid != null) cloudinaryUtil.delete(pid);
        }
        return mediaDAO.deleteByEntity(entityType, entityId);
    }

    // ========================
    // HELPERS
    // ========================

    private String resolveMediaType(String mimeType) {
        if (mimeType == null) return null;
        if (ALLOWED_IMAGE_TYPES.contains(mimeType.toLowerCase())) return "image";
        if (ALLOWED_VIDEO_TYPES.contains(mimeType.toLowerCase())) return "video";
        return null;
    }

    private int toInt(Object value) {
        if (value == null) return 0;
        if (value instanceof Integer) return (Integer) value;
        try { return Integer.parseInt(value.toString()); } catch (Exception e) { return 0; }
    }
}
