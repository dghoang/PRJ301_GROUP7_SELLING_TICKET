<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

<c:set var="pageTitle" value="Thanh toán" scope="request" />
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

    <!-- Error Message -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger rounded-4 mb-4 d-flex align-items-center gap-2 animate-on-scroll">
            <i class="fas fa-exclamation-triangle"></i>
            <span>${error}</span>
        </div>
    </c:if>

    <form method="POST" action="${pageContext.request.contextPath}/checkout" id="checkoutForm">
        <input type="hidden" name="eventId" value="${event.eventId}">
        <%-- Multi-ticket items param: typeId:qty,typeId:qty --%>
        <c:if test="${not empty selectedItems}">
            <c:set var="itemsStr" value=""/>
            <c:forEach var="si" items="${selectedItems}" varStatus="siLoop">
                <c:set var="itemsStr" value="${itemsStr}${siLoop.first ? '' : ','}${si.ticketType.ticketTypeId}:${si.quantity}"/>
            </c:forEach>
            <input type="hidden" name="items" value="${itemsStr}">
        </c:if>
        <input type="hidden" name="csrf_token" value="${not empty requestScope.csrf_token ? requestScope.csrf_token : sessionScope.csrf_token}"/>

        <%-- Show error if event ended --%>
        <c:if test="${not empty error}">
            <div class="alert border-0 rounded-4 mb-4" style="background: rgba(239,68,68,0.08); border-left: 4px solid #ef4444 !important;">
                <i class="fas fa-exclamation-triangle text-danger me-2"></i>
                <strong>${error}</strong>
            </div>
        </c:if>

        <div class="row g-4 g-lg-5">
            <!-- Main Content -->
            <div class="col-lg-8">
                <!-- Buyer Info -->
                <div class="glass-strong p-4 rounded-4 mb-4 animate-on-scroll">
                    <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                        <i class="fas fa-user text-primary"></i> Thông tin người mua
                    </h5>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-medium">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" class="form-control py-2 rounded-3" name="buyerName"
                                   value="${not empty user.fullName ? user.fullName : ''}" required
                                   placeholder="Nguyễn Văn A">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-medium">Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control py-2 rounded-3" name="buyerEmail"
                                   value="${not empty user.email ? user.email : ''}" required
                                   placeholder="email@example.com">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-medium">Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control py-2 rounded-3" name="buyerPhone"
                                   value="${not empty user.phone ? user.phone : ''}" required
                                   placeholder="0901234567">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-medium">Ghi chú</label>
                            <input type="text" class="form-control py-2 rounded-3" name="notes"
                                   placeholder="Ghi chú cho ban tổ chức (tùy chọn)">
                        </div>
                    </div>
                </div>

                <!-- Delivery Method -->
                <div class="glass-strong p-4 rounded-4 mb-4 animate-on-scroll">
                    <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                        <i class="fas fa-shipping-fast text-primary"></i> Phương thức nhận vé
                    </h5>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="delivery-option glass p-4 rounded-4 text-center h-100 selected hover-lift" onclick="selectDelivery('email')" data-type="email" style="border: 2px solid var(--primary); cursor: pointer; transition: all 0.3s;">
                                <div class="mb-3">
                                    <div class="rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, rgba(147,51,234,0.1), rgba(219,39,119,0.1));">
                                        <i class="fas fa-envelope text-primary fa-lg"></i>
                                    </div>
                                </div>
                                <h6 class="fw-bold mb-1">Vé điện tử (E-Ticket)</h6>
                                <p class="text-muted small mb-2">Nhận QR code qua email ngay sau thanh toán</p>
                                <span class="badge rounded-pill px-3 py-1" style="background: linear-gradient(135deg, #10b981, #06b6d4);">Miễn phí · Tức thì</span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="delivery-option glass p-4 rounded-4 text-center h-100 hover-lift" onclick="selectDelivery('physical')" data-type="physical" style="border: 2px solid transparent; cursor: pointer; transition: all 0.3s;">
                                <div class="mb-3">
                                    <div class="rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: rgba(245,158,11,0.1);">
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
                    <div class="d-flex flex-column gap-3">
                        <div class="payment-option glass p-4 rounded-4 d-flex align-items-center gap-3 selected hover-lift" onclick="selectPayment('seepay')" data-type="seepay" style="border: 2px solid var(--primary); cursor: pointer; transition: all 0.3s;">
                            <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-qrcode text-white"></i>
                            </div>
                            <div class="flex-grow-1">
                                <h6 class="fw-bold mb-0">Chuyển khoản QR <span class="badge bg-success rounded-pill ms-1" style="font-size:10px;">Khuyên dùng</span></h6>
                                <small class="text-muted">Quét mã QR VietQR qua app ngân hàng</small>
                            </div>
                            <i class="fas fa-check-circle text-primary fs-5"></i>
                        </div>
                        <div class="payment-option glass p-4 rounded-4 d-flex align-items-center gap-3 hover-lift" onclick="selectPayment('momo')" data-type="momo" style="border: 2px solid transparent; cursor: pointer; transition: all 0.3s;">
                            <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: linear-gradient(135deg, #a855f7, #ec4899);">
                                <span class="fw-bold text-white">M</span>
                            </div>
                            <div class="flex-grow-1">
                                <h6 class="fw-bold mb-0">Ví MoMo</h6>
                                <small class="text-muted">Thanh toán qua ví điện tử</small>
                            </div>
                            <i class="fas fa-check-circle text-muted fs-5"></i>
                        </div>
                        <div class="payment-option glass p-4 rounded-4 d-flex align-items-center gap-3 hover-lift" onclick="selectPayment('vnpay')" data-type="vnpay" style="border: 2px solid transparent; cursor: pointer; transition: all 0.3s;">
                            <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: linear-gradient(135deg, #06b6d4, #3b82f6);">
                                <span class="fw-bold text-white">V</span>
                            </div>
                            <div class="flex-grow-1">
                                <h6 class="fw-bold mb-0">VNPay</h6>
                                <small class="text-muted">Thẻ ngân hàng, Visa, MasterCard</small>
                            </div>
                            <i class="fas fa-check-circle text-muted fs-5"></i>
                        </div>
                    </div>
                    <input type="hidden" name="paymentMethod" id="paymentMethodInput" value="seepay">
                </div>

                <!-- Promo Code -->
                <div class="glass-strong p-4 rounded-4 animate-on-scroll">
                    <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                        <i class="fas fa-tag text-primary"></i> Mã giảm giá
                    </h5>
                    <div class="input-group">
                        <input type="text" class="form-control py-3 rounded-start-4" placeholder="Nhập mã giảm giá" id="promoCode">
                        <button type="button" class="btn btn-gradient px-4 rounded-end-4 hover-glow" id="promoBtn" onclick="applyPromo()">Áp dụng</button>
                    </div>
                    <div id="promoResult" class="mt-3"></div>
                    <input type="hidden" name="voucherCode" id="voucherCodeInput" value="">
                </div>
            </div>

            <!-- Order Summary - Sticky -->
            <div class="col-lg-4">
                <div class="position-sticky" style="top: 100px;">
                    <div class="glass-strong p-4 rounded-4 animate-on-scroll">
                        <h5 class="fw-bold mb-4">Chi tiết đơn hàng</h5>

                        <!-- Event Info (Dynamic) -->
                        <div class="d-flex gap-3 mb-4 pb-4 border-bottom">
                            <c:choose>
                                <c:when test="${not empty event.bannerImage}">
                                    <img src="${event.bannerImage}" alt="${event.title}" class="rounded-3" style="width: 80px; height: 80px; object-fit: cover;">
                                </c:when>
                                <c:otherwise>
                                    <div class="rounded-3 d-flex align-items-center justify-content-center" style="width:80px;height:80px;background:linear-gradient(135deg,#9333ea,#db2777);">
                                        <i class="fas fa-calendar-alt text-white fa-2x"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <h6 class="fw-bold mb-1">
                                    <c:out value="${event.title}" default="Sự kiện"/>
                                </h6>
                                <p class="small text-muted mb-0">
                                    <i class="far fa-calendar me-1"></i>
                                    <c:if test="${not empty event.startDate}">
                                        <fmt:formatDate value="${event.startDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </c:if>
                                </p>
                                <p class="small text-muted mb-0">
                                    <i class="fas fa-map-marker-alt me-1"></i>
                                    <c:out value="${event.location}" default=""/>
                                </p>
                            </div>
                        </div>

                        <!-- Ticket Details (Dynamic) -->
                        <div class="mb-4">
                            <c:choose>
                                <c:when test="${not empty selectedItems}">
                                    <c:forEach var="si" items="${selectedItems}">
                                        <div class="d-flex justify-content-between small mb-2">
                                            <span class="text-muted">${si.ticketType.name} x ${si.quantity}</span>
                                            <span><fmt:formatNumber value="${si.subtotal}" pattern="#,###"/> đ</span>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:when test="${not empty selectedTicket}">
                                    <div class="d-flex justify-content-between small mb-2">
                                        <span class="text-muted">${selectedTicket.name} x ${quantity}</span>
                                        <span><fmt:formatNumber value="${subtotal}" pattern="#,###"/> đ</span>
                                    </div>
                                </c:when>
                            </c:choose>
                        </div>

                        <!-- Pricing -->
                        <div class="py-4 border-top border-bottom mb-4">
                            <div class="d-flex justify-content-between small mb-2">
                                <span class="text-muted">Tạm tính</span>
                                <span><fmt:formatNumber value="${subtotal}" pattern="#,###"/> đ</span>
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
                            <span class="fw-bold fs-4 text-primary" id="totalAmount">
                                <fmt:formatNumber value="${subtotal}" pattern="#,###"/> đ
                            </span>
                        </div>


                        <!-- Pay Button -->
                        <button type="submit" class="btn btn-gradient w-100 py-3 rounded-3 fw-bold hover-glow" id="payBtn">
                            <span id="payBtnText"><i class="fas fa-lock me-2"></i>Thanh toán ngay</span>
                            <span id="payBtnLoading" class="d-none">
                                <span class="spinner-border spinner-border-sm me-2"></span>Đang xử lý...
                            </span>
                        </button>

                        <p class="text-muted small text-center mt-3 mb-0">
                            <i class="fas fa-shield-alt text-success me-1"></i>Thanh toán an toàn 100% · SSL/TLS
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<script>
var selectedPayment = 'bank_transfer';
var currentDiscount = 0;
var baseSubtotal = ${subtotal != null ? subtotal : 0};

function selectDelivery(type) {
    document.querySelectorAll('.delivery-option').forEach(function(el) {
        el.style.borderColor = 'transparent';
        el.classList.remove('selected');
    });
    var sel = document.querySelector('.delivery-option[data-type="' + type + '"]');
    sel.style.borderColor = 'var(--primary)';
    sel.classList.add('selected');
}

function selectPayment(type) {
    selectedPayment = type;
    document.querySelectorAll('.payment-option').forEach(function(el) {
        el.style.borderColor = 'transparent';
        el.classList.remove('selected');
        el.querySelector('.fa-check-circle').classList.remove('text-primary');
        el.querySelector('.fa-check-circle').classList.add('text-muted');
    });
    var sel = document.querySelector('.payment-option[data-type="' + type + '"]');
    sel.style.borderColor = 'var(--primary)';
    sel.classList.add('selected');
    sel.querySelector('.fa-check-circle').classList.remove('text-muted');
    sel.querySelector('.fa-check-circle').classList.add('text-primary');
    document.getElementById('paymentMethodInput').value = type;
}

function applyPromo() {
    var code = document.getElementById('promoCode').value.trim();
    var result = document.getElementById('promoResult');
    if (!code) { result.innerHTML = ''; return; }

    var btn = document.getElementById('promoBtn');
    btn.disabled = true;
    result.innerHTML = '<div class="alert alert-info py-2 rounded-3 d-flex align-items-center gap-2"><i class="fas fa-spinner fa-spin"></i>Đang kiểm tra...</div>';

    var ctx = '${pageContext.request.contextPath}';
    var eventId = '${event.eventId}';

    fetch(ctx + '/api/voucher/validate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        credentials: 'same-origin',
        body: 'code=' + encodeURIComponent(code) + '&eventId=' + encodeURIComponent(eventId) + '&amount=' + encodeURIComponent(baseSubtotal)
    })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            btn.disabled = false;
            if (data.valid) {
                currentDiscount = data.discountAmount;
                document.getElementById('voucherCodeInput').value = code;
                document.getElementById('promoCode').readOnly = true;
                result.innerHTML = '<div class="alert alert-success py-2 rounded-3 d-flex align-items-center justify-content-between">'
                    + '<span><i class="fas fa-check-circle me-2"></i>' + data.message + '</span>'
                    + '<button type="button" class="btn btn-sm btn-outline-danger rounded-pill" onclick="removePromo()"><i class="fas fa-times"></i></button>'
                    + '</div>';
                updateOrderTotal();
            } else {
                currentDiscount = 0;
                document.getElementById('voucherCodeInput').value = '';
                result.innerHTML = '<div class="alert alert-warning py-2 rounded-3 d-flex align-items-center gap-2"><i class="fas fa-info-circle"></i>' + data.message + '</div>';
                updateOrderTotal();
            }
        })
        .catch(function() {
            btn.disabled = false;
            result.innerHTML = '<div class="alert alert-danger py-2 rounded-3"><i class="fas fa-exclamation-triangle me-2"></i>Lỗi kết nối. Thử lại sau.</div>';
        });
}

