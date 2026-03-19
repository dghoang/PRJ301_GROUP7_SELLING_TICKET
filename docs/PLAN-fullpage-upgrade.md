# PLAN: Full Page Upgrade — 404 Prevention & Notification System

> **Trạng thái:** Chờ duyệt | **Ngày:** 26/02/2026
> **Phạm vi:** 39 JSP pages, 30 controllers, notification system

---

## 1. Tổng quan vấn đề

Sau khi audit toàn bộ **39 trang JSP** và **30 controllers**, phát hiện các vấn đề:

### 🔴 CRITICAL — Gây 404 ngay lập tức

| # | Link bị 404 | Trang gọi | Nguyên nhân |
|---|---|---|---|
| 1 | `/order-detail?id=xxx` | `my-tickets.jsp:113` | **KHÔNG có controller** — không tồn tại OrderDetailServlet |
| 2 | `/organizer/team` | `organizer/sidebar.jsp:130,183` | **KHÔNG có controller** — có JSP `team.jsp` nhưng chưa có servlet |
| 3 | `/event?id=xxx` | `ticket-selection.jsp:9` | **SAI route** — controller thực tế là `/event-detail` |
| 4 | `/admin` | `admin/sidebar.jsp:14` | **KHÔNG có mapping** — controller chỉ map `/admin/dashboard` |

### 🟡 WARNING — Link `#` placeholder (dead-end)

| # | Link | Trang | Mô tả |
|---|---|---|---|
| 5 | `href="#"` "Tính năng" | `footer.jsp:54` | Placeholder không dẫn đi đâu |
| 6 | `href="#"` "Điều khoản" | `footer.jsp:63` | Placeholder |
| 7 | `href="#"` "Chính sách" | `footer.jsp:64` | Placeholder |
| 8 | `href="#"` Privacy/Terms/Cookies | `footer.jsp:91-93` | Placeholder |
| 9 | `href="#"` "Quên mật khẩu?" | `login.jsp:176` | Placeholder |

### 🟠 MAJOR — Toast Notification System bị thiếu CSS

Hệ thống `toast.js` (128 dòng) đã được tạo với đầy đủ logic nhưng:
- ❌ **KHÔNG có CSS** — các class `.toast-container`, `.toast-notification`, `.toast-progress` **không tồn tại** trong `main.css`
- ❌ **Xung đột** — `header.jsp` dùng Bootstrap Toast ở góc TRÊN PHẢI, `toast.js` tạo container riêng KHÔNG có vị trí
- ❌ **Vị trí sai** — User yêu cầu thông báo ở **góc dưới bên tay phải**

---

## 2. Kế hoạch thực hiện

### Phase 1: Fix 404 Routes (Critical)

#### 1.1. Fix `/order-detail` → Redirect to existing order flow
- **File:** [NEW] `OrderDetailServlet.java`  
- **Path:** `controller/OrderDetailServlet.java`
- **Logic:** Map `/order-detail`, query order by ID, check ownership, forward to existing `order-confirmation.jsp` with dynamic data
- **Hoặc:** Fix link trong `my-tickets.jsp` trỏ đến `/order-confirmation?id=xxx` (đơn giản hơn)

#### 1.2. Fix `/organizer/team` → Add controller  
- **File:** [NEW] `OrganizerTeamController.java`
- **Path:** `controller/organizer/OrganizerTeamController.java`
- **Logic:** Map `/organizer/team`, forward to existing `organizer/team.jsp`
- **Note:** JSP `team.jsp` đã có, chỉ thiếu controller

#### 1.3. Fix `/event` → `/event-detail` in JSP
- **File:** [MODIFY] `ticket-selection.jsp`
- **Change:** Sửa `href="/event?id=..."` → `href="/event-detail?id=..."`

#### 1.4. Fix `/admin` → Add redirect
- **File:** [MODIFY] `AdminDashboardController.java`
- **Change:** Thêm `/admin` vào urlPatterns (bên cạnh `/admin/dashboard`)

### Phase 2: Fix Placeholder Links

#### 2.1. Footer placeholder links
- **File:** [MODIFY] `footer.jsp`
- **Changes:**
  - "Tính năng" → link đến `/about` (đã có)
  - "Điều khoản" / "Chính sách" / Privacy / Terms / Cookies → link đến `/faq` hoặc tạo anchor sections trong `faq.jsp`

#### 2.2. "Quên mật khẩu?" placeholder
- **File:** [MODIFY] `login.jsp`
- **Change:** `href="#"` → `href="javascript:void(0)"` + `onclick="showInfo('Tính năng sẽ sớm ra mắt')"` (hoặc nếu có ForgotPasswordServlet thì link thật)

### Phase 3: Nâng cấp Toast Notification System (Bottom-Right)

