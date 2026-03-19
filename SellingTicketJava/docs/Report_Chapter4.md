# CHƯƠNG 4: THIẾT KẾ CƠ SỞ DỮ LIỆU

## 4.1 Tổng quan hệ quản trị cơ sở dữ liệu

### 4.1.1 Lựa chọn RDBMS

Hệ thống TicketBox sử dụng **Microsoft SQL Server** làm hệ quản trị cơ sở dữ liệu quan hệ (RDBMS). Lựa chọn này dựa trên các tiêu chí:

| Tiêu chí | Đánh giá |
|----------|----------|
| **Yêu cầu môn học** | PRJ301 yêu cầu SQL Server + JDBC |
| **Transaction ACID** | Hỗ trợ đầy đủ cho nghiệp vụ thanh toán vé |
| **Tích hợp IDE** | NetBeans + SQL Server Management Studio |
| **Unicode** | NVARCHAR hỗ trợ tiếng Việt (UTF-16) |
| **Indexing** | Nonclustered Index + INCLUDE columns |
| **CHECK Constraints** | Đảm bảo data integrity ở database level |

### 4.1.2 Thông tin kết nối

- **Database Name:** `SellingTicketDB`
- **Driver:** Microsoft JDBC Driver for SQL Server (`sqljdbc4`)
- **Connection Pooling:** Sử dụng singleton pattern qua lớp `DBContext.java`
- **Authentication:** SQL Server Authentication (sa/password)

### 4.1.3 Quy mô cơ sở dữ liệu

| Chỉ số | Giá trị |
|--------|---------|
| Tổng số bảng | **23 bảng** |
| Bảng nghiệp vụ chính | 12 bảng |
| Bảng hỗ trợ / phụ trợ | 11 bảng |
| Tổng số index | **40+ indexes** |
| Schema version | V3.1 (idempotent) |
| Migration files | 14 files |

---

## 4.2 Mô hình khái niệm (Conceptual Model)

### 4.2.1 Các thực thể chính

Hệ thống TicketBox bao gồm **7 nhóm thực thể** chính:

| STT | Nhóm | Bảng | Mô tả |
|-----|-------|------|-------|
| 1 | **Người dùng & Phân quyền** | Users, Permissions, RolePermissions, UserSessions, PasswordResets | Quản lý tài khoản, xác thực, phân quyền RBAC |
| 2 | **Sự kiện** | Events, Categories, EventStaff, Media | Quản lý sự kiện, danh mục, nhân sự, ảnh/video |
| 3 | **Vé** | TicketTypes, Tickets | Loại vé, vé phát hành (QR code) |
| 4 | **Đơn hàng & Thanh toán** | Orders, OrderItems, PaymentTransactions, SeepayWebhookDedup | Quy trình đặt vé, thanh toán SeePay |
| 5 | **Khuyến mãi** | Vouchers, VoucherUsages | Mã giảm giá, theo dõi sử dụng |
| 6 | **Hỗ trợ & Chat** | SupportTickets, TicketMessages, ChatSessions, ChatMessages | Hệ thống hỗ trợ khách hàng |
| 7 | **Hệ thống** | SiteSettings, ActivityLog, Notifications | Cấu hình, nhật ký, thông báo |

### 4.2.2 Sơ đồ quan hệ thực thể (ER Diagram — Text)

```
┌─────────────┐      1:N      ┌──────────────┐      1:N      ┌──────────────┐
│   Users     │──────────────>│   Events     │──────────────>│ TicketTypes  │
│  (user_id)  │  organizer_id │  (event_id)  │   event_id    │(ticket_type  │
└──────┬──────┘               └──────┬───────┘               │    _id)      │
       │                             │                        └──────┬───────┘
       │ 1:N                         │ 1:N                           │
       v                             v                               │
┌──────────────┐             ┌──────────────┐                        │
│   Orders     │             │  EventStaff  │                        │
│ (order_id)   │             │  (staff_id)  │                        │
└──────┬───────┘             └──────────────┘                        │
       │ 1:N                                                         │
       v                                                             │
┌──────────────┐      N:1                                            │
│  OrderItems  │─────────────────────────────────────────────────────┘
│(order_item   │  ticket_type_id
│    _id)      │
└──────┬───────┘
       │ 1:N
       v
┌──────────────┐
│   Tickets    │
│ (ticket_id)  │
│  QR Code     │
└──────────────┘

┌─────────────┐      1:N      ┌──────────────┐
│   Vouchers  │──────────────>│VoucherUsages │
│(voucher_id) │               │  (usage_id)  │
└─────────────┘               └──────────────┘

┌─────────────┐      1:N      ┌──────────────┐
│   Orders    │──────────────>│  Payment     │
│             │               │ Transactions │
└─────────────┘               └──────────────┘

┌──────────────┐     1:N      ┌──────────────┐
│SupportTickets│─────────────>│TicketMessages│
│              │              │              │
└──────────────┘              └──────────────┘

┌──────────────┐     1:N      ┌──────────────┐
│ ChatSessions │─────────────>│ ChatMessages │
│              │              │              │
└──────────────┘              └──────────────┘
```

### 4.2.3 Các mối quan hệ chính

| Quan hệ | Kiểu | Mô tả |
|----------|------|-------|
| Users → Events | 1:N | Organizer tạo nhiều sự kiện |
| Users → Orders | 1:N | Customer đặt nhiều đơn hàng |
| Events → TicketTypes | 1:N | Mỗi sự kiện có nhiều loại vé |
| Orders → OrderItems | 1:N | Mỗi đơn có nhiều mục (CASCADE DELETE) |
| OrderItems → Tickets | 1:N | Mỗi mục sinh ra nhiều vé (CASCADE DELETE) |
| Events → EventStaff | 1:N | Mỗi sự kiện có nhiều nhân viên (CASCADE DELETE) |
| Orders → PaymentTransactions | 1:N | Mỗi đơn có lịch sử thanh toán |
| Vouchers → VoucherUsages | 1:N | Theo dõi sử dụng voucher |
| Media → Entity (Polymorphic) | N:1 | Media gắn vào user/event/ticket_type |
| Users → SupportTickets | 1:N | Khách tạo nhiều yêu cầu hỗ trợ |
| SupportTickets → TicketMessages | 1:N | Mỗi ticket có thread tin nhắn |
| Users → ChatSessions | 1:N | Khách mở nhiều phiên chat |
| ChatSessions → ChatMessages | 1:N | Mỗi phiên có nhiều tin nhắn |

