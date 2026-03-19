# CHƯƠNG 2. PHÂN TÍCH YÊU CẦU HỆ THỐNG

## Mở đầu chương

Phân tích yêu cầu (Requirements Analysis) là giai đoạn nền tảng trong quy trình phát triển phần mềm, quyết định trực tiếp đến chất lượng và sự thành công của dự án. Theo nghiên cứu của Standish Group trong báo cáo CHAOS (2020), **66% các dự án phần mềm thất bại** có nguyên nhân gốc rễ từ việc thu thập và phân tích yêu cầu không đầy đủ [1]. IEEE định nghĩa phân tích yêu cầu là *"quá trình nghiên cứu nhu cầu của người dùng để đi đến định nghĩa các yêu cầu hệ thống"* (IEEE Std 610.12-1990) [2].

Chương này áp dụng phương pháp luận phân tích yêu cầu theo chuẩn **IEEE 830-1998 (SRS — Software Requirements Specification)** [3] kết hợp với kỹ thuật mô hình hóa **UML 2.5** (Unified Modeling Language) của OMG [4] để phân tích toàn diện hệ thống **Online Event Ticketing Platform**. Quy trình phân tích được thực hiện theo 5 bước tuần tự:

1. **Xác định mục tiêu hệ thống** — Mapping từ business objectives sang system objectives
2. **Nhận diện tác nhân (Actors)** — Phân loại stakeholders theo mô hình RACI [5]
3. **Thu thập yêu cầu chức năng** — Kỹ thuật Use Case Driven Development [6]
4. **Xác định yêu cầu phi chức năng** — Mô hình FURPS+ của Grady & Caswell [7]
5. **Mô hình hóa Use Case** — UML Use Case Diagram + Detailed Specification

---

## 1. Phân tích hệ thống

### 1.1. Mục tiêu của hệ thống

Dựa trên phân tích thực trạng thị trường tại Chương 1 và phương pháp **Goal-Question-Metric (GQM)** của Basili et al. [8], nhóm xác định các mục tiêu hệ thống được phân theo 3 tầng: Chiến lược (Strategic), Chiến thuật (Tactical), và Vận hành (Operational).

#### a) Mục tiêu chiến lược (Strategic Goals)

| ID | Mục tiêu | KPI đo lường | Nguồn tham chiếu |
|----|----------|-------------|-------------------|
| SG-01 | Xây dựng nền tảng bán vé sự kiện trực tuyến hoàn chỉnh | Hệ thống hoạt động end-to-end | Chương 1, Mục 2 |
| SG-02 | Giải quyết 6 hạn chế của các nền tảng hiện tại | ≥5/6 hạn chế được giải quyết | Chương 1, Mục 1.1d |
| SG-03 | Đáp ứng xu hướng chuyển đổi số tại Việt Nam | Thanh toán QR, đa ngôn ngữ | Chương 1, Mục 1.3 |

#### b) Mục tiêu chiến thuật (Tactical Goals)

| ID | Mục tiêu | Mô tả chi tiết | Độ ưu tiên |
|----|----------|----------------|-----------|
| TG-01 | Hệ thống đa vai trò | 5 roles: Admin, Organizer, Staff, Attendee, Guest — mỗi role có dashboard và permission riêng | Cao |
| TG-02 | Quy trình mua vé - thanh toán liền mạch | Chọn vé → Checkout → Thanh toán VietQR → Nhận vé QR Code | Cao |
| TG-03 | Công cụ quản lý sự kiện cho Organizer | CRUD sự kiện, quản lý loại vé, voucher, thống kê doanh thu | Cao |
| TG-04 | Hệ thống giao tiếp tích hợp | Chat real-time + Support Ticket system | Trung bình |
| TG-05 | Bảo mật ứng dụng web | Authentication, CSRF protection, input validation, RBAC | Cao |

#### c) Mục tiêu vận hành (Operational Goals)

| ID | Mục tiêu | Tiêu chí hoàn thành |
|----|----------|---------------------|
| OG-01 | Response time ≤ 3 giây (trang chính) | Đo trên Chrome DevTools |
| OG-02 | Xử lý đồng thời ≥ 50 users | Không crash, không data corruption |
| OG-03 | Uptime ≥ 95% trên hosting environment | Monitoring trên Render.com |
| OG-04 | Tương thích đa trình duyệt | Chrome, Firefox, Edge — desktop + mobile |
| OG-05 | Hỗ trợ đa ngôn ngữ (i18n) | Tiếng Việt + English chuyển đổi real-time |

> **Phương pháp luận:** Các mục tiêu được xây dựng theo nguyên tắc **SMART** (Specific, Measurable, Achievable, Relevant, Time-bound) [9] và liên kết trực tiếp với các hạn chế thị trường đã phân tích tại Chương 1.

---

### 1.2. Các tác nhân của hệ thống (Actors)

