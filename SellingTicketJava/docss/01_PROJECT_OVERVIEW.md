# 01. Project Overview

## Dự án làm gì
Đây là web bán vé sự kiện. Người dùng có thể xem sự kiện, chọn loại vé, đặt vé, thanh toán qua SeePay, xem vé đã mua, và gửi ticket hỗ trợ. Nhà tổ chức có thể tạo sự kiện, tạo ticket type, quản lý đơn hàng, voucher và nhân sự theo sự kiện. Admin có thể duyệt sự kiện, quản lý user, đơn hàng, báo cáo và cài đặt.

## Actor chính
- `customer`: người mua vé.
- `organizer`: người tạo và quản lý sự kiện.
- `admin`: quản trị toàn hệ thống.
- `support_agent`: xử lý hỗ trợ, chat, một phần trang admin.
- `staff` theo nghĩa nghiệp vụ: người được gán vào `EventStaff` để check-in/kiểm soát theo từng event.

## Kiến trúc tổng thể
Source đang đi theo mô hình Servlet/JSP + DAO + Service, gần với MVC cổ điển.

- View: JSP trong `/src/webapp`
- Controller: Servlet trong `/src/java/com/sellingticket/controller`
- Business: Service trong `/src/java/com/sellingticket/service`
- Data access: DAO trong `/src/java/com/sellingticket/dao`
- Cross-cutting: Filter, util, security
- Database: SQL Server

## Các nhóm chức năng chính
- Auth: login, register, logout, Google OAuth.
- Event: list, detail, create, update, approve, reject.
- Ticket: ticket type CRUD, availability, issuance, check-in.
- Order/Checkout: tạo đơn, payment pending, confirm payment, refund/cancel.
- Support: support ticket, chat, notifications.
- Admin dashboard: users, events, orders, settings, reports.

## Tóm tắt dễ nhớ
Web này là một hệ thống bán vé event khá đầy đủ: có mua vé, duyệt event, check-in, voucher, support và dashboard.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/02_TECH_STACK_ANALYSIS.md`

## Điểm người mới hay nhầm
- Tưởng project dùng Spring, nhưng source thực tế là Servlet/JSP thuần.
- Tưởng “admin”, “staff”, “organizer” là một tầng quyền đơn giản, nhưng thực tế quyền còn gắn theo sự kiện.
