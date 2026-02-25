<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<style>
/* ======== EVENT GRID STYLES ======== */
.filter-tabs .btn {
    border-radius: 50rem;
    font-weight: 500;
    font-size: 0.85rem;
    padding: 0.4rem 1rem;
    transition: all 0.3s;
    border: 1px solid rgba(0,0,0,0.08);
    background: transparent;
    color: var(--text-muted);
}
.filter-tabs .btn.active {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    border-color: transparent;
    box-shadow: 0 4px 12px rgba(147, 51, 234, 0.25);
}
.filter-tabs .btn .badge {
    font-size: 0.65rem;
    padding: 0.2em 0.5em;
    border-radius: 50rem;
}

.event-manage-card {
    border: none;
    border-radius: var(--radius-lg);
    overflow: hidden;
    transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
    background: rgba(255,255,255,0.85);
    backdrop-filter: blur(12px);
    height: 100%;
    cursor: pointer;
}
.event-manage-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 16px 40px rgba(0,0,0,0.1);
}
.event-manage-card .card-img-wrapper {
    position: relative;
    overflow: hidden;
    height: 160px;
}
.event-manage-card .card-img-wrapper img {
    width: 100%; height: 100%;
    object-fit: cover;
    transition: transform 0.5s;
}
.event-manage-card:hover .card-img-wrapper img {
    transform: scale(1.08);
}
.event-manage-card .status-badge {
    position: absolute; top: 0.75rem; right: 0.75rem;
    padding: 0.3rem 0.75rem;
    border-radius: 50rem;
    font-size: 0.7rem;
    font-weight: 600;
    backdrop-filter: blur(8px);
}
.progress-thin {
    height: 4px;
    border-radius: 4px;
    background: rgba(0,0,0,0.06);
}
.progress-thin .progress-bar {
    border-radius: 4px;
    background: linear-gradient(90deg, #10b981, #06b6d4);
}
.action-dropdown .dropdown-toggle::after { display: none; }
.action-dropdown .dropdown-menu {
    border: none;
    border-radius: var(--radius-md);
    box-shadow: 0 12px 32px rgba(0,0,0,0.12);
    padding: 0.5rem;
    min-width: 180px;
    background: rgba(255,255,255,0.95);
    backdrop-filter: blur(16px);
}
.action-dropdown .dropdown-item {
    border-radius: 8px;
    padding: 0.5rem 0.75rem;
    font-size: 0.85rem;
    transition: background 0.2s;
}
.action-dropdown .dropdown-item:hover { background: rgba(147, 51, 234, 0.08); }

/* Empty state */
.empty-events {
    text-align: center;
    padding: 4rem 2rem;
}
.empty-events-icon {
    width: 120px; height: 120px;
    border-radius: 50%;
    background: linear-gradient(135deg, rgba(147,51,234,0.08), rgba(219,39,119,0.08));
    display: flex; align-items: center; justify-content: center;
    margin: 0 auto 1.5rem;
    font-size: 3rem;
    color: var(--primary);
}

/* Search highlight */
.search-highlight {
    background: rgba(147, 51, 234, 0.2);
    border-radius: 3px;
    padding: 0 2px;
}
</style>

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="events"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1">Sự kiện của tôi</h2>
                    <p class="text-muted mb-0 small">Quản lý tất cả sự kiện bạn đã tạo và tham gia quản lý</p>
                </div>
                <c:choose>
                    <c:when test="${param.error == 'limit_reached'}">
                        <div class="alert alert-warning border-0 rounded-pill px-4 py-2 m-0 animate-shake shadow-sm">
                            <i class="fas fa-exclamation-triangle me-2"></i>Tối đa 3 sự kiện chờ duyệt!
                        </div>
                    </c:when>
                    <c:when test="${param.error == 'access_denied'}">
                        <div class="alert alert-danger border-0 rounded-pill px-4 py-2 m-0 animate-shake shadow-sm">
                            <i class="fas fa-lock me-2"></i>Bạn không có quyền truy cập sự kiện này!
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/organizer/create-event" class="btn btn-gradient rounded-pill px-4 hover-glow">
                            <i class="fas fa-plus me-2"></i>Tạo sự kiện
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Filter + Search Bar -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible">
                <div class="card-body d-flex gap-3 flex-wrap align-items-center p-3">
                    <div class="filter-tabs d-flex gap-2 flex-wrap">
                        <button class="btn active" data-filter="all">Tất cả</button>
                        <button class="btn" data-filter="approved">Đang bán</button>
                        <button class="btn" data-filter="pending">Chờ duyệt</button>
                        <button class="btn" data-filter="draft">Nháp</button>
                        <button class="btn" data-filter="ended">Đã kết thúc</button>
                    </div>
                    <div class="input-group ms-auto" style="max-width: 260px;">
                        <span class="input-group-text glass border-0 bg-transparent"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" class="form-control glass border-0 bg-transparent" placeholder="Tìm sự kiện..." id="eventSearchInput">
                    </div>
                </div>
            </div>

            <!-- Events Grid -->
            <div class="row g-4" id="eventsGrid">
                <c:forEach var="event" items="${events}">
                    <div class="col-md-6 col-lg-4 event-item animate-on-scroll visible" data-status="${event.status}" data-title="${event.title}">
                        <div class="event-manage-card" onclick="window.location='${pageContext.request.contextPath}/organizer/events/${event.eventId}'">
                            <div class="card-img-wrapper">
                                <img src="${event.bannerUrl != null ? event.bannerUrl : 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400'}" alt="${event.title}">
                                <span class="status-badge
                                    ${event.status == 'approved' ? 'bg-success text-white' : ''}
                                    ${event.status == 'pending' ? 'bg-warning text-dark' : ''}
                                    ${event.status == 'draft' ? 'bg-secondary text-white' : ''}
                                    ${event.status == 'ended' ? 'bg-dark text-white' : ''}">
                                    ${event.status == 'approved' ? 'Đang bán' : event.status == 'pending' ? 'Chờ duyệt' : event.status == 'draft' ? 'Nháp' : 'Đã kết thúc'}
                                </span>
                            </div>
                            <div class="card-body p-3">
                                <h6 class="fw-bold mb-2 event-title">${event.title}</h6>
                                <p class="text-muted small mb-2">
                                    <i class="far fa-calendar me-1"></i>${event.eventDate}
                                    <span class="mx-1">&bull;</span>
                                    <i class="fas fa-map-marker-alt me-1"></i>${event.location}
                                </p>

                                <!-- Ticket Progress -->
                                <c:set var="soldPct" value="${event.totalTickets > 0 ? (event.soldTickets * 100 / event.totalTickets) : 0}"/>
                                <div class="mb-2">
                                    <div class="d-flex justify-content-between small mb-1">
                                        <span><strong>${event.soldTickets}</strong>/${event.totalTickets} vé</span>
                                        <c:if test="${event.totalTickets > 0}">
                                            <span class="text-muted"><fmt:formatNumber value="${soldPct}" maxFractionDigits="0"/>%</span>
                                        </c:if>
                                    </div>
                                    <div class="progress-thin">
                                        <div class="progress-bar" style="width: <fmt:formatNumber value='${soldPct}' maxFractionDigits='0'/>%"></div>
                                    </div>
                                </div>

                                <!-- Actions -->
                                <div class="d-flex justify-content-between align-items-center" onclick="event.stopPropagation()">
                                    <span class="text-success fw-bold small">${event.revenue}</span>
                                    <div class="action-dropdown dropdown">
                                        <button class="btn btn-sm glass rounded-pill px-2" data-bs-toggle="dropdown">
                                            <i class="fas fa-ellipsis-h text-muted"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end">
                                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/organizer/events/${event.eventId}/edit"><i class="fas fa-edit me-2 text-primary"></i>Chỉnh sửa</a></li>
                                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/organizer/events/${event.eventId}"><i class="fas fa-eye me-2 text-info"></i>Xem chi tiết</a></li>
                                            <c:if test="${sessionScope.user.userId == event.organizerId}">
                                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/organizer/events/${event.eventId}/staff"><i class="fas fa-users me-2 text-purple"></i>Nhân sự</a></li>
                                            </c:if>
                                            <li><hr class="dropdown-divider my-1"></li>
                                            <li><a class="dropdown-item text-danger" href="#" onclick="confirmDelete(${event.eventId}, '${event.title}')"><i class="fas fa-trash me-2"></i>Xóa</a></li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Empty State -->
            <c:if test="${empty events}">
                <div class="empty-events animate-on-scroll visible">
                    <div class="empty-events-icon">
                        <i class="fas fa-calendar-plus"></i>
                    </div>
                    <h4 class="fw-bold mb-2">Chưa có sự kiện nào</h4>
                    <p class="text-muted mb-4">Bắt đầu tạo sự kiện đầu tiên của bạn ngay!</p>
                    <a href="${pageContext.request.contextPath}/organizer/create-event" class="btn btn-gradient rounded-pill px-5 py-2 hover-glow">
                        <i class="fas fa-plus me-2"></i>Tạo sự kiện đầu tiên
                    </a>
                </div>
            </c:if>

            <!-- No Results (hidden by default) -->
            <div id="noResults" class="text-center py-5 d-none">
                <i class="fas fa-search fa-3x text-muted opacity-25 mb-3"></i>
                <p class="text-muted">Không tìm thấy sự kiện phù hợp</p>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4 shadow-lg">
            <div class="modal-body text-center p-5">
                <div class="mb-3">
                    <div style="width:64px;height:64px;border-radius:50%;background:rgba(239,68,68,0.1);display:flex;align-items:center;justify-content:center;margin:0 auto;">
                        <i class="fas fa-trash-alt fa-2x text-danger"></i>
                    </div>
                </div>
                <h5 class="fw-bold mb-2">Xóa sự kiện?</h5>
                <p class="text-muted mb-4">Bạn chắc chắn muốn xóa <strong id="deleteEventName"></strong>? Hành động này không thể hoàn tác.</p>
                <div class="d-flex gap-3 justify-content-center">
                    <button class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <form id="deleteForm" method="POST">
                        <input type="hidden" name="csrf_token" value="${csrf_token}"/>
                        <button type="submit" class="btn btn-danger rounded-pill px-4"><i class="fas fa-trash me-2"></i>Xóa</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// ========== FILTER TABS ==========
document.querySelectorAll('.filter-tabs .btn').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.filter-tabs .btn').forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        const filter = this.dataset.filter;
        let visibleCount = 0;
        document.querySelectorAll('.event-item').forEach(item => {
            const status = item.dataset.status;
            const show = filter === 'all' || status === filter;
            item.style.display = show ? '' : 'none';
            if (show) visibleCount++;
        });
        document.getElementById('noResults').classList.toggle('d-none', visibleCount > 0);
    });
});

// ========== SEARCH ==========
let searchTimeout;
document.getElementById('eventSearchInput').addEventListener('input', function() {
    clearTimeout(searchTimeout);
    const query = this.value.trim().toLowerCase();
    searchTimeout = setTimeout(() => {
        let visibleCount = 0;
        document.querySelectorAll('.event-item').forEach(item => {
            const title = item.dataset.title.toLowerCase();
            const match = !query || title.includes(query);
            item.style.display = match ? '' : 'none';
            if (match) visibleCount++;
        });
        document.getElementById('noResults').classList.toggle('d-none', visibleCount > 0);
    }, 200);
});

// ========== DELETE MODAL ==========
function confirmDelete(eventId, eventName) {
    event.preventDefault();
    document.getElementById('deleteEventName').textContent = eventName;
    document.getElementById('deleteForm').action = '${pageContext.request.contextPath}/organizer/events/' + eventId + '/delete';
    new bootstrap.Modal(document.getElementById('deleteModal')).show();
}
</script>

<jsp:include page="../footer.jsp" />
