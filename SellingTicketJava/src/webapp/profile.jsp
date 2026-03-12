<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Bảng điều khiển" scope="request" />
<fmt:formatDate value="${userProfile.dateOfBirth}" pattern="yyyy-MM-dd" var="dobVal"/>
<jsp:include page="header.jsp" />

<style>
/* Tab animations */
.tab-content {
    animation: fadeInUp 0.3s ease;
}
.list-group-item {
    transition: all 0.3s ease;
}
.list-group-item:hover {
    background: rgba(147, 51, 234, 0.05);
    transform: translateX(5px);
}
.list-group-item.active {
    background: linear-gradient(135deg, var(--primary), var(--secondary)) !important;
    border-color: transparent !important;
}
</style>

<div class="container py-5">
    <div class="row g-4">
        <!-- Sidebar -->
        <div class="col-lg-3">
            <div class="card glass-strong border-0 rounded-4 animate-fadeInLeft position-sticky" style="top: 100px;">
                <div class="card-body text-center p-4">
                    <div class="position-relative d-inline-block mb-3">
                        <img src="${not empty userProfile.avatar ? userProfile.avatar : 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200'}" 
                             alt="Avatar" class="rounded-circle shadow" style="width: 100px; height: 100px; object-fit: cover; border: 4px solid white;">
                        <button class="btn btn-sm btn-gradient rounded-circle position-absolute bottom-0 end-0 p-0 d-flex align-items-center justify-content-center" style="width: 32px; height: 32px;">
                            <i class="fas fa-camera" style="font-size: 12px;"></i>
                        </button>
                    </div>
                    <h5 class="fw-bold mb-1">${not empty userProfile.fullName ? userProfile.fullName : sessionScope.account.fullName}</h5>
                    <p class="text-muted small mb-2">${not empty userProfile.email ? userProfile.email : sessionScope.account.email}</p>
                    <span class="badge rounded-pill px-3 py-1" style="background: linear-gradient(135deg, var(--primary), var(--secondary));">
                        <i class="fas fa-crown me-1"></i>Thành viên VIP
                    </span>
                </div>
                <hr class="my-0">
                <div class="list-group list-group-flush rounded-bottom-4">
                    <a href="#profile" onclick="showTab('profile')" class="list-group-item list-group-item-action d-flex align-items-center gap-3 py-3 active" id="tab-profile">
                        <i class="fas fa-user text-white"></i> Thông tin cá nhân
                    </a>
                    <a href="#orders" onclick="showTab('orders')" class="list-group-item list-group-item-action d-flex align-items-center gap-3 py-3" id="tab-orders">
                        <i class="fas fa-shopping-bag text-primary"></i> Lịch sử đơn hàng
                    </a>
                    <a href="#tickets" onclick="showTab('tickets')" class="list-group-item list-group-item-action d-flex align-items-center gap-3 py-3" id="tab-tickets">
                        <i class="fas fa-ticket-alt text-primary"></i> Vé của tôi
                    </a>
                    <a href="#security" onclick="showTab('security')" class="list-group-item list-group-item-action d-flex align-items-center gap-3 py-3" id="tab-security">
                        <i class="fas fa-lock text-primary"></i> Bảo mật
                    </a>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="col-lg-9">
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success rounded-4 mb-4 d-flex align-items-center gap-2">
                    <i class="fas fa-check-circle"></i>
                    <span>${sessionScope.success}</span>
                </div>
                <c:remove var="success" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger rounded-4 mb-4 d-flex align-items-center gap-2">
                    <i class="fas fa-exclamation-circle"></i>
                    <span>${sessionScope.error}</span>
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <!-- Profile Tab -->
            <div id="content-profile" class="tab-content animate-fadeInUp">
                <div class="card glass-strong border-0 rounded-4">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <h4 class="fw-bold mb-1">Thông tin cá nhân</h4>
                                <p class="text-muted mb-0 small">Quản lý thông tin hồ sơ của bạn</p>
                            </div>
                            <button class="btn btn-gradient rounded-pill px-4 hover-glow" onclick="toggleEdit()">
                                <i class="fas fa-edit me-2"></i>Chỉnh sửa
                            </button>
                        </div>
                        <form action="${pageContext.request.contextPath}/profile" method="POST">
                            <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Họ và tên</label>
                                    <div class="input-group">
                                        <span class="input-group-text glass border-end-0 rounded-start-3"><i class="fas fa-user text-primary"></i></span>
                                        <input type="text" class="form-control glass border-start-0 rounded-end-3" name="fullName" value="${not empty userProfile.fullName ? userProfile.fullName : sessionScope.account.fullName}" disabled id="input-fullName">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Email</label>
                                    <div class="input-group">
                                        <span class="input-group-text glass border-end-0 rounded-start-3"><i class="fas fa-envelope text-primary"></i></span>
                                        <input type="email" class="form-control glass border-start-0 rounded-end-3" value="${not empty userProfile.email ? userProfile.email : sessionScope.account.email}" disabled>
                                    </div>
                                    <small class="text-muted">Email không thể thay đổi</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Số điện thoại</label>
                                    <div class="input-group">
                                        <span class="input-group-text glass border-end-0 rounded-start-3"><i class="fas fa-phone text-primary"></i></span>
                                        <input type="tel" class="form-control glass border-start-0 rounded-end-3" name="phone" placeholder="0901234567" value="${not empty userProfile.phone ? userProfile.phone : ''}" disabled id="input-phone">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Ngày sinh</label>
                                    <div class="input-group">
                                        <span class="input-group-text glass border-end-0 rounded-start-3"><i class="fas fa-calendar text-primary"></i></span>
                                        <input type="date" class="form-control glass border-start-0 rounded-end-3" name="birthDate" value="${dobVal}" disabled id="input-birthDate">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Giới tính</label>
                                    <select class="form-select glass rounded-3" name="gender" disabled id="input-gender">
                                        <option value="male" ${(not empty userProfile.gender && userProfile.gender == 'male') ? 'selected' : ''}>Nam</option>
                                        <option value="female" ${(not empty userProfile.gender && userProfile.gender == 'female') ? 'selected' : ''}>Nữ</option>
                                        <option value="other" ${(not empty userProfile.gender && userProfile.gender == 'other') ? 'selected' : ''}>Khác</option>
                                    </select>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-gradient rounded-pill px-5 py-2 mt-4 d-none hover-glow" id="saveBtn">
                                <i class="fas fa-save me-2"></i>Lưu thay đổi
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Orders Tab -->
            <div id="content-orders" class="tab-content d-none">
                <div class="card glass-strong border-0 rounded-4">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                            <h4 class="fw-bold mb-0">Lịch sử đơn hàng thật</h4>
                            <input type="text" id="profileOrderSearch" class="form-control rounded-pill" style="max-width:260px" placeholder="Tìm mã đơn hoặc sự kiện...">
                        </div>
                        <div class="d-flex gap-2 mb-3" id="profileOrderFilter">
                            <button type="button" class="btn btn-sm btn-gradient rounded-pill" data-status="">Tất cả</button>
                            <button type="button" class="btn btn-sm glass rounded-pill" data-status="pending">Chờ thanh toán</button>
                            <button type="button" class="btn btn-sm glass rounded-pill" data-status="paid">Đã thanh toán</button>
                        </div>
                        <div id="profileOrdersContainer" class="d-flex flex-column gap-3"></div>
                        <div class="text-end mt-3">
                            <a href="${pageContext.request.contextPath}/my-tickets" class="btn glass rounded-pill px-4">
                                <i class="fas fa-arrow-right me-1"></i>Xem tất cả đơn & vé
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tickets Tab -->
            <div id="content-tickets" class="tab-content d-none">
                <div class="card glass-strong border-0 rounded-4">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                            <h4 class="fw-bold mb-0">Vé thật của tôi</h4>
                            <input type="text" id="profileTicketSearch" class="form-control rounded-pill" style="max-width:260px" placeholder="Tìm mã vé hoặc sự kiện...">
                        </div>
                        <div id="profileTicketsContainer" class="row g-3"></div>
                        <div class="text-end mt-3">
                            <a href="${pageContext.request.contextPath}/my-tickets" class="btn glass rounded-pill px-4">
                                <i class="fas fa-ticket-alt me-1"></i>Quản lý vé chi tiết
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Security Tab -->
            <div id="content-security" class="tab-content d-none">
                <div class="card glass-strong border-0 rounded-4">
                    <div class="card-body p-4 p-md-5">
                        <h4 class="fw-bold mb-4">Bảo mật</h4>
                        
                        <c:choose>
                        <c:when test="${sessionScope.user.oauthUser}">
                        <div class="glass p-4 rounded-4 mb-4 animate-on-scroll">
                            <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                                <i class="fas fa-lock text-primary"></i>Đổi mật khẩu
                            </h5>
                            <div class="d-flex align-items-center gap-3 p-3 rounded-3" style="background: rgba(59, 130, 246, 0.08);">
                                <i class="fab fa-google text-danger fs-4"></i>
                                <div>
                                    <p class="fw-medium mb-1">Tài khoản đăng nhập bằng Google</p>
                                    <p class="text-muted small mb-0">Mật khẩu được quản lý bởi Google. Bạn không cần đổi mật khẩu tại đây.</p>
                                </div>
                            </div>
                        </div>
                        </c:when>
                        <c:otherwise>
                        <div class="glass p-4 rounded-4 mb-4 animate-on-scroll">
                            <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                                <i class="fas fa-lock text-primary"></i>Đổi mật khẩu
                            </h5>
                            <form action="${pageContext.request.contextPath}/change-password" method="POST">
                                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                <div class="row g-3">
                                    <div class="col-12">
                                        <label class="form-label fw-medium">Mật khẩu hiện tại</label>
                                        <input type="password" class="form-control glass rounded-3 py-3" name="oldPassword" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-medium">Mật khẩu mới</label>
                                        <input type="password" class="form-control glass rounded-3 py-3" name="newPassword" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-medium">Xác nhận mật khẩu mới</label>
                                        <input type="password" class="form-control glass rounded-3 py-3" name="confirmNewPassword" required>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-gradient rounded-pill px-4 mt-4 hover-glow">Cập nhật mật khẩu</button>
                            </form>
                        </div>
                        </c:otherwise>
                        </c:choose>
                        
                        <div class="glass p-4 rounded-4 animate-on-scroll">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));">
                                        <i class="fas fa-shield-alt text-primary"></i>
                                    </div>
                                    <div>
                                        <h6 class="fw-bold mb-1">Xác thực hai yếu tố</h6>
                                        <p class="text-muted small mb-0">Tăng cường bảo mật cho tài khoản của bạn</p>
                                    </div>
                                </div>
                                <button class="btn glass rounded-pill px-4 hover-lift">Kích hoạt</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const ctxPath = '${pageContext.request.contextPath}';