---

## 4.3 Thiết kế logic — Nhóm Người dùng & Phân quyền

### 4.3.1 Bảng `Users`

Bảng trung tâm lưu trữ tất cả người dùng: customer, organizer, admin, support_agent.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `user_id` | INT IDENTITY(1,1) | **PK** | Khóa chính tự tăng |
| `email` | NVARCHAR(255) | NOT NULL, UNIQUE | Email đăng nhập |
| `password_hash` | NVARCHAR(255) | NOT NULL | Mật khẩu BCrypt hash |
| `full_name` | NVARCHAR(100) | NOT NULL | Họ tên đầy đủ |
| `phone` | NVARCHAR(20) | | Số điện thoại |
| `gender` | NVARCHAR(10) | | Giới tính |
| `date_of_birth` | DATE | | Ngày sinh |
| `role` | NVARCHAR(20) | CHECK IN ('customer', 'organizer', 'admin', 'support_agent') | Vai trò, mặc định 'customer' |
| `avatar` | NVARCHAR(500) | | URL ảnh đại diện |
| `is_active` | BIT | DEFAULT 1 | Trạng thái hoạt động |
| `is_deleted` | BIT | DEFAULT 0 | Soft delete flag |
| `bio` | NVARCHAR(2000) | | Giới thiệu bản thân (organizer) |
| `website` | NVARCHAR(255) | | Website cá nhân |
| `social_facebook` | NVARCHAR(255) | | Link Facebook |
| `social_instagram` | NVARCHAR(255) | | Tài khoản Instagram |
| `email_verified` | BIT | DEFAULT 0 | Email đã xác thực chưa |
| `email_verified_at` | DATETIME | | Thời điểm xác thực email |
| `last_login_at` | DATETIME | | Lần đăng nhập cuối |
| `last_login_ip` | NVARCHAR(45) | | IP lần đăng nhập cuối |
| `password_changed_at` | DATETIME | | Lần đổi mật khẩu cuối |
| `created_at` | DATETIME | DEFAULT GETDATE() | Ngày tạo |
| `updated_at` | DATETIME | DEFAULT GETDATE() | Ngày cập nhật |

**Đặc điểm thiết kế:**
- **Single Table Inheritance:** Tất cả roles dùng chung 1 bảng, phân biệt qua cột `role`
- **BCrypt password:** Sử dụng `$2a$12$...` (cost factor 12) — bảo mật cấp enterprise
- **Soft Delete:** Cột `is_deleted` cho phép xóa mềm, giữ dữ liệu tham chiếu
- **Organizer profile:** Các cột `bio`, `website`, `social_*` chỉ có ý nghĩa khi role = 'organizer'

### 4.3.2 Bảng `Permissions`

Bảng định nghĩa các quyền trong hệ thống theo module.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `permission_id` | INT IDENTITY(1,1) | **PK** | |
| `permission_key` | NVARCHAR(100) | NOT NULL, UNIQUE | Mã quyền (vd: `event.create`) |
| `permission_name` | NVARCHAR(100) | NOT NULL | Tên hiển thị |
| `description` | NVARCHAR(255) | | Mô tả chi tiết |
| `module` | NVARCHAR(50) | NOT NULL | Module (event, order, user, report, setting, media) |

**Danh sách 17 quyền hệ thống:**

| Module | Permission Key | Mô tả |
|--------|---------------|-------|
| event | event.create | Tạo sự kiện mới |
| event | event.edit | Chỉnh sửa sự kiện |
| event | event.delete | Xóa sự kiện |
| event | event.approve | Phê duyệt sự kiện |
| event | event.publish | Xuất bản sự kiện |
| event | event.feature | Đánh dấu nổi bật |
| order | order.view | Xem đơn hàng |
| order | order.refund | Hoàn tiền |
| order | order.export | Xuất báo cáo |
| user | user.view | Xem người dùng |
| user | user.manage | Quản lý người dùng |
| user | user.ban | Khóa tài khoản |
| report | report.view | Xem báo cáo |
| report | report.revenue | Báo cáo doanh thu |
| setting | settings.manage | Quản lý cài đặt |
| media | media.upload | Tải lên media |
| media | media.delete | Xóa media |

### 4.3.3 Bảng `RolePermissions`

Ma trận phân quyền Role-Based Access Control (RBAC).

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `role_permission_id` | INT IDENTITY(1,1) | **PK** | |
| `role` | NVARCHAR(20) | CHECK IN ('customer', 'organizer', 'admin', 'support_agent') | |
| `permission_id` | INT | **FK** → Permissions, CASCADE DELETE | |
| | | UNIQUE (role, permission_id) | Không trùng lặp |

**Ma trận phân quyền:**

| Quyền | Admin | Organizer | Customer |
|-------|:-----:|:---------:|:--------:|
| event.create | ✅ | ✅ | ❌ |
| event.edit | ✅ | ✅ | ❌ |
| event.delete | ✅ | ❌ | ❌ |
| event.approve | ✅ | ❌ | ❌ |
| event.publish | ✅ | ✅ | ❌ |
| event.feature | ✅ | ❌ | ❌ |
| order.view | ✅ | ✅ | ✅ |
| order.refund | ✅ | ❌ | ❌ |
| order.export | ✅ | ✅ | ❌ |
| user.view | ✅ | ❌ | ❌ |
| user.manage | ✅ | ❌ | ❌ |
| user.ban | ✅ | ❌ | ❌ |
| report.view | ✅ | ✅ | ❌ |
| report.revenue | ✅ | ✅ | ❌ |
| settings.manage | ✅ | ❌ | ❌ |
| media.upload | ✅ | ✅ | ✅ |
| media.delete | ✅ | ✅ | ❌ |

### 4.3.4 Bảng `UserSessions`

