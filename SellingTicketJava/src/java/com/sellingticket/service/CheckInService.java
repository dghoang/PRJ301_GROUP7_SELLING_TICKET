package com.sellingticket.service;

import com.sellingticket.dao.OrderDAO;
import com.sellingticket.dao.TicketDAO;
import com.sellingticket.dto.CheckInResult;
import com.sellingticket.model.Order;
import com.sellingticket.model.Ticket;
import com.sellingticket.model.User;
import com.sellingticket.util.JwtUtil;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Centralized service for ticket check-in logic.
 */
public class CheckInService {
    private static final Logger LOGGER = Logger.getLogger(CheckInService.class.getName());
    private final TicketDAO ticketDAO = new TicketDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final EventService eventService = new EventService();

    /**
     * Handles QR token check-in.
     */
    public CheckInResult handleQrCheckIn(int eventId, String qrToken, User checker) {
        if (qrToken == null || qrToken.trim().isEmpty()) {
            return CheckInResult.error("Mã QR không hợp lệ");
        }

        try {
            // 1. Verify token using the correct util
            Map<String, Object> claims = JwtUtil.verifyTicketToken(qrToken.trim());
            if (claims == null) {
                return CheckInResult.error("QR không hợp lệ hoặc đã hết hạn");
            }

            String ticketCode = (String) claims.get("sub");
            int tokenEventId = ((Number) claims.get("eid")).intValue();
            int ticketId = ((Number) claims.get("tid")).intValue();

            // 2. Load ticket
            Ticket ticket = ticketDAO.getTicketById(ticketId);
            if (ticket == null || !ticket.getTicketCode().equals(ticketCode)) {
                return CheckInResult.error("Vé không tồn tại trong hệ thống");
            }

            // 3. Verify event match and permissions
            if (eventId > 0 && tokenEventId != eventId) {
                return CheckInResult.error("Vé không thuộc sự kiện này! Vé vẫn còn hiệu lực.");
            }
            if (!eventService.hasCheckInPermission(tokenEventId, checker.getUserId(), checker.getRole())) {
                return CheckInResult.error("Bạn không có quyền check-in sự kiện của vé này!");
            }

            // 4. Verify order status (anti-fraud)
            String orderStatus = ticket.getOrderStatus();
            if ("cancelled".equals(orderStatus) || "refunded".equals(orderStatus)) {
                return CheckInResult.error("Đơn hàng đã bị huỷ/hoàn tiền — vé không hợp lệ");
            }
            if (!("paid".equals(orderStatus) || "checked_in".equals(orderStatus))) {
                return CheckInResult.error("Đơn hàng chưa thanh toán — không thể check-in");
            }

            // 5. Check already checked-in
            if (ticket.isCheckedIn()) {
                CheckInResult res = CheckInResult.error("Vé đã được sử dụng trước đó!");
                res.setAlreadyCheckedIn(true);
                res.setCustomerName(ticket.getAttendeeName());
                res.setTicketCode(ticket.getTicketCode());
                return res;
            }

            // 6. Perform check-in
            if (ticketDAO.checkInTicket(ticketId, checker.getUserId())) {
                CheckInResult res = CheckInResult.success("Check-in thành công!");
                res.setCustomerName(ticket.getAttendeeName());
                res.setTicketCode(ticket.getTicketCode());
                res.setTicketType(ticket.getTicketTypeName());
                res.setTicketId(ticketId);
                return res;
            } else {
                return CheckInResult.error("Lỗi cập nhật trạng thái check-in");
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "QR Check-in error", e);
            return CheckInResult.error("Lỗi hệ thống khi xử lý QR");
        }
    }

