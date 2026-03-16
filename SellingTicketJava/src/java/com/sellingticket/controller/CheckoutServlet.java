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
import java.util.Date;
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
    private static final int DEFAULT_MAX_TICKETS_PER_BUYER = 4;
    private static final int ABSOLUTE_MAX_QUANTITY = 50;
    private static final int MAX_BUYER_NAME_LEN = 100;
    private static final int MAX_BUYER_EMAIL_LEN = 255;
    private static final int MAX_BUYER_PHONE_LEN = 20;
    private static final int MAX_NOTES_LEN = 500;

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
        Event event = null;

        if (eventId > 0) {
            event = eventService.getEventDetails(eventId);
            // Block checkout page for past events
            if (event != null && event.getEndDate() != null && event.getEndDate().before(new java.util.Date())) {
                request.setAttribute("error", "Sự kiện đã kết thúc, không thể thanh toán.");
                request.setAttribute("event", event);
                request.getRequestDispatcher("/checkout.jsp").forward(request, response);
                return;
            }
            request.setAttribute("event", event);
            if (event != null) {
                request.setAttribute("tickets", ticketService.getTicketsByEvent(eventId));
            }
        }

        // Parse items param: "typeId:qty,typeId:qty" (multi-ticket support)
        int maxQtyForPreview = resolvePerBuyerLimit(event);
        List<Map<String, Object>> selectedItems = parseItemsParam(request, maxQtyForPreview);
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
            request.getSession().setAttribute("redirectAfterLogin", getRequestPathWithQuery(request));
            redirectToLogin(request, response);
            return;
        }

        // Double-submit guard: check for in-flight checkout
        synchronized (request.getSession()) {
            Boolean checkoutInProgress = (Boolean) request.getSession().getAttribute("checkoutInProgress");
            if (Boolean.TRUE.equals(checkoutInProgress)) {
                showError(request, response, "Đơn hàng đang được xử lý. Vui lòng không nhấn nút nhiều lần.");
                return;
            }
            request.getSession().setAttribute("checkoutInProgress", true);
        }

        try {
            Order order = buildOrderFromRequest(request, user);
            if (order == null) {
                showError(request, response, "Dữ liệu đơn hàng không hợp lệ hoặc vé đã hết. Vui lòng quay lại chọn vé.");
                return;
            }

            // Apply voucher if provided (max 50 chars, alphanumeric only)
            String voucherCode = request.getParameter("voucherCode");
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                voucherCode = voucherCode.trim();
                if (voucherCode.length() > 50) voucherCode = voucherCode.substring(0, 50);
                VoucherResult vr = voucherService.validateVoucher(
                        voucherCode, order.getEventId(), order.getTotalAmount());
                if (vr.valid && vr.discountAmount > 0) {
                    order.setDiscountAmount(vr.discountAmount);
                    order.setFinalAmount(order.getTotalAmount() - vr.discountAmount);
                    order.setVoucherCode(voucherCode.trim());
                    // Settlement split: track voucher scope and fund source
                    order.setVoucherId(vr.voucherId);
                    order.setVoucherScope(vr.voucherScope);
                    order.setVoucherFundSource(vr.fundSource);
                    order.setEventDiscountAmount(vr.eventDiscountAmount);
                    order.setSystemDiscountAmount(vr.systemDiscountAmount);
                    // Organizer payout: full face value minus event discount minus platform fee
                    double platformFee = 0; // TODO: configurable platform fee rate
                    order.setPlatformFeeAmount(platformFee);
                    order.setOrganizerPayoutAmount(order.getTotalAmount() - vr.eventDiscountAmount - platformFee);
                    LOGGER.log(Level.INFO, "Voucher {0} validated: discount={1}, scope={2}, source={3}",
                            new Object[]{voucherCode, vr.discountAmount, vr.voucherScope, vr.fundSource});
                }
            }

            // If no voucher was applied, set default settlement values
            if (order.getVoucherScope() == null) {
                order.setVoucherScope("NONE");
                order.setVoucherFundSource("NONE");
                order.setOrganizerPayoutAmount(order.getTotalAmount());
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

            // Business policy: QR transfer only via SeePay pending flow.
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

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Checkout error for user=" + user.getUserId(), e);
            showError(request, response, "Đã xảy ra lỗi hệ thống. Vui lòng thử lại.");
        } finally {
            request.getSession().removeAttribute("checkoutInProgress");
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
                + ",\"voucherScope\":\"" + escapeJson(result.voucherScope) + "\""
                + ",\"fundSource\":\"" + escapeJson(result.fundSource) + "\""
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
    private List<Map<String, Object>> parseItemsParam(HttpServletRequest request, int maxQty) {
        List<Map<String, Object>> result = new ArrayList<>();
        String itemsParam = request.getParameter("items");
        int safeMax = Math.max(1, Math.min(maxQty, ABSOLUTE_MAX_QUANTITY));

        if (itemsParam != null && !itemsParam.isEmpty()) {
            String[] parts = itemsParam.split(",");
            for (String part : parts) {
                String[] pair = part.trim().split(":");
                if (pair.length != 2) continue;
                int typeId = parseIntOrDefault(pair[0].trim(), -1);
                int qty = parseIntOrDefault(pair[1].trim(), 0);
                if (typeId <= 0 || qty <= 0 || qty > safeMax) continue;

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
            int quantity = Math.max(1, Math.min(parseIntOrDefault(request.getParameter("quantity"), 1), safeMax));
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

        // V4 FIX: Only allow checkout for approved events
        if (!"approved".equals(event.getStatus())) return null;

        // Block checkout for past events
        Date now = new Date();
        if (event.getEndDate() != null && event.getEndDate().before(now)) {
            return null;
        }

        // Anti-hoarding limit per buyer (configurable per event).
        int perBuyerLimit = resolvePerBuyerLimit(event);

        List<OrderItem> items = new ArrayList<>();
        double totalAmount = 0;
        int totalTicketsInOrder = 0;

        String itemsParam = request.getParameter("items");
        if (itemsParam != null && !itemsParam.isEmpty()) {
            String[] parts = itemsParam.split(",");
            for (String part : parts) {
                String[] pair = part.trim().split(":");
                if (pair.length != 2) continue;
                int typeId = parseIntOrDefault(pair[0].trim(), -1);
                int qty = parseIntOrDefault(pair[1].trim(), 0);
                if (typeId <= 0 || qty <= 0 || qty > perBuyerLimit) continue;

                TicketType ticket = ticketService.getTicketTypeById(typeId);
                if (ticket == null) continue;
                // V9 FIX: Verify ticket belongs to this event
                if (ticket.getEventId() != eventId) continue;
                // Sale window enforcement
                if (ticket.getSaleStart() != null && ticket.getSaleStart().after(now)) continue;
                if (ticket.getSaleEnd() != null && ticket.getSaleEnd().before(now)) continue;
                if (!ticketService.checkAvailability(typeId, qty)) return null;

                double subtotal = ticket.getPrice() * qty;
                OrderItem item = new OrderItem();
                item.setTicketTypeId(typeId);
                item.setQuantity(qty);
                item.setUnitPrice(ticket.getPrice());
                item.setSubtotal(subtotal);
                items.add(item);
                totalAmount += subtotal;
                totalTicketsInOrder += qty;
            }
        } else {
            int ticketTypeId = parseIntOrDefault(request.getParameter("ticketTypeId"), -1);
            int quantity = parseIntOrDefault(request.getParameter("quantity"), 1);
            if (ticketTypeId <= 0 || quantity < 1 || quantity > perBuyerLimit) return null;

            TicketType ticket = ticketService.getTicketTypeById(ticketTypeId);
            if (ticket == null) return null;
            // V9 FIX: Verify ticket belongs to this event
            if (ticket.getEventId() != eventId) return null;
            // Sale window enforcement
            if (ticket.getSaleStart() != null && ticket.getSaleStart().after(now)) return null;
            if (ticket.getSaleEnd() != null && ticket.getSaleEnd().before(now)) return null;
            if (!ticketService.checkAvailability(ticketTypeId, quantity)) return null;

            totalAmount = ticket.getPrice() * quantity;
            OrderItem item = new OrderItem();
            item.setTicketTypeId(ticketTypeId);
            item.setQuantity(quantity);
            item.setUnitPrice(ticket.getPrice());
            item.setSubtotal(totalAmount);
            items.add(item);
            totalTicketsInOrder += quantity;
        }

        if (items.isEmpty()) return null;

        // Enforce max tickets per order
        if (totalTicketsInOrder > perBuyerLimit) return null;

        // Enforce max total tickets for event
        int eventMaxTotal = event.getMaxTotalTickets();
        if (eventMaxTotal > 0 && (event.getSoldTickets() + totalTicketsInOrder) > eventMaxTotal) return null;

        // Per-user purchase limit: existing tickets + new tickets <= configured cap.
        int existingUserTickets = orderService.countUserTicketsForEvent(user.getUserId(), eventId);
        if ((existingUserTickets + totalTicketsInOrder) > perBuyerLimit) return null;

        // Business policy: only QR bank transfer via SeePay is accepted.
        String paymentMethod = "seepay";

        Order order = new Order();
        order.setOrderCode(orderService.generateOrderCode());
        order.setUserId(user.getUserId());
        order.setEventId(eventId);
        order.setTotalAmount(totalAmount);
        order.setDiscountAmount(0);
        order.setFinalAmount(totalAmount);
        order.setPaymentMethod(paymentMethod);

        // Sanitize buyer info with length limits
        String buyerName = truncate(getParamOrDefault(request, "buyerName", user.getFullName()), MAX_BUYER_NAME_LEN);
        String buyerEmail = truncate(getParamOrDefault(request, "buyerEmail", user.getEmail()), MAX_BUYER_EMAIL_LEN);
        String buyerPhone = truncate(getParamOrDefault(request, "buyerPhone", user.getPhone()), MAX_BUYER_PHONE_LEN);
        String notes = truncate(request.getParameter("notes"), MAX_NOTES_LEN);

        // Validate buyer email format
        if (buyerEmail != null && !buyerEmail.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            buyerEmail = user.getEmail();
        }

        order.setBuyerName(buyerName);
        order.setBuyerEmail(buyerEmail);
        order.setBuyerPhone(buyerPhone);
        order.setNotes(notes);
        order.setItems(items);

        return order;
    }

    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        doGet(request, response);
    }

    private String getParamOrDefault(HttpServletRequest request, String param, String defaultValue) {
        String value = request.getParameter(param);
        return (value != null && !value.isEmpty()) ? value.trim() : defaultValue;
    }

    private String truncate(String value, int maxLen) {
        if (value == null) return null;
        return value.length() > maxLen ? value.substring(0, maxLen) : value;
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

    private int resolvePerBuyerLimit(Event event) {
        if (event == null) {
            return DEFAULT_MAX_TICKETS_PER_BUYER;
        }
        int configured = event.getMaxTicketsPerOrder();
        if (configured <= 0) {
            return DEFAULT_MAX_TICKETS_PER_BUYER;
        }
        return Math.min(configured, ABSOLUTE_MAX_QUANTITY);
    }
}