Quản lý phiên đăng nhập, hỗ trợ multi-device.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `session_id` | INT IDENTITY(1,1) | **PK** | |
| `user_id` | INT | **FK** → Users, CASCADE DELETE | |
| `session_token` | NVARCHAR(255) | NOT NULL, UNIQUE | Token phiên |
| `device_info` | NVARCHAR(255) | | Thông tin thiết bị |
| `ip_address` | NVARCHAR(45) | | Địa chỉ IP (IPv4/IPv6) |
| `expires_at` | DATETIME | NOT NULL | Thời điểm hết hạn |
| `is_active` | BIT | DEFAULT 1 | Phiên còn hoạt động |
| `created_at` | DATETIME | DEFAULT GETDATE() | |
| `last_activity` | DATETIME | DEFAULT GETDATE() | Hoạt động cuối |

### 4.3.5 Bảng `PasswordResets`

Token đặt lại mật khẩu có thời hạn.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `reset_id` | INT IDENTITY(1,1) | **PK** | |
| `user_id` | INT | **FK** → Users, CASCADE DELETE | |
| `reset_token` | NVARCHAR(255) | NOT NULL, UNIQUE | Token reset |
| `expires_at` | DATETIME | NOT NULL | Thời hạn |
| `is_used` | BIT | DEFAULT 0 | Đã sử dụng chưa |
| `used_at` | DATETIME | | Thời điểm sử dụng |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

---

## 4.4 Thiết kế logic — Nhóm Sự kiện

### 4.4.1 Bảng `Categories`

Danh mục phân loại sự kiện.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `category_id` | INT IDENTITY(1,1) | **PK** | |
| `name` | NVARCHAR(100) | NOT NULL | Tên danh mục (VD: Âm nhạc) |
| `slug` | NVARCHAR(100) | NOT NULL, UNIQUE | URL-friendly slug |
| `icon` | NVARCHAR(50) | | FontAwesome icon class |
| `description` | NVARCHAR(500) | | Mô tả |
| `display_order` | INT | DEFAULT 0 | Thứ tự hiển thị |
| `is_deleted` | BIT | DEFAULT 0 | Soft delete |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

**Seed data:** 7 danh mục — Âm nhạc, Thể thao, Workshop, Ẩm thực, Nghệ thuật, Kinh doanh, Công nghệ.

### 4.4.2 Bảng `Events`

Bảng trung tâm lưu trữ thông tin sự kiện — bảng lớn nhất hệ thống.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `event_id` | INT IDENTITY(1,1) | **PK** | |
| `organizer_id` | INT | **FK** → Users, NOT NULL | Người tạo sự kiện |
| `category_id` | INT | **FK** → Categories, NOT NULL | Danh mục |
| `title` | NVARCHAR(255) | NOT NULL | Tiêu đề sự kiện |
| `slug` | NVARCHAR(255) | NOT NULL, UNIQUE | URL slug |
| `short_description` | NVARCHAR(500) | | Mô tả ngắn |
| `description` | NVARCHAR(MAX) | | Nội dung Rich HTML |
| `banner_image` | NVARCHAR(500) | | URL ảnh banner |
| `location` | NVARCHAR(255) | | Tên địa điểm |
| `address` | NVARCHAR(500) | | Địa chỉ chi tiết |
| `start_date` | DATETIME | NOT NULL | Ngày bắt đầu |
| `end_date` | DATETIME | | Ngày kết thúc |
| `status` | NVARCHAR(20) | CHECK IN ('draft', 'pending', 'approved', 'rejected', 'cancelled', 'completed') | Trạng thái duyệt |
| `is_featured` | BIT | DEFAULT 0 | Sự kiện nổi bật |
| `is_private` | BIT | DEFAULT 0 | Sự kiện riêng tư |
| `is_deleted` | BIT | DEFAULT 0 | Soft delete |
| `views` | INT | DEFAULT 0 | Lượt xem |
| `pin_order` | INT | DEFAULT 0 | Thứ tự ghim (0 = không ghim) |
| `display_priority` | INT | DEFAULT 0 | Ưu tiên hiển thị |
| `max_tickets_per_order` | INT | NOT NULL, DEFAULT 0 | Giới hạn vé/đơn (0 = mặc định 10) |
| `max_total_tickets` | INT | NOT NULL, DEFAULT 0 | Tổng vé tối đa (0 = vô hạn) |
| `pre_order_enabled` | BIT | NOT NULL, DEFAULT 0 | Cho phép đặt trước |
| `rejection_reason` | NVARCHAR(MAX) | | Lý do từ chối |
| `rejected_at` | DATETIME | | Thời điểm từ chối |
| `published_at` | DATETIME | | Thời điểm xuất bản |
| `created_at` | DATETIME | DEFAULT GETDATE() | |
| `updated_at` | DATETIME | DEFAULT GETDATE() | |

**Vòng đời trạng thái sự kiện:**

```
draft ──> pending ──> approved ──> completed
                  │         │
                  └──> rejected
                        │
            cancelled <──┘ (by organizer)
```

### 4.4.3 Bảng `EventStaff`

Phân công nhân sự cho sự kiện.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `staff_id` | INT IDENTITY(1,1) | **PK** | |
| `event_id` | INT | **FK** → Events, CASCADE DELETE | |
| `user_id` | INT | **FK** → Users, CASCADE DELETE | |
| `role` | NVARCHAR(20) | CHECK IN ('manager', 'staff', 'scanner'), DEFAULT 'staff' | Vai trò nhân viên |
| `granted_by` | INT | **FK** → Users | Người phân công |
| `created_at` | DATETIME | DEFAULT GETDATE() | |
| | | UNIQUE (event_id, user_id) | Mỗi user chỉ 1 vai trò/sự kiện |

**Vai trò nhân viên:**
- **manager:** Quản lý toàn bộ sự kiện
- **staff:** Nhân viên hỗ trợ
- **scanner:** Nhân viên check-in (quét QR code)

### 4.4.4 Bảng `Media`

