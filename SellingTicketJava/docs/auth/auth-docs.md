# 📋 Authentication & Authorization Docs

> **SellingTicket - Java Servlet (Jakarta EE 6.0)**
> Cập nhật: 16/03/2026

---

## 1. Tổng Quan Kiến Trúc

```
┌─────────────────────────────────────────────────────────────────┐
│                        BROWSER                                  │
│  ┌────────────────────┐  ┌────────────────────┐               │
│  │ st_refresh         │  │ JSESSIONID         │               │
│  │ (opaque token ID,  │  │ (HttpOnly,Secure)  │               │
│  │  HttpOnly)         │  │                    │               │
│  └────────────────────┘  └────────────────────┘               │
└──────────────────────────┬──────────────────────────────────────┘
                           │ HTTP Request
┌──────────────────────────▼──────────────────────────────────────┐
│                     TOMCAT SERVER                               │
│                                                                 │
│  ┌───────────────────────────────────┐                         │
│  │ 1. SecurityHeadersFilter (/*.*)   │  X-Frame, HSTS, CSP    │
│  │ 2. CsrfFilter (POST requests)    │  CSRF Token Validation  │
│  │ 3. AuthFilter (protected URLs)   │  Session + Token Check  │
│  └───────────────┬───────────────────┘                         │
│                  │                                              │
│  ┌───────────────▼───────────────────┐                         │
│  │         SERVLETS                   │                         │
│  │  LoginServlet    → /login          │                         │
│  │  RegisterServlet → /register       │                         │
│  │  LogoutServlet   → /logout         │                         │
│  │  GoogleOAuth     → /auth/google    │                         │
│  │  ChangePassword  → /change-password│                         │
│  └───────────────┬───────────────────┘                         │
│                  │                                              │
│  ┌───────────────▼───────────────────┐                         │
│  │       SERVICE LAYER               │                         │
│  │  UserService      AuthTokenService│                         │
│  └───────────────┬───────────────────┘                         │
│                  │                                              │
│  ┌───────────────▼───────────────────┐                         │
│  │       DAO LAYER                   │                         │
│  │  UserDAO      RefreshTokenDAO     │                         │
│  └───────────────┬───────────────────┘                         │
│                  │                                              │
│  ┌───────────────▼───────────────────┐                         │
│  │       UTILITIES                   │                         │
│  │  JwtUtil  CookieUtil  PasswordUtil│                         │
│  └───────────────────────────────────┘                         │
└─────────────────────────────────────────────────────────────────┘
                           │
              ┌────────────▼────────────┐
              │    SQL SERVER DATABASE   │
              │  Users | UserSessions    │
              └─────────────────────────┘
```

---

## 2. Login Flow (Chi Tiết Từng Bước)

### 2.1. LoginServlet — `POST /login`

```
Bước │ Mô tả                              │ Fail → Response
─────┼────────────────────────────────────┼──────────────────────────
  1  │ Set no-cache headers               │ —
  2  │ Set UTF-8 encoding                 │ —
  3  │ Read email, password, clientIp     │ —
  4  │ Null/empty check                   │ "Vui lòng nhập email và mật khẩu"
  5  │ Email length ≤ 255 chars           │ "Email không hợp lệ"
  6  │ Password length ≤ 128 chars        │ "Mật khẩu quá dài"
  7  │ Trim + lowercase email             │ —
  8  │ Email regex validation             │ "Email không hợp lệ"
  9  │ IP-only rate limit check           │ "Quá nhiều lần đăng nhập từ IP này"
 10  │ Email+IP rate limit check          │ "Tạm khóa do sai quá nhiều lần"
 11  │ Start timer (timing attack)        │ —
 12  │ UserService.authenticate()         │ —
 13  │ Enforce 200ms minimum delay        │ —
 14  │ If null → record failure           │ "Email hoặc mật khẩu không đúng"
 15  │ If !active → reject               │ "Tài khoản bị khóa"
 16  │ Reset rate limiter                 │ —
 17  │ Read remember checkbox             │ —
 18  │ Update last_login_at, last_login_ip│ —
 19  │ Session fixation protection        │ —
 20  │ Create new session                 │ —
 21  │ Issue refresh cookie + DB token ID │ —
 22  │ Set toast message                  │ —
 23  │ Sanitize returnUrl                 │ —
 24  │ Redirect to returnUrl or /home     │ —
```

### 2.2. Luồng Xác Thực (BCrypt)

