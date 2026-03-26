<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="users"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <h2 class="fw-bold mb-0"><i class="fas fa-users text-primary me-2"></i>Quản lý người dùng</h2>
            </div>

            <c:if test="${not empty flashSuccess}">
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="background: rgba(16,185,129,0.1); border-left: 4px solid #10b981 !important;">
                    <i class="fas fa-check-circle text-success me-2"></i>${flashSuccess}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty flashError}">
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="background: rgba(239,68,68,0.1); border-left: 4px solid #ef4444 !important;">
                    <i class="fas fa-exclamation-circle text-danger me-2"></i>${flashError}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Stats -->
            <div class="row g-3 mb-4">
                <div class="col-md-3 animate-on-scroll">
                    <a href="${pageContext.request.contextPath}/admin/users" class="text-decoration-none">
                    <div class="card glass-strong border-0 rounded-4 hover-lift cursor-pointer">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #3b82f6, #6366f1);">
                                <i class="fas fa-users text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">${totalUsers != null ? totalUsers : 0}</h4>
                                <small class="text-muted">Tổng cộng</small>
                            </div>
                        </div>
                    </div>
                    </a>
                </div>
                <div class="col-md-3 animate-on-scroll stagger-1">
                    <a href="${pageContext.request.contextPath}/admin/users?filter=active&isActive=true" class="text-decoration-none">
                    <div class="card glass-strong border-0 rounded-4 hover-lift cursor-pointer">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-user-check text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">${activeUsers != null ? activeUsers : 0}</h4>
                                <small class="text-muted">Hoạt động</small>
                            </div>
                        </div>
                    </div>
                    </a>
                </div>
                <div class="col-md-3 animate-on-scroll stagger-2">
                    <a href="${pageContext.request.contextPath}/admin/users?filter=support_agent&role=support_agent" class="text-decoration-none">
                    <div class="card glass-strong border-0 rounded-4 hover-lift cursor-pointer">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #9333ea, #a855f7);">
                                <i class="fas fa-headset text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">${supportAgentCount != null ? supportAgentCount : 0}</h4>
                                <small class="text-muted">Hỗ trợ viên</small>
                            </div>
                        </div>
                    </div>
                    </a>
                </div>
                <div class="col-md-3 animate-on-scroll stagger-3">
                    <a href="${pageContext.request.contextPath}/admin/users?filter=locked&isActive=false" class="text-decoration-none">
                    <div class="card glass-strong border-0 rounded-4 hover-lift cursor-pointer">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #f59e0b, #f97316);">
                                <i class="fas fa-user-slash text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">${lockedUsers != null ? lockedUsers : 0}</h4>
                                <small class="text-muted">Bị khóa</small>
                            </div>
                        </div>
                    </div>
                    </a>
                </div>
            </div>

            <!-- Search & Filter -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body d-flex gap-3 align-items-center flex-wrap p-3">
                    <div class="input-group" style="max-width: 320px;">
                        <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" id="admin-user-search" class="form-control glass border-0" placeholder="Tìm kiếm tên, email, SDT...">
                    </div>
                    <div class="d-flex gap-2" data-filter-group="role">
                        <label class="btn btn-sm glass rounded-pill px-3 mb-0">
                            <input type="checkbox" value="customer" class="d-none"> Khách hàng
                        </label>
                        <label class="btn btn-sm glass rounded-pill px-3 mb-0">
                            <input type="checkbox" value="organizer" class="d-none"> Organizer
                        </label>
                        <label class="btn btn-sm glass rounded-pill px-3 mb-0">
                            <input type="checkbox" value="admin" class="d-none"> Admin
                        </label>
                        <label class="btn btn-sm glass rounded-pill px-3 mb-0">
                            <input type="checkbox" value="support_agent" class="d-none"> Hỗ trợ viên
                        </label>
                    </div>
                    <select data-filter-select="isActive" class="form-select form-select-sm rounded-3" style="width:auto">
                        <option value="">Tất cả trạng thái</option>
                        <option value="true">Hoạt động</option>
                        <option value="false">Bị khóa</option>
                    </select>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-end mb-3 animate-on-scroll">
                <div class="d-flex align-items-center gap-2">
                    <span class="text-muted small fw-medium">Hiển thị:</span>
                    <select id="userPageSize" class="form-select form-select-sm glass border-0 rounded-3 text-center fw-bold text-primary shadow-sm" style="width: 80px; cursor: pointer;">
                        <option value="10">10</option>
                        <option value="20" selected>20</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                        <option value="200">200</option>
                    </select>
                    <span class="text-muted small">người dùng</span>
                </div>
            </div>

            <!-- Users Table -->
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Người dùng</th>
                                    <th>Email</th>
                                    <th>Vai trò</th>
                                    <th>Đăng ký</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody id="admin-users-tbody">
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <%-- Pagination --%>
                <div id="admin-users-pagination" class="card-footer bg-transparent border-0 pb-3"></div>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/ajax-table.js?v=1.2"></script>
