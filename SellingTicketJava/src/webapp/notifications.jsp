<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<div class="container py-4" style="max-width: 800px;">
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
        <div>
            <h3 class="fw-bold mb-1"><i class="fas fa-bell text-warning me-2"></i>Thông báo</h3>
            <p class="text-muted mb-0">Trung tâm thông báo hệ thống</p>
        </div>
        <div class="d-flex gap-2">
            <c:if test="${unreadCount > 0}">
                <button id="btn-read-all" class="btn btn-sm btn-outline-primary rounded-pill">
                    <i class="fas fa-check-double me-1"></i>Đánh dấu tất cả đã đọc
                </button>
            </c:if>
            <span class="badge glass rounded-pill px-3 py-2">
                <i class="fas fa-envelope me-1"></i><span id="unread-label">${unreadCount}</span> chưa đọc
            </span>
        </div>
    </div>

    <!-- Filter Tabs -->
    <div class="d-flex gap-2 mb-3 animate-fadeInDown" style="animation-delay: 0.05s;">
        <button class="btn btn-sm rounded-pill notif-filter active" data-filter="all"
                style="background: rgba(59,130,246,0.15); color: #3b82f6; border: none;">Tất cả</button>
        <button class="btn btn-sm rounded-pill notif-filter" data-filter="unread"
                style="background: rgba(0,0,0,0.04); color: #64748b; border: none;">Chưa đọc</button>
        <button class="btn btn-sm rounded-pill notif-filter" data-filter="read"
                style="background: rgba(0,0,0,0.04); color: #64748b; border: none;">Đã đọc</button>
    </div>

    <!-- Notification List -->
    <div class="card glass-strong border-0 rounded-4 animate-fadeInDown" style="animation-delay: 0.1s;">
        <div class="card-body p-0">
            <c:forEach var="n" items="${notifications}">
            <div class="d-flex align-items-start gap-3 p-3 border-bottom notif-item ${n.read ? 'read' : 'unread bg-primary bg-opacity-10'}"
                 data-id="${n.notificationId}" data-status="${n.read ? 'read' : 'unread'}" style="transition: all 0.3s;">
                <!-- Icon -->
                <div class="flex-shrink-0 d-flex align-items-center justify-content-center rounded-circle"
                     style="width: 40px; height: 40px; background: ${n.type == 'event_pending' ? 'rgba(245,158,11,0.15)' :
                            n.type == 'order_new' || n.type == 'new_order' ? 'rgba(59,130,246,0.15)' :
                            n.type == 'event_approved' ? 'rgba(16,185,129,0.15)' :
                            n.type == 'event_rejected' ? 'rgba(239,68,68,0.15)' :
                            n.type == 'refund' ? 'rgba(168,85,247,0.15)' :
                            n.type == 'support' || n.type == 'support_routed' ? 'rgba(14,165,233,0.15)' :
                            n.type == 'system' ? 'rgba(100,116,139,0.15)' :
                            'rgba(16,185,129,0.15)'};">
                    <i class="fas ${n.type == 'event_pending' ? 'fa-clock' :
                                   n.type == 'order_new' || n.type == 'new_order' ? 'fa-shopping-cart' :
                                   n.type == 'event_approved' ? 'fa-check-circle' :
                                   n.type == 'event_rejected' ? 'fa-times-circle' :
                                   n.type == 'refund' ? 'fa-undo' :
                                   n.type == 'support' || n.type == 'support_routed' ? 'fa-headset' :
                                   n.type == 'system' ? 'fa-cog' : 'fa-bell'}"
                       style="color: ${n.type == 'event_pending' ? '#f59e0b' :
                                      n.type == 'order_new' || n.type == 'new_order' ? '#3b82f6' :
                                      n.type == 'event_approved' ? '#10b981' :
                                      n.type == 'event_rejected' ? '#ef4444' :
                                      n.type == 'refund' ? '#a855f7' :
                                      n.type == 'support' || n.type == 'support_routed' ? '#0ea5e9' :
                                      n.type == 'system' ? '#64748b' : '#10b981'};"></i>
                </div>
                <!-- Content -->
                <div class="flex-grow-1 min-width-0">
                    <div class="d-flex justify-content-between align-items-start">
                        <h6 class="mb-1 fw-semibold ${n.read ? 'text-muted' : ''}" style="font-size: 0.9rem;">${n.title}</h6>
                        <small class="text-muted text-nowrap ms-2 notif-time" data-time="${n.createdAt.time}">
                            <fmt:formatDate value="${n.createdAt}" pattern="dd/MM HH:mm"/>
                        </small>
                    </div>
                    <p class="mb-1 small ${n.read ? 'text-muted' : ''}">${n.message}</p>
                    <div class="d-flex gap-2">
                        <c:if test="${not empty n.link}">
                            <a href="${pageContext.request.contextPath}${n.link}" class="btn btn-sm btn-outline-primary rounded-pill" style="font-size:0.7rem;">
                                <i class="fas fa-external-link-alt me-1"></i>Xem chi tiết
                            </a>
                        </c:if>
                        <c:if test="${!n.read}">
                            <button class="btn btn-sm btn-ghost rounded-pill btn-mark-read" data-id="${n.notificationId}" style="font-size:0.7rem;">
                                <i class="fas fa-check me-1"></i>Đã đọc
                            </button>
                        </c:if>
                    </div>
                </div>
                <!-- Unread dot -->
                <c:if test="${!n.read}">
                    <span class="flex-shrink-0 rounded-circle mt-2 unread-dot" style="width:8px;height:8px;background: var(--primary);"></span>
                </c:if>
            </div>
            </c:forEach>

            <c:if test="${empty notifications}">
            <div class="text-center py-5 text-muted">
                <i class="fas fa-bell-slash fa-3x mb-3 opacity-25"></i>
                <p class="mb-0">Chưa có thông báo nào</p>
            </div>
            </c:if>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var ctx = document.body.dataset.contextPath || '';

    // Relative time
    document.querySelectorAll('.notif-time[data-time]').forEach(function(el) {
        var ms = parseInt(el.dataset.time);
        if (!ms) return;
        var diff = Date.now() - ms;
        var mins = Math.floor(diff / 60000);
        if (mins < 1) el.textContent = 'Vừa xong';
        else if (mins < 60) el.textContent = mins + ' phút trước';
        else if (mins < 1440) el.textContent = Math.floor(mins / 60) + ' giờ trước';
        else if (mins < 10080) el.textContent = Math.floor(mins / 1440) + ' ngày trước';
    });

    // Mark single read
    document.querySelectorAll('.btn-mark-read').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var id = this.dataset.id;
            var item = this.closest('.notif-item');
            fetch(ctx + '/notifications/read', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'id=' + id
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    item.classList.remove('bg-primary', 'bg-opacity-10', 'unread');
                    item.classList.add('read');
                    item.dataset.status = 'read';
                    btn.remove();
                    var dot = item.querySelector('.unread-dot');
                    if (dot) dot.remove();
                    item.querySelectorAll('.fw-semibold:not(.mb-0)').forEach(function(el) { el.classList.add('text-muted'); });
                    item.querySelector('p').classList.add('text-muted');
                    // Update badge
                    var lbl = document.getElementById('unread-label');
                    if (lbl) {
                        var c = parseInt(lbl.textContent) - 1;
                        lbl.textContent = Math.max(0, c);
                    }
                }
            });
        });
    });

    // Mark all read
    var readAllBtn = document.getElementById('btn-read-all');
    if (readAllBtn) {
        readAllBtn.addEventListener('click', function() {
            fetch(ctx + '/notifications/read-all', { method: 'POST' })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) location.reload();
            });
        });
    }

    // Filter tabs
    document.querySelectorAll('.notif-filter').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.notif-filter').forEach(function(b) {
                b.classList.remove('active');
                b.style.background = 'rgba(0,0,0,0.04)';
                b.style.color = '#64748b';
            });
            this.classList.add('active');
            this.style.background = 'rgba(59,130,246,0.15)';
            this.style.color = '#3b82f6';

            var filter = this.dataset.filter;
            document.querySelectorAll('.notif-item').forEach(function(item) {
                if (filter === 'all') item.style.display = '';
                else if (filter === 'unread') item.style.display = item.dataset.status === 'unread' ? '' : 'none';
                else item.style.display = item.dataset.status === 'read' ? '' : 'none';
            });
        });
    });
});
</script>

<jsp:include page="footer.jsp" />
