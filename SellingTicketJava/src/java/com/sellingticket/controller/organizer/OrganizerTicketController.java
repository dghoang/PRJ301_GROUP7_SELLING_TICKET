package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.service.TicketService;
import com.sellingticket.util.InputValidator;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Organizer ticket type management.
 * GET  — displays all ticket types grouped by event.
 * POST — create, update, or delete a ticket type.
 */
@WebServlet(name = "OrganizerTicketController", urlPatterns = {"/organizer/tickets"})
public class OrganizerTicketController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerTicketController.class.getName());
    private EventService eventService;
    private TicketService ticketService;

    @Override
    public void init() throws ServletException {
        eventService = new EventService();
        ticketService = new TicketService();
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        try {
            List<Event> events = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "edit");
            LOGGER.info("[TICKET-DEBUG] userId=" + user.getUserId() + " role=" + user.getRole() + " eventsCount=" + events.size());

            List<Integer> eventIds = new ArrayList<>();
            for (Event e : events) { eventIds.add(e.getEventId()); }
            LOGGER.info("[TICKET-DEBUG] eventIds=" + eventIds);

            Map<Integer, List<TicketType>> ticketMap = eventIds.isEmpty()
                    ? Collections.emptyMap()
                    : ticketService.getTicketsByEventIds(eventIds);
            LOGGER.info("[TICKET-DEBUG] ticketMapSize=" + ticketMap.size() + " totalTickets=" + ticketMap.values().stream().mapToInt(List::size).sum());

            // Hydrate eventTitle on each TicketType for JSP display
            Map<Integer, String> eventTitleMap = new java.util.HashMap<>();
            for (Event e : events) { eventTitleMap.put(e.getEventId(), e.getTitle()); }
            for (List<TicketType> list : ticketMap.values()) {
                for (TicketType tt : list) {
                    tt.setEventTitle(eventTitleMap.getOrDefault(tt.getEventId(), ""));
                }
            }

            List<TicketType> allTicketTypes = new ArrayList<>();
            int filterEventId = parseIntOrDefault(request.getParameter("eventId"), 0);
            if (filterEventId > 0) {
                if (ticketMap.containsKey(filterEventId)) {
                    allTicketTypes.addAll(ticketMap.get(filterEventId));
                }
            } else {
                for (List<TicketType> list : ticketMap.values()) {
                    allTicketTypes.addAll(list);
                }
            }
            LOGGER.info("[TICKET-DEBUG] allTicketTypesCount=" + allTicketTypes.size());

            request.setAttribute("events", events);
            request.setAttribute("ticketMap", ticketMap);

            // In-memory pagination
            int page = Math.max(1, parseIntOrDefault(request.getParameter("page"), 1));
            int size = Math.max(1, Math.min(200, parseIntOrDefault(request.getParameter("size"), 20)));
            int totalRecords = allTicketTypes.size();
            int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / size));
            page = Math.min(page, totalPages);
            int fromIndex = (page - 1) * size;
            int toIndex = Math.min(fromIndex + size, totalRecords);
            List<TicketType> pagedTickets = (fromIndex < totalRecords)
                    ? allTicketTypes.subList(fromIndex, toIndex)
                    : Collections.emptyList();

            request.setAttribute("ticketTypes", pagedTickets);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("pageSize", size);
            request.setAttribute("totalRecords", totalRecords);
            request.getRequestDispatcher("/organizer/tickets.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer tickets", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        try {
            request.setCharacterEncoding("UTF-8");
            String action = request.getParameter("action");

            switch (action != null ? action : "") {
                case "create" -> handleCreate(request, user);
                case "update" -> handleUpdate(request, user);
                case "delete" -> handleDelete(request, user);
                default -> setToast(request, "Hành động không hợp lệ", "error");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in OrganizerTicketController.doPost", e);
            setToast(request, "Đã xảy ra lỗi, vui lòng thử lại", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/tickets");
    }

    private void handleCreate(HttpServletRequest request, User user) {
        int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);
        if (!eventService.hasEditPermission(eventId, user.getUserId(), user.getRole())) {
            setToast(request, "Bạn không có quyền thêm vé cho sự kiện này", "error");
            return;
        }

        String name = request.getParameter("typeName");
        double price = parseDoubleOrDefault(request.getParameter("price"), -1);
        int quantity = parseIntOrDefault(request.getParameter("quantity"), 0);

        if (!InputValidator.isValidTicketTypeName(name)) {
            setToast(request, "Tên loại vé phải từ 1-100 ký tự", "error"); return;
        }
        if (!InputValidator.isNonNegative(price)) {
            setToast(request, "Giá vé không hợp lệ", "error"); return;
        }
        if (quantity < 1) {
            setToast(request, "Số lượng vé phải >= 1", "error"); return;
        }

        TicketType tt = new TicketType();
        tt.setEventId(eventId);
        tt.setName(name.trim());
        tt.setPrice(price);
        tt.setQuantity(quantity);
        tt.setDescription(InputValidator.truncate(request.getParameter("description"), 2000));

        boolean ok = ticketService.createTicketType(tt);
        setToast(request, ok ? "Tạo loại vé thành công!" : "Tạo loại vé thất bại!", ok ? "success" : "error");
    }

    private void handleUpdate(HttpServletRequest request, User user) {
        int id = parseIntOrDefault(request.getParameter("ticketTypeId"), 0);
        TicketType tt = ticketService.getTicketTypeById(id);
        if (tt == null) { setToast(request, "Không tìm thấy loại vé", "error"); return; }

        if (!eventService.hasEditPermission(tt.getEventId(), user.getUserId(), user.getRole())) {
            setToast(request, "Bạn không có quyền sửa vé này", "error");
            return;
        }

        String name = request.getParameter("typeName");
        double price = parseDoubleOrDefault(request.getParameter("price"), -1);
        int quantity = parseIntOrDefault(request.getParameter("quantity"), 0);

        if (!InputValidator.isValidTicketTypeName(name)) {
            setToast(request, "Tên loại vé phải từ 1-100 ký tự", "error"); return;
        }
        if (!InputValidator.isNonNegative(price)) {
            setToast(request, "Giá vé không hợp lệ", "error"); return;
        }
        if (quantity < 1) {
            setToast(request, "Số lượng vé phải >= 1", "error"); return;
        }

        tt.setName(name.trim());
        tt.setPrice(price);
        tt.setQuantity(quantity);
        tt.setDescription(InputValidator.truncate(request.getParameter("description"), 2000));
        ticketService.updateTicketType(tt);
        setToast(request, "Cập nhật loại vé thành công!", "success");
    }

    private void handleDelete(HttpServletRequest request, User user) {
        int id = parseIntOrDefault(request.getParameter("ticketTypeId"), 0);
        TicketType tt = ticketService.getTicketTypeById(id);
        if (tt != null) {
            if (!eventService.hasEditPermission(tt.getEventId(), user.getUserId(), user.getRole())) {
                setToast(request, "Bạn không có quyền xóa vé này", "error");
                return;
            }
            ticketService.deleteTicketType(id);
            setToast(request, "Đã xóa loại vé!", "success");
        } else {
            setToast(request, "Không tìm thấy loại vé", "error");
        }
    }
}
