package com.sellingticket.controller.api;

import com.sellingticket.model.Order;
import com.sellingticket.model.PageResult;
import com.sellingticket.model.User;
import com.sellingticket.service.OrderService;
import com.sellingticket.util.JsonResponse;
import com.sellingticket.util.JsonUtil;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.text.SimpleDateFormat;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin Orders API — JSON endpoint for admin order management table.
 * Requires admin role.
 *
 * GET /api/admin/orders?q=keyword&status=paid&status=pending&dateFrom=2024-01-01&dateTo=2024-12-31&page=1&size=20
 */
@WebServlet(name = "AdminOrderApiServlet", urlPatterns = {"/api/admin/orders"})
public class AdminOrderApiServlet extends HttpServlet {

    private OrderService orderService;

    @Override
    public void init() {
        orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User user = getSessionUser(request);
        if (user == null || !"admin".equals(user.getRole())) {
            JsonResponse.unauthorized().send(response);
            return;
        }

        String keyword = request.getParameter("q");
        String[] statuses = request.getParameterValues("status");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        int page = parseIntOrDefault(request.getParameter("page"), 1);
        int size = parseIntOrDefault(request.getParameter("size"), 20);

        PageResult<Order> result = orderService.searchOrdersPaged(
                keyword, statuses, dateFrom, dateTo, page, size);

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
            item.append("\"orderCode\":\"").append(JsonUtil.esc(o.getOrderCode())).append("\",");
            item.append("\"buyerName\":\"").append(JsonUtil.esc(o.getBuyerName())).append("\",");
            item.append("\"buyerEmail\":\"").append(JsonUtil.esc(o.getBuyerEmail())).append("\",");
            item.append("\"buyerPhone\":\"").append(JsonUtil.esc(o.getBuyerPhone())).append("\",");
            item.append("\"eventTitle\":\"").append(JsonUtil.esc(o.getEventTitle())).append("\",");
            item.append("\"totalAmount\":").append(o.getTotalAmount()).append(",");
            item.append("\"discountAmount\":").append(o.getDiscountAmount()).append(",");
            item.append("\"finalAmount\":").append(o.getFinalAmount()).append(",");
            item.append("\"status\":\"").append(JsonUtil.esc(o.getStatus())).append("\",");
            item.append("\"paymentMethod\":\"").append(JsonUtil.esc(o.getPaymentMethod())).append("\",");
            item.append("\"createdAt\":\"").append(o.getCreatedAt() != null ? sdf.format(o.getCreatedAt()) : "").append("\"");
            item.append("}");
            json.arrayElement(item.toString());
        }
        json.endArray();
        json.send(response);
    }


}