function removePromo() {
    currentDiscount = 0;
    document.getElementById('voucherCodeInput').value = '';
    document.getElementById('promoCode').value = '';
    document.getElementById('promoCode').readOnly = false;
    document.getElementById('promoResult').innerHTML = '';
    updateOrderTotal();
}

function updateOrderTotal() {
    var discountRow = document.getElementById('discountRow');
    var discountAmountEl = document.getElementById('discountAmount');
    var totalEl = document.getElementById('totalAmount');
    var finalTotal = baseSubtotal - currentDiscount;
    if (finalTotal < 0) finalTotal = 0;

    if (currentDiscount > 0) {
        discountRow.style.display = 'flex';
        discountRow.style.setProperty('display', 'flex', 'important');
        discountAmountEl.textContent = '-' + currentDiscount.toLocaleString('vi-VN') + ' đ';
    } else {
        discountRow.style.setProperty('display', 'none', 'important');
    }
    totalEl.textContent = finalTotal.toLocaleString('vi-VN') + ' đ';
}

document.getElementById('checkoutForm').addEventListener('submit', function(e) {
    var btn = document.getElementById('payBtn');
    btn.disabled = true;
    document.getElementById('payBtnText').classList.add('d-none');
    document.getElementById('payBtnLoading').classList.remove('d-none');
});
</script>

<style>
@keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-8px); }
    75% { transform: translateX(8px); }
}
</style>

<jsp:include page="footer.jsp" />
