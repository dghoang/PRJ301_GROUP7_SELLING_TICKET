<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<!-- Hero Section -->
<section class="terms-hero py-5" style="background: linear-gradient(135deg, #fdfbfb 0%, #ebedee 100%);">
    <div class="container py-5 text-center">
        <div class="dash-icon-box mx-auto mb-4 animate-fadeInDown" style="width: 80px; height: 80px; background: linear-gradient(135deg, #a855f7, #6366f1); border-radius: 20px;">
            <i class="fas fa-file-contract fa-2x text-white"></i>
        </div>
        <h1 class="display-4 fw-bold mb-3 animate-fadeInUp">Điều khoản & Chính sách</h1>
        <p class="lead text-muted mb-0 animate-fadeInUp" style="animation-delay: 0.1s;">Vui lòng đọc kỹ trước khi sử dụng dịch vụ của WIBU DASH</p>
    </div>
</section>

<!-- Content Section -->
<section class="py-5 bg-white">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="card glass-strong border-0 shadow-sm rounded-4 mb-5 animate-on-scroll">
                    <div class="card-body p-4 p-md-5">
                        
                        <!-- Section 1: Điều khoản chung -->
                        <div class="mb-5">
                            <h3 class="fw-bold mb-4 text-primary d-flex align-items-center">
                                <i class="fas fa-gavel me-3 fs-4"></i>1. Điều khoản chung
                            </h3>
                            <div class="ps-md-5 text-muted line-height-lg">
                                <p>Bằng việc truy cập và sử dụng nền tảng WIBU DASH để mua vé hoặc tạo sự kiện, bạn đồng ý tuân thủ các Điều khoản Dịch vụ này.</p>
                                <ul class="mb-0">
                                    <li class="mb-2"><strong>Dịch vụ:</strong> WIBU DASH cung cấp nền tảng kết nối giữa Ban tổ chức sự kiện (Organizer) và người mua vé. Chúng tôi không trực tiếp tổ chức sự kiện trừ khi được nêu rõ.</li>
                                    <li class="mb-2"><strong>Tài khoản:</strong> Bạn chịu trách nhiệm bảo mật thông tin tài khoản và mật khẩu của mình. Mọi giao dịch phát sinh từ tài khoản của bạn sẽ được coi là hợp lệ.</li>
                                    <li><strong>Độ tuổi:</strong> Người dùng phải đủ 18 tuổi hoặc có sự giám hộ của phụ huynh để thực hiện giao dịch mua bán trên hệ thống.</li>
                                </ul>
                            </div>
                        </div>

                        <hr class="text-light mb-5">

                        <!-- Section 2: Chính sách mua vé & Thanh toán -->
                        <div class="mb-5">
                            <h3 class="fw-bold mb-4 text-primary d-flex align-items-center">
                                <i class="fas fa-ticket-alt me-3 fs-4"></i>2. Chính sách mua vé & Thanh toán
                            </h3>
                            <div class="ps-md-5 text-muted line-height-lg">
                                <p>WIBU DASH cam kết quy trình thanh toán minh bạch và tiện lợi nhất cho khách hàng.</p>
                                <ul class="mb-0">
                                    <li class="mb-2"><strong>Quy trình:</strong> Vé chỉ được xuất sau khi hệ thống xác nhận thanh toán thành công 100%.</li>
                                    <li class="mb-2"><strong>Mã QR:</strong> Mỗi vé sẽ đi kèm một mã QR duy nhất mã hóa bằng JWT. Quý khách tuyệt đối không chia sẻ mã QR này cho người khác lên mạng xã hội.</li>
                                    <li class="mb-2"><strong>Thay đổi:</strong> Ban tổ chức có quyền thay đổi thời gian, địa điểm hoặc nội dung sự kiện. WIBU DASH sẽ thông báo qua email hoặc số điện thoại đăng ký.</li>
                                    <li><strong>Giới hạn:</strong> Hệ thống có thể áp dụng giới hạn số lượng vé mua tối đa cho mỗi tài khoản để chống đầu cơ.</li>
                                </ul>
                            </div>
                        </div>

                        <hr class="text-light mb-5">

                        <!-- Section 3: Chính sách hoàn/hủy đổi trả -->
                        <div class="mb-5">
                            <h3 class="fw-bold mb-4 text-primary d-flex align-items-center">
                                <i class="fas fa-undo-alt me-3 fs-4"></i>3. Chính sách Hoàn, Hủy & Đổi trả
                            </h3>
                            <div class="ps-md-5 text-muted line-height-lg">
                                <div class="alert alert-warning border-0 bg-warning bg-opacity-10 text-warning-emphasis mb-4 rounded-3 d-flex align-items-start">
                                    <i class="fas fa-exclamation-triangle mt-1 me-3"></i>
                                    <div>Xin lưu ý: WIBU DASH tuân theo chính sách hoàn/hủy từ phía Ban tổ chức sự kiện. Dưới đây là chính sách tiêu chuẩn nếu Ban tổ chức không có quy định khác.</div>
                                </div>
                                <ul class="mb-0">
                                    <li class="mb-2"><strong>Khách hàng hủy vé:</strong> Trừ các trường hợp đặc biệt được Ban tổ chức công bố, vé đã mua <strong class="text-danger">KHÔNG ĐƯỢC HOÀN TRẢ</strong> hoặc đổi sang sự kiện khác dưới mọi hình thức.</li>
                                    <li class="mb-2"><strong>Event bị hủy/hoãn:</strong> Trong trường hợp sự kiện bị hủy do lỗi của Ban tổ chức hoặc lý do bất khả kháng, tiền vé sẽ được hoàn trả 100% qua phương thức thanh toán gốc trong vòng từ 7-14 ngày làm việc.</li>
                                    <li><strong>Chuyển nhượng vé:</strong> Khách hàng có thể chuyển nhượng vé cho người khác bằng cách gửi mã QR, tuy nhiên hệ thống sẽ không chịu trách nhiệm nếu xảy ra tranh chấp hoặc vé bị sao chép đen.</li>
                                </ul>
                            </div>
                        </div>

                        <hr class="text-light mb-5">

                        <!-- Section 4: Chính sách bảo mật dữ liệu -->
                        <div>
                            <h3 class="fw-bold mb-4 text-primary d-flex align-items-center">
                                <i class="fas fa-user-shield me-3 fs-4"></i>4. Chính sách bảo mật dữ liệu (Privacy Policy)
                            </h3>
                            <div class="ps-md-5 text-muted line-height-lg">
                                <p>Sự riêng tư của bạn là ưu tiên hàng đầu của chúng tôi.</p>
                                <ul class="mb-0">
                                    <li class="mb-2"><strong>Thu thập:</strong> Chúng tôi chỉ thu thập các thông tin cần thiết: Họ tên, Email, SĐT để phục vụ việc gửi vé và hỗ trợ khách hàng.</li>
                                    <li class="mb-2"><strong>Sử dụng:</strong> Dữ liệu của bạn được mã hóa an toàn và không bao giờ được chia sẻ/bán cho bên thứ ba cho mục đích quảng cáo rác.</li>
                                    <li><strong>Cookie:</strong> Hệ thống sử dụng cookie (như JWT token) để duy trì phiên đăng nhập và bảo mật tài khoản. Mã QR vé cũng là một token mã hóa 2 chiều không thể làm giả.</li>
                                </ul>
                            </div>
                        </div>

                    </div>
                </div>
                
                <div class="text-center mt-4 mb-5 text-muted">
                    <p class="small">Cập nhật lần cuối: 03/2026</p>
                    <p>Nếu bạn có câu hỏi, vui lòng liên hệ <a href="mailto:support@wibudash.com" class="text-primary text-decoration-none fw-medium">support@wibudash.com</a></p>
                </div>
            </div>
        </div>
    </div>
</section>

<style>
.line-height-lg {
    line-height: 1.8;
}
.glass-strong {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid rgba(255,255,255,0.2) !important;
}
</style>

<jsp:include page="footer.jsp" />