let profileOrdersLoaded = false;
let profileTicketsLoaded = false;
let currentOrderStatus = '';

function showTab(tabName) {
    document.querySelectorAll('.tab-content').forEach(c => c.classList.add('d-none'));
    document.querySelectorAll('.list-group-item').forEach(t => {
        t.classList.remove('active');
        t.querySelector('i').classList.remove('text-white');
        t.querySelector('i').classList.add('text-primary');
    });
    
    const content = document.getElementById('content-' + tabName);
    const tab = document.getElementById('tab-' + tabName);
    
    content.classList.remove('d-none');
    tab.classList.add('active');
    tab.querySelector('i').classList.remove('text-primary');
    tab.querySelector('i').classList.add('text-white');

    if (tabName === 'orders' && !profileOrdersLoaded) {
        loadProfileOrders();
    }
    if (tabName === 'tickets' && !profileTicketsLoaded) {
        loadProfileTickets();
    }
}

function toggleEdit() {
    const inputs = ['fullName', 'phone', 'birthDate', 'gender'];
    let isEditing = false;
    
    inputs.forEach(id => {
        const el = document.getElementById('input-' + id);
        if (el) {
            el.disabled = !el.disabled;
            isEditing = !el.disabled;
        }
    });
    
    document.getElementById('saveBtn').classList.toggle('d-none', !isEditing);
}

