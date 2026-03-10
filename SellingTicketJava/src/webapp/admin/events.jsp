<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="events"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-calendar-alt text-primary me-2"></i>Quản lý sự kiện</h2>
                    <p class="text-muted mb-0">Xem, duyệt và quản lý tất cả sự kiện</p>
                </div>
            </div>

            <%-- Search Bar --%>
            <div class="d-flex justify-content-between align-items-center mb-4 animate-on-scroll">
                <div class="d-flex align-items-center gap-2" data-filter-group="status">
                    <label class="btn btn-sm glass rounded-pill px-3">
                        <input type="checkbox" value="pending" class="d-none"> <i class="fas fa-clock me-1 text-warning"></i>Chờ duyệt
                    </label>
                    <label class="btn btn-sm glass rounded-pill px-3">
                        <input type="checkbox" value="approved" class="d-none"> <i class="fas fa-check me-1 text-success"></i>Đã duyệt
                    </label>
                    <label class="btn btn-sm glass rounded-pill px-3">
                        <input type="checkbox" value="rejected" class="d-none"> <i class="fas fa-times me-1 text-danger"></i>Từ chối
                    </label>
                </div>
                <div class="input-group shadow-sm rounded-pill overflow-hidden" style="max-width: 320px;">
                    <span class="input-group-text glass border-0 bg-white"><i class="fas fa-search text-muted"></i></span>
                    <input type="text" id="admin-event-search" class="form-control glass border-0 bg-white shadow-none ps-0" placeholder="Tìm kiếm sự kiện...">
                </div>
            </div>

            <%-- Stats Cards as Filters --%>
            <div class="row g-3 mb-4">
                <%-- Tất cả --%>
                <div class="col-6 col-md-3 animate-on-scroll">
                    <a href="${pageContext.request.contextPath}/admin/events" class="text-decoration-none">
                        <div class="card glass-strong border-0 rounded-4 hover-lift h-100 ${empty statusFilter ? 'shadow-lg border-primary' : ''}" 
                             style="${empty statusFilter ? 'background: rgba(59,130,246,0.1); border: 2px solid var(--primary) !important;' : 'transition: all 0.3s;'}">
                            <div class="card-body d-flex align-items-center gap-3 p-3">
                                <div class="dash-icon-box flex-shrink-0" style="width:42px;height:42px;background:linear-gradient(135deg,#3b82f6,#2563eb);border-radius:12px;">
                                    <i class="fas fa-layer-group text-white"></i>
                                </div>
                                <div class="min-w-0">
                                    <h4 class="fw-bold mb-0 text-dark">${pendingCount + approvedCount + rejectedCount}</h4>
                                    <small class="text-muted d-block text-truncate">Tất cả</small>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>

                <%-- Chờ duyệt --%>
                <div class="col-6 col-md-3 animate-on-scroll stagger-1">
                    <a href="${pageContext.request.contextPath}/admin/events?status=pending" class="text-decoration-none">
                        <div class="card glass-strong border-0 rounded-4 hover-lift h-100 ${statusFilter == 'pending' ? 'shadow-lg' : ''}"
                             style="${statusFilter == 'pending' ? 'background: rgba(245,158,11,0.1); border: 2px solid #f59e0b !important;' : 'transition: all 0.3s;'}">
                            <div class="card-body d-flex align-items-center gap-3 p-3">
                                <div class="dash-icon-box flex-shrink-0" style="width:42px;height:42px;background:linear-gradient(135deg,#f59e0b,#f97316);border-radius:12px;">
                                    <i class="fas fa-clock text-white"></i>
                                </div>
                                <div class="min-w-0">
                                    <h4 class="fw-bold mb-0 text-dark">${pendingCount != null ? pendingCount : 0}</h4>
                                    <small class="text-muted d-block text-truncate">Chờ duyệt</small>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>

                <%-- Đã duyệt --%>
                <div class="col-6 col-md-3 animate-on-scroll stagger-2">
                    <a href="${pageContext.request.contextPath}/admin/events?status=approved" class="text-decoration-none">
                        <div class="card glass-strong border-0 rounded-4 hover-lift h-100 ${statusFilter == 'approved' ? 'shadow-lg' : ''}"
                             style="${statusFilter == 'approved' ? 'background: rgba(16,185,129,0.1); border: 2px solid #10b981 !important;' : 'transition: all 0.3s;'}">
                            <div class="card-body d-flex align-items-center gap-3 p-3">
                                <div class="dash-icon-box flex-shrink-0" style="width:42px;height:42px;background:linear-gradient(135deg,#10b981,#06b6d4);border-radius:12px;">
                                    <i class="fas fa-check text-white"></i>
                                </div>
                                <div class="min-w-0">
                                    <h4 class="fw-bold mb-0 text-dark">${approvedCount != null ? approvedCount : 0}</h4>
                                    <small class="text-muted d-block text-truncate">Đã duyệt</small>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>

                <%-- Từ chối --%>
                <div class="col-6 col-md-3 animate-on-scroll stagger-3">
                    <a href="${pageContext.request.contextPath}/admin/events?status=rejected" class="text-decoration-none">
                        <div class="card glass-strong border-0 rounded-4 hover-lift h-100 ${statusFilter == 'rejected' ? 'shadow-lg' : ''}"
                             style="${statusFilter == 'rejected' ? 'background: rgba(239,68,68,0.1); border: 2px solid #ef4444 !important;' : 'transition: all 0.3s;'}">
                            <div class="card-body d-flex align-items-center gap-3 p-3">
                                <div class="dash-icon-box flex-shrink-0" style="width:42px;height:42px;background:linear-gradient(135deg,#ef4444,#dc2626);border-radius:12px;">
                                    <i class="fas fa-times text-white"></i>
                                </div>
                                <div class="min-w-0">
                                    <h4 class="fw-bold mb-0 text-dark">${rejectedCount != null ? rejectedCount : 0}</h4>
                                    <small class="text-muted d-block text-truncate">Từ chối</small>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </div>

            <%-- Toast messages --%>
            <c:if test="${not empty flashSuccess}">
                <div class="alert alert-success alert-dismissible fade show rounded-4 border-0" role="alert" style="background: rgba(16,185,129,0.1); color: #059669;">
                    <i class="fas fa-check-circle me-2"></i>${flashSuccess}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty flashError}">
                <div class="alert alert-danger alert-dismissible fade show rounded-4 border-0" role="alert" style="background: rgba(239,68,68,0.1); color: #dc2626;">
                    <i class="fas fa-exclamation-circle me-2"></i>${flashError}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <%-- Events Table --%>
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Sự kiện</th>
                                    <th>Organizer</th>
                                    <th>Danh mục</th>
                                    <th>Ngày</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody id="admin-events-tbody">
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <%-- Pagination --%>
            <div id="admin-events-pagination" class="d-flex justify-content-center mt-4"></div>
        </div>
    </div>