Theo Jacobson et al. trong *Object-Oriented Software Engineering* [10], tác nhân (Actor) là *"bất kỳ thực thể bên ngoài nào tương tác với hệ thống"*. Hệ thống Online Event Ticketing Platform xác định **5 tác nhân chính** và **3 tác nhân bên ngoài (External Systems)**.

#### a) Tác nhân chính (Primary Actors)

| # | Actor | Vai trò | Mô tả chi tiết | Đặc quyền nổi bật |
|---|-------|---------|-----------------|-------------------|
| A1 | **Guest** (Khách) | Người dùng chưa đăng nhập | Truy cập hệ thống qua trình duyệt, xem sự kiện public, tìm kiếm, xem chi tiết | Chỉ đọc (Read-only) |
| A2 | **Attendee** (Người tham dự) | Người dùng đã đăng ký tài khoản | Mua vé, thanh toán, xem vé đã mua, chat với organizer, gửi support ticket | Mua vé, chat, support |
| A3 | **Organizer** (Nhà tổ chức) | Chủ sở hữu sự kiện | Tạo/quản lý sự kiện, loại vé, voucher, quản lý staff, xem dashboard thống kê | CRUD event, analytics |
| A4 | **Staff** (Nhân viên) | Nhân viên được Organizer phân công | Check-in vé bằng QR code tại sự kiện, xem danh sách attendees | Check-in QR |
| A5 | **Admin** (Quản trị viên) | Quản trị viên hệ thống | Quản lý users, duyệt/từ chối sự kiện, quản lý categories, cấu hình hệ thống, xem báo cáo tổng hợp | Full system access |

#### b) Tác nhân bên ngoài (External System Actors)

| # | External Actor | Vai trò | Giao thức |
|---|--------------|---------|-----------|
| E1 | **SePay Payment Gateway** | Xử lý thanh toán VietQR, gửi webhook xác nhận | REST API + Webhook |
| E2 | **Google OAuth 2.0** | Xác thực đăng nhập Google | OAuth 2.0 Protocol |
| E3 | **Cloudinary CDN** | Lưu trữ và phân phối hình ảnh sự kiện | REST API |

#### c) Mô hình phân quyền RBAC

Hệ thống áp dụng mô hình **Role-Based Access Control (RBAC)** theo tiêu chuẩn NIST RBAC [11] với **hierarchy quan hệ kế thừa**: Guest ⊂ Attendee ⊂ Organizer (đối với event owner), và Staff là vai trò được delegate bởi Organizer.

| Chức năng | Admin | Organizer | Staff | Attendee | Guest |
|-----------|:-----:|:---------:|:-----:|:--------:|:-----:|
| Xem sự kiện public | ✓ | ✓ | ✓ | ✓ | ✓ |
| Tìm kiếm sự kiện | ✓ | ✓ | ✓ | ✓ | ✓ |
| Đăng ký / Đăng nhập | — | — | — | — | ✓ |
| Mua vé & Thanh toán | — | — | — | ✓ | — |
| Xem vé đã mua | — | — | — | ✓ | — |
| Chat với Organizer | — | ✓ | — | ✓ | — |
| Gửi Support Ticket | — | ✓ | — | ✓ | — |
| CRUD Sự kiện | ✓ | ✓ (own) | — | — | — |
| Quản lý loại vé | — | ✓ (own) | — | — | — |
| Quản lý Voucher | ✓ (system) | ✓ (event) | — | — | — |
| Check-in QR Code | — | ✓ (own) | ✓ | — | — |
| Quản lý Staff | — | ✓ | — | — | — |
| Dashboard Analytics | ✓ (system) | ✓ (own events) | — | — | — |
| Duyệt/Từ chối sự kiện | ✓ | — | — | — | — |
| Quản lý Users | ✓ | — | — | — | — |
| Quản lý Categories | ✓ | — | — | — | — |
| Cấu hình hệ thống | ✓ | — | — | — | — |

> **Lưu ý triển khai:** Ma trận phân quyền này được enforce bởi 7 filter classes trong package `com.sellingticket.filter`: `AuthFilter`, `OrganizerAccessFilter`, `StaffAccessFilter`, `CsrfFilter`, `SecurityHeadersFilter`, `CacheFilter`, `ProtectedJspAccessFilter`.

---

### 1.3. Yêu cầu chức năng (Functional Requirements)

Theo tiêu chuẩn IEEE 830-1998 [3], yêu cầu chức năng mô tả *"các chức năng mà phần mềm phải thực hiện"*, bao gồm đầu vào, xử lý, và đầu ra. Robertson & Robertson trong *Mastering the Requirements Process* [12] khuyến nghị phân nhóm yêu cầu theo **functional area** để đảm bảo tính truy vết (traceability).

Hệ thống được phân tích thành **9 module chức năng** với tổng cộng **48 yêu cầu chức năng**:

#### Module 1: Quản lý Người dùng & Xác thực (User & Authentication Management)

| ID | Yêu cầu | Mô tả chi tiết | Actor | Độ ưu tiên |
|----|---------|----------------|-------|-----------|
| FR-01 | Đăng ký tài khoản | Guest có thể tạo tài khoản mới bằng email, mật khẩu, họ tên, số điện thoại. Hệ thống validate email unique, mật khẩu ≥ 8 ký tự | Guest | Cao |
| FR-02 | Đăng nhập hệ thống | User đăng nhập bằng email/password hoặc Google OAuth 2.0. Hệ thống tạo session và chuyển hướng theo role | Guest | Cao |
| FR-03 | Đăng nhập Google OAuth | Hệ thống tích hợp Google OAuth 2.0 cho phép đăng nhập/đăng ký 1-click. Tự động tạo user nếu chưa tồn tại | Guest | Cao |
| FR-04 | Đổi mật khẩu | User có thể thay đổi mật khẩu. Yêu cầu nhập mật khẩu hiện tại + mật khẩu mới (xác nhận 2 lần) | All Users | Trung bình |
| FR-05 | Quản lý profile cá nhân | User chỉnh sửa thông tin: fullName, phone, gender, dateOfBirth, avatar. Organizer có thêm: bio, website, socialFacebook, socialInstagram | All Users | Trung bình |
| FR-06 | Đăng xuất | Hủy session hiện tại, xóa refresh token, chuyển về trang chủ | All Users | Cao |

#### Module 2: Quản lý Sự kiện (Event Management)

| ID | Yêu cầu | Mô tả chi tiết | Actor | Độ ưu tiên |
|----|---------|----------------|-------|-----------|
| FR-07 | Tạo sự kiện mới | Organizer tạo sự kiện với: title, slug, shortDescription, description (rich text), bannerImage, location, address, startDate, endDate, categoryId, isPrivate, maxTicketsPerOrder, preOrderEnabled | Organizer | Cao |
| FR-08 | Chỉnh sửa sự kiện | Organizer cập nhật thông tin sự kiện đã tạo (chỉ events thuộc sở hữu). Sự kiện đang active giới hạn fields được sửa | Organizer | Cao |
| FR-09 | Xóa/Ẩn sự kiện | Organizer có thể soft-delete hoặc chuyển trạng thái sự kiện thành draft/hidden | Organizer | Trung bình |
| FR-10 | Duyệt/Từ chối sự kiện | Admin xem danh sách sự kiện pending, phê duyệt (approved) hoặc từ chối (rejected) kèm lý do (rejectionReason) | Admin | Cao |
| FR-11 | Feature sự kiện | Admin đánh dấu sự kiện nổi bật (isFeatured=true) để hiển thị ưu tiên trên trang chủ | Admin | Thấp |
| FR-12 | Xem danh sách sự kiện | Guest/User xem danh sách sự kiện public với pagination, filter theo category, search theo title/location | All | Cao |
| FR-13 | Xem chi tiết sự kiện | Hiển thị đầy đủ thông tin sự kiện: banner, mô tả, địa điểm, thời gian, danh sách loại vé, organizer info. Tăng view count | All | Cao |
| FR-14 | Tìm kiếm sự kiện | Full-text search theo title, location, category. Hỗ trợ filter theo: ngày, khoảng giá, trạng thái | All | Cao |

#### Module 3: Quản lý Loại vé (Ticket Type Management)

| ID | Yêu cầu | Mô tả chi tiết | Actor | Độ ưu tiên |
|----|---------|----------------|-------|-----------|
| FR-15 | Tạo loại vé | Organizer tạo nhiều loại vé cho 1 sự kiện: name, description, price, quantity, saleStart, saleEnd | Organizer | Cao |
| FR-16 | Chỉnh sửa loại vé | Cập nhật thông tin loại vé. Không được giảm quantity dưới soldQuantity | Organizer | Cao |
| FR-17 | Xóa/Vô hiệu hóa loại vé | Soft-delete loại vé (isActive=false). Không xóa nếu đã có vé bán ra | Organizer | Trung bình |

#### Module 4: Đặt vé & Thanh toán (Ticket Booking & Payment)