function esc(v) {
    if (!v) return '';
    const d = document.createElement('div');
    d.textContent = v;
    return d.innerHTML;
}

function fmtMoney(v) {
    return Number(v || 0).toLocaleString('vi-VN') + 'đ';
}

function fmtDate(v) {
    if (!v) return '';
    const d = new Date(v);
    const p = (n) => String(n).padStart(2, '0');
    return p(d.getDate()) + '/' + p(d.getMonth() + 1) + '/' + d.getFullYear() + ' ' + p(d.getHours()) + ':' + p(d.getMinutes());
}

function orderStatusBadge(status) {
    if (status === 'pending') {
        return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#f59e0b,#d97706);color:white;"><i class="fas fa-clock me-1"></i>Chờ thanh toán</span>';
    }
    if (status === 'paid' || status === 'checked_in') {
        return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;"><i class="fas fa-check-circle me-1"></i>Đã thanh toán</span>';
    }
    if (status === 'cancelled') {
        return '<span class="badge bg-danger rounded-pill px-3 py-2"><i class="fas fa-times-circle me-1"></i>Đã hủy</span>';
    }
    return '<span class="badge bg-secondary rounded-pill px-3 py-2">' + esc(status) + '</span>';
}

async function loadProfileOrders() {
    const q = document.getElementById('profileOrderSearch').value.trim();
    const params = new URLSearchParams({ page: '1', size: '6' });
    if (q) params.set('q', q);
    if (currentOrderStatus) params.append('status', currentOrderStatus);

    const container = document.getElementById('profileOrdersContainer');
    container.innerHTML = '<div class="text-muted">Đang tải đơn hàng...</div>';

    try {
        const res = await fetch(ctxPath + '/api/my-orders?' + params.toString(), { credentials: 'same-origin', headers: { 'Accept': 'application/json' } });
        if (!res.ok) throw new Error('HTTP ' + res.status);
        const contentType = res.headers.get('content-type') || '';
        if (!contentType.includes('application/json')) throw new Error('Invalid response');
        const data = await res.json();
        const items = data.items || [];

        if (!items.length) {
            container.innerHTML = '<div class="glass p-4 rounded-4 text-center text-muted">Chưa có đơn hàng phù hợp.</div>';
            profileOrdersLoaded = true;
            return;
        }

        container.innerHTML = items.map(o => {
            const summary = (o.items || []).map(it => esc(it.ticketTypeName) + ' x' + it.quantity).join(' • ');
            const pendingAction = o.status === 'pending'
                ? '<a href="' + ctxPath + '/resume-payment?orderId=' + o.orderId + '" class="btn btn-sm rounded-pill px-3" style="background:linear-gradient(135deg,#f59e0b,#d97706);color:white;border:none;"><i class="fas fa-credit-card me-1"></i>Thanh toán ngay</a>'
                : '';
            return '<div class="glass p-4 rounded-4 hover-lift">' +
                '<div class="d-flex justify-content-between align-items-start flex-wrap gap-3">' +
                    '<div>' +
                        '<h6 class="fw-bold mb-1">' + esc(o.eventTitle) + '</h6>' +
                        '<p class="text-muted small mb-1">Mã đơn: ' + esc(o.orderCode) + ' • ' + fmtDate(o.createdAt) + '</p>' +
                        '<p class="text-muted small mb-0">' + (summary || 'Không có chi tiết vé') + '</p>' +
                    '</div>' +
                    '<div class="text-end">' +
                        orderStatusBadge(o.status) +
                        '<div class="fw-bold text-primary mt-2">' + fmtMoney(o.finalAmount) + '</div>' +
                    '</div>' +
                '</div>' +
                (pendingAction ? '<div class="mt-3">' + pendingAction + '</div>' : '') +
            '</div>';
        }).join('');

        profileOrdersLoaded = true;
    } catch (e) {
        container.innerHTML = '<div class="glass p-4 rounded-4 text-danger">Không tải được dữ liệu đơn hàng thật. Vui lòng thử lại.</div>';
    }
}

