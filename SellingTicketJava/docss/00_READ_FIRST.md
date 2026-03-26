# 00. Read First

## Nên đọc theo thứ tự này
1. `18_MASTER_SYSTEM_TEACHING_GUIDE.md`
2. `01_PROJECT_OVERVIEW.md`
3. `02_TECH_STACK_ANALYSIS.md`
4. `03_FOLDER_FILE_MAP.md`
5. `04_ARCHITECTURE_FLOW.md`
6. `05_AUTHENTICATION_AUTHORIZATION.md`
7. `06_USER_BUSINESS_FLOW.md`
8. `07_ADMIN_BUSINESS_FLOW.md`
9. `08_STAFF_BUSINESS_FLOW.md`
10. `09_CRUD_ANALYSIS.md`
11. `10_DATABASE_ANALYSIS.md`
12. `11_SECURITY_REVIEW.md`
13. `12_CONCURRENCY_TICKET_LOCKING.md`
14. `13_PERFORMANCE_CODE_QUALITY.md`
15. `14_BUG_RISK_AND_IMPROVEMENT_PLAN.md`
16. `15_LEARNING_PATH_FOR_BEGINNER.md`
17. `16_SHORT_FLOW_DIAGRAMS.md`
18. `17_DEEP_TEACHING_GUIDE.md`

## File lõi cần đọc trước
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/LoginServlet.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/CsrfFilter.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/UserService.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/UserDAO.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/CheckoutServlet.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/OrderDAO.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/TicketDAO.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/webapp/WEB-INF/web.xml`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/database/schema/ticketbox_schema.sql`

## Tóm tắt cực ngắn
Đây là dự án Java Web kiểu Servlet/JSP, kiến trúc phân tầng `Controller -> Service -> DAO -> SQL Server`. Hệ thống dùng `session + JWT cookie` để xác thực, `Filter` để phân quyền, và `transaction + UPDLOCK/HOLDLOCK` để giảm nguy cơ bán vượt vé. Nếu muốn đọc một file duy nhất để hiểu toàn hệ thống, hãy mở `18_MASTER_SYSTEM_TEACHING_GUIDE.md` trước.

## Điểm cần nhớ
- `customer`, `organizer`, `admin`, `support_agent` là role thực tế trong source.
- `staff` portal không phải một role DB riêng; nó dựa vào bảng `EventStaff` và filter/cờ quyền theo sự kiện.
- Login có cả session lẫn JWT cookie, nên đọc kỹ `LoginServlet`, `AuthFilter`, `AuthTokenService`.

## Tóm tắt dễ nhớ
- Đọc auth trước.
- Sau đó đọc checkout.
- Cuối cùng đọc database và security.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/01_PROJECT_OVERVIEW.md`

## Điểm người mới hay nhầm
- Nghĩ rằng chỉ cần đăng nhập là vào được mọi trang, nhưng source có nhiều lớp chặn khác nhau.
- Nghĩ rằng “staff” là một role cố định, trong khi ở đây nó còn phụ thuộc `EventStaff`.
