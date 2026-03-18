<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="notifications"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
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
                        <i class="fas fa-envelope me-1"></i>${unreadCount} chưa đọc
                    </span>
                </div>
            </div>

            <!-- Notification List -->
            <div class="card glass-strong border-0 rounded-4">
                <div class="card-body p-0">
                    <c:forEach var="n" items="${notifications}">
                    <div class="d-flex align-items-start gap-3 p-3 border-bottom notif-item ${n.read ? '' : 'bg-primary bg-opacity-10'}" 
                         data-id="${n.notificationId}" style="transition: all 0.3s;">
                        <!-- Icon -->
                        <div class="flex-shrink-0 d-flex align-items-center justify-content-center rounded-circle"
                             style="width: 40px; height: 40px; background: ${n.type == 'event_pending' ? 'rgba(245,158,11,0.15)' :
                                    n.type == 'order_new' ? 'rgba(59,130,246,0.15)' :
                                    n.type == 'system' ? 'rgba(100,116,139,0.15)' :
                                    'rgba(16,185,129,0.15)'};">
                            <i class="fas ${n.type == 'event_pending' ? 'fa-clock' :
                                           n.type == 'order_new' ? 'fa-shopping-cart' :
                                           n.type == 'system' ? 'fa-cog' : 'fa-bell'}"
                               style="color: ${n.type == 'event_pending' ? '#f59e0b' :
                                              n.type == 'order_new' ? '#3b82f6' :
                                              n.type == 'system' ? '#64748b' : '#10b981'};"></i>
                        </div>
                        <!-- Content -->
                        <div class="flex-grow-1 min-width-0">
                            <div class="d-flex justify-content-between align-items-start">
                                <h6 class="mb-1 fw-semibold ${n.read ? 'text-muted' : ''}" style="font-size: 0.9rem;">${n.title}</h6>
                                <small class="text-muted text-nowrap ms-2">
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
                            <span class="flex-shrink-0 rounded-circle mt-2" style="width:8px;height:8px;background: var(--primary);"></span>
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
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Mark single read
    document.querySelectorAll('.btn-mark-read').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var id = this.dataset.id;
            var item = this.closest('.notif-item');
            fetch('${pageContext.request.contextPath}/admin/notifications/read', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'id=' + id
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    item.classList.remove('bg-primary', 'bg-opacity-10');
                    btn.remove();
                    var dot = item.querySelector('.rounded-circle[style*="width:8px"]');
                    if (dot) dot.remove();
                }
            });
        });
    });

    // Mark all read
    var readAllBtn = document.getElementById('btn-read-all');
    if (readAllBtn) {
        readAllBtn.addEventListener('click', function() {
            fetch('${pageContext.request.contextPath}/admin/notifications/read-all', {
                method: 'POST'
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) location.reload();
            });
        });
    }
});
</script>

<jsp:include page="../footer.jsp" />