Lưu trữ media files (ảnh/video) theo mô hình **Polymorphic Association**.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `media_id` | INT IDENTITY(1,1) | **PK** | |
| `uploader_id` | INT | **FK** → Users, NOT NULL | Người upload |
| `cloudinary_url` | NVARCHAR(500) | NOT NULL | URL Cloudinary |
| `cloudinary_public_id` | NVARCHAR(255) | NOT NULL | Public ID trên Cloudinary |
| `file_name` | NVARCHAR(255) | NOT NULL | Tên file gốc |
| `file_size` | INT | CHECK ≤ 52428800 | Dung lượng (tối đa 50MB) |
| `media_type` | NVARCHAR(10) | CHECK IN ('image', 'video') | Loại media |
| `mime_type` | NVARCHAR(50) | | MIME type (image/jpeg, etc.) |
| `width` | INT | | Chiều rộng (px) |
| `height` | INT | | Chiều cao (px) |
| `entity_type` | NVARCHAR(20) | CHECK IN ('user', 'event', 'ticket_type') | Loại entity liên kết |
| `entity_id` | INT | NOT NULL | ID entity liên kết |
| `media_purpose` | NVARCHAR(20) | CHECK IN ('avatar', 'banner', 'gallery', 'inline', 'ticket_design') | Mục đích sử dụng |
| `display_order` | INT | DEFAULT 0 | Thứ tự hiển thị |
| `alt_text` | NVARCHAR(255) | | Alt text cho SEO/accessibility |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

**Giải thích Polymorphic Association:**

```
Media (entity_type='user',  entity_id=5)  → Users.user_id=5  (avatar)
Media (entity_type='event', entity_id=3)  → Events.event_id=3 (banner, gallery)
Media (entity_type='ticket_type', entity_id=1) → TicketTypes.ticket_type_id=1
```

> Ưu điểm: Một bảng duy nhất cho tất cả media, tránh tạo nhiều bảng junction.
> Nhược điểm: Không thể dùng FK constraint trực tiếp ở database level.

---

## 4.5 Thiết kế logic — Nhóm Vé & Đơn hàng

### 4.5.1 Bảng `TicketTypes`