| ID | Yêu cầu | Mô tả chi tiết | Actor | Độ ưu tiên |
|----|---------|----------------|-------|-----------|
| FR-18 | Chọn vé | Attendee chọn loại vé và số lượng. Validate: availableQuantity, maxTicketsPerOrder, saleStart/saleEnd window | Attendee | Cao |
| FR-19 | Checkout đơn hàng | Nhập thông tin buyer: buyerName, buyerEmail, buyerPhone, notes. Áp dụng voucher code (nếu có). Tính toán: totalAmount, discountAmount, finalAmount | Attendee | Cao |
| FR-20 | Thanh toán VietQR | Tạo mã QR VietQR qua SePay API. Hiển thị QR code + thông tin chuyển khoản. Webhook tự động xác nhận khi bank transfer thành công | Attendee | Cao |
| FR-21 | Xác nhận thanh toán thủ công | Admin có thể confirm payment thủ công cho trường hợp webhook fail | Admin | Trung bình |
| FR-22 | Tạo vé QR Code | Sau thanh toán thành công, hệ thống tự động generate N vé riêng lẻ (mỗi vé 1 QR code unique) từ OrderItems | System | Cao |
| FR-23 | Xem vé đã mua | Attendee xem danh sách tất cả vé: eventTitle, ticketTypeName, ticketCode, qrCode, trạng thái check-in | Attendee | Cao |
| FR-24 | Xem lịch sử đơn hàng | Attendee xem danh sách orders: orderCode, eventTitle, finalAmount, status, paymentDate. Chi tiết order items | Attendee | Trung bình |
| FR-25 | Resume thanh toán | Attendee quay lại thanh toán cho orders ở trạng thái pending | Attendee | Trung bình |

#### Module 5: Check-in QR Code

| ID | Yêu cầu | Mô tả chi tiết | Actor | Độ ưu tiên |
|----|---------|----------------|-------|-----------|
| FR-26 | Scan QR check-in | Staff/Organizer scan QR code vé tại sự kiện. Validate: ticketCode hợp lệ, chưa check-in, thuộc event đúng | Staff, Organizer | Cao |
| FR-27 | Xác nhận check-in | Cập nhật isCheckedIn=true, ghi nhận checkedInAt timestamp và checkedInBy (staff userId) | Staff, Organizer | Cao |
| FR-28 | Xem danh sách check-in | Organizer/Staff xem realtime danh sách attendees đã/chưa check-in cho sự kiện | Staff, Organizer | Trung bình |

#### Module 6: Chat & Giao tiếp (Communication)

| ID | Yêu cầu | Mô tả chi tiết | Actor | Độ ưu tiên |
|----|---------|----------------|-------|-----------|
| FR-29 | Tạo phiên chat | Attendee mở cuộc hội thoại mới với Organizer của sự kiện cụ thể (ChatSession) | Attendee | Trung bình |
| FR-30 | Gửi/nhận tin nhắn | Hai bên gửi và nhận tin nhắn trong session. Hiển thị senderName, senderRole, timestamp | Attendee, Organizer | Trung bình |
| FR-31 | Gửi Support Ticket | Attendee/Organizer tạo ticket hỗ trợ với: category (payment_error, missing_ticket, cancellation, refund, event_issue, account_issue, technical, feedback), subject, description. Auto-routing: event-related → organizer, system-related → admin | Attendee, Organizer | Trung bình |
| FR-32 | Xử lý Support Ticket | Admin/Organizer xem, trả lời, cập nhật trạng thái (open → in_progress → resolved → closed) | Admin, Organizer | Trung bình |

#### Module 7: Voucher & Khuyến mãi (Voucher Management)

| ID | Yêu cầu | Mô tả chi tiết | Actor | Độ ưu tiên |
|----|---------|----------------|-------|-----------|
| FR-33 | Tạo Event Voucher | Organizer tạo mã giảm giá cho sự kiện cụ thể: code, discountType (percentage/fixed), discountValue, minOrderAmount, maxDiscount, usageLimit, startDate, endDate | Organizer | Trung bình |
| FR-34 | Tạo System Voucher | Admin tạo mã giảm giá toàn hệ thống (voucherScope=SYSTEM, fundSource=SYSTEM) | Admin | Thấp |
| FR-35 | Validate Voucher | Khi checkout, validate: code tồn tại, isActive, chưa hết hạn, usedCount < usageLimit, minOrderAmount đạt. Trả về discountAmount | System | Cao |
| FR-36 | Quản lý Voucher | CRUD + kích hoạt/vô hiệu hóa voucher. Xem thống kê usedCount/usageLimit | Organizer, Admin | Trung bình |

#### Module 8: Dashboard & Thống kê (Analytics)

| ID | Yêu cầu | Mô tả chi tiết | Actor | Độ ưu tiên |
|----|---------|----------------|-------|-----------|
| FR-37 | Organizer Dashboard | Thống kê: tổng sự kiện, tổng vé bán, tổng doanh thu, vé bán theo ngày, top events, conversion rate | Organizer | Cao |
| FR-38 | Admin Dashboard | Thống kê toàn hệ thống: total users, events, orders, revenue. Biểu đồ doanh thu theo tháng, phân bổ theo category | Admin | Cao |
| FR-39 | Staff Dashboard | Xem overview sự kiện được phân công, thống kê check-in (đã/chưa/tổng), pending events | Staff | Trung bình |
| FR-40 | Báo cáo chi tiết | Admin xuất báo cáo: revenue by event, order summary, user growth, category performance | Admin | Thấp |
| FR-41 | Activity Log | Ghi nhận log hoạt động quan trọng: login, event created, order paid, user banned | System | Trung bình |

