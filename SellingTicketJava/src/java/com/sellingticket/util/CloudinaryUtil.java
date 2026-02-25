package com.sellingticket.util;

import java.io.InputStream;
import java.util.Map;
import java.util.Properties;

/**
 * CloudinaryUtil — Wrapper for Cloudinary SDK.
 *
 * SETUP REQUIRED:
 * 1. Download cloudinary-core-1.37.0.jar + cloudinary-http45-1.37.0.jar
 * 2. Add to project Libraries in NetBeans
 * 3. Create WEB-INF/cloudinary.properties with your credentials:
 *    cloudinary.cloud_name=your_cloud_name
 *    cloudinary.api_key=your_api_key
 *    cloudinary.api_secret=your_api_secret
 *
 * NOTE: This is a framework-ready wrapper. When Cloudinary JARs are added,
 * uncomment the Cloudinary SDK imports and implementation sections.
 */
public class CloudinaryUtil {

    private static CloudinaryUtil instance;
    private String cloudName;
    private String apiKey;
    private String apiSecret;
    // Uncomment when Cloudinary JAR is added:
    // private com.cloudinary.Cloudinary cloudinary;

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
                this.cloudName = props.getProperty("cloudinary.cloud_name", "");
                this.apiKey = props.getProperty("cloudinary.api_key", "");
                this.apiSecret = props.getProperty("cloudinary.api_secret", "");

                // Uncomment when Cloudinary JAR is added:
                // Map<String, String> config = new HashMap<>();
                // config.put("cloud_name", cloudName);
                // config.put("api_key", apiKey);
                // config.put("api_secret", apiSecret);
                // config.put("secure", "true");
                // this.cloudinary = new com.cloudinary.Cloudinary(config);
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
    public Map<String, Object> upload(byte[] fileBytes, String folder, String fileName) {
        // Uncomment when Cloudinary JAR is added:
        // try {
        //     Map<String, Object> options = new HashMap<>();
        //     options.put("folder", folder);
        //     options.put("resource_type", "auto");
        //     options.put("quality", "auto");
        //     options.put("fetch_format", "auto");
        //
        //     Map result = cloudinary.uploader().upload(fileBytes, options);
        //
        //     Map<String, Object> response = new HashMap<>();
        //     response.put("url", result.get("secure_url"));
        //     response.put("public_id", result.get("public_id"));
        //     response.put("width", result.get("width"));
        //     response.put("height", result.get("height"));
        //     response.put("bytes", result.get("bytes"));
        //     response.put("format", result.get("format"));
        //     return response;
        // } catch (Exception e) {
        //     System.err.println("[CloudinaryUtil] Upload failed: " + e.getMessage());
        //     return null;
        // }

        // Placeholder: return null until Cloudinary JAR is configured
        System.err.println("[CloudinaryUtil] Upload skipped — Cloudinary JAR not configured.");
        return null;
    }

    /**
     * Delete a file from Cloudinary by its public_id.
     * @return true if deletion was successful
     */
    public boolean delete(String publicId) {
        // Uncomment when Cloudinary JAR is added:
        // try {
        //     Map result = cloudinary.uploader().destroy(publicId, new HashMap<>());
        //     return "ok".equals(result.get("result"));
        // } catch (Exception e) {
        //     System.err.println("[CloudinaryUtil] Delete failed: " + e.getMessage());
        //     return false;
        // }

        System.err.println("[CloudinaryUtil] Delete skipped — Cloudinary JAR not configured.");
        return false;
    }

    /**
     * Build a transformed Cloudinary URL from the original URL.
     * Inserts transformation params after "/upload/" in the URL.
     *
     * Example:
     *   Original:  https://res.cloudinary.com/demo/image/upload/v1/events/banner.jpg
     *   transform: c_fill,w_400,h_225,q_auto,f_auto
     *   Result:    https://res.cloudinary.com/demo/image/upload/c_fill,w_400,h_225,q_auto,f_auto/v1/events/banner.jpg
     *
     * @param originalUrl The original Cloudinary URL
     * @param width       Target width
     * @param height      Target height (0 = auto)
     * @return Transformed URL string
     */
    public static String transformUrl(String originalUrl, int width, int height) {
        if (originalUrl == null || originalUrl.isEmpty()) return originalUrl;
        if (!originalUrl.contains("/upload/")) return originalUrl;

        StringBuilder transform = new StringBuilder("c_fill,w_").append(width);
        if (height > 0) transform.append(",h_").append(height);
        transform.append(",q_auto,f_auto");

        return originalUrl.replace("/upload/", "/upload/" + transform + "/");
    }

    /**
     * Build a thumbnail URL (400x225, card size).
     */
    public static String thumbnailUrl(String originalUrl) {
        return transformUrl(originalUrl, 400, 225);
    }

    /**
     * Build a banner URL (1200px width, auto height).
     */
    public static String bannerUrl(String originalUrl) {
        return transformUrl(originalUrl, 1200, 0);
    }

    /**
     * Build an avatar URL (150x150 circle crop).
     */
    public static String avatarUrl(String originalUrl) {
        if (originalUrl == null || originalUrl.isEmpty()) return originalUrl;
        if (!originalUrl.contains("/upload/")) return originalUrl;
        return originalUrl.replace("/upload/", "/upload/c_fill,w_150,h_150,g_face,q_auto,f_auto/");
    }

    public String getCloudName() { return cloudName; }
}