Định nghĩa các loại vé cho mỗi sự kiện.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `ticket_type_id` | INT IDENTITY(1,1) | **PK** | |
| `event_id` | INT | **FK** → Events, CASCADE DELETE | |
| `name` | NVARCHAR(100) | NOT NULL | Tên loại vé (VIP, Thường, Early Bird) |
| `description` | NVARCHAR(500) | | Mô tả quyền lợi |
| `price` | DECIMAL(18,2) | NOT NULL | Giá vé (VND) |
| `quantity` | INT | NOT NULL | Số lượng phát hành |
| `sold_quantity` | INT | DEFAULT 0 | Đã bán |
| `sale_start` | DATETIME | | Thời điểm mở bán |
| `sale_end` | DATETIME | | Thời điểm ngừng bán |
| `is_active` | BIT | DEFAULT 1 | Còn bán hay không |
| `is_deleted` | BIT | DEFAULT 0 | Soft delete |
| `color_theme` | NVARCHAR(7) | | Mã màu HEX (#FFD700) |
| `design_url` | NVARCHAR(500) | | URL thiết kế vé |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

**Tính vé còn lại:** `remaining = quantity - sold_quantity`

### 4.5.2 Bảng `Orders`

Đơn hàng mua vé — bảng nghiệp vụ quan trọng nhất.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `order_id` | INT IDENTITY(1,1) | **PK** | |
| `order_code` | NVARCHAR(50) | NOT NULL, UNIQUE | Mã đơn hàng (TB-xxxxxx) |
| `user_id` | INT | **FK** → Users, NOT NULL | Người mua |
| `event_id` | INT | **FK** → Events, NOT NULL | Sự kiện |
| `total_amount` | DECIMAL(18,2) | NOT NULL | Tổng tiền trước giảm |
| `discount_amount` | DECIMAL(18,2) | DEFAULT 0 | Tổng giảm giá |
| `final_amount` | DECIMAL(18,2) | NOT NULL | Số tiền thực trả |
| `status` | NVARCHAR(20) | CHECK IN ('pending', 'paid', 'cancelled', 'refunded', 'refund_requested', 'checked_in') | Trạng thái đơn |
| `payment_method` | NVARCHAR(30) | CHECK IN ('seepay', 'bank_transfer', 'cash') | Phương thức thanh toán |
| `payment_date` | DATETIME | | Ngày thanh toán |
| `payment_expires_at` | DATETIME | | Hạn thanh toán |
| `is_deleted` | BIT | DEFAULT 0 | Soft delete |
| `buyer_name` | NVARCHAR(100) | | Tên người mua |
| `buyer_email` | NVARCHAR(255) | | Email người mua |
| `buyer_phone` | NVARCHAR(20) | | SĐT người mua |
| `notes` | NVARCHAR(500) | | Ghi chú |
| `voucher_id` | INT | NULL | Voucher đã áp dụng |
| `voucher_scope` | NVARCHAR(10) | DEFAULT 'NONE' | Phạm vi voucher (NONE/EVENT/SYSTEM) |
| `voucher_fund_source` | NVARCHAR(10) | DEFAULT 'NONE' | Nguồn tài trợ (NONE/ORGANIZER/SYSTEM) |
| `event_discount_amount` | DECIMAL(18,2) | DEFAULT 0 | Giảm giá từ organizer |
| `system_discount_amount` | DECIMAL(18,2) | DEFAULT 0 | Giảm giá từ platform |
| `platform_fee_amount` | DECIMAL(18,2) | DEFAULT 0 | Phí nền tảng |
| `organizer_payout_amount` | DECIMAL(18,2) | DEFAULT 0 | Số tiền trả cho organizer |
| `created_at` | DATETIME | DEFAULT GETDATE() | |
| `updated_at` | DATETIME | DEFAULT GETDATE() | |

**Vòng đời đơn hàng:**

```
pending ──> paid ──> checked_in
    │         │
    │         └──> refund_requested ──> refunded
    │
    └──> cancelled
```

**Công thức đối soát (settlement):**

```
organizer_payout = total_amount - event_discount_amount - platform_fee_amount
final_amount     = total_amount - discount_amount
discount_amount  = event_discount_amount + system_discount_amount
```

### 4.5.3 Bảng `OrderItems`

Chi tiết từng loại vé trong đơn hàng.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `order_item_id` | INT IDENTITY(1,1) | **PK** | |
| `order_id` | INT | **FK** → Orders, CASCADE DELETE | |
| `ticket_type_id` | INT | **FK** → TicketTypes | |
| `quantity` | INT | NOT NULL | Số lượng vé |
| `unit_price` | DECIMAL(18,2) | NOT NULL | Đơn giá tại thời điểm mua |
| `subtotal` | DECIMAL(18,2) | NOT NULL | Thành tiền (quantity × unit_price) |

### 4.5.4 Bảng `Tickets`

Vé thực tế phát hành — mỗi vé có QR code riêng.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `ticket_id` | INT IDENTITY(1,1) | **PK** | |
| `ticket_code` | NVARCHAR(50) | NOT NULL, UNIQUE | Mã vé (TK-xxxx-xxxx) |
| `order_item_id` | INT | **FK** → OrderItems, CASCADE DELETE | |
| `attendee_name` | NVARCHAR(100) | | Tên người tham dự |
| `attendee_email` | NVARCHAR(255) | | Email người tham dự |
| `qr_code` | NVARCHAR(500) | | Dữ liệu QR code |
| `is_checked_in` | BIT | DEFAULT 0 | Đã check-in chưa |
| `checked_in_at` | DATETIME | | Thời điểm check-in |
| `checked_in_by` | INT | **FK** → Users | Nhân viên check-in |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

**Luồng vé:** OrderItem (quantity=3) → tạo 3 bản ghi Tickets, mỗi bản ghi có `ticket_code` và `qr_code` riêng.

---

## 4.6 Thiết kế logic — Nhóm Thanh toán

### 4.6.1 Bảng `PaymentTransactions`

Lưu trữ lịch sử giao dịch thanh toán qua cổng SePay.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `transaction_id` | INT IDENTITY(1,1) | **PK** | |
| `order_id` | INT | **FK** → Orders, NOT NULL | Đơn hàng liên kết |
| `payment_method` | NVARCHAR(30) | NOT NULL | Phương thức TT |
| `seepay_transaction_id` | NVARCHAR(100) | | Mã giao dịch SePay |
| `seepay_reference` | NVARCHAR(100) | | Mã tham chiếu SePay |
| `seepay_qr_code` | NVARCHAR(500) | | QR code thanh toán |
| `amount` | DECIMAL(18,2) | NOT NULL | Số tiền giao dịch |
| `currency` | NVARCHAR(3) | DEFAULT 'VND' | Đơn vị tiền tệ |
| `status` | NVARCHAR(20) | CHECK IN ('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded', 'expired') | Trạng thái |
| `initiated_at` | DATETIME | DEFAULT GETDATE() | Thời điểm khởi tạo |
| `completed_at` | DATETIME | | Thời điểm hoàn thành |
| `expires_at` | DATETIME | | Thời hạn thanh toán |
| `provider_response` | NVARCHAR(MAX) | | Phản hồi từ SePay (JSON) |
| `error_code` | NVARCHAR(50) | | Mã lỗi |
| `error_message` | NVARCHAR(500) | | Thông báo lỗi |
| `ip_address` | NVARCHAR(45) | | IP người thanh toán |

### 4.6.2 Bảng `SeepayWebhookDedup`

Bảng chống xử lý trùng lặp webhook từ SePay — đảm bảo **idempotency**.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `dedup_id` | INT IDENTITY(1,1) | **PK** | |
| `sepay_transaction_id` | NVARCHAR(100) | NOT NULL, UNIQUE | Mã giao dịch SePay (dedup key) |
| `order_code` | NVARCHAR(100) | | Mã đơn hàng liên quan |
| `process_result` | NVARCHAR(30) | DEFAULT 'processed' | Kết quả xử lý |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

**Cơ chế hoạt động:**
1. Webhook SePay gọi đến → kiểm tra `sepay_transaction_id` trong bảng
2. Nếu đã tồn tại → bỏ qua (tránh xử lý trùng)
3. Nếu chưa tồn tại → INSERT rồi xử lý đơn hàng
4. Tự động xóa bản ghi cũ hơn 30 ngày để tránh tăng vô hạn

---

## 4.7 Thiết kế logic — Nhóm Khuyến mãi

### 4.7.1 Bảng `Vouchers`

Mã giảm giá — hỗ trợ 2 phạm vi: theo sự kiện (EVENT) và toàn hệ thống (SYSTEM).

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `voucher_id` | INT IDENTITY(1,1) | **PK** | |
| `organizer_id` | INT | **FK** → Users, NOT NULL | Người tạo voucher |
| `event_id` | INT | **FK** → Events, NULL | Sự kiện áp dụng (NULL = toàn hệ thống) |
| `code` | NVARCHAR(50) | NOT NULL, UNIQUE | Mã voucher |
| `discount_type` | NVARCHAR(20) | CHECK IN ('percentage', 'fixed') | Loại giảm giá |
| `discount_value` | DECIMAL(18,2) | NOT NULL | Giá trị giảm (% hoặc VND) |
| `min_order_amount` | DECIMAL(18,2) | DEFAULT 0 | Đơn tối thiểu |
| `max_discount` | DECIMAL(18,2) | DEFAULT 0 | Giảm tối đa (cho %) |
| `usage_limit` | INT | DEFAULT 0 | Giới hạn sử dụng (0 = vô hạn) |
| `used_count` | INT | DEFAULT 0 | Đã sử dụng |
| `start_date` | DATETIME | | Ngày bắt đầu |
| `end_date` | DATETIME | | Ngày hết hạn |
| `is_active` | BIT | DEFAULT 1 | Đang hoạt động |
| `is_deleted` | BIT | DEFAULT 0 | Soft delete |
| `voucher_scope` | NVARCHAR(10) | DEFAULT 'EVENT' | Phạm vi: EVENT / SYSTEM |
| `fund_source` | NVARCHAR(10) | DEFAULT 'ORGANIZER' | Nguồn tài trợ: ORGANIZER / SYSTEM |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

**Phân loại voucher:**

| voucher_scope | fund_source | Ý nghĩa |
|---------------|-------------|---------|
| EVENT | ORGANIZER | Organizer tự trả chi phí giảm giá cho sự kiện của mình |
| SYSTEM | SYSTEM | Platform (admin) tài trợ giảm giá cho toàn hệ thống |

### 4.7.2 Bảng `VoucherUsages`

Ghi nhận mỗi lần sử dụng voucher.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `usage_id` | INT IDENTITY(1,1) | **PK** | |
| `voucher_id` | INT | **FK** → Vouchers, NOT NULL | |
| `order_id` | INT | **FK** → Orders, NOT NULL | |
| `discount_applied` | DECIMAL(18,2) | NOT NULL | Số tiền giảm thực tế |
| `used_at` | DATETIME | DEFAULT GETDATE() | |

---

## 4.8 Thiết kế logic — Nhóm Hỗ trợ & Chat

### 4.8.1 Bảng `SupportTickets`

Hệ thống yêu cầu hỗ trợ (helpdesk).

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `ticket_id` | INT IDENTITY(1,1) | **PK** | |
| `ticket_code` | NVARCHAR(20) | NOT NULL, UNIQUE | Mã yêu cầu (ST-xxxx) |
| `user_id` | INT | **FK** → Users, NOT NULL | Người tạo yêu cầu |
| `order_id` | INT | **FK** → Orders, NULL | Đơn hàng liên quan |
| `event_id` | INT | **FK** → Events, NULL | Sự kiện liên quan |
| `category` | NVARCHAR(30) | CHECK IN ('payment_error', 'missing_ticket', 'cancellation', 'refund', 'event_issue', 'account_issue', 'technical', 'feedback', 'other') | Phân loại vấn đề |
| `subject` | NVARCHAR(200) | NOT NULL | Tiêu đề |
| `description` | NVARCHAR(MAX) | NOT NULL | Nội dung chi tiết |
| `status` | NVARCHAR(20) | CHECK IN ('open', 'in_progress', 'resolved', 'closed') | Trạng thái xử lý |
| `priority` | NVARCHAR(10) | CHECK IN ('low', 'normal', 'high', 'urgent') | Mức ưu tiên |
| `routed_to` | NVARCHAR(20) | CHECK IN ('admin', 'organizer') | Chuyển đến |
| `assigned_to` | INT | **FK** → Users, NULL | Nhân viên xử lý |
| `resolved_at` | DATETIME | | Thời điểm giải quyết |
| `created_at` | DATETIME | DEFAULT GETDATE() | |
| `updated_at` | DATETIME | DEFAULT GETDATE() | |

### 4.8.2 Bảng `TicketMessages`

Thread tin nhắn trong yêu cầu hỗ trợ.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `message_id` | INT IDENTITY(1,1) | **PK** | |
| `ticket_id` | INT | **FK** → SupportTickets, NOT NULL | |
| `sender_id` | INT | **FK** → Users, NOT NULL | Người gửi |
| `content` | NVARCHAR(MAX) | NOT NULL | Nội dung tin nhắn |
| `is_internal` | BIT | DEFAULT 0 | Ghi chú nội bộ (không hiển thị cho khách) |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

### 4.8.3 Bảng `ChatSessions`

Phiên chat thời gian thực giữa customer và support agent.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `session_id` | INT IDENTITY(1,1) | **PK** | |
| `customer_id` | INT | **FK** → Users, NOT NULL | Khách hàng |
| `agent_id` | INT | **FK** → Users, NULL | Nhân viên hỗ trợ (NULL = chưa assign) |
| `event_id` | INT | **FK** → Events, NULL | Sự kiện liên quan |
| `status` | NVARCHAR(10) | CHECK IN ('waiting', 'active', 'closed') | Trạng thái |
| `created_at` | DATETIME | DEFAULT GETDATE() | |
| `closed_at` | DATETIME | | Thời điểm đóng phiên |

### 4.8.4 Bảng `ChatMessages`

Tin nhắn trong phiên chat.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `message_id` | INT IDENTITY(1,1) | **PK** | |
| `session_id` | INT | **FK** → ChatSessions, NOT NULL | |
| `sender_id` | INT | **FK** → Users, NOT NULL | Người gửi |
| `content` | NVARCHAR(500) | NOT NULL | Nội dung tin nhắn |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

---

## 4.9 Thiết kế logic — Nhóm Hệ thống

### 4.9.1 Bảng `SiteSettings`

Cấu hình hệ thống dạng key-value — linh hoạt, không cần thay đổi schema.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `setting_id` | INT IDENTITY(1,1) | **PK** | |
| `setting_key` | NVARCHAR(100) | NOT NULL, UNIQUE | Khóa cấu hình |
| `setting_value` | NVARCHAR(MAX) | | Giá trị |
| `setting_type` | NVARCHAR(20) | DEFAULT 'string' | Kiểu dữ liệu (string, number, boolean, json) |
| `category` | NVARCHAR(50) | | Nhóm cấu hình |
| `description` | NVARCHAR(255) | | Mô tả |
| `updated_by` | INT | **FK** → Users | Người cập nhật cuối |
| `updated_at` | DATETIME | DEFAULT GETDATE() | |

**Seed data cấu hình mặc định:**

| setting_key | setting_value | category |
|-------------|---------------|----------|
| site_name | TicketBox Vietnam | general |
| platform_fee_percentage | 3 | payment |
| max_tickets_per_order | 10 | ticketing |
| payment_timeout_minutes | 15 | payment |
| min_ticket_price | 10000 | ticketing |
| max_events_per_organizer | 50 | event |
| support_email | support@ticketbox.vn | contact |
| currency | VND | payment |

### 4.9.2 Bảng `ActivityLog`

Nhật ký hoạt động — audit trail cho mọi thao tác quan trọng.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `log_id` | INT IDENTITY(1,1) | **PK** | |
| `user_id` | INT | NULL | Người thực hiện (NULL = system) |
| `action` | NVARCHAR(50) | NOT NULL | Hành động (CREATE, UPDATE, DELETE, LOGIN...) |
| `entity_type` | NVARCHAR(50) | | Loại đối tượng |
| `entity_id` | INT | | ID đối tượng |
| `description` | NVARCHAR(500) | | Mô tả chi tiết |
| `ip_address` | NVARCHAR(45) | | Địa chỉ IP |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

### 4.9.3 Bảng `Notifications`

Thông báo đẩy tới người dùng.

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|-----|---------------|-----------|-------|
| `notification_id` | INT IDENTITY(1,1) | **PK** | |
| `user_id` | INT | **FK** → Users, NOT NULL | Người nhận |
| `title` | NVARCHAR(200) | NOT NULL | Tiêu đề |
| `message` | NVARCHAR(500) | NOT NULL | Nội dung |
| `type` | NVARCHAR(30) | | Loại (order, event, system) |
| `reference_type` | NVARCHAR(30) | | Đối tượng liên quan |
| `reference_id` | INT | | ID đối tượng |
| `is_read` | BIT | DEFAULT 0 | Đã đọc chưa |
| `created_at` | DATETIME | DEFAULT GETDATE() | |

---

## 4.10 Chiến lược tối ưu hóa cơ sở dữ liệu

### 4.10.1 Chiến lược Indexing

Hệ thống sử dụng **40+ nonclustered indexes** được thiết kế theo nguyên tắc **covering index** (bao gồm INCLUDE columns) để tối ưu các truy vấn thường xuyên.

**a) Indexes bảng `Events` (8 indexes):**