<script>
var ctxPath = '${pageContext.request.contextPath}';
var csrfToken = '${sessionScope.csrf_token}';
var currentUserId = parseInt('${sessionScope.user != null ? sessionScope.user.userId : 0}') || 0;

function esc(v) { if (!v) return ''; var d = document.createElement('div'); d.textContent = v; return d.innerHTML; }
function fmtDate(s) {
    if (!s) return '';
    var d = new Date(s);
    return String(d.getDate()).padStart(2,'0') + '/' + String(d.getMonth()+1).padStart(2,'0') + '/' + d.getFullYear();
}
function roleStyle(role) {
    var r = (role || '').toUpperCase();
    if (r === 'ADMIN') return 'background:linear-gradient(135deg,#ef4444,#f97316);color:white;';
    if (r === 'SUPPORT_AGENT') return 'background:linear-gradient(135deg,#9333ea,#a855f7);color:white;';
    return 'background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;';
}

function handleRoleChange(select, userId) {
    var keyInput = document.getElementById('adminKey_' + userId);
    var submitBtn = document.getElementById('submitRole_' + userId);
    if (select.value === 'admin') {
        keyInput.classList.remove('d-none');
        submitBtn.classList.remove('d-none');
        keyInput.focus();
    } else {
        keyInput.classList.add('d-none');
        submitBtn.classList.add('d-none');
        keyInput.value = '';
        if (confirm('Đổi vai trò người dùng này?')) select.form.submit();
    }
}

// Toggle filter checkbox styling
document.querySelectorAll('[data-filter-group="role"] label').forEach(function(label) {
    var cb = label.querySelector('input[type="checkbox"]');
    cb.addEventListener('change', function() {
        label.classList.toggle('active', cb.checked);
        label.style.background = cb.checked ? 'var(--primary)' : '';
        label.style.color = cb.checked ? 'white' : '';
    });
});

