# 09. CRUD Analysis

## User
- Create: `RegisterServlet -> UserService.registerFull() -> UserDAO.registerFull()`
- Read: `UserService.getUserById()`, `getAllUsers()`, `searchUsers()`
- Update: `ProfileServlet`, `AdminUserController.updateRole()`
- Delete/Deactivate: `UserDAO.deactivateUser()`

## Event
- Create: `EventService.createEventWithTickets()`
- Read: `EventService.getEventDetails()`, `getAllEvents()`, `searchEvents()`
- Update: `AdminEventController.updateEvent()`, `EventService.updateEvent()`
- Delete: `EventService.deleteEvent()`

## Ticket Type
- Create: `OrganizerTicketController.handleCreate()`
- Read: `TicketService.getTicketsByEvent()`
- Update: `OrganizerTicketController.handleUpdate()`
- Delete/soft delete: `TicketTypeDAO.deleteTicketType()`

## Order/Booking
- Create: `CheckoutServlet -> OrderService.createOrder() -> OrderDAO.createOrderAtomic()`
- Read: `OrderService.getOrderById()`, `getOrdersByUserPaged()`, `getAllOrders()`
- Update status: `confirmPayment()`, `cancelOrder()`, `approveRefund()`, `checkInOrder()`

## Payment
- Process: `OrderService.processPayment()`
- Confirm webhook: `OrderService.confirmPayment()`
- Transaction log: `PaymentTransactions`

## Category/Venue/Staff
- Category: có DAO/service, chủ yếu admin quản lý
- Venue: trong source hiện tại venue nằm chung trong event (`location`, `address`), chưa thấy bảng riêng
- Staff: `EventStaffDAO` + route organizer/staff

## Validate
- Backend có validate ở nhiều controller/service.
- Frontend JSP có hiển thị form/regex nhưng không thay thế backend.

## Tóm tắt dễ nhớ
CRUD không nằm ở một chỗ. Mỗi module có controller riêng nhưng đều đi qua service/DAO.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/10_DATABASE_ANALYSIS.md`

## Điểm người mới hay nhầm
- Tưởng update role hoặc status là “đơn giản”. Thực tế cần kiểm tra ngữ cảnh nghiệp vụ.