| Index Name | Columns | Include | Mục đích |
|------------|---------|---------|---------|
| IX_Events_Organizer | organizer_id | title, start_date, status | Lấy sự kiện theo organizer |
| IX_Events_Category | category_id | title, start_date, status | Lọc theo danh mục |
| IX_Events_Status | status, is_deleted | event_id, title, start_date, banner_image | Trang chủ: lọc approved + not deleted |
| IX_Events_StartDate | start_date, status | event_id, title, banner_image, location | Sắp xếp theo ngày |
| IX_Events_Featured | is_featured, status | event_id, title, start_date | Lọc sự kiện nổi bật |
| IX_Events_Slug | slug | event_id | Tìm theo URL slug |
| IX_Events_SoftDelete | is_deleted, status | event_id, title | Soft delete filter |
| IX_Events_PinDisplay | pin_order, display_priority, start_date | event_id, title, banner_image | Sắp xếp homepage |

**b) Indexes bảng `Orders` (4 indexes):**

| Index Name | Columns | Include | Mục đích |
|------------|---------|---------|---------|
| IX_Orders_User | user_id, status | order_id, event_id, total_amount, created_at | Đơn hàng của tôi |
| IX_Orders_Event | event_id, status | order_id, user_id, total_amount | Dashboard organizer |
| IX_Orders_Code | order_code | order_id, status | Tra cứu theo mã |
| IX_Orders_Event_Status | event_id, status | order_id, order_code, buyer_name, buyer_email, created_at | Check-in flow |

