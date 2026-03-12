package com.sellingticket.controller.admin;

import com.sellingticket.dao.TicketDAO;
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
    private final TicketDAO ticketDAO = new TicketDAO();

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
                Order targetOrder = orderService.getOrderById(orderId);
                if (targetOrder == null) {
                    ok = false;
                    successMsg = "not_found";
                    break;
                }

                // Step 1: Ensure order is paid (atomic if currently pending)
                if ("pending".equals(targetOrder.getStatus())) {
                    ok = orderService.confirmPayment(orderId, "ADMIN-MANUAL-" + System.currentTimeMillis());
                    if (!ok) {
                        // Could be a race where another process already confirmed it.
                        Order refreshed = orderService.getOrderById(orderId);
                        ok = refreshed != null && "paid".equals(refreshed.getStatus());
                    }
                } else {
                    ok = "paid".equals(targetOrder.getStatus()) || "checked_in".equals(targetOrder.getStatus());
                }

                if (!ok) {
                    successMsg = "mark_paid_failed";
                    break;
                }

                // Step 2: Ensure tickets are issued exactly once
                int existingTickets = ticketDAO.getTicketsByOrder(orderId).size();
                if (existingTickets == 0) {
                    int issued = orderService.issueTickets(orderId, targetOrder.getBuyerName(), targetOrder.getBuyerEmail());
                    ok = issued > 0;
                    successMsg = ok ? "marked_paid_issued" : "ticket_issue_failed";
                } else {
                    successMsg = "marked_paid_already_issued";
                }
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
            String msg;
            if ("cancelled".equals(successMsg)) {
                msg = "Đơn hàng đã được hủy!";
            } else if ("marked_paid_issued".equals(successMsg)) {
                msg = "Đã xác nhận thanh toán và phát hành vé thành công!";
            } else if ("marked_paid_already_issued".equals(successMsg)) {
                msg = "Đơn hàng đã thanh toán và vé đã được phát trước đó.";
            } else {
                msg = "Hoàn tiền đã được phê duyệt!";
            }
            FlashUtil.success(request, msg);
        } else {
            String err;
            if ("not_found".equals(successMsg)) {
                err = "Không tìm thấy đơn hàng.";
            } else if ("ticket_issue_failed".equals(successMsg)) {
                err = "Đã xác nhận thanh toán nhưng phát hành vé thất bại. Vui lòng thử lại.";
            } else {
                err = "Thao tác thất bại!";
            }
            FlashUtil.error(request, err);
        }
        response.sendRedirect(request.getContextPath() + "/admin/orders");
    }

    private String getAction(String pathInfo) {
        if (pathInfo == null || pathInfo.equals("/")) return "list";
        return pathInfo.substring(1);
    }
}
