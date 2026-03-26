# 04. Architecture Flow

## Kiến trúc thực tế
Luồng chuẩn là:
`JSP/View -> Servlet/Controller -> Service -> DAO -> SQL Server -> trả ngược về View`

## Request flow tổng quát
1. Browser mở JSP hoặc gửi form.
2. `web.xml` và annotation route request vào filter/servlet.
3. `AuthFilter` kiểm tra login + role.
4. `CsrfFilter` kiểm tra token với POST.
5. Controller gọi service.
6. Service gọi DAO.
7. DAO dùng JDBC truy vấn SQL Server.
8. Kết quả trả về JSP hoặc JSON.

## Các lớp cross-cutting
- `AuthFilter`: xác thực và phân quyền.
- `CsrfFilter`: chống CSRF.
- `SecurityHeadersFilter`: header an toàn.
- `CacheFilter`: chống cache file tĩnh.
- `OrganizerAccessFilter`, `StaffAccessFilter`: quyền theo nghiệp vụ.

## Điểm đáng chú ý
- Hệ thống không dùng Spring container.
- Nhiều controller khởi tạo service bằng `new`.
- Session và JWT cookie tồn tại song song.
- `ServletUtil.getSessionUser()` là điểm gom user từ session/attribute.

## Tóm tắt dễ nhớ
Đọc flow này là hiểu “request đi qua đâu”.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/05_AUTHENTICATION_AUTHORIZATION.md`

## Điểm người mới hay nhầm
- Nghĩ rằng filter chỉ để login. Thực tế filter còn cắt quyền admin/organizer/api/staff.