**c) Indexes bảng check-in flow (2 indexes):**

| Index Name | Columns | Include | Mục đích |
|------------|---------|---------|---------|
| IX_Tickets_OrderItem_CheckedIn | order_item_id, is_checked_in | ticket_id, checked_in_at, checked_in_by | Tra vé theo order item |
| IX_OrderItems_Order_TicketType | order_id, ticket_type_id | order_item_id | Join order → items |

**d) Indexes bảng `Media` (3 indexes):**

| Index Name | Columns | Include | Mục đích |
|------------|---------|---------|---------|
| IX_Media_Entity | entity_type, entity_id | media_id, cloudinary_url, media_purpose | Polymorphic lookup |
| IX_Media_Uploader | uploader_id | media_id, file_name, created_at | Media của tôi |
| IX_Media_Purpose | media_purpose, entity_type | media_id, cloudinary_url, entity_id | Lọc theo mục đích |

**e) Indexes bảng khác (10+ indexes):**

| Bảng | Index Name | Columns | Mục đích |
|------|-----------|---------|---------|
| Users | IX_Users_Role | role, is_active, is_deleted | Lọc theo vai trò |
| Users | IX_Users_Email | email | Login lookup |
| TicketTypes | IX_TicketTypes_Event | event_id, is_active | Vé theo sự kiện |
| Tickets | IX_Tickets_Code | ticket_code | Quét QR code |
| Vouchers | IX_Vouchers_Code | code | Tra mã voucher |
| Vouchers | IX_Vouchers_Event | event_id, is_active | Voucher theo sự kiện |
| PaymentTransactions | IX_PaymentTransactions_Order | order_id | Giao dịch theo đơn |
| SupportTickets | IX_SupportTickets_User | user_id, status | Yêu cầu của tôi |
| ChatSessions | IX_ChatSessions_Customer | customer_id, status | Phiên chat của tôi |
| UserSessions | IX_UserSessions_User | user_id, is_active | Phiên đăng nhập |

### 4.10.2 Chiến lược đảm bảo toàn vẹn dữ liệu (Data Integrity)

**a) Referential Integrity (Khóa ngoại):**

| Chiến lược | Bảng áp dụng | Giải thích |
|------------|-------------|-----------|
| CASCADE DELETE | OrderItems, Tickets, EventStaff, UserSessions, PasswordResets | Xóa cha → tự động xóa con |
| SET NULL | Orders.voucher_id | Xóa voucher → order vẫn tồn tại |
| NO ACTION | Events.organizer_id, Orders.user_id | Không cho xóa user nếu còn sự kiện/đơn hàng |

**b) CHECK Constraints:**

| Bảng | Constraint | Ý nghĩa |
|------|-----------|---------|
| Users | role IN ('customer', 'organizer', 'admin', 'support_agent') | Chỉ 4 vai trò hợp lệ |
| Events | status IN ('draft', 'pending', 'approved', 'rejected', 'cancelled', 'completed') | 6 trạng thái |
| Orders | status IN ('pending', 'paid', 'cancelled', 'refunded', 'refund_requested', 'checked_in') | 6 trạng thái |
| Media | file_size ≤ 52428800 | Tối đa 50MB |
| Media | entity_type IN ('user', 'event', 'ticket_type') | 3 entity hợp lệ |
| Vouchers | discount_type IN ('percentage', 'fixed') | 2 kiểu giảm giá |

**c) UNIQUE Constraints:**

