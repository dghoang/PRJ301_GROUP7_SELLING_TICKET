<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<style>
@keyframes pulse-glow { 0%, 100% { box-shadow: 0 0 20px rgba(16,185,129,0.3); } 50% { box-shadow: 0 0 40px rgba(16,185,129,0.6); } }
@keyframes spin-slow { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
.qr-pulse { animation: pulse-glow 2s infinite; }
.status-spinner { animation: spin-slow 2s linear infinite; }
.bank-info-item { background: rgba(147,51,234,0.04); border: 1px solid rgba(147,51,234,0.1); transition: all 0.2s; }
.bank-info-item:hover { border-color: rgba(147,51,234,0.25); }
.copy-btn { cursor: pointer; transition: all 0.2s; }
.copy-btn:hover { color: var(--primary) !important; }
</style>

<div class="container py-5" style="max-width: 700px;">
    <!-- Progress Steps -->
    <div class="mb-5 animate-fadeInDown">
        <div class="d-flex align-items-center justify-content-center gap-2 gap-md-4 flex-wrap">
            <div class="d-flex align-items-center gap-2">
                <span class="badge rounded-circle d-flex align-items-center justify-content-center" style="width:32px;height:32px;background:linear-gradient(135deg,#10b981,#06b6d4);"><i class="fas fa-check text-white" style="font-size:12px;"></i></span>
                <span class="fw-medium text-success d-none d-sm-inline">Chọn vé</span>
            </div>
            <div class="flex-grow-1 border-top border-2 border-success" style="max-width:80px;"></div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge rounded-circle d-flex align-items-center justify-content-center text-white" style="width:32px;height:32px;background:linear-gradient(135deg,var(--primary),var(--secondary));">
                    <i class="fas fa-spinner status-spinner" style="font-size:12px;" id="stepIcon"></i>
                </span>
                <span class="fw-bold d-none d-sm-inline">Thanh toán</span>
            </div>
            <div class="flex-grow-1 border-top border-2" style="max-width:80px;border-color:#e5e7eb !important;"></div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge rounded-circle d-flex align-items-center justify-content-center bg-light text-muted" style="width:32px;height:32px;">3</span>
                <span class="text-muted d-none d-sm-inline">Hoàn tất</span>
            </div>
        </div>
    </div>

    <div class="glass-strong rounded-4 p-4 p-md-5 text-center animate-fadeInUp">
        <!-- Header -->
        <div class="mb-4">
            <div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width:80px;height:80px;background:linear-gradient(135deg,rgba(147,51,234,0.1),rgba(219,39,119,0.1));">
                <i class="fas fa-qrcode fa-2x text-primary"></i>
            </div>
            <h3 class="fw-bold mb-2">Quét mã QR để thanh toán</h3>
            <p class="text-muted mb-0">Mở app ngân hàng → Quét QR → Xác nhận chuyển khoản</p>
        </div>

        <!-- QR Code -->
        <div class="qr-pulse rounded-4 p-3 d-inline-block mb-4" style="background: white;">
            <img src="${paymentResult.qrCodeUrl}" alt="QR Thanh toán" style="width:280px;height:280px;" id="qrImage">
        </div>

        <!-- Bank Transfer Info -->
        <div class="text-start mb-4" style="max-width:460px;margin:0 auto;">
            <h6 class="fw-bold mb-3"><i class="fas fa-university text-primary me-2"></i>Thông tin chuyển khoản</h6>

            <div class="bank-info-item rounded-3 p-3 mb-2 d-flex justify-content-between align-items-center">
                <div><small class="text-muted d-block">Ngân hàng</small><span class="fw-bold">${bankName}</span></div>
            </div>
            <div class="bank-info-item rounded-3 p-3 mb-2 d-flex justify-content-between align-items-center">
                <div><small class="text-muted d-block">Số tài khoản</small><span class="fw-bold font-monospace" id="accountNo">${accountNo}</span></div>
                <i class="fas fa-copy text-muted copy-btn" onclick="copyText('${accountNo}', this)"></i>
            </div>
            <div class="bank-info-item rounded-3 p-3 mb-2 d-flex justify-content-between align-items-center">
                <div><small class="text-muted d-block">Chủ tài khoản</small><span class="fw-bold">${accountName}</span></div>
            </div>
            <div class="bank-info-item rounded-3 p-3 mb-2 d-flex justify-content-between align-items-center" style="background:rgba(16,185,129,0.06);border-color:rgba(16,185,129,0.2);">
                <div><small class="text-muted d-block">Số tiền</small><span class="fw-bold fs-5 text-success"><fmt:formatNumber value="${order.finalAmount}" pattern="#,###"/> VNĐ</span></div>
            </div>
            <div class="bank-info-item rounded-3 p-3 mb-2 d-flex justify-content-between align-items-center" style="background:rgba(239,68,68,0.04);border-color:rgba(239,68,68,0.15);">
                <div>
                    <small class="text-muted d-block">Nội dung chuyển khoản <span class="text-danger">(BẮT BUỘC)</span></small>
                    <span class="fw-bold font-monospace text-danger" id="orderCode">${order.orderCode}</span>
                </div>
                <i class="fas fa-copy text-muted copy-btn" onclick="copyText('${order.orderCode}', this)"></i>
            </div>
        </div>

        <!-- Countdown -->
        <div class="glass rounded-4 p-3 mb-4 d-inline-flex align-items-center gap-3" style="min-width:300px;">
            <i class="fas fa-clock text-warning"></i>
            <div class="text-start">
                <small class="text-muted d-block">Thời gian còn lại</small>
                <span class="fw-bold fs-5" id="countdown">${timeoutMinutes}:00</span>
            </div>
            <div class="ms-auto">
                <span class="badge rounded-pill px-3 py-2" id="statusBadge" style="background:linear-gradient(135deg,#f59e0b,#d97706);color:white;">
                    <i class="fas fa-spinner fa-spin me-1"></i>Chờ thanh toán
                </span>
            </div>
        </div>

        <!-- Manual Confirm Button -->
        <div class="mb-4" id="testConfirmBox">
            <button type="button" class="btn btn-lg px-5 py-3 rounded-4 fw-bold hover-glow" id="testConfirmBtn"
                    style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;border:none;"
                    onclick="manualConfirm()">
                <i class="fas fa-check-circle me-2"></i>Tôi đã thanh toán
            </button>
            <div class="mt-2">
                <small class="text-muted"><i class="fas fa-info-circle me-1"></i>Nhấn nút này sau khi bạn đã chuyển khoản thành công</small>
            </div>
        </div>

        <!-- Warning -->
        <div class="alert alert-warning rounded-3 text-start small mb-0" style="max-width:460px;margin:0 auto;">
            <i class="fas fa-exclamation-triangle me-2"></i>
            <strong>Lưu ý:</strong> Nhập chính xác nội dung chuyển khoản <code>${order.orderCode}</code> để hệ thống tự động xác nhận. Đơn hàng sẽ bị huỷ nếu không thanh toán trong thời gian quy định.
        </div>
    </div>
</div>

<script>
var orderId = ${order.orderId};
var timeoutMinutes = ${timeoutMinutes};
var totalSeconds = timeoutMinutes * 60;
var pollInterval;

// Countdown timer
var countdownEl = document.getElementById('countdown');
var timer = setInterval(function() {
    totalSeconds--;
    if (totalSeconds <= 0) {
        clearInterval(timer);
        clearInterval(pollInterval);
        countdownEl.textContent = '0:00';
        document.getElementById('statusBadge').innerHTML = '<i class="fas fa-times-circle me-1"></i>Hết hạn';
        document.getElementById('statusBadge').style.background = 'linear-gradient(135deg,#ef4444,#dc2626)';
        return;
    }
    var m = Math.floor(totalSeconds / 60);
    var s = totalSeconds % 60;
    countdownEl.textContent = m + ':' + (s < 10 ? '0' : '') + s;
}, 1000);

// Poll payment status every 3 seconds
pollInterval = setInterval(function() {
    fetch('${pageContext.request.contextPath}/api/payment/status?orderId=' + orderId)
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (data.status === 'paid') {
                clearInterval(timer);
                clearInterval(pollInterval);
                document.getElementById('statusBadge').innerHTML = '<i class="fas fa-check-circle me-1"></i>Đã thanh toán!';
                document.getElementById('statusBadge').style.background = 'linear-gradient(135deg,#10b981,#06b6d4)';
                document.getElementById('stepIcon').className = 'fas fa-check';
                document.getElementById('stepIcon').style.animation = 'none';
                setTimeout(function() {
                    window.location.href = '${pageContext.request.contextPath}/order-confirmation?id=' + orderId;
                }, 1500);
            }
        })
        .catch(function() {});
}, 3000);

