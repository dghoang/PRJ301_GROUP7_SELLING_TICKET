

# 🎫 Kế hoạch xây dựng Ticketbox - Nền tảng bán vé sự kiện

## 🎨 Phong cách thiết kế
- **Gradient chính**: Hồng pastel (#FFE5EC) → Tím lavender (#E8E0FF)
- **Glass morphism iOS 26**: Các card và modal trong suốt, blur backdrop
- **Font**: Modern, tròn và thân thiện (Inter hoặc Plus Jakarta Sans)
- **Nút**: Bo tròn, gradient, hiệu ứng hover mượt mà
- **Responsive**: Hoàn hảo trên mobile, tablet, desktop

---

## 📱 PHÍA NGƯỜI MUA (8 trang)

### 1. Trang chủ (Landing Page)
- Hero section với gradient nổi bật
- Thanh tìm kiếm sự kiện
- Danh sách sự kiện nổi bật (carousel)
- Danh mục sự kiện (Âm nhạc, Workshop, Thể thao...)
- Sự kiện sắp diễn ra

### 2. Trang đăng ký / Đăng nhập
- Form đăng ký: Họ tên, email, SĐT, ngày sinh, giới tính, mật khẩu
- Form đăng nhập
- Xác thực email/OTP
- Thiết kế 2 cột: ảnh minh họa + form

### 3. Trang danh sách sự kiện
- Bộ lọc: Thể loại, ngày, địa điểm, giá
- Grid/List view toggle
- Sắp xếp: Mới nhất, phổ biến, giá
- Pagination

### 4. Trang chi tiết sự kiện
- Banner sự kiện (1280x720)
- Thông tin BTC (logo, mô tả)
- Lịch diễn (nhiều suất)
- Danh sách loại vé với giá
- Nút "Mua vé ngay" / "Đăng ký ngay"
- **Popup nhập mã** cho sự kiện riêng tư

### 5. Trang chọn vé & ghế ngồi
- Sơ đồ chỗ ngồi (nếu có)
- Chọn loại vé, số lượng
- Hiển thị giá tạm tính
- Countdown giữ vé

### 6. Trang thanh toán (Checkout)
- Thông tin đơn hàng
- Nhập mã khuyến mãi
- Chọn phương thức thanh toán
- Chọn vé giấy/điện tử (phí ship nếu vé giấy)
- Xác nhận và thanh toán

### 7. Trang xác nhận đơn hàng
- Thông tin vé đã mua
- QR code vé điện tử
- Gửi email xác nhận
- Theo dõi vận chuyển (nếu vé giấy)

### 8. Trang tài khoản cá nhân
- Thông tin cá nhân (chỉnh sửa)
- Lịch sử đơn hàng
- Vé của tôi
- Đổi mật khẩu

---

## 🏢 PHÍA BAN TỔ CHỨC (10 trang)

### 1. Dashboard BTC
- Tổng quan doanh thu
- Biểu đồ bán vé theo thời gian
- Danh sách sự kiện đang quản lý
- Thông báo quan trọng

### 2. Trang tạo sự kiện mới ⭐
- **Step 1**: Thông tin cơ bản (tên, mô tả, thể loại)
- **Step 2**: Upload ảnh (logo 720x958, banner 1280x720)
- **Step 3**: Địa điểm (online/offline, địa chỉ chi tiết)
- **Step 4**: Thông tin BTC (tên, logo, mô tả)
- **Step 5**: Lịch diễn (nhiều suất)
- **Step 6**: Cấu hình vé (loại vé, giá, số lượng, thời gian bán)
- **Step 7**: Tùy chỉnh (URL, quyền riêng tư, mã truy cập)
- **Step 8**: Tài khoản ngân hàng + hóa đơn
- **Gửi duyệt**

### 3. Trang quản lý sự kiện
- Danh sách sự kiện (draft, pending, approved, active)
- Chỉnh sửa sự kiện
- Sao chép sự kiện
- Tạm dừng/hủy sự kiện

### 4. Trang quản lý vé
- Danh sách loại vé theo sự kiện
- Chỉnh sửa giá, số lượng
- Theo dõi tình trạng bán

### 5. Trang mã giảm giá
- Tạo voucher mới
- Cấu hình: % hay VNĐ, giới hạn, thời gian
- Bật/tắt trạng thái
- Theo dõi lượt sử dụng

### 6. Trang quản lý đơn hàng (RSVP)
- Danh sách khách hàng đã mua vé
- Export Excel
- Tìm kiếm theo tên/email/mã đơn

### 7. Trang thống kê doanh số
- Biểu đồ doanh thu
- Top loại vé bán chạy
- Thống kê theo suất diễn
- So sánh các sự kiện

### 8. Trang điều hành viên
- Thêm thành viên bằng email
- Phân quyền (quản lý, check-in, xem báo cáo)
- Danh sách thành viên hiện tại

### 9. Trang soát vé (Check-in)
- Giao diện quét QR
- Tìm kiếm vé thủ công
- Xác nhận check-in
- Thống kê real-time

### 10. Trang cài đặt tài khoản BTC
- Thông tin tổ chức
- Tài khoản ngân hàng
- Thông tin xuất hóa đơn

---

## 👨‍💼 PHÍA QUẢN TRỊ VIÊN (5 trang)

### 1. Dashboard Admin
- Tổng quan hệ thống
- Doanh thu toàn nền tảng
- Sự kiện chờ duyệt
- Cảnh báo/thông báo

### 2. Quản lý sự kiện
- Duyệt/từ chối sự kiện
- Yêu cầu chỉnh sửa
- Ghi chú lý do

### 3. Quản lý người dùng
- Danh sách khách hàng
- Danh sách BTC
- Khóa/mở khóa tài khoản
- Xem lịch sử hoạt động

### 4. Quản lý đơn vị vận chuyển
- Danh sách đơn vị
- Thêm/sửa/xóa
- Cấu hình phí ship

### 5. Báo cáo tổng hợp
- Doanh thu theo thời gian
- Top BTC
- Top sự kiện
- Phân tích người dùng

---

## 🔧 Tính năng bổ sung
- **Dark mode** toggle
- **Đa ngôn ngữ** (VN/EN)
- **Thông báo** toast đẹp
- **Loading** skeleton animations
- **Form validation** rõ ràng
- **Responsive** hoàn hảo

---

## 📁 Cấu trúc file
Tôi sẽ tạo các component và pages riêng biệt, dễ dàng tích hợp với Java backend của bạn thông qua API calls.