#### 3.1. Thêm CSS cho Toast
- **File:** [MODIFY] `main.css`
- **Thêm ~80 dòng CSS** cho:
  - `.toast-container` — fixed, **bottom-right** (`bottom: 1.5rem; right: 1.5rem`)
  - `.toast-notification` — glassmorphism card, slide-in animation
  - `.toast-success/error/warning/info` — gradient borders theo design system
  - `.toast-progress-bar` — animated progress bar
  - `.toast-close` — nút đóng
  - Responsive cho mobile

#### 3.2. Thống nhất Toast Systems
- **File:** [MODIFY] `header.jsp`
- **Change:** Xóa Bootstrap Toast HTML (`#globalToast`) khỏi `header.jsp`, chuyển logic server-side toast sang dùng `toast.js`
- Server-side toast message (từ session) sẽ gọi `showToast()` thay vì Bootstrap Toast

#### 3.3. Cải tiến toast.js
- **File:** [MODIFY] `toast.js`
- **Thêm:**
  - Stacking (tối đa 3 toast cùng lúc, cái cũ tự loại)
  - Click-to-dismiss
  - Accessibility: `role="alert"`, `aria-live="polite"`

---

## 3. Ma trận ưu tiên

| Priority | Task | Impact | Effort |
|---|---|---|---|
| 🔴 P0 | Fix `/order-detail` 404 | High — user click gây lỗi | 30 min |
| 🔴 P0 | Fix `/organizer/team` 404 | High — sidebar link gây lỗi | 15 min |
| 🔴 P0 | Fix `/event` → `/event-detail` | High — ticket page back button | 5 min |
| 🔴 P0 | Fix `/admin` route | High — admin sidebar gây lỗi | 5 min |
| 🟠 P1 | Toast CSS (bottom-right) | Medium — UX improvement | 45 min |
| 🟠 P1 | Unify toast systems | Medium — consistency | 20 min |
| 🟡 P2 | Fix `#` placeholder links | Low — cosmetic | 15 min |

**Tổng thời gian ước tính: ~2.5 giờ**

---

## 4. Files sẽ thay đổi

### New Files (2)
| File | Mô tả |
|---|---|
| `OrganizerTeamController.java` | Controller cho `/organizer/team` |
| `OrderDetailServlet.java` | Controller cho `/order-detail` (hoặc fix link) |

### Modified Files (7)
| File | Thay đổi |
|---|---|
| `main.css` | +80 dòng CSS cho toast bottom-right |
| `header.jsp` | Xóa Bootstrap Toast, chuyển sang `toast.js` |
| `toast.js` | Thêm stacking, accessibility, cải tiến |
| `ticket-selection.jsp` | Fix link `/event` → `/event-detail` |
| `my-tickets.jsp` | Fix link `/order-detail` |
| `footer.jsp` | Fix placeholder `#` links |
| `login.jsp` | Fix "Quên mật khẩu?" placeholder |
| `AdminDashboardController.java` | Thêm `/admin` vào urlPatterns |

---

## 5. Verification Plan

### Automated Checks
- [ ] Grep tất cả `href=` trong JSP → không còn `href="#"` cho navigation links
- [ ] Grep tất cả `href="${pageContext...}"` routes → tất cả match @WebServlet

### Manual Verification
- [ ] Click từng link trong sidebar (admin, organizer) → no 404
- [ ] Click "Chi tiết" trong my-tickets → shows order detail
- [ ] Trigger toast notification → appears bottom-right
- [ ] Toast auto-dismiss sau 4s
- [ ] Toast progress bar hoạt động
- [ ] Multiple toasts stack correctly
- [ ] Server-side toast (login/logout) hiển thị đúng
- [ ] Mobile responsive toast

---

## 6. Design chi tiết Toast Notification (Bottom-Right)

```
┌──────────────────────────────────┐
│                                  │
│         Main Page Content        │
│                                  │
│                                  │
│                    ┌────────────┐│
│                    │ ✓ Thành    ││
│                    │   công!     ││
│                    │ Đã lưu     ││
│                    │ thành công ││
│                    │ ▓▓▓▓░░░░░ ││
│                    └────────────┘│
└──────────────────────────────────┘
```

**Design tokens:**
- Position: `fixed`, `bottom: 1.5rem`, `right: 1.5rem`
- Width: `380px` (max), responsive down to `calc(100vw - 2rem)`
- Background: glassmorphism (`rgba(255,255,255,0.95)`, `backdrop-filter: blur(20px)`)
- Border-left: `4px solid` theo type (success=#10b981, error=#ef4444, warning=#f59e0b, info=#9333ea)
- Border-radius: `var(--radius-md)` = `16px`
- Shadow: `0 20px 60px rgba(0,0,0,0.15)`
- Animation: `slideInRight 0.4s cubic-bezier(0.4, 0, 0.2, 1)`
- Progress bar: gradient matching type color
- Stack direction: bottom-up, gap 12px, max 3 visible