function copyText(text, btn) {
    navigator.clipboard.writeText(text);
    btn.className = 'fas fa-check text-success copy-btn';
    setTimeout(function() { btn.className = 'fas fa-copy text-muted copy-btn'; }, 2000);
}

// Manual payment confirmation with detailed error handling
function manualConfirm() {
    var btn = document.getElementById('testConfirmBtn');
    var smallEl = document.getElementById('testConfirmBox').querySelector('small');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Đang xác nhận...';
    smallEl.textContent = 'Đang kết nối hệ thống thanh toán...';
    smallEl.className = 'text-muted';

    fetch('${pageContext.request.contextPath}/api/payment/status?orderId=' + orderId, {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'orderId=' + orderId
    })
    .then(function(res) {
        if (!res.ok && res.status === 401) {
            // Session expired — redirect to login
            window.location.href = '${pageContext.request.contextPath}/login?returnUrl=' +
                encodeURIComponent('/payment-pending?orderId=' + orderId);
            return null;
        }
        return res.json();
    })
    .then(function(data) {
        if (!data) return; // Redirecting to login

        if (data.status === 'paid') {
            clearInterval(timer);
            clearInterval(pollInterval);
            document.getElementById('statusBadge').innerHTML = '<i class="fas fa-check-circle me-1"></i>Đã thanh toán!';
            document.getElementById('statusBadge').style.background = 'linear-gradient(135deg,#10b981,#06b6d4)';
            document.getElementById('stepIcon').className = 'fas fa-check';
            document.getElementById('stepIcon').style.animation = 'none';
            btn.innerHTML = '<i class="fas fa-check-circle me-2"></i>Thành công!';
            btn.style.background = 'linear-gradient(135deg,#10b981,#059669)';
            smallEl.textContent = data.message || 'Đang chuyển đến trang xác nhận...';
            smallEl.className = 'text-success';
            setTimeout(function() {
                window.location.href = '${pageContext.request.contextPath}/order-confirmation?id=' + orderId;
            }, 1500);
        } else {
            // Show error message from server
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-redo me-2"></i>Thử lại';
            btn.style.background = 'linear-gradient(135deg,#ef4444,#dc2626)';
            smallEl.textContent = data.message || 'Xác nhận thất bại. Vui lòng thử lại.';
            smallEl.className = 'text-danger';
            // Reset button style after 3s
            setTimeout(function() {
                btn.style.background = 'linear-gradient(135deg,#10b981,#06b6d4)';
                smallEl.textContent = 'Nhấn nút này sau khi bạn đã chuyển khoản thành công';
                smallEl.className = 'text-muted';
            }, 4000);
        }
    })
    .catch(function(err) {
        console.error('Payment confirm error:', err);
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-exclamation-triangle me-2"></i>Lỗi kết nối';
        btn.style.background = 'linear-gradient(135deg,#f59e0b,#d97706)';
        smallEl.textContent = 'Không thể kết nối máy chủ. Kiểm tra kết nối mạng và thử lại.';
        smallEl.className = 'text-warning';
        setTimeout(function() {
            btn.innerHTML = '<i class="fas fa-check-circle me-2"></i>Tôi đã thanh toán';
            btn.style.background = 'linear-gradient(135deg,#10b981,#06b6d4)';
            smallEl.textContent = 'Nhấn nút này sau khi bạn đã chuyển khoản thành công';
            smallEl.className = 'text-muted';
        }, 4000);
    });
}
</script>

<jsp:include page="footer.jsp" />
