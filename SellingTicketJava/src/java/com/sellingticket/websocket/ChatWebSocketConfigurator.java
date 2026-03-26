package com.sellingticket.websocket;

import com.sellingticket.model.User;

import jakarta.servlet.http.HttpSession;
import jakarta.websocket.HandshakeResponse;
import jakarta.websocket.server.HandshakeRequest;
import jakarta.websocket.server.ServerEndpointConfig;

/**
 * Configurator that transfers the HTTP session's User object
 * into the WebSocket session's user properties for auth.
 */
public class ChatWebSocketConfigurator extends ServerEndpointConfig.Configurator {

    @Override
    public void modifyHandshake(ServerEndpointConfig sec,
                                 HandshakeRequest request,
                                 HandshakeResponse response) {
        HttpSession httpSession = (HttpSession) request.getHttpSession();
        if (httpSession != null) {
            Object user = httpSession.getAttribute("user");
            if (user instanceof User) {
                sec.getUserProperties().put("user", user);
            }
        }
    }
}
