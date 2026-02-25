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
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

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
            if (order == null) return;

            int orderId = orderService.createOrder(order);
            if (orderId <= 0) {
                showError(request, response, "Không thể tạo đơn hàng. Vui lòng thử lại.");
                return;
            }

            redirectAfterPayment(response, orderId, order.getPaymentMethod());
        } catch (Exception e) {
            e.printStackTrace();
            showError(request, response, "Đã xảy ra lỗi: " + e.getMessage());
        }
    }

    private Order buildOrderFromRequest(HttpServletRequest request, User user)
            throws ServletException, IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        int ticketTypeId = parseIntOrDefault(request.getParameter("ticketTypeId"), -1);
        int quantity = parseIntOrDefault(request.getParameter("quantity"), 1);

        Event event = eventService.getEventDetails(eventId);
        if (event == null) {
            showError(request, (HttpServletResponse) null, "Sự kiện không tồn tại");
            return null;
        }

        if (!ticketService.checkAvailability(ticketTypeId, quantity)) {
            showError(request, null, "Số lượng vé không đủ");
            return null;
        }

        TicketType ticket = ticketService.getTicketTypeById(ticketTypeId);
        if (ticket == null) {
            showError(request, null, "Loại vé không hợp lệ");
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
        if (response != null) {
            doGet(request, response);
        }
    }

    private String getParamOrDefault(HttpServletRequest request, String param, String defaultValue) {
        String value = request.getParameter(param);
        return (value != null && !value.isEmpty()) ? value : defaultValue;
    }
}
