# 15. Learning Path for Beginner

## Thứ tự đọc để hiểu nhanh
1. `web.xml`
2. `login.jsp`
3. `LoginServlet`
4. `AuthFilter`
5. `CsrfFilter`
6. `UserService` + `UserDAO`
7. `EventService` + `EventDAO`
8. `CheckoutServlet`
9. `OrderService` + `OrderDAO`
10. `TicketService` + `TicketDAO`
11. `AdminEventController`
12. `AdminOrderController`
13. `StaffCheckInController`
14. `ticketbox_schema.sql`

## Học theo câu hỏi
- Login chạy qua đâu?
- Vì sao vào admin bị chặn?
- Checkout trừ vé ở đâu?
- Payment confirm có chống lặp không?
- Check-in cập nhật gì trong DB?

## Điểm dễ nhầm
- Session vs JWT cookie
- Role hệ thống vs quyền theo event
- Order pending vs paid vs checked_in
- Ticket type vs ticket issued

## Cách học hiệu quả
- Mở một file JSP, tìm form action.
- Đi tới servlet nhận request.
- Xem service gọi DAO gì.
- Đọc query SQL tương ứng trong schema.

## Tóm tắt dễ nhớ
Đừng đọc source theo file ngẫu nhiên. Hãy đọc theo luồng người dùng thật.

## File nên mở tiếp theo
- Bắt đầu lại từ `00_READ_FIRST.md` khi quên luồng.

## Điểm người mới hay nhầm
- Cố nhớ hết ngay. Hãy nhớ 4 đường chính: auth, event, checkout, admin.
