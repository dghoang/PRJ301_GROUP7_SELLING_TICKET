# 03. Folder File Map

## Cấu trúc chính
- `src/java/com/sellingticket/controller`: các Servlet xử lý request.
- `src/java/com/sellingticket/service`: business logic.
- `src/java/com/sellingticket/dao`: truy cập database.
- `src/java/com/sellingticket/model`: entity/model.
- `src/java/com/sellingticket/filter`: auth, CSRF, security headers.
- `src/java/com/sellingticket/util`: helper, JWT, password, DB.
- `src/webapp`: JSP, assets, tags.
- `database/schema`: schema SQL Server.

## File lõi theo vai trò
| File | Vai trò | Gọi bởi | Gọi tiếp |
|---|---|---|---|
| `LoginServlet.java` | đăng nhập | `login.jsp`, `AuthFilter` redirect | `UserService`, `AuthTokenService` |
| `AuthFilter.java` | chặn URL theo session/JWT/role | `web.xml` | `AuthTokenService`, `ServletUtil` |
| `CsrfFilter.java` | CSRF protection | `web.xml` | `JwtUtil` |
| `CheckoutServlet.java` | checkout/order/payment | `checkout.jsp`, route `/checkout` | `OrderService`, `TicketService`, `VoucherService` |
| `OrderDAO.java` | tạo đơn atomic, cancel, confirm pay | `OrderService` | `Orders`, `OrderItems`, `TicketTypes` |
| `TicketDAO.java` | phát hành vé, check-in | `OrderService`, staff controller | `Tickets` |
| `EventService.java` | logic sự kiện + permission | nhiều controller | `EventDAO`, `TicketTypeDAO`, `EventStaffDAO` |
| `AdminEventController.java` | admin event CRUD/approve | `/admin/events` | `EventService`, `ActivityLogService` |
| `AdminUserController.java` | admin user CRUD/role | `/admin/users` | `UserService`, `ActivityLogService` |
| `StaffCheckInController.java` | staff check-in vé | `/staff/check-in` | `EventService`, `TicketDAO` |

## File người mới nên đọc đầu tiên
1. `web.xml`
2. `LoginServlet.java`
3. `AuthFilter.java`
4. `CheckoutServlet.java`
5. `OrderDAO.java`
6. `EventService.java`
7. `database/schema/ticketbox_schema.sql`

## Tóm tắt dễ nhớ
Controller nhận request, service quyết định nghiệp vụ, DAO chạm DB.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/04_ARCHITECTURE_FLOW.md`

## Điểm người mới hay nhầm
- Nhìn JSP tưởng là nơi xử lý nghiệp vụ, nhưng đa số chỉ render form và gọi AJAX.
