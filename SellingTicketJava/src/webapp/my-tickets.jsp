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
/* Stats cards */
.stat-mini-card { transition: all 0.3s; }
.stat-mini-card:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.08); }
.stat-mini-card .stat-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.stat-mini-card .stat-value { font-size: 1.4rem; font-weight: 700; line-height: 1.2; }
.stat-mini-card .stat-label { font-size: 0.75rem; color: #6b7280; }
/* Copy toast */
.copy-toast { position: fixed; bottom: 24px; right: 24px; z-index: 9999; }
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
                <h2 class="fw-bold mb-1"><i class="fas fa-ticket-alt me-2"></i><span data-i18n="mytickets.title">Vé của tôi</span></h2>
                <p class="text-muted mb-0" data-i18n="mytickets.subtitle">Quản lý đơn hàng & vé điện tử • Nhấn vào đơn hàng để xem QR</p>
            </div>
            <div class="col-md-4 text-end d-none d-md-block">
                <a href="${pageContext.request.contextPath}/events" class="btn btn-gradient rounded-pill px-4 hover-glow">
                    <i class="fas fa-search me-2"></i><span data-i18n="mytickets.explore">Khám phá sự kiện</span>
                </a>
            </div>
        </div>
    </div>

    <%-- View Mode Tabs --%>
    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
        <div class="card-body p-3 d-flex flex-wrap gap-3 align-items-center">
            <div class="d-flex gap-2" id="viewModeTabs">
                <a class="nav-link nav-tabs-glass-item active rounded-pill px-3 py-2" href="#" onclick="switchView('tickets', this); return false;">
                    <i class="fas fa-ticket-alt me-1"></i><span data-i18n="mytickets.tab_tickets">Vé của tôi</span>
                </a>
                <a class="nav-link nav-tabs-glass-item rounded-pill px-3 py-2" href="#" onclick="switchView('orders', this); return false;">
                    <i class="fas fa-receipt me-1"></i><span data-i18n="mytickets.tab_orders">Đơn hàng</span>
                </a>
            </div>
        </div>
    </div>

    <%-- ========= TICKETS VIEW ========= --%>
    <div id="ticketsView">
        <%-- Filter Tabs --%>
        <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
            <div class="card-body p-3 d-flex flex-wrap gap-3 align-items-center">
                <div data-pill-group="checkedIn" class="d-flex gap-2">
                    <a class="nav-link nav-tabs-glass-item active rounded-pill px-3 py-2" href="#" data-pill-value="">
                        <i class="fas fa-list me-1"></i><span data-i18n="mytickets.filter_all">Tất cả</span>
                    </a>
                    <a class="nav-link nav-tabs-glass-item rounded-pill px-3 py-2" href="#" data-pill-value="false">
                        <i class="fas fa-ticket-alt me-1"></i><span data-i18n="mytickets.filter_not_checked">Chưa check-in</span>
                    </a>
                    <a class="nav-link nav-tabs-glass-item rounded-pill px-3 py-2" href="#" data-pill-value="true">
                        <i class="fas fa-door-open me-1"></i><span data-i18n="mytickets.filter_checked">Đã check-in</span>
                    </a>
                </div>
                <div class="input-group ms-auto" style="max-width: 280px;">
                    <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                    <input type="text" id="myTicketSearch" class="form-control glass border-0" placeholder="Tìm sự kiện, mã vé..." data-i18n-placeholder="mytickets.search_tickets">
                </div>
            </div>
        </div>
        <%-- Stats Cards (populated by JS after first API load) --%>
        <div class="row g-3 mb-4" id="ticketStatsRow" style="display:none;">
            <div class="col-6 col-md-3">
                <div class="card glass-strong border-0 rounded-4 stat-mini-card h-100">
                    <div class="card-body p-3 d-flex align-items-center gap-3">
                        <div class="stat-icon" style="background:rgba(59,130,246,0.1);"><i class="fas fa-ticket-alt" style="color:#3b82f6;"></i></div>
                        <div><div class="stat-value" id="statTotalTickets">0</div><div class="stat-label">Tổng vé</div></div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card glass-strong border-0 rounded-4 stat-mini-card h-100">
                    <div class="card-body p-3 d-flex align-items-center gap-3">
                        <div class="stat-icon" style="background:rgba(16,185,129,0.1);"><i class="fas fa-check-circle" style="color:#10b981;"></i></div>
                        <div><div class="stat-value" id="statValidTickets">0</div><div class="stat-label">Vé hợp lệ</div></div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card glass-strong border-0 rounded-4 stat-mini-card h-100">
                    <div class="card-body p-3 d-flex align-items-center gap-3">
                        <div class="stat-icon" style="background:rgba(139,92,246,0.1);"><i class="fas fa-door-open" style="color:#8b5cf6;"></i></div>
                        <div><div class="stat-value" id="statCheckedIn">0</div><div class="stat-label">Đã check-in</div></div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card glass-strong border-0 rounded-4 stat-mini-card h-100">
                    <div class="card-body p-3 d-flex align-items-center gap-3">
                        <div class="stat-icon" style="background:rgba(245,158,11,0.1);"><i class="fas fa-clock" style="color:#f59e0b;"></i></div>
                        <div><div class="stat-value" id="statPending">0</div><div class="stat-label">Chờ thanh toán</div></div>
                    </div>
                </div>
            </div>
        </div>
        <div id="myTicketsContainer">
            <div class="text-center py-5 text-muted" id="myTicketsLoading">
                <div class="spinner-border text-primary mb-3" role="status"><span class="visually-hidden">Loading...</span></div>
                <p data-i18n="mytickets.loading_tickets">Đang tải vé...</p>
            </div>
        </div>
        <div id="myTicketsPagination" class="d-flex justify-content-center mt-4"></div>
    </div>

    <%-- ========= ORDERS VIEW ========= --%>
    <div id="ordersView" style="display:none;">
        <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
            <div class="card-body p-3 d-flex flex-wrap gap-3 align-items-center">
                <div data-pill-group="status" class="d-flex gap-2">
                    <a class="nav-link nav-tabs-glass-item active rounded-pill px-3 py-2" href="#" data-pill-value="">
                        <i class="fas fa-list me-1"></i><span data-i18n="mytickets.filter_all">Tất cả</span>
                    </a>
                    <a class="nav-link nav-tabs-glass-item rounded-pill px-3 py-2" href="#" data-pill-value="pending">
                        <i class="fas fa-clock me-1"></i><span data-i18n="mytickets.filter_pending">Chờ thanh toán</span>
                    </a>
                    <a class="nav-link nav-tabs-glass-item rounded-pill px-3 py-2" href="#" data-pill-value="paid">
                        <i class="fas fa-check-circle me-1"></i><span data-i18n="mytickets.filter_paid">Đã thanh toán</span>
                    </a>
                    <a class="nav-link nav-tabs-glass-item rounded-pill px-3 py-2" href="#" data-pill-value="checked_in">
                        <i class="fas fa-door-open me-1"></i><span data-i18n="mytickets.filter_checked_in">Đã check-in</span>
                    </a>
                    <a class="nav-link nav-tabs-glass-item rounded-pill px-3 py-2" href="#" data-pill-value="cancelled">
                        <i class="fas fa-times-circle me-1"></i><span data-i18n="mytickets.filter_cancelled">Đã hủy</span>
                    </a>
                </div>
                <div class="input-group ms-auto" style="max-width: 280px;">
                    <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                    <input type="text" id="myOrderSearch" class="form-control glass border-0" placeholder="Tìm mã đơn, sự kiện..." data-i18n-placeholder="mytickets.search_orders">
                </div>
            </div>
        </div>
        <div id="myOrdersContainer">
            <div class="text-center py-5 text-muted" id="myOrdersLoading">
                <div class="spinner-border text-primary mb-3" role="status"><span class="visually-hidden">Loading...</span></div>
                <p data-i18n="mytickets.loading_orders">Đang tải đơn hàng...</p>
            </div>
        </div>
        <div id="myOrdersPagination" class="d-flex justify-content-center mt-4"></div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/ajax-cards.js?v=20260313_1"></script>
<script>
(function() {
    var ctxPath = '${pageContext.request.contextPath}';

    function esc(v) { if (!v) return ''; var d = document.createElement('div'); d.textContent = v; return d.innerHTML; }
    function fmtDate(s) {
        if (!s) return '';
        var d = new Date(s), p = function(n){return String(n).padStart(2,'0');};
        return p(d.getDate())+'/'+p(d.getMonth()+1)+'/'+d.getFullYear()+' '+p(d.getHours())+':'+p(d.getMinutes());
    }
    function fmtDateShort(s) {
        if (!s) return '';
        var d = new Date(s), p = function(n){return String(n).padStart(2,'0');};
        return p(d.getDate())+'/'+p(d.getMonth()+1)+'/'+d.getFullYear();
    }
    function countdown(s) {
        if (!s) return '';
        var now = new Date(), target = new Date(s);
        var diff = target - now;
        if (diff <= 0) return '<span class="badge rounded-pill" style="background:rgba(107,114,128,0.15);color:#6b7280;font-size:0.7rem;"><i class="fas fa-flag-checkered me-1"></i>Đã diễn ra</span>';
        var days = Math.floor(diff / 86400000);
        if (days > 30) return '<span class="badge rounded-pill" style="background:rgba(59,130,246,0.12);color:#3b82f6;font-size:0.7rem;"><i class="fas fa-calendar me-1"></i>Còn ' + days + ' ngày</span>';
        if (days > 3) return '<span class="badge rounded-pill" style="background:rgba(16,185,129,0.12);color:#10b981;font-size:0.7rem;"><i class="fas fa-hourglass-half me-1"></i>Còn ' + days + ' ngày</span>';
        if (days >= 1) return '<span class="badge rounded-pill status-pulse" style="background:rgba(245,158,11,0.15);color:#d97706;font-size:0.7rem;"><i class="fas fa-fire me-1"></i>Còn ' + days + ' ngày</span>';
        var hours = Math.floor(diff / 3600000);
        return '<span class="badge rounded-pill status-pulse" style="background:rgba(239,68,68,0.15);color:#ef4444;font-size:0.7rem;"><i class="fas fa-bolt me-1"></i>Còn ' + hours + ' giờ</span>';
    }

    function statusBadge(ticket) {
        if (ticket.orderStatus === 'pending') return '<span class="badge rounded-pill px-3 py-2 status-pulse" style="background:linear-gradient(135deg,#f59e0b,#d97706);color:white;"><i class="fas fa-clock me-1"></i>' + i18n.t('mytickets.status_pending') + '</span>';
        if (ticket.isCheckedIn) return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#8b5cf6,#6366f1);color:white;"><i class="fas fa-door-open me-1"></i>' + i18n.t('mytickets.status_checked_in') + '</span>';
        return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;"><i class="fas fa-check-circle me-1"></i>' + i18n.t('mytickets.status_valid') + '</span>';
    }

    function statusIcon(ticket) {
        if (ticket.orderStatus === 'pending') return {gradient: '#f59e0b,#d97706', icon: 'fa-clock'};
        if (ticket.isCheckedIn) return {gradient: '#8b5cf6,#6366f1', icon: 'fa-door-open'};
        return {gradient: '#10b981,#06b6d4', icon: 'fa-check-circle'};
    }

    var myTickets;
    try {
    myTickets = new AjaxCards({
        apiUrl: ctxPath + '/api/my-tickets',
        container: '#myTicketsContainer',
        paginationContainer: '#myTicketsPagination',
        searchInput: '#myTicketSearch',
        filterScope: '#ticketsView',
        pageSize: 10,
        skeletonCount: 3,
        skeletonHtml: '<div class="card glass-strong border-0 rounded-4 mb-3 skeleton-card" style="height:120px;"><div class="skeleton-body p-4"><div class="skeleton-line w-50"></div><div class="skeleton-line w-75"></div><div class="skeleton-line w-25"></div></div></div>',
        renderEmpty: function() {
            return '<div class="card glass-strong border-0 rounded-4">' +
                '<div class="card-body p-5 text-center">' +
                '<div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-4" style="width:100px;height:100px;background:linear-gradient(135deg,rgba(59,130,246,0.1),rgba(99,102,241,0.1));">' +
                '<i class="fas fa-ticket-alt fa-3x" style="background:linear-gradient(135deg,#3b82f6,#6366f1);-webkit-background-clip:text;-webkit-text-fill-color:transparent;"></i></div>' +
                '<h4 class="fw-bold">' + i18n.t('mytickets.no_tickets') + '</h4>' +
                '<p class="text-muted mb-4">' + i18n.t('mytickets.no_tickets_desc') + '</p>' +
                '<a href="' + ctxPath + '/events" class="btn btn-gradient rounded-pill px-4 hover-glow"><i class="fas fa-search me-2"></i>' + i18n.t('mytickets.explore') + '</a>' +
                '</div></div>';
        },
        renderCard: function(t) {
            var si = statusIcon(t);
            var ticketId = 'ticket_' + t.ticketId;
            var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=' + encodeURIComponent(t.qrCode || '');

            var card = '<div class="card glass-strong border-0 rounded-4 order-card" id="' + ticketId + '" style="border:2px solid transparent !important;">';

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
            card += '</div>';
            // Event date & venue info row
            if (t.eventStartDate || t.venue) {
                card += '<div class="d-flex align-items-center gap-2 flex-wrap mt-1">';
                if (t.eventStartDate) card += '<span class="small" style="color:#6b7280;"><i class="fas fa-calendar-day me-1" style="color:#3b82f6;"></i>' + fmtDateShort(t.eventStartDate) + '</span>';
                if (t.venue) card += '<span class="small text-truncate" style="color:#6b7280;max-width:180px;" title="' + esc(t.venue) + '"><i class="fas fa-map-marker-alt me-1" style="color:#ef4444;"></i>' + esc(t.venue) + '</span>';
                card += '</div>';
            }
            card += '</div></div></div>';

            card += '<div class="col-md-3 text-md-center mt-3 mt-md-0">';
            card += statusBadge(t);
            if (t.eventStartDate && !t.isCheckedIn && t.orderStatus !== 'pending') card += '<div class="mt-1">' + countdown(t.eventStartDate) + '</div>';
            card += '</div>';

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
            card += '<h6 class="fw-bold mb-0"><i class="fas fa-qrcode text-primary me-2"></i>' + i18n.t('mytickets.eticket') + '</h6>';
            card += '<small class="text-muted"><i class="fas fa-shield-alt text-success me-1"></i>' + i18n.t('mytickets.anti_fraud') + '</small></div>';

            card += '<div class="row g-3"><div class="col-sm-6 col-lg-4">';
            card += '<div class="ticket-qr-card ' + (t.isCheckedIn ? 'used' : '') + ' rounded-4 p-3 text-center h-100">';
            card += '<div class="d-flex justify-content-between align-items-start mb-2">';
            card += '<div class="text-start"><span class="font-monospace fw-bold small">' + esc(t.ticketCode) + '</span><br><small class="text-muted">' + esc(t.ticketTypeName) + '</small></div>';
            card += t.isCheckedIn
                ? '<span class="badge bg-danger rounded-pill" style="font-size:10px;">' + i18n.t('mytickets.badge_used') + '</span>'
                : (t.orderStatus === 'pending'
                    ? '<span class="badge rounded-pill" style="font-size:10px;background:linear-gradient(135deg,#f59e0b,#d97706);color:white;">' + i18n.t('mytickets.badge_pending') + '</span>'
                    : '<span class="badge rounded-pill" style="font-size:10px;background:linear-gradient(135deg,#10b981,#06b6d4);color:white;">' + i18n.t('mytickets.badge_valid') + '</span>');
            card += '</div>';
            card += '<div class="qr-box mb-2"><img src="' + qrUrl + '" alt="QR ' + esc(t.ticketCode) + '" width="160" height="160"' + (t.isCheckedIn ? ' style="filter:grayscale(100%) opacity(0.5);"' : '') + '></div>';
            card += '<small class="text-muted d-block mb-2">' + esc(t.attendeeName) + '</small>';
            if (!t.isCheckedIn) {
                card += '<div class="d-flex gap-2 justify-content-center flex-wrap">';
                card += '<button class="btn btn-sm glass rounded-pill px-3 download-btn" onclick="event.stopPropagation();downloadQR(\'' + esc(t.ticketCode) + '\')"><i class="fas fa-download me-1 text-primary"></i>' + i18n.t('mytickets.download_qr') + '</button>';
                card += '<button class="btn btn-sm glass rounded-pill px-3 download-btn" onclick="event.stopPropagation();copyTicketCode(\'' + esc(t.ticketCode) + '\')"><i class="fas fa-copy me-1" style="color:#6366f1;"></i>Copy mã</button>';
                card += '</div>';
            }
            if (t.isCheckedIn && t.checkedInAt) {
                card += '<div class="mt-2 px-2 py-1 rounded-3" style="background:rgba(239,68,68,0.08);display:inline-block;">';
                card += '<small style="color:#dc2626;"><i class="fas fa-check-double me-1"></i>Check-in lúc ' + fmtDate(t.checkedInAt) + '</small>';
                card += '</div>';
            }
            card += '</div></div></div>';

            // Chat with event organizer button + Resume payment for pending orders
            card += '<div class="px-4 pb-3 d-flex flex-wrap gap-2">';
            if (t.orderStatus === 'pending') {
                card += '<a href="' + ctxPath + '/resume-payment?orderId=' + (t.orderId || '') + '" class="btn btn-sm rounded-pill px-3" onclick="event.stopPropagation();" style="background:linear-gradient(135deg,#f59e0b,#d97706);color:white;border:none;"><i class="fas fa-credit-card me-2"></i>' + i18n.t('mytickets.pay_now') + '</a>';
            }
            if (t.eventId) {
                card += '<button class="btn btn-sm rounded-pill px-3" onclick="event.stopPropagation();if(typeof openEventChat===\'function\')openEventChat('+t.eventId+',\''+esc(t.eventTitle).replace(/'/g,"\\'")+'\');else alert(i18n.t(\'mytickets.reload_page\'));" style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;border:none;"><i class="fas fa-comments me-2"></i>' + i18n.t('mytickets.chat_support') + '</button>';
            }
            card += '</div>';

            card += '</div></div></div>';
            card += '</div>';

            return card;
        }
    });
        myTickets.init();
        // Populate stats after first successful data load
        var origOnData = myTickets.onDataLoaded;
        myTickets.onDataLoaded = function(data) {
            if (origOnData) origOnData(data);
            updateTicketStats(data);
        };
    } catch(e) {
        console.error('MyTickets init error:', e);
        document.getElementById('myTicketsContainer').innerHTML =
            '<div class="alert alert-danger rounded-4 m-3"><i class="fas fa-exclamation-triangle me-2"></i>' + i18n.t('mytickets.error_init_tickets') + ': ' + e.message + '</div>';
    }

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

    // Copy ticket code
    window.copyTicketCode = function(code) {
        navigator.clipboard.writeText(code).then(function() {
            var toast = document.createElement('div');
            toast.className = 'copy-toast animate-fadeInDown';
            toast.innerHTML = '<div class="alert alert-success rounded-pill py-2 px-4 shadow d-flex align-items-center gap-2 mb-0"><i class="fas fa-check-circle"></i>Đã copy mã <strong>' + code + '</strong></div>';
            document.body.appendChild(toast);
            setTimeout(function() { toast.remove(); }, 2500);
        });
    };

    // Update stats from API response
    function updateTicketStats(data) {
        if (!data || !data.totalCount) return;
        var row = document.getElementById('ticketStatsRow');
        if (row) row.style.display = '';
        var total = data.totalCount || 0;
        var items = data.items || data.data || [];
        // Count from full totalCount (server-side), approximate from page data
        document.getElementById('statTotalTickets').textContent = total;
        // For detailed stats, count from loaded items if totalCount small enough
        var checked = 0, pending = 0, valid = 0;
        items.forEach(function(t) {
            if (t.isCheckedIn) checked++;
            else if (t.orderStatus === 'pending') pending++;
            else valid++;
        });
        document.getElementById('statCheckedIn').textContent = checked;
        document.getElementById('statPending').textContent = pending;
        document.getElementById('statValidTickets').textContent = valid;
    }

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
            ctx.fillText(i18n.t('mytickets.canvas_eticket'), 20, 38);
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
            var t1 = i18n.t('mytickets.canvas_show_qr');
            ctx.fillText(t1, (w-ctx.measureText(t1).width)/2, 400);
            ctx.fillStyle = '#10b981'; ctx.font = 'bold 12px Inter, sans-serif';
            var t2 = i18n.t('mytickets.canvas_anti_fraud');
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

// ========== ORDERS VIEW ==========
(function() {
    var ctxPath = '${pageContext.request.contextPath}';
    function esc(v) { if (!v) return ''; var d = document.createElement('div'); d.textContent = v; return d.innerHTML; }
    function fmtDate(s) {
        if (!s) return '';
        var d = new Date(s), p = function(n){return String(n).padStart(2,'0');};
        return p(d.getDate())+'/'+p(d.getMonth()+1)+'/'+d.getFullYear()+' '+p(d.getHours())+':'+p(d.getMinutes());
    }
    function fmtMoney(v) { return Number(v||0).toLocaleString('vi-VN') + 'đ'; }

    function orderStatusBadge(status) {
        switch (status) {
            case 'pending': return '<span class="badge rounded-pill px-3 py-2 status-pulse" style="background:linear-gradient(135deg,#f59e0b,#d97706);color:white;"><i class="fas fa-clock me-1"></i>' + i18n.t('mytickets.status_pending') + '</span>';
            case 'paid': return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;"><i class="fas fa-check-circle me-1"></i>' + i18n.t('mytickets.status_paid') + '</span>';
            case 'checked_in': return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#8b5cf6,#6366f1);color:white;"><i class="fas fa-door-open me-1"></i>' + i18n.t('mytickets.status_checked_in') + '</span>';
            case 'cancelled': return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#ef4444,#dc2626);color:white;"><i class="fas fa-times-circle me-1"></i>' + i18n.t('mytickets.status_cancelled') + '</span>';
            case 'refunded': return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#6366f1,#8b5cf6);color:white;"><i class="fas fa-undo me-1"></i>' + i18n.t('mytickets.status_refunded') + '</span>';
            default: return '<span class="badge rounded-pill px-3 py-2 bg-secondary">' + esc(status) + '</span>';
        }
    }

    function orderStatusIcon(status) {
        switch (status) {
            case 'pending': return {gradient: '#f59e0b,#d97706', icon: 'fa-clock'};
            case 'paid': return {gradient: '#10b981,#06b6d4', icon: 'fa-check-circle'};
            case 'checked_in': return {gradient: '#8b5cf6,#6366f1', icon: 'fa-door-open'};
            case 'cancelled': return {gradient: '#ef4444,#dc2626', icon: 'fa-times-circle'};
            default: return {gradient: '#6366f1,#8b5cf6', icon: 'fa-receipt'};
        }
    }

    try {
    window._myOrders = new AjaxCards({
        apiUrl: ctxPath + '/api/my-orders',
        container: '#myOrdersContainer',
        paginationContainer: '#myOrdersPagination',
        searchInput: '#myOrderSearch',
        filterScope: '#ordersView',
        pageSize: 10,
        skeletonCount: 3,
        skeletonHtml: '<div class="card glass-strong border-0 rounded-4 mb-3 skeleton-card" style="height:120px;"><div class="skeleton-body p-4"><div class="skeleton-line w-50"></div><div class="skeleton-line w-75"></div><div class="skeleton-line w-25"></div></div></div>',
        renderEmpty: function() {
            return '<div class="card glass-strong border-0 rounded-4">' +
                '<div class="card-body p-5 text-center">' +
                '<div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-4" style="width:100px;height:100px;background:linear-gradient(135deg,rgba(59,130,246,0.1),rgba(99,102,241,0.1));">' +
                '<i class="fas fa-receipt fa-3x" style="background:linear-gradient(135deg,#3b82f6,#6366f1);-webkit-background-clip:text;-webkit-text-fill-color:transparent;"></i></div>' +
                '<h4 class="fw-bold">' + i18n.t('mytickets.no_orders') + '</h4>' +
                '<p class="text-muted mb-4">' + i18n.t('mytickets.no_orders_desc') + '</p>' +
                '<a href="' + ctxPath + '/events" class="btn btn-gradient rounded-pill px-4 hover-glow"><i class="fas fa-search me-2"></i>' + i18n.t('mytickets.explore') + '</a>' +
                '</div></div>';
        },
        renderCard: function(o) {
            var si = orderStatusIcon(o.status);
            var orderId = 'order_' + o.orderId;

            var card = '<div class="card glass-strong border-0 rounded-4 order-card mb-3" id="' + orderId + '" style="border:2px solid transparent !important;">';

            // Header row (clickable to expand)
            card += '<div class="card-body p-4" onclick="toggleOrder(\'' + orderId + '\')" style="cursor:pointer">';
            card += '<div class="row align-items-center">';
            card += '<div class="col-md-4"><div class="d-flex align-items-center gap-3">';
            card += '<div class="rounded-3 d-flex align-items-center justify-content-center flex-shrink-0" style="width:52px;height:52px;background:linear-gradient(135deg,' + si.gradient + ');">';
            card += '<i class="fas ' + si.icon + ' text-white fa-lg"></i></div>';
            card += '<div class="min-w-0"><h6 class="fw-bold mb-1 text-truncate">' + esc(o.eventTitle) + '</h6>';
            card += '<span class="text-muted small font-monospace">' + esc(o.orderCode) + '</span>';
            card += '</div></div></div>';

            card += '<div class="col-md-3 text-md-center mt-3 mt-md-0">' + orderStatusBadge(o.status) + '</div>';

            card += '<div class="col-md-2 text-md-end mt-3 mt-md-0">';
            card += '<span class="fw-bold text-primary">' + fmtMoney(o.finalAmount) + '</span>';
            card += '</div>';

            card += '<div class="col-md-3 text-md-end mt-3 mt-md-0">';
            card += '<div class="d-flex align-items-center justify-content-md-end gap-3">';
            card += '<span class="text-muted small"><i class="fas fa-clock me-1"></i>' + fmtDate(o.createdAt) + '</span>';
            card += '<i class="fas fa-chevron-down expand-icon text-muted"></i>';
            card += '</div></div>';
            card += '</div></div>';

            // Expandable detail
            card += '<div class="ticket-grid flex-column" id="orderDetail_' + orderId + '">';
            card += '<div class="px-4 pb-4"><div class="border-top pt-4">';

            // Order items — enhanced visual hierarchy
            card += '<h6 class="fw-bold mb-3"><i class="fas fa-list text-primary me-2"></i>' + i18n.t('mytickets.order_details') + '</h6>';
            if (o.items && o.items.length) {
                o.items.forEach(function(it) {
                    card += '<div class="d-flex align-items-center gap-3 p-3 mb-2 rounded-3" style="background:rgba(59,130,246,0.04);border-left:3px solid #3b82f6;">';
                    card += '<div class="flex-grow-1">';
                    card += '<div class="fw-semibold">' + esc(it.ticketTypeName) + '</div>';
                    card += '<small class="text-muted">' + fmtMoney(it.unitPrice) + ' × ' + it.quantity + '</small>';
                    card += '</div>';
                    card += '<div class="fw-bold text-primary">' + fmtMoney(it.subtotal) + '</div>';
                    card += '</div>';
                });
            }

            // Totals — cleaner card style
            card += '<div class="rounded-3 p-3 mt-2" style="background:rgba(16,185,129,0.04);">';
            if (o.discountAmount > 0) {
                card += '<div class="d-flex justify-content-between small mb-1"><span class="text-muted">' + i18n.t('mytickets.subtotal') + '</span><span>' + fmtMoney(o.totalAmount) + '</span></div>';
                card += '<div class="d-flex justify-content-between small mb-2"><span class="text-muted">' + i18n.t('mytickets.discount') + '</span><span class="text-success fw-semibold"><i class="fas fa-tag me-1"></i>-' + fmtMoney(o.discountAmount) + '</span></div>';
            }
            card += '<div class="d-flex justify-content-between fw-bold fs-6 pt-2" style="border-top:1px dashed rgba(0,0,0,0.1);"><span>' + i18n.t('mytickets.grand_total') + '</span><span class="text-primary">' + fmtMoney(o.finalAmount) + '</span></div>';
            card += '</div>';

            // Buyer info — icon-enhanced cards
            card += '<div class="row g-2 mt-3">';
            card += '<div class="col-sm-4"><div class="d-flex align-items-center gap-2"><i class="fas fa-user-circle text-muted"></i><div><small class="text-muted d-block">' + i18n.t('mytickets.buyer') + '</small><span class="fw-medium small">' + esc(o.buyerName) + '</span></div></div></div>';
            card += '<div class="col-sm-4"><div class="d-flex align-items-center gap-2"><i class="fas fa-envelope text-muted"></i><div><small class="text-muted d-block">Email</small><span class="fw-medium small">' + esc(o.buyerEmail) + '</span></div></div></div>';
            card += '<div class="col-sm-4"><div class="d-flex align-items-center gap-2"><i class="fas fa-credit-card text-muted"></i><div><small class="text-muted d-block">' + i18n.t('mytickets.payment_method') + '</small><span class="fw-medium small">' + esc(o.paymentMethod) + '</span></div></div></div>';
            card += '</div>';

            // Action buttons
            card += '<div class="mt-3 d-flex flex-wrap gap-2">';
            if (o.status === 'pending') {
                card += '<a href="' + ctxPath + '/resume-payment?orderId=' + o.orderId + '" class="btn btn-sm rounded-pill px-3" onclick="event.stopPropagation();" style="background:linear-gradient(135deg,#f59e0b,#d97706);color:white;border:none;"><i class="fas fa-credit-card me-2"></i>' + i18n.t('mytickets.pay_now') + '</a>';
            }
            if (o.status === 'paid' || o.status === 'checked_in') {
                card += '<a href="' + ctxPath + '/order-confirmation?id=' + o.orderId + '" class="btn btn-sm rounded-pill px-3" onclick="event.stopPropagation();" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;border:none;"><i class="fas fa-qrcode me-2"></i>' + i18n.t('mytickets.view_eticket') + '</a>';
            }
            card += '</div>';

            card += '</div></div></div>';
            card += '</div>';

            return card;
        }
    });
    } catch(e) {
        console.error('MyOrders constructor error:', e);
        document.getElementById('myOrdersContainer').innerHTML =
            '<div class="alert alert-danger rounded-4 m-3"><i class="fas fa-exclamation-triangle me-2"></i>' + i18n.t('mytickets.error_init_orders') + ': ' + e.message + '</div>';
    }
    // Don't init yet - will init when switching to orders view
})();

// ========== VIEW SWITCHING ==========
var ordersInitialized = false;
window.switchView = function(view, tabEl) {
    // Update tab active states
    document.querySelectorAll('#viewModeTabs .nav-link').forEach(function(a) {
        a.classList.remove('active');
    });
    tabEl.classList.add('active');

    if (view === 'tickets') {
        document.getElementById('ticketsView').style.display = '';
        document.getElementById('ordersView').style.display = 'none';
    } else {
        document.getElementById('ticketsView').style.display = 'none';
        document.getElementById('ordersView').style.display = '';
        // Lazy-init orders AjaxCards on first switch
        if (!ordersInitialized && window._myOrders) {
            try {
                window._myOrders.init();
            } catch(e) {
                console.error('MyOrders init error:', e);
                document.getElementById('myOrdersContainer').innerHTML =
                    '<div class="alert alert-danger rounded-4 m-3"><i class="fas fa-exclamation-triangle me-2"></i>' + i18n.t('mytickets.error_load_orders') + ': ' + e.message + '</div>';
            }
            ordersInitialized = true;
        }
    }
};

// ========== ORDER EXPAND/COLLAPSE ==========
window.toggleOrder = function(orderId) {
    var card = document.getElementById(orderId);
    var grid = document.getElementById('orderDetail_' + orderId);
    if (!card || !grid) return;

    if (grid.classList.contains('show')) {
        grid.classList.remove('show');
        card.classList.remove('expanded');
        card.style.borderColor = 'transparent';
    } else {
        document.querySelectorAll('#ordersView .ticket-grid.show').forEach(function(g) {
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
</script>

<%@include file="footer.jsp" %>
