package com.sellingticket.controller.api;

import com.sellingticket.model.Order;
import com.sellingticket.model.OrderItem;
import com.sellingticket.model.PageResult;
import com.sellingticket.model.User;
import com.sellingticket.service.OrderService;
import com.sellingticket.util.JsonResponse;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * My Orders API — JSON endpoint for user's order history with search/filter.
 * Shows ALL orders including pending (not yet paid), paid, cancelled, etc.
 * This complements MyTicketApiServlet which only shows issued tickets.
 *
 * GET /api/my-orders?q=keyword&status=pending&status=paid&page=1&size=10
 */
@WebServlet(name = "MyOrderApiServlet", urlPatterns = {"/api/my-orders"})
public class MyOrderApiServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MyOrderApiServlet.class.getName());
    private OrderService orderService;

    @Override
    public void init() {
        orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User user = getSessionUser(request);
        if (user == null) {
            JsonResponse.unauthorized().send(response);
            return;
        }

        try {
            String keyword = request.getParameter("q");
            String[] statuses = request.getParameterValues("status");
            int page = parseIntOrDefault(request.getParameter("page"), 1);
            int size = parseIntOrDefault(request.getParameter("size"), 10);

            PageResult<Order> result = orderService.getOrdersByUserPaged(
                    user.getUserId(), keyword, statuses, page, size);

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

            JsonResponse json = JsonResponse.ok()
                    .put("totalItems", result.getTotalItems())
                    .put("totalPages", result.getTotalPages())
                    .put("currentPage", result.getCurrentPage())
                    .put("pageSize", result.getPageSize());

            json.startArray("items");
            for (Order o : result.getItems()) {
                StringBuilder item = new StringBuilder("{");
                item.append("\"orderId\":").append(o.getOrderId()).append(",");
                item.append("\"orderCode\":\"").append(esc(o.getOrderCode())).append("\",");
                item.append("\"eventTitle\":\"").append(esc(o.getEventTitle())).append("\",");
                item.append("\"eventId\":").append(o.getEventId()).append(",");
                item.append("\"status\":\"").append(esc(o.getStatus())).append("\",");
                item.append("\"paymentMethod\":\"").append(esc(o.getPaymentMethod())).append("\",");
                item.append("\"totalAmount\":").append(o.getTotalAmount()).append(",");
                item.append("\"discountAmount\":").append(o.getDiscountAmount()).append(",");
                item.append("\"finalAmount\":").append(o.getFinalAmount()).append(",");
                item.append("\"buyerName\":\"").append(esc(o.getBuyerName())).append("\",");
                item.append("\"buyerEmail\":\"").append(esc(o.getBuyerEmail())).append("\",");
                item.append("\"createdAt\":\"").append(o.getCreatedAt() != null ? sdf.format(o.getCreatedAt()) : "").append("\",");

                // Include order items
                item.append("\"items\":[");
                if (o.getItems() != null) {
                    for (int i = 0; i < o.getItems().size(); i++) {
                        OrderItem oi = o.getItems().get(i);
                        if (i > 0) item.append(",");
                        item.append("{\"ticketTypeName\":\"").append(esc(oi.getTicketTypeName())).append("\",");
                        item.append("\"quantity\":").append(oi.getQuantity()).append(",");
                        item.append("\"unitPrice\":").append(oi.getUnitPrice()).append(",");
                        item.append("\"subtotal\":").append(oi.getSubtotal()).append("}");
                    }
                }
                item.append("]");
                item.append("}");
                json.arrayElement(item.toString());
            }
            json.endArray();
            json.send(response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading user orders", e);
            JsonResponse.serverError().send(response);
        }
    }

    private static String esc(String v) {
        if (v == null) return "";
        return v.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r");
    }
}
