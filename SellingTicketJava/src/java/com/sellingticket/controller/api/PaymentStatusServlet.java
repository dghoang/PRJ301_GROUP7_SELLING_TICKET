package com.sellingticket.controller.api;

import com.sellingticket.model.Order;
import com.sellingticket.model.User;
import com.sellingticket.service.OrderService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * PaymentStatusServlet — JSON API for frontend polling during payment-pending.
 *
 * GET  /api/payment/status?orderId=X  → poll current status
 * POST /api/payment/status?orderId=X  → manual payment confirmation
 *
 * Security: Only the authenticated order owner can access their order.
 */
@WebServlet(name = "PaymentStatusServlet", urlPatterns = {"/api/payment/status"})
public class PaymentStatusServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PaymentStatusServlet.class.getName());
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
            sendJson(response, 401, "{\"error\":\"Unauthorized\",\"status\":\"error\"}");
            return;
        }

        int orderId = parseIntOrDefault(request.getParameter("orderId"), -1);
        if (orderId <= 0) {
            sendJson(response, 400, "{\"error\":\"Invalid orderId\",\"status\":\"error\"}");
            return;
        }

        Order order = orderService.getOrderById(orderId);
        if (order == null || order.getUserId() != user.getUserId()) {
            sendJson(response, 404, "{\"error\":\"Order not found\",\"status\":\"error\"}");
            return;
        }

        String status = order.getStatus();
        sendJson(response, String.format(
            "{\"status\":\"%s\",\"orderId\":%d,\"orderCode\":\"%s\"}",
            status, orderId, order.getOrderCode()
        ));
    }

    /**
     * POST /api/payment/status — Manual payment confirmation.
     *
     * Flow: validate session → validate order → confirm payment → issue tickets.
     * Returns detailed error info so frontend can show useful messages.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // 1. Auth check
        User user = getSessionUser(request);
        if (user == null) {
            LOGGER.log(Level.WARNING, "Payment confirm rejected: no session");
            sendJson(response, 401,
                "{\"status\":\"error\",\"message\":\"Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.\"}");
            return;
        }

        // 2. Parse orderId
        int orderId = parseIntOrDefault(request.getParameter("orderId"), -1);
        if (orderId <= 0) {
            sendJson(response, 400,
                "{\"status\":\"error\",\"message\":\"Mã đơn hàng không hợp lệ.\"}");
            return;
        }

        LOGGER.log(Level.INFO, "Manual payment confirm: orderId={0}, userId={1}",
                new Object[]{orderId, user.getUserId()});

        // 3. Fetch order
        Order order;
        try {
            order = orderService.getOrderById(orderId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "DB error fetching order id=" + orderId, e);
            sendJson(response, 500,
                "{\"status\":\"error\",\"message\":\"Lỗi hệ thống khi truy vấn đơn hàng. Vui lòng thử lại.\"}");
            return;
        }

        if (order == null) {
            LOGGER.log(Level.WARNING, "Order not found: id={0}", orderId);
            sendJson(response, 404,
                "{\"status\":\"error\",\"message\":\"Không tìm thấy đơn hàng.\"}");
            return;
        }

        // 4. Ownership check
        if (order.getUserId() != user.getUserId()) {
            LOGGER.log(Level.WARNING, "Ownership mismatch: orderId={0}, orderUser={1}, sessionUser={2}",
                    new Object[]{orderId, order.getUserId(), user.getUserId()});
            sendJson(response, 403,
                "{\"status\":\"error\",\"message\":\"Bạn không có quyền xác nhận đơn hàng này.\"}");
            return;
        }

        // 5. Status checks
        if ("paid".equals(order.getStatus()) || "checked_in".equals(order.getStatus())) {
            LOGGER.log(Level.INFO, "Order already paid: orderId={0}", orderId);
            sendJson(response, "{\"status\":\"paid\",\"message\":\"Đơn hàng đã được thanh toán.\"}");
            return;
        }

        if (!"pending".equals(order.getStatus())) {
            LOGGER.log(Level.WARNING, "Cannot confirm order in status={0}, orderId={1}",
                    new Object[]{order.getStatus(), orderId});
            sendJson(response, 400, String.format(
                "{\"status\":\"error\",\"message\":\"Đơn hàng ở trạng thái '%s', không thể xác nhận.\"}",
                order.getStatus()
            ));
            return;
        }

        // 6. Confirm payment atomically
        boolean paymentOk;
        try {
            paymentOk = orderService.confirmPayment(orderId, "MANUAL-" + System.currentTimeMillis());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Exception confirming payment: orderId=" + orderId, e);
            sendJson(response, 500,
                "{\"status\":\"error\",\"message\":\"Lỗi hệ thống khi xác nhận thanh toán.\"}");
            return;
        }

        if (!paymentOk) {
            // Could be a race condition — re-check current status
            Order refreshed = orderService.getOrderById(orderId);
            if (refreshed != null && ("paid".equals(refreshed.getStatus()) || "checked_in".equals(refreshed.getStatus()))) {
                LOGGER.log(Level.INFO, "Payment already confirmed by another process: orderId={0}", orderId);
                sendJson(response, "{\"status\":\"paid\",\"message\":\"Đã thanh toán (xác nhận bởi hệ thống).\"}");
                return;
            }
            LOGGER.log(Level.WARNING, "confirmPaymentAtomic returned false: orderId={0}", orderId);
            sendJson(response, 500,
                "{\"status\":\"error\",\"message\":\"Xác nhận thanh toán thất bại. Vui lòng thử lại hoặc liên hệ hỗ trợ.\"}");
            return;
        }

        // 7. Issue tickets
        int ticketCount = 0;
        try {
            ticketCount = orderService.issueTickets(orderId, order.getBuyerName(), order.getBuyerEmail());
            LOGGER.log(Level.INFO, "Tickets issued: orderId={0}, count={1}",
                    new Object[]{orderId, ticketCount});
        } catch (Exception e) {
            // Payment is confirmed but ticket issuance failed — log but don't fail the response.
            // Admin can re-issue tickets later.
            LOGGER.log(Level.SEVERE, "Ticket issuance failed (payment OK): orderId=" + orderId, e);
        }

        // 8. Success response
        sendJson(response, String.format(
            "{\"status\":\"paid\",\"orderId\":%d,\"ticketsIssued\":%d,\"message\":\"Thanh toán thành công! Đã phát hành %d vé.\"}",
            orderId, ticketCount, ticketCount
        ));
    }
}
