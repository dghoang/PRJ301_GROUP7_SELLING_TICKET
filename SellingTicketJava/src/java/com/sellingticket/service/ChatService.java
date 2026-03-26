package com.sellingticket.service;

import com.sellingticket.dao.ChatDAO;
import com.sellingticket.dao.SiteSettingsDAO;
import com.sellingticket.model.ChatMessage;
import com.sellingticket.model.ChatSession;
import java.util.List;

public class ChatService {

    private final ChatDAO dao = new ChatDAO();
    private final SiteSettingsDAO settingsDAO = new SiteSettingsDAO();

    /** Check if chat feature is enabled globally by admin. */
    public boolean isChatEnabled() {
        return settingsDAO.getBoolean("chat_enabled", true);
    }

    /** Check if sessions should be auto-accepted (no waiting for agent). */
    public boolean isAutoAcceptEnabled() {
        return settingsDAO.getBoolean("chat_auto_accept", true);
    }

    /**
     * Get or create a chat session with anti-spam checks.
     * If auto_accept is enabled, sessions start as 'active' immediately.
     */
    public ChatSessionResult getOrCreateSession(int customerId, Integer eventId) {
        if (!isChatEnabled()) {
            return new ChatSessionResult(null, "chat_disabled");
        }

        // Check: already has an active/waiting session
        if (dao.countActiveSessionsByCustomer(customerId) > 0) {
            ChatSession existing = dao.findActiveSession(customerId, eventId);
            if (existing != null) {
                return new ChatSessionResult(existing, null);
            }
            return new ChatSessionResult(null, "active_session_exists");
        }

        // Check: cooldown after last closed session
        int cooldownMinutes = settingsDAO.getInt("chat_cooldown_minutes", 30);
        int cooldownRemaining = dao.getCooldownMinutesRemaining(customerId, cooldownMinutes);
        if (cooldownRemaining > 0) {
            ChatSessionResult result = new ChatSessionResult(null, "cooldown");
            result.retryAfterMinutes = cooldownRemaining;
            return result;
        }

        // Create new session
        int id = dao.createSession(customerId, eventId);
        if (id > 0) {
            // Auto-accept: set session to 'active' immediately
            if (isAutoAcceptEnabled()) {
                dao.autoActivateSession(id);
            }
            return new ChatSessionResult(dao.getSession(id), null);
        }
        return new ChatSessionResult(null, "create_failed");
    }

    public ChatSession getSession(int sessionId) {
        return dao.getSession(sessionId);
    }

    public boolean sendMessage(int sessionId, int senderId, String content) {
        return dao.sendMessage(sessionId, senderId, content);
    }

    public List<ChatMessage> getMessages(int sessionId, int afterMessageId) {
        return dao.getMessages(sessionId, afterMessageId);
    }

    public List<ChatMessage> getRecentMessages(int sessionId, int limit) {
        return dao.getRecentMessages(sessionId, limit);
    }

    public List<ChatMessage> getHistory(int sessionId, int beforeMessageId, int limit) {
        return dao.getHistory(sessionId, beforeMessageId, limit);
    }

    public List<ChatSession> getActiveSessions(String type) {
        return dao.getActiveSessions(type);
    }

    public boolean acceptSession(int sessionId, int agentId) {
        return dao.acceptSession(sessionId, agentId);
    }

    public boolean closeSession(int sessionId) {
        return dao.closeSession(sessionId);
    }

    public List<ChatSession> getSessionsByOrganizer(int userId) {
        return dao.getSessionsByOrganizer(userId);
    }

    public boolean isOrganizerOfSession(int sessionId, int userId) {
        return dao.isOrganizerOfSession(sessionId, userId);
    }

    /** Global count of active chat sessions. */
    public int countActiveSessions() {
        return dao.countActiveSessions();
    }

    /** Global count of waiting (unassigned) chat sessions. */
    public int countWaitingSessions() {
        return dao.countWaitingSessions();
    }

    /** Result wrapper for session creation with anti-spam info. */
    public static class ChatSessionResult {
        public final ChatSession session;
        public final String blockedReason; // null = success
        public int retryAfterMinutes;

        public ChatSessionResult(ChatSession session, String blockedReason) {
            this.session = session;
            this.blockedReason = blockedReason;
        }

        public boolean isBlocked() { return blockedReason != null && session == null; }
    }
}
