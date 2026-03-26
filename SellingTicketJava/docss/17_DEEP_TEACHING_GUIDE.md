# 17. Deep Teaching Guide

> Bản master mới và đầy đủ hơn nằm ở `18_MASTER_SYSTEM_TEACHING_GUIDE.md`.
> Tài liệu này vẫn giữ nguyên giá trị như một bản giảng lại source, nhưng nếu muốn đọc một file duy nhất thì hãy đọc file 18 trước.

Tài liệu này được viết theo kiểu “giảng lại source code”, không phải chỉ tóm tắt. Mục tiêu là giúp bạn hiểu cơ chế thật của hệ thống để khi thầy hỏi, bạn có thể nói được:

- request đi qua file nào
- vì sao lại thiết kế như vậy
- dữ liệu từ đâu tới đâu
- chỗ nào an toàn, chỗ nào còn rủi ro
- nếu sửa thì sửa ở tầng nào

---

## 1) Hệ thống này về bản chất là gì?

Đây là một web app Java kiểu truyền thống:

- `JSP` dùng để hiển thị giao diện.
- `Servlet` nhận request từ form hoặc AJAX.
- `Service` chứa logic nghiệp vụ.
- `DAO` nói chuyện với SQL Server bằng JDBC.
- `Filter` dùng để chặn đăng nhập, phân quyền, chống CSRF và thêm header an toàn.

Nếu giải thích cho thầy giáo theo cách đơn giản:

> “Hệ thống này không dùng Spring. Nó là Java Web cổ điển, nhưng vẫn tách lớp khá rõ. View nằm ở JSP, luồng xử lý đi qua Servlet, business logic nằm ở Service, và tất cả truy vấn DB nằm ở DAO.”

---

## 2) Cách đọc source cho đúng

Người mới thường mở file ngẫu nhiên nên bị rối. Cách đúng là đọc theo 4 câu hỏi:

1. Người dùng bấm gì?
2. Request đi đến Servlet nào?
3. Servlet gọi Service/DAO nào?
4. DB trả gì về và view hiển thị ra sao?

Ví dụ:

- Người dùng bấm nút đăng nhập ở `login.jsp`
- Form POST sang `/login`
- `LoginServlet` nhận request
- `LoginServlet` gọi `UserService.authenticate()`
- `UserService` gọi `UserDAO.login()`
- `UserDAO` truy vấn bảng `Users`
- Nếu đúng, session được set và cookie JWT được cấp

Đó là cách tư duy đúng để giải thích source.

---

## 3) Đăng nhập và xác thực: giảng lại từng bước

### 3.1. File giao diện

File: [`login.jsp`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/webapp/login.jsp)

Đây là form login. Trong form có:

- `email`
- `password`
- checkbox `remember`
- hidden `csrf_token`
- hidden `returnUrl`

Điểm rất quan trọng:

- `csrf_token` lấy từ session
- tức là form này không chỉ gửi username/password, mà còn phải mang token chống CSRF

### 3.2. Request submit đi đâu

Khi bấm nút đăng nhập:

- method = `POST`
- action = `/login`

Request chạy vào [`LoginServlet.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/LoginServlet.java)

### 3.3. Trong LoginServlet có gì?

`LoginServlet` làm 6 việc chính:

1. Chặn cache bằng header `no-store`
2. Lấy `email`, `password`, IP
3. Validate đầu vào
4. Kiểm tra rate limit theo IP và email
5. Gọi `UserService.authenticate()`
6. Nếu đúng thì tạo session + JWT cookie

### 3.4. Vì sao validate lại nhiều như vậy?

Đây là chỗ để bạn giải thích với thầy:

- Validate rỗng để tránh request lỗi
- Validate độ dài để chống payload quá lớn
- Validate regex email để lọc dữ liệu bẩn
- Rate limit để chống brute-force

Nghĩa là:

> “Không phải cứ có form là tin dữ liệu. Backend phải tự kiểm tra lại vì người dùng có thể gửi request tay hoặc sửa request bằng tool.”

### 3.5. Mật khẩu được xử lý thế nào?

Trong source:

- `PasswordUtil.hashPassword()` dùng BCrypt
- `PasswordUtil.checkPassword()` dùng BCrypt verify

File:

- [`PasswordUtil.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/PasswordUtil.java)

Điều này có nghĩa:

- không lưu plaintext
- mỗi mật khẩu có salt riêng bên trong BCrypt hash
- khi login, code không so sánh chuỗi thường mà so bằng hàm BCrypt

Nói với thầy:

> “Password lưu dạng BCrypt hash, không phải plaintext. Khi đăng nhập, hệ thống dùng BCrypt check chứ không tự so sánh trực tiếp.”

### 3.6. Session sau khi login

Sau khi đúng mật khẩu:

- session cũ bị invalidate
- session mới được tạo
- `user` và `account` được set trong session
- `csrf_token` được set nếu chưa có
- timeout = 3600 giây

Ý nghĩa:

- invalidate session cũ để chống session fixation
- giữ user trong session để các trang khác đọc ra dễ dàng

### 3.7. JWT cookie dùng để làm gì?

Hệ thống không chỉ dùng session. Nó còn cấp:

- access token
- refresh token

File:

- [`AuthTokenService.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/AuthTokenService.java)
- [`JwtUtil.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java)
- [`CookieUtil.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/CookieUtil.java)

Mục đích:

- session là trạng thái chính trong web app
- JWT cookie giúp khôi phục login nếu session mất hoặc hết

Nói dễ hiểu:

> “Session là sổ tay đang mở trong server. JWT cookie là thẻ định danh lưu ở trình duyệt để nếu mất sổ tay thì còn khôi phục lại được.”

### 3.8. `remember me` hoạt động sao?

Nếu tick `remember`:

- refresh cookie sống lâu hơn
- login không mất ngay khi đóng browser

Nếu không tick:

- cookie sẽ kiểu session hoặc tồn tại ngắn hơn tùy cách issue token

Điểm cần lưu ý:

- access token của hệ thống có expiry riêng
- refresh token dùng để xin lại access token

### 3.9. Nếu quên session thì hệ thống làm gì?

`AuthFilter` kiểm tra:

1. session có user chưa?
2. nếu chưa thì thử đọc access JWT cookie
3. nếu access expired thì dùng refresh token để restore

Tức là:

> “Hệ thống ưu tiên session, sau đó mới fallback sang cookie JWT.”

### 3.10. Thầy có thể hỏi: vì sao vừa session vừa JWT?

Bạn có thể trả lời:

> “Dự án đang ở trạng thái hybrid. Session giúp code JSP/Servlet đơn giản và dễ dùng, còn JWT cookie giúp restore login, hỗ trợ API, và giảm phụ thuộc vào session khi cần.”

---

## 4) Phân quyền: giảng lại thật rõ

### 4.1. Phân quyền nằm ở đâu?

Không nằm ở một chỗ duy nhất. Có 3 lớp:

1. `AuthFilter`
2. `OrganizerAccessFilter`
3. `StaffAccessFilter`

Ngoài ra một số controller vẫn check lại quyền trước khi thao tác.

### 4.2. Role thực tế trong source

Trong DB schema, `Users.role` có:

- `customer`
- `organizer`
- `admin`
- `support_agent`

Nhưng trên nghiệp vụ còn có:

- `staff` theo sự kiện
- `manager`
- `scanner`

Chỗ này rất dễ nhầm. Bạn nên nói:

> “Role hệ thống và role theo sự kiện là hai lớp khác nhau. Hệ thống có customer/organizer/admin/support_agent. Còn staff của từng event nằm trong bảng EventStaff với các vai trò manager/staff/scanner.”

### 4.3. `AuthFilter` làm gì?

[`AuthFilter.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java)

Filter này:

- cho phép public route
- chặn user chưa login ở route cần auth
- chặn admin area nếu không đúng role
- chặn organizer area nếu không đúng role
- chặn API admin/organizer theo role

Đây là chỗ giải thích quan trọng:

> “Filter là lớp chặn trước khi vào servlet. Nó giống như cổng bảo vệ của hệ thống.”

### 4.4. `OrganizerAccessFilter` làm gì?

[`OrganizerAccessFilter.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/OrganizerAccessFilter.java)

Filter này không chỉ hỏi “có login chưa”, mà còn hỏi:

- người này có event nào không
- event đó đã approved chưa
- đang vào trang nào của organizer
- nếu vào trang của một event cụ thể thì có quyền edit/check-in không

Nói với thầy:

> “Organizer không chỉ cần login mà còn phải có event hợp lệ, và một số trang chỉ mở khi event đã được duyệt.”

### 4.5. `StaffAccessFilter` làm gì?

[`StaffAccessFilter.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/StaffAccessFilter.java)

Filter này kiểm tra:

- admin thì auto pass
- user thường muốn vào staff portal thì phải có record trong `EventStaff`

Tức là staff portal không mở cho mọi organizer.

### 4.6. Nếu staff sửa URL để vào admin thì sao?

`AuthFilter` chặn `/admin/*`