</div>

<%-- Reject Modal with Rich Editor --%>
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form method="POST" action="${pageContext.request.contextPath}/admin/events/reject" onsubmit="return prepareReject()">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                <input type="hidden" name="eventId" id="rejectEventId"/>
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-times-circle text-danger me-2"></i>Từ chối sự kiện</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Sự kiện: <strong id="rejectEventName"></strong></p>
                    <label class="form-label fw-medium">Lý do từ chối <span class="text-danger">*</span></label>
                    <div class="desc-toolbar" style="display:flex;gap:0.25rem;flex-wrap:wrap;padding:0.5rem;background:rgba(0,0,0,0.02);border-radius:8px 8px 0 0;border:1px solid rgba(0,0,0,0.08);border-bottom:none;">
                        <button type="button" onclick="rFmt('bold')" title="In đậm" class="btn btn-sm btn-light"><i class="fas fa-bold"></i></button>
                        <button type="button" onclick="rFmt('italic')" title="In nghiêng" class="btn btn-sm btn-light"><i class="fas fa-italic"></i></button>
                        <button type="button" onclick="rFmt('underline')" title="Gạch chân" class="btn btn-sm btn-light"><i class="fas fa-underline"></i></button>
                        <span style="width:1px;background:rgba(0,0,0,0.1);margin:0 4px;height:20px;align-self:center;"></span>
                        <button type="button" onclick="rFmt('insertUnorderedList')" title="Danh sách" class="btn btn-sm btn-light"><i class="fas fa-list-ul"></i></button>
                        <button type="button" onclick="rFmt('insertOrderedList')" title="Số" class="btn btn-sm btn-light"><i class="fas fa-list-ol"></i></button>
                        <span style="width:1px;background:rgba(0,0,0,0.1);margin:0 4px;height:20px;align-self:center;"></span>
                        <select class="form-select form-select-sm" style="width:auto;" onchange="rFmt('formatBlock',this.value);this.selectedIndex=0;">
                            <option value="" hidden>Tiêu đề</option>
                            <option value="H3">Tiêu đề</option>
                            <option value="P">Bình thường</option>
                        </select>
                        <button type="button" onclick="rFmt('foreColor','#ef4444')" title="Màu đỏ" class="btn btn-sm btn-light"><i class="fas fa-palette" style="color:#ef4444;"></i></button>
                    </div>
                    <div contenteditable="true" id="evtRejectEditor" spellcheck="false" style="border:1px solid rgba(0,0,0,0.08);border-radius:0 0 8px 8px;min-height:180px;padding:1rem;background:white;outline:none;font-size:0.95rem;line-height:1.6;max-height:400px;overflow-y:auto;"
                         onfocus="this.style.borderColor='var(--primary)';this.style.boxShadow='0 0 0 3px rgba(147,51,234,0.1)';"
                         onblur="this.style.borderColor='rgba(0,0,0,0.08)';this.style.boxShadow='none';"></div>
                    <textarea name="reason" id="evtRejectReason" class="d-none"></textarea>
                    <div id="rejectError" class="text-danger small mt-1 d-none"><i class="fas fa-exclamation-circle me-1"></i>Vui lòng nhập lý do từ chối</div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4">
                        <i class="fas fa-times me-2"></i>Xác nhận từ chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function rFmt(cmd, val) { document.execCommand(cmd, false, val); document.getElementById('evtRejectEditor').focus(); }

