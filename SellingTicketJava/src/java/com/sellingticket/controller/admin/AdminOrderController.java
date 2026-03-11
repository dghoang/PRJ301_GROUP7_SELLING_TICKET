package com.sellingticket.controller.admin;

import com.sellingticket.model.Order;
import com.sellingticket.service.DashboardService;
import com.sellingticket.service.OrderService;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;
import com.sellingticket.util.FlashUtil;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin order management — list, filter, search, cancel, refund actions.
 */
@WebServlet(name = "AdminOrderController", urlPatterns = {"/admin/orders", "/admin/orders/*"})
public class AdminOrderController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminOrderController.class.getName());
    private final OrderService orderService = new OrderService();
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            FlashUtil.apply(request);
            String status = request.getParameter("status");
            String query = request.getParameter("q");
            int page = parseIntOrDefault(request.getParameter("page"), 1);

            // If searching by order code
            if (query != null && !query.trim().isEmpty()) {
                Order found = orderService.getOrderByCode(query.trim());
                if (found != null) {
                    request.setAttribute("orders", List.of(found));
                    request.setAttribute("searchQuery", query.trim());
                } else {
                    request.setAttribute("orders", List.of());
                    request.setAttribute("searchQuery", query.trim());
                    request.setAttribute("searchNotFound", true);
                }
            } else {
                List<Order> orders = orderService.getAllOrders(status, page, 20);
                request.setAttribute("orders", orders);
                request.setAttribute("currentPage", page);
            }

            request.setAttribute("statusFilter", status);

            // Stats
            int paid = orderService.countOrdersByStatus("paid");
            int pending = orderService.countOrdersByStatus("pending");
            int cancelled = orderService.countOrdersByStatus("cancelled");
            int refundReq = orderService.countOrdersByStatus("refund_requested");
            request.setAttribute("paidOrders", paid);
            request.setAttribute("pendingOrders", pending);
            request.setAttribute("cancelledOrders", cancelled);
            request.setAttribute("refundRequested", refundReq);
            request.setAttribute("totalOrders", paid + pending + cancelled + refundReq);

            // Sidebar badge
            request.setAttribute("pendingCount", dashboardService.getPendingEventsCount());

            request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load admin orders", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = getAction(request.getPathInfo());
        int orderId = parseIntOrDefault(request.getParameter("orderId"), -1);

        if (orderId <= 0) {
            FlashUtil.error(request, "Dữ liệu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        boolean ok;
        String successMsg;

        switch (action) {
            case "cancel":
                ok = orderService.cancelOrder(orderId);
                successMsg = "cancelled";
                break;
            case "mark-paid":
                ok = orderService.markAsPaid(orderId);
                successMsg = "marked_paid";
                break;
            case "approve-refund":
                ok = orderService.approveRefund(orderId);
                successMsg = "refunded";
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/orders");
                return;
        }

        if (ok) {
            FlashUtil.success(request, successMsg.equals("cancelled") ? "Đơn hàng đã được hủy!" : successMsg.equals("marked_paid") ? "Đơn hàng đã được thanh toán!" : "Hoàn tiền đã được phê duyệt!");
        } else {
            FlashUtil.error(request, "Thao tác thất bại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/orders");
    }

    private String getAction(String pathInfo) {
        if (pathInfo == null || pathInfo.equals("/")) return "list";
        return pathInfo.substring(1);
    }
}
