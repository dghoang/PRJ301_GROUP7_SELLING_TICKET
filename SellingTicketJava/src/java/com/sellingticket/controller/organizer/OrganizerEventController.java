package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import com.sellingticket.model.User;
import com.sellingticket.service.CategoryService;
import com.sellingticket.service.EventService;
import com.sellingticket.service.OrderService;
import com.sellingticket.service.TicketService;
import com.sellingticket.util.CloudinaryUtil;
import static com.sellingticket.util.ServletUtil.*;
import com.sellingticket.util.InputValidator;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

/**
 * Core controller for organizer event lifecycle.
 * <ul>
 *   <li>GET  — list events, view detail, show create/edit forms, manage staff</li>
 *   <li>POST — create, update, delete events; add/remove staff</li>
 * </ul>
 */
@WebServlet(name = "OrganizerEventController", urlPatterns = {
    "/organizer/events", "/organizer/events/*", "/organizer/create-event"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class OrganizerEventController extends HttpServlet {

    private final EventService eventService = new EventService();
    private final CategoryService categoryService = new CategoryService();
    private final TicketService ticketService = new TicketService();
    private final OrderService orderService = new OrderService();
    // Removed: SimpleDateFormat is NOT thread-safe in servlet singletons.
    // Using ServletUtil.parseDateOrNull() instead (thread-safe DateTimeFormatter).

    // ========================
    // GET ROUTING
    // ========================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String path = request.getServletPath();
        String pathInfo = request.getPathInfo();

        if ("/organizer/create-event".equals(path)) {
            showCreateForm(request, response, user);
        } else if (pathInfo != null && pathInfo.matches("/\\d+/edit")) {
            showEditForm(request, response, user);
        } else if (pathInfo != null && pathInfo.matches("/\\d+/staff")) {
            manageStaff(request, response, user);
        } else if (pathInfo != null && pathInfo.matches("/\\d+")) {
            viewEvent(request, response, user);
        } else {
            listEvents(request, response, user);
        }
    }

    // ========================
    // POST ROUTING
    // ========================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String path = request.getServletPath();
        String pathInfo = request.getPathInfo();

        if ("/organizer/create-event".equals(path)) {
            createEvent(request, response);
        } else if ("/update".equals(pathInfo)) {
            updateEvent(request, response, user);
        } else if ("/delete".equals(pathInfo)) {
            deleteEvent(request, response, user);
        } else if ("/staff/add".equals(pathInfo)) {
            addStaff(request, response, user);
        } else if ("/staff/remove".equals(pathInfo)) {
            removeStaff(request, response, user);
        } else {
            response.sendRedirect(request.getContextPath() + "/organizer/events");
        }
    }

    // ========================
    // GET HANDLERS
    // ========================

    private void listEvents(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        request.setAttribute("events", eventService.getEventsByOrganizer(user.getUserId()));
        request.getRequestDispatcher("/organizer/events.jsp").forward(request, response);
    }

    /** Display event detail with check-in stats. */
    private void viewEvent(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Event event = getAccessibleEvent(request.getPathInfo(), user);
        if (event == null) {
            setToast(request, "Không có quyền truy cập sự kiện này", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        int totalOrders = orderService.getOrdersByEvent(event.getEventId(), 1, 9999).size();
        int checkedIn = orderService.getCheckInCount(event.getEventId());
        int checkInRate = totalOrders > 0 ? Math.round(checkedIn * 100f / totalOrders) : 0;

        request.setAttribute("event", event);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("checkedInCount", checkedIn);
        request.setAttribute("checkInRate", checkInRate);
        request.getRequestDispatcher("/organizer/event-detail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        if (!eventService.canUserCreateEvent(user.getUserId())) {
            setToast(request, "Bạn đã đạt giới hạn sự kiện đang chờ duyệt", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }
        request.setAttribute("categories", categoryService.getAllCategories());
        request.getRequestDispatcher("/organizer/create-event.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Event event = getAccessibleEvent(request.getPathInfo(), user);
        if (event == null) {
            setToast(request, "Không có quyền truy cập sự kiện này", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        request.setAttribute("event", event);
        request.setAttribute("categories", categoryService.getAllCategories());
        request.getRequestDispatcher("/organizer/edit-event.jsp").forward(request, response);
    }

    // ========================
    // POST HANDLERS: EVENTS
    // ========================

    private void createEvent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (!eventService.canUserCreateEvent(user.getUserId())) {
            setToast(request, "Bạn đã đạt giới hạn sự kiện đang chờ duyệt", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        try {
            // Validate inputs before processing
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            if (!InputValidator.isValidEventTitle(title)) {
                request.setAttribute("error", "Tên sự kiện phải từ 3-200 ký tự");
                showCreateForm(request, response, user);
                return;
            }
            if (!InputValidator.isValidDescription(description)) {
                request.setAttribute("error", "Mô tả phải từ 10-10,000 ký tự");
                showCreateForm(request, response, user);
                return;
            }

            Event event = buildEventFromRequest(request, user);
            uploadBanner(request, event, user);
            event.setStatus("pending");
            event.setFeatured(false);

            List<TicketType> tickets = parseTicketTypes(request);

            if (eventService.createEventWithTickets(event, tickets)) {
                setToast(request, "Tạo sự kiện thành công! Đang chờ duyệt.", "success");
                response.sendRedirect(request.getContextPath() + "/organizer/events");
            } else {
                request.setAttribute("error", "Failed to create event");
                showCreateForm(request, response, user);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid category or date format");
            showCreateForm(request, response, user);
        }
    }

    private void updateEvent(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        Event existing = (eventId > 0) ? eventService.getEventDetails(eventId) : null;
        if (existing == null || existing.getOrganizerId() != user.getUserId()) {
            setToast(request, "Cập nhật thất bại", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        try {
            existing.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            existing.setTitle(request.getParameter("title"));
            existing.setDescription(request.getParameter("description"));
            existing.setBannerImage(request.getParameter("bannerImage"));
            existing.setLocation(request.getParameter("location"));
            existing.setAddress(request.getParameter("address"));
            existing.setStartDate(parseDateOrNull(request.getParameter("startDate")));

            String endDateStr = request.getParameter("endDate");
            if (endDateStr != null && !endDateStr.isEmpty()) {
                existing.setEndDate(parseDateOrNull(endDateStr));
            }

            if (eventService.updateEvent(existing)) {
                setToast(request, "Cập nhật sự kiện thành công!", "success");
                response.sendRedirect(request.getContextPath() + "/organizer/events/" + eventId);
                return;
            }
        } catch (NumberFormatException e) {
            // fall through to error
        }

        setToast(request, "Cập nhật thất bại", "error");
        response.sendRedirect(request.getContextPath() + "/organizer/events");
    }

    private void deleteEvent(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        Event existing = (eventId > 0) ? eventService.getEventDetails(eventId) : null;

        if (existing != null && existing.getOrganizerId() == user.getUserId() && eventService.deleteEvent(eventId)) {
            setToast(request, "Đã xóa sự kiện", "success");
        } else {
            setToast(request, "Xóa thất bại", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/events");
    }

    // ========================
    // POST HANDLERS: STAFF
    // ========================

    private void manageStaff(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Event event = getAccessibleEvent(request.getPathInfo(), user);
        if (event == null || event.getOrganizerId() != user.getUserId()) {
            setToast(request, "Bạn không có quyền quản lý nhân sự", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        request.setAttribute("event", event);
        request.setAttribute("staff", eventService.getEventStaff(event.getEventId()));
        request.getRequestDispatcher("/organizer/manage-staff.jsp").forward(request, response);
    }

    private void addStaff(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        String email = request.getParameter("email");
        String role = request.getParameter("role");

        if (eventService.hasManagerPermission(eventId, user.getUserId())
                && eventService.addEventStaff(eventId, email, role, user.getUserId())) {
            setToast(request, "Đã thêm cộng tác viên!", "success");
        } else {
            setToast(request, "Thêm cộng tác viên thất bại", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/events/" + eventId + "/staff");
    }

    private void removeStaff(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        int userId = parseIntOrDefault(request.getParameter("userId"), -1);

        if (eventService.hasManagerPermission(eventId, user.getUserId())
                && eventService.removeEventStaff(eventId, userId)) {
            setToast(request, "Đã xóa cộng tác viên!", "success");
        } else {
            setToast(request, "Xóa cộng tác viên thất bại", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/events/" + eventId + "/staff");
    }

    // ========================
    // UTILITY METHODS
    // ========================

    /** Get event only if the current user has manager permission. */
    private Event getAccessibleEvent(String pathInfo, User user) {
        int eventId = getIdFromPath(pathInfo);
        if (eventId <= 0) return null;
        if (!eventService.hasManagerPermission(eventId, user.getUserId())) return null;
        return eventService.getEventDetails(eventId);
    }

    /** Extract event fields from form parameters. */
    private Event buildEventFromRequest(HttpServletRequest request, User user) {
        Event event = new Event();
        event.setOrganizerId(user.getUserId());
        event.setCategoryId(Integer.parseInt(request.getParameter("category")));
        event.setTitle(request.getParameter("title"));
        event.setSlug(generateSlug(request.getParameter("title")));
        event.setDescription(request.getParameter("description"));
        event.setBannerImage(request.getParameter("bannerImage"));
        event.setLocation(request.getParameter("location"));
        event.setAddress(request.getParameter("address"));
        event.setStartDate(parseDateOrNull(request.getParameter("startDate")));
        event.setPrivate("on".equals(request.getParameter("isPrivate")));

        String endDateStr = request.getParameter("endDate");
        if (endDateStr != null && !endDateStr.isEmpty()) {
            event.setEndDate(parseDateOrNull(endDateStr));
        }
        return event;
    }

    /** Upload banner image to Cloudinary if present in the request. */
    private void uploadBanner(HttpServletRequest request, Event event, User user)
            throws IOException, ServletException {
        Part bannerPart = request.getPart("banner");
        if (bannerPart == null || bannerPart.getSize() <= 0) return;

        byte[] bytes = bannerPart.getInputStream().readAllBytes();
        Map<String, Object> uploadResult = CloudinaryUtil.getInstance().upload(
                bytes, "ticketbox/events/" + user.getUserId(), bannerPart.getSubmittedFileName()
        );
        if (uploadResult != null) {
            event.setBannerImage((String) uploadResult.get("url"));
        }
    }

    /** Generate URL-friendly slug from title with timestamp for uniqueness. */
    private String generateSlug(String title) {
        if (title == null) return "";
        return title.toLowerCase()
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-+", "-")
                + "-" + System.currentTimeMillis();
    }

    /** Extract ticket types from form array parameters. */
    private List<TicketType> parseTicketTypes(HttpServletRequest request) {
        List<TicketType> tickets = new ArrayList<>();

        String[] names = request.getParameterValues("ticketName[]");
        String[] prices = request.getParameterValues("ticketPrice[]");
        String[] quantities = request.getParameterValues("ticketQuantity[]");

        if (names == null || prices == null || quantities == null) return tickets;

        for (int i = 0; i < names.length; i++) {
            if (names[i] == null || names[i].isEmpty()) continue;
            TicketType ticket = new TicketType();
            ticket.setName(names[i]);
            ticket.setPrice(Double.parseDouble(prices[i]));
            ticket.setQuantity(Integer.parseInt(quantities[i]));
            tickets.add(ticket);
        }

        return tickets;
    }
}
