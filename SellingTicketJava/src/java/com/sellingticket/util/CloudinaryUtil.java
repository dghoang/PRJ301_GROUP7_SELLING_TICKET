package com.sellingticket.util;

import com.cloudinary.Cloudinary;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/**
 * CloudinaryUtil — Wrapper for Cloudinary SDK.
 *
 * SETUP REQUIRED:
 * 1. JARs already in WEB-INF/lib/ (cloudinary-core, cloudinary-http45, httpclient, httpcore, httpmime, commons-*)
 * 2. Create WEB-INF/cloudinary.properties with your credentials:
 *    cloudinary.cloud_name=your_cloud_name
 *    cloudinary.api_key=your_api_key
 *    cloudinary.api_secret=your_api_secret
 */
public class CloudinaryUtil {

    private static CloudinaryUtil instance;
    private Cloudinary cloudinary;
    private boolean configured = false;

    private CloudinaryUtil() {
        loadConfig();
    }

    public static synchronized CloudinaryUtil getInstance() {
        if (instance == null) {
            instance = new CloudinaryUtil();
        }
        return instance;
    }

    private void loadConfig() {
        try (InputStream is = getClass().getClassLoader()
                .getResourceAsStream("cloudinary.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);

                String cloudName = props.getProperty("cloudinary.cloud_name", "");
                String apiKey = props.getProperty("cloudinary.api_key", "");
                String apiSecret = props.getProperty("cloudinary.api_secret", "");

                if (!cloudName.isEmpty() && !cloudName.startsWith("YOUR_")) {
                    Map<String, String> config = new HashMap<>();
                    config.put("cloud_name", cloudName);
                    config.put("api_key", apiKey);
                    config.put("api_secret", apiSecret);
                    config.put("secure", "true");
                    this.cloudinary = new Cloudinary(config);
                    this.configured = true;
                    System.out.println("[CloudinaryUtil] Configured for cloud: " + cloudName);
                } else {
                    System.err.println("[CloudinaryUtil] Properties found but credentials not set. Fill in cloudinary.properties.");
                }
            } else {
                System.err.println("[CloudinaryUtil] cloudinary.properties not found in classpath.");
            }
        } catch (Exception e) {
            System.err.println("[CloudinaryUtil] Failed to load config: " + e.getMessage());
        }
    }

    /**
     * Upload a file to Cloudinary.
     * @param fileBytes     The file content as byte array
     * @param folder        Cloudinary folder (e.g., "ticketbox/events/5")
     * @param fileName      Original file name (for reference)
     * @return Map with keys: "url", "public_id", "width", "height", "bytes", "format"
     *         or null if upload fails
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> upload(byte[] fileBytes, String folder, String fileName) {
        if (!configured) {
            System.err.println("[CloudinaryUtil] Not configured — fill in cloudinary.properties first.");
            return null;
        }
        try {
            Map<String, Object> options = new HashMap<>();
            options.put("folder", folder);
            options.put("resource_type", "auto");

            Map<String, Object> result = cloudinary.uploader().upload(fileBytes, options);

            Map<String, Object> response = new HashMap<>();
            response.put("url", result.get("secure_url"));
            response.put("public_id", result.get("public_id"));
            response.put("width", result.get("width"));
            response.put("height", result.get("height"));
            response.put("bytes", result.get("bytes"));
            response.put("format", result.get("format"));
            return response;
        } catch (Exception e) {
            System.err.println("[CloudinaryUtil] Upload failed: " + e.getMessage());
            return null;
        }
    }

    /**
     * Delete a file from Cloudinary by its public_id.
     * @return true if deletion was successful
     */
    @SuppressWarnings("unchecked")
    public boolean delete(String publicId) {
        if (!configured) return false;
        try {
            Map<String, Object> result = cloudinary.uploader().destroy(publicId, new HashMap<>());
            return "ok".equals(result.get("result"));
        } catch (Exception e) {
            System.err.println("[CloudinaryUtil] Delete failed: " + e.getMessage());
            return false;
        }
    }

    /**
     * Build a transformed Cloudinary URL from the original URL.
     * Inserts transformation params after "/upload/" in the URL.
     */
    public static String transformUrl(String originalUrl, int width, int height) {
        if (originalUrl == null || originalUrl.isEmpty()) return originalUrl;
        if (!originalUrl.contains("/upload/")) return originalUrl;

        StringBuilder transform = new StringBuilder("c_fill,w_").append(width);
        if (height > 0) transform.append(",h_").append(height);
        transform.append(",q_auto,f_auto");

        return originalUrl.replace("/upload/", "/upload/" + transform + "/");
    }

    /** Build a thumbnail URL (400x225, card size). */
    public static String thumbnailUrl(String originalUrl) {
        return transformUrl(originalUrl, 400, 225);
    }

    /** Build a banner URL (1200px width, auto height). */
    public static String bannerUrl(String originalUrl) {
        return transformUrl(originalUrl, 1200, 0);
    }

    /** Build an avatar URL (150x150 face-detect crop). */
    public static String avatarUrl(String originalUrl) {
        if (originalUrl == null || originalUrl.isEmpty()) return originalUrl;
        if (!originalUrl.contains("/upload/")) return originalUrl;
        return originalUrl.replace("/upload/", "/upload/c_fill,w_150,h_150,g_face,q_auto,f_auto/");
    }

    public boolean isConfigured() { return configured; }
}
