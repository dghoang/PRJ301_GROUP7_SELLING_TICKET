<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<!-- Hero Section -->
<section class="py-5 position-relative overflow-hidden" style="background: linear-gradient(135deg, var(--primary), var(--secondary));">
    <div class="hero-blob blob-1" style="width: 300px; height: 300px; top: -100px; left: 10%;"></div>
    
    <div class="container position-relative text-center" style="z-index: 10;">
        <span class="badge glass rounded-pill px-3 py-2 mb-3 animate-fadeInDown">
            <i class="fas fa-question-circle me-2"></i><span data-i18n="faq.badge">Trung tâm trợ giúp</span>
        </span>
        <h1 class="display-5 fw-bold text-white mb-3 animate-fadeInUp" data-i18n="faq.title">Câu hỏi thường gặp</h1>
        <p class="lead text-white-50 mb-0 animate-fadeInUp stagger-2" data-i18n="faq.subtitle">Tìm câu trả lời nhanh cho các thắc mắc của bạn</p>
    </div>
</section>

<div class="container py-5" style="max-width: 850px;">
    <!-- Search -->
    <div class="mb-5 animate-on-scroll">
        <div class="input-group input-group-lg glass-strong rounded-4 overflow-hidden shadow">
            <span class="input-group-text bg-transparent border-0 ps-4">
                <i class="fas fa-search text-muted"></i>
            </span>
            <input type="text" class="form-control bg-transparent border-0 py-3" data-i18n-placeholder="faq.search_placeholder" placeholder="Tìm kiếm câu hỏi..." id="faqSearch" onkeyup="filterFAQ()">
        </div>
    </div>

    <!-- FAQ Categories -->
    <div class="d-flex flex-wrap gap-2 mb-4 justify-content-center animate-on-scroll">
        <button class="btn btn-gradient rounded-pill px-4 active" onclick="filterCategory('all')" data-i18n="faq.cat_all">Tất cả</button>
        <button class="btn glass rounded-pill px-4" onclick="filterCategory('booking')" data-i18n="faq.cat_booking">Đặt vé</button>
        <button class="btn glass rounded-pill px-4" onclick="filterCategory('payment')" data-i18n="faq.cat_payment">Thanh toán</button>
        <button class="btn glass rounded-pill px-4" onclick="filterCategory('organizer')" data-i18n="faq.cat_organizer">Tổ chức</button>
    </div>

    <div class="accordion" id="faqAccordion" data-stagger-children="0.1">
        <!-- FAQ 1 -->
        <div class="accordion-item glass-strong border-0 rounded-4 mb-3 overflow-hidden animate-on-scroll faq-item" data-category="booking">
            <h2 class="accordion-header">
                <button class="accordion-button rounded-4 fw-bold py-4" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                    <span class="badge rounded-circle me-3" style="width: 32px; height: 32px; background: linear-gradient(135deg, var(--primary), var(--secondary)); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-ticket-alt text-white" style="font-size: 12px;"></i>
                    </span>
                    <span data-i18n="faq.q1_title">Làm thế nào để mua vé trên Ticketbox?</span>
                </button>
            </h2>
            <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-muted pb-4">
                    <div class="d-flex gap-3">
                        <div class="flex-shrink-0">
                            <div class="rounded-circle bg-success bg-opacity-10 d-flex align-items-center justify-content-center" style="width: 32px; height: 32px;">
                                <i class="fas fa-check text-success" style="font-size: 12px;"></i>
                            </div>
                        </div>
                        <div>
                            <span data-i18n="faq.q1_intro">Bạn chỉ cần thực hiện 4 bước đơn giản:</span>
                            <ol class="mt-2 mb-0">
                                <li data-i18n="faq.q1_step1">Chọn sự kiện muốn tham gia</li>
                                <li data-i18n="faq.q1_step2">Chọn loại vé và số lượng</li>
                                <li data-i18n="faq.q1_step3">Điền thông tin và thanh toán</li>
                                <li data-i18n="faq.q1_step4">Nhận vé điện tử qua email</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- FAQ 2 -->
        <div class="accordion-item glass-strong border-0 rounded-4 mb-3 overflow-hidden animate-on-scroll faq-item" data-category="payment">
            <h2 class="accordion-header">
                <button class="accordion-button collapsed rounded-4 fw-bold py-4" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                    <span class="badge rounded-circle me-3" style="width: 32px; height: 32px; background: linear-gradient(135deg, #3b82f6, #06b6d4); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-credit-card text-white" style="font-size: 12px;"></i>
                    </span>
                    <span data-i18n="faq.q2_title">Các phương thức thanh toán được hỗ trợ?</span>
                </button>
            </h2>
            <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-muted pb-4">
                    <p class="mb-3" data-i18n="faq.q2_intro">Ticketbox hiện hỗ trợ thanh toán bằng chuyển khoản QR:</p>
                    <div class="d-flex flex-wrap gap-2">
                        <span class="badge glass px-3 py-2"><i class="fas fa-qrcode text-green-600 me-1"></i> <span data-i18n="faq.q2_method1">VietQR / SePay</span></span>
                        <span class="badge glass px-3 py-2"><i class="fas fa-university text-blue-600 me-1"></i> <span data-i18n="faq.q2_method2">Ứng dụng ngân hàng</span></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- FAQ 3 -->
        <div class="accordion-item glass-strong border-0 rounded-4 mb-3 overflow-hidden animate-on-scroll faq-item" data-category="booking">
            <h2 class="accordion-header">
                <button class="accordion-button collapsed rounded-4 fw-bold py-4" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                    <span class="badge rounded-circle me-3" style="width: 32px; height: 32px; background: linear-gradient(135deg, #f59e0b, #ef4444); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-exchange-alt text-white" style="font-size: 12px;"></i>
                    </span>
                    <span data-i18n="faq.q3_title">Tôi có thể hủy hoặc đổi vé không?</span>
                </button>
            </h2>
            <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-muted pb-4">
                    <div class="alert glass border-0 mb-0">
                        <i class="fas fa-info-circle text-primary me-2"></i>
                        <span data-i18n="faq.q3_answer">Chính sách hủy/đổi vé phụ thuộc vào từng sự kiện và ban tổ chức. Vui lòng kiểm tra điều khoản của sự kiện trước khi mua hoặc liên hệ hotline</span> <strong class="text-primary">1900 6408</strong>.
                    </div>
                </div>
            </div>
        </div>

        <!-- FAQ 4 -->
        <div class="accordion-item glass-strong border-0 rounded-4 mb-3 overflow-hidden animate-on-scroll faq-item" data-category="booking">
            <h2 class="accordion-header">
                <button class="accordion-button collapsed rounded-4 fw-bold py-4" type="button" data-bs-toggle="collapse" data-bs-target="#faq4">
                    <span class="badge rounded-circle me-3" style="width: 32px; height: 32px; background: linear-gradient(135deg, #10b981, #06b6d4); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-qrcode text-white" style="font-size: 12px;"></i>
                    </span>
                    <span data-i18n="faq.q4_title">Làm sao để check-in tại sự kiện?</span>
                </button>
            </h2>
            <div id="faq4" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-muted pb-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="glass p-3 rounded-3 h-100">
                                <i class="fas fa-envelope text-primary mb-2 fs-4"></i>
                                <p class="mb-0 small" data-i18n="faq.q4_option1">Mang theo mã QR trong email vé điện tử</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="glass p-3 rounded-3 h-100">
                                <i class="fas fa-mobile-alt text-primary mb-2 fs-4"></i>
                                <p class="mb-0 small" data-i18n="faq.q4_option2">Hoặc mở vé trong "Vé của tôi" trên website/app</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- FAQ 5 -->
        <div class="accordion-item glass-strong border-0 rounded-4 mb-3 overflow-hidden animate-on-scroll faq-item" data-category="organizer">
            <h2 class="accordion-header">
                <button class="accordion-button collapsed rounded-4 fw-bold py-4" type="button" data-bs-toggle="collapse" data-bs-target="#faq5">
                    <span class="badge rounded-circle me-3" style="width: 32px; height: 32px; background: linear-gradient(135deg, #8b5cf6, #ec4899); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-calendar-plus text-white" style="font-size: 12px;"></i>
                    </span>
                    <span data-i18n="faq.q5_title">Tôi muốn tổ chức sự kiện, làm sao để đăng ký?</span>
                </button>
            </h2>
            <div id="faq5" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-muted pb-4">
                    <div class="d-flex align-items-start gap-3">
                        <span class="badge rounded-pill px-2 py-1" style="background: var(--primary);">1</span>
                        <span data-i18n="faq.q5_step1">Đăng ký tài khoản Organizer tại trang đăng ký</span>
                    </div>
                    <div class="d-flex align-items-start gap-3 mt-2">
                        <span class="badge rounded-pill px-2 py-1" style="background: var(--primary);">2</span>
                        <span data-i18n="faq.q5_step2">Điền thông tin công ty/tổ chức của bạn</span>
                    </div>
                    <div class="d-flex align-items-start gap-3 mt-2">
                        <span class="badge rounded-pill px-2 py-1" style="background: var(--primary);">3</span>
                        <span data-i18n="faq.q5_step3">Chờ admin phê duyệt (trong 24h làm việc)</span>
                    </div>
                    <div class="d-flex align-items-start gap-3 mt-2">
                        <span class="badge rounded-pill px-2 py-1 bg-success">4</span>
                        <span class="fw-medium" data-i18n="faq.q5_step4">Bắt đầu tạo và quản lý sự kiện!</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Contact CTA -->
    <div class="text-center mt-5 glass-strong p-5 rounded-4 animate-on-scroll">
        <div class="mb-4">
            <div class="rounded-circle d-inline-flex align-items-center justify-content-center mx-auto" style="width: 80px; height: 80px; background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));">
                <i class="fas fa-headset text-primary fa-2x"></i>
            </div>
        </div>
        <h4 class="fw-bold mb-2" data-i18n="faq.cta_title">Không tìm thấy câu trả lời?</h4>
        <p class="text-muted mb-4" data-i18n="faq.cta_desc">Đội ngũ hỗ trợ sẵn sàng giúp đỡ bạn 24/7</p>
        <div class="d-flex justify-content-center gap-3 flex-wrap">
            <a href="tel:19006408" class="btn btn-gradient rounded-pill px-4 py-2 hover-glow">
                <i class="fas fa-phone me-2"></i>1900 6408
            </a>
            <a href="mailto:support@ticketbox.vn" class="btn glass rounded-pill px-4 py-2 hover-lift">
                <i class="fas fa-envelope me-2"></i><span data-i18n="faq.btn_email">Email hỗ trợ</span>
            </a>
            <button type="button" class="btn glass rounded-pill px-4 py-2 hover-lift" onclick="openFaqChat(event)">
                <i class="fab fa-facebook-messenger me-2"></i><span data-i18n="faq.btn_chat">Chat trực tuyến</span>
            </button>
        </div>
    </div>
