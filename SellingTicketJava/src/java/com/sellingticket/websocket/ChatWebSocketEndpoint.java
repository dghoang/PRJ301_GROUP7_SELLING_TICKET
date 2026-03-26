package com.sellingticket.websocket;

import com.sellingticket.model.User;

import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

/**
 * WebSocket endpoint for real-time chat.
 * Clients connect to: ws://host/SellingTicketJava/ws/chat/{sessionId}
 *
 * Once connected, messages sent via the REST API (/api/chat/send) will also
 * be broadcast to all WebSocket subscribers of that chat session through
 * {@link #broadcast(int, String)}.
 *
 * Client → Server text messages are echoed as JSON to all peers in the room
 * after being persisted via ChatService.
 */
@ServerEndpoint(value = "/ws/chat/{sessionId}", configurator = ChatWebSocketConfigurator.class)
public class ChatWebSocketEndpoint {

    private static final Logger LOGGER = Logger.getLogger(ChatWebSocketEndpoint.class.getName());

    /** Map of chatSessionId → set of WebSocket sessions in that room. */
    private static final Map<Integer, Set<Session>> ROOMS = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session, @PathParam("sessionId") int sessionId) {
        User user = (User) session.getUserProperties().get("user");
        if (user == null) {
            closeQuietly(session, CloseReason.CloseCodes.VIOLATED_POLICY, "Unauthorized");
            return;
        }
        session.getUserProperties().put("chatSessionId", sessionId);
        session.getUserProperties().put("userId", user.getUserId());
        ROOMS.computeIfAbsent(sessionId, k -> new CopyOnWriteArraySet<>()).add(session);
        LOGGER.log(Level.FINE, "WS opened: user={0} session={1}", new Object[]{user.getUserId(), sessionId});
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        // Client-side sends are handled via REST /api/chat/send which calls broadcast().
        // This handler is a no-op for now but can be extended for typing indicators.
        Integer chatSessionId = (Integer) session.getUserProperties().get("chatSessionId");
        if (chatSessionId == null) return;

        // Broadcast typing indicator or heartbeat
        if ("ping".equals(message)) {
            sendQuietly(session, "{\"type\":\"pong\"}");
        }
    }

    @OnClose
    public void onClose(Session session) {
        removeFromRoom(session);
    }

    @OnError
    public void onError(Session session, Throwable error) {
        LOGGER.log(Level.WARNING, "WS error: " + error.getMessage());
        removeFromRoom(session);
    }

    // ========================
    // PUBLIC STATIC API
    // ========================

    /**
     * Broadcast a JSON message to all WebSocket clients in a chat room.
     * Called from ChatApiServlet after a message is persisted.
     */
    public static void broadcast(int chatSessionId, String json) {
        Set<Session> peers = ROOMS.get(chatSessionId);
        if (peers == null || peers.isEmpty()) return;
        for (Session s : peers) {
            if (s.isOpen()) {
                sendQuietly(s, json);
            }
        }
    }

    /**
     * Notify all connected clients that sessions list has changed
     * (new session created, session accepted, session closed).
     */
    public static void broadcastSessionUpdate() {
        String payload = "{\"type\":\"session_update\"}";
        for (Map.Entry<Integer, Set<Session>> entry : ROOMS.entrySet()) {
            for (Session s : entry.getValue()) {
                if (s.isOpen()) sendQuietly(s, payload);
            }
        }
    }

    // ========================
    // HELPERS
    // ========================

    private void removeFromRoom(Session session) {
        Integer chatSessionId = (Integer) session.getUserProperties().get("chatSessionId");
        if (chatSessionId != null) {
            Set<Session> peers = ROOMS.get(chatSessionId);
            if (peers != null) {
                peers.remove(session);
                if (peers.isEmpty()) ROOMS.remove(chatSessionId);
            }
        }
    }

    private static void sendQuietly(Session session, String text) {
        try {
            session.getBasicRemote().sendText(text);
        } catch (IOException e) {
            LOGGER.log(Level.FINE, "WS send failed", e);
        }
    }

    private void closeQuietly(Session session, CloseReason.CloseCode code, String reason) {
        try {
            session.close(new CloseReason(code, reason));
        } catch (IOException e) {
            LOGGER.log(Level.FINE, "WS close failed", e);
        }
    }
}
