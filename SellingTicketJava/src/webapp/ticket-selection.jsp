<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<div class="container py-5" style="max-width: 1140px;">
    <!-- Header -->
    <div class="mb-5 animate-fadeInUp">
        <a href="${pageContext.request.contextPath}/event/${event.slug}" class="d-inline-flex align-items-center gap-2 text-muted text-decoration-none mb-3 hover-lift">
            <i class="fas fa-arrow-left"></i> Quay lại chi tiết sự kiện
        </a>
        <h1 class="display-6 fw-bold mb-2">Chọn vé</h1>
        <p class="text-muted lead">Đêm nhạc Acoustic - Những bản tình ca</p>
    </div>

    <div class="row g-4 g-lg-5">
        <!-- Ticket Selection -->
        <div class="col-lg-8">
            <!-- Schedule Info -->
            <div class="glass-strong p-4 rounded-4 mb-4 animate-on-scroll">
                <div class="d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center gap-3">
                        <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 56px; height: 56px; background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));">
                            <i class="far fa-clock text-primary fs-4"></i>
                        </div>
                        <div>
                            <p class="fw-bold mb-0 fs-5">15/02/2026</p>
                            <p class="text-muted mb-0">19:00 - 22:00</p>
                        </div>
                    </div>
                    <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #06b6d4);">
                        <i class="fas fa-check-circle me-1"></i>Còn vé
                    </span>
                </div>
            </div>

            <!-- Ticket Types -->
            <div class="glass-strong p-4 rounded-4 animate-on-scroll">
                <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                    <i class="fas fa-ticket-alt text-primary"></i>
                    Chọn loại vé
                </h5>

                <div class="d-flex flex-column gap-3" data-stagger-children="0.1">
                    <!-- Ticket Type 1 -->
                    <div class="ticket-row p-4 rounded-4 border-2 border-transparent glass animate-on-scroll hover-lift" data-id="t1" data-name="Vé thường" data-price="350000" data-max="10" style="cursor: pointer; transition: all 0.3s ease;">
                        <div class="row align-items-center">
                            <div class="col">
                                <div class="d-flex align-items-center gap-2 mb-2">
                                    <h6 class="fw-bold mb-0">Vé thường</h6>
                                </div>
                                <p class="text-muted small mb-2">Ghế ngồi khu vực B, C</p>
                                <p class="fs-5 fw-bold text-primary mb-0">350.000 đ</p>
                                <p class="text-muted small mb-0">Còn 500 vé • Tối đa 10 vé/đơn</p>
                            </div>
                            <div class="col-auto">
                                <div class="d-flex align-items-center gap-3">
                                    <button onclick="updateQty('t1', -1)" class="btn glass rounded-3 d-flex align-items-center justify-content-center hover-scale" style="width: 44px; height: 44px;">
                                        <i class="fas fa-minus"></i>
                                    </button>
                                    <span id="qty-t1" class="fs-5 fw-bold" style="min-width: 40px; text-align: center;">0</span>
                                    <button onclick="updateQty('t1', 1)" class="btn glass rounded-3 d-flex align-items-center justify-content-center hover-scale" style="width: 44px; height: 44px;">
                                        <i class="fas fa-plus"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Ticket Type 2 -->
                    <div class="ticket-row p-4 rounded-4 border-2 border-transparent glass animate-on-scroll hover-lift" data-id="t2" data-name="Vé VIP" data-price="750000" data-max="5" style="cursor: pointer; transition: all 0.3s ease;">
                        <div class="row align-items-center">
                            <div class="col">
                                <div class="d-flex align-items-center gap-2 mb-2">
                                    <h6 class="fw-bold mb-0">Vé VIP</h6>
                                    <span class="badge rounded-pill bg-warning text-dark px-2 py-1 small">Hot</span>
                                </div>
                                <p class="text-muted small mb-2">Ghế ngồi khu vực A, bao gồm đồ uống</p>
                                <p class="fs-5 fw-bold text-primary mb-0">750.000 đ</p>
                                <p class="text-muted small mb-0">Còn 100 vé • Tối đa 5 vé/đơn</p>
                            </div>
                            <div class="col-auto">
                                <div class="d-flex align-items-center gap-3">
                                    <button onclick="updateQty('t2', -1)" class="btn glass rounded-3 d-flex align-items-center justify-content-center hover-scale" style="width: 44px; height: 44px;">
                                        <i class="fas fa-minus"></i>
                                    </button>
                                    <span id="qty-t2" class="fs-5 fw-bold" style="min-width: 40px; text-align: center;">0</span>
                                    <button onclick="updateQty('t2', 1)" class="btn glass rounded-3 d-flex align-items-center justify-content-center hover-scale" style="width: 44px; height: 44px;">
                                        <i class="fas fa-plus"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Ticket Type 3 -->
                    <div class="ticket-row p-4 rounded-4 border-2 border-transparent glass animate-on-scroll hover-lift" data-id="t3" data-name="Vé VVIP" data-price="1500000" data-max="2" style="cursor: pointer; transition: all 0.3s ease;">
                        <div class="row align-items-center">
                            <div class="col">
                                <div class="d-flex align-items-center gap-2 mb-2">
                                    <h6 class="fw-bold mb-0">Vé VVIP</h6>
                                    <span class="badge rounded-pill bg-danger px-2 py-1 small">Còn ít</span>
                                </div>
                                <p class="text-muted small mb-2">Ghế ngồi hàng đầu, giao lưu với nghệ sĩ</p>
                                <p class="fs-5 fw-bold text-primary mb-0">1.500.000 đ</p>
                                <p class="text-muted small mb-0">Còn 20 vé • Tối đa 2 vé/đơn</p>
                            </div>
                            <div class="col-auto">
                                <div class="d-flex align-items-center gap-3">
                                    <button onclick="updateQty('t3', -1)" class="btn glass rounded-3 d-flex align-items-center justify-content-center hover-scale" style="width: 44px; height: 44px;">
                                        <i class="fas fa-minus"></i>
                                    </button>
                                    <span id="qty-t3" class="fs-5 fw-bold" style="min-width: 40px; text-align: center;">0</span>
                                    <button onclick="updateQty('t3', 1)" class="btn glass rounded-3 d-flex align-items-center justify-content-center hover-scale" style="width: 44px; height: 44px;">
                                        <i class="fas fa-plus"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Order Summary - Sticky -->
        <div class="col-lg-4">
            <div class="position-sticky" style="top: 100px;">
                <!-- Countdown Timer -->
                <div id="timerCard" class="d-none p-4 rounded-4 mb-4 animate-pulse" style="border: 2px solid #fbbf24; background: linear-gradient(135deg, #fef3c7, #fde68a);">
                    <div class="d-flex align-items-center gap-3">
                        <i class="fas fa-exclamation-triangle text-warning fs-3"></i>
                        <div>
                            <p class="fw-medium mb-0 small">Thời gian giữ vé</p>
                            <p id="countdown" class="fs-3 fw-bold text-warning mb-0">10:00</p>
                        </div>
                    </div>
                </div>

                <!-- Order Summary -->
                <div class="glass-strong p-4 rounded-4 animate-on-scroll">
                    <h5 class="fw-bold mb-4">Đơn hàng của bạn</h5>

                    <!-- Event Thumbnail -->
                    <div class="d-flex gap-3 mb-4 pb-4 border-bottom">
                        <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800" alt="Event" class="rounded-3" style="width: 70px; height: 70px; object-fit: cover;">
                        <div class="flex-grow-1">
                            <p class="fw-bold small mb-1" style="line-height: 1.4;">Đêm nhạc Acoustic - Những bản tình ca</p>
                            <p class="text-muted small mb-0">15/02/2026</p>
                        </div>
                    </div>

                    <!-- Selected Tickets -->
                    <div id="orderItems" class="mb-4">
                        <div class="text-center py-5 text-muted">
                            <i class="fas fa-ticket-alt fs-1 opacity-25 mb-2"></i>
                            <p class="small mb-0">Chưa chọn vé nào</p>
                        </div>
                    </div>

                    <!-- Total -->
                    <div id="totalRow" class="d-none justify-content-between align-items-center py-4 border-top">
                        <span class="fw-medium">Tổng cộng</span>
                        <span id="totalAmount" class="fs-3 fw-bold text-primary">0 đ</span>
                    </div>

                    <!-- Continue Button -->
                    <a id="checkoutBtn" href="#" class="btn w-100 py-3 rounded-3 fw-bold mt-3 d-flex align-items-center justify-content-center gap-2" style="background: #d1d5db; color: #6b7280; pointer-events: none;">
                        Tiếp tục <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const quantities = { t1: 0, t2: 0, t3: 0 };
