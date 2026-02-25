<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <%-- Sidebar --%>
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="settings"/>
            </jsp:include>
        </div>

        <%-- Main Content --%>
        <div class="col-lg-10">
            <div class="animate-fadeInDown">
                <h2 class="fw-bold mb-2"><i class="fas fa-cog text-primary me-2"></i>Cài đặt hệ thống</h2>
                <p class="text-muted mb-4">Quản lý cấu hình toàn hệ thống</p>
            </div>

            <%-- Tabs --%>
            <ul class="nav nav-tabs-glass mb-4" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#general" type="button">
                        <i class="fas fa-sliders-h me-2"></i>Chung
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#payment" type="button">
                        <i class="fas fa-credit-card me-2"></i>Thanh toán
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#email" type="button">
                        <i class="fas fa-envelope me-2"></i>Email
                    </button>
                </li>
            </ul>

            <form method="POST" action="${pageContext.request.contextPath}/admin/settings">
                <div class="tab-content">
                    <%-- General Tab --%>
                    <div class="tab-pane fade show active" id="general" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-globe text-primary me-2"></i>Cấu hình chung</h5>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Tên website</label>
                                        <input type="text" class="form-control glass-input rounded-3" name="siteName" value="SellingTicket" placeholder="Tên trang web">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Ngôn ngữ mặc định</label>
                                        <select class="form-select glass-input rounded-3" name="language">
                                            <option value="vi" selected>Tiếng Việt</option>
                                            <option value="en">English</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Đơn vị tiền tệ</label>
                                        <select class="form-select glass-input rounded-3" name="currency">
                                            <option value="VND" selected>VND (₫)</option>
                                            <option value="USD">USD ($)</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Múi giờ</label>
                                        <select class="form-select glass-input rounded-3" name="timezone">
                                            <option value="Asia/Ho_Chi_Minh" selected>Asia/Ho_Chi_Minh (UTC+7)</option>
                                        </select>
                                    </div>
                                </div>

                                <hr style="border-color: rgba(0,0,0,0.06);">

                                <h6 class="fw-bold mb-3">Chính sách sự kiện</h6>
                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Yêu cầu duyệt sự kiện</p>
                                        <p class="text-muted small mb-0">Sự kiện mới cần admin duyệt trước khi hiển thị</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="requireApproval" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center py-3">
                                    <div>
                                        <p class="fw-medium mb-1">Cho phép đăng ký organizer</p>
                                        <p class="text-muted small mb-0">Người dùng có thể tự đăng ký làm ban tổ chức</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="allowOrganizerReg" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Payment Tab --%>
                    <div class="tab-pane fade" id="payment" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-credit-card text-primary me-2"></i>Cổng thanh toán</h5>

                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="rounded-3 p-2" style="background: rgba(59,130,246,0.1);">
                                            <i class="fas fa-wallet fa-lg text-primary"></i>
                                        </div>
                                        <div>
                                            <p class="fw-medium mb-0">VNPay</p>
                                            <small class="text-muted">Cổng thanh toán nội địa</small>
                                        </div>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center py-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="rounded-3 p-2" style="background: rgba(16,185,129,0.1);">
                                            <i class="fas fa-qrcode fa-lg text-success"></i>
                                        </div>
                                        <div>
                                            <p class="fw-medium mb-0">Chuyển khoản ngân hàng</p>
                                            <small class="text-muted">Thanh toán bằng QR code</small>
                                        </div>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Email Tab --%>
                    <div class="tab-pane fade" id="email" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-envelope text-primary me-2"></i>Cấu hình Email</h5>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">SMTP Server</label>
                                        <input type="text" class="form-control glass-input rounded-3" name="smtpHost" placeholder="smtp.gmail.com">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Port</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="smtpPort" placeholder="587">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Email gửi</label>
                                        <input type="email" class="form-control glass-input rounded-3" name="smtpEmail" placeholder="noreply@sellingticket.com">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Mật khẩu</label>
                                        <input type="password" class="form-control glass-input rounded-3" name="smtpPassword" placeholder="••••••••">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Save Button --%>
                <div class="text-end mt-4">
                    <button type="submit" class="btn btn-gradient rounded-pill px-4 hover-glow">
                        <i class="fas fa-save me-2"></i>Lưu thay đổi
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