async function loadProfileTickets() {
    const q = document.getElementById('profileTicketSearch').value.trim();
    const params = new URLSearchParams({ page: '1', size: '6' });
    if (q) params.set('q', q);

    const container = document.getElementById('profileTicketsContainer');
    container.innerHTML = '<div class="text-muted">Đang tải vé...</div>';

    try {
        const res = await fetch(ctxPath + '/api/my-tickets?' + params.toString(), { credentials: 'same-origin', headers: { 'Accept': 'application/json' } });
        if (!res.ok) throw new Error('HTTP ' + res.status);
        const contentType = res.headers.get('content-type') || '';
        if (!contentType.includes('application/json')) throw new Error('Invalid response');
        const data = await res.json();
        const items = data.items || [];

        if (!items.length) {
            container.innerHTML = '<div class="col-12"><div class="glass p-4 rounded-4 text-center text-muted">Chưa có vé nào.</div></div>';
            profileTicketsLoaded = true;
            return;
        }

        container.innerHTML = items.map(t => {
            const status = t.orderStatus === 'pending'
                ? '<span class="badge rounded-pill px-2 py-1" style="background:linear-gradient(135deg,#f59e0b,#d97706);color:white;">Chờ TT</span>'
                : (t.isCheckedIn
                    ? '<span class="badge bg-danger rounded-pill px-2 py-1">Đã dùng</span>'
                    : '<span class="badge rounded-pill px-2 py-1" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;">Hiệu lực</span>');

            return '<div class="col-md-6">' +
                '<div class="card glass border-0 rounded-4 h-100 hover-lift">' +
                    '<div class="card-body p-3">' +
                        '<div class="d-flex justify-content-between align-items-start mb-2">' +
                            '<div>' +
                                '<h6 class="fw-bold mb-1">' + esc(t.eventTitle) + '</h6>' +
                                '<div class="text-muted small">' + esc(t.ticketTypeName) + '</div>' +
                            '</div>' + status +
                        '</div>' +
                        '<div class="small text-muted mb-2">Mã vé: <span class="font-monospace">' + esc(t.ticketCode) + '</span></div>' +
                        '<div class="small text-muted mb-3">Đặt lúc: ' + fmtDate(t.createdAt) + '</div>' +
                        '<a href="' + ctxPath + '/my-tickets" class="btn btn-sm btn-gradient rounded-pill px-3"><i class="fas fa-qrcode me-1"></i>Xem QR chi tiết</a>' +
                    '</div>' +
                '</div>' +
            '</div>';
        }).join('');

        profileTicketsLoaded = true;
    } catch (e) {
        container.innerHTML = '<div class="col-12"><div class="glass p-4 rounded-4 text-danger">Không tải được dữ liệu vé thật. Vui lòng thử lại.</div></div>';
    }
}

document.getElementById('profileOrderSearch')?.addEventListener('input', function() {
    clearTimeout(window.__profileOrderTimer);
    window.__profileOrderTimer = setTimeout(loadProfileOrders, 300);
});

document.querySelectorAll('#profileOrderFilter [data-status]').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('#profileOrderFilter button').forEach(b => {
            b.classList.remove('btn-gradient');
            b.classList.add('glass');
        });
        this.classList.remove('glass');
        this.classList.add('btn-gradient');
        currentOrderStatus = this.dataset.status || '';
        loadProfileOrders();
    });
});

document.getElementById('profileTicketSearch')?.addEventListener('input', function() {
    clearTimeout(window.__profileTicketTimer);
    window.__profileTicketTimer = setTimeout(loadProfileTickets, 300);
});
</script>

<jsp:include page="footer.jsp" />
