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
import java.util.logging.Level;
import java.util.logging.Logger;
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

    private static final Logger LOGGER = Logger.getLogger(OrganizerEventController.class.getName());
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
        if (user == null) { redirectToLogin(request, response); return; }

        try {
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
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer events", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // ========================
    // POST ROUTING
    // ========================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        String path = request.getServletPath();
        String pathInfo = request.getPathInfo();

        if ("/organizer/create-event".equals(path)) {
            createEvent(request, response);
        } else if ("/update".equals(pathInfo)) {
            updateEvent(request, response, user);
        } else if ("/delete".equals(pathInfo)) {
            deleteEvent(request, response, user);
        } else if ("/submit-draft".equals(pathInfo)) {
            submitDraft(request, response, user);
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
        String userRole = user.getRole();
        boolean isAdmin = "admin".equals(userRole);
        List<Event> events = eventService.getAccessibleEvents(user.getUserId(), userRole);
        request.setAttribute("events", events);
        request.setAttribute("isAdmin", isAdmin);

        // Compute user's specific role for each event (to control UI buttons)
        java.util.Map<Integer, String> eventRoles = new java.util.HashMap<>();
        for (Event e : events) {
            eventRoles.put(e.getEventId(), eventService.getUserEventRole(e.getEventId(), user.getUserId(), userRole));
        }
        request.setAttribute("eventRoles", eventRoles);

        // Summary stats computed from events list
        int totalSold = 0;
        double totalRevenue = 0;
        int countApproved = 0, countPending = 0, countDraft = 0, countEnded = 0;
        for (Event e : events) {
            totalSold += e.getSoldTickets();
            totalRevenue += e.getRevenue();
            switch (e.getStatus() != null ? e.getStatus() : "") {
                case "approved": countApproved++; break;
                case "pending":  countPending++;  break;
                case "draft":    countDraft++;     break;
                default:         countEnded++;     break;
            }
        }
        request.setAttribute("totalSold", totalSold);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("countAll", events.size());
        request.setAttribute("countApproved", countApproved);
        request.setAttribute("countPending", countPending);
        request.setAttribute("countDraft", countDraft);
        request.setAttribute("countEnded", countEnded);

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
            setToast(request, "Bạn đã đạt giới hạn sự kiện đang chờ duyệt (tối đa 3). Bạn vẫn có thể lưu bản nháp.", "warning");
        }
        request.setAttribute("categories", categoryService.getAllCategories());
        request.setAttribute("canSubmitForApproval", eventService.canUserCreateEvent(user.getUserId()));
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

        // Determine intended status from form (draft or pending)
        String requestedStatus = request.getParameter("status");
        boolean isDraft = "draft".equals(requestedStatus);

        // Only check pending limit when submitting for approval (not drafts)
        if (!isDraft && !eventService.canUserCreateEvent(user.getUserId())) {
            setToast(request, "Bạn đã đạt giới hạn sự kiện đang chờ duyệt (tối đa 3)", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        try {
            // Validate inputs before processing
            String title = request.getParameter("title");
            String shortDescription = request.getParameter("shortDescription");
            String description = request.getParameter("description");
            int categoryId = parseIntOrDefault(request.getParameter("category"), -1);

            // Build event early so we can preserve form state on errors
            Event event = buildEventFromRequest(request, user, categoryId);
            List<TicketType> tickets = null;
            try {
                tickets = parseTicketTypes(request);
            } catch (IllegalArgumentException ignored) {
                // Will be caught in validation below
            }

            if (!InputValidator.isValidEventTitle(title)) {
                returnFormWithError(request, response, user, event, tickets, "Tên sự kiện phải từ 3-200 ký tự");
                return;
            }
            if (!InputValidator.isValidText(shortDescription, 10, 500)) {
                returnFormWithError(request, response, user, event, tickets, "Mô tả ngắn phải từ 10-500 ký tự");
                return;
            }
            if (!InputValidator.isValidDescription(description)) {
                returnFormWithError(request, response, user, event, tickets, "Mô tả phải từ 10-500,000 ký tự");
                return;
            }
            if (categoryId <= 0 || categoryService.getCategoryById(categoryId) == null) {
                returnFormWithError(request, response, user, event, tickets, "Danh mục không hợp lệ");
                return;
            }
            if (!InputValidator.isNotBlank(event.getLocation())) {
                returnFormWithError(request, response, user, event, tickets, "Vui lòng nhập địa điểm sự kiện");
                return;
            }

            // Validate: start date is required
            if (event.getStartDate() == null) {
                returnFormWithError(request, response, user, event, tickets, "Vui lòng chọn ngày bắt đầu sự kiện");
                return;
            }
            // Validate: event start date must not be in the past
            if (event.getStartDate().before(new java.util.Date())) {
                returnFormWithError(request, response, user, event, tickets, "Ngày bắt đầu sự kiện không được trong quá khứ. Vui lòng chọn ngày từ hôm nay trở đi.");
                return;
            }
            // Validate: end date must be after start date
            if (event.getEndDate() != null && event.getEndDate().before(event.getStartDate())) {
                returnFormWithError(request, response, user, event, tickets, "Ngày kết thúc phải sau ngày bắt đầu");
                return;
            }

            uploadBanner(request, event, user);

            // Set status based on user choice: draft saves without approval, pending submits for review
            event.setStatus(isDraft ? "draft" : "pending");
            event.setFeatured(false);

            if (tickets == null || tickets.isEmpty()) {
                returnFormWithError(request, response, user, event, tickets, "Phải có ít nhất 1 loại vé hợp lệ");
                return;
            }

            if (eventService.createEventWithTickets(event, tickets)) {
                if (isDraft) {
                    setToast(request, "Đã lưu bản nháp sự kiện thành công!", "success");
                } else {
                    setToast(request, "Tạo sự kiện thành công! Đang chờ Admin duyệt.", "success");
                }
                response.sendRedirect(request.getContextPath() + "/organizer/events");
            } else {
                returnFormWithError(request, response, user, event, tickets, "Không thể tạo sự kiện. Vui lòng thử lại.");
            }
        } catch (IllegalArgumentException e) {
            returnFormWithError(request, response, user, null, null, "Dữ liệu nhập không hợp lệ: " + e.getMessage());
        }
    }

    /** Return to create form with error message and preserved form data. */
    private void returnFormWithError(HttpServletRequest request, HttpServletResponse response,
            User user, Event event, List<TicketType> tickets, String errorMessage)
            throws ServletException, IOException {
        request.setAttribute("error", errorMessage);
        request.setAttribute("formEvent", event);
        request.setAttribute("formTickets", tickets);
        request.setAttribute("categories", categoryService.getAllCategories());
        request.getRequestDispatcher("/organizer/create-event.jsp").forward(request, response);
    }

    private void updateEvent(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        Event existing = (eventId > 0) ? eventService.getEventDetails(eventId) : null;
        if (existing == null || !eventService.hasEditPermission(eventId, user.getUserId(), user.getRole())) {
            setToast(request, "Cập nhật thất bại hoặc không có quyền", "error");
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

            // Event ticket settings
            existing.setMaxTicketsPerOrder(parseIntOrDefault(request.getParameter("maxTicketsPerOrder"), existing.getMaxTicketsPerOrder()));
            existing.setMaxTotalTickets(parseIntOrDefault(request.getParameter("maxTotalTickets"), existing.getMaxTotalTickets()));
            existing.setPreOrderEnabled("true".equals(request.getParameter("preOrderEnabled")));

            // Validate: start date must not be in the past (for new dates only)
            if (existing.getStartDate() != null && existing.getStartDate().before(new java.util.Date())) {
                setToast(request, "Ngày bắt đầu sự kiện không được trong quá khứ", "error");
                response.sendRedirect(request.getContextPath() + "/organizer/events/" + eventId + "/edit");
                return;
            }
            // Validate: end date must be after start date
            if (existing.getEndDate() != null && existing.getStartDate() != null
                    && existing.getEndDate().before(existing.getStartDate())) {
                setToast(request, "Ngày kết thúc phải sau ngày bắt đầu", "error");
                response.sendRedirect(request.getContextPath() + "/organizer/events/" + eventId + "/edit");
                return;
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

        if (eventId > 0 && eventService.hasDeletePermission(eventId, user.getUserId(), user.getRole())
                && eventService.deleteEvent(eventId)) {
            setToast(request, "Đã xóa sự kiện", "success");
        } else {
            setToast(request, "Xóa thất bại hoặc không có quyền", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/events");
    }

    /** Submit a draft event for admin approval (draft → pending). */
    private void submitDraft(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        if (eventId <= 0) {
            setToast(request, "Sự kiện không hợp lệ", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        Event event = eventService.getEventDetails(eventId);
        if (event == null || !"draft".equals(event.getStatus())) {
            setToast(request, "Chỉ có thể gửi duyệt sự kiện ở trạng thái bản nháp", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        if (!eventService.hasEditPermission(eventId, user.getUserId(), user.getRole())) {
            setToast(request, "Bạn không có quyền thao tác sự kiện này", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        if (!eventService.canUserCreateEvent(user.getUserId())) {
            setToast(request, "Bạn đã đạt giới hạn 3 sự kiện chờ duyệt. Vui lòng chờ Admin xử lý.", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events");
            return;
        }

        // Validate: start date must not be in the past when submitting
        if (event.getStartDate() != null && event.getStartDate().before(new java.util.Date())) {
            setToast(request, "Ngày bắt đầu sự kiện đã qua. Vui lòng chỉnh sửa trước khi gửi duyệt.", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/events/" + eventId + "/edit");
            return;
        }

        if (eventService.submitDraftForApproval(eventId)) {
            setToast(request, "Đã gửi sự kiện lên Admin duyệt thành công!", "success");
        } else {
            setToast(request, "Gửi duyệt thất bại. Vui lòng thử lại.", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/events");
    }

    // ========================
    // POST HANDLERS: STAFF
    // ========================

    private void manageStaff(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Event event = getAccessibleEvent(request.getPathInfo(), user);
        if (event == null || !eventService.hasVoucherPermission(event.getEventId(), user.getUserId(), user.getRole())) {
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

        if (eventService.hasVoucherPermission(eventId, user.getUserId(), user.getRole())
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

        if (eventService.hasVoucherPermission(eventId, user.getUserId(), user.getRole())
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

    /** Get event only if the current user has manager permission (includes admin bypass). */
    private Event getAccessibleEvent(String pathInfo, User user) {
        int eventId = getIdFromPath(pathInfo);
        if (eventId <= 0) return null;
        if (!eventService.hasManagerPermission(eventId, user.getUserId(), user.getRole())) return null;
        return eventService.getEventDetails(eventId);
    }

    /** Extract event fields from form parameters. */
    private Event buildEventFromRequest(HttpServletRequest request, User user, int categoryId) {
        Event event = new Event();
        event.setOrganizerId(user.getUserId());
        event.setCategoryId(categoryId);
        event.setTitle(request.getParameter("title"));
        event.setSlug(generateSlug(request.getParameter("title")));
        event.setShortDescription(request.getParameter("shortDescription"));
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

        // Event ticket settings
        event.setMaxTicketsPerOrder(parseIntOrDefault(request.getParameter("maxTicketsPerOrder"), 0));
        event.setMaxTotalTickets(parseIntOrDefault(request.getParameter("maxTotalTickets"), 0));
        event.setPreOrderEnabled("true".equals(request.getParameter("preOrderEnabled")));

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
        if (names.length != prices.length || prices.length != quantities.length) {
            throw new IllegalArgumentException("Ticket fields do not match");
        }

        for (int i = 0; i < names.length; i++) {
            String ticketName = names[i] == null ? "" : names[i].trim();
            if (ticketName.isEmpty()) continue;

            double ticketPrice = Double.parseDouble(prices[i]);
            int ticketQuantity = Integer.parseInt(quantities[i]);

            if (!InputValidator.isValidTicketTypeName(ticketName)
                    || !InputValidator.isNonNegative(ticketPrice)
                    || ticketQuantity <= 0) {
                throw new IllegalArgumentException("Invalid ticket type");
            }

            TicketType ticket = new TicketType();
            ticket.setName(ticketName);
            ticket.setPrice(ticketPrice);
            ticket.setQuantity(ticketQuantity);
            tickets.add(ticket);
        }

        return tickets;
    }
}