    /**
     * Handles Order Lookup for manual/lookup check-in.
     */
    public CheckInResult handleOrderLookup(int eventId, String orderCode, User checker) {
        if (orderCode == null || orderCode.trim().isEmpty()) {
            return CheckInResult.error("Mã đơn hàng không được để trống");
        }

        try {
            Order order = orderDAO.getOrderByCode(orderCode.trim());
            if (order == null) return CheckInResult.error("Không tìm thấy đơn hàng");

            if (eventId > 0 && order.getEventId() != eventId) {
                return CheckInResult.error("Mã không thuộc sự kiện này! Vé vẫn còn hiệu lực.");
            }
            if (!eventService.hasCheckInPermission(order.getEventId(), checker.getUserId(), checker.getRole())) {
                return CheckInResult.error("Bạn không có quyền check-in sự kiện của đơn hàng này!");
            }

            if ("cancelled".equals(order.getStatus()) || "refunded".equals(order.getStatus())) {
                return CheckInResult.error("Đơn hàng đã bị huỷ/hoàn tiền — không thể check-in");
            }

            if (!("paid".equals(order.getStatus()) || "checked_in".equals(order.getStatus()))) {
                return CheckInResult.error("Đơn hàng chưa thanh toán (trạng thái: " + order.getStatus() + ")");
            }

            List<Ticket> tickets = ticketDAO.getTicketsByOrder(order.getOrderId());
            if (tickets.isEmpty()) {
                return CheckInResult.error("Đơn hàng chưa được phát vé");
            }

            CheckInResult res = new CheckInResult();
            res.setSuccess(true);
            res.setAction("lookup");
            res.setOrderCode(order.getOrderCode());
            res.setCustomerName(order.getBuyerName());
            
            List<Map<String, Object>> ticketList = new ArrayList<>();
            for (Ticket t : tickets) {
                Map<String, Object> m = new HashMap<>();
                m.put("ticketId", t.getTicketId());
                m.put("ticketCode", t.getTicketCode());
                m.put("attendeeName", t.getAttendeeName());
                m.put("ticketType", t.getTicketTypeName());
                m.put("checkedIn", t.isCheckedIn());
                ticketList.add(m);
            }
            res.setTickets(ticketList);
            return res;

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Order lookup error", e);
            return CheckInResult.error("Lỗi hệ thống khi tra cứu đơn hàng");
        }
    }

    /**
     * Handles check-in for a specific ticket selected from a lookup.
     */
    public CheckInResult handleSingleTicketCheckIn(int eventId, String orderCode, int ticketId, User checker) {
        if (ticketId <= 0) {
            return CheckInResult.error("Vui lòng chọn vé cần check-in");
        }

        try {
            Ticket ticket = ticketDAO.getTicketById(ticketId);
            if (ticket == null || (orderCode != null && !orderCode.equals(ticket.getOrderCode()))) {
                return CheckInResult.error("Vé không hợp lệ");
            }

            if (eventId > 0 && ticket.getEventId() != eventId) {
                return CheckInResult.error("Vé không thuộc sự kiện này!");
            }
            if (!eventService.hasCheckInPermission(ticket.getEventId(), checker.getUserId(), checker.getRole())) {
                return CheckInResult.error("Bạn không có quyền check-in sự kiện của vé này!");
            }

            if (ticket.isCheckedIn()) {
                CheckInResult res = CheckInResult.error("Vé đã check-in rồi");
                res.setAlreadyCheckedIn(true);
                res.setCustomerName(ticket.getAttendeeName());
                return res;
            }

            String orderStatus = ticket.getOrderStatus();
            if ("cancelled".equals(orderStatus) || "refunded".equals(orderStatus)) {
                return CheckInResult.error("Đơn hàng đã bị huỷ/hoàn tiền — không thể check-in");
            }
            if (!("paid".equals(orderStatus) || "checked_in".equals(orderStatus))) {
                return CheckInResult.error("Đơn hàng chưa thanh toán — không thể check-in");
            }

            if (ticketDAO.checkInTicket(ticketId, checker.getUserId())) {
                CheckInResult res = CheckInResult.success("Check-in thành công!");
                res.setCustomerName(ticket.getAttendeeName());
                res.setTicketCode(ticket.getTicketCode());
                res.setTicketType(ticket.getTicketTypeName());
                return res;
            } else {
                return CheckInResult.error("Lỗi hệ thống khi check-in");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Single ticket check-in error", e);
            return CheckInResult.error("Lỗi hệ thống");
        }
    }
}
