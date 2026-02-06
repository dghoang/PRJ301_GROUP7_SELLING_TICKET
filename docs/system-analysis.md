# Ticketbox - Phân tích hệ thống

## 1. Danh sách tác nhân (Actors)

| Tác nhân | Mô tả | Vai trò trong hệ thống |
|----------|-------|------------------------|
| **Khách vãng lai** | Người dùng chưa đăng nhập | Xem sự kiện, tìm kiếm, đăng ký tài khoản |
| **Customer** | Người dùng đã đăng nhập | Mua vé, xem lịch sử đơn hàng, quản lý profile |
| **Organizer** | Nhà tổ chức sự kiện | Tạo/quản lý sự kiện, xem báo cáo bán vé |
| **Admin** | Quản trị viên hệ thống | Phê duyệt sự kiện, quản lý user, cấu hình hệ thống |

---

## 2. Use Case Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           TICKETBOX SYSTEM                              │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        PUBLIC AREA                               │   │
│  │  ╭──────────╮   ╭──────────╮   ╭──────────╮   ╭──────────╮      │   │
│  │  │ Xem sự   │   │ Tìm kiếm │   │ Xem chi  │   │ Đăng ký/ │      │   │
│  │  │ kiện     │   │ sự kiện  │   │ tiết     │   │ Đăng nhập│      │   │
│  │  ╰────┬─────╯   ╰────┬─────╯   ╰────┬─────╯   ╰────┬─────╯      │   │
│  │       │              │              │              │             │   │
│  └───────┼──────────────┼──────────────┼──────────────┼─────────────┘   │
│          │              │              │              │                  │
│          └──────────────┴──────────────┴──────────────┘                  │
│                              │                                           │
│                         <<Actor>>                                       │
│                        [Khách vãng lai]                                 │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      CUSTOMER AREA                               │   │
│  │  ╭──────────╮   ╭──────────╮   ╭──────────╮   ╭──────────╮      │   │
│  │  │ Chọn vé  │   │ Thanh    │   │ Xem lịch │   │ Quản lý  │      │   │
│  │  │          │   │ toán     │   │ sử mua   │   │ Profile  │      │   │
│  │  ╰────┬─────╯   ╰────┬─────╯   ╰────┬─────╯   ╰────┬─────╯      │   │
│  └───────┼──────────────┼──────────────┼──────────────┼─────────────┘   │
│          │              │              │              │                  │
│          └──────────────┴──────────────┴──────────────┘                  │
│                              │                                           │
│                         <<Actor>>                                       │
│                         [Customer]                                      │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     ORGANIZER AREA                               │   │
│  │  ╭──────────╮   ╭──────────╮   ╭──────────╮   ╭──────────╮      │   │
│  │  │ Tạo sự   │   │ Quản lý  │   │ Xem báo  │   │ Quản lý  │      │   │
│  │  │ kiện     │   │ vé       │   │ cáo      │   │ check-in │      │   │
│  │  ╰────┬─────╯   ╰────┬─────╯   ╰────┬─────╯   ╰────┬─────╯      │   │
│  └───────┼──────────────┼──────────────┼──────────────┼─────────────┘   │
│          │              │              │              │                  │
│          └──────────────┴──────────────┴──────────────┘                  │
│                              │                                           │
│                         <<Actor>>                                       │
│                         [Organizer]                                     │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        ADMIN AREA                                │   │
│  │  ╭──────────╮   ╭──────────╮   ╭──────────╮   ╭──────────╮      │   │
│  │  │ Phê duyệt│   │ Quản lý  │   │ Quản lý  │   │ Cấu hình │      │   │
│  │  │ sự kiện  │   │ Users    │   │ danh mục │   │ hệ thống │      │   │
│  │  ╰────┬─────╯   ╰────┬─────╯   ╰────┬─────╯   ╰────┬─────╯      │   │
│  └───────┼──────────────┼──────────────┼──────────────┼─────────────┘   │
│          │              │              │              │                  │
│          └──────────────┴──────────────┴──────────────┘                  │
│                              │                                           │
│                         <<Actor>>                                       │
│                          [Admin]                                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Chức năng nghiệp vụ chính

### 3.1 Module Xác thực (Authentication)
| UC ID | Use Case | Mô tả |
|-------|----------|-------|
| UC01 | Đăng ký | Customer tạo tài khoản mới |
| UC02 | Đăng nhập | Xác thực và tạo session |
| UC03 | Đăng xuất | Hủy session và redirect |
| UC04 | Quên mật khẩu | Reset password qua email |

### 3.2 Module Sự kiện (Events)
| UC ID | Use Case | Mô tả |
|-------|----------|-------|
| UC05 | Xem danh sách sự kiện | Hiển thị sự kiện với filter |
| UC06 | Tìm kiếm sự kiện | Search theo keyword, category |
| UC07 | Xem chi tiết sự kiện | Hiển thị full info + ticket types |
| UC08 | Tạo sự kiện | Organizer tạo event mới |
| UC09 | Phê duyệt sự kiện | Admin approve/reject event |

### 3.3 Module Đặt vé (Booking)
| UC ID | Use Case | Mô tả |
|-------|----------|-------|
| UC10 | Chọn vé | Customer chọn loại vé và số lượng |
| UC11 | Checkout | Nhập thông tin thanh toán |
| UC12 | Thanh toán | Process payment (MoMo, VNPay...) |
| UC13 | Xác nhận đơn hàng | Hiển thị vé điện tử + gửi email |

### 3.4 Module Quản trị (Admin)
| UC ID | Use Case | Mô tả |
|-------|----------|-------|
| UC14 | Quản lý Users | CRUD users, assign roles |
| UC15 | Quản lý Categories | CRUD danh mục sự kiện |
| UC16 | Xem báo cáo | Dashboard thống kê |

---

## 4. Ma trận phân quyền

| Chức năng | Guest | Customer | Organizer | Admin |
|-----------|-------|----------|-----------|-------|
| Xem sự kiện | ✓ | ✓ | ✓ | ✓ |
| Đăng ký/Đăng nhập | ✓ | - | - | - |
| Mua vé | - | ✓ | ✓ | ✓ |
| Xem lịch sử mua | - | ✓ | ✓ | ✓ |
| Tạo sự kiện | - | - | ✓ | ✓ |
| Quản lý sự kiện | - | - | ✓ | ✓ |
| Phê duyệt sự kiện | - | - | - | ✓ |
| Quản lý Users | - | - | - | ✓ |