Nếu role không phải admin/support_agent:

- bị redirect về home

Nếu là `support_agent`:

- chỉ được vào một số trang admin support/chat

Nói đơn giản:

> “Sửa URL không qua được vì filter đã chặn ở tầng server, không phụ thuộc giao diện.”

---

## 5) Checkout và chống bán vượt vé

### 5.1. Checkout đi qua file nào?

- View: `checkout.jsp`
- Controller: [`CheckoutServlet.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/CheckoutServlet.java)
- Service: `OrderService`, `EventService`, `TicketService`, `VoucherService`
- DAO quan trọng: `OrderDAO`, `TicketTypeDAO`

### 5.2. Luồng xử lý checkout

Luồng thực tế:

1. User mở checkout
2. `CheckoutServlet.doGet()` load event + ticket
3. `doPost()` kiểm tra login
4. check `checkoutInProgress`
5. build order từ request
6. validate event approved
7. validate event chưa hết hạn
8. validate ticket type thuộc event
9. validate sale window
10. validate số lượng còn
11. validate giới hạn mua
12. tạo đơn atomic
13. xử lý payment pending

### 5.3. Vì sao phần này quan trọng?

Vì đây là nơi có tiền thật và số lượng thật.

Nếu check sai:

- có thể bán quá số lượng
- có thể mua ticket type của event khác
- có thể spam đặt nhiều lần

### 5.4. Chống oversell bằng gì?

Nằm trong [`OrderDAO.createOrderAtomic()`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/OrderDAO.java)

SQL có:

```sql
UPDATE TicketTypes WITH (UPDLOCK, HOLDLOCK)
SET sold_quantity = sold_quantity + ?
WHERE ticket_type_id = ? AND (quantity - sold_quantity) >= ? AND is_active = 1
```

Giải thích cho thầy:

> “Đây là atomic reservation ở mức database. Khi hai người mua cùng lúc, DB lock row lại. Nếu không đủ vé thì update trả về 0 và transaction rollback.”

### 5.5. Tại sao validate ở Java vẫn cần?

Vì Java giúp:

- chặn request sai sớm
- báo lỗi dễ hiểu cho user
- giảm tải DB

Nhưng:

- chỉ validate Java thôi thì chưa đủ
- DB lock mới là lớp bảo vệ cuối

### 5.6. Nếu hai người cùng mua 1 vé cuối cùng?

Trường hợp thực tế:

- cả hai cùng gửi checkout gần như đồng thời
- một transaction vào trước sẽ lock row TicketTypes
- transaction còn lại chờ hoặc fail khi điều kiện `quantity - sold_quantity >= qty` không còn đúng

Kết quả:

- một người mua thành công
- người còn lại nhận lỗi vé đã hết

### 5.7. Tình huống xấu có thể hỏi

Thầy có thể hỏi:

> “Nếu user spam nút thanh toán thì sao?”

Bạn trả lời:

> “Trong `CheckoutServlet` có cờ `checkoutInProgress` trong session để chặn double click. Ngoài ra DB transaction/lock cũng bảo vệ ở bước tạo đơn.”

### 5.8. Nhưng còn điểm cần lưu ý

`checkoutInProgress` chỉ giúp giảm double click một session.

Không bảo vệ hoàn toàn nếu:

- user mở nhiều tab
- gửi request thủ công
- retry từ client khác

Nên bảo vệ thật sự vẫn là atomic update ở DB.

---

## 6) Thanh toán SeePay: giảng lại theo nghĩa nghiệp vụ

### 6.1. Sau checkout xong chuyện gì xảy ra?

Trong `CheckoutServlet`:

- tạo order
- set trạng thái pending
- gọi `orderService.processPayment(order)`
- forward đến `payment-pending.jsp`

Nghĩa là:

> “Đơn hàng chưa hoàn tất ngay. Nó ở trạng thái chờ thanh toán.”

### 6.2. PaymentService hoạt động thế nào?

Trong `OrderService.processPayment()`:

- chọn provider từ `PaymentFactory`
- gọi `provider.initiatePayment(order)`

Đây là OOP strategy/factory pattern đơn giản:

- method payment nào thì route về provider tương ứng

### 6.3. Webhook confirm thanh toán

Khi SeePay callback:

- `PaymentStatusServlet` hoặc `SeepayWebhookServlet` nhận callback
- gọi `OrderService.confirmPayment()`
- `OrderDAO.confirmPaymentAtomic()`

Điểm rất quan trọng:

> “Confirm payment là atomic và chỉ update nếu order vẫn pending.”

SQL logic:

```sql
UPDATE Orders
SET status = 'paid', payment_date = GETDATE(), updated_at = GETDATE()
WHERE order_id = ? AND status = 'pending'
```

Tức là:

- nếu đã paid rồi thì không cập nhật nữa
- tránh webhook lặp

### 6.4. Sau khi paid thì vé được phát thế nào?

`AdminOrderController` có logic:

- nếu đơn đã paid mà chưa có vé thì gọi `TicketDAO.createTicketsForOrder()`

`TicketDAO` sẽ:

- đọc `OrderItems`
- mỗi quantity tạo một ticket record
- tạo `ticket_code`
- tạo JWT QR token
- update `qr_code`

Nói với thầy:

> “Vé không tạo ngay lúc pending. Vé được phát sau khi payment confirmed hoặc khi admin xác nhận thanh toán.”

---

## 7) Check-in staff: giảng lại rõ hơn

### 7.1. File nào xử lý?

- [`StaffCheckInController.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/staff/StaffCheckInController.java)
- [`TicketDAO.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/TicketDAO.java)
- [`EventService.java`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/EventService.java)

### 7.2. Luồng check-in

1. Staff vào `/staff/check-in`
2. Controller lấy user từ session
3. Nếu chưa chọn event thì show danh sách event được gán
4. Nếu đã chọn event thì kiểm tra quyền check-in theo event
5. Staff nhập `ticketCode`
6. DAO tìm vé theo code
7. Nếu vé hợp lệ và chưa check-in thì update vé
8. Nếu tất cả vé trong order đã check-in thì order có thể chuyển sang `checked_in`

### 7.3. Vì sao phải check theo event?

Vì staff có thể được gán cho event A nhưng không phải event B.

Nên quyền check-in không chỉ là:

- “đã login chưa?”

mà còn phải là:

- “có quyền với event này không?”

### 7.4. Chống quét vé trùng

Trong `TicketDAO.checkInTicket()`:

- update `is_checked_in = 1`
- chỉ update nếu `is_checked_in = 0`

Nghĩa là vé đã check-in sẽ không check-in lại được.

Đây là kiểu idempotent theo logic nghiệp vụ.

---

## 8) CRUD: giảng theo module

### 8.1. User CRUD

Create:

- `RegisterServlet`
- `UserService.registerFull()`
- `UserDAO.registerFull()`

Read:

- `AdminUserController`
- `ProfileServlet`
- `UserService.getUserById()`

Update:

- `ProfileServlet` update hồ sơ
- `AdminUserController.updateRole()`

Deactivate:

- `UserDAO.deactivateUser()`

### 8.2. Event CRUD

Create:

- `EventService.createEventWithTickets()`

Read:

- `EventService.getEventDetails()`
- `EventService.getAllEvents()`
- `EventService.getPendingEvents()`

Update:

- `AdminEventController.updateEvent()`
- `EventService.updateEvent()`

Approve/Reject:

- `AdminEventController.approveEvent()`
- `AdminEventController.rejectEvent()`

Delete:

- `EventService.deleteEvent()`

### 8.3. Ticket type CRUD

Create/update/delete:

- `OrganizerTicketController`
- `TicketService`
- `TicketTypeDAO`

### 8.4. Order CRUD

Create:

- `CheckoutServlet`
- `OrderDAO.createOrderAtomic()`

Read:

- `AdminOrderController`
- `OrderService.getOrdersByUserPaged()`

Update status:

- `confirmPayment`
- `cancelOrder`
- `approveRefund`
- `checkInOrder`

### 8.5. Support CRUD

Create:

- `SupportTicketService.createTicket()`

Read:

- `SupportTicketService.getByUser()`
- `SupportTicketService.getByEvent()`

Update:

- `updateStatus`
- `assignTicket`
- `updatePriority`

---

## 9) Database: cách giải thích cho dễ hiểu

### 9.1. Bảng nào quan trọng nhất?

Nếu thầy hỏi bảng nào là trung tâm, bạn nói:

1. `Events`
2. `TicketTypes`
3. `Orders`
4. `OrderItems`
5. `Tickets`

### 9.2. Quan hệ nghiệp vụ

- Một user có nhiều order
- Một event có nhiều ticket type
- Một order có nhiều order items
- Một order item có nhiều ticket issued
- Một ticket thuộc một order item

### 9.3. Tại sao không để ticket trực tiếp trên order?

Vì:

- một đơn có thể mua nhiều loại vé
- mỗi loại vé có thể phát nhiều vé con

Nên phải có bảng chi tiết:

- `Orders` là header
- `OrderItems` là lines
- `Tickets` là vé con phát ra thật

Đây là mô hình chuẩn cho hệ thống bán vé.

---

## 10) Bảo mật: cách thầy hay hỏi và cách trả lời

### 10.1. SQL Injection có không?

Phần lớn query dùng `PreparedStatement`, nên nguy cơ SQLi giảm mạnh.

Nhưng bạn vẫn nên nói:

> “Tôi đã thấy source dùng parameterized query ở nhiều DAO, đây là điểm tốt chống SQL injection.”

### 10.2. XSS có không?

Có nguy cơ nếu output không encode.

Nhất là các trường:

- event description
- notes
- bio
- support ticket content

### 10.3. CSRF có không?

Có `CsrfFilter`, form có token.

Nói với thầy:

> “Dự án có filter chống CSRF và có hidden token trong form.”

### 10.4. Password lưu an toàn không?

Có BCrypt.

Đây là câu trả lời rất quan trọng.

### 10.5. Session fixation có không?

Source có invalidate session cũ trước khi tạo session mới lúc login.

Đây là điểm an toàn tốt.

### 10.6. Log quan trọng có không?

Có `ActivityLog` cho một số thao tác admin/event.

Nhưng nếu hỏi rộng hơn:

> “Chưa phải mọi hành động nhạy cảm đều được audit ở mức đầy đủ như production.”

Đây là câu trả lời trung thực.

---

## 11) Nếu thầy hỏi “hệ thống này an toàn chưa?”

Bạn có thể trả lời cân bằng:

> “So với đồ án sinh viên, dự án này đã có nhiều lớp bảo vệ khá tốt như BCrypt, CSRF filter, session fixation protection, JWT HttpOnly cookie, SQL parameterization, và atomic update cho vé. Tuy nhiên vẫn còn điểm cần siết như access control ở một số route phụ, output encoding chống XSS, và idempotency/robustness cho payment webhook.”

Đây là câu trả lời rất ổn vì:

- không nói quá
- không chê quá
- thể hiện bạn hiểu thật

---

## 12) Cách nói khi đứng trước thầy

Nếu thầy yêu cầu bạn trình bày hệ thống, bạn có thể nói theo khung này:

1. Hệ thống dùng Java Web Servlet/JSP.
2. View ở JSP, request vào Servlet.
3. Servlet gọi Service, Service gọi DAO, DAO query SQL Server.
4. Login dùng BCrypt + session + JWT cookie.
5. Phân quyền dùng filter theo role và theo event.
6. Checkout có atomic transaction để tránh oversell.
7. Payment confirm có idempotency bằng update trạng thái pending -> paid.
8. Check-in xác thực theo event assignment trong `EventStaff`.
9. Hệ thống có security filter và audit log, nhưng vẫn có thể cải thiện thêm ở access control và XSS.

Đó là “câu chuyện” trọn vẹn của hệ thống.

---

## 13) Những câu dễ bị hỏi và câu trả lời ngắn

### Câu 1: Tại sao không dùng Spring?
Vì đây là dự án Java Web truyền thống, mục tiêu chính là học Servlet/JSP/DAO/Filter và luồng web cơ bản.

### Câu 2: Tại sao vừa session vừa JWT?
Session giúp dùng web app đơn giản. JWT cookie giúp khôi phục phiên và hỗ trợ API/migration.

### Câu 3: Chống bán vượt vé ở đâu?
Ở `OrderDAO.createOrderAtomic()` bằng transaction và lock SQL Server.

### Câu 4: Staff vào trang check-in bằng cách nào?
Qua `StaffAccessFilter`, rồi `StaffCheckInController` kiểm tra quyền theo event.

### Câu 5: Admin sửa URL trực tiếp có vào được không?
Không, vì `AuthFilter` và các filter phụ chặn ở backend.

### Câu 6: Vé được tạo lúc nào?
Khi đơn được xác nhận thanh toán hoặc admin mark-paid thành công.

---

## 14) Tóm tắt dễ nhớ

Hãy nhớ 5 đường chính:

1. `Auth`
2. `Event`
3. `Checkout`
4. `Payment`
5. `Check-in`

Nếu bạn hiểu 5 đường này, bạn đã hiểu xương sống của hệ thống.

## File nên mở tiếp theo
- [`00_READ_FIRST.md`](/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/00_READ_FIRST.md)

## Điểm người mới hay nhầm
- Cố học thuộc từng file mà không hiểu luồng.
- Không phân biệt role hệ thống với role theo event.
- Quên rằng checkout và payment là hai bước khác nhau.