```
LoginServlet
    → UserService.authenticate(email, password)
        → UserDAO.login(email, password)
            → SQL: SELECT * FROM Users WHERE email = ? AND is_active = 1
            → PasswordUtil.checkPassword(password, hash)
                → BCrypt.checkpw(password, hash)  // Cost factor 12
            → return User or null
```

### 2.3. Luồng Refresh Cookie Mới (Sau Login Thành Công)

```
AuthTokenService.issueTokens(response, user, request, rememberMe)
│
├─ Clear legacy auth cookies first
│   → delete st_access at context path and root path
│   → delete st_refresh at context path and root path
│
├─ JwtUtil.generateRefreshTokenId()
│   → tokenId = UUID
│
├─ RefreshTokenDAO.saveToken(userId, tokenId, userAgent, ip, expiresAt)
│   → INSERT INTO UserSessions (...)
│
└─ CookieUtil.addSecureCookie("st_refresh", tokenId, maxAge, secure)
    → Set-Cookie: st_refresh=<opaque-id>; HttpOnly; SameSite=Lax; Path=/SellingTicketJava
```

Ghi chú:
- Web flow mới không còn cần gửi `st_access` JWT trên mọi request.
- Bearer token vẫn được hỗ trợ cho API clients bên ngoài.
- Refresh JWT cũ vẫn được backend hiểu trong giai đoạn chuyển tiếp.

---

## 3. Session Restoration (AuthFilter)

Khi session hết hạn (60 phút idle) nhưng user vẫn còn cookie `st_refresh`:

```
AuthFilter.doFilter()
│
├─ getSessionUser() → null (session đã expire)
│
├─ Nếu request là /api/* và có Bearer token hợp lệ:
│   └─ authenticate from Authorization header
│
├─ authTokenService.validateAccessToken(request)
│   └─ Chỉ dùng cho legacy st_access cookie (compatibility mode)
│
├─ authTokenService.refreshAccessToken(request, response)
│   ├─ Đọc cookie "st_refresh"
│   ├─ Nếu cookie là opaque token ID:
│   │   └─ RefreshTokenDAO.getUserIdByActiveToken(tokenId)
│   ├─ Nếu cookie là JWT refresh cũ:
│   │   ├─ Verify JWT
│   │   └─ Lấy jti rồi check DB
│   ├─ UserDAO.getUserById(userId) → User
│   ├─ RefreshTokenDAO.updateLastActivity(tokenId)
│   └─ Delete legacy st_access cookie copies if present
│
└─ Nếu có User → Restore session:
    session.setAttribute("user", user)
    session.setAttribute("account", user)
```

He thong nay giu request header gon hon vi web flow binh thuong chi can `JSESSIONID` va `st_refresh`.

---

## 4. Google OAuth Flow

```
Browser                    Server                         Google
  │                          │                               │
  ├─ GET /auth/google ──────►│                               │
  │                          ├─ Generate state token ───────►│
  │  ◄── Redirect ───────────┤  (CSRF protection)           │
  │                          │                               │
  ├─ Login on Google ────────────────────────────────────────►│
  │                          │                               │
  │  ◄── Callback: code + state ─────────────────────────────┤
  ├─ GET /auth/google?code=X&state=Y ─►│                    │
  │                          ├─ Verify state token           │
  │                          ├─ Exchange code for token ────►│
  │                          │  ◄── Access token ────────────┤
  │                          ├─ Fetch user info ────────────►│
  │                          │  ◄── Email, Name, Avatar ─────┤
  │                          ├─ Find/Create user in DB       │
  │                          ├─ Session fixation protection   │
    │                          ├─ Issue refresh cookie + session (always remember)
  │  ◄── Redirect /home ─────┤                               │
```

---

## 5. Logout Flow

```
LogoutServlet.doGet()
│
├─ authTokenService.revokeTokens(request, response)
│   ├─ Read st_refresh cookie
│   ├─ Resolve tokenId directly or from legacy JWT refresh cookie
│   ├─ RefreshTokenDAO.revokeToken(tokenId) → UPDATE is_active = 0
│   ├─ Delete legacy st_access cookie (Max-Age=0)
│   └─ Delete st_refresh cookie (Max-Age=0)
│
├─ session.invalidate()
│
└─ Redirect → /home
```

---

## 6. Password Change Flow

```
ChangePasswordServlet.doPost()
│
├─ Validate old password, new password
├─ Check new != old
├─ UserService.changePassword()
├─ authTokenService.revokeAllUserTokens(userId, ...)
│   ├─ RefreshTokenDAO.revokeAllTokens(userId)
│   │   → UPDATE UserSessions SET is_active = 0 WHERE user_id = ?
│   └─ Delete cookies
│
└─ Redirect → /profile (user must re-login on other devices)
```

