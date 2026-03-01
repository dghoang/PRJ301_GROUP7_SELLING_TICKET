package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.Order;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.service.OrderService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "OrganizerOrderController", urlPatterns = {"/organizer/orders", "/organizer/orders/*"})
public class OrganizerOrderController extends HttpServlet {

    private final EventService eventService = new EventService();
    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
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
            response.sendRedirect(request.getContextPath() + "/login");
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

        List<Event> myEvents = eventService.getAccessibleEvents(user.getUserId(), user.getRole());
        request.setAttribute("myEvents", myEvents);

        int totalPaid = 0;
        int totalPending = 0;
        int totalCanceled = 0;
        double totalRevenueStr = 0;

        String eventIdStr = request.getParameter("eventId");
        if (eventIdStr != null && !eventIdStr.isEmpty()) {
            int eventId = parseIntOrDefault(eventIdStr, -1);
            boolean ownsEvent = myEvents.stream().anyMatch(e -> e.getEventId() == eventId);
            if (ownsEvent) {
                int page = parseIntOrDefault(request.getParameter("page"), 1);
                
                // Get all orders for stats (page 1, large size just for stats, this could be optimized later with a DAO count method)
                List<Order> allOrders = orderService.getOrdersByEvent(eventId, 1, 9999);
                for (Order o : allOrders) {
                    if ("PAID".equals(o.getStatus())) {
                        totalPaid++;
                        totalRevenueStr += o.getFinalAmount();
                    } else if ("PENDING".equals(o.getStatus())) {
                        totalPending++;
                    } else if ("CANCELED".equals(o.getStatus())) {
                        totalCanceled++;
                    }
                }

                request.setAttribute("orders", orderService.getOrdersByEvent(eventId, page, 50));
                request.setAttribute("selectedEventId", eventId);
            }
        }

        request.setAttribute("totalPaid", totalPaid);
        request.setAttribute("totalPending", totalPending);
        request.setAttribute("totalCanceled", totalCanceled);
        request.setAttribute("totalRevenue", totalRevenueStr);

        request.getRequestDispatcher("/organizer/orders.jsp").forward(request, response);
    }

    private void viewEventOrders(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        int eventId = getIdFromPath(request.getPathInfo());
        if (eventId <= 0 || !eventService.hasManagerPermission(eventId, user.getUserId(), user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/organizer/orders?error=access_denied");
            return;
        }

        Event event = eventService.getEventDetails(eventId);
        if (event == null) {
            response.sendRedirect(request.getContextPath() + "/organizer/orders?error=not_found");
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
            response.sendRedirect(request.getContextPath() + "/organizer/orders?error=action_failed");
            return;
        }

        Event event = eventService.getEventDetails(eventId);
        if (event == null || !eventService.hasManagerPermission(eventId, user.getUserId(), user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/organizer/orders?error=action_failed");
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