var usersTable = new AjaxTable({
    apiUrl: ctxPath + '/api/admin/users',
    tableBody: '#admin-users-tbody',
    paginationContainer: '#admin-users-pagination',
    searchInput: '#admin-user-search',
    pageSize: 20,
    pageSizeSelector: '#userPageSize',
    skeletonCols: 6,
    debounceDelay: 500,
    renderRow: function(u) {
        var avatar = u.avatar
            ? '<img src="' + esc(u.avatar) + '" class="rounded-circle object-fit-cover shadow-sm" style="width:40px;height:40px;">'
            : '<div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold shadow-sm" style="width:40px;height:40px;background:linear-gradient(135deg,var(--primary),var(--secondary));font-size:0.85rem;">' + esc((u.fullName||'?').charAt(0)).toUpperCase() + '</div>';

        var actions = '';
        if (u.userId === currentUserId) {
            actions = '<span class="badge bg-light text-muted border">Bạn</span>';
        } else {
            var roleLower = (u.role||'').toLowerCase();
            if (!u.isDeleted) {
                actions += '<form action="' + ctxPath + '/admin/users/update-role" method="POST" class="d-flex gap-1 align-items-center">' +
                '<input type="hidden" name="csrf_token" value="' + csrfToken + '">' +
                '<input type="hidden" name="userId" value="' + u.userId + '">' +
                '<select name="role" class="form-select form-select-sm rounded-3" style="font-size:0.75rem;width:120px;" id="roleSelect_' + u.userId + '" onchange="handleRoleChange(this,' + u.userId + ')">' +
                '<option value="customer"' + (roleLower==='customer' ? ' selected' : '') + '>Khách hàng</option>' +
                '<option value="support_agent"' + (roleLower==='support_agent' ? ' selected' : '') + '>Hỗ trợ viên</option>' +
                '<option value="admin"' + (roleLower==='admin' ? ' selected' : '') + '>Admin</option>' +
                '</select>' +
                '<input type="password" name="adminKey" class="form-control form-control-sm rounded-3 d-none" id="adminKey_' + u.userId + '" style="font-size:0.75rem;width:120px;" placeholder="Mật khẩu admin">' +
                '<button type="submit" class="btn btn-sm btn-primary rounded-pill px-2 d-none" id="submitRole_' + u.userId + '"><i class="fas fa-check"></i></button></form>';
            }
            actions += '<a href="' + ctxPath + '/admin/users/' + u.userId + '" class="btn btn-sm btn-light text-primary rounded-circle shadow-sm" title="Xem chi tiết"><i class="fas fa-eye"></i></a>';
            if (u.isDeleted) {
                actions += '<span class="badge bg-secondary-subtle text-secondary border">Đã xóa</span>';
            } else if (u.isActive) {
                actions += '<form action="' + ctxPath + '/admin/users/deactivate" method="POST" class="d-inline"><input type="hidden" name="csrf_token" value="' + csrfToken + '"><input type="hidden" name="userId" value="' + u.userId + '"><button class="btn btn-sm btn-light text-warning rounded-circle shadow-sm" title="Khóa" onclick="return confirm(\'Khóa tài khoản này?\')"><i class="fas fa-ban"></i></button></form>';
            } else {
                actions += '<form action="' + ctxPath + '/admin/users/activate" method="POST" class="d-inline"><input type="hidden" name="csrf_token" value="' + csrfToken + '"><input type="hidden" name="userId" value="' + u.userId + '"><button class="btn btn-sm btn-light text-success rounded-circle shadow-sm" title="Mở khóa" onclick="return confirm(\'Mở khóa tài khoản?\')"><i class="fas fa-unlock"></i></button></form>';
            }
        }

        var statusClass = u.isDeleted ? 'bg-secondary' : (u.isActive ? 'bg-success' : 'bg-danger');
        var statusLabel = u.isDeleted ? 'Đã xóa' : (u.isActive ? 'Hoạt động' : 'Bị khóa');

        return '<tr class="hover-lift" style="transition:all 0.2s;">' +
            '<td><div class="d-flex align-items-center gap-3">' + avatar + '<span class="fw-medium">' + esc(u.fullName) + '</span></div></td>' +
            '<td class="text-muted">' + esc(u.email) + '</td>' +
            '<td><span class="badge rounded-pill px-3 py-2" style="' + roleStyle(u.role) + '">' + esc(u.role) + '</span></td>' +
            '<td class="text-muted">' + fmtDate(u.createdAt) + '</td>' +
            '<td><span class="badge ' + statusClass + ' rounded-pill px-3 py-2">' + statusLabel + '</span></td>' +
            '<td class="text-center"><div class="d-flex justify-content-center gap-2 flex-wrap">' + actions + '</div></td>' +
        '</tr>';
    }
});
usersTable.init();
</script>

<jsp:include page="../footer.jsp" />

