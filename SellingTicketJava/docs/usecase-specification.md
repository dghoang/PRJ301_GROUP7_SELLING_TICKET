# Đặc Tả Use Case — Hệ Thống Bán Vé Sự Kiện Trực Tuyến

> **Dự án:** SellingTicket Platform — PRJ301 Group 4 — FPT University  
> **Phiên bản:** 1.0 — Ngày: 19/03/2026  
> **Tác giả:** Group 4  
> **Mô tả:** Tài liệu đặc tả chi tiết tất cả các luồng Use Case chính của hệ thống

---

## Mục Lục

1. [Tổng Quan Hệ Thống](#1-tổng-quan-hệ-thống)
2. [Module 1: Xác Thực & Quản Lý Người Dùng](#2-module-1-xác-thực--quản-lý-người-dùng)
3. [Module 2: Quản Lý Sự Kiện](#3-module-2-quản-lý-sự-kiện)
4. [Module 3: Quản Lý Loại Vé](#4-module-3-quản-lý-loại-vé)
5. [Module 4: Đặt Vé & Thanh Toán](#5-module-4-đặt-vé--thanh-toán)
6. [Module 5: Check-in QR Code](#6-module-5-check-in-qr-code)
7. [Module 6: Chat & Giao Tiếp](#7-module-6-chat--giao-tiếp)
8. [Module 7: Voucher & Khuyến Mãi](#8-module-7-voucher--khuyến-mãi)
9. [Module 8: Dashboard & Thống Kê](#9-module-8-dashboard--thống-kê)
10. [Module 9: Quản Trị Hệ Thống](#10-module-9-quản-trị-hệ-thống)
11. [Ma Trận Actor – Use Case](#11-ma-trận-actor--use-case)
12. [Phụ Lục: Danh Sách Diagram](#12-phụ-lục-danh-sách-diagram)

---

## 1. Tổng Quan Hệ Thống

### 1.1 Mô tả hệ thống

SellingTicket Platform là nền tảng bán vé sự kiện trực tuyến, cho phép:
- **Organizer** tạo và quản lý sự kiện, loại vé, voucher
- **Customer** duyệt, tìm kiếm, mua vé và thanh toán qua VietQR
- **Staff** scan QR check-in tại cổng sự kiện
- **Admin** duyệt sự kiện, quản lý users, cấu hình hệ thống

### 1.2 Các Actor

| Actor | Mô tả | Kế thừa |
|-------|-------|---------|
| **Guest** | Khách chưa đăng nhập — có thể duyệt sự kiện, đăng ký, đăng nhập | — |
| **Customer** | Người dùng đã đăng nhập — mua vé, xem đơn hàng, chat, profile | Kế thừa Guest |
| **Organizer** | Nhà tổ chức sự kiện — tạo/sửa/xóa sự kiện, quản lý vé, voucher, staff | — |
| **Staff** | Nhân viên soát vé — scan QR, xác nhận check-in | — |
| **Admin** | Quản trị viên hệ thống — duyệt sự kiện, quản lý user, cấu hình | — |

### 1.3 Tổng quan modules

| Module | Số UC | Mô tả |
|--------|-------|-------|
| M1: Xác thực & Người dùng | 6 | Đăng ký, đăng nhập, OAuth, profile, mật khẩu |
| M2: Quản lý Sự kiện | 8 | Tạo, sửa, xóa, duyệt, feature, duyệt, tìm kiếm |
| M3: Quản lý Loại vé | 3 | CRUD loại vé cho sự kiện |
| M4: Đặt vé & Thanh toán | 8 | Checkout, VietQR, webhook, phát vé, lịch sử |
| M5: Check-in QR Code | 3 | Scan QR, check-in thủ công, danh sách |
| M6: Chat & Giao tiếp | 4 | Chat realtime, support ticket |
| M7: Voucher & Khuyến mãi | 4 | Event/System voucher, validate, quản lý |
| M8: Dashboard & Thống kê | 5 | Organizer/Admin/Staff dashboard, báo cáo |
| M9: Quản trị Hệ thống | 7 | Users, categories, orders, config, media |
| **Tổng** | **48** | |

---

## 2. Module 1: Xác Thực & Quản Lý Người Dùng

### UC-1.1: Đăng ký tài khoản

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-1.1 |
| **Tên** | Đăng ký tài khoản |
| **Actor chính** | Guest |
| **Mô tả** | Khách tạo tài khoản mới bằng email và mật khẩu |
| **Tiền điều kiện** | Guest chưa đăng nhập, email chưa tồn tại trong hệ thống |
| **Hậu điều kiện** | Tài khoản được tạo với role = `customer`, mật khẩu được hash BCrypt |

**Luồng chính (Main Flow):**

| Bước | Hành động |
|------|-----------|
| 1 | Guest truy cập trang `/register` |
| 2 | Guest nhập: email, password, confirmPassword, fullName, phone |
| 3 | Hệ thống validate: email format, email unique, password ≥ 8 ký tự, password = confirmPassword, phone format |
| 4 | Hệ thống hash mật khẩu bằng BCrypt (cost factor 12) |
| 5 | Hệ thống INSERT vào bảng `Users` (role = `customer`, is_active = 1) |
| 6 | Hệ thống chuyển hướng → trang login với thông báo "Đăng ký thành công" |

**Luồng thay thế (Alternative Flow):**

| ID | Điều kiện | Xử lý |
|----|-----------|-------|
| 1a | Email đã tồn tại | Hiển thị lỗi "Email đã được sử dụng" |
| 1b | Email format sai | Hiển thị lỗi "Email không hợp lệ" |
| 1c | Password < 8 ký tự | Hiển thị lỗi "Mật khẩu phải ≥ 8 ký tự" |
| 1d | Password ≠ confirmPassword | Hiển thị lỗi "Mật khẩu xác nhận không khớp" |

**File liên quan:** `RegisterServlet.java` → `UserService.java` → `UserDAO.java` → `PasswordUtil.java`

---

### UC-1.2: Đăng nhập hệ thống

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-1.2 |
| **Tên** | Đăng nhập hệ thống |
| **Actor chính** | Guest |
| **Mô tả** | Xác thực email/password, tạo session và JWT token |
| **Tiền điều kiện** | Guest có tài khoản hợp lệ, chưa bị khóa |
| **Hậu điều kiện** | Session tạo, JWT access + refresh token phát hành, chuyển hướng theo role |
| **Include** | Validate Input, Tạo Session & JWT Token |
| **Extend** | Progressive Lockout (khi fail ≥ 5 lần), Remember Me (refresh token 30 ngày) |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Guest nhập email + password tại `/login` |
| 2 | Hệ thống validate đầu vào: null check, length ≤ 255, email regex |
| 3 | Hệ thống normalize: trim + toLowerCase(email) |
| 4 | Hệ thống kiểm tra rate limit: `LoginAttemptTracker.isBlocked(email, ip)` |
| 5 | Hệ thống gọi `UserService.authenticate(email, password)` → BCrypt.checkpw() |
| 6 | Hệ thống áp dụng minimum delay 200ms (chống timing attack) |
| 7 | Hệ thống reset rate limit counter |
| 8 | Hệ thống Session Fixation Protection: invalidate session cũ → tạo mới |
| 9 | Hệ thống phát JWT: access token (7 ngày) + refresh token (30 ngày) |
| 10 | Hệ thống lưu refresh token vào bảng `UserSessions` |
| 11 | Hệ thống đặt cookie HttpOnly: `st_access`, `st_refresh` |
| 12 | Redirect theo role: customer → `/home`, organizer → `/organizer/dashboard`, admin → `/admin/dashboard` |

**Luồng thay thế:**

| ID | Điều kiện | Xử lý |
|----|-----------|-------|
| 4a | IP/email bị khóa (≥ 5 lần fail) | Hiển thị "Tài khoản tạm khóa, thử lại sau 15 phút" |
| 5a | Email không tồn tại hoặc sai password | Hiển thị "Email hoặc mật khẩu không đúng" |
| 5b | User bị vô hiệu hóa (is_active = 0) | Hiển thị "Tài khoản đã bị khóa" |

**File liên quan:** `LoginServlet.java` → `LoginAttemptTracker.java` → `UserService.java` → `UserDAO.java` → `AuthTokenService.java` → `JwtUtil.java` → `CookieUtil.java`

---

### UC-1.3: Đăng nhập Google OAuth 2.0

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-1.3 |
| **Tên** | Đăng nhập Google OAuth 2.0 |
| **Actor chính** | Guest |
| **Mô tả** | Xác thực qua Google OAuth 2.0, tự tạo user nếu chưa tồn tại |
| **Tiền điều kiện** | Guest có tài khoản Google |
| **Hậu điều kiện** | User đăng nhập thành công, session + JWT được tạo |
| **Extend của** | UC-1.2 (Đăng nhập hệ thống) |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Guest click "Đăng nhập bằng Google" |
| 2 | Hệ thống redirect → Google OAuth consent screen (scopes: openid, email, profile) |
| 3 | User đồng ý → Google redirect callback với authorization code |
| 4 | Hệ thống trao đổi code → access_token → lấy thông tin user (email, name, avatar) |
| 5 | Hệ thống kiểm tra email đã tồn tại → Nếu có: đăng nhập. Nếu không: tạo user mới (random password) |
| 6 | Hệ thống tạo session + JWT (giống UC-1.2 bước 8-12) |

**File liên quan:** `GoogleCallbackServlet.java` → `GoogleOAuthService.java` → `UserService.java`

---

### UC-1.4: Đổi mật khẩu

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-1.4 |
| **Tên** | Đổi mật khẩu |
| **Actor chính** | Customer, Organizer |
| **Tiền điều kiện** | User đã đăng nhập |
| **Hậu điều kiện** | Mật khẩu được cập nhật, password_changed_at ghi nhận |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | User vào trang Profile → tab "Đổi mật khẩu" |
| 2 | User nhập: currentPassword, newPassword, confirmNewPassword |
| 3 | Hệ thống verify currentPassword bằng BCrypt.checkpw() |
| 4 | Hệ thống validate newPassword ≥ 8 ký tự, = confirmNewPassword |
| 5 | Hệ thống hash newPassword bằng BCrypt → UPDATE bảng Users |
| 6 | Hiển thị thông báo "Đổi mật khẩu thành công" |

---

### UC-1.5: Quản lý Profile

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-1.5 |
| **Tên** | Quản lý Profile |
| **Actor chính** | Customer, Organizer |
| **Mô tả** | Chỉnh sửa thông tin cá nhân |
| **Extend** | Upload Avatar (qua Cloudinary) |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | User vào `/profile` |
| 2 | User chỉnh sửa: fullName, phone, gender, dateOfBirth, avatar |
| 3 | Organizer có thêm: bio, website, social_facebook, social_instagram |
| 4 | Hệ thống validate đầu vào → UPDATE bảng Users |
| 5 | Nếu upload avatar mới → upload lên Cloudinary → lưu URL vào bảng Media |

---

### UC-1.6: Đăng xuất

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-1.6 |
| **Tên** | Đăng xuất |
| **Actor chính** | Customer, Organizer, Staff, Admin |
| **Hậu điều kiện** | Session bị hủy, cookie bị xóa, redirect → trang chủ |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | User click "Đăng xuất" |
| 2 | Hệ thống hủy HttpSession (invalidate) |
| 3 | Hệ thống xóa refresh token trong bảng UserSessions |
| 4 | Hệ thống xóa cookies: `st_access`, `st_refresh` |
| 5 | Redirect → trang chủ `/` |

---

## 3. Module 2: Quản Lý Sự Kiện

### UC-2.1: Tạo sự kiện mới

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-2.1 |
| **Tên** | Tạo sự kiện mới |
| **Actor chính** | Organizer |
| **Mô tả** | Organizer tạo sự kiện với thông tin chi tiết, upload banner, và tạo loại vé |
| **Tiền điều kiện** | Organizer đã đăng nhập |
| **Hậu điều kiện** | Sự kiện được tạo với status = `pending`, chờ Admin duyệt |
| **Include** | Upload Banner (Cloudinary), Auto-generate Slug, Gửi Notification Admin |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Organizer vào `/organizer/events/create` |
| 2 | Nhập thông tin cơ bản: title, shortDescription, description (HTML editor) |
| 3 | Chọn category từ danh sách Categories |
| 4 | Nhập location, address, startDate, endDate |
| 5 | Upload banner image → Cloudinary CDN |
| 6 | Tạo ≥ 1 loại vé: name, price, quantity, saleStart, saleEnd (xem UC-3.1) |
| 7 | Nhập cài đặt: maxTicketsPerOrder, maxTotalTickets, isPrivate |
| 8 | Hệ thống auto-generate slug từ title (URL-friendly) |
| 9 | Hệ thống INSERT vào bảng Events (status = `pending`) |
| 10 | Hệ thống gửi notification cho Admin: "Sự kiện mới chờ duyệt" |

**Luồng thay thế:**

| ID | Điều kiện | Xử lý |
|----|-----------|-------|
| 2a | Title trống hoặc > 255 ký tự | Hiển thị lỗi validation |
| 4a | startDate > endDate | Hiển thị lỗi "Ngày bắt đầu phải trước ngày kết thúc" |
| 5a | File upload > 50MB | Hiển thị lỗi "File quá lớn" |

**File liên quan:** `CreateEventServlet.java` → `EventService.java` → `EventDAO.java` → `CloudinaryService.java` → `MediaDAO.java`

---

### UC-2.2: Chỉnh sửa sự kiện

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-2.2 |
| **Tên** | Chỉnh sửa sự kiện |
| **Actor chính** | Organizer |
| **Tiền điều kiện** | Organizer sở hữu sự kiện, sự kiện chưa bị xóa |
| **Hậu điều kiện** | Thông tin sự kiện được cập nhật |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Organizer vào `/organizer/events/edit?id={eventId}` |
| 2 | Hệ thống kiểm tra quyền sở hữu: `event.organizerId == session.userId` |
| 3 | Organizer chỉnh sửa các trường cho phép |
| 4 | Nếu sự kiện đã `approved` → giới hạn fields được sửa (không sửa title, dates) |
| 5 | Hệ thống UPDATE bảng Events |

---

### UC-2.3: Xóa/Ẩn sự kiện

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-2.3 |
| **Actor chính** | Organizer |
| **Mô tả** | Soft-delete hoặc chuyển status → draft |

**Business Rule:** Không cho xóa nếu sự kiện đã có orders (status = `paid`).

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Organizer click "Xóa sự kiện" |
| 2 | Hệ thống kiểm tra: SELECT COUNT(*) FROM Orders WHERE event_id = ? AND status = 'paid' |
| 3 | Nếu count = 0 → SET is_deleted = 1 |
| 4 | Nếu count > 0 → Hiển thị lỗi "Không thể xóa sự kiện đã có vé bán" |

---

### UC-2.4: Duyệt/Từ chối sự kiện

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-2.4 |
| **Actor chính** | Admin |
| **Tiền điều kiện** | Sự kiện có status = `pending` |
| **Hậu điều kiện** | Status chuyển sang `approved` hoặc `rejected` |
| **Include** | Gửi Notification cho Organizer |

**Luồng chính (Approve):**

| Bước | Hành động |
|------|-----------|
| 1 | Admin vào `/admin/events` → filter status = `pending` |
| 2 | Admin xem chi tiết sự kiện |
| 3 | Admin click "Duyệt" |
| 4 | Hệ thống UPDATE status = `approved`, published_at = NOW() |
| 5 | Hệ thống gửi notification cho Organizer: "Sự kiện đã được duyệt" |

**Luồng thay thế (Reject):**

| Bước | Hành động |
|------|-----------|
| 3a | Admin click "Từ chối" → nhập rejection_reason |
| 4a | Hệ thống UPDATE status = `rejected`, rejection_reason, rejected_at = NOW() |
| 5a | Hệ thống gửi notification cho Organizer kèm lý do từ chối |

---

### UC-2.5: Feature sự kiện

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-2.5 |
| **Actor chính** | Admin |
| **Mô tả** | Đánh dấu sự kiện nổi bật, hiển thị ưu tiên trên trang chủ |

**Luồng chính:** Admin toggle `is_featured = true/false` → sự kiện xuất hiện ở section Featured trên trang chủ với pin_order và display_priority cao.

---

### UC-2.6: Xem danh sách sự kiện

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-2.6 |
| **Actor chính** | Guest, Customer |
| **Extend** | UC-2.8 Tìm kiếm sự kiện |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Guest truy cập `/events` |
| 2 | Hệ thống query: SELECT FROM Events WHERE status = 'approved' AND is_deleted = 0 |
| 3 | Hiển thị danh sách: banner, title, date, location, giá từ |
| 4 | Pagination: 12 events/trang |
| 5 | Filter: theo category, sắp xếp theo date/popularity |

---

### UC-2.7: Xem chi tiết sự kiện

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-2.7 |
| **Actor chính** | Guest, Customer |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | User click vào event card → `/event/{slug}` |
| 2 | Hệ thống tăng view count +1 |
| 3 | Hiển thị: banner, mô tả chi tiết, địa điểm (bản đồ), thời gian |
| 4 | Hiển thị danh sách loại vé: tên, giá, số lượng còn lại |
| 5 | Hiển thị thông tin Organizer: tên, avatar, bio |

---

### UC-2.8: Tìm kiếm sự kiện

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-2.8 |
| **Actor chính** | Guest, Customer |

**Luồng chính:** Full-text search theo title, location. Filter: category, date range, price range. Kết quả phân trang.

---

## 4. Module 3: Quản Lý Loại Vé

### UC-3.1: Tạo loại vé

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-3.1 |
| **Actor chính** | Organizer |
| **Tiền điều kiện** | Sự kiện đã được tạo |
| **Include** | Validate Sale Window |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Organizer vào trang quản lý sự kiện → tab "Loại vé" |
| 2 | Nhập: name, description, price (≥ 0), quantity (> 0) |
| 3 | Nhập: saleStart, saleEnd (phải ≤ event.endDate) |
| 4 | Hệ thống validate: saleStart < saleEnd, saleEnd ≤ event.endDate |
| 5 | INSERT vào bảng TicketTypes |

**Ví dụ loại vé:** VIP (2,000,000₫), Standard (800,000₫), Early Bird (500,000₫), Free (0₫)

---

### UC-3.2: Chỉnh sửa loại vé

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-3.2 |
| **Actor chính** | Organizer |
| **Include** | Validate Sale Window, Kiểm tra soldCount constraint |

**Business Rule:** `newQuantity ≥ soldCount` — không được giảm số lượng xuống dưới số vé đã bán.

---

### UC-3.3: Xóa/Vô hiệu hóa loại vé

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-3.3 |
| **Actor chính** | Organizer |
| **Mô tả** | Soft-delete: is_active = false. Vé đã bán vẫn valid |

**Business Rule:** Không cho xóa nếu soldCount > 0. Chỉ vô hiệu hóa (ẩn khỏi trang mua vé).

---

## 5. Module 4: Đặt Vé & Thanh Toán

### UC-4.1: Chọn vé

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.1 |
| **Actor chính** | Customer |
| **Tiền điều kiện** | Customer đã đăng nhập, sự kiện đang mở bán |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Customer vào trang chi tiết sự kiện |
| 2 | Chọn loại vé + số lượng |
| 3 | Hệ thống validate: quantity ≤ available, ≤ maxTicketsPerOrder |
| 4 | Hệ thống validate: saleStart ≤ NOW() ≤ saleEnd |
| 5 | Click "Mua vé" → chuyển sang trang Checkout |

---

### UC-4.2: Checkout đơn hàng

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.2 |
| **Actor chính** | Customer |
| **Mô tả** | Tạo đơn hàng với Atomic Transaction |
| **Include** | Validate Voucher, Atomic Transaction |
| **Extend** | Timeout 15 phút (auto-cancel), Resume thanh toán |

**Luồng chính (Atomic Transaction):**

| Bước | Hành động |
|------|-----------|
| 1 | Customer nhập buyer info: buyerName, buyerEmail, buyerPhone, notes |
| 2 | (Tùy chọn) Nhập mã voucher → hệ thống validate (xem UC-7.3) |
| 3 | Hệ thống tính: totalAmount, discountAmount, finalAmount |
| 4 | **BEGIN TRANSACTION** |
| 5 | INSERT vào bảng Orders (status = `pending`, payment_expires_at = NOW() + 15 phút) |
| 6 | INSERT vào bảng OrderItems (cho mỗi loại vé × số lượng) |
| 7 | UPDATE TicketTypes SET sold_quantity += quantity (atomic) |
| 8 | Nếu có voucher: INSERT vào VoucherUsages, UPDATE Vouchers.used_count += 1 |
| 9 | **COMMIT** |
| 10 | Chuyển sang trang thanh toán VietQR |

**Luồng thay thế:**

| ID | Điều kiện | Xử lý |
|----|-----------|-------|
| 7a | sold_quantity + quantity > total quantity | **ROLLBACK** → "Hết vé" |
| 9a | Bất kỳ lỗi nào | **ROLLBACK** toàn bộ → giữ nguyên trạng thái |

---

### UC-4.3: Thanh toán VietQR (SePay)

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.3 |
| **Actor chính** | Customer |
| **Mô tả** | Tạo mã QR qua SePay API, customer chuyển khoản ngân hàng |
| **Include** | Webhook IPN Validation |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Hệ thống gọi SePay API → nhận QR code + thông tin CK |
| 2 | Hiển thị QR code + nội dung CK: `SEVQR {orderCode}` |
| 3 | Hiển thị countdown timer 15 phút |
| 4 | Customer scan QR bằng app ngân hàng → chuyển khoản |
| 5 | SePay gửi webhook IPN → hệ thống xử lý (xem UC-4.4) |

---

### UC-4.4: Webhook IPN — Xác nhận tự động

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.4 |
| **Mô tả** | SePay gửi POST callback khi nhận được tiền |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | SePay POST `/api/webhook/sepay` với transaction data |
| 2 | Hệ thống validate: API key header, body size ≤ 10KB |
| 3 | Hệ thống parse content → extract orderCode từ transferContent |
| 4 | Idempotency check: kiểm tra bảng SeepayWebhookDedup |
| 5 | Validate amount: `transferAmount ≥ order.finalAmount` |
| 6 | UPDATE Orders SET status = `paid`, payment_date = NOW() |
| 7 | UPDATE PaymentTransactions SET status = `completed` |
| 8 | Trigger phát vé → UC-4.5 |

---

### UC-4.5: Phát vé điện tử (Ticket Issuance)

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.5 |
| **Mô tả** | Tự động tạo N vé riêng lẻ sau khi thanh toán thành công |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Với mỗi OrderItem: tạo N tickets (N = quantity) |
| 2 | Mỗi ticket: generate ticketCode unique (format: `TK-{UUID}`) |
| 3 | Tạo QR code: JWT token chứa {ticketId, ticketCode, eventId}, ký HMAC-SHA256 |
| 4 | INSERT vào bảng Tickets |
| 5 | Gửi notification cho Customer: "Vé đã sẵn sàng" |

---

### UC-4.6: Xem vé đã mua

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.6 |
| **Actor chính** | Customer |

**Luồng chính:** Customer vào `/my-tickets` → hiển thị tất cả vé: eventTitle, ticketType, ticketCode, QR code, trạng thái check-in.

---

### UC-4.7: Xem lịch sử đơn hàng

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.7 |
| **Actor chính** | Customer |

**Luồng chính:** Customer vào `/orders` → danh sách orders: orderCode, event, totalAmount, status, paymentDate. Click → xem chi tiết order items.

---

### UC-4.8: Resume thanh toán

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.8 |
| **Actor chính** | Customer |
| **Mô tả** | Quay lại thanh toán cho orders đang pending |

**Luồng chính:** Customer vào lịch sử đơn hàng → click "Thanh toán lại" → hệ thống kiểm tra chưa hết hạn → refresh QR code → hiển thị trang thanh toán.

---

### UC-4.9: Xác nhận thanh toán thủ công

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.9 |
| **Actor chính** | Admin |
| **Mô tả** | Admin xác nhận thanh toán khi webhook fail |

**Luồng chính:** Admin vào `/admin/orders` → tìm order pending → kiểm tra bằng chứng CK → click "Xác nhận" → status = `paid` → trigger phát vé.

---

### UC-4.10: Hết hạn đơn hàng

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-4.10 |
| **Mô tả** | Tự động cancel đơn hàng sau 15 phút không thanh toán |

**Luồng chính:** Background job kiểm tra: `Orders WHERE status = 'pending' AND payment_expires_at < NOW()` → UPDATE status = `cancelled` → Hoàn trả soldCount vào TicketTypes.

---

## 6. Module 5: Check-in QR Code

### UC-5.1: Scan QR check-in

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-5.1 |
| **Actor chính** | Staff, Organizer |
| **Include** | Decode QR Code, Validate Ticket, Hiển thị thông tin attendee, Xác nhận check-in |
| **Extend** | Manual Code Input (fallback), Duplicate Check-in Warning |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Staff mở trang `/staff/checkin/{eventId}` |
| 2 | Camera scan QR code trên vé (sử dụng jsQR library) |
| 3 | Hệ thống decode JWT token → extract ticketCode |
| 4 | Hệ thống validate: ticket tồn tại, đúng event, chưa check-in, order đã paid |
| 5 | Hiển thị thông tin: attendee name, ticket type, seat info |
| 6 | Staff xác nhận → UPDATE Tickets SET is_checked_in = 1, checked_in_at = NOW(), checked_in_by = staffId |
| 7 | Hiển thị ✅ "Check-in thành công" |

**Luồng thay thế:**

| ID | Điều kiện | Xử lý |
|----|-----------|-------|
| 4a | Vé không tồn tại | ❌ "Mã vé không hợp lệ" |
| 4b | Vé không thuộc sự kiện này | ❌ "Vé không thuộc sự kiện này" |
| 4c | Vé đã check-in | ⚠️ "Vé đã sử dụng lúc {checked_in_at}" |
| 4d | Order chưa paid | ❌ "Đơn hàng chưa thanh toán" |

---

### UC-5.2: Check-in thủ công

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-5.2 |
| **Actor chính** | Staff |
| **Mô tả** | Nhập ticketCode thủ công khi camera không hoạt động |

---

### UC-5.3: Xem danh sách check-in

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-5.3 |
| **Actor chính** | Staff, Organizer |

**Hiển thị realtime:** Tổng attendees, đã check-in, chưa check-in, tỷ lệ %. Search/filter theo tên, loại vé.

---

## 7. Module 6: Chat & Giao Tiếp

### UC-6.1: Tạo phiên chat

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-6.1 |
| **Actor chính** | Customer |
| **Mô tả** | Customer mở cuộc chat với Organizer của sự kiện |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Customer vào trang chi tiết sự kiện → click "Chat với nhà tổ chức" |
| 2 | Hệ thống kiểm tra ChatSession đã tồn tại (eventId, customerId) |
| 3 | Nếu chưa có → INSERT ChatSession (status = `waiting`) |
| 4 | Nếu đã có → reopen session đó |
| 5 | Chuyển vào giao diện chat |

**Business Rule:** 1 ChatSession per (event, customer, organizer)

---

### UC-6.2: Gửi/Nhận tin nhắn

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-6.2 |
| **Actor chính** | Customer, Organizer |

**Luồng chính:** User nhập tin nhắn → INSERT ChatMessages → AJAX polling hiển thị realtime cho cả 2 bên. Mỗi message chứa: senderName, senderRole, content, timestamp.

---

### UC-6.3: Gửi Support Ticket

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-6.3 |
| **Actor chính** | Customer |
| **Include** | Auto-routing, Auto-generate Ticket Code |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Customer vào `/support/create` |
| 2 | Chọn category: payment_error, missing_ticket, cancellation, refund, event_issue, account_issue, technical, feedback |
| 3 | Nhập subject + description |
| 4 | (Tùy chọn) Đính kèm eventId hoặc orderId liên quan |
| 5 | Hệ thống generate ticketCode: `SUP-{6 chữ số}` |
| 6 | Auto-routing: nếu event-related → routed_to = `organizer`, else → `admin` |
| 7 | INSERT SupportTickets (status = `open`, priority = `normal`) |

---

### UC-6.4: Xử lý Support Ticket

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-6.4 |
| **Actor chính** | Organizer, Admin |
| **Extend** | Escalate Priority |

**Status flow:** `open` → `in_progress` → `resolved` → `closed`

**Luồng chính:** Admin/Organizer xem ticket → trả lời (INSERT TicketMessages) → cập nhật status → gửi notification cho Customer.

---

## 8. Module 7: Voucher & Khuyến Mãi

### UC-7.1: Tạo Event Voucher

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-7.1 |
| **Actor chính** | Organizer |
| **Mô tả** | Tạo mã giảm giá cho sự kiện cụ thể. Scope = EVENT, Fund source = ORGANIZER |

**Fields:** code (unique), discountType (percentage/fixed), discountValue, minOrderAmount, maxDiscount, usageLimit, startDate, endDate.

---

### UC-7.2: Tạo System Voucher

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-7.2 |
| **Actor chính** | Admin |
| **Mô tả** | Tạo mã giảm giá toàn hệ thống. Scope = SYSTEM, Fund source = SYSTEM |

---

### UC-7.3: Validate & Áp dụng Voucher

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-7.3 |
| **Actor chính** | Customer |
| **Include** | Tính Discount Amount, Tách nguồn chi phí, Cập nhật usedCount |

**Validation chain (7 bước):**

| # | Kiểm tra | Lỗi nếu fail |
|---|----------|---------------|
| 1 | Code tồn tại? | "Mã voucher không hợp lệ" |
| 2 | isActive == true? | "Mã voucher đã bị vô hiệu hóa" |
| 3 | NOW() ≥ startDate? | "Mã voucher chưa bắt đầu" |
| 4 | NOW() ≤ endDate? | "Mã voucher đã hết hạn" |
| 5 | usedCount < usageLimit? | "Mã voucher đã hết lượt sử dụng" |
| 6 | totalAmount ≥ minOrderAmount? | "Đơn hàng chưa đạt giá trị tối thiểu" |
| 7 | Scope phù hợp (EVENT/SYSTEM)? | "Mã voucher không áp dụng cho sự kiện này" |

**Tính discount:**
- `percentage`: discount = min(totalAmount × discountValue%, maxDiscount)
- `fixed`: discount = min(discountValue, totalAmount)

**Tách nguồn:** Order lưu cả `event_discount_amount` (organizer chịu) và `system_discount_amount` (platform chịu).

---

### UC-7.4: Quản lý Voucher

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-7.4 |
| **Actor chính** | Organizer, Admin |

**Luồng chính:** CRUD voucher + xem thống kê: usedCount/usageLimit, tổng discount đã phát. Activate/Deactivate voucher.

---

## 9. Module 8: Dashboard & Thống Kê

### UC-8.1: Organizer Dashboard

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-8.1 |
| **Actor chính** | Organizer |
| **Include** | Tính toán KPIs, Render Charts |
| **Extend** | Filter by Date Range |

**KPIs hiển thị:**
- Tổng sự kiện (theo status: approved, pending, draft)
- Tổng vé đã bán
- Tổng doanh thu (VND)
- Biểu đồ: vé bán theo ngày (Line chart), top 5 events by revenue (Bar chart)
- Conversion rate: views → orders

---

### UC-8.2: Admin Dashboard

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-8.2 |
| **Actor chính** | Admin |

**KPIs toàn hệ thống:**
- Total users (theo role), Total events (theo status), Total orders (theo status)
- Monthly revenue chart (Bar chart)
- Category distribution (Doughnut chart)
- User growth trend

---

### UC-8.3: Staff Dashboard

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-8.3 |
| **Actor chính** | Staff |

**Hiển thị:** Danh sách sự kiện được phân công, thống kê check-in mỗi event: đã/chưa/tổng, pending events count.

---

### UC-8.4: Báo cáo chi tiết

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-8.4 |
| **Actor chính** | Organizer, Admin |
| **Extend** | Export PDF/CSV |

**Nội dung:** Revenue by event, order summary, user growth, category performance.

---

### UC-8.5: Activity Log

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-8.5 |
| **Actor chính** | Admin |

**Ghi nhận:** LOGIN, LOGOUT, CREATE_EVENT, APPROVE_EVENT, REJECT_EVENT, CONFIRM_PAYMENT, BAN_USER, UPDATE_SETTINGS. Mỗi log: userId, action, details, ipAddress, createdAt.

---

## 10. Module 9: Quản Trị Hệ Thống

### UC-9.1: Quản lý Users

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-9.1 |
| **Actor chính** | Admin |
| **Include** | Pagination & Search/Filter, Ghi Activity Log, Soft-delete |
| **Extend** | Bulk Operations |

**Luồng chính:**

| Bước | Hành động |
|------|-----------|
| 1 | Admin vào `/admin/users` |
| 2 | Xem danh sách users (phân trang, 20/trang) |
| 3 | Search by name/email, filter by role/status |
| 4 | Click user → xem chi tiết: profile, orders, login history |
| 5 | Actions: Activate/Deactivate (ban), Soft-delete, Change role |

---

### UC-9.2: Quản lý Categories

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-9.2 |
| **Actor chính** | Admin |

**CRUD:** name, slug, icon (FontAwesome), description, display_order. Toggle is_deleted.

---

### UC-9.3: Quản lý đơn hàng

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-9.3 |
| **Actor chính** | Admin |

**Luồng chính:** Xem toàn bộ orders → filter: status, event, date range → view order details → xác nhận thanh toán thủ công (xem UC-4.9).

---

### UC-9.4: Quản lý thông báo

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-9.4 |
| **Actor chính** | Admin |

**Luồng chính:** Gửi notification: toàn hệ thống (broadcast) hoặc targeted user groups (theo role, email).

---

### UC-9.5: Cấu hình hệ thống

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-9.5 |
| **Actor chính** | Admin |

**Bảng SiteSettings (key-value):** siteName, contactEmail, contactPhone, defaultMaxTickets, platformFeePercent, maintenanceMode. Singleton pattern — cached in memory.

---

### UC-9.6: Upload Media

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-9.6 |
| **Actor chính** | Organizer, Admin |

**Luồng chính:** Upload file → validate (type: image/video, size ≤ 50MB) → Cloudinary CDN → lưu URL vào bảng Media (polymorphic: entity_type + entity_id).

---

### UC-9.7: Quản lý Staff sự kiện

| Thuộc tính | Giá trị |
|------------|---------|
| **ID** | UC-9.7 |
| **Actor chính** | Organizer |

**Luồng chính:** Organizer search user by email → assign role (manager/staff/scanner) → INSERT EventStaff. Staff sau đó có thể scan QR check-in cho sự kiện đó.

---

## 11. Ma Trận Actor – Use Case

### Guest

| UC | Tên |
|----|-----|
| UC-1.1 | Đăng ký tài khoản |
| UC-1.2 | Đăng nhập hệ thống |
| UC-1.3 | Đăng nhập Google OAuth |
| UC-2.6 | Xem danh sách sự kiện |
| UC-2.7 | Xem chi tiết sự kiện |
| UC-2.8 | Tìm kiếm sự kiện |

### Customer (kế thừa Guest)

| UC | Tên |
|----|-----|
| UC-1.4 | Đổi mật khẩu |
| UC-1.5 | Quản lý Profile |
| UC-1.6 | Đăng xuất |
| UC-4.1 | Chọn vé |
| UC-4.2 | Checkout đơn hàng |
| UC-4.3 | Thanh toán VietQR |
| UC-4.6 | Xem vé đã mua |
| UC-4.7 | Xem lịch sử đơn hàng |
| UC-4.8 | Resume thanh toán |
| UC-6.1 | Tạo phiên chat |
| UC-6.2 | Gửi/Nhận tin nhắn |
| UC-6.3 | Gửi Support Ticket |
| UC-7.3 | Áp dụng Voucher |

### Organizer

| UC | Tên |
|----|-----|
| UC-2.1 | Tạo sự kiện mới |
| UC-2.2 | Chỉnh sửa sự kiện |
| UC-2.3 | Xóa/Ẩn sự kiện |
| UC-3.1 | Tạo loại vé |
| UC-3.2 | Chỉnh sửa loại vé |
| UC-3.3 | Xóa/Vô hiệu hóa loại vé |
| UC-5.1 | Scan QR check-in |
| UC-5.3 | Xem danh sách check-in |
| UC-6.2 | Gửi/Nhận tin nhắn |
| UC-6.4 | Xử lý Support Ticket |
| UC-7.1 | Tạo Event Voucher |
| UC-7.4 | Quản lý Voucher |
| UC-8.1 | Organizer Dashboard |
| UC-8.4 | Báo cáo / Export |
| UC-9.6 | Upload Media |
| UC-9.7 | Quản lý Staff |

### Staff

| UC | Tên |
|----|-----|
| UC-5.1 | Scan QR check-in |
| UC-5.2 | Check-in thủ công |
| UC-5.3 | Xem danh sách check-in |
| UC-8.3 | Staff Dashboard |

### Admin

| UC | Tên |
|----|-----|
| UC-2.4 | Duyệt/Từ chối sự kiện |
| UC-2.5 | Feature sự kiện |
| UC-4.9 | Xác nhận thanh toán thủ công |
| UC-6.4 | Xử lý Support Ticket |
| UC-7.2 | Tạo System Voucher |
| UC-7.4 | Quản lý Voucher |
| UC-8.2 | Admin Dashboard |
| UC-8.4 | Báo cáo / Export |
| UC-8.5 | Activity Log |
| UC-9.1 | Quản lý Users |
| UC-9.2 | Quản lý Categories |
| UC-9.3 | Quản lý đơn hàng |
| UC-9.4 | Quản lý thông báo |
| UC-9.5 | Cấu hình hệ thống |

---

## 12. Phụ Lục: Danh Sách Diagram

### Use Case Diagrams (9 files)

| File | Module |
|------|--------|
| `UC_00_TongQuan_SystemOverview.puml` | Tổng quan hệ thống |
| `UC_01_UserAuthentication.puml` | M1: Xác thực & Người dùng |
| `UC_02_EventManagement.puml` | M2: Quản lý Sự kiện |
| `UC_03_TicketTypeManagement.puml` | M3: Quản lý Loại vé |
| `UC_04_BookingPayment.puml` | M4: Đặt vé & Thanh toán |
| `UC_05_CheckIn.puml` | M5: Check-in QR Code |
| `UC_06_Communication.puml` | M6: Chat & Giao tiếp |
| `UC_07_VoucherManagement.puml` | M7: Voucher & Khuyến mãi |
| `UC_08_Dashboard.puml` | M8: Dashboard & Thống kê |
| `UC_09_SystemAdministration.puml` | M9: Quản trị Hệ thống |

### Sequence Diagrams (20 files)

| File | Luồng |
|------|-------|
| `SD_01_Registration.puml` | Đăng ký tài khoản |
| `SD_02_Login.puml` | Đăng nhập email/password |
| `SD_03_GoogleOAuth.puml` | Đăng nhập Google OAuth |
| `SD_04_CreateEvent.puml` | Tạo sự kiện |
| `SD_05_ApproveRejectEvent.puml` | Duyệt/Từ chối sự kiện |
| `SD_06_TicketPurchase.puml` | Mua vé |
| `SD_07_SepayPayment.puml` | Thanh toán SePay VietQR |
| `SD_08_QRCheckIn.puml` | Check-in QR |
| `SD_09_ChatSession.puml` | Chat realtime |
| `SD_10_SupportTicket.puml` | Support ticket |
| `SD_11_VoucherValidation.puml` | Validate voucher |
| `SD_12_BrowseSearchEvents.puml` | Duyệt/tìm kiếm sự kiện |
| `SD_13_ProfileManagement.puml` | Quản lý profile |
| `SD_14_DashboardAnalytics.puml` | Dashboard thống kê |
| `SD_15_AdminUserManagement.puml` | Admin quản lý users |
| `SD_16_SecurityFilterChain.puml` | Chuỗi filter bảo mật |
| `SD_17_NotificationSystem.puml` | Hệ thống thông báo |
| `SD_18_ViewOrderHistory.puml` | Xem lịch sử đơn hàng |
| `SD_19_OrderExpiry.puml` | Hết hạn đơn hàng |
| `SD_20_StaffManagement.puml` | Quản lý staff |

---

> **Ghi chú:** Tài liệu này phản ánh đúng code thực tế đã implement trong dự án SellingTicketJava. Mỗi Use Case tham chiếu trực tiếp tới các Servlet, Service, DAO, và bảng database tương ứng.
