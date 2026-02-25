package com.sellingticket.dao;

import com.sellingticket.model.Media;
import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MediaDAO extends DBContext {

    private Media mapResultSet(ResultSet rs) throws SQLException {
        Media media = new Media();
        media.setMediaId(rs.getInt("media_id"));
        media.setUploaderId(rs.getInt("uploader_id"));
        media.setCloudinaryUrl(rs.getString("cloudinary_url"));
        media.setCloudinaryPublicId(rs.getString("cloudinary_public_id"));
        media.setFileName(rs.getString("file_name"));
        media.setFileSize(rs.getInt("file_size"));
        media.setMediaType(rs.getString("media_type"));
        media.setMimeType(rs.getString("mime_type"));
        media.setWidth(rs.getInt("width"));
        media.setHeight(rs.getInt("height"));
        media.setEntityType(rs.getString("entity_type"));
        media.setEntityId(rs.getInt("entity_id"));
        media.setMediaPurpose(rs.getString("media_purpose"));
        media.setDisplayOrder(rs.getInt("display_order"));
        media.setAltText(rs.getString("alt_text"));
        media.setCreatedAt(rs.getTimestamp("created_at"));
        return media;
    }

    /**
     * Insert a new media record. Returns generated media_id.
     */
    public int insert(Media media) {
        String sql = "INSERT INTO Media (uploader_id, cloudinary_url, cloudinary_public_id, " +
                     "file_name, file_size, media_type, mime_type, width, height, " +
                     "entity_type, entity_id, media_purpose, display_order, alt_text) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, media.getUploaderId());
            ps.setString(2, media.getCloudinaryUrl());
            ps.setString(3, media.getCloudinaryPublicId());
            ps.setString(4, media.getFileName());
            ps.setInt(5, media.getFileSize());
            ps.setString(6, media.getMediaType());
            ps.setString(7, media.getMimeType());
            ps.setInt(8, media.getWidth());
            ps.setInt(9, media.getHeight());
            ps.setString(10, media.getEntityType());
            ps.setInt(11, media.getEntityId());
            ps.setString(12, media.getMediaPurpose());
            ps.setInt(13, media.getDisplayOrder());
            ps.setString(14, media.getAltText());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    int id = keys.getInt(1);
                    media.setMediaId(id);
                    return id;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Get a single media by ID.
     */
    public Media getById(int mediaId) {
        String sql = "SELECT * FROM Media WHERE media_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, mediaId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSet(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get all media for an entity (e.g., all images for event #5).
     */
    public List<Media> getByEntity(String entityType, int entityId) {
        List<Media> list = new ArrayList<>();
        String sql = "SELECT * FROM Media WHERE entity_type = ? AND entity_id = ? ORDER BY display_order";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapResultSet(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get media for an entity filtered by purpose (e.g., only 'gallery' images for event #5).
     */
    public List<Media> getByEntityAndPurpose(String entityType, int entityId, String purpose) {
        List<Media> list = new ArrayList<>();
        String sql = "SELECT * FROM Media WHERE entity_type = ? AND entity_id = ? AND media_purpose = ? ORDER BY display_order";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            ps.setString(3, purpose);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapResultSet(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get the single banner/avatar for an entity (returns first match).
     */
    public Media getSingleByEntityAndPurpose(String entityType, int entityId, String purpose) {
        String sql = "SELECT TOP 1 * FROM Media WHERE entity_type = ? AND entity_id = ? AND media_purpose = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            ps.setString(3, purpose);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSet(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Delete a media record by ID.
     */
    public boolean deleteById(int mediaId) {
        String sql = "DELETE FROM Media WHERE media_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, mediaId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Delete all media for an entity (e.g., when deleting an event).
     */
    public int deleteByEntity(String entityType, int entityId) {
        String sql = "DELETE FROM Media WHERE entity_type = ? AND entity_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get all public_ids for an entity (used before bulk delete from Cloudinary).
     */
    public List<String> getPublicIdsByEntity(String entityType, int entityId) {
        List<String> ids = new ArrayList<>();
        String sql = "SELECT cloudinary_public_id FROM Media WHERE entity_type = ? AND entity_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) ids.add(rs.getString("cloudinary_public_id"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ids;
    }

    /**
     * Count media for an entity (limit checks, e.g., max 10 images per event).
     */
    public int countByEntity(String entityType, int entityId) {
        String sql = "SELECT COUNT(*) FROM Media WHERE entity_type = ? AND entity_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