#### Module 9: Quản trị hệ thống (System Administration)

| ID | Yêu cầu | Mô tả chi tiết | Actor | Độ ưu tiên |
|----|---------|----------------|-------|-----------|
| FR-42 | Quản lý Users | Admin xem danh sách users, search, filter theo role/status. Activate/deactivate/delete user | Admin | Cao |
| FR-43 | Quản lý Categories | Admin CRUD danh mục sự kiện: name, description, icon | Admin | Trung bình |
| FR-44 | Quản lý đơn hàng | Admin xem toàn bộ orders, filter theo status/event. Confirm payment thủ công | Admin | Cao |
| FR-45 | Quản lý thông báo | Admin gửi notification toàn hệ thống hoặc targeted user groups | Admin | Thấp |
| FR-46 | Cấu hình hệ thống | Admin cấu hình: site name, contact info, default max tickets per order, payment settings | Admin | Thấp |
| FR-47 | Upload Media | Tải ảnh lên Cloudinary CDN cho event banners, user avatars | Organizer, Admin | Trung bình |
| FR-48 | Quản lý Staff | Organizer thêm/xóa staff cho sự kiện. Assign staff từ registered users | Organizer | Trung bình |

#### Tổng hợp phân bổ yêu cầu chức năng

| Module | Số lượng FR | Tỷ lệ | Độ ưu tiên Cao |
|--------|:-----------:|:------:|:--------------:|
| User & Authentication | 6 | 12.5% | 4 |
| Event Management | 8 | 16.7% | 5 |
| Ticket Type | 3 | 6.3% | 2 |
| Booking & Payment | 8 | 16.7% | 5 |
| Check-in QR | 3 | 6.3% | 2 |
| Chat & Communication | 4 | 8.3% | 0 |
| Voucher | 4 | 8.3% | 1 |
| Dashboard & Analytics | 5 | 10.4% | 2 |
| System Admin | 7 | 14.6% | 2 |
| **Tổng cộng** | **48** | **100%** | **23 (47.9%)** |

---

### 1.4. Yêu cầu phi chức năng (Non-Functional Requirements)

Theo mô hình **FURPS+** (Functionality, Usability, Reliability, Performance, Supportability) của Grady & Caswell [7], yêu cầu phi chức năng xác định *các ràng buộc chất lượng* mà hệ thống phải thỏa mãn.

| ID | Loại | Yêu cầu | Mô tả chi tiết | Tiêu chí đo lường |
|----|------|---------|-----------------|-------------------|
| NFR-01 | **Performance** | Thời gian phản hồi | Trang chính load ≤ 3s, API response ≤ 1s | Chrome DevTools, JMeter |
| NFR-02 | **Performance** | Đồng thời | Hỗ trợ ≥ 50 concurrent users | Stress test không crash |
| NFR-03 | **Usability** | Responsive Design | Giao diện thích ứng desktop (≥1024px), tablet (768-1023px), mobile (≤767px) | Manual testing 3 breakpoints |
| NFR-04 | **Usability** | Đa ngôn ngữ (i18n) | Chuyển đổi Tiếng Việt ↔ English real-time, không reload page | Cookie-based locale switching |
| NFR-05 | **Usability** | UX/UI nhất quán | Design system thống nhất: color palette, typography, spacing, component library | Visual audit |
| NFR-06 | **Reliability** | Uptime | Availability ≥ 95% trên production | Monitoring dashboard |
| NFR-07 | **Reliability** | Data Integrity | Transactions cho payment flow, no double-charge, no orphan tickets | SQL transaction isolation |
| NFR-08 | **Security** | Authentication | BCrypt password hashing, session-based auth, Google OAuth 2.0, auto-logout | Code audit |
| NFR-09 | **Security** | CSRF Protection | Double-submit cookie pattern cho tất cả POST/PUT/DELETE requests | CsrfFilter enforcement |
| NFR-10 | **Security** | Input Validation | Server-side validation tất cả user input, XSS prevention, SQL injection prevention | OWASP testing |
| NFR-11 | **Security** | RBAC Enforcement | Filter-level access control cho mỗi URL pattern. Unauthorized → 403 redirect | AuthFilter, OrganizerAccessFilter |
| NFR-12 | **Security** | Security Headers | X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Content-Security-Policy | SecurityHeadersFilter |
| NFR-13 | **Supportability** | Logging | Activity logging cho các hành động quan trọng (login, payment, admin actions) | ActivityLog table |
| NFR-14 | **Supportability** | Cấu hình | System settings configurable qua Admin UI, không cần code change | SiteSettings model |
| NFR-15 | **Compatibility** | Trình duyệt | Chrome 90+, Firefox 88+, Edge 90+ | Cross-browser testing |
| NFR-16 | **Compatibility** | Database | Microsoft SQL Server 2019+ | JDBC driver compatibility |

