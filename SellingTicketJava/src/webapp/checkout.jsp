<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<div class="container py-5" style="max-width: 1140px;">
    <!-- Progress Steps -->
    <div class="mb-5 animate-fadeInDown">
        <div class="d-flex align-items-center justify-content-center gap-2 gap-md-4 flex-wrap">
            <div class="d-flex align-items-center gap-2">
                <span class="badge rounded-circle d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; background: linear-gradient(135deg, #10b981, #06b6d4);">
                    <i class="fas fa-check text-white" style="font-size: 12px;"></i>
                </span>
                <span class="fw-medium text-success d-none d-sm-inline">Chọn vé</span>
            </div>
            <div class="flex-grow-1 border-top border-2" style="max-width: 80px;"></div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge rounded-circle d-flex align-items-center justify-content-center text-white" style="width: 32px; height: 32px; background: linear-gradient(135deg, var(--primary), var(--secondary));">2</span>
                <span class="fw-bold d-none d-sm-inline">Thanh toán</span>
            </div>
            <div class="flex-grow-1 border-top border-2" style="max-width: 80px; border-color: #e5e7eb !important;"></div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge rounded-circle d-flex align-items-center justify-content-center bg-light text-muted" style="width: 32px; height: 32px;">3</span>
                <span class="text-muted d-none d-sm-inline">Hoàn tất</span>
            </div>
        </div>
    </div>

    <div class="row g-4 g-lg-5">
        <!-- Main Content -->
        <div class="col-lg-8">
            <!-- Delivery Method -->
            <div class="glass-strong p-4 rounded-4 mb-4 animate-on-scroll">
                <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                    <i class="fas fa-shipping-fast text-primary"></i> Phương thức nhận vé
                </h5>
                <div class="row g-3">
                    <div class="col-md-6">
                        <div class="delivery-option glass p-4 rounded-4 text-center h-100 selected hover-lift" onclick="selectDelivery('email')" data-type="email" style="border: 2px solid var(--primary); cursor: pointer; transition: all 0.3s ease;">
                            <div class="mb-3">
                                <div class="rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));">
                                    <i class="fas fa-envelope text-primary fa-lg"></i>
                                </div>
                            </div>
                            <h6 class="fw-bold mb-1">Vé điện tử</h6>
                            <p class="text-muted small mb-2">Nhận qua email ngay sau thanh toán</p>
                            <span class="badge rounded-pill px-3 py-1" style="background: linear-gradient(135deg, #10b981, #06b6d4);">Miễn phí</span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="delivery-option glass p-4 rounded-4 text-center h-100 hover-lift" onclick="selectDelivery('physical')" data-type="physical" style="border: 2px solid transparent; cursor: pointer; transition: all 0.3s ease;">
                            <div class="mb-3">
                                <div class="rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: rgba(245, 158, 11, 0.1);">
                                    <i class="fas fa-ticket-alt text-warning fa-lg"></i>
                                </div>
                            </div>
                            <h6 class="fw-bold mb-1">Vé giấy</h6>
                            <p class="text-muted small mb-2">Giao đến địa chỉ trong 3-5 ngày</p>
                            <span class="badge bg-warning text-dark rounded-pill px-3 py-1">+ 30.000đ</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Payment Method -->
            <div class="glass-strong p-4 rounded-4 mb-4 animate-on-scroll">
                <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                    <i class="fas fa-credit-card text-primary"></i> Phương thức thanh toán
                </h5>
                <div class="d-flex flex-column gap-3" data-stagger-children="0.1">
                    <div class="payment-option glass p-4 rounded-4 d-flex align-items-center gap-3 selected hover-lift" onclick="selectPayment('momo')" data-type="momo" style="border: 2px solid var(--primary); cursor: pointer; transition: all 0.3s ease;">
                        <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: linear-gradient(135deg, #a855f7, #ec4899);">
                            <span class="fw-bold text-white">M</span>
                        </div>
                        <div class="flex-grow-1">
                            <h6 class="fw-bold mb-0">Ví MoMo</h6>
                            <small class="text-muted">Thanh toán nhanh chóng qua ví điện tử</small>
                        </div>
                        <i class="fas fa-check-circle text-primary fs-5"></i>
                    </div>
                    <div class="payment-option glass p-4 rounded-4 d-flex align-items-center gap-3 hover-lift" onclick="selectPayment('vnpay')" data-type="vnpay" style="border: 2px solid transparent; cursor: pointer; transition: all 0.3s ease;">
                        <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: linear-gradient(135deg, #06b6d4, #3b82f6);">
                            <span class="fw-bold text-white">V</span>
                        </div>
                        <div class="flex-grow-1">
                            <h6 class="fw-bold mb-0">VNPay</h6>
                            <small class="text-muted">Quét mã QR hoặc thẻ ngân hàng</small>
                        </div>
                        <i class="fas fa-check-circle text-muted fs-5"></i>
                    </div>
                    <div class="payment-option glass p-4 rounded-4 d-flex align-items-center gap-3 hover-lift" onclick="selectPayment('card')" data-type="card" style="border: 2px solid transparent; cursor: pointer; transition: all 0.3s ease;">
                        <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: linear-gradient(135deg, #1e293b, #475569);">
                            <i class="fab fa-cc-visa text-white"></i>
                        </div>
                        <div class="flex-grow-1">
                            <h6 class="fw-bold mb-0">Thẻ quốc tế</h6>
                            <small class="text-muted">Visa, MasterCard, JCB</small>
                        </div>
                        <i class="fas fa-check-circle text-muted fs-5"></i>
                    </div>
                </div>
            </div>

            <!-- Promo Code -->
            <div class="glass-strong p-4 rounded-4 animate-on-scroll">
                <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                    <i class="fas fa-tag text-primary"></i> Mã giảm giá
                </h5>
                <div class="input-group">
                    <input type="text" class="form-control py-3 rounded-start-4" placeholder="Nhập mã giảm giá" id="promoCode">
                    <button class="btn btn-gradient px-4 rounded-end-4 hover-glow" onclick="applyPromo()">Áp dụng</button>
                </div>
                <div id="promoResult" class="mt-3"></div>
            </div>
        </div>

        <!-- Order Summary - Sticky -->
        <div class="col-lg-4">
            <div class="position-sticky" style="top: 100px;">
                <div class="glass-strong p-4 rounded-4 animate-on-scroll">
                    <h5 class="fw-bold mb-4">Chi tiết đơn hàng</h5>

                    <!-- Event Info -->
                    <div class="d-flex gap-3 mb-4 pb-4 border-bottom">
                        <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800" alt="Event" class="rounded-3" style="width: 80px; height: 80px; object-fit: cover;">
                        <div>
                            <h6 class="fw-bold mb-1">Đêm nhạc Acoustic</h6>
                            <p class="small text-muted mb-0">
                                <i class="far fa-calendar me-1"></i>15/02/2026
                            </p>
                            <p class="small text-muted mb-0">
                                <i class="fas fa-map-marker-alt me-1"></i>Nhà hát Thành phố
                            </p>
                        </div>
                    </div>

                    <!-- Tickets -->
                    <div class="mb-4">
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-muted">Vé VIP x 2</span>
                            <span>1.500.000 đ</span>
                        </div>
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-muted">Vé thường x 1</span>
                            <span>350.000 đ</span>
                        </div>
                    </div>

                    <!-- Pricing -->
                    <div class="py-4 border-top border-bottom mb-4">
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-muted">Tạm tính</span>
                            <span>1.850.000 đ</span>
                        </div>
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-muted">Phí dịch vụ</span>
                            <span>0 đ</span>
                        </div>
                        <div class="d-flex justify-content-between small" id="discountRow" style="display: none !important;">
                            <span class="text-success">Giảm giá</span>
                            <span class="text-success" id="discountAmount">-0 đ</span>
                        </div>
                    </div>

                    <!-- Total -->
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <span class="fw-bold fs-5">Tổng cộng</span>
                        <span class="fw-bold fs-4 text-primary" id="totalAmount">1.850.000 đ</span>
                    </div>

                    <!-- Pay Button -->
                    <button class="btn btn-gradient w-100 py-3 rounded-3 fw-bold hover-glow" onclick="processPayment()">
                        <span id="payBtnText">Thanh toán ngay</span>
                        <span id="payBtnLoading" class="d-none">
                            <span class="spinner-border spinner-border-sm me-2"></span>Đang xử lý...
                        </span>
                    </button>

                    <p class="text-muted small text-center mt-3 mb-0">
                        <i class="fas fa-lock me-1"></i>Thanh toán an toàn với SSL
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function selectDelivery(type) {
    document.querySelectorAll('.delivery-option').forEach(el => {
        el.style.borderColor = 'transparent';
        el.classList.remove('selected');
    });
    const selected = document.querySelector('.delivery-option[data-type="' + type + '"]');
    selected.style.borderColor = 'var(--primary)';
    selected.classList.add('selected');
}

function selectPayment(type) {
    document.querySelectorAll('.payment-option').forEach(el => {
        el.style.borderColor = 'transparent';
        el.classList.remove('selected');
        el.querySelector('.fa-check-circle').classList.remove('text-primary');
        el.querySelector('.fa-check-circle').classList.add('text-muted');
    });
    const selected = document.querySelector('.payment-option[data-type="' + type + '"]');
    selected.style.borderColor = 'var(--primary)';
    selected.classList.add('selected');
    selected.querySelector('.fa-check-circle').classList.remove('text-muted');
    selected.querySelector('.fa-check-circle').classList.add('text-primary');
}

function applyPromo() {
    const code = document.getElementById('promoCode').value.trim();
    const result = document.getElementById('promoResult');
    
    if (code === 'SALE10') {
        result.innerHTML = '<div class="alert alert-success py-2 rounded-3 d-flex align-items-center gap-2"><i class="fas fa-check-circle"></i>Áp dụng thành công! Giảm 10%</div>';
        document.getElementById('discountRow').style.display = 'flex';
        document.getElementById('discountAmount').textContent = '-185.000 đ';
        document.getElementById('totalAmount').textContent = '1.665.000 đ';
    } else if (code) {
        result.innerHTML = '<div class="alert alert-danger py-2 rounded-3 d-flex align-items-center gap-2"><i class="fas fa-times-circle"></i>Mã không hợp lệ hoặc đã hết hạn</div>';
    }
}

function processPayment() {
    const btnText = document.getElementById('payBtnText');
    const btnLoading = document.getElementById('payBtnLoading');
    
    btnText.classList.add('d-none');
    btnLoading.classList.remove('d-none');
    
    setTimeout(function() {
        window.location.href = '${pageContext.request.contextPath}/order-confirmation';
    }, 2000);
}
</script>

<jsp:include page="footer.jsp" />