| Bảng | Columns | Ý nghĩa |
|------|---------|---------|
| Users | email | Không trùng email |
| Events | slug | Không trùng URL |
| Orders | order_code | Mã đơn duy nhất |
| Tickets | ticket_code | Mã vé duy nhất |
| Vouchers | code | Mã voucher duy nhất |
| Categories | slug | Slug danh mục duy nhất |
| EventStaff | (event_id, user_id) | Mỗi user 1 vai trò/sự kiện |
| RolePermissions | (role, permission_id) | Không gán trùng quyền |
| SeepayWebhookDedup | sepay_transaction_id | Key chống trùng webhook |

**d) Soft Delete Pattern:**

Áp dụng cho 5 bảng: `Users`, `Categories`, `Events`, `TicketTypes`, `Vouchers`, `Orders`.

```
-- Thay vì DELETE vật lý:
UPDATE Events SET is_deleted = 1 WHERE event_id = @id;

-- Truy vấn phải lọc:
SELECT * FROM Events WHERE is_deleted = 0;

-- Composite index hỗ trợ:
CREATE INDEX IX_Events_SoftDelete ON Events(is_deleted, status)
INCLUDE (event_id, title);
```

**Lý do sử dụng Soft Delete:**
- Giữ toàn vẹn dữ liệu tham chiếu (FK)
- Hỗ trợ khôi phục dữ liệu (undo)
- Tuân thủ yêu cầu lưu trữ lịch sử giao dịch

### 4.10.3 Chiến lược Migration

Hệ thống sử dụng **14 migration files** theo nguyên tắc **idempotent** (an toàn khi chạy lại nhiều lần):

| STT | Migration File | Nội dung |
|-----|---------------|---------|
| 1 | full_reset_seed.sql | Schema + seed data đầy đủ (master file) |
| 2 | migration_soft_delete.sql | Thêm cột is_deleted cho 5 bảng |
| 3 | migration_event_settings.sql | Thêm cột pin_order, display_priority, max_tickets |
| 4 | migration_event_all_features.sql | Thêm pre_order, max_total_tickets |
| 5 | migration_voucher_settlement.sql | Thêm cột đối soát voucher trong Orders |
| 6 | migration_sepay_dedup.sql | Tạo bảng SeepayWebhookDedup |
| 7 | migration_site_settings.sql | Tạo bảng SiteSettings + seed |
| 8 | migration_auth_fix.sql | Thêm cột gender, date_of_birth, avatar |
| 9 | migration_checkin_performance_indexes.sql | 3 index cho check-in flow |
| 10 | migration_event_staff_canonicalize.sql | Chuẩn hóa EventStaff (CASCADE DELETE + UNIQUE) |

**Pattern idempotent:**

```sql
-- Mỗi migration sử dụng IF NOT EXISTS
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Events')
      AND name = 'pin_order'
)
BEGIN
    ALTER TABLE Events ADD pin_order INT NOT NULL DEFAULT 0;
END
GO
```

---

## 4.11 Tổng kết Chương 4

### Bảng tổng hợp 23 bảng

| STT | Bảng | Số cột | PK | FK | Indexes | Nhóm |
|-----|------|--------|----|----|---------|------|
| 1 | Users | 22 | user_id | — | 2 | Người dùng |
| 2 | Permissions | 5 | permission_id | — | 1 | Phân quyền |
| 3 | RolePermissions | 3 | role_permission_id | 1 | 1 | Phân quyền |
| 4 | UserSessions | 9 | session_id | 1 | 1 | Xác thực |
| 5 | PasswordResets | 7 | reset_id | 1 | 1 | Xác thực |
| 6 | Categories | 8 | category_id | — | 1 | Sự kiện |
| 7 | Events | 26 | event_id | 2 | 8 | Sự kiện |
| 8 | EventStaff | 6 | staff_id | 3 | 1 | Sự kiện |
| 9 | Media | 16 | media_id | 1 | 3 | Media |
| 10 | TicketTypes | 14 | ticket_type_id | 1 | 1 | Vé |
| 11 | Orders | 26 | order_id | 2 | 4 | Đơn hàng |
| 12 | OrderItems | 6 | order_item_id | 2 | 1 | Đơn hàng |
| 13 | Tickets | 10 | ticket_id | 2 | 2 | Vé |
| 14 | PaymentTransactions | 16 | transaction_id | 1 | 1 | Thanh toán |
| 15 | SeepayWebhookDedup | 5 | dedup_id | — | 1 | Thanh toán |
| 16 | Vouchers | 17 | voucher_id | 2 | 2 | Khuyến mãi |
| 17 | VoucherUsages | 5 | usage_id | 2 | 0 | Khuyến mãi |
| 18 | SupportTickets | 16 | ticket_id | 3 | 1 | Hỗ trợ |
| 19 | TicketMessages | 6 | message_id | 2 | 0 | Hỗ trợ |
| 20 | ChatSessions | 7 | session_id | 2 | 1 | Chat |
| 21 | ChatMessages | 5 | message_id | 2 | 0 | Chat |
| 22 | SiteSettings | 8 | setting_id | 1 | 1 | Hệ thống |
| 23 | ActivityLog | 8 | log_id | — | 0 | Hệ thống |
| 24 | Notifications | 9 | notification_id | 1 | 0 | Hệ thống |

### Các quyết định thiết kế quan trọng

| Quyết định | Lý do |
|-----------|-------|
| **Single Table Inheritance** cho Users | Đơn giản hóa JOIN, phù hợp quy mô môn học |
| **Polymorphic Association** cho Media | 1 bảng phục vụ nhiều entity, linh hoạt |
| **Soft Delete** thay vì Hard Delete | Bảo toàn referential integrity + audit |
| **Covering Indexes** với INCLUDE | Tránh key lookup, tối ưu I/O |
| **Idempotent Migrations** | An toàn khi chạy lại, hỗ trợ đội nhóm |
| **Voucher Settlement Columns** | Đối soát tài chính minh bạch |
| **SeePay Dedup Table** | Chống duplicate webhook processing |
| **CHECK Constraints** | Data integrity ở database level |
| **CASCADE DELETE** cho child tables | Tự động dọn dẹp khi xóa parent |
| **Key-Value SiteSettings** | Thêm config không cần thay đổi schema |