---

## 2. Đặc tả chi tiết các Use Case chính

Theo Cockburn trong *Writing Effective Use Cases* [13], mỗi use case cần được đặc tả ở mức **Fully-dressed format** bao gồm: Actor, Precondition, Main Flow, Alternative Flows, Postcondition, và Business Rules. Dưới đây là đặc tả chi tiết 5 use case core của hệ thống.

### UC-01: Đặt vé sự kiện (Buy Event Tickets)

| Thuộc tính | Giá trị |
|-----------|---------|
| **Use Case ID** | UC-01 |
| **Tên** | Đặt vé sự kiện (Buy Event Tickets) |
| **Actor chính** | Attendee |
| **Actor phụ** | SePay Payment Gateway |
| **Mô tả** | Attendee chọn sự kiện, chọn loại vé và số lượng, nhập thông tin mua, thanh toán qua VietQR, nhận vé điện tử với QR code |
| **Preconditions** | Attendee đã đăng nhập. Sự kiện ở trạng thái approved và chưa kết thúc |
| **Trigger** | Attendee click "Mua vé" trên trang chi tiết sự kiện |

**Main Flow (Luồng chính):**

1. Hệ thống hiển thị danh sách loại vé khả dụng (TicketType có isActive=true, saleStart ≤ now ≤ saleEnd, availableQuantity > 0)
2. Attendee chọn loại vé và số lượng (≤ maxTicketsPerOrder)
3. Hệ thống tính totalAmount = Σ(price × quantity) cho từng loại vé
4. Attendee nhập thông tin buyer: buyerName, buyerEmail, buyerPhone, notes (optional)
5. Attendee nhập voucher code (optional) → Hệ thống validate và tính discountAmount
6. Hệ thống tính finalAmount = totalAmount - discountAmount
7. Hệ thống tạo Order (status=pending) + OrderItems + cập nhật soldQuantity
8. Hệ thống gọi SePay API tạo mã QR VietQR với số tiền finalAmount
9. Attendee quét QR code hoặc chuyển khoản ngân hàng
10. SePay gửi webhook xác nhận thanh toán thành công
11. Hệ thống cập nhật Order(status=paid, paymentDate=now)
12. Hệ thống generate N vé riêng lẻ (Ticket) với QR code unique cho mỗi vé
13. Hệ thống hiển thị trang xác nhận đặt vé thành công

**Alternative Flows:**

- **AF-1:** Vé hết (step 1) → Hiển thị "Hết vé", disable nút mua
- **AF-2:** Voucher không hợp lệ (step 5) → Hiển thị lỗi, cho phép nhập lại hoặc bỏ qua
- **AF-3:** Thanh toán timeout 15 phút (step 9) → Order status giữ pending, cho phép resume
- **AF-4:** Webhook fail (step 10) → Admin có thể confirm thủ công (FR-21)

**Postconditions:**
- Order status = paid, paymentDate được ghi nhận
- OrderItems liên kết với TicketTypes, soldQuantity được cập nhật
- N Ticket records được tạo với QR code unique
- Voucher usedCount tăng 1 (nếu có sử dụng voucher)

**Business Rules:**
- BR-01: Số vé mỗi đơn ≤ maxTicketsPerOrder (cấu hình per event)
- BR-02: Voucher chỉ áp dụng nếu: isActive=true, chưa hết hạn, usedCount < usageLimit, totalAmount ≥ minOrderAmount
- BR-03: discountAmount tối đa = maxDiscount (nếu discountType=percentage)
- BR-04: platformFeeAmount = finalAmount × platformFeePercent (hệ thống thu)
- BR-05: organizerPayoutAmount = finalAmount - platformFeeAmount

---

### UC-02: Tạo sự kiện mới (Create Event)

| Thuộc tính | Giá trị |
|-----------|---------|
| **Use Case ID** | UC-02 |
| **Tên** | Tạo sự kiện mới (Create Event) |
| **Actor chính** | Organizer |
| **Mô tả** | Organizer tạo sự kiện mới với đầy đủ thông tin, upload banner, tạo loại vé, submit để Admin duyệt |
| **Preconditions** | Organizer đã đăng nhập. Ít nhất 1 category tồn tại |
| **Trigger** | Organizer click "Tạo sự kiện mới" trên Organizer Dashboard |

**Main Flow:**

