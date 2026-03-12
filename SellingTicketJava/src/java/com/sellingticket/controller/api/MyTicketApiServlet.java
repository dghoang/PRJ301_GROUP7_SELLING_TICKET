package com.sellingticket.controller.api;

import com.sellingticket.dao.TicketDAO;
import com.sellingticket.model.PageResult;
import com.sellingticket.model.Ticket;
import com.sellingticket.model.User;
import com.sellingticket.util.JsonResponse;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.text.SimpleDateFormat;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * My Tickets API — JSON endpoint for user's ticket list with search/filter.
 * Requires authenticated user.
 *
 * GET /api/my-tickets?q=keyword&checkedIn=true|false&page=1&size=10
 */
@WebServlet(name = "MyTicketApiServlet", urlPatterns = {"/api/my-tickets"})
public class MyTicketApiServlet extends HttpServlet {

    private TicketDAO ticketDAO;

    @Override
    public void init() {
        ticketDAO = new TicketDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User user = getSessionUser(request);
        if (user == null) {
            JsonResponse.unauthorized().send(response);
            return;
        }

        String keyword = request.getParameter("q");
        String checkedInStr = request.getParameter("checkedIn");
        Boolean isCheckedIn = null;
        if ("true".equals(checkedInStr)) isCheckedIn = true;
        else if ("false".equals(checkedInStr)) isCheckedIn = false;

        int page = parseIntOrDefault(request.getParameter("page"), 1);
        int size = parseIntOrDefault(request.getParameter("size"), 10);

        PageResult<Ticket> result = ticketDAO.getTicketsByUserPaged(
                user.getUserId(), keyword, isCheckedIn, page, size);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

        JsonResponse json = JsonResponse.ok()
                .put("totalItems", result.getTotalItems())
                .put("totalPages", result.getTotalPages())
                .put("currentPage", result.getCurrentPage())
                .put("pageSize", result.getPageSize());

        json.startArray("items");
        for (Ticket t : result.getItems()) {
            StringBuilder item = new StringBuilder("{");
            item.append("\"ticketId\":").append(t.getTicketId()).append(",");
            item.append("\"ticketCode\":\"").append(esc(t.getTicketCode())).append("\",");
            item.append("\"eventTitle\":\"").append(esc(t.getEventTitle())).append("\",");
            item.append("\"eventId\":").append(t.getEventId()).append(",");
            item.append("\"ticketTypeName\":\"").append(esc(t.getTicketTypeName())).append("\",");
            item.append("\"orderCode\":\"").append(esc(t.getOrderCode())).append("\",");
            item.append("\"attendeeName\":\"").append(esc(t.getAttendeeName())).append("\",");
            item.append("\"attendeeEmail\":\"").append(esc(t.getAttendeeEmail())).append("\",");
            item.append("\"qrCode\":\"").append(esc(t.getQrCode())).append("\",");
            item.append("\"isCheckedIn\":").append(t.isCheckedIn()).append(",");
            item.append("\"orderStatus\":\"").append(esc(t.getOrderStatus() != null ? t.getOrderStatus() : "paid")).append("\",");
            item.append("\"orderId\":").append(t.getOrderId()).append(",");
            item.append("\"checkedInAt\":\"").append(t.getCheckedInAt() != null ? sdf.format(t.getCheckedInAt()) : "").append("\",");
            item.append("\"createdAt\":\"").append(t.getCreatedAt() != null ? sdf.format(t.getCreatedAt()) : "").append("\"");
            item.append("}");
            json.arrayElement(item.toString());
        }
        json.endArray();
        json.send(response);
    }

    private static String esc(String v) {
        if (v == null) return "";
        return v.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r");
    }
}