function prepareReject() {
    var editor = document.getElementById('evtRejectEditor');
    var ta = document.getElementById('evtRejectReason');
    var errEl = document.getElementById('rejectError');
    var content = editor.innerHTML.trim();
    // Check if editor has any text content (not just empty tags)
    if (!content || editor.innerText.trim().length === 0) {
        errEl.classList.remove('d-none');
        editor.focus();
        return false;
    }
    errEl.classList.add('d-none');
    ta.value = content;
    return true;
}

function toggleFeatured(eventId, currentState, btn) {
    var basePath = document.querySelector('meta[name="ctx"]')?.content || '';
    fetch(basePath + '/admin/events/feature', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'eventId=' + eventId + '&featured=' + (!currentState)
    })
    .then(function(res) { if (res.ok) window.adminEventsTable.load(); });
}
</script>

<script src="${pageContext.request.contextPath}/assets/js/ajax-table.js"></script>
<script>
(function() {
    var ctxPath = '${pageContext.request.contextPath}';
    var csrfToken = '${sessionScope.csrf_token}';

    function esc(v) {
        if (!v) return '';
        var d = document.createElement('div'); d.textContent = v; return d.innerHTML;
    }
    function fmtDate(s) {
        if (!s) return '';
        var d = new Date(s);
        var pad = function(n) { return String(n).padStart(2, '0'); };
        return pad(d.getDate()) + '/' + pad(d.getMonth()+1) + '/' + d.getFullYear() + ' ' + pad(d.getHours()) + ':' + pad(d.getMinutes());
    }
    function statusBadge(status) {
        switch(status) {
            case 'approved': return '<span class="badge bg-success rounded-pill px-3 py-2"><i class="fas fa-check me-1"></i>Đã duyệt</span>';
            case 'pending': return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#f59e0b,#f97316);color:white;"><i class="fas fa-clock me-1"></i>Chờ duyệt</span>';
            case 'rejected': return '<span class="badge bg-danger rounded-pill px-3 py-2"><i class="fas fa-times me-1"></i>Từ chối</span>';
            default: return '<span class="badge bg-secondary rounded-pill px-3 py-2">' + esc(status) + '</span>';
        }
    }

    // Toggle filter checkbox styling
    document.querySelectorAll('[data-filter-group="status"] label').forEach(function(label) {
        var cb = label.querySelector('input[type="checkbox"]');
        cb.addEventListener('change', function() {
            label.classList.toggle('active', cb.checked);
            label.style.background = cb.checked ? 'var(--primary)' : '';
            label.style.color = cb.checked ? 'white' : '';
        });
    });

    window.adminEventsTable = new AjaxTable({
        apiUrl: ctxPath + '/api/admin/events',
        tableBody: '#admin-events-tbody',
        paginationContainer: '#admin-events-pagination',
        searchInput: '#admin-event-search',
        pageSize: 20,
        skeletonCols: 6,
        renderRow: function(e) {
            var img = esc(e.bannerImage || 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100');
            var actions = '<a href="' + ctxPath + '/admin/events/' + e.eventId + '" class="btn btn-sm glass rounded-pill px-2" title="Xem chi tiết"><i class="fas fa-eye text-primary"></i></a>';
            if (e.status === 'pending') {
                actions += '<form method="POST" action="' + ctxPath + '/admin/events/approve" class="d-inline">' +
                    '<input type="hidden" name="csrf_token" value="' + csrfToken + '"/>' +
                    '<input type="hidden" name="eventId" value="' + e.eventId + '"/>' +
                    '<button type="submit" class="btn btn-sm rounded-pill px-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;" title="Duyệt"><i class="fas fa-check"></i></button></form>';
                actions += '<button class="btn btn-sm btn-outline-danger rounded-pill px-2" title="Từ chối" data-bs-toggle="modal" data-bs-target="#rejectModal" onclick="document.getElementById(\'rejectEventId\').value=\'' + e.eventId + '\';document.getElementById(\'rejectEventName\').textContent=\'' + esc(e.title).replace(/'/g, "\\'") + '\'"><i class="fas fa-times"></i></button>';
            } else {
                actions += '<form method="POST" action="' + ctxPath + '/admin/events/delete" class="d-inline" onsubmit="return confirm(\'Bạn có chắc muốn xóa sự kiện này?\')">' +
                    '<input type="hidden" name="csrf_token" value="' + csrfToken + '"/>' +
                    '<input type="hidden" name="eventId" value="' + e.eventId + '"/>' +
                    '<button type="submit" class="btn btn-sm glass rounded-pill px-2" title="Xóa"><i class="fas fa-trash text-danger"></i></button></form>';
            }
            var featStyle = e.isFeatured
                ? 'background:linear-gradient(135deg,#f59e0b,#d97706);color:white;border:none'
                : 'background:rgba(245,158,11,0.1);color:#d97706;border:1px solid rgba(245,158,11,0.3)';
            actions += '<button class="btn btn-sm rounded-pill px-2" style="' + featStyle + '" onclick="toggleFeatured(' + e.eventId + ',' + e.isFeatured + ',this)"><i class="fas fa-star"></i></button>';

            return '<tr class="hover-lift" style="transition:all 0.2s;">' +
                '<td><div class="d-flex align-items-center gap-3">' +
                    '<img src="' + img + '" class="rounded-3 shadow-sm" style="width:50px;height:50px;object-fit:cover;" alt="">' +
                    '<div><a href="' + ctxPath + '/admin/events/' + e.eventId + '" class="fw-medium text-decoration-none">' + esc(e.title) + '</a>' +
                    '<div class="text-muted small"><i class="fas fa-map-marker-alt me-1"></i>' + esc(e.location) + '</div></div></div></td>' +
                '<td class="text-muted">' + esc(e.organizerName) + '</td>' +
                '<td><span class="badge glass rounded-pill px-3 py-1">' + esc(e.categoryName) + '</span></td>' +
                '<td class="text-muted small">' + fmtDate(e.startDate) + '</td>' +
                '<td>' + statusBadge(e.status) + '</td>' +
                '<td class="text-center"><div class="d-flex gap-1 justify-content-center flex-wrap">' + actions + '</div></td>' +
            '</tr>';
        }
    });
    adminEventsTable.init();
})();
</script>

<jsp:include page="../footer.jsp" />
