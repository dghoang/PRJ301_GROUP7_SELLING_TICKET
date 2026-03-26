# 08. Staff Business Flow

## Staff ở dự án này là gì
Source không có bảng `Staff` riêng. Staff portal hoạt động theo:
- user có role phù hợp
- được gán vào sự kiện trong `EventStaff`
- có quyền cụ thể: `manager`, `staff`, `scanner`

## File chính
- `StaffAccessFilter`
- `OrganizerAccessFilter`
- `StaffCheckInController`
- `EventStaffDAO`
- `EventService`

## Luồng check-in
1. Staff mở `/staff/check-in`
2. Filter kiểm tra user đã login và có assignment
3. Nếu chưa chọn event, hiện danh sách event được gán
4. Nếu chọn event, `EventService.hasCheckInPermission()` kiểm tra quyền
5. POST mã vé
6. `TicketDAO.getTicketByCode()`
7. `TicketDAO.checkInTicket()` đánh dấu vé đã check-in và nếu đủ điều kiện thì cập nhật order sang `checked_in`

## Ai được vào
- Admin: luôn được vào
- User có record trong `EventStaff`: được vào
- Người không có assignment: bị chặn

## Rủi ro
- Nếu staff sửa URL sang event khác, filter vẫn phải check quyền theo event. Source có làm việc này ở `EventService`.
- Nếu quyền event không đồng bộ với dữ liệu DB, có thể gây hiểu nhầm trong sidebar/UI.

## Tóm tắt dễ nhớ
Staff portal là check-in theo event, không phải staff quyền hệ thống toàn cục.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/09_CRUD_ANALYSIS.md`

## Điểm người mới hay nhầm
- Tưởng vào `/staff/*` là đủ. Thực tế còn phải có assignment trong `EventStaff`.
