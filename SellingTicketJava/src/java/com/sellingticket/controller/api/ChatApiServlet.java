package com.sellingticket.controller.api;

import com.sellingticket.model.ChatMessage;
import com.sellingticket.model.ChatSession;
import com.sellingticket.model.User;
import com.sellingticket.service.ChatService;
import com.sellingticket.service.ChatService.ChatSessionResult;
import static com.sellingticket.util.ServletUtil.sendJson;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * JSON API for live chat (AJAX polling) with anti-spam + cursor pagination.
 *
 * POST /api/chat/start        → create/resume session (anti-spam gated)
 * POST /api/chat/send         → send message (active sessions only, ≤500 chars)
 * GET  /api/chat/messages     → ?sessionId=X&after=Y → poll new messages (TOP 50)
 * GET  /api/chat/history      → ?sessionId=X&before=Y&limit=30 → load older messages
 * GET  /api/chat/sessions     → ?type=system|event → list sessions (VIP-sorted)
 * POST /api/chat/accept       → agent accepts waiting session
 * POST /api/chat/close        → close session
 */
@WebServlet(name = "ChatApiServlet", urlPatterns = {"/api/chat/*"})
public class ChatApiServlet extends HttpServlet {

    private final ChatService chatService = new ChatService();
    private final SimpleDateFormat sdf = new SimpleDateFormat("dd/MM HH:mm");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) { sendJson(response, 401, "{\"error\":\"Unauthorized\"}"); return; }

        boolean isAgent = "admin".equals(user.getRole()) || "support_agent".equals(user.getRole());
        String path = request.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/messages": {
                int sessionId = parseInt(request.getParameter("sessionId"), 0);
                if (!canAccessSession(sessionId, user, isAgent)) {
                    sendJson(response, 403, "{\"error\":\"Forbidden\"}"); return;
                }
                int after = parseInt(request.getParameter("after"), 0);
                List<ChatMessage> msgs = after > 0
                    ? chatService.getMessages(sessionId, after)
                    : chatService.getRecentMessages(sessionId, 30);
                sendJson(response, buildMessagesJson(msgs));
                break;
            }
            case "/history": {
                int sessionId = parseInt(request.getParameter("sessionId"), 0);
                if (!canAccessSession(sessionId, user, isAgent)) {
                    sendJson(response, 403, "{\"error\":\"Forbidden\"}"); return;
                }
                int before = parseInt(request.getParameter("before"), Integer.MAX_VALUE);
                int limit = parseInt(request.getParameter("limit"), 30);
                List<ChatMessage> msgs = chatService.getHistory(sessionId, before, limit);
                sendJson(response, buildMessagesJson(msgs));
                break;
            }
            case "/sessions": {
                String type = request.getParameter("type");
                if ("my-events".equals(type)) {
                    // Organizer/staff: get sessions for their events
                    List<ChatSession> sessions = chatService.getSessionsByOrganizer(user.getUserId());
                    sendJson(response, buildSessionsJson(sessions));
                } else {
                    if (!isAgent) { sendJson(response, 403, "{\"error\":\"Forbidden\"}"); return; }
                    List<ChatSession> sessions = chatService.getActiveSessions(type);
                    sendJson(response, buildSessionsJson(sessions));
                }
                break;
            }
            default:
                sendJson(response, 404, "{\"error\":\"Not found\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) { sendJson(response, 401, "{\"error\":\"Unauthorized\"}"); return; }

        boolean isAgent = "admin".equals(user.getRole()) || "support_agent".equals(user.getRole());
        String path = request.getPathInfo();
        if (path == null) path = "/";

        switch (path) {
            case "/start": {
                String eventIdStr = request.getParameter("eventId");
                Integer eventId = eventIdStr != null && !eventIdStr.isEmpty() ? parseInt(eventIdStr, null) : null;
                ChatSessionResult result = chatService.getOrCreateSession(user.getUserId(), eventId);
                if (result.isBlocked()) {
                    String json = "{\"blocked\":true,\"reason\":\"" + result.blockedReason + "\"";
                    if (result.retryAfterMinutes > 0) json += ",\"retryAfter\":" + result.retryAfterMinutes;
                    sendJson(response, 429, json + "}");
                } else if (result.session != null) {
                    sendJson(response, "{\"sessionId\":" + result.session.getSessionId()
                        + ",\"status\":\"" + result.session.getStatus() + "\"}");
                } else {
                    sendJson(response, 500, "{\"error\":\"Failed to create session\"}");
                }
                break;
            }
            case "/send": {
                int sessionId = parseInt(request.getParameter("sessionId"), 0);
                if (!canAccessSession(sessionId, user, isAgent)) {
                    sendJson(response, 403, "{\"error\":\"Forbidden\"}"); return;
                }
                String content = request.getParameter("content");
                if (sessionId <= 0 || content == null || content.trim().isEmpty()) {
                    sendJson(response, 400, "{\"error\":\"Invalid input\"}");
                    break;
                }
                // Truncate to 500 chars
                String trimmed = content.trim();
                if (trimmed.length() > 500) trimmed = trimmed.substring(0, 500);
                boolean ok = chatService.sendMessage(sessionId, user.getUserId(), trimmed);
                if (ok) {
                    sendJson(response, "{\"ok\":true}");
                } else {
                    sendJson(response, 403, "{\"error\":\"Phiên chat đã đóng hoặc không tồn tại.\"}");
                }
                break;
            }
            case "/accept": {
                if (!isAgent && !chatService.isOrganizerOfSession(parseInt(request.getParameter("sessionId"), 0), user.getUserId())) {
                    sendJson(response, 403, "{\"error\":\"Forbidden\"}"); return;
                }
                int sessionId = parseInt(request.getParameter("sessionId"), 0);
                boolean ok = chatService.acceptSession(sessionId, user.getUserId());
                sendJson(response, ok ? "{\"ok\":true}" : "{\"error\":\"Failed\"}");
                break;
            }
            case "/close": {
                int sessionId = parseInt(request.getParameter("sessionId"), 0);
                if (!isAgent && !chatService.isOrganizerOfSession(sessionId, user.getUserId())) {
                    sendJson(response, 403, "{\"error\":\"Forbidden\"}"); return;
                }
                boolean ok = chatService.closeSession(sessionId);
                sendJson(response, ok ? "{\"ok\":true}" : "{\"error\":\"Failed\"}");
                break;
            }
            default:
                sendJson(response, 404, "{\"error\":\"Not found\"}");
        }
    }

    private boolean canAccessSession(int sessionId, User user, boolean isAgent) {
        if (isAgent) return true;
        if (isOwner(sessionId, user.getUserId())) return true;
        return chatService.isOrganizerOfSession(sessionId, user.getUserId());
    }

    private boolean isOwner(int sessionId, int userId) {
        ChatSession s = chatService.getSession(sessionId);
        return s != null && s.getCustomerId() == userId;
    }

    private String buildMessagesJson(List<ChatMessage> msgs) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < msgs.size(); i++) {
            if (i > 0) sb.append(",");
            ChatMessage m = msgs.get(i);
            sb.append("{\"id\":").append(m.getMessageId())
              .append(",\"senderId\":").append(m.getSenderId())
              .append(",\"senderName\":\"").append(esc(m.getSenderName())).append("\"")
              .append(",\"senderRole\":\"").append(esc(m.getSenderRole())).append("\"")
              .append(",\"content\":\"").append(esc(m.getContent())).append("\"")
              .append(",\"time\":\"").append(sdf.format(m.getCreatedAt())).append("\"}");
        }
        return sb.append("]").toString();
    }

    private String buildSessionsJson(List<ChatSession> sessions) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < sessions.size(); i++) {
            if (i > 0) sb.append(",");
            ChatSession s = sessions.get(i);
            sb.append("{\"id\":").append(s.getSessionId())
              .append(",\"customerName\":\"").append(esc(s.getCustomerName())).append("\"")
              .append(",\"status\":\"").append(s.getStatus()).append("\"")
              .append(",\"eventTitle\":\"").append(s.getEventTitle() != null ? esc(s.getEventTitle()) : "").append("\"")
              .append(",\"tier\":\"").append(s.getCustomerTier() != null ? s.getCustomerTier() : "registered").append("\"")
              .append(",\"priorityScore\":").append(s.getPriorityScore())
              .append(",\"time\":\"").append(sdf.format(s.getCreatedAt())).append("\"}");
        }
        return sb.append("]").toString();
    }

    private String esc(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }

    private int parseInt(String s, int def) {
        if (s == null) return def;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return def; }
    }

    private Integer parseInt(String s, Integer def) {
        if (s == null) return def;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return def; }
    }
}
