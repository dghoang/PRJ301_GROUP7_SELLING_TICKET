<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>
<c:set var="pageTitle" value="Vé của tôi" scope="request" />
<%@include file="header.jsp" %>

<style>
.order-card { transition: all 0.3s; cursor: pointer; }
.order-card:hover { transform: translateY(-2px); }
.order-card.expanded { border-color: var(--primary) !important; }
.ticket-grid { display: none; }
.ticket-grid.show { display: flex; }
.ticket-qr-card {
    background: linear-gradient(135deg, rgba(16,185,129,0.04), rgba(6,182,212,0.04));
    border: 2px dashed rgba(16,185,129,0.25);
    transition: all 0.3s;
}
.ticket-qr-card:hover { border-color: #10b981; transform: translateY(-3px); box-shadow: 0 8px 25px rgba(16,185,129,0.15); }
.ticket-qr-card.used { background: rgba(239,68,68,0.04); border-color: rgba(239,68,68,0.2); opacity: 0.7; }
.qr-box { background: white; padding: 10px; border-radius: 12px; display: inline-block; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.status-pulse { animation: statusPulse 2s infinite; }
@keyframes statusPulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.6; } }
.download-btn { transition: all 0.2s; }
.download-btn:hover { transform: scale(1.05); }
.expand-icon { transition: transform 0.3s; }
.expanded .expand-icon { transform: rotate(180deg); }
</style>

<div class="container py-5">
    <%-- Page Header --%>
    <%-- Flash Error from ResumePaymentServlet --%>
    <c:if test="${not empty sessionScope.flashError}">
        <div class="alert alert-danger rounded-4 mb-4 d-flex align-items-center gap-2 animate-fadeInDown">
            <i class="fas fa-exclamation-triangle"></i>
            <span>${sessionScope.flashError}</span>
        </div>
        <c:remove var="flashError" scope="session"/>
    </c:if>

    <div class="glass-gradient rounded-4 p-4 mb-4 position-relative overflow-hidden animate-fadeInDown">
        <div class="row align-items-center">
            <div class="col-md-8">
                <h2 class="fw-bold mb-1"><i class="fas fa-ticket-alt me-2"></i>Vé của tôi</h2>
                <p class="text-muted mb-0">Quản lý đơn hàng & vé điện tử • Nhấn vào đơn hàng để xem QR</p>
            </div>
            <div class="col-md-4 text-end d-none d-md-block">
                <a href="${pageContext.request.contextPath}/events" class="btn btn-gradient rounded-pill px-4 hover-glow">
                    <i class="fas fa-search me-2"></i>Khám phá sự kiện
                </a>
            </div>
        </div>
    </div>

    <%-- Filter Tabs --%>
    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
        <div class="card-body p-3 d-flex flex-wrap gap-3 align-items-center">
            <div data-pill-group="checkedIn" class="d-flex gap-2">
                <a class="nav-link nav-tabs-glass-item active rounded-pill px-3 py-2" href="#" data-pill-value="">
                    <i class="fas fa-list me-1"></i>Tất cả
                </a>
                <a class="nav-link nav-tabs-glass-item rounded-pill px-3 py-2" href="#" data-pill-value="false">
                    <i class="fas fa-ticket-alt me-1"></i>Chưa check-in
                </a>
                <a class="nav-link nav-tabs-glass-item rounded-pill px-3 py-2" href="#" data-pill-value="true">
                    <i class="fas fa-door-open me-1"></i>Đã check-in
                </a>
            </div>
            <div class="input-group ms-auto" style="max-width: 280px;">
                <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                <input type="text" id="myTicketSearch" class="form-control glass border-0" placeholder="Tìm sự kiện, mã vé...">
            </div>
        </div>
    </div>

    <%-- Pagination --%>
    <div id="myTicketsPagination" class="d-flex justify-content-center mt-4"></div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/ajax-cards.js"></script>
