# 07. Admin Business Flow

## Chức năng chính
- Quản lý user
- Quản lý event
- Duyệt/reject event
- Quản lý đơn hàng
- Duyệt hoàn tiền
- Quản lý voucher hệ thống
- Xem báo cáo/dashboard
- Xem notifications/support/chat

## File chính
- `AdminUserController`
- `AdminEventController`
- `AdminOrderController`
- `AdminDashboardController`
- `AdminReportsController`
- `AdminSettingsController`
- `AdminSupportController`
- `AdminNotificationController`

## Flow quản lý user
- List/search/view/update role/deactivate/activate
- `AdminUserController -> UserService -> UserDAO`
- Có audit log bằng `ActivityLogService`
- Có kiểm tra `adminKey` khi set role admin

## Flow quản lý event
- List pending/view/approve/reject/delete/feature/pin/unpin/update
- `AdminEventController -> EventService`
- Có ghi activity log cho thao tác quan trọng

## Flow quản lý order
- `AdminOrderController`
- List/search/cancel/mark-paid/approve-refund
- Khi mark-paid: nếu chưa có vé thì phát hành vé qua `TicketDAO`

## Rủi ro nghiệp vụ
- Nếu role hoặc ownership check thiếu ở endpoint phụ, admin có thể thao tác ngoài ý muốn.
- Một số update status nếu gọi tay có thể gây sai trạng thái nếu không kiểm tra tiền điều kiện kỹ.

## Tóm tắt dễ nhớ
Admin là người “duyệt và điều phối”: user, event, order, refund, settings.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/08_STAFF_BUSINESS_FLOW.md`

## Điểm người mới hay nhầm
- Coi admin và support_agent giống nhau. Thực tế quyền trong `AuthFilter` khác nhau.