1. Hệ thống hiển thị form tạo sự kiện với các fields: title, shortDescription, description (rich text editor), location, address, startDate, endDate, categoryId, isPrivate, maxTicketsPerOrder, preOrderEnabled
2. Organizer upload banner image → Cloudinary CDN → nhận URL
3. Hệ thống auto-generate slug từ title (URL-friendly)
4. Organizer thêm ≥ 1 loại vé (TicketType): name, description, price, quantity, saleStart, saleEnd
5. Organizer submit form
6. Hệ thống validate: title not empty, startDate < endDate, startDate > now, quantity > 0, price ≥ 0
7. Hệ thống tạo Event(status=pending) + TicketTypes
8. Hệ thống thông báo Admin có event mới cần duyệt
9. Organizer nhận phản hồi: "Sự kiện đã được gửi chờ duyệt"

**Alternative Flows:**

- **AF-1:** Validation fail (step 6) → Hiển thị error messages, giữ nguyên form data
- **AF-2:** Upload image fail → Sử dụng default placeholder image
- **AF-3:** Slug trùng → Auto-append random suffix

**Postconditions:**
- Event record tồn tại với status=pending
- ≥ 1 TicketType records liên kết với event
- Banner image lưu trên Cloudinary

---

### UC-03: Check-in vé bằng QR Code

| Thuộc tính | Giá trị |
|-----------|---------|
| **Use Case ID** | UC-03 |
| **Tên** | Check-in vé bằng QR Code |
| **Actor chính** | Staff |
| **Actor phụ** | Organizer (có thể check-in cho event own) |
| **Mô tả** | Staff scan QR code trên vé của attendee tại sự kiện, hệ thống xác thực và ghi nhận check-in |
| **Preconditions** | Staff đã đăng nhập và được assign vào event. Event đang diễn ra hoặc sắp diễn ra |
| **Trigger** | Staff mở trang Check-in và bật camera scan |

**Main Flow:**

1. Staff truy cập trang check-in của sự kiện cụ thể
2. Staff scan QR code trên vé của attendee (hoặc nhập ticketCode thủ công)
3. Hệ thống decode QR → extract ticketCode
4. Hệ thống validate: ticketCode tồn tại, thuộc event đang check-in, chưa isCheckedIn
5. Hệ thống hiển thị thông tin vé: attendeeName, ticketTypeName, orderCode
6. Staff xác nhận check-in → Hệ thống cập nhật: isCheckedIn=true, checkedInAt=now, checkedInBy=staff.userId
7. Hiển thị "Check-in thành công" với thông tin attendee

**Alternative Flows:**

- **AF-1:** QR code không hợp lệ (step 4) → "Mã vé không tồn tại"
- **AF-2:** Vé đã check-in rồi (step 4) → "Vé đã được sử dụng lúc {checkedInAt}"
- **AF-3:** Vé thuộc event khác (step 4) → "Vé không thuộc sự kiện này"

---

### UC-04: Duyệt sự kiện (Approve/Reject Event)

| Thuộc tính | Giá trị |
|-----------|---------|
| **Use Case ID** | UC-04 |
| **Tên** | Duyệt/Từ chối sự kiện |
| **Actor chính** | Admin |
| **Mô tả** | Admin xem danh sách events pending, review nội dung, phê duyệt hoặc từ chối kèm lý do |
| **Preconditions** | Admin đã đăng nhập. Tồn tại ≥ 1 event có status=pending |
| **Trigger** | Admin truy cập trang quản lý sự kiện hoặc nhận notification |

**Main Flow:**

1. Admin xem danh sách events pending (sorted by createdAt DESC)
2. Admin click vào event để xem chi tiết: title, description, banner, location, dates, ticket types, organizer info
3. Admin review nội dung sự kiện
4. Admin chọn "Phê duyệt" → Hệ thống cập nhật status=approved
5. Hệ thống gửi notification cho Organizer: "Sự kiện đã được phê duyệt"
6. Event hiển thị trên trang chủ cho public

**Alternative Flow:**

- **AF-1:** Admin từ chối (step 4) → Nhập rejectionReason → status=rejected → Notification cho Organizer kèm lý do

---

### UC-05: Gửi Support Ticket

| Thuộc tính | Giá trị |
|-----------|---------|
| **Use Case ID** | UC-05 |
| **Tên** | Gửi Support Ticket |
| **Actor chính** | Attendee |
| **Actor phụ** | Admin, Organizer (xử lý ticket) |
| **Mô tả** | Attendee tạo ticket hỗ trợ. Hệ thống tự động routing đến Admin hoặc Organizer dựa trên category |
| **Preconditions** | User đã đăng nhập |
| **Trigger** | User click "Hỗ trợ" từ menu |

**Main Flow:**

1. User chọn category: payment_error, missing_ticket, cancellation, refund, event_issue, account_issue, technical, feedback
2. User chọn event liên quan (optional, cho các category event-related)
3. User chọn order liên quan (optional)
4. User nhập subject và description
5. Hệ thống auto-generate ticketCode (format: SUP-XXXXXX)
6. Hệ thống compute routedTo: nếu eventId != null AND category ∈ {missing_ticket, cancellation, event_issue} → "organizer", ngược lại → "admin"
7. Hệ thống tạo SupportTicket(status=open, priority=normal)
8. User xem ticket đã tạo + có thể gửi thêm messages