<script>
(function() {
    var ctxPath = '${pageContext.request.contextPath}';

    function esc(v) { if (!v) return ''; var d = document.createElement('div'); d.textContent = v; return d.innerHTML; }
    function fmtDate(s) {
        if (!s) return '';
        var d = new Date(s), p = function(n){return String(n).padStart(2,'0');};
        return p(d.getDate())+'/'+p(d.getMonth()+1)+'/'+d.getFullYear()+' '+p(d.getHours())+':'+p(d.getMinutes());
    }

    function statusBadge(ticket) {
        if (ticket.isCheckedIn) return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#8b5cf6,#6366f1);color:white;"><i class="fas fa-door-open me-1"></i>Đã check-in</span>';
        return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;"><i class="fas fa-check-circle me-1"></i>Hiệu lực</span>';
    }

    function statusIcon(ticket) {
        if (ticket.isCheckedIn) return {gradient: '#8b5cf6,#6366f1', icon: 'fa-door-open'};
        return {gradient: '#10b981,#06b6d4', icon: 'fa-check-circle'};
    }

    var myTickets = new AjaxCards({
        apiUrl: ctxPath + '/api/my-tickets',
        container: '#myTicketsContainer',
        paginationContainer: '#myTicketsPagination',
        searchInput: '#myTicketSearch',
        pageSize: 10,
        skeletonCount: 3,
        skeletonHtml: '<div class="card glass-strong border-0 rounded-4 mb-3 skeleton-card" style="height:120px;"><div class="skeleton-body p-4"><div class="skeleton-line w-50"></div><div class="skeleton-line w-75"></div><div class="skeleton-line w-25"></div></div></div>',
        renderEmpty: function() {
            return '<div class="card glass-strong border-0 rounded-4">' +
                '<div class="card-body p-5 text-center">' +
                '<div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-4" style="width:100px;height:100px;background:linear-gradient(135deg,rgba(59,130,246,0.1),rgba(99,102,241,0.1));">' +
                '<i class="fas fa-ticket-alt fa-3x" style="background:linear-gradient(135deg,#3b82f6,#6366f1);-webkit-background-clip:text;-webkit-text-fill-color:transparent;"></i></div>' +
                '<h4 class="fw-bold">Chưa có vé nào</h4>' +
                '<p class="text-muted mb-4">Bạn chưa mua vé nào. Hãy khám phá các sự kiện hấp dẫn!</p>' +
                '<a href="' + ctxPath + '/events" class="btn btn-gradient rounded-pill px-4 hover-glow"><i class="fas fa-search me-2"></i>Khám phá sự kiện</a>' +
                '</div></div>';
        },
        renderCard: function(t) {
            var si = statusIcon(t);
            var ticketId = 'ticket_' + t.ticketId;
            var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=' + encodeURIComponent(t.qrCode || '');

            var card = '<div class="card glass-strong border-0 rounded-4 order-card animate-on-scroll" id="' + ticketId + '" style="border:2px solid transparent !important;">';

            // Header row (clickable to expand)
            card += '<div class="card-body p-4" onclick="toggleTicket(\'' + ticketId + '\')" style="cursor:pointer">';
            card += '<div class="row align-items-center">';
            card += '<div class="col-md-5"><div class="d-flex align-items-center gap-3">';
            card += '<div class="rounded-3 d-flex align-items-center justify-content-center flex-shrink-0" style="width:52px;height:52px;background:linear-gradient(135deg,' + si.gradient + ');">';
            card += '<i class="fas ' + si.icon + ' text-white fa-lg"></i></div>';
            card += '<div class="min-w-0"><h6 class="fw-bold mb-1 text-truncate">' + esc(t.eventTitle) + '</h6>';
            card += '<div class="d-flex align-items-center gap-2 flex-wrap">';
            card += '<span class="text-muted small font-monospace">' + esc(t.ticketCode) + '</span>';
            card += '<span class="text-muted small">&bull;</span>';
            card += '<span class="text-muted small">' + esc(t.ticketTypeName) + '</span>';
            card += '</div></div></div></div>';

            card += '<div class="col-md-3 text-md-center mt-3 mt-md-0">' + statusBadge(t) + '</div>';

            card += '<div class="col-md-4 text-md-end mt-3 mt-md-0">';
            card += '<div class="d-flex align-items-center justify-content-md-end gap-3">';
            card += '<span class="text-muted small"><i class="fas fa-clock me-1"></i>' + fmtDate(t.createdAt) + '</span>';
            card += '<i class="fas fa-chevron-down expand-icon text-muted"></i>';
            card += '</div></div>';
            card += '</div></div>';

            // Expandable detail
            card += '<div class="ticket-grid flex-column" id="ticketDetail_' + ticketId + '">';
            card += '<div class="px-4 pb-4"><div class="border-top pt-4">';

            // QR section
            card += '<div class="d-flex align-items-center justify-content-between mb-3">';
            card += '<h6 class="fw-bold mb-0"><i class="fas fa-qrcode text-primary me-2"></i>Vé điện tử</h6>';
            card += '<small class="text-muted"><i class="fas fa-shield-alt text-success me-1"></i>Vé chống giả mạo</small></div>';

            card += '<div class="row g-3"><div class="col-sm-6 col-lg-4">';
            card += '<div class="ticket-qr-card ' + (t.isCheckedIn ? 'used' : '') + ' rounded-4 p-3 text-center h-100">';
            card += '<div class="d-flex justify-content-between align-items-start mb-2">';
            card += '<div class="text-start"><span class="font-monospace fw-bold small">' + esc(t.ticketCode) + '</span><br><small class="text-muted">' + esc(t.ticketTypeName) + '</small></div>';
            card += t.isCheckedIn
                ? '<span class="badge bg-danger rounded-pill" style="font-size:10px;">ĐÃ DÙNG</span>'
                : '<span class="badge rounded-pill" style="font-size:10px;background:linear-gradient(135deg,#10b981,#06b6d4);color:white;">HIỆU LỰC</span>';
            card += '</div>';
            card += '<div class="qr-box mb-2"><img src="' + qrUrl + '" alt="QR ' + esc(t.ticketCode) + '" width="160" height="160"' + (t.isCheckedIn ? ' style="filter:grayscale(100%) opacity(0.5);"' : '') + '></div>';
            card += '<small class="text-muted d-block mb-2">' + esc(t.attendeeName) + '</small>';
            if (!t.isCheckedIn) {
                card += '<button class="btn btn-sm glass rounded-pill px-3 download-btn" onclick="event.stopPropagation();downloadQR(\'' + esc(t.ticketCode) + '\')"><i class="fas fa-download me-1 text-primary"></i>Tải QR</button>';
            }
            if (t.isCheckedIn && t.checkedInAt) {
                card += '<small class="text-danger d-block"><i class="fas fa-clock me-1"></i>' + fmtDate(t.checkedInAt) + '</small>';
            }
            card += '</div></div></div>';

            card += '</div></div></div>';
            card += '</div>';

            return card;
        }
    });
    myTickets.init();

    // Toggle ticket expand/collapse
    window.toggleTicket = function(ticketId) {
        var card = document.getElementById(ticketId);
        var grid = document.getElementById('ticketDetail_' + ticketId);
        if (!card || !grid) return;

        if (grid.classList.contains('show')) {
            grid.classList.remove('show');
            card.classList.remove('expanded');
            card.style.borderColor = 'transparent';
        } else {
            document.querySelectorAll('.ticket-grid.show').forEach(function(g) {
                g.classList.remove('show');
                g.closest('.order-card').classList.remove('expanded');
                g.closest('.order-card').style.borderColor = 'transparent';
            });
            grid.classList.add('show');
            card.classList.add('expanded');
            card.style.borderColor = 'var(--primary)';
            setTimeout(function() { card.scrollIntoView({behavior:'smooth',block:'nearest'}); }, 100);
        }
    };

    // Download QR (reuse existing logic)
    window.downloadQR = function(ticketCode) {
        var qrImgs = document.querySelectorAll('img[alt="QR ' + ticketCode + '"]');
        if (!qrImgs.length) return;
        var canvas = document.createElement('canvas');
        var ctx = canvas.getContext('2d');
        var img = new Image();
        img.crossOrigin = 'anonymous';
        img.onload = function() {
            var w = 400, h = 480;
            canvas.width = w; canvas.height = h;
            ctx.fillStyle = '#ffffff';
            ctx.beginPath(); ctx.roundRect(0,0,w,h,16); ctx.fill();
            var grad = ctx.createLinearGradient(0,0,w,60);
            grad.addColorStop(0,'#10b981'); grad.addColorStop(1,'#06b6d4');
            ctx.fillStyle = grad;
            ctx.beginPath(); ctx.roundRect(0,0,w,60,[16,16,0,0]); ctx.fill();
            ctx.fillStyle = '#ffffff';
            ctx.font = 'bold 18px Inter, sans-serif';
            ctx.fillText('VÉ ĐIỆN TỬ', 20, 38);
            ctx.font = '12px Inter, sans-serif';
            ctx.fillText(ticketCode, w - ctx.measureText(ticketCode).width - 20, 38);
            var qrSize = 240, qrX = (w - qrSize) / 2;
            ctx.drawImage(img, qrX, 80, qrSize, qrSize);
            ctx.fillStyle = '#1f2937';
            ctx.font = 'bold 16px monospace';
            ctx.fillText(ticketCode, (w - ctx.measureText(ticketCode).width) / 2, 345);
            ctx.strokeStyle = '#e5e7eb'; ctx.setLineDash([5,5]);
            ctx.beginPath(); ctx.moveTo(20,370); ctx.lineTo(w-20,370); ctx.stroke();
            ctx.setLineDash([]);
            ctx.fillStyle = '#6b7280'; ctx.font = '11px Inter, sans-serif';
            var t1 = 'Xuất trình mã QR này khi check-in tại sự kiện';
            ctx.fillText(t1, (w-ctx.measureText(t1).width)/2, 400);
            ctx.fillStyle = '#10b981'; ctx.font = 'bold 12px Inter, sans-serif';
            var t2 = 'Vé điện tử • Chống giả mạo';
            ctx.fillText(t2, (w-ctx.measureText(t2).width)/2, 420);
            ctx.fillStyle = '#d1d5db'; ctx.font = '10px Inter, sans-serif';
            ctx.fillText('SellingTicket.vn', (w-ctx.measureText('SellingTicket.vn').width)/2, 460);
            var link = document.createElement('a');
            link.download = 'ticket-' + ticketCode + '.png';
            link.href = canvas.toDataURL('image/png');
            link.click();
        };
        img.src = qrImgs[0].src.replace('160x160','300x300');
    };
})();
</script>

<%@include file="footer.jsp" %>
