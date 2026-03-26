# 10. Database Analysis

## Bảng chính
- `Users`: tài khoản, role, profile, security flags
- `Categories`: danh mục sự kiện
- `Events`: sự kiện
- `TicketTypes`: loại vé và tồn kho
- `Orders`: đơn hàng
- `OrderItems`: chi tiết đơn hàng
- `Tickets`: vé đã phát hành
- `PaymentTransactions`: giao dịch thanh toán
- `Vouchers`: mã giảm giá
- `EventStaff`: staff theo sự kiện
- `SupportTickets`, `TicketMessages`
- `ChatSessions`, `ChatMessages`
- `Notifications`
- `ActivityLog`
- `UserSessions`, `PasswordResets`, `Permissions`, `RolePermissions`

## Bảng trung tâm nghiệp vụ
- `Events`, `TicketTypes`, `Orders`, `OrderItems`, `Tickets`

## Luồng dữ liệu
1. JSP gửi form
2. Servlet validate
3. Service gọi DAO
4. DAO chạy query SQL Server
5. DB trả dữ liệu
6. Service/controller đẩy về JSP hoặc JSON

## Thiết kế tốt
- Có unique key cho email, order_code, ticket_code, voucher code.
- Có index cho `Orders`, `Events`, `TicketTypes`, `ActivityLog`.
- Có `EventStaff` riêng cho quyền theo event.

## Điểm chưa tốt hoặc cần chú ý
- `Venue` chưa tách thành bảng riêng.
- `Users` đang kiêm nhiều loại profile khác nhau.
- `Orders` và `PaymentTransactions` cần đảm bảo đồng bộ trạng thái thật chặt.

## Gợi ý index/constraint
- Unique `Tickets.ticket_code` đã có.
- Unique composite cho `OrderItems(order_id, ticket_type_id)` có thể cân nhắc.
- Index trên `TicketTypes(event_id, is_active)` là tốt.
- Index trên `SupportTickets(status, assigned_to)` có thể hữu ích.

## Tóm tắt dễ nhớ
DB trung tâm là `Orders/TicketTypes/Events`. Vé và đơn là hai bảng cần bảo vệ chặt nhất.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/11_SECURITY_REVIEW.md`

## Điểm người mới hay nhầm
- Nghĩ `Users` là bảng duy nhất quan trọng. Thực tế `Orders` và `TicketTypes` còn quan trọng hơn cho doanh thu.