</div>

<!-- Fallback Modal (for users without floating live-chat widget) -->
<div class="modal fade" id="faqSupportModal" tabindex="-1" aria-labelledby="faqSupportModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4 overflow-hidden">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="faqSupportModalLabel">
                    <i class="fas fa-headset text-primary me-2"></i><span data-i18n="faq.modal_title">Liên hệ hỗ trợ</span>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body pt-2">
                <p class="text-muted mb-3" data-i18n="faq.modal_desc">Bạn có thể trò chuyện trực tiếp sau khi đăng nhập, hoặc gửi yêu cầu hỗ trợ ngay bây giờ.</p>
                <div class="d-grid gap-2">
                    <a href="${pageContext.request.contextPath}/login?returnUrl=%2Ffaq" class="btn btn-gradient rounded-pill">
                        <i class="fas fa-sign-in-alt me-2"></i><span data-i18n="faq.modal_login">Đăng nhập để chat trực tuyến</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/support/new" class="btn glass rounded-pill">
                        <i class="fas fa-paper-plane me-2"></i><span data-i18n="faq.modal_support">Tạo yêu cầu hỗ trợ</span>
                    </a>
                    <a href="mailto:support@ticketbox.vn" class="btn btn-light rounded-pill">
                        <i class="fas fa-envelope me-2"></i><span data-i18n="faq.modal_email">Gửi email support@ticketbox.vn</span>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function filterFAQ() {
    const query = document.getElementById('faqSearch').value.toLowerCase();
    document.querySelectorAll('.faq-item').forEach(item => {
        const text = item.textContent.toLowerCase();
        item.style.display = text.includes(query) ? '' : 'none';
    });
}

function filterCategory(cat) {
    document.querySelectorAll('.faq-item').forEach(item => {
        if (cat === 'all' || item.dataset.category === cat) {
            item.style.display = '';
        } else {
            item.style.display = 'none';
        }
    });
}

function openFaqChat(event) {
    if (event) event.preventDefault();

    // Primary path: use the existing floating live-chat widget.
    if (typeof openSupportLiveChat === 'function') {
        openSupportLiveChat();
        return;
    }

    // Fallback path: show support modal for guests / unavailable widget.
    const modalEl = document.getElementById('faqSupportModal');
    if (modalEl && window.bootstrap && window.bootstrap.Modal) {
        window.bootstrap.Modal.getOrCreateInstance(modalEl).show();
    }
}
</script>

<jsp:include page="footer.jsp" />
