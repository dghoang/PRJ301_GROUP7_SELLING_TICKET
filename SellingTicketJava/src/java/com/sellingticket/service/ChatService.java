package com.sellingticket.service;

import com.sellingticket.dao.ChatDAO;
import com.sellingticket.model.ChatMessage;
import com.sellingticket.model.ChatSession;

import java.util.List;

public class ChatService {

    private final ChatDAO dao = new ChatDAO();

    /**
     * Get or create a chat session with anti-spam checks.
     * Returns null and sets reason if blocked.
     */
    public ChatSessionResult getOrCreateSession(int customerId, Integer eventId) {
        // Check: already has an active/waiting session
        if (dao.countActiveSessionsByCustomer(customerId) > 0) {
            ChatSession existing = dao.findActiveSession(customerId, eventId);
            if (existing != null) {
                return new ChatSessionResult(existing, null);
            }
            return new ChatSessionResult(null, "active_session_exists");
        }

        // Check: cooldown after last closed session
        int cooldownRemaining = dao.getCooldownMinutesRemaining(customerId);
        if (cooldownRemaining > 0) {
            ChatSessionResult result = new ChatSessionResult(null, "cooldown");
            result.retryAfterMinutes = cooldownRemaining;
            return result;
        }

        // Create new session (starts as 'waiting')
        int id = dao.createSession(customerId, eventId);
        if (id > 0) {
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
