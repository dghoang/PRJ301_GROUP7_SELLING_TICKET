<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<style>
/* Success animation */
@keyframes successPop {
    0% { transform: scale(0); opacity: 0; }
    50% { transform: scale(1.2); }
    100% { transform: scale(1); opacity: 1; }
}
@keyframes checkDraw {
    0% { stroke-dashoffset: 50; }
    100% { stroke-dashoffset: 0; }
}
@keyframes confetti {
    0% { transform: translateY(0) rotate(0deg); opacity: 1; }
    100% { transform: translateY(-100vh) rotate(720deg); opacity: 0; }
}
.success-icon {
    animation: successPop 0.6s ease-out forwards;
}
.success-check {
    stroke-dasharray: 50;
    stroke-dashoffset: 50;
    animation: checkDraw 0.5s ease-out 0.3s forwards;
}
.confetti {
    position: fixed;
    bottom: 0;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    animation: confetti 3s ease-out forwards;
}
</style>

<!-- Confetti particles -->
<div id="confettiContainer"></div>

<div class="container py-5" style="max-width: 768px;">
    <!-- Progress Steps - Completed -->
    <div class="mb-5 animate-fadeInDown">
        <div class="d-flex align-items-center justify-content-center gap-2 gap-md-4 flex-wrap">
            <div class="d-flex align-items-center gap-2">
                <span class="badge rounded-circle d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; background: linear-gradient(135deg, #10b981, #06b6d4);">
                    <i class="fas fa-check text-white" style="font-size: 12px;"></i>
                </span>
                <span class="fw-medium text-success d-none d-sm-inline">Chọn vé</span>
            </div>
            <div class="flex-grow-1 border-top border-2 border-success" style="max-width: 80px;"></div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge rounded-circle d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; background: linear-gradient(135deg, #10b981, #06b6d4);">
                    <i class="fas fa-check text-white" style="font-size: 12px;"></i>
                </span>
                <span class="fw-medium text-success d-none d-sm-inline">Thanh toán</span>
            </div>
            <div class="flex-grow-1 border-top border-2 border-success" style="max-width: 80px;"></div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge rounded-circle d-flex align-items-center justify-content-center text-white" style="width: 32px; height: 32px; background: linear-gradient(135deg, var(--primary), var(--secondary));">3</span>
                <span class="fw-bold gradient-text-animate d-none d-sm-inline">Hoàn tất</span>
            </div>
        </div>
    </div>

    <div class="glass-strong p-5 rounded-4 text-center animate-fadeInUp">
        <!-- Success Icon -->
        <div class="success-icon rounded-circle d-flex align-items-center justify-content-center mx-auto mb-4" style="width: 120px; height: 120px; background: linear-gradient(135deg, #10b981, #06b6d4);">
            <svg width="60" height="60" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                <polyline class="success-check" points="20 6 9 17 4 12"></polyline>
            </svg>
        </div>

        <h1 class="display-5 fw-bold mb-3 animate-fadeInUp stagger-2">Đặt vé thành công!</h1>
        <p class="text-muted lead mb-5 animate-fadeInUp stagger-3">
            Cảm ơn bạn đã đặt vé. Thông tin vé đã được gửi đến email của bạn. 🎉
        </p>

        <!-- Order Info Card -->
        <div class="glass p-4 rounded-4 text-start mb-5 animate-on-scroll">
            <div class="d-flex align-items-center justify-content-between mb-4 pb-4 border-bottom">
                <span class="text-muted">Mã đơn hàng</span>
                <div class="d-flex align-items-center gap-2">
                    <span class="font-monospace fw-bold fs-5 text-primary">#TBX2026021501</span>
                    <button class="btn btn-sm glass rounded-3" onclick="copyOrderId()" title="Sao chép">
                        <i class="fas fa-copy"></i>
                    </button>
                </div>
            </div>
            
            <div class="d-flex gap-3 mb-4">
                <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800" alt="Event" class="rounded-3" style="width: 100px; height: 100px; object-fit: cover;">
                <div class="flex-grow-1">
                    <h5 class="fw-bold mb-2">Đêm nhạc Acoustic - Những bản tình ca</h5>
                    <p class="small text-muted mb-1">
                        <i class="far fa-calendar me-1"></i> 15/02/2026 • 19:00 - 22:00
                    </p>
                    <p class="small text-muted mb-0">
                        <i class="fas fa-map-marker-alt me-1"></i> Nhà hát Thành phố, Quận 1
                    </p>
                </div>
            </div>
            
            <div class="pt-4 border-top">
                <div class="d-flex justify-content-between small mb-2">
                    <span class="text-muted">Vé VIP x 2</span>
                    <span>1.500.000 đ</span>
                </div>
                <div class="d-flex justify-content-between small mb-2">
                    <span class="text-muted">Vé thường x 1</span>
                    <span>350.000 đ</span>
                </div>
                <div class="d-flex justify-content-between fw-bold fs-5 mt-4 pt-4 border-top" style="border-style: dashed !important;">
                    <span>Tổng cộng</span>
                    <span class="text-primary">1.850.000 đ</span>
                </div>
            </div>
        </div>

        <!-- Info Cards -->
        <div class="row g-3 mb-5" data-stagger-children="0.1">
            <div class="col-sm-6 animate-on-scroll">
                <div class="glass p-4 rounded-4 text-start h-100 hover-lift">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px; background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));">
                            <i class="fas fa-envelope text-primary"></i>
                        </div>
                        <span class="fw-bold">Vé điện tử</span>
                    </div>
                    <p class="text-muted small mb-0">
                        Vé đã được gửi đến email của bạn. Kiểm tra cả hộp thư rác nhé!
                    </p>
                </div>
            </div>
            <div class="col-sm-6 animate-on-scroll">
                <div class="glass p-4 rounded-4 text-start h-100 hover-lift">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px; background: linear-gradient(135deg, rgba(16, 185, 129, 0.1), rgba(6, 182, 212, 0.1));">
                            <i class="fas fa-qrcode text-success"></i>
                        </div>
                        <span class="fw-bold">Check-in</span>
                    </div>
                    <p class="text-muted small mb-0">
                        Mang theo mã QR trong email để check-in tại sự kiện.
                    </p>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center animate-on-scroll">
            <a href="${pageContext.request.contextPath}/events" class="btn btn-lg btn-gradient rounded-pill px-5 py-3 hover-glow">
                <i class="fas fa-search me-2"></i> Khám phá thêm
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="btn btn-lg glass rounded-pill px-5 py-3 hover-lift">
                <i class="fas fa-ticket-alt me-2"></i> Vé của tôi
            </a>
        </div>
        
        <!-- Share -->
        <div class="mt-5 pt-4 border-top animate-on-scroll">
            <p class="text-muted small mb-3">Chia sẻ với bạn bè</p>
            <div class="d-flex justify-content-center gap-2">
                <button class="btn glass rounded-circle hover-scale" style="width: 48px; height: 48px;">
                    <i class="fab fa-facebook-f text-primary"></i>
                </button>
                <button class="btn glass rounded-circle hover-scale" style="width: 48px; height: 48px;">
                    <i class="fab fa-twitter text-info"></i>
                </button>
                <button class="btn glass rounded-circle hover-scale" style="width: 48px; height: 48px;">
                    <i class="fas fa-link text-muted"></i>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
// Confetti effect
function createConfetti() {
    const container = document.getElementById('confettiContainer');
    const colors = ['#ec4899', '#8b5cf6', '#06b6d4', '#10b981', '#f59e0b'];
    
    for (let i = 0; i < 50; i++) {
        setTimeout(() => {
            const confetti = document.createElement('div');
            confetti.className = 'confetti';
            confetti.style.left = Math.random() * 100 + 'vw';
            confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
            confetti.style.animationDuration = (Math.random() * 2 + 2) + 's';
            confetti.style.animationDelay = Math.random() * 0.5 + 's';
            container.appendChild(confetti);
            
            setTimeout(() => confetti.remove(), 3500);
        }, i * 50);
    }
}

function copyOrderId() {
    navigator.clipboard.writeText('TBX2026021501');
    const btn = event.target.closest('button');
    btn.innerHTML = '<i class="fas fa-check"></i>';
    setTimeout(() => btn.innerHTML = '<i class="fas fa-copy"></i>', 2000);
}

// Start confetti on page load
document.addEventListener('DOMContentLoaded', createConfetti);
</script>

<jsp:include page="footer.jsp" />
