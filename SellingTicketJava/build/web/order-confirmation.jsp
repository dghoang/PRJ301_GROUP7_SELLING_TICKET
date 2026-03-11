<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<style>
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
.success-icon { animation: successPop 0.6s ease-out forwards; }
.success-check { stroke-dasharray: 50; stroke-dashoffset: 50; animation: checkDraw 0.5s ease-out 0.3s forwards; }
.confetti { position: fixed; bottom: 0; width: 10px; height: 10px; border-radius: 50%; animation: confetti 3s ease-out forwards; }
.ticket-qr-card {
    background: linear-gradient(135deg, rgba(16, 185, 129, 0.05), rgba(6, 182, 212, 0.05));
    border: 2px dashed rgba(16, 185, 129, 0.3);
    transition: all 0.3s;
}
.ticket-qr-card:hover { border-color: #10b981; transform: translateY(-2px); }
.ticket-qr-card.used {
    background: rgba(239, 68, 68, 0.05);
    border-color: rgba(239, 68, 68, 0.3);
    opacity: 0.7;
}
.qr-container { background: white; padding: 8px; border-radius: 8px; display: inline-block; }
</style>

<div id="confettiContainer"></div>

<div class="container py-5" style="max-width: 850px;">
    <!-- Progress Steps -->
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

    <c:choose>
        <c:when test="${not empty order}">
            <div class="glass-strong p-5 rounded-4 text-center animate-fadeInUp">
                <!-- Success Icon -->
                <div class="success-icon rounded-circle d-flex align-items-center justify-content-center mx-auto mb-4" style="width: 120px; height: 120px; background: linear-gradient(135deg, #10b981, #06b6d4);">
                    <svg width="60" height="60" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                        <polyline class="success-check" points="20 6 9 17 4 12"></polyline>
                    </svg>
                </div>

                <h1 class="display-5 fw-bold mb-3 animate-fadeInUp stagger-2">Đặt vé thành công!</h1>
                <p class="text-muted lead mb-5 animate-fadeInUp stagger-3">
                    Mã QR bên dưới chính là vé điện tử của bạn. Xuất trình khi check-in tại sự kiện! <i class="fas fa-gift text-primary"></i>
                </p>

                <!-- Order Info Card -->
                <div class="glass p-4 rounded-4 text-start mb-4 animate-on-scroll">
                    <div class="d-flex align-items-center justify-content-between mb-4 pb-4 border-bottom">
                        <span class="text-muted">Mã đơn hàng</span>
                        <div class="d-flex align-items-center gap-2">
                            <span class="font-monospace fw-bold fs-5 text-primary" id="orderCodeDisplay">${order.orderCode}</span>
                            <button class="btn btn-sm glass rounded-3" onclick="copyCode('${order.orderCode}')" title="Sao chép">
                                <i class="fas fa-copy"></i>
                            </button>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-sm-6">
                            <small class="text-muted">Người mua</small>
                            <p class="fw-medium mb-1">${order.buyerName}</p>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted">Email</small>
                            <p class="fw-medium mb-1">${order.buyerEmail}</p>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-6">
                            <small class="text-muted">Phương thức thanh toán</small>
                            <p class="fw-medium mb-1">
                                <c:choose>
                                    <c:when test="${order.paymentMethod == 'seepay'}"><i class="fas fa-qrcode text-primary me-1"></i>SeePay</c:when>
                                    <c:when test="${order.paymentMethod == 'bank_transfer'}"><i class="fas fa-university text-info me-1"></i>Chuyển khoản</c:when>
                                    <c:otherwise><i class="fas fa-money-bill-wave text-success me-1"></i>${order.paymentMethod}</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted">Trạng thái</small>
                            <p class="mb-1">
                                <c:choose>
                                    <c:when test="${order.status == 'paid'}"><span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;"><i class="fas fa-check-circle me-1"></i>Đã thanh toán</span></c:when>
                                    <c:when test="${order.status == 'pending'}"><span class="badge bg-warning text-dark rounded-pill px-3 py-2"><i class="fas fa-clock me-1"></i>Chờ thanh toán</span>
                                        <a href="${pageContext.request.contextPath}/resume-payment?orderId=${order.orderId}" class="btn btn-sm rounded-pill px-3 ms-2" style="background:linear-gradient(135deg,#f59e0b,#d97706);color:white;border:none;"><i class="fas fa-credit-card me-1"></i>Thanh toán ngay</a>
                                    </c:when>
                                    <c:otherwise><span class="badge bg-secondary rounded-pill px-3 py-2">${order.status}</span></c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>

                    <c:if test="${not empty order.items}">
                        <div class="pt-3 border-top">
                            <c:forEach var="item" items="${order.items}">
                                <div class="d-flex justify-content-between small mb-2">
                                    <span class="text-muted">${item.ticketTypeName} x ${item.quantity}</span>
                                    <span><fmt:formatNumber value="${item.subtotal}" type="number" groupingUsed="true"/>đ</span>
                                </div>
                            </c:forEach>
                            <div class="d-flex justify-content-between fw-bold fs-5 mt-3 pt-3 border-top" style="border-style: dashed !important;">
                                <span>Tổng cộng</span>
                                <span class="text-primary"><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/>đ</span>
                            </div>
                        </div>
                    </c:if>
                </div>

                <!-- ========== ISSUED TICKETS WITH QR CODES ========== -->
                <c:if test="${not empty tickets}">
                    <div class="text-start mb-5 animate-on-scroll">
                        <h4 class="fw-bold mb-3"><i class="fas fa-qrcode text-primary me-2"></i>Vé điện tử của bạn (${tickets.size()} vé)</h4>
                        <p class="text-muted small mb-4">
                            <i class="fas fa-shield-alt text-success me-1"></i>
                            Mỗi vé có mã QR được ký số JWT — không thể giả mạo. Xuất trình QR khi vào cửa.
                        </p>
                        <div class="row g-3">
                            <c:forEach var="ticket" items="${tickets}" varStatus="tloop">
                                <div class="col-md-6">
                                    <div class="ticket-qr-card ${ticket.checkedIn ? 'used' : ''} rounded-4 p-4 text-center">
                                        <div class="d-flex justify-content-between align-items-start mb-3">
                                            <div class="text-start">
                                                <span class="font-monospace fw-bold small">${ticket.ticketCode}</span>
                                                <br><small class="text-muted">${ticket.ticketTypeName}</small>
                                            </div>
                                            <c:choose>
                                                <c:when test="${ticket.checkedIn}">
                                                    <span class="badge bg-danger rounded-pill px-2 py-1">
                                                        <i class="fas fa-times-circle me-1"></i>Đã sử dụng
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge rounded-pill px-2 py-1" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">
                                                        <i class="fas fa-check-circle me-1"></i>Còn hiệu lực
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <!-- QR Code generated from JWT token -->
                                        <div class="qr-container mb-3">
                                            <c:url var="qrUrl" value="https://api.qrserver.com/v1/create-qr-code/">
                                                <c:param name="size" value="180x180"/>
                                                <c:param name="data" value="${ticket.qrCode}"/>
                                            </c:url>
                                            <img src="${qrUrl}"
                                                 alt="QR Vé ${ticket.ticketCode}" width="180" height="180"
                                                 style="${ticket.checkedIn ? 'filter: grayscale(100%) opacity(0.5);' : ''}">
                                        </div>

                                        <c:if test="${ticket.checkedIn}">
                                            <div class="text-center">
                                                <small class="text-danger">
                                                    <i class="fas fa-clock me-1"></i>
                                                    Check-in: <fmt:formatDate value="${ticket.checkedInAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </small>
                                            </div>
                                        </c:if>

                                        <div class="mt-2">
                                            <small class="text-muted">${ticket.attendeeName}</small>
                                        </div>

                                        <c:if test="${!ticket.checkedIn}">
                                            <button class="btn btn-sm glass rounded-pill px-3 mt-2" onclick="downloadTicketQR('${ticket.ticketCode}')">
                                                <i class="fas fa-download me-1 text-primary"></i>Tải vé
                                            </button>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <!-- Action Buttons -->
                <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center animate-on-scroll">
                    <a href="${pageContext.request.contextPath}/my-tickets" class="btn btn-lg btn-gradient rounded-pill px-5 py-3 hover-glow">
                        <i class="fas fa-ticket-alt me-2"></i> Vé của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/events" class="btn btn-lg glass rounded-pill px-5 py-3 hover-lift">
                        <i class="fas fa-search me-2"></i> Khám phá thêm
                    </a>
                    <a href="${pageContext.request.contextPath}/support/new?orderId=${order.orderId}" class="btn btn-lg btn-outline-warning rounded-pill px-4 py-3 hover-lift">
                        <i class="fas fa-flag me-2"></i> Báo cáo vấn đề
                    </a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="glass-strong p-5 rounded-4 text-center animate-fadeInUp">
                <div class="mb-4">
                    <i class="fas fa-exclamation-triangle fa-4x text-warning"></i>
                </div>
                <h3 class="fw-bold mb-3">Không tìm thấy đơn hàng</h3>
                <p class="text-muted mb-4">Đơn hàng không tồn tại hoặc bạn không có quyền xem.</p>
                <a href="${pageContext.request.contextPath}/events" class="btn btn-gradient rounded-pill px-4">
                    <i class="fas fa-home me-2"></i>Về trang chủ
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
function createConfetti() {
    const container = document.getElementById('confettiContainer');
    const colors = ['#ec4899', '#8b5cf6', '#06b6d4', '#10b981', '#f59e0b'];
    for (let i = 0; i < 50; i++) {
        setTimeout(() => {
            const c = document.createElement('div');
            c.className = 'confetti';
            c.style.left = Math.random() * 100 + 'vw';
            c.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
            c.style.animationDuration = (Math.random() * 2 + 2) + 's';
            c.style.animationDelay = Math.random() * 0.5 + 's';
            container.appendChild(c);
            setTimeout(() => c.remove(), 3500);
        }, i * 50);
    }
}

function copyCode(code) {
    navigator.clipboard.writeText(code);
    const btn = event.target.closest('button');
    btn.innerHTML = '<i class="fas fa-check text-success"></i>';
    setTimeout(() => btn.innerHTML = '<i class="fas fa-copy"></i>', 2000);
}

function downloadTicketQR(ticketCode) {
    // Find the QR image src from the DOM by ticket code
    var qrImgs = document.querySelectorAll('img[alt="QR Vé ' + ticketCode + '"]');
    if (!qrImgs.length) return;
    var canvas = document.createElement('canvas');
    var ctx = canvas.getContext('2d');
    var img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = function() {
        var w = 400, h = 480;
        canvas.width = w; canvas.height = h;
        ctx.fillStyle = '#fff';
        ctx.beginPath(); ctx.roundRect(0, 0, w, h, 16); ctx.fill();
        var grad = ctx.createLinearGradient(0, 0, w, 60);
        grad.addColorStop(0, '#10b981'); grad.addColorStop(1, '#06b6d4');
        ctx.fillStyle = grad;
        ctx.beginPath(); ctx.roundRect(0, 0, w, 60, [16, 16, 0, 0]); ctx.fill();
        ctx.fillStyle = '#fff'; ctx.font = 'bold 18px sans-serif';
        ctx.fillText('VÉ ĐIỆN TỬ', 20, 38);
        ctx.font = '12px monospace'; ctx.fillText(ticketCode, w - ctx.measureText(ticketCode).width - 20, 38);
        ctx.drawImage(img, 80, 80, 240, 240);
        ctx.fillStyle = '#1f2937'; ctx.font = 'bold 16px monospace';
        ctx.fillText(ticketCode, (w - ctx.measureText(ticketCode).width) / 2, 345);
        ctx.strokeStyle = '#e5e7eb'; ctx.setLineDash([5, 5]);
        ctx.beginPath(); ctx.moveTo(20, 370); ctx.lineTo(w - 20, 370); ctx.stroke();
        ctx.setLineDash([]); ctx.fillStyle = '#6b7280'; ctx.font = '11px sans-serif';
        var t1 = 'Xuất trình QR khi check-in tại sự kiện';
        ctx.fillText(t1, (w - ctx.measureText(t1).width) / 2, 400);
        ctx.fillStyle = '#10b981'; ctx.font = 'bold 12px sans-serif';
        var t2 = 'Vé điện tử • Chống giả mạo';
        ctx.fillText(t2, (w - ctx.measureText(t2).width) / 2, 420);
        var a = document.createElement('a');
        a.download = 'ticket-' + ticketCode + '.png'; a.href = canvas.toDataURL('image/png'); a.click();
    };
    img.src = qrImgs[0].src.replace('180x180', '300x300');
}

document.addEventListener('DOMContentLoaded', createConfetti);
</script>

<jsp:include page="footer.jsp" />
