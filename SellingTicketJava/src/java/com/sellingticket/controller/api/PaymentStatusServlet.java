package com.sellingticket.controller.api;

import com.sellingticket.model.Order;
import com.sellingticket.model.User;
import com.sellingticket.service.OrderService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * PaymentStatusServlet — JSON API for frontend polling during payment-pending.
 *
 * URL: GET /api/payment/status?orderId=X
 * Response: {"status":"pending|paid|expired","orderId":N}
 *
 * Security: Only the order owner can check status (session-based auth).
 */
@WebServlet(name = "PaymentStatusServlet", urlPatterns = {"/api/payment/status"})
public class PaymentStatusServlet extends HttpServlet {

    private OrderService orderService;

    @Override
    public void init() {
        orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        User user = getSessionUser(request);
        if (user == null) {
            response.setStatus(401);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        int orderId = parseIntOrDefault(request.getParameter("orderId"), -1);
        if (orderId <= 0) {
            response.setStatus(400);
            response.getWriter().write("{\"error\":\"Invalid orderId\"}");
            return;
        }

        Order order = orderService.getOrderById(orderId);
        if (order == null || order.getUserId() != user.getUserId()) {
            response.setStatus(404);
            response.getWriter().write("{\"error\":\"Order not found\"}");
            return;
        }

        String status = order.getStatus();
        response.getWriter().write(String.format(
            "{\"status\":\"%s\",\"orderId\":%d,\"orderCode\":\"%s\"}",
            status, orderId, order.getOrderCode()
        ));
    }

    /**
     * POST /api/payment/status — Manual payment confirmation.
     * Allows the order owner to manually confirm payment (simulates IPN).
     * Security: Only the authenticated order owner can confirm their own order.
     * Only pending orders can be confirmed (idempotent via confirmPaymentAtomic).
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        User user = getSessionUser(request);
        if (user == null) {
            response.setStatus(401);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        int orderId = parseIntOrDefault(request.getParameter("orderId"), -1);
        if (orderId <= 0) {
            response.setStatus(400);
            response.getWriter().write("{\"error\":\"Invalid orderId\"}");
            return;
        }

        Order order = orderService.getOrderById(orderId);
        if (order == null || order.getUserId() != user.getUserId()) {
            response.setStatus(404);
            response.getWriter().write("{\"error\":\"Order not found\"}");
            return;
        }

        if ("paid".equals(order.getStatus())) {
            response.getWriter().write("{\"status\":\"paid\",\"message\":\"Already paid\"}");
            return;
        }

        if (!"pending".equals(order.getStatus())) {
            response.setStatus(400);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Order is not in pending state\"}");
            return;
        }

        // Mark as paid + issue tickets (simulating IPN)
        boolean ok = orderService.confirmPayment(orderId, "MANUAL-" + System.currentTimeMillis());
        if (ok) {
            orderService.issueTickets(orderId, order.getBuyerName(), order.getBuyerEmail());
        }

        response.getWriter().write(String.format(
            "{\"status\":\"%s\",\"orderId\":%d,\"message\":\"%s\"}",
            ok ? "paid" : "error", orderId, ok ? "Payment confirmed" : "Failed"
        ));
    }
}
