package com.sellingticket.controller.api;

import com.sellingticket.dao.TicketDAO;
import com.sellingticket.model.Order;
import com.sellingticket.model.Ticket;
import com.sellingticket.model.User;
import com.sellingticket.service.OrderService;
import com.sellingticket.util.JsonResponse;
import com.sellingticket.util.JsonUtil;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin Confirm Payment API — AJAX endpoint for payment confirmation + ticket issuance.
 * Returns issued ticket data including QR codes for client-side rendering.
 *
 * POST /api/admin/orders/confirm-payment
 * Body: orderId=123
 * Response: { success, message, order: { orderId, orderCode, status },
 *             tickets: [{ ticketId, ticketCode, ticketTypeName, attendeeName, qrCode }] }
 */
@WebServlet(name = "AdminConfirmPaymentApiServlet", urlPatterns = {"/api/admin/orders/confirm-payment"})
public class AdminConfirmPaymentApiServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminConfirmPaymentApiServlet.class.getName());
    private OrderService orderService;
    private TicketDAO ticketDAO;

    @Override
    public void init() {
        orderService = new OrderService();
        ticketDAO = new TicketDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User user = getSessionUser(request);
        if (user == null || !"admin".equals(user.getRole())) {
            JsonResponse.unauthorized().send(response);
            return;
        }

        int orderId = parseIntOrDefault(request.getParameter("orderId"), -1);
        if (orderId <= 0) {
            JsonResponse.badRequest("Mã đơn hàng không hợp lệ").send(response);
            return;
        }

        Order targetOrder = orderService.getOrderById(orderId);
        if (targetOrder == null) {
            JsonResponse.notFound("Đơn hàng").send(response);
            return;
        }

        // Step 1: Confirm payment (atomic — only if still pending)
        boolean paymentOk;
        if ("pending".equals(targetOrder.getStatus())) {
            paymentOk = orderService.confirmPayment(orderId, "ADMIN-MANUAL-" + System.currentTimeMillis());
            if (!paymentOk) {
                // Race condition: another process may have confirmed it already
                Order refreshed = orderService.getOrderById(orderId);
                paymentOk = refreshed != null && ("paid".equals(refreshed.getStatus()) || "checked_in".equals(refreshed.getStatus()));
            }
        } else {
            paymentOk = "paid".equals(targetOrder.getStatus()) || "checked_in".equals(targetOrder.getStatus());
        }

        if (!paymentOk) {
            JsonResponse.error(400, "Không thể xác nhận thanh toán. Trạng thái hiện tại: " + targetOrder.getStatus())
                    .send(response);
            return;
        }

        // Step 2: Issue tickets (idempotent — skip if already issued)
        List<Ticket> existingTickets = ticketDAO.getTicketsByOrder(orderId);
        if (existingTickets.isEmpty()) {
            int issued = orderService.issueTickets(orderId, targetOrder.getBuyerName(), targetOrder.getBuyerEmail());
            if (issued <= 0) {
                JsonResponse.error(500, "Đã xác nhận thanh toán nhưng phát hành vé thất bại. Vui lòng thử lại.")
                        .send(response);
                return;
            }
            existingTickets = ticketDAO.getTicketsByOrder(orderId);
        }

        // Step 3: Build response with ticket + QR data
        Order updatedOrder = orderService.getOrderById(orderId);
        JsonResponse json = JsonResponse.ok()
                .put("message", "Đã xác nhận thanh toán và phát hành " + existingTickets.size() + " vé thành công!")
                .put("orderId", updatedOrder.getOrderId())
                .put("orderCode", updatedOrder.getOrderCode())
                .put("orderStatus", updatedOrder.getStatus())
                .put("buyerName", updatedOrder.getBuyerName())
                .put("buyerEmail", updatedOrder.getBuyerEmail())
                .put("eventTitle", updatedOrder.getEventTitle());

        json.startArray("tickets");
        for (Ticket t : existingTickets) {
            StringBuilder item = new StringBuilder("{");
            item.append("\"ticketId\":").append(t.getTicketId()).append(",");
            item.append("\"ticketCode\":\"").append(JsonUtil.esc(t.getTicketCode())).append("\",");
            item.append("\"ticketTypeName\":\"").append(JsonUtil.esc(t.getTicketTypeName())).append("\",");
            item.append("\"attendeeName\":\"").append(JsonUtil.esc(t.getAttendeeName())).append("\",");
            item.append("\"attendeeEmail\":\"").append(JsonUtil.esc(t.getAttendeeEmail())).append("\",");
            item.append("\"qrCode\":\"").append(JsonUtil.esc(t.getQrCode())).append("\"");
            item.append("}");
            json.arrayElement(item.toString());
        }
        json.endArray();
        json.send(response);

        LOGGER.log(Level.INFO, "Admin {0} confirmed payment for order {1}, issued {2} tickets",
                new Object[]{user.getEmail(), orderId, existingTickets.size()});
    }


}
