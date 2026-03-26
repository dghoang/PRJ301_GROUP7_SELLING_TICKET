# 05. Authentication Authorization

## Login đang hoạt động thế nào
### Nơi nhập tài khoản
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/webapp/login.jsp`

### Form submit đến đâu
- POST `/login`

### Controller nhận request
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/LoginServlet.java`

### Service/DAO xử lý
- `LoginServlet -> UserService.authenticate() -> UserDAO.login()`

### Query kiểm tra tài khoản
```sql
SELECT * FROM Users WHERE email = ? AND is_active = 1 AND (is_deleted = 0 OR is_deleted IS NULL)
```

### Mật khẩu
- Lưu bằng BCrypt.
- So khớp bằng `PasswordUtil.checkPassword()`.
- Không thấy plaintext lưu trực tiếp trong luồng đăng nhập.

## Sau khi login thành công
- Session được reset để chống session fixation.
- Lưu `user` và `account` vào session.
- Set `csrf_token` trong session nếu chưa có.
- `session.setMaxInactiveInterval(3600)` tức 60 phút.
- JWT access/refresh được ghi vào cookie HttpOnly qua `AuthTokenService.issueTokens()`.

## Phân quyền
### Cách làm chính
- Dựa vào `AuthFilter`.
- Role đọc từ `user.getRole()`.
- Có thêm `OrganizerAccessFilter` và `StaffAccessFilter`.

### URL theo role
- Public: `/home`, `/events`, `/event-detail`, `/login`, `/register`, `/auth/google`.
- Admin: `/admin/*`
- Organizer: `/organizer/*`
- User checkout/ticket/profile: `/checkout`, `/my-tickets`, `/profile`, `/change-password`, `/support/*`
- Staff portal: `/staff/*` nhưng còn phụ thuộc `EventStaff`

### Chặn truy cập trái phép
- `AuthFilter` redirect nếu chưa login.
- `AuthFilter` chặn role sai với `/admin` và `/organizer`.
- `OrganizerAccessFilter` chặn event chưa được duyệt hoặc không có quyền theo event.
- `StaffAccessFilter` chặn nếu không có assignment trong `EventStaff`.

## Logout
- `/logout`
- `LogoutServlet` gọi `AuthTokenService.revokeTokens()`
- Invalidate session server-side

## Điểm yếu/ghi chú
- Có cookie JWT song song với session nên nếu session chết mà cookie còn hợp lệ, `AuthFilter` vẫn có thể restore session.
- `remember me` chỉ làm cookie refresh tồn tại lâu hơn, còn access token vẫn có hạn riêng.
- Chưa thấy luồng quên mật khẩu/OTP/email verify hoàn chỉnh trong phần đã đọc.

## Tóm tắt dễ nhớ
Đăng nhập = session + JWT cookie. Phân quyền = filter + role + quyền theo event.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/06_USER_BUSINESS_FLOW.md`

## Điểm người mới hay nhầm
- Tưởng vào được `/admin/*` nếu có session. Thực tế phải đúng role `admin` hoặc `support_agent` tùy trang.