**Business Rules:**
- BR-01: Auto-routing logic được định nghĩa trong `SupportTicket.computeRoutedTo()`
- BR-02: Priority mặc định = normal, Admin có thể escalate
- BR-03: Status flow: open → in_progress → resolved → closed

---

## 3. Biểu đồ Use Case (Use Case Diagram)

Biểu đồ Use Case tổng quát dưới đây mô hình hóa toàn bộ 48 yêu cầu chức năng đã phân tích, theo chuẩn UML 2.5 [4]. Biểu đồ thể hiện quan hệ giữa 5 tác nhân chính và 3 tác nhân bên ngoài với các use case của hệ thống.

> **Ghi chú ký hiệu:**
> - Hình người (stick figure): Actor
> - Hình oval: Use Case
> - Đường liền: Association (actor tham gia use case)
> - Nét đứt `<<include>>`: Use case bắt buộc gọi use case khác
> - Nét đứt `<<extend>>`: Use case mở rộng tùy chọn

### Tóm tắt quan hệ Actor — Use Case

| Actor | Số Use Cases | Use Cases chính |
|-------|:-----------:|----------------|
| Guest | 5 | Browse Events, Search, View Detail, Register, Login |
| Attendee | 12 | Mua vé, Checkout, Thanh toán, Xem vé, Xem orders, Chat, Support Ticket, Profile |
| Organizer | 15 | CRUD Event, TicketTypes, Vouchers, Staff, Dashboard, Chat, Check-in |
| Staff | 3 | QR Check-in, View Attendees, Staff Dashboard |
| Admin | 13 | Manage Users, Approve Events, Categories, Orders, System Settings, Dashboard, System Vouchers |

---

## 4. Tổng kết chương

Chương 2 đã thực hiện phân tích yêu cầu toàn diện cho hệ thống Online Event Ticketing Platform với các kết quả chính:

| Hạng mục | Kết quả |
|----------|---------|
| Mục tiêu hệ thống | 3 Strategic + 5 Tactical + 5 Operational Goals |
| Tác nhân | 5 Primary Actors + 3 External System Actors |
| Yêu cầu chức năng | 48 FRs chia thành 9 modules, 47.9% ưu tiên Cao |
| Yêu cầu phi chức năng | 16 NFRs theo mô hình FURPS+ |
| Use Case chi tiết | 5 fully-dressed use case specifications |
| Mô hình phân quyền | RBAC matrix 17 chức năng × 5 roles |

Kết quả phân tích này là nền tảng cho việc **thiết kế hệ thống** (Chương 3) bao gồm: thiết kế kiến trúc, thiết kế cơ sở dữ liệu, và thiết kế giao diện.

---

## Tài liệu tham khảo (Chương 2)

[1] Standish Group, "CHAOS Report 2020: Beyond Infinity," The Standish Group International, 2020.

[2] IEEE, "IEEE Standard Glossary of Software Engineering Terminology," IEEE Std 610.12-1990, 1990.

[3] IEEE, "IEEE Recommended Practice for Software Requirements Specifications," IEEE Std 830-1998, 1998.

[4] Object Management Group (OMG), "Unified Modeling Language (UML) Specification, Version 2.5.1," OMG, 2017.

[5] R. Smith, "The RACI Matrix: A Tool for Organizational Analysis and Design," *Project Management Journal*, vol. 36, no. 4, 2005.

[6] I. Jacobson, G. Booch, and J. Rumbaugh, *The Unified Software Development Process*, Addison-Wesley, 1999.

[7] R. Grady and D. Caswell, *Software Metrics: Establishing a Company-Wide Program*, Prentice Hall, 1987.

[8] V. Basili, G. Caldiera, and H. D. Rombach, "The Goal Question Metric Approach," *Encyclopedia of Software Engineering*, Wiley, 1994.

[9] G. T. Doran, "There's a S.M.A.R.T. Way to Write Management's Goals and Objectives," *Management Review*, vol. 70, no. 11, pp. 35-36, 1981.

[10] I. Jacobson, M. Christerson, P. Jonsson, and G. Övergaard, *Object-Oriented Software Engineering: A Use Case Driven Approach*, Addison-Wesley, 1992.

[11] D. Ferraiolo, R. Sandhu, S. Gavrila, et al., "Proposed NIST standard for role-based access control," *ACM TISSEC*, vol. 4, no. 3, pp. 224-274, 2001.

[12] S. Robertson and J. Robertson, *Mastering the Requirements Process: Getting Requirements Right*, 3rd ed., Addison-Wesley, 2012.

[13] A. Cockburn, *Writing Effective Use Cases*, Addison-Wesley, 2001.
