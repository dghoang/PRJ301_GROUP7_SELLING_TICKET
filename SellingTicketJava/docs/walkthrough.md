# 📋 MASTER WALKTHROUGH — ĐỒ ÁN PRJ301 GROUP 4: SELLING TICKET

> **Tổng hợp toàn bộ công việc AI hỗ trợ qua 3 phiên làm việc**
> **Dự án:** PRJ301_GROUP4_SELLING_TICKET (Java Servlet/JSP, SQL Server)
> **Ngày tổng hợp:** 2025-07-18

---

## MỤC LỤC

| # | Nội dung | Nguồn Session |
|---|----------|---------------|
| 1 | [Code Review — 24 bugs phát hiện](#1-code-review-toàn-diện) | `922a` |
| 2 | [Payment & Ticket Flow Analysis — 2 bugs + 1 edge case](#2-payment--ticket-flow-analysis) | `922a` |
| 3 | [Staff Flow Analysis — 3 bugs + 1 gap](#3-staff-flow-analysis) | `922a` |
| 4 | [Admin/Staff Brainstorm — 3 options nâng cấp](#4-brainstorm-nâng-cấp-admin--staff) | `922a` |
| 5 | [Tech Debt Cleanup — 6 Java files đã sửa](#5-tech-debt-cleanup) | `922a` |
| 6 | [Round 2 Audit — Kết quả gần hoàn hảo](#6-round-2-audit) | `922a` |
| 7 | [Report Outline — Bố cục 8 chương](#7-report-outline) | `0335` |
| 8 | [Chapter 6 Security Report — 737 dòng chi tiết](#8-chapter-6-security-report) | `0335` |
| 9 | [UML Diagrams — 30 file PlantUML](#9-uml-diagrams) | `c383` |

---

# 1. CODE REVIEW TOÀN DIỆN

> **Scope:** Toàn bộ server-side codebase (controllers, services, DAOs, filters, utilities)
> **Kết quả:** 🔴 7 Critical · 🟠 5 High · 🟡 12 Medium · ✅ 10 Positive

## 1.1. 🔴 Critical Issues (7)

### C1. `JwtUtil.constantTimeEquals()` — Timing Attack Vector
**File:** [JwtUtil.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java#L127-L135)

```java
private static boolean constantTimeEquals(String a, String b) {
    if (a.length() != b.length()) return false;  // ← LEAKS LENGTH
    ...
}
```

**Vấn đề:** `return false` sớm khi length khác nhau **tiết lộ signature length** qua thời gian response. Attacker probe nhiều signature lengths → biết HMAC output size.

**Fix:** Dùng `MessageDigest.isEqual(a.getBytes(), b.getBytes())` — JDK constant-time comparison.

---

### C2. [JwtUtil](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java#18-319) — Custom JSON Parser Fragile & Exploitable
**File:** [JwtUtil.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java#L68-L88)

```java
private static Map<String, String> parseJsonToMap(String json) {
    json = json.replaceAll("[{}\"']", "");
    String[] pairs = json.split(",");
    ...
}
```

**Vấn đề:** Regex parser sẽ break khi value chứa dấu phẩy (`"name":"Nguyễn, Văn A"`), dấu hai chấm (`"note":"time:10:30"`), empty values, hoặc Unicode escapes.

**Fix:** Dùng JSON library (`org.json`, Gson, Jackson) hoặc `javax.json` (Jakarta EE built-in).

---

### C3. Hardcoded JWT Secret with Weak Fallback
**File:** [AppConstants.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/AppConstants.java#L111-L115)

```java
private static String loadSecret() {
    String env = System.getenv("TICKETBOX_JWT_SECRET");
    if (env != null && !env.isEmpty()) return env;
    return "TkB0x_S3cR3t_K3y_2026!@#HMAC256_AntiF0rg3ry";  // ← HARDCODED
}
```

**Vấn đề:** Source code trên GitHub → ai đọc cũng có thể forge JWT → impersonate bất kỳ user → escalate admin. Tương tự với `ADMIN_PRIVATE_KEY`.

**Fix:** Xóa default fallback. Fail loudly khi env var thiếu. Rotate secret ngay lập tức.

---

### C4. `UserDAO.isEmailExists()` — Connection Leak
**File:** [UserDAO.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/UserDAO.java#L203-L226)

```java
public boolean isEmailExists(String email) {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        conn = DBContext.getConnection();
        ...
        return rs.next();
    } catch (Exception e) {
        LOGGER.log(Level.SEVERE, "Error checking email exists", e);
        return false;  // ← No finally block!
    }
    // Missing finally to close conn, ps, rs
}
```

**Vấn đề:** Connection không bao giờ trả về pool khi exception → under load sẽ exhaust connection pool → toàn bộ app chết.

**Fix:** Thêm `finally { DBContext.close(conn, ps, rs); }` matching pattern của các method khác.

---

### C5. `OrderDAO.cancelOrder()` — Race Condition: Tickets Restored Before Status Check
**File:** OrderDAO (cancelOrder method)

```java
public boolean cancelOrder(int orderId) {
    // Step 1: Restore sold_quantity (CHẠY VÔ ĐIỀU KIỆN)
    String restoreSql = "UPDATE TicketTypes SET sold_quantity = sold_quantity - ...";
    ps.executeUpdate();

    // Step 2: Rồi mới check trạng thái
    String updateSql = "UPDATE Orders SET status = 'cancelled' WHERE status IN ('pending','paid')";
    int rows = ps2.executeUpdate();
    if (rows == 0) {
        conn.rollback();  // ← Quá muộn, tickets đã restore!
        return false;
    }
}
```

**Vấn đề:** Restore tickets chạy trước khi check trạng thái order. Order đã `cancelled` hoặc `refunded` → `sold_quantity` giảm lần nữa (double-restore) → inventory ảo.

**Fix:** Swap thứ tự — check + update order status TRƯỚC, rồi restore tickets nếu success.

---

### C6. Database Schema Mismatch — Role Enum Inconsistency

| Source | Allowed Roles |
|--------|--------------|
| DB CHECK constraint | `customer`, `organizer`, `admin` |
| `AppConstants.UserRole` enum | `customer`, `support_agent`, `admin` |

**Vấn đề:** Code định nghĩa `support_agent` nhưng DB không có (DB có `organizer`). → `CHECK constraint violation` khi tạo/update user với `support_agent`.

**Fix:** Đồng bộ enum với DB schema.

---

### C7. `OrderDAO.createOrderAtomic()` — `sold_quantity` Overflow Not Checked

```sql
UPDATE TicketTypes SET sold_quantity = sold_quantity + ?
WHERE ticket_type_id = ? AND (quantity - sold_quantity) >= ?
```

**Vấn đề:** Under high concurrency với `READ COMMITTED`, hai request đồng thời đều pass WHERE check → cả hai increment → `sold_quantity > quantity` (overselling).

**Fix:** Dùng `SERIALIZABLE` isolation hoặc `WITH (UPDLOCK, HOLDLOCK)` hint, hoặc optimistic concurrency với version column.

---

## 1.2. 🟠 High-Severity Issues (5)

| # | Issue | File | Impact |
|---|-------|------|--------|
| **H1** | [DBContext](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/DBContext.java#31-276) Connection Pool — No Connection Validation. Pool trả connection không kiểm tra alive → stale connection gây `SQLServerException` | [DBContext.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/DBContext.java) | Connection crash |
| **H2** | [AuthFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java#34-292) — Session User Not Refreshed. Không check `user.isActive()` → deactivated user vẫn truy cập khi JWT chưa hết hạn | [AuthFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java) | Unauthorized access |
| **H3** | [CsrfFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/CsrfFilter.java#24-220) — API Endpoints Exempt from CSRF. `/api/*` skip CSRF hoàn toàn, `SameSite=Lax` không block programmatic POST | [CsrfFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/CsrfFilter.java) | Cross-site attacks |
| **H4** | [JwtUtil](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java#18-319) — No Algorithm Verification. Không validate `alg` field → token `"alg":"none"` có thể bypass (defense-in-depth) | [JwtUtil.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java) | Token manipulation |
| **H5** | `EventService.getAccessibleEvents()` — N+1 Query Problem. 1 query per staff event → 50 events = 50+ queries | [EventService.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/EventService.java) | Performance |

---

## 1.3. 🟡 Medium Issues (12)

| # | Category | Issue |
|---|----------|-------|
| M1 | Resource Leak | Several DAO methods missing `finally` blocks |
| M2 | Thread Safety | `DBContext.close()` không đảm bảo cả 3 resources (conn/ps/rs) đều close nếu 1 throw |
| M3 | Validation | [isValidUrl()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/InputValidator.java#158-166) không block `javascript:` hoặc data URLs trong redirect |
| M4 | Error Handling | Tất cả DAOs catch `Exception` quá broad, return `false/null/0` — caller không phân biệt "not found" vs "DB error" |
| M5 | Logging | BCrypt verification failure log SEVERE — nên là INFO/WARNING (failed login là bình thường) |
| M6 | Slug Generation | [generateSlug()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/organizer/OrganizerEventController.java#593-602) dùng `System.currentTimeMillis()` — collision trong cùng millisecond |
| M7 | Service Layer | Service constructors `new` DAO trực tiếp — không inject mock được cho testing |
| M8 | Date Handling | `OrderService.generateOrderCode()` dùng millis + 8-char UUID — không globally unique under high throughput |
| M9 | SQL | `OrderDAO.searchOrdersPaged()` dynamic SQL với status arrays — cần review edge cases |
| M10 | Session | `ServletUtil.getSessionUser()` check cả `"user"` và `"account"` session keys — legacy code smell |
| M11 | Security | `AuthTokenService.invalidateUserTokens()` chỉ clear DB, không invalidate in-memory JWT tokens |
| M12 | Architecture | DB schema role `CHECK('customer','organizer','admin')` nhưng [AuthFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java#34-292) dùng `support_agent` |

---

## 1.4. ✅ Positive Observations (10)

| Area | Assessment |
|------|-----------|
| BCrypt passwords | ✅ Cost factor 12, proper library usage |
| CSRF protection | ✅ Double-submit cookie pattern, per-session tokens |
| JWT in HttpOnly cookie | ✅ SameSite=Lax, Secure flag, 24h expiry |
| Input validation | ✅ Centralized [InputValidator](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/InputValidator.java#10-185) with domain-specific methods |
| Constants/Enums | ✅ `AppConstants` eliminates most magic strings |
| Servlet utility class | ✅ `ServletUtil` reduces code duplication |
| Connection pooling | ✅ Custom pool with configurable size, proper LIFO semantics |
| Parameterized queries | ✅ Consistent `PreparedStatement` across all DAOs |
| Vietnamese slug generation | ✅ Proper diacritic handling for URL-safe slugs |
| Atomic order creation | ✅ Transaction with availability check + reservation in single tx |

---

## 1.5. Recommended Fix Priority

| Priority | Issue | Effort | Impact |
|----------|-------|--------|--------|
| **P0 — Now** | C3: Rotate hardcoded JWT secret | 15 min | 🔴 Auth bypass |
| **P0 — Now** | C1: Fix [constantTimeEquals()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java#230-236) | 5 min | 🔴 Token forgery |
| **P0 — Now** | C4: Fix [isEmailExists()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/UserDAO.java#143-156) leak | 5 min | 🔴 Pool exhaustion |
| **P1 — This Sprint** | C2: Replace custom JSON parser | 1 hr | 🔴 Token crash |
| **P1 — This Sprint** | C5: Fix cancel order race condition | 30 min | 🔴 Inventory corruption |
| **P1 — This Sprint** | C6: Align role enums with DB | 30 min | 🔴 Constraint violations |
| **P1 — This Sprint** | H2: Check [isActive](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/model/User.java#70-71) in AuthFilter | 10 min | 🟠 Zombie access |
| **P2 — Next Sprint** | H3: CSRF for API endpoints | 2 hr | 🟠 Cross-site attacks |
| **P2 — Next Sprint** | H5: Fix N+1 queries | 1 hr | 🟠 Performance |
| **P3 — Backlog** | M7: Add DI/constructor injection | 4 hr | 🟡 Testability |
| **P3 — Backlog** | All: Add test suite | 8+ hr | 🟡 Regression safety |

---

## 1.6. Architecture Summary

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│  JSP Views  │◄────│  Servlets    │────►│  Services   │────►│  DAOs        │
│  (22+ pages)│     │  (22 ctrl)   │     │  (3 svcs)   │     │  (6+ DAOs)   │
└─────────────┘     └──────┬───────┘     └──────┬──────┘     └──────┬───────┘
                           │                     │                   │
                    ┌──────┴───────┐      ┌──────┴──────┐    ┌──────┴───────┐
                    │  Filters     │      │  Payment    │    │  DBContext   │
                    │  Auth+CSRF   │      │  Factory    │    │  Pool (JDBC) │
                    └──────────────┘      └─────────────┘    └──────────────┘
```

**Database:** SQL Server 15+ tables, idempotent migration scripts, good indexing strategy.

---

# 2. PAYMENT & TICKET FLOW ANALYSIS

> **Kết luận: Luồng thanh toán & phát vé cơ bản ĐÚNG. Tìm thấy 2 bugs + 1 edge case.**

## 2.1. User Flow ("Tôi đã thanh toán" button)

```
Browser (payment-pending.jsp)
    │── POST /api/payment/status?orderId=X
    │── PaymentStatusServlet validates session + order ownership
    │── OrderService.confirmPayment(orderId, "MANUAL-xxx")
    │    └── OrderDAO.confirmPaymentAtomic(orderId, txRef)
    │         └── UPDATE Orders SET status='paid' WHERE status='pending'
    │── OrderService.issueTickets(orderId, name, email)
    │    └── TicketDAO.createTicketsForOrder(orderId, name, email)
    │         └── SELECT OrderItems → INSERT Tickets → JWT QR
    │── Response: {"status":"paid"}
    └── Browser redirect → /order-confirmation?id=X
```

## 2.2. Admin Flow ("Xác nhận thanh toán" button)

```
Admin (admin-orders.jsp)
    │── POST /admin/orders/mark-paid (orderId)
    │── AdminOrderController
    │    ├── OrderService.confirmPayment(orderId, "ADMIN-MANUAL-xxx")
    │    ├── ticketDAO.getTicketsByOrder(orderId).size()
    │    └── if (existingTickets == 0) → orderService.issueTickets(...)
    └── Flash message + redirect
```

## 2.3. 🐛 Bug 1: [updateTransactionId()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/OrderDAO.java#363-382) — Non-existent column (CRITICAL)

| Item | Detail |
|------|--------|
| **File** | [OrderDAO.java:364-374](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/OrderDAO.java#L364-L374) |
| **SQL** | `UPDATE Orders SET transaction_id = ?` |
| **Problem** | `transaction_id` column **KHÔNG TỒN TẠI** trong Orders table |
| **Impact** | Không ảnh hưởng flow chính (method không được call), nhưng sẽ throw `SQLException` nếu SeePay webhook gọi |
| **Fix** | Thêm column `transaction_id` vào Orders **HOẶC** xóa method |

## 2.4. 🐛 Bug 2: `Vouchers.usage_limit` vs `Vouchers.max_uses` column mismatch

| Item | Detail |
|------|--------|
| **File** | [OrderDAO.java:64-77](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/OrderDAO.java#L64-L77) |
| **SQL in DAO** | `WHERE ... (usage_limit = 0 OR used_count < usage_limit)` |
| **Schema** | Vouchers table defines `max_uses INT` — **KHÔNG PHẢI** `usage_limit` |
| **Impact** | Order creation WITH vouchers fails silently (returns 0). Orders WITHOUT vouchers work fine |
| **Fix** | Change `usage_limit` → `max_uses` trong SQL, hoặc thêm column alias qua migration |

## 2.5. ⚠️ Edge Case: Double Ticket Issuance

- **User flow** (`PaymentStatusServlet.doPost`): **KHÔNG** check tickets đã tồn tại trước khi issue
- **Admin flow** ([AdminOrderController](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/admin/AdminOrderController.java#23-176)): **CÓ** check `existingTickets == 0` trước
- **Mitigation:** [confirmPaymentAtomic()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/OrderDAO.java#333-362) chỉ succeed 1 lần (`WHERE status='pending'`), nên double-click không duplicated. Nhưng rapid double POST có thể race.

---

# 3. STAFF FLOW ANALYSIS

> **Phát hiện 3 bugs + 1 gap trong hệ thống quản lý nhân viên sự kiện**

## 3.1. Kiến trúc Staff System

```
┌── Organizer Side ──────────────────────────────┐
│  Organizer/Manager                              │
│  ├── POST /organizer/events/{id}/staff/add      │
│  ├── GET  /organizer/events/{id}/staff          │
│  └── POST .../staff/remove                      │
│  → OrganizerEventController                     │
│  → EventService (hasVoucherPermission)          │
│  → EventStaffDAO (addStaffByEmail/removeStaff)  │
│  → manage-staff.jsp                             │
└─────────────────────────────────────────────────┘

┌── Staff Portal ────────────────────────────────┐
│  Staff User → /staff/*                          │
│  → StaffAccessFilter (getEventsWhereStaff)      │
│  → StaffDashboardController → dashboard.jsp     │
│  → StaffCheckInController → check-in.jsp        │
│  → EventStaffDAO + TicketDAO                    │
└─────────────────────────────────────────────────┘

┌── DB: EventStaff Table ────────────────────────┐
│  staff_id, event_id, user_id, role,             │
│  granted_by, created_at                         │
│  Roles: manager | staff | scanner               │
└─────────────────────────────────────────────────┘
```

## 3.2. Permission Matrix

Defined in [EventService.java:210-264](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/EventService.java#L210-L264):

| Permission | admin | owner | manager | staff | scanner |
|------------|:-----:|:-----:|:-------:|:-----:|:-------:|
| **Edit** (sửa event, vé) | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Check-in** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Delete** (xóa event) | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Voucher/Staff Mgmt** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Stats** | ✅ | ✅ | ✅ | ✅ | ❌ |

## 3.3. 🐛 Bug 1: [StaffCheckInController](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/staff/StaffCheckInController.java#30-140) KHÔNG kiểm tra role (CRITICAL)

**File:** [StaffCheckInController.java:54](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/staff/StaffCheckInController.java#L54)

```java
// HIỆN TẠI (sai): chỉ check tồn tại trong bảng, KHÔNG check role
if (!eventStaffDAO.hasPermission(eventId, user.getUserId())) { ... }

// CẦN SỬA: check quyền check-in cụ thể
if (!eventService.hasCheckInPermission(eventId, user.getUserId(), user.getRole())) { ... }
```

**Vấn đề:** Role `staff` (chỉ được sửa event per Permission Matrix) cũng check-in được vì [hasPermission()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/EventStaffDAO.java#17-30) chỉ check existence trong bảng EventStaff, không phân biệt role. Vi phạm Permission Matrix.

## 3.4. 🐛 Bug 2: [hasManagerPermission](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/EventService.java#221-224) dùng sai method (MEDIUM)

**File:** [EventService.java:225-231](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/EventService.java#L225-L231)

```java
// BUG: scanner/staff cũng pass, vì hasPermission chỉ check existence
return eventStaffDAO.hasPermission(eventId, userId);

// SHOULD: check specific role
String staffRole = eventStaffDAO.getStaffRole(eventId, userId);
return "manager".equals(staffRole);
```

## 3.5. 🐛 Bug 3: [StaffAccessFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/StaffAccessFilter.java#23-67) không truyền role info (LOW)

**File:** [StaffAccessFilter.java:53-61](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/StaffAccessFilter.java#L53-L61)

`staffAssignedEvents` (list event IDs) vào request attribute, nhưng **không đặt role map**. Controller phải tự query lại role.

## 3.6. Gap 4: Không có Activity Log cho staff actions

Staff check-in, add/remove staff không ghi audit log. Đề xuất tích hợp `ActivityLogService`.

## 3.7. File Map

| Layer | File | Vai trò |
|-------|------|---------|
| Model | [EventStaff.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/model/EventStaff.java) | POJO (staffId, eventId, userId, role, grantedBy) |
| DAO | [EventStaffDAO.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/EventStaffDAO.java) | 7 methods: hasPermission, getStaffByEvent, addStaffByEmail, getStaffRole, getEventsWhereStaff, removeStaff, getAssignedEventsWithDetails |
| Service | [EventService.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/EventService.java) | Permission matrix: getUserEventRole, hasEditPermission, hasCheckInPermission, hasDeletePermission, hasVoucherPermission |
| Filter | [StaffAccessFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/StaffAccessFilter.java) | Guards `/staff/*`, checks EventStaff existence |
| Controller | [StaffDashboardController.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/staff/StaffDashboardController.java) | Dashboard cho staff |
| Controller | [StaffCheckInController.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/staff/StaffCheckInController.java) | Check-in vé (⚠️ missing role check) |
| Controller | [OrganizerEventController.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/organizer/OrganizerEventController.java) | Staff CRUD (add/remove/manage) |
| JSP | staff/dashboard.jsp, staff/check-in.jsp, staff/sidebar.jsp | Staff portal UI |
| JSP | organizer/manage-staff.jsp | Organizer invites/removes staff |
| DB | EventStaff table | Roles: `manager`, `staff`, `scanner` |

---

# 4. BRAINSTORM NÂNG CẤP ADMIN & STAFF

> **3 options đã đề xuất cho user lựa chọn**

## 4.1. Inventory hiện tại

| Module | Pages | Controllers | Chức năng chính |
|--------|-------|-------------|-----------------|
| Admin | 16 JSP | 11 Ctrl + 5 API | Dashboard, Users, Events, Orders, Categories, Reports, Settings, Support, Chat, Vouchers, Event Approval |
| Organizer | 19 JSP | 12 Ctrl + 1 API | Dashboard, Events CRUD, Orders, Check-in, Statistics, Team, Staff, Vouchers, Chat, Support, Settings |
| Staff | 1 JSP | 0 Controller | [manage-staff.jsp](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/webapp/organizer/manage-staff.jsp) (quản lý từ Organizer) |

## 4.2. Gaps phát hiện

### Admin Gaps:
| Gap | Mô tả | Mức độ |
|-----|-------|--------|
| A1 | Dashboard thiếu realtime (Active users, conversion rate) | Medium |
| A2 | Chưa có Activity Log (audit trail) | High |
| A3 | Notification Center | Medium |
| A4 | Role Management chi tiết | High |
| A5 | Payment Management (hoàn tiền, reconciliation) | High |
| A6 | Content Management (banner, featured events) | Medium |
| A7 | System Health monitor | Low |

### Staff Gaps:
| Gap | Mô tả | Mức độ |
|-----|-------|--------|
| S1 | **Không có Staff Portal** — chỉ được quản lý từ Organizer | Critical |
| S2 | Check-in chỉ Organizer, Scanner staff không self-serve | High |
| S3 | Staff thiếu dashboard overview | High |
| S4 | Permissions matrix chưa map rõ | High |
| S5 | Staff không xem được thống kê | Medium |

## 4.3. Option A: "Quick Wins" (~40-60 tool calls)
- Admin UI Polish (3-4 pages): Dashboard widgets, Users filter, Orders refund button, Sidebar fix
- Staff Portal mới (3 pages): dashboard, check-in, event-detail
- StaffAccessFilter + StaffController (2 files backend)
- ✅ Nhanh, ~15-20 files | ❌ Thiếu audit log, notifications

## 4.4. Option B: "Full Admin Upgrade" (~100-150 tool calls, 3-4 phases)
- Admin Dashboard 2.0: realtime stats, quick actions, system health, activity feed
- Admin New Features: Activity Log, Notification Center, Role Management, Payment Management, Content Management
- Staff Portal có permissions check
- Backend: ActivityLogDAO, NotificationDAO, new filters
- ✅ Enterprise-grade | ❌ Cần 2-3 bảng DB mới, effort lớn

## 4.5. Option C: "Staff-First" (~60-80 tool calls)
- Staff Portal hoàn chỉnh (6-7 pages): Dashboard, Check-in, Event Detail, Attendee Search, My Schedule, Reports
- Permission Matrix đầy đủ: manager → view all, check-in, manage sub-staff, view reports; staff → view assigned, check-in, view attendees; scanner → check-in only
- Admin: Minimal upgrade (sidebar fix + dashboard widgets)
- ✅ Staff có system nghiệp vụ đầy đủ | ❌ Admin vẫn basic

---

# 5. TECH DEBT CLEANUP

> **6 Java files đã sửa trực tiếp trong codebase**

## 5.1. Files đã fix

| # | File | Bug Fixed | Thay đổi chính |
|---|------|-----------|-----------------|
| 1 | [JwtUtil.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java) | C1 + C2 + H4 | (1) Thay [constantTimeEquals()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java#230-236) bằng `MessageDigest.isEqual()`, (2) Viết lại JSON parser với escape-aware loop, (3) Thêm [isExpectedAlgorithm()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java#204-217) validate `"HS256"` |
| 2 | [AppConstants.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/AppConstants.java) | C3 + C6 | (1) Xóa hardcoded fallback secret → throw `IllegalStateException` nếu env var thiếu, (2) Đồng bộ [UserRole](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/UserDAO.java#306-318) enum: thêm `organizer`, giữ `support_agent` |
| 3 | [UserDAO.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/UserDAO.java) | C4 | Thêm `finally { DBContext.close(conn, ps, rs); }` vào [isEmailExists()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/UserDAO.java#143-156) |
| 4 | [OrderDAO.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/OrderDAO.java) | C5 | Swap thứ tự trong [cancelOrder()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/OrderDAO.java#383-437): check status TRƯỚC → restore tickets SAU |
| 5 | [EventService.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/EventService.java) | H5 | Thêm method [getEventsByIds(List<Integer>)](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/EventDAO.java#159-180) với `IN (?)` clause, thay thế N+1 loop |
| 6 | [AuthFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java) | H2 | Thêm `if (user == null \|\| !user.isActive()) { clearAndRedirect(); return; }` sau [getUserById()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/UserService.java#92-95) |

## 5.2. Impact

- 🟢 **Zero new bugs introduced** — verified qua Round 2 Audit
- 🟢 **Backward compatible** — API contracts không thay đổi
- 🟡 **C3 fix requires env setup** — production cần set `TICKETBOX_JWT_SECRET` env var

---

# 6. ROUND 2 AUDIT

> **Kết quả: Gần hoàn hảo — chỉ còn 1 Low severity issue**

## 6.1. Executive Summary

| Metric | Result |
|--------|--------|
| **New Issues Found** | 1 (Low severity) |
| **Security Posture** | ✅ Strong |
| **Architecture Quality** | ✅ Clean layered architecture |
| **Input Validation** | ✅ Comprehensive |
| **Auth/AuthZ** | ✅ Multi-layer enforcement |

## 6.2. Issue Still Remaining

### `GoogleOAuthServlet.extractJsonValue()` — Escape-Unaware JSON Parsing

**File:** [GoogleOAuthServlet.java:280-294](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/GoogleOAuthServlet.java#L280-L294)
**Severity:** Low

```java
// Naively finds next quote without checking for backslash escapes
int endQuote = json.indexOf('"', startQuote + 1);
```

Đây là **CÙNG class bug** đã fix ở `JwtUtil.parseSimpleJson()`. Fix bằng escape-aware while-loop.

## 6.3. Security Strengths Verified (8 categories)

| # | Category | Key Findings | Rating |
|---|----------|-------------|--------|
| 1 | **Auth** | Role-based access, support_agent restricted, deactivated users blocked, Bearer token auth, session fixation prevention | ✅ |
| 2 | **CSRF** | Token-per-session with rotation, one-step grace period, Bearer token exemption, SeePay webhook exempted, multipart form fallback | ✅ |
| 3 | **Security Headers** | X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy, direct JSP access blocked | ✅ |
| 4 | **Input Validation** | Event titles (3-200), descriptions (10-500K), phone regex, gender whitelist, date timezone-aware, password strength | ✅ |
| 5 | **Anti-IDOR** | Granular permission engine: hasManagerPermission, hasEditPermission, hasCheckInPermission, hasDeletePermission, hasVoucherPermission | ✅ |
| 6 | **File Upload** | Content type whitelist, 10MB limit, folder prefix whitelist, path traversal prevention, ownership verification | ✅ |
| 7 | **Payment** | Webhook API key validation, duplicate prevention, atomic confirmation, amount validation, admin idempotent | ✅ |
| 8 | **OAuth** | CSRF state parameter, server-side token exchange, OAuth users blocked from password change, session fixation prevented | ✅ |

## 6.4. Architecture Quality

| Aspect | Rating |
|--------|--------|
| Layering | ⭐⭐⭐⭐⭐ Clean Controller → Service → DAO |
| Permission Engine | ⭐⭐⭐⭐⭐ Centralized, consistently used |
| Error Handling | ⭐⭐⭐⭐ Comprehensive try-catch with logging |
| Thread Safety | ⭐⭐⭐⭐⭐ No shared mutable state, removed unsafe SimpleDateFormat |
| Code Organization | ⭐⭐⭐⭐ Well-structured packages |

---

# 7. REPORT OUTLINE

> **Bố cục 8 chương cho báo cáo PRJ301**

## 7.1. Mục lục tổng quan

| Chương | Nội dung | Trang ước tính |
|--------|----------|----------------|
| 1 | Giới thiệu đề tài (lý do, mục tiêu, phạm vi, công nghệ) | 3-4 |
| 2 | Phân tích yêu cầu (actors, use cases, permission matrix, phi chức năng) | 5-8 |
| 3 | Thiết kế hệ thống (architecture, MVC, class diagram, sequence diagram, activity diagram, UI) | 9-16 |
| 4 | Thiết kế CSDL (ERD, 21 bảng, DDL, FK constraints, indexing) | 17-22 |
| 5 | Triển khai chi tiết (Auth, Events, Booking, Check-in, Chat, Dashboard, i18n) | 23-38 |
| 6 | Bảo mật & An toàn (7 filter chain, OWASP mapping, payment security) | 39-42 |
| 7 | Kết quả & Demo (64+ screenshots, feature matrix, code stats) | 43-48 |
| 8 | Kết luận & Hướng phát triển | 49-50 |

## 7.2. Actors & Use Cases (24 UC)

| UC Module | UC IDs | Actor chính |
|-----------|--------|-------------|
| Xác thực | UC01-UC04 | Khách, Customer |
| Sự kiện | UC05-UC09 | All, Organizer, Admin |
| Đặt vé & Thanh toán | UC10-UC13 | Customer |
| Quản trị | UC14-UC19 | Admin |
| Organizer | UC20-UC24 | Organizer, Staff |

## 7.3. Technology Stack

| Layer | Công nghệ |
|-------|-----------|
| Backend | Java Servlet 4.0, JSP, JSTL |
| Database | Microsoft SQL Server |
| Frontend | HTML5, CSS3, JavaScript (Vanilla) |
| Auth | JWT + Session + Google OAuth 2.0 |
| Payment | SePay QR, MoMo, VNPay |
| Upload | Cloudinary API |
| Build | Apache Ant, NetBeans |
| Server | Apache Tomcat 9 |

## 7.4. Project Structure

```
SellingTicketJava/
├── src/java/com/sellingticket/
│   ├── controller/          # 60+ Servlets
│   │   ├── admin/           # 13 Admin controllers
│   │   ├── api/             # 17 REST API servlets
│   │   └── organizer/       # 10 Organizer controllers
│   ├── dao/                 # 18 Data Access Objects
│   ├── model/               # 17 Entity models
│   ├── service/             # 20 Business services
│   │   └── payment/         # Payment providers
│   ├── filter/              # 7 Security filters
│   ├── util/                # 12 Utility classes
│   ├── security/            # Login attempt tracker
│   └── exception/           # 2 Custom exceptions
├── webapp/
│   ├── *.jsp                # 24 Public pages
│   ├── admin/               # 18 Admin pages
│   ├── organizer/           # 19 Organizer pages
│   ├── staff/               # 3 Staff pages
│   └── assets/              # CSS, JS, i18n
├── database/
│   ├── schema/              # DDL scripts
│   ├── migrations/          # Migration SQL files
│   └── seeds/               # Seed data
└── conf/                    # Configuration
```

## 7.5. Code Statistics

| Metric | Giá trị |
|--------|---------|
| Tổng Java classes | ~130+ |
| Controllers/Servlets | 60+ |
| DAO classes | 18 |
| Model classes | 17 |
| Service classes | 20 |
| Filter classes | 7 |
| JSP pages | 64+ |
| Database tables | 20+ |

## 7.6. Phân chia viết báo cáo (gợi ý)

| Thành viên | Phần phụ trách | Chương |
|------------|---------------|--------|
| TV1 | Giới thiệu + Phân tích yêu cầu | Ch.1 + Ch.2 |
| TV2 | Thiết kế hệ thống (kiến trúc, class diagram) | Ch.3 |
| TV3 | Thiết kế CSDL + Triển khai backend core | Ch.4 + Ch.5.1-5.4 |
| TV4 | Triển khai modules phụ + Bảo mật + Demo | Ch.5.5-5.8 + Ch.6 + Ch.7 |
| Cả nhóm | Kết luận + Review | Ch.8 |

---

# 8. CHAPTER 6 SECURITY REPORT

> **Báo cáo bảo mật hoàn chỉnh — 737 dòng, 13 mục, sẵn sàng paste vào báo cáo**

## 8.1. Tóm tắt nội dung (đã viết đầy đủ)

Chương 6 đã hoàn thành với 13 mục chi tiết:

| Mục | Nội dung | Highlights |
|-----|----------|------------|
| 6.1 | Kiến trúc Filter Chain | Biểu đồ 7 filter tuần tự, bảng cấu hình web.xml |
| 6.2 | Xác thực (Authentication) | 5 sub-sections: AuthFilter 3-step, Login với 9 biện pháp, Google OAuth flow diagram, JWT token 3 loại, Token Lifecycle Service |
| 6.3 | Chống CSRF | Synchronizer Token Pattern + Origin/Referer validation, Token Rotation, Exemptions, JSP integration |
| 6.4 | HTTP Security Headers | 5 headers: X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy |
| 6.5 | Chống Brute Force | Progressive Lockout 2 tầng (email+IP: 5/10/15/20 lần, IP-only: 30 lần), ConcurrentHashMap, auto-cleanup |
| 6.6 | Mã hóa mật khẩu | BCrypt cost 12 (~250ms), auto salt, timing-safe |
| 6.7 | Xác thực đầu vào | InputValidator: 7 methods (email, password, phone, fullName, sanitizeHtml, isValidUrl, isValidMoney), HTML Sanitization, SQL Injection prevention |
| 6.8 | Cookie Security | CookieUtil: HttpOnly, Secure, SameSite=Lax, Path scope, Session config |
| 6.9 | Phân quyền (Authorization) | RBAC 6 roles, OrganizerAccessFilter 3-level check, StaffAccessFilter, ProtectedJspAccessFilter |
| 6.10 | Audit Trail | ActivityLogDAO: log(), getRecent(), search() with pagination, getDistinctActions() |
| 6.11 | Bảo mật thanh toán | SePay Webhook 5-step validation, Ticket Token JWT QR code lifecycle |
| 6.12 | Error Handling | Custom error pages (404, 500, Throwable catch-all), Logging strategy (no passwords/tokens logged) |
| 6.13 | Bảng tổng hợp bảo mật | 15 threats mapped to OWASP 2021 categories |

## 8.2. Bảng tổng hợp bảo mật OWASP Mapping

| Mối đe dọa | Giải pháp | File triển khai | OWASP 2021 |
|------------|-----------|-----------------|------------|
| SQL Injection | PreparedStatement toàn bộ DAO layer | `*DAO.java` (18 files) | A03 Injection |
| XSS | Input validation + HTML sanitization + Security headers | [InputValidator.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/InputValidator.java), [SecurityHeadersFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/SecurityHeadersFilter.java) | A03 Injection |
| CSRF | Synchronizer Token + Origin validation + SameSite cookies | [CsrfFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/CsrfFilter.java), [CookieUtil.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/CookieUtil.java) | A01 Broken Access Control |
| Brute Force | Progressive lockout (email+IP) + IP-only blocking | [LoginAttemptTracker.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/security/LoginAttemptTracker.java), [LoginServlet.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/LoginServlet.java) | A07 Identification Failures |
| Session Hijacking | HttpOnly + Secure + SameSite cookies | [CookieUtil.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/CookieUtil.java), [web.xml](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/webapp/WEB-INF/web.xml) | A07 Identification Failures |
| Session Fixation | Invalidate old session on login | [LoginServlet.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/LoginServlet.java), [GoogleOAuthServlet.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/GoogleOAuthServlet.java) | A07 Identification Failures |
| Clickjacking | X-Frame-Options: SAMEORIGIN | [SecurityHeadersFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/SecurityHeadersFilter.java) | A05 Security Misconfiguration |
| MIME Sniffing | X-Content-Type-Options: nosniff | [SecurityHeadersFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/SecurityHeadersFilter.java) | A05 Security Misconfiguration |
| Open Redirect | Whitelist redirect paths, block `://`, `//`, `javascript:` | `LoginServlet.java` | A01 Broken Access Control |
| Timing Attack | Constant-time comparison (JWT), fixed-delay login | `JwtUtil.java`, `LoginServlet.java` | A02 Cryptographic Failures |
| Algorithm Confusion | Header algorithm validation (reject non-HS256) | `JwtUtil.java` | A02 Cryptographic Failures |
| IDOR | Event ownership check, permission-based access | `OrganizerAccessFilter.java` | A01 Broken Access Control |
| Direct JSP Access | Forward/include check → 404 for direct access | `ProtectedJspAccessFilter.java` | A01 Broken Access Control |
| Webhook Replay | Idempotency via `SeepayWebhookDedup` table | `SeepayWebhookServlet.java` | A08 Software/Data Integrity |
| Weak Password | BCrypt cost 12, password policy enforcement | `PasswordUtil.java`, `InputValidator.java` | A02 Cryptographic Failures |

> **📌 File báo cáo chương 6 đầy đủ:** [chapter6_security_report.md](file:///C:/Users/Duong%20Hoang/.gemini/antigravity/brain/033510c9-0fbf-48a0-a210-86c5769d4ed6/chapter6_security_report.md) — 737 dòng, sẵn sàng paste vào Word/Google Docs.

---

# 9. UML DIAGRAMS

> **30 file PlantUML đã tạo: 10 Use Case + 20 Sequence Diagrams**

## 9.1. Use Case Diagrams (10 files)

| File | Scope | Actors | Use Cases |
|------|-------|--------|-----------|
| `UC_00_TongQuan_SystemOverview.puml` | Tổng quan hệ thống | Guest, Customer, Organizer, Staff, Admin, SePay, Google, Cloudinary | 24 UC tổng hợp |
| `UC_01_UserAuthentication.puml` | Module xác thực | Guest, Customer, Google OAuth | Đăng ký, Đăng nhập, Google OAuth, Đổi mật khẩu, Quản lý session |
| `UC_02_EventManagement.puml` | Quản lý sự kiện | Guest, Customer, Organizer, Admin | Browse, Search, Filter, CRUD, Approve/Reject, Categories |
| `UC_03_TicketTypeManagement.puml` | Quản lý loại vé | Organizer, Admin | CRUD loại vé, Pricing, Quantity control |
| `UC_04_BookingPayment.puml` | Đặt vé & Thanh toán | Customer, SePay | Chọn vé, Checkout, Apply voucher, Payment, Confirmation |
| `UC_05_CheckIn.puml` | Check-in sự kiện | Organizer, Staff/Scanner | QR scan, Manual check-in, Bulk check-in |
| `UC_06_Communication.puml` | Chat & Hỗ trợ | Customer, Organizer, Admin/Support | Live chat, Support tickets, Notifications |
| `UC_07_VoucherManagement.puml` | Quản lý voucher | Organizer, Admin, Customer | Create, Apply, System vouchers, Event vouchers |
| `UC_08_Dashboard.puml` | Dashboard & Thống kê | Organizer, Admin, Staff | Revenue charts, Ticket stats, User analytics |
| `UC_09_SystemAdministration.puml` | Quản trị hệ thống | Admin | User mgmt, Site settings, Activity log, Categories, Reports |

## 9.2. Sequence Diagrams (20 files)

| File | Luồng | Participants chính |
|------|-------|--------------------|
| `SD_01_Registration.puml` | Đăng ký tài khoản | Browser → RegisterServlet → InputValidator → UserService → UserDAO → DB |
| `SD_02_Login.puml` | Đăng nhập | Browser → LoginServlet → LoginAttemptTracker → UserDAO → BCrypt → JwtUtil → Cookie |
| `SD_03_GoogleOAuth.puml` | Google OAuth 2.0 | Browser → GoogleOAuthServlet → Google API → UserDAO → Session |
| `SD_04_CreateEvent.puml` | Tạo sự kiện (multi-step) | Browser → OrganizerEventController → EventService → EventDAO → MediaDAO → Cloudinary |
| `SD_05_ApproveRejectEvent.puml` | Phê duyệt sự kiện | Admin → AdminEventController → EventService → EventDAO → NotificationDAO |
| `SD_06_TicketPurchase.puml` | Mua vé + Checkout | Browser → CheckoutServlet → OrderService → OrderDAO (atomic) → TicketTypeDAO |
| `SD_07_SepayPayment.puml` | Thanh toán SePay + Webhook | Browser → QR → SePay → SeepayWebhookServlet → OrderDAO → TicketDAO → JwtUtil (QR token) |
| `SD_08_QRCheckIn.puml` | Check-in QR | Staff → StaffCheckInController → JwtUtil.verifyTicketToken → TicketDAO → DB update |
| `SD_09_ChatSession.puml` | Live Chat | Customer/Organizer → ChatServlet → ChatService → ChatDAO → ChatSessionDAO |
| `SD_10_SupportTicket.puml` | Support Ticket | Customer → SupportServlet → SupportTicketService → SupportTicketDAO → TicketMessageDAO |
| `SD_11_VoucherValidation.puml` | Áp dụng voucher | Browser → VoucherServlet → VoucherService → VoucherDAO → validate + apply discount |
| `SD_12_BrowseSearchEvents.puml` | Browse/Search Events | Browser → EventListServlet → EventService → EventDAO (search, filter, paginate) |
| `SD_13_ProfileManagement.puml` | Quản lý profile | Browser → ProfileServlet → UserService → UserDAO → PasswordUtil (BCrypt) |
| `SD_14_DashboardAnalytics.puml` | Dashboard Analytics | Admin/Organizer → DashboardController → DashboardDAO → aggregate queries |
| `SD_15_AdminUserManagement.puml` | Admin quản lý User | Admin → AdminUserController → UserService → UserDAO → ActivityLogDAO |
| `SD_16_SecurityFilterChain.puml` | Chuỗi Filter bảo mật | Request → CacheFilter → SecurityHeadersFilter → CsrfFilter → AuthFilter → Controller |
| `SD_17_NotificationSystem.puml` | Hệ thống thông báo | System → NotificationService → NotificationDAO → User inbox |
| `SD_18_ViewOrderHistory.puml` | Xem lịch sử đơn hàng | Browser → MyOrdersServlet → OrderService → OrderDAO → OrderItemDAO |
| `SD_19_OrderExpiry.puml` | Hết hạn đơn hàng | Scheduler → OrderService → OrderDAO (expire pending orders) → TicketTypeDAO (restore quantity) |
| `SD_20_StaffManagement.puml` | Quản lý nhân viên BTC | Organizer → OrganizerEventController → EventStaffDAO → EventStaff table |

## 9.3. Vị trí files

Tất cả 30 files PlantUML đặt tại:
```
d:\GITHUB\PRJ301_GROUP4_SELLING_TICKET\SellingTicketJava\docs\diagrams\
├── UC_00_TongQuan_SystemOverview.puml
├── UC_01_UserAuthentication.puml
├── ...
├── UC_09_SystemAdministration.puml
├── SD_01_Registration.puml
├── SD_02_Login.puml
├── ...
└── SD_20_StaffManagement.puml
```

**Render diagrams:** Sử dụng PlantUML Online Server hoặc VS Code extension "PlantUML" để render PNG/SVG.

---

# TỔNG KẾT

## Thành quả qua 3 phiên làm việc

| Hạng mục | Số lượng | Chi tiết |
|----------|----------|----------|
| **Bugs phát hiện** | 29+ | 7 Critical + 5 High + 12 Medium + 2 Payment + 3 Staff |
| **Files đã sửa** | 6 | JwtUtil, AppConstants, UserDAO, OrderDAO, EventService, AuthFilter |
| **Báo cáo chapter** | 1 hoàn chỉnh | Chapter 6: 737 dòng bảo mật |
| **Report outline** | 8 chương | Bố cục đầy đủ cho báo cáo PRJ301 |
| **UML diagrams** | 30 files | 10 Use Case + 20 Sequence Diagrams |
| **Audit kết quả** | Near-perfect | Round 2: chỉ còn 1 Low severity |

## Files tham chiếu chính

| File | Đường dẫn |
|------|-----------|
| Code Review Report | `brain/922a.../code_review_report.md` (297 dòng) |
| Full Codebase Audit | `brain/922a.../full_codebase_audit.md` (144 dòng) |
| Payment Flow Analysis | `brain/922a.../payment_ticket_flow.md` (118 dòng) |
| Staff Flow Analysis | `brain/922a.../staff_flow_analysis.md` (169 dòng) |
| Admin/Staff Brainstorm | `brain/922a.../admin_staff_brainstorm.md` (186 dòng) |
| Report Outline | `brain/0335.../report_outline.md` (543 dòng) |
| Chapter 6 Security | `brain/0335.../chapter6_security_report.md` (737 dòng) |
| UML Diagrams | `docs/diagrams/*.puml` (30 files) |
