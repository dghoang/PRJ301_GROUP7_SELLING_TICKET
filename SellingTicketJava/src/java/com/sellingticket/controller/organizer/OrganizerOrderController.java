package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.Order;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.service.OrderService;
import com.sellingticket.util.AppConstants;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "OrganizerOrderController", urlPatterns = {"/organizer/orders", "/organizer/orders/*"})
public class OrganizerOrderController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerOrderController.class.getName());
    private final EventService eventService = new EventService();
    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo != null && pathInfo.matches("/\\d+")) {
            viewEventOrders(request, response, user);
        } else {
            listAllOrders(request, response, user);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        String pathInfo = request.getPathInfo();
        if ("/confirm-payment".equals(pathInfo)) {
            handleOrderAction(request, response, user, true);
        } else if ("/cancel".equals(pathInfo)) {
            handleOrderAction(request, response, user, false);
        } else {
            response.sendRedirect(request.getContextPath() + "/organizer/orders");
        }
    }

    private void listAllOrders(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        try {
            List<Event> myEvents = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "edit");
            request.setAttribute("myEvents", myEvents);

            int totalPaid = 0;
            int totalPending = 0;
            int totalCanceled = 0;
            double totalRevenueStr = 0;

            String eventIdStr = request.getParameter("eventId");
            int page = parseIntOrDefault(request.getParameter("page"), 1);

            List<Order> allOrders = new java.util.ArrayList<>();
            List<Order> displayOrders = new java.util.ArrayList<>();

            if (eventIdStr != null && !eventIdStr.isEmpty()) {
                int eventId = parseIntOrDefault(eventIdStr, -1);
                boolean ownsEvent = myEvents.stream().anyMatch(e -> e.getEventId() == eventId);
                if (ownsEvent) {
                    allOrders = orderService.getOrdersByEvent(eventId, 1, 9999);
                    displayOrders = orderService.getOrdersByEvent(eventId, page, 50);
                    request.setAttribute("selectedEventId", eventId);
                }
            } else {
                for (Event e : myEvents) {
                    allOrders.addAll(orderService.getOrdersByEvent(e.getEventId(), 1, 9999));
                }
                // Sort allOrders descending by created_at since it's merged
                allOrders.sort((o1, o2) -> o2.getCreatedAt().compareTo(o1.getCreatedAt()));
                int start = (page - 1) * 50;
                int end = Math.min(start + 50, allOrders.size());
                if (start < allOrders.size()) {
                    displayOrders = allOrders.subList(start, end);
                }
            }

            for (Order o : allOrders) {
                if (AppConstants.OrderStatus.PAID.getValue().equals(o.getStatus())) {
                    totalPaid++;
                    totalRevenueStr += o.getFinalAmount();
                } else if (AppConstants.OrderStatus.PENDING.getValue().equals(o.getStatus())) {
                    totalPending++;
                } else if (AppConstants.OrderStatus.CANCELLED.getValue().equals(o.getStatus())) {
                    totalCanceled++;
                }
            }

            request.setAttribute("orders", displayOrders);

            request.setAttribute("totalPaid", totalPaid);
            request.setAttribute("totalPending", totalPending);
            request.setAttribute("totalCanceled", totalCanceled);
            request.setAttribute("totalRevenue", totalRevenueStr);

            request.getRequestDispatcher("/organizer/orders.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer orders", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void viewEventOrders(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        int eventId = getIdFromPath(request.getPathInfo());
        if (eventId <= 0 || !eventService.hasManagerPermission(eventId, user.getUserId(), user.getRole())) {
            com.sellingticket.util.ServletUtil.setToast(request, "Bạn không có quyền xem đơn hàng này!", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/orders");
            return;
        }

        Event event = eventService.getEventDetails(eventId);
        if (event == null) {
            com.sellingticket.util.ServletUtil.setToast(request, "Đơn hàng không tồn tại!", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/orders");
            return;
        }

        int page = parseIntOrDefault(request.getParameter("page"), 1);
        request.setAttribute("event", event);
        request.setAttribute("orders", orderService.getOrdersByEvent(eventId, page, 20));
        request.getRequestDispatcher("/organizer/event-orders.jsp").forward(request, response);
    }

    private void handleOrderAction(HttpServletRequest request, HttpServletResponse response,
                                   User user, boolean isConfirm) throws IOException {

        int orderId = parseIntOrDefault(request.getParameter("orderId"), -1);
        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);

        if (orderId <= 0 || eventId <= 0) {
            com.sellingticket.util.ServletUtil.setToast(request, "Thao tác trên đơn hàng thất bại!", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/orders");
            return;
        }

        Event event = eventService.getEventDetails(eventId);
        if (event == null || !eventService.hasManagerPermission(eventId, user.getUserId(), user.getRole())) {
            com.sellingticket.util.ServletUtil.setToast(request, "Thao tác trên đơn hàng thất bại!", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/orders");
            return;
        }

        boolean success = isConfirm ? orderService.markAsPaid(orderId) : orderService.cancelOrder(orderId);
        String resultParam = success
                ? "success=" + (isConfirm ? "confirmed" : "cancelled")
                : "error=" + (isConfirm ? "confirm_failed" : "cancel_failed");

        String redirectPath = success
                ? "/organizer/orders/" + eventId + "?" + resultParam
                : "/organizer/orders?" + resultParam;

        response.sendRedirect(request.getContextPath() + redirectPath);
    }
}
