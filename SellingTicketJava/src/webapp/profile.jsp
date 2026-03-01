<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

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
                        <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200" 
                             alt="Avatar" class="rounded-circle shadow" style="width: 100px; height: 100px; object-fit: cover; border: 4px solid white;">
                        <button class="btn btn-sm btn-gradient rounded-circle position-absolute bottom-0 end-0 p-0 d-flex align-items-center justify-content-center" style="width: 32px; height: 32px;">
                            <i class="fas fa-camera" style="font-size: 12px;"></i>
                        </button>
                    </div>
                    <h5 class="fw-bold mb-1">${sessionScope.account.fullName}</h5>
                    <p class="text-muted small mb-2">${sessionScope.account.email}</p>
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
                                        <input type="text" class="form-control glass border-start-0 rounded-end-3" name="fullName" value="${sessionScope.account.fullName}" disabled id="input-fullName">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Email</label>
                                    <div class="input-group">
                                        <span class="input-group-text glass border-end-0 rounded-start-3"><i class="fas fa-envelope text-primary"></i></span>
                                        <input type="email" class="form-control glass border-start-0 rounded-end-3" value="${sessionScope.account.email}" disabled>
                                    </div>
                                    <small class="text-muted">Email không thể thay đổi</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Số điện thoại</label>
                                    <div class="input-group">
                                        <span class="input-group-text glass border-end-0 rounded-start-3"><i class="fas fa-phone text-primary"></i></span>
                                        <input type="tel" class="form-control glass border-start-0 rounded-end-3" name="phone" placeholder="0901234567" disabled id="input-phone">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Ngày sinh</label>
                                    <div class="input-group">
                                        <span class="input-group-text glass border-end-0 rounded-start-3"><i class="fas fa-calendar text-primary"></i></span>
                                        <input type="date" class="form-control glass border-start-0 rounded-end-3" name="birthDate" disabled id="input-birthDate">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Giới tính</label>
                                    <select class="form-select glass rounded-3" name="gender" disabled id="input-gender">
                                        <option value="male">Nam</option>
                                        <option value="female">Nữ</option>
                                        <option value="other">Khác</option>
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
                        <h4 class="fw-bold mb-4">Lịch sử đơn hàng</h4>
                        <div class="d-flex flex-column gap-3" data-stagger-children="0.1">
                            <div class="glass p-4 rounded-4 animate-on-scroll hover-lift">
                                <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
                                    <div class="d-flex gap-3">
                                        <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=200" class="rounded-3" style="width: 70px; height: 70px; object-fit: cover;">
                                        <div>
                                            <h6 class="fw-bold mb-1">Đêm nhạc Acoustic - Những bản tình ca</h6>
                                            <p class="text-muted small mb-1">Mã đơn: TB2026021501234 • 15/02/2026</p>
                                            <p class="text-muted small mb-0">3 vé • <span class="fw-bold text-primary">1.850.000 đ</span></p>
                                        </div>
                                    </div>
                                    <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #06b6d4);">
                                        <i class="fas fa-check-circle me-1"></i>Đã xác nhận
                                    </span>
                                </div>
                            </div>
                            <div class="glass p-4 rounded-4 animate-on-scroll hover-lift">
                                <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
                                    <div class="d-flex gap-3">
                                        <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=200" class="rounded-3" style="width: 70px; height: 70px; object-fit: cover;">
                                        <div>
                                            <h6 class="fw-bold mb-1">Workshop UI/UX Design</h6>
                                            <p class="text-muted small mb-1">Mã đơn: TB2026011587654 • 20/01/2026</p>
                                            <p class="text-muted small mb-0">1 vé • <span class="fw-bold text-primary">500.000 đ</span></p>
                                        </div>
                                    </div>
                                    <span class="badge bg-secondary rounded-pill px-3 py-2">
                                        <i class="fas fa-check me-1"></i>Hoàn thành
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tickets Tab -->
            <div id="content-tickets" class="tab-content d-none">
                <h4 class="fw-bold mb-4 animate-fadeInUp">Vé của tôi</h4>
                <div class="row g-4" data-stagger-children="0.1">
                    <div class="col-md-6 animate-on-scroll">
                        <div class="card glass-strong border-0 rounded-4 overflow-hidden hover-lift card-3d">
                            <div class="position-relative">
                                <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400" class="card-img-top" style="height: 140px; object-fit: cover;">
                                <div class="position-absolute top-0 end-0 m-3">
                                    <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, var(--primary), var(--secondary));">Sắp diễn ra</span>
                                </div>
                            </div>
                            <div class="card-body p-4">
                                <h6 class="fw-bold mb-3">Đêm nhạc Acoustic</h6>
                                <div class="text-muted small mb-3">
                                    <div class="mb-1"><i class="far fa-calendar me-2"></i>15/02/2026</div>
                                    <div class="mb-1"><i class="far fa-clock me-2"></i>19:00</div>
                                    <div><i class="fas fa-map-marker-alt me-2"></i>Nhà hát Thành phố</div>
                                </div>
                                <hr>
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <small class="text-muted">Vé VIP</small>
                                        <p class="fw-bold mb-0">Ghế A5</p>
                                    </div>
                                    <button class="btn btn-gradient btn-sm rounded-pill px-3 hover-glow">
                                        <i class="fas fa-qrcode me-1"></i>Xem QR
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Security Tab -->
            <div id="content-security" class="tab-content d-none">
                <div class="card glass-strong border-0 rounded-4">
                    <div class="card-body p-4 p-md-5">
                        <h4 class="fw-bold mb-4">Bảo mật</h4>
                        
                        <div class="glass p-4 rounded-4 mb-4 animate-on-scroll">
                            <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                                <i class="fas fa-lock text-primary"></i>Đổi mật khẩu
                            </h5>
                            <form action="${pageContext.request.contextPath}/change-password" method="POST">
                                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                <div class="row g-3">
                                    <div class="col-12">
                                        <label class="form-label fw-medium">Mật khẩu hiện tại</label>
                                        <input type="password" class="form-control glass rounded-3 py-3" name="currentPassword" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-medium">Mật khẩu mới</label>
                                        <input type="password" class="form-control glass rounded-3 py-3" name="newPassword" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-medium">Xác nhận mật khẩu mới</label>
                                        <input type="password" class="form-control glass rounded-3 py-3" name="confirmPassword" required>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-gradient rounded-pill px-4 mt-4 hover-glow">Cập nhật mật khẩu</button>
                            </form>
                        </div>
                        
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
</script>

<jsp:include page="footer.jsp" />
