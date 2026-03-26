# 16. Short Flow Diagrams

## 1) Luồng đăng nhập
```mermaid
flowchart TD
    A["login.jsp"] --> B["POST /login"]
    B --> C["LoginServlet"]
    C --> D["UserService.authenticate()"]
    D --> E["UserDAO.login()"]
    E --> F{"Đúng email + mật khẩu?"}
    F -- "Không" --> G["Trả lỗi về login.jsp"]
    F -- "Có" --> H["Reset session + set user/account"]
    H --> I["Issue JWT cookies"]
    I --> J["Redirect returnUrl hoặc /home"]
```

## 2) Luồng xem sự kiện
```mermaid
flowchart TD
    A["home.jsp / events.jsp"] --> B["GET /home hoặc /events"]
    B --> C["HomeServlet / EventsServlet"]
    C --> D["EventService"]
    D --> E["EventDAO + TicketTypeDAO"]
    E --> F["SQL Server"]
    F --> G["Forward JSP hiển thị danh sách"]
```

## 3) Luồng checkout đặt vé
```mermaid
flowchart TD
    A["ticket-selection.jsp / checkout.jsp"] --> B["POST /checkout"]
    B --> C["CheckoutServlet"]
    C --> D["Validate login + CSRF + input"]
    D --> E["EventService + TicketService"]
    E --> F["Kiểm tra event approved + còn bán"]
    F --> G["OrderService.createOrder()"]
    G --> H["OrderDAO.createOrderAtomic()"]
    H --> I["Lock TicketTypes + tăng sold_quantity"]
    I --> J["Insert Orders + OrderItems"]
    J --> K["Order thành công"]
    K --> L["Process payment pending"]
    L --> M["payment-pending.jsp"]
```

## 4) Luồng thanh toán SeePay
```mermaid
flowchart TD
    A["payment-pending.jsp"] --> B["SeePay redirect/webhook"]
    B --> C["PaymentStatusServlet / SeepayWebhookServlet"]
    C --> D["OrderService.confirmPayment()"]
    D --> E["OrderDAO.confirmPaymentAtomic()"]
    E --> F{"Order còn pending?"}
    F -- "Không" --> G["Bỏ qua để chống xử lý lặp"]
    F -- "Có" --> H["Update order = paid"]
    H --> I["OrderDAO.updateTransactionId()"]
    I --> J["TicketDAO.createTicketsForOrder()"]
```

## 5) Luồng check-in staff
```mermaid
flowchart TD
    A["staff/check-in.jsp"] --> B["GET /staff/check-in"]
    B --> C["StaffCheckInController"]
    C --> D["EventStaffDAO + EventService.hasCheckInPermission()"]
    D --> E["Chọn event được gán"]
    E --> F["POST mã vé"]
    F --> G["TicketDAO.getTicketByCode()"]
    G --> H{"Vé hợp lệ và chưa check-in?"}
    H -- "Không" --> I["Trả lỗi JSON"]
    H -- "Có" --> J["TicketDAO.checkInTicket()"]
    J --> K["Update Tickets + Order status checked_in"]
```

## 6) Luồng quản lý user của admin
```mermaid
flowchart TD
    A["admin/users.jsp"] --> B["GET /admin/users"]
    B --> C["AdminUserController"]
    C --> D["UserService.getAllUsers() / searchUsers()"]
    D --> E["UserDAO"]
    E --> F["SQL Server"]
    F --> G["Forward /admin/users.jsp"]
    G --> H["POST update-role / activate / deactivate"]
    H --> I["UserService"]
    I --> J["UserDAO update"]
```

## 7) Luồng quản lý event của admin
```mermaid
flowchart TD
    A["admin/events.jsp"] --> B["GET /admin/events"]
    B --> C["AdminEventController"]
    C --> D["EventService.getAllEvents() / getPendingEvents()"]
    D --> E["EventDAO"]
    E --> F["SQL Server"]
    F --> G["Forward admin view"]
    G --> H["POST approve/reject/update/delete"]
    H --> I["EventService"]
    I --> J["EventDAO update"]
    J --> K["ActivityLogService ghi log"]
```

## Tóm tắt dễ nhớ
- Login: JSP -> Servlet -> Service -> DAO -> session/JWT.
- Checkout: validate nhiều lớp rồi mới atomic reserve vé.
- Check-in: verify quyền theo event rồi update ticket/order.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/00_READ_FIRST.md`

## Điểm người mới hay nhầm
- Sơ đồ slide nên ngắn, chỉ giữ 5-7 bước chính. Đừng nhét quá nhiều chi tiết vào một flow.