const prices = { t1: 350000, t2: 750000, t3: 1500000 };
const names = { t1: 'Vé thường', t2: 'Vé VIP', t3: 'Vé VVIP' };
const maxQty = { t1: 10, t2: 5, t3: 2 };
let timerInterval = null;
let timeLeft = 600;

function updateQty(id, delta) {
    const current = quantities[id];
    const newQty = Math.max(0, Math.min(maxQty[id], current + delta));
    quantities[id] = newQty;
    document.getElementById('qty-' + id).textContent = newQty;

    const row = document.querySelector('.ticket-row[data-id="' + id + '"]');
    if (newQty > 0) {
        row.classList.add('border-primary');
        row.style.background = 'rgba(147, 51, 234, 0.05)';
    } else {
        row.classList.remove('border-primary');
        row.style.background = '';
    }

    updateOrderSummary();
}

function updateOrderSummary() {
    const orderItems = document.getElementById('orderItems');
    const totalRow = document.getElementById('totalRow');
    const totalAmountEl = document.getElementById('totalAmount');
    const checkoutBtn = document.getElementById('checkoutBtn');
    const timerCard = document.getElementById('timerCard');

    let html = '';
    let total = 0;
    let hasSelection = false;

    for (const id in quantities) {
        if (quantities[id] > 0) {
            hasSelection = true;
            const subtotal = quantities[id] * prices[id];
            total += subtotal;
            html += '<div class="d-flex justify-content-between small mb-2"><span>' + names[id] + ' x ' + quantities[id] + '</span><span class="fw-medium">' + formatPrice(subtotal) + '</span></div>';
        }
    }

    if (hasSelection) {
        orderItems.innerHTML = html;
        totalRow.classList.remove('d-none');
        totalRow.classList.add('d-flex');
        totalAmountEl.textContent = formatPrice(total);
        checkoutBtn.href = '${pageContext.request.contextPath}/checkout?eventId=${param.eventId}';
        checkoutBtn.style.background = 'linear-gradient(135deg, var(--primary), var(--secondary))';
        checkoutBtn.style.color = 'white';
        checkoutBtn.style.pointerEvents = 'auto';
        checkoutBtn.classList.add('hover-glow');
        timerCard.classList.remove('d-none');
        if (!timerInterval) startTimer();
    } else {
        orderItems.innerHTML = '<div class="text-center py-5 text-muted"><i class="fas fa-ticket-alt fs-1 opacity-25 mb-2"></i><p class="small mb-0">Chưa chọn vé nào</p></div>';
        totalRow.classList.add('d-none');
        checkoutBtn.href = '#';
        checkoutBtn.style.background = '#d1d5db';
        checkoutBtn.style.color = '#6b7280';
        checkoutBtn.style.pointerEvents = 'none';
        checkoutBtn.classList.remove('hover-glow');
        timerCard.classList.add('d-none');
        stopTimer();
    }
}

function formatPrice(price) {
    return price.toLocaleString('vi-VN') + ' đ';
}

function startTimer() {
    timeLeft = 600;
    timerInterval = setInterval(function() {
        timeLeft--;
        const mins = Math.floor(timeLeft / 60);
        const secs = timeLeft % 60;
        document.getElementById('countdown').textContent = String(mins).padStart(2, '0') + ':' + String(secs).padStart(2, '0');
        if (timeLeft <= 0) {
            stopTimer();
            quantities.t1 = quantities.t2 = quantities.t3 = 0;
            document.getElementById('qty-t1').textContent = '0';
            document.getElementById('qty-t2').textContent = '0';
            document.getElementById('qty-t3').textContent = '0';
            document.querySelectorAll('.ticket-row').forEach(r => {
                r.classList.remove('border-primary');
                r.style.background = '';
            });
            updateOrderSummary();
            alert('Hết thời gian giữ vé. Vui lòng chọn lại.');
        }
    }, 1000);
}

function stopTimer() {
    if (timerInterval) {
        clearInterval(timerInterval);
        timerInterval = null;
    }
}
</script>

<jsp:include page="footer.jsp" />
