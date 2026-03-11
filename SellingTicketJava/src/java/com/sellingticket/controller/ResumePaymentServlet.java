package com.sellingticket.controller;

import com.sellingticket.model.Order;
import com.sellingticket.model.User;
import com.sellingticket.service.OrderService;
import com.sellingticket.service.payment.PaymentResult;
import com.sellingticket.service.payment.SeepayProvider;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * ResumePaymentServlet — Resumes payment for an existing pending order.
 *
 * GET /resume-payment?orderId=X
 *   - If order is pending → show payment-pending.jsp with QR
 *   - If order is paid → redirect to order-confirmation
 *   - If order is expired → auto-cancel + redirect with error
 */
@WebServlet(name = "ResumePaymentServlet", urlPatterns = {"/resume-payment"})
public class ResumePaymentServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ResumePaymentServlet.class.getName());
    private static final int DEFAULT_TIMEOUT = 15; // minutes

    private OrderService orderService;

    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        String ctx = request.getContextPath();

        int orderId = parseIntOrDefault(request.getParameter("orderId"), -1);
        if (orderId <= 0) {
            response.sendRedirect(ctx + "/my-tickets");
            return;
        }

        Order order = orderService.getOrderById(orderId);
        if (order == null || order.getUserId() != user.getUserId()) {
            response.sendRedirect(ctx + "/my-tickets");
            return;
        }

        // Already paid → go to confirmation
        if ("paid".equals(order.getStatus()) || "checked_in".equals(order.getStatus())) {
            response.sendRedirect(ctx + "/order-confirmation?id=" + orderId);
            return;
        }

        // Cancelled/refunded → show error
        if ("cancelled".equals(order.getStatus()) || "refunded".equals(order.getStatus())) {
            request.getSession().setAttribute("flashError", "Đơn hàng đã bị hủy. Vui lòng đặt lại.");
            response.sendRedirect(ctx + "/my-tickets");
            return;
        }

        // Pending → check if expired (created_at + timeout < now)
        if ("pending".equals(order.getStatus())) {
            SeepayProvider sp = new SeepayProvider();
            int timeoutMinutes = sp.getTimeoutMinutes();

            if (order.getCreatedAt() != null) {
                long createdMs = order.getCreatedAt().getTime();
                long nowMs = System.currentTimeMillis();
                long elapsedMinutes = (nowMs - createdMs) / (60 * 1000);

                if (elapsedMinutes > timeoutMinutes) {
                    // Auto-cancel expired order
                    orderService.cancelOrder(orderId);
                    LOGGER.log(Level.INFO, "Auto-cancelled expired order: id={0}, elapsed={1}min",
                            new Object[]{orderId, elapsedMinutes});
                    request.getSession().setAttribute("flashError",
                            "Đơn hàng đã hết hạn thanh toán và bị hủy. Vui lòng đặt lại.");
                        response.sendRedirect(ctx + "/my-tickets");
                    return;
                }

                // Calculate remaining time for countdown
                int remainingMinutes = (int) Math.max(1, timeoutMinutes - elapsedMinutes);
                request.setAttribute("timeoutMinutes", remainingMinutes);
            } else {
                request.setAttribute("timeoutMinutes", timeoutMinutes);
            }

            // Generate fresh QR with existing order data
            PaymentResult paymentResult = orderService.processPayment(order);

            request.setAttribute("order", order);
            request.setAttribute("paymentResult", paymentResult);
            request.setAttribute("bankName", getBankDisplayName(sp.getBankId()));
            request.setAttribute("accountNo", sp.getAccountNo());
            request.setAttribute("accountName", sp.getAccountName());
            request.getRequestDispatcher("/payment-pending.jsp").forward(request, response);
            return;
        }

        // Unknown status → redirect
        response.sendRedirect(ctx + "/my-tickets");
    }

    private String getBankDisplayName(String bankId) {
        switch (bankId) {
            case "MB": return "MB Bank (Quân đội)";
            case "VCB": return "Vietcombank";
            case "TCB": return "Techcombank";
            case "ACB": return "ACB";
            case "VPB": return "VPBank";
            case "TPB": return "TPBank";
            case "BIDV": return "BIDV";
            case "VTB": return "VietinBank";
            default: return bankId;
        }
    }
}
