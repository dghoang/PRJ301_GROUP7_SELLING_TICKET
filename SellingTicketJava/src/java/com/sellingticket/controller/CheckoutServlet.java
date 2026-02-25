package com.sellingticket.controller;

import com.sellingticket.model.Event;
import com.sellingticket.model.Order;
import com.sellingticket.model.OrderItem;
import com.sellingticket.model.TicketType;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.service.OrderService;
import com.sellingticket.service.TicketService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
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

    private final OrderService orderService = new OrderService();
    private final EventService eventService = new EventService();
    private final TicketService ticketService = new TicketService();

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

        int ticketTypeId = parseIntOrDefault(request.getParameter("ticketTypeId"), -1);
        int quantity = parseIntOrDefault(request.getParameter("quantity"), 1);

        // Bound quantity
        quantity = Math.max(1, Math.min(quantity, MAX_QUANTITY));

        if (ticketTypeId > 0) {
            TicketType ticket = ticketService.getTicketTypeById(ticketTypeId);
            request.setAttribute("selectedTicket", ticket);
            request.setAttribute("quantity", quantity);
            if (ticket != null) {
                request.setAttribute("subtotal", ticket.getPrice() * quantity);
            }
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
        User user = getSessionUser(request);

        if (user == null) {
            request.getSession().setAttribute("redirectAfterLogin", "checkout?" + request.getQueryString());
            response.sendRedirect("login");
            return;
        }

        try {
            Order order = buildOrderFromRequest(request, user);
            if (order == null) {
                showError(request, response, "Dữ liệu đơn hàng không hợp lệ.");
                return;
            }

            int orderId = orderService.createOrder(order);
            if (orderId <= 0) {
                LOGGER.log(Level.WARNING, "Order creation failed for user={0}, event={1}",
                        new Object[]{user.getUserId(), order.getEventId()});
                showError(request, response, "Không thể tạo đơn hàng. Vé có thể đã hết.");
                return;
            }

            LOGGER.log(Level.INFO, "Order created: id={0}, user={1}, amount={2}",
                    new Object[]{orderId, user.getUserId(), order.getFinalAmount()});

            redirectAfterPayment(response, orderId, order.getPaymentMethod());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Checkout error for user=" + user.getUserId(), e);
            showError(request, response, "Đã xảy ra lỗi hệ thống. Vui lòng thử lại.");
        }
    }

    private Order buildOrderFromRequest(HttpServletRequest request, User user) {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        int ticketTypeId = parseIntOrDefault(request.getParameter("ticketTypeId"), -1);
        int quantity = parseIntOrDefault(request.getParameter("quantity"), 1);

        // Validate bounds
        if (eventId <= 0 || ticketTypeId <= 0 || quantity < 1 || quantity > MAX_QUANTITY) {
            return null;
        }

        Event event = eventService.getEventDetails(eventId);
        if (event == null) return null;

        TicketType ticket = ticketService.getTicketTypeById(ticketTypeId);
        if (ticket == null) return null;

        if (!ticketService.checkAvailability(ticketTypeId, quantity)) {
            return null;
        }

        double totalAmount = ticket.getPrice() * quantity;
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

        OrderItem item = new OrderItem();
        item.setTicketTypeId(ticketTypeId);
        item.setQuantity(quantity);
        item.setUnitPrice(ticket.getPrice());
        item.setSubtotal(totalAmount);

        List<OrderItem> items = new ArrayList<>();
        items.add(item);
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
}