---

## 7. Rate Limiting (LoginAttemptTracker)

### Per Email+IP (targeted brute force)
| Failures | Lockout Duration |
|----------|-----------------|
| 5+       | 1 phút          |
| 10+      | 5 phút          |
| 15+      | 15 phút         |
| 20+      | 60 phút         |

### Per IP Only (credential stuffing)
| Failures | Lockout Duration |
|----------|-----------------|
| 30+      | 15 phút         |

- IP-level tracking **không reset** khi login thành công
- Entries tự xóa sau 2 giờ không hoạt động
- Background thread cleanup mỗi 10 phút

---

## 8. Password Requirements

| Rule | Giá trị |
|------|---------|
| Minimum length | 8 ký tự |
| Maximum length | 128 ký tự |
| Uppercase | ≥ 1 chữ hoa (A-Z) |
| Digit | ≥ 1 chữ số (0-9) |
| Special char | ≥ 1 ký tự đặc biệt (!@#$%...) |
| Hashing | BCrypt cost factor 12 |

---

## 9. Security Headers

| Header | Value | Purpose |
|--------|-------|---------|
| `X-Content-Type-Options` | `nosniff` | Chống MIME sniffing |
| `X-Frame-Options` | `SAMEORIGIN` | Chống clickjacking |
| `X-XSS-Protection` | `1; mode=block` | XSS filter (legacy) |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Giới hạn Referer |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=()` | Tắt API nguy hiểm |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Force HTTPS 1 năm |
| `Cache-Control` | `no-store` (login page only) | Không cache credentials |

---

## 10. Cookie Security

| Cookie | Flags | MaxAge |
|--------|-------|--------|
| `st_refresh` | HttpOnly, SameSite=Lax, Secure*, Path=/SellingTicketJava | 30d (remember) / session |
| `st_access` (legacy) | compatibility only, auto-deleted when seen | cleanup only |
| `JSESSIONID` | HttpOnly, Secure | 60 min idle |

*\*Secure flag chỉ set khi HTTPS*

---

## 11. File Map

```
src/java/com/sellingticket/
├── controller/
│   ├── LoginServlet.java          ← Login logic + session creation
│   ├── RegisterServlet.java       ← Registration + validation
│   ├── LogoutServlet.java         ← Token revocation + session invalidation
│   ├── GoogleOAuthServlet.java    ← Google OAuth 2.0 integration
│   └── ChangePasswordServlet.java ← Password change + token revocation
├── filter/
│   ├── AuthFilter.java            ← Session/refresh/bearer auth + returnUrl
│   ├── CsrfFilter.java           ← CSRF token validation
│   └── SecurityHeadersFilter.java ← Security response headers
├── security/
│   └── LoginAttemptTracker.java   ← Rate limiting (email+IP, IP-only)
├── service/
│   ├── UserService.java           ← Auth business logic
│   └── AuthTokenService.java      ← Refresh cookie lifecycle + legacy compat
├── dao/
│   ├── UserDAO.java               ← User CRUD + password verification
│   └── RefreshTokenDAO.java       ← Refresh token persistence
├── util/
│   ├── JwtUtil.java               ← Bearer JWT + legacy refresh JWT compat
│   ├── CookieUtil.java            ← Secure cookie creation
│   ├── PasswordUtil.java          ← BCrypt hashing
│   └── AppConstants.java          ← JWT secret (env var)
└── model/
    └── User.java                  ← User entity

src/webapp/
├── WEB-INF/
│   ├── web.xml                    ← Filter config, session config
│   └── google-oauth.properties    ← OAuth credentials
└── login.jsp                      ← Login form + CSRF + returnUrl
```

---

## 12. Environment Variables

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `TICKETBOX_JWT_SECRET` | Production: Yes | Dev fallback | HMAC-SHA256 signing key |

> ⚠️ Thay đổi JWT_SECRET sẽ invalidate **tất cả** tokens hiện tại → toàn bộ user phải đăng nhập lại.

---

## 13. Tomcat Dev Header Note

Neu local Tomcat van gap loi request header qua lon trong giai doan browser con giu cookie cu, merge sample sau vao `TOMCAT_HOME/conf/server.xml`:

- `SellingTicketJava/conf/tomcat-connector.dev-example.xml`

Muc tieu cua sample nay la tang `maxHttpHeaderSize` cho moi truong dev, khong phai cau hinh production mac dinh.
