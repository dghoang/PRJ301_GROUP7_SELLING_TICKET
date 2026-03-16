<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

<jsp:include page="../header.jsp" />

<style>
/* ======== STAT CARDS ======== */
.stat-card {
    border: none;
    border-radius: var(--radius-lg);
    background: rgba(255,255,255,0.85);
    backdrop-filter: blur(12px);
    padding: 1.25rem;
    transition: transform 0.3s, box-shadow 0.3s;
}
.stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 32px rgba(0,0,0,0.08);
}
.stat-icon {
    width: 48px; height: 48px;
    border-radius: 14px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.2rem;
}

/* ======== FILTER TABS ======== */
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

/* ======== EVENT CARDS ======== */
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
    height: 170px;
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
.event-manage-card .category-badge {
    position: absolute; bottom: 0.75rem; left: 0.75rem;
    padding: 0.25rem 0.65rem;
    border-radius: 50rem;
    font-size: 0.65rem;
    font-weight: 600;
    background: rgba(0,0,0,0.55);
    color: white;
    backdrop-filter: blur(6px);
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

/* ======== EMPTY STATE ======== */
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
            <c:if test="${param.createStatus == 'success'}">
                <div class="alert alert-success alert-dismissible fade show rounded-4 border-0 d-flex align-items-center mb-4 shadow-sm animate-fadeInDown" role="alert" style="background: rgba(16, 185, 129, 0.1); color: #047857;">
                    <i class="fas fa-check-circle fs-4 me-3"></i>
                    <div>
                        <strong>Tạo sự kiện thành công!</strong> Sự kiện đã được lưu. Bạn có thể tiếp tục chỉnh sửa hoặc gửi duyệt.
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>
            <c:if test="${param.error == 'unapproved_events'}">
                <div class="alert alert-warning alert-dismissible fade show rounded-4 border-0 d-flex align-items-center mb-4 shadow-sm animate-fadeInDown" role="alert" style="background: rgba(245, 158, 11, 0.1); color: #b45309;">
                    <i class="fas fa-lock fs-4 me-3"></i>
                    <div>
                        <strong>Tính năng bị khóa!</strong> Bạn cần tạo sự kiện và được Admin hệ thống duyệt để có thể sử dụng các chức năng vận hành bán vé (Đơn hàng, Vé, Check-in, Voucher...).
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>
            <c:if test="${param.error == 'no_events'}">
                <div class="alert alert-danger alert-dismissible fade show rounded-4 border-0 d-flex align-items-center mb-4 shadow-sm animate-fadeInDown" role="alert" style="background: rgba(239, 68, 68, 0.1); color: #b91c1c;">
                    <i class="fas fa-ban fs-4 me-3"></i>
                    <div>
                        <strong>Bạn chưa có sự kiện nào!</strong> Để vào trang Tổng quan (Dashboard), vui lòng bấm "Tạo sự kiện" để bắt đầu thiết lập sự kiện đầu tiên của bạn.
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>
            <c:if test="${param.error == 'no_permission'}">
                <div class="alert alert-danger alert-dismissible fade show rounded-4 border-0 d-flex align-items-center mb-4 shadow-sm animate-fadeInDown" role="alert" style="background: rgba(239, 68, 68, 0.1); color: #b91c1c;">
                    <i class="fas fa-shield-alt fs-4 me-3"></i>
                    <div>
                        <strong>Không có quyền truy cập!</strong> Bạn không phải là ban tổ chức hoặc nhân viên của sự kiện này. Vui lòng chỉ truy cập sự kiện mà bạn được phân quyền.
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

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

            <!-- Summary Stats -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-lg-3 animate-on-scroll visible">
                    <div class="stat-card">
                        <div class="d-flex align-items-center gap-3">
                            <div class="stat-icon" style="background: rgba(147,51,234,0.1); color: #9333ea;">
                                <i class="fas fa-calendar-alt"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Tổng sự kiện</div>
                                <div class="fw-bold fs-5">${countAll}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 animate-on-scroll visible">
                    <div class="stat-card">
                        <div class="d-flex align-items-center gap-3">
                            <div class="stat-icon" style="background: rgba(16,185,129,0.1); color: #10b981;">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Đang bán</div>
                                <div class="fw-bold fs-5">${countApproved}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 animate-on-scroll visible">
                    <div class="stat-card">
                        <div class="d-flex align-items-center gap-3">
                            <div class="stat-icon" style="background: rgba(6,182,212,0.1); color: #06b6d4;">
                                <i class="fas fa-ticket-alt"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Vé đã bán</div>
                                <div class="fw-bold fs-5"><fmt:formatNumber value="${totalSold}" pattern="#,###"/></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 animate-on-scroll visible">
                    <div class="stat-card">
                        <div class="d-flex align-items-center gap-3">
                            <div class="stat-icon" style="background: rgba(245,158,11,0.1); color: #f59e0b;">
                                <i class="fas fa-coins"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Doanh thu</div>
                                <div class="fw-bold fs-5"><fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filter + Search Bar -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible">
                <div class="card-body d-flex gap-3 flex-wrap align-items-center p-3">
                    <div class="filter-tabs d-flex gap-2 flex-wrap" data-pill-group="status">
                        <button class="btn active" data-pill-value="">Tất cả <span class="badge bg-light text-dark ms-1">${countAll}</span></button>
                        <button class="btn" data-pill-value="approved">Đang bán <span class="badge bg-light text-dark ms-1">${countApproved}</span></button>
                        <button class="btn" data-pill-value="pending">Chờ duyệt <span class="badge bg-light text-dark ms-1">${countPending}</span></button>
                        <button class="btn" data-pill-value="draft">Nháp <span class="badge bg-light text-dark ms-1">${countDraft}</span></button>
                        <button class="btn" data-pill-value="ended">Đã kết thúc <span class="badge bg-light text-dark ms-1">${countEnded}</span></button>
                    </div>
                    <div class="input-group ms-auto" style="max-width: 260px;">
                        <span class="input-group-text glass border-0 bg-transparent"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" class="form-control glass border-0 bg-transparent" placeholder="Tìm sự kiện..." id="eventSearchInput">
                    </div>
                </div>
            </div>

            <!-- Events Grid (AJAX-powered) -->
            <div class="row g-4" id="eventsGrid">
            </div>

            <!-- Pagination -->
            <div id="orgEvtPagination" class="d-flex justify-content-center mt-4"></div>
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
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                        <button type="submit" class="btn btn-danger rounded-pill px-4"><i class="fas fa-trash me-2"></i>Xóa</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Submit Draft for Approval Modal -->
<div class="modal fade" id="submitDraftModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4 shadow-lg">
            <div class="modal-body text-center p-5">
                <div class="mb-3">
                    <div style="width:64px;height:64px;border-radius:50%;background:rgba(16,185,129,0.1);display:flex;align-items:center;justify-content:center;margin:0 auto;">
                        <i class="fas fa-paper-plane fa-2x text-success"></i>
                    </div>
                </div>
                <h5 class="fw-bold mb-2">Gửi duyệt sự kiện?</h5>
                <p class="text-muted mb-4">Gửi <strong id="submitDraftEventName"></strong> lên Admin để phê duyệt? Sau khi gửi, sự kiện sẽ chuyển sang trạng thái "Chờ duyệt".</p>
                <div class="d-flex gap-3 justify-content-center">
                    <button class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <form id="submitDraftForm" method="POST">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                        <input type="hidden" name="eventId" id="submitDraftEventId"/>
                        <button type="submit" class="btn rounded-pill px-4" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;border:none;"><i class="fas fa-paper-plane me-2"></i>Gửi duyệt</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/ajax-cards.js"></script>
<script>
(function() {
    var ctxPath = '${pageContext.request.contextPath}';

    function esc(v) { if (!v) return ''; var d = document.createElement('div'); d.textContent = v; return d.innerHTML; }
    function fmtDate(s) {
        if (!s) return '';
        var d = new Date(s), pad = function(n) { return String(n).padStart(2, '0'); };
        return pad(d.getDate()) + '/' + pad(d.getMonth()+1) + '/' + d.getFullYear();
    }
    function fmtMoney(n) { return new Intl.NumberFormat('vi-VN').format(n || 0) + 'đ'; }
    function statusLabel(s) {
        switch(s) {
            case 'approved': return {cls: 'bg-success text-white', text: 'Đang bán'};
            case 'pending':  return {cls: 'bg-warning text-dark', text: 'Chờ duyệt'};
            case 'draft':    return {cls: 'bg-secondary text-white', text: 'Nháp'};
            default:         return {cls: 'bg-dark text-white', text: 'Đã kết thúc'};
        }
    }

    var orgCards = new AjaxCards({
        apiUrl: ctxPath + '/api/organizer/events',
        container: '#eventsGrid',
        paginationContainer: '#orgEvtPagination',
        searchInput: '#eventSearchInput',
        pageSize: 12,
        skeletonCount: 6,
        renderEmpty: function() {
            return '<div class="col-12">' +
                '<div class="empty-events animate-on-scroll visible">' +
                '<div class="empty-events-icon"><i class="fas fa-calendar-plus"></i></div>' +
                '<h4 class="fw-bold mb-2">Chưa có sự kiện nào</h4>' +
                '<p class="text-muted mb-4">Bắt đầu tạo sự kiện đầu tiên của bạn ngay!</p>' +
                '<a href="' + ctxPath + '/organizer/create-event" class="btn btn-gradient rounded-pill px-5 py-2 hover-glow"><i class="fas fa-plus me-2"></i>Tạo sự kiện đầu tiên</a>' +
                '</div></div>';
        },
        renderCard: function(e) {
                var imgContent = e.bannerImage
                    ? '<img src="' + esc(e.bannerImage) + '" alt="' + esc(e.title) + '" style="width:100%;height:100%;object-fit:cover;">'
                    : '<div style="width:100%;height:100%;background:linear-gradient(135deg,#9333ea,#db2777);display:flex;align-items:center;justify-content:center;"><i class=\'fas fa-calendar-alt fa-2x\' style=\'color:rgba(255,255,255,0.4);\'></i></div>';
                var st = statusLabel(e.status);
            var soldPct = e.totalTickets > 0 ? Math.round(e.soldTickets * 100 / e.totalTickets) : 0;

            // Dropdown menu
            var menu = '<li><a class="dropdown-item" href="' + ctxPath + '/organizer/events/' + e.eventId + '"><i class="fas fa-eye me-2 text-info"></i>Xem chi tiết</a></li>';
            menu += '<li><a class="dropdown-item" href="' + ctxPath + '/organizer/events/' + e.eventId + '/edit"><i class="fas fa-edit me-2 text-primary"></i>Chỉnh sửa</a></li>';
            if (e.status === 'draft') {
                menu += '<li><a class="dropdown-item text-success" href="#" data-event-id="' + e.eventId + '" data-event-title="' + esc(e.title).replace(/"/g,'&quot;') + '" onclick="confirmSubmitDraft(this)"><i class="fas fa-paper-plane me-2"></i>Gửi duyệt</a></li>';
            }
            menu += '<li><a class="dropdown-item" href="' + ctxPath + '/organizer/events/' + e.eventId + '/staff"><i class="fas fa-users me-2" style="color:#9333ea;"></i>Nhân sự</a></li>';
            menu += '<li><hr class="dropdown-divider my-1"></li>';
            menu += '<li><a class="dropdown-item text-danger" href="#" data-event-id="' + e.eventId + '" data-event-title="' + esc(e.title).replace(/"/g,'&quot;') + '" onclick="confirmDelete(this)"><i class="fas fa-trash me-2"></i>Xóa</a></li>';

            return '<div class="col-md-6 col-lg-4 event-item animate-on-scroll visible">' +
                '<div class="event-manage-card" onclick="window.location=\'' + ctxPath + '/organizer/events/' + e.eventId + '\'">' +
                '<div class="card-img-wrapper">' +
                    imgContent +
                    '<span class="status-badge ' + st.cls + '">' + st.text + '</span>' +
                    (e.categoryName ? '<span class="category-badge"><i class="fas fa-tag me-1"></i>' + esc(e.categoryName) + '</span>' : '') +
                '</div>' +
                '<div class="card-body p-3">' +
                    '<h6 class="fw-bold mb-2 event-title">' + esc(e.title) + '</h6>' +
                    '<p class="text-muted small mb-2">' +
                        '<i class="far fa-calendar me-1"></i>' + fmtDate(e.startDate) +
                        ' <span class="mx-1">&bull;</span> ' +
                        '<i class="fas fa-map-marker-alt me-1"></i>' + esc(e.location) +
                    '</p>' +
                    '<div class="mb-2">' +
                        '<div class="d-flex justify-content-between small mb-1">' +
                            '<span><strong>' + e.soldTickets + '</strong>/' + e.totalTickets + ' vé</span>' +
                            (e.totalTickets > 0 ? '<span class="text-muted">' + soldPct + '%</span>' : '') +
                        '</div>' +
                        '<div class="progress-thin"><div class="progress-bar" style="width:' + soldPct + '%"></div></div>' +
                    '</div>' +
                    '<div class="d-flex justify-content-between align-items-center" onclick="event.stopPropagation()">' +
                        '<div><span class="text-success fw-bold small">' + fmtMoney(e.revenue) + '</span></div>' +
                        '<div class="action-dropdown dropdown">' +
                            '<button class="btn btn-sm glass rounded-pill px-2" data-bs-toggle="dropdown"><i class="fas fa-ellipsis-h text-muted"></i></button>' +
                            '<ul class="dropdown-menu dropdown-menu-end">' + menu + '</ul>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
                '</div></div>';
        }
    });
    orgCards.init();

    // ========== DELETE MODAL ==========
    window.confirmDelete = function(el) {
        if (window.event) window.event.preventDefault();
        var eventId = el.getAttribute('data-event-id');
        var eventName = el.getAttribute('data-event-title');
        document.getElementById('deleteEventName').textContent = eventName;
        document.getElementById('deleteForm').action = ctxPath + '/organizer/events/' + eventId + '/delete';
        new bootstrap.Modal(document.getElementById('deleteModal')).show();
    };

    // ========== SUBMIT DRAFT MODAL ==========
    window.confirmSubmitDraft = function(el) {
        if (window.event) window.event.preventDefault();
        var eventId = el.getAttribute('data-event-id');
        var eventName = el.getAttribute('data-event-title');
        document.getElementById('submitDraftEventName').textContent = eventName;
        document.getElementById('submitDraftEventId').value = eventId;
        document.getElementById('submitDraftForm').action = ctxPath + '/organizer/events/submit-draft';
        new bootstrap.Modal(document.getElementById('submitDraftModal')).show();
    };
})();
</script>

<jsp:include page="../footer.jsp" />
