package com.sellingticket.controller;

import com.sellingticket.model.Event;
import com.sellingticket.model.Order;
import com.sellingticket.model.OrderItem;
import com.sellingticket.model.TicketType;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.service.OrderService;
import com.sellingticket.service.TicketService;
import com.sellingticket.service.VoucherService;
import com.sellingticket.service.VoucherService.VoucherResult;
import com.sellingticket.service.payment.PaymentResult;
import com.sellingticket.service.payment.SeepayProvider;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CheckoutServlet.class.getName());
    private static final int MAX_QUANTITY = 10;

    private OrderService orderService;
    private EventService eventService;
    private TicketService ticketService;
    private VoucherService voucherService;

    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
        eventService = new EventService();
        ticketService = new TicketService();
        voucherService = new VoucherService();
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);

        if (eventId > 0) {
            Event event = eventService.getEventDetails(eventId);
            request.setAttribute("event", event);
            if (event != null) {
                request.setAttribute("tickets", ticketService.getTicketsByEvent(eventId));
            }
        }

        // Parse items param: "typeId:qty,typeId:qty" (multi-ticket support)
        List<Map<String, Object>> selectedItems = parseItemsParam(request);
        if (!selectedItems.isEmpty()) {
            request.setAttribute("selectedItems", selectedItems);
            double totalAmount = 0;
            for (Map<String, Object> item : selectedItems) {
                totalAmount += (double) item.get("subtotal");
            }
            request.setAttribute("subtotal", totalAmount);
        }

        if (user != null) {
            request.setAttribute("user", user);
        }

        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // AJAX: voucher validation
        String action = request.getParameter("action");
        if ("validate-voucher".equals(action)) {
            handleVoucherValidation(request, response);
            return;
        }

        User user = getSessionUser(request);

        if (user == null) {
            request.getSession().setAttribute("redirectAfterLogin", "checkout?" + request.getQueryString());
            response.sendRedirect("login");
            return;
        }

        try {
            Order order = buildOrderFromRequest(request, user);
            if (order == null) {
                showError(request, response, "Dữ liệu đơn hàng không hợp lệ hoặc vé đã hết. Vui lòng quay lại chọn vé.");
                return;
            }

            // Apply voucher if provided
            String voucherCode = request.getParameter("voucherCode");
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                VoucherResult vr = voucherService.validateVoucher(
                        voucherCode.trim(), order.getEventId(), order.getTotalAmount());
                if (vr.valid && vr.discountAmount > 0) {
                    order.setDiscountAmount(vr.discountAmount);
                    order.setFinalAmount(order.getTotalAmount() - vr.discountAmount);
                    order.setVoucherCode(voucherCode.trim()); // Set to be applied atomically
                    LOGGER.log(Level.INFO, "Voucher {0} validated: discount={1}",
                            new Object[]{voucherCode, vr.discountAmount});
                }
            }

            int orderId = orderService.createOrder(order);
            if (orderId <= 0) {
                LOGGER.log(Level.WARNING, "Order creation failed for user={0}, event={1}",
                        new Object[]{user.getUserId(), order.getEventId()});
                showError(request, response,
                        "Không thể tạo đơn hàng. Vé đã được người khác mua trước. Vui lòng chọn lại.");
                return;
            }

            order.setOrderId(orderId);
            LOGGER.log(Level.INFO, "Order created: id={0}, user={1}, amount={2}",
                    new Object[]{orderId, user.getUserId(), order.getFinalAmount()});

            // SeePay flow: show QR → wait for IPN → then issue tickets
            if ("seepay".equals(order.getPaymentMethod())) {
                PaymentResult paymentResult = orderService.processPayment(order);
                SeepayProvider sp = new SeepayProvider();

                request.setAttribute("order", order);
                request.setAttribute("paymentResult", paymentResult);
                request.setAttribute("bankName", getBankDisplayName(sp.getBankId()));
                request.setAttribute("accountNo", sp.getAccountNo());
                request.setAttribute("accountName", sp.getAccountName());
                request.setAttribute("timeoutMinutes", sp.getTimeoutMinutes());
                request.getRequestDispatcher("/payment-pending.jsp").forward(request, response);
                return;
            }

            // Non-SeePay: issue tickets immediately + redirect
            int ticketsIssued = orderService.issueTickets(orderId, order.getBuyerName(), order.getBuyerEmail());
            LOGGER.log(Level.INFO, "Tickets issued: orderId={0}, count={1}", new Object[]{orderId, ticketsIssued});
            redirectAfterPayment(response, orderId, order.getPaymentMethod());

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Checkout error for user=" + user.getUserId(), e);
            showError(request, response, "Đã xảy ra lỗi hệ thống. Vui lòng thử lại.");
        }
    }

    /** AJAX handler: validate voucher code and return discount info as JSON. */
    private void handleVoucherValidation(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String code = request.getParameter("code");
        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        double amount = 0;
        try { amount = Double.parseDouble(request.getParameter("amount")); } catch (Exception ignored) {}

        VoucherResult result = voucherService.validateVoucher(code, eventId, amount);
        String json = "{\"valid\":" + result.valid
                + ",\"discountAmount\":" + result.discountAmount
                + ",\"message\":\"" + escapeJson(result.message) + "\"}";
        response.getWriter().write(json);
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }

    /**
     * Parse the items parameter format: "typeId:qty,typeId:qty".
     * Falls back to legacy single ticketTypeId + quantity params.
     */
    private List<Map<String, Object>> parseItemsParam(HttpServletRequest request) {
        List<Map<String, Object>> result = new ArrayList<>();
        String itemsParam = request.getParameter("items");

        if (itemsParam != null && !itemsParam.isEmpty()) {
            String[] parts = itemsParam.split(",");
            for (String part : parts) {
                String[] pair = part.trim().split(":");
                if (pair.length != 2) continue;
                int typeId = parseIntOrDefault(pair[0].trim(), -1);
                int qty = parseIntOrDefault(pair[1].trim(), 0);
                if (typeId <= 0 || qty <= 0 || qty > MAX_QUANTITY) continue;

                TicketType ticket = ticketService.getTicketTypeById(typeId);
                if (ticket == null) continue;

                Map<String, Object> item = new HashMap<>();
                item.put("ticketType", ticket);
                item.put("quantity", qty);
                item.put("subtotal", ticket.getPrice() * qty);
                result.add(item);
            }
        } else {
            int ticketTypeId = parseIntOrDefault(request.getParameter("ticketTypeId"), -1);
            int quantity = Math.max(1, Math.min(parseIntOrDefault(request.getParameter("quantity"), 1), MAX_QUANTITY));
            if (ticketTypeId > 0) {
                TicketType ticket = ticketService.getTicketTypeById(ticketTypeId);
                if (ticket != null) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("ticketType", ticket);
                    item.put("quantity", quantity);
                    item.put("subtotal", ticket.getPrice() * quantity);
                    result.add(item);
                }
            }
        }
        return result;
    }

    private Order buildOrderFromRequest(HttpServletRequest request, User user) {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        if (eventId <= 0) return null;

        Event event = eventService.getEventDetails(eventId);
        if (event == null) return null;

        List<OrderItem> items = new ArrayList<>();
        double totalAmount = 0;

        String itemsParam = request.getParameter("items");
        if (itemsParam != null && !itemsParam.isEmpty()) {
            String[] parts = itemsParam.split(",");
            for (String part : parts) {
                String[] pair = part.trim().split(":");
                if (pair.length != 2) continue;
                int typeId = parseIntOrDefault(pair[0].trim(), -1);
                int qty = parseIntOrDefault(pair[1].trim(), 0);
                if (typeId <= 0 || qty <= 0 || qty > MAX_QUANTITY) continue;

                TicketType ticket = ticketService.getTicketTypeById(typeId);
                if (ticket == null) continue;
                if (!ticketService.checkAvailability(typeId, qty)) return null;

                double subtotal = ticket.getPrice() * qty;
                OrderItem item = new OrderItem();
                item.setTicketTypeId(typeId);
                item.setQuantity(qty);
                item.setUnitPrice(ticket.getPrice());
                item.setSubtotal(subtotal);
                items.add(item);
                totalAmount += subtotal;
            }
        } else {
            int ticketTypeId = parseIntOrDefault(request.getParameter("ticketTypeId"), -1);
            int quantity = parseIntOrDefault(request.getParameter("quantity"), 1);
            if (ticketTypeId <= 0 || quantity < 1 || quantity > MAX_QUANTITY) return null;

            TicketType ticket = ticketService.getTicketTypeById(ticketTypeId);
            if (ticket == null) return null;
            if (!ticketService.checkAvailability(ticketTypeId, quantity)) return null;

            totalAmount = ticket.getPrice() * quantity;
            OrderItem item = new OrderItem();
            item.setTicketTypeId(ticketTypeId);
            item.setQuantity(quantity);
            item.setUnitPrice(ticket.getPrice());
            item.setSubtotal(totalAmount);
            items.add(item);
        }

        if (items.isEmpty()) return null;

        String paymentMethod = request.getParameter("paymentMethod");

        Order order = new Order();
        order.setOrderCode(orderService.generateOrderCode());
        order.setUserId(user.getUserId());
        order.setEventId(eventId);
        order.setTotalAmount(totalAmount);
        order.setDiscountAmount(0);
        order.setFinalAmount(totalAmount);
        order.setPaymentMethod(paymentMethod != null ? paymentMethod : "bank_transfer");
        order.setBuyerName(getParamOrDefault(request, "buyerName", user.getFullName()));
        order.setBuyerEmail(getParamOrDefault(request, "buyerEmail", user.getEmail()));
        order.setBuyerPhone(getParamOrDefault(request, "buyerPhone", user.getPhone()));
        order.setNotes(request.getParameter("notes"));
        order.setItems(items);

        return order;
    }

    private void redirectAfterPayment(HttpServletResponse response, int orderId, String paymentMethod)
            throws IOException {

        if ("bank_transfer".equals(paymentMethod) || "cash".equals(paymentMethod)) {
            response.sendRedirect("order-confirmation?id=" + orderId);
        } else {
            orderService.processPayment(orderId, paymentMethod);
            response.sendRedirect("order-confirmation?id=" + orderId + "&paid=true");
        }
    }

    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        doGet(request, response);
    }

    private String getParamOrDefault(HttpServletRequest request, String param, String defaultValue) {
        String value = request.getParameter(param);
        return (value != null && !value.isEmpty()) ? value : defaultValue;
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
