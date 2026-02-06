<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="settings"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <h2 class="fw-bold mb-2">Cài đặt hệ thống</h2>
            <p class="text-muted mb-4">Cấu hình toàn cục cho nền tảng</p>

            <!-- Tabs -->
            <ul class="nav nav-tabs-glass mb-4" id="settingsTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="general-tab" data-bs-toggle="tab" data-bs-target="#general" type="button" role="tab">
                        <i class="fas fa-sliders-h me-2"></i>Chung
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="payment-tab" data-bs-toggle="tab" data-bs-target="#payment" type="button" role="tab">
                        <i class="fas fa-credit-card me-2"></i>Thanh toán
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="email-tab" data-bs-toggle="tab" data-bs-target="#email" type="button" role="tab">
                        <i class="fas fa-envelope me-2"></i>Email
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="security-tab" data-bs-toggle="tab" data-bs-target="#security" type="button" role="tab">
                        <i class="fas fa-shield-alt me-2"></i>Bảo mật
                    </button>
                </li>
            </ul>

            <!-- Tab Content -->
            <div class="tab-content" id="settingsTabContent">
                <!-- General Tab -->
                <div class="tab-pane fade show active" id="general" role="tabpanel">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4">Thông tin website</h5>
                            <form>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Tên website</label>
                                        <input type="text" class="form-control glass-input rounded-3" value="TicketBox">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Tagline</label>
                                        <input type="text" class="form-control glass-input rounded-3" value="Nền tảng bán vé sự kiện hàng đầu">
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-medium">Mô tả SEO</label>
                                    <textarea class="form-control glass-input rounded-3" rows="2">TicketBox là nền tảng mua bán vé sự kiện trực tuyến số 1 Việt Nam.</textarea>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Email hỗ trợ</label>
                                        <input type="email" class="form-control glass-input rounded-3" value="support@ticketbox.vn">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Hotline</label>
                                        <input type="tel" class="form-control glass-input rounded-3" value="1900 1234">
                                    </div>
                                </div>
                                <hr class="my-4">
                                <h5 class="fw-bold mb-4">Phí dịch vụ</h5>
                                <div class="row">
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-medium">Phí platform (%)</label>
                                        <input type="number" class="form-control glass-input rounded-3" value="5" min="0" max="50">
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-medium">Phí thanh toán (%)</label>
                                        <input type="number" class="form-control glass-input rounded-3" value="2.5" min="0" max="10" step="0.1">
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-medium">Thuế VAT (%)</label>
                                        <input type="number" class="form-control glass-input rounded-3" value="10" min="0" max="20">
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Payment Tab -->
                <div class="tab-pane fade" id="payment" role="tabpanel">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4">Cổng thanh toán</h5>
                            
                            <div class="settings-item">
                                <div class="d-flex align-items-center gap-3">
                                    <img src="https://upload.wikimedia.org/wikipedia/commons/5/55/Logo_VNPAY.png" alt="VNPAY" height="32">
                                    <div>
                                        <p class="fw-medium mb-0">VNPAY</p>
                                        <small class="text-muted">Thẻ nội địa, QR Code</small>
                                    </div>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                            
                            <div class="settings-item">
                                <div class="d-flex align-items-center gap-3">
                                    <img src="https://upload.wikimedia.org/wikipedia/commons/b/b0/MOMO_Logo.png" alt="MoMo" height="32">
                                    <div>
                                        <p class="fw-medium mb-0">MoMo</p>
                                        <small class="text-muted">Ví điện tử MoMo</small>
                                    </div>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                            
                            <div class="settings-item">
                                <div class="d-flex align-items-center gap-3">
                                    <i class="fab fa-cc-visa fa-2x text-primary"></i>
                                    <div>
                                        <p class="fw-medium mb-0">Visa / Mastercard</p>
                                        <small class="text-muted">Thẻ quốc tế</small>
                                    </div>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                            
                            <div class="settings-item">
                                <div class="d-flex align-items-center gap-3">
                                    <i class="fas fa-university fa-2x text-primary"></i>
                                    <div>
                                        <p class="fw-medium mb-0">Chuyển khoản ngân hàng</p>
                                        <small class="text-muted">Bank Transfer</small>
                                    </div>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Email Tab -->
                <div class="tab-pane fade" id="email" role="tabpanel">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4">Cấu hình SMTP</h5>
                            <form>
                                <div class="row">
                                    <div class="col-md-8 mb-3">
                                        <label class="form-label fw-medium">SMTP Host</label>
                                        <input type="text" class="form-control glass-input rounded-3" value="smtp.gmail.com">
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-medium">Port</label>
                                        <input type="number" class="form-control glass-input rounded-3" value="587">
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Username</label>
                                        <input type="text" class="form-control glass-input rounded-3" value="noreply@ticketbox.vn">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Password</label>
                                        <input type="password" class="form-control glass-input rounded-3" value="********">
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">From Name</label>
                                        <input type="text" class="form-control glass-input rounded-3" value="TicketBox">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">From Email</label>
                                        <input type="email" class="form-control glass-input rounded-3" value="noreply@ticketbox.vn">
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <button type="button" class="btn btn-outline-primary rounded-pill">
                                        <i class="fas fa-paper-plane me-2"></i>Gửi email test
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Security Tab -->
                <div class="tab-pane fade" id="security" role="tabpanel">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4">Bảo mật</h5>
                            
                            <div class="settings-item">
                                <div>
                                    <p class="fw-medium mb-1">Xác thực 2 bước (2FA)</p>
                                    <p class="text-muted small mb-0">Bắt buộc 2FA cho tài khoản admin</p>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                            
                            <div class="settings-item">
                                <div>
                                    <p class="fw-medium mb-1">reCAPTCHA</p>
                                    <p class="text-muted small mb-0">Bật xác minh CAPTCHA khi đăng nhập</p>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                            
                            <div class="settings-item">
                                <div>
                                    <p class="fw-medium mb-1">Giới hạn đăng nhập thất bại</p>
                                    <p class="text-muted small mb-0">Khóa tài khoản sau 5 lần đăng nhập sai</p>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                            
                            <div class="settings-item">
                                <div>
                                    <p class="fw-medium mb-1">Session timeout</p>
                                    <p class="text-muted small mb-0">Tự động đăng xuất sau thời gian không hoạt động</p>
                                </div>
                                <select class="form-select glass-input rounded-3" style="width: 150px;">
                                    <option value="15">15 phút</option>
                                    <option value="30" selected>30 phút</option>
                                    <option value="60">60 phút</option>
                                    <option value="120">2 giờ</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Save Button -->
            <div class="text-end mt-4">
                <button type="button" class="btn btn-gradient rounded-pill px-4">
                    <i class="fas fa-save me-2"></i>Lưu thay đổi
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
