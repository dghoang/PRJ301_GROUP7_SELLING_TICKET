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

            <%-- Toast Notification from session --%>
            <c:if test="${not empty sessionScope.toastMessage}">
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="background: rgba(${sessionScope.toastType == 'success' ? '16,185,129' : '239,68,68'},0.1);
                            border-left: 4px solid ${sessionScope.toastType == 'success' ? '#10b981' : '#ef4444'} !important;">
                    <i class="fas ${sessionScope.toastType == 'success' ? 'fa-check-circle text-success' : 'fa-exclamation-circle text-danger'} me-2"></i>
                    ${sessionScope.toastMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="toastMessage" scope="session"/>
                <c:remove var="toastType" scope="session"/>
            </c:if>

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
                <li class="nav-item" role="presentation">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#display" type="button">
                        <i class="fas fa-tv me-2"></i>Hiển thị
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#security" type="button">
                        <i class="fas fa-shield-alt me-2"></i>Bảo mật
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#notifications" type="button">
                        <i class="fas fa-bell me-2"></i>Thông báo
                    </button>
                </li>
            </ul>

            <form method="POST" action="${pageContext.request.contextPath}/admin/settings">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
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

                    <%-- Display Tab --%>
                    <div class="tab-pane fade" id="display" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-tv text-primary me-2"></i>Cài đặt hiển thị sự kiện</h5>

                                <h6 class="fw-bold mb-3">📌 Sắp xếp & Ghim sự kiện</h6>
                                <p class="text-muted small mb-3">Kéo thả để thay đổi thứ tự ưu tiên hiển thị trên trang chủ</p>

                                <ul id="sortableList" class="list-unstyled mb-3" style="max-width: 600px;">
                                    <li class="sort-item d-flex align-items-center gap-3 p-3 mb-2 rounded-3" draggable="true" data-value="pinned" style="background: rgba(147,51,234,0.06); border: 1px solid rgba(147,51,234,0.15); cursor: grab;">
                                        <i class="fas fa-grip-vertical text-muted"></i>
                                        <span class="badge rounded-circle d-flex align-items-center justify-content-center" style="width:28px;height:28px;background:linear-gradient(135deg,#9333ea,#db2777);color:white;font-size:11px;">1</span>
                                        <div class="flex-grow-1">
                                            <div class="fw-bold small">📌 Ghim trước</div>
                                            <div class="text-muted" style="font-size:0.75rem;">Sự kiện admin ghim sẽ luôn ở trên cùng</div>
                                        </div>
                                        <div class="form-check form-switch"><input class="form-check-input" type="checkbox" checked style="width:2rem;height:1rem;"></div>
                                    </li>
                                    <li class="sort-item d-flex align-items-center gap-3 p-3 mb-2 rounded-3" draggable="true" data-value="best_sellers" style="background: rgba(239,68,68,0.06); border: 1px solid rgba(239,68,68,0.15); cursor: grab;">
                                        <i class="fas fa-grip-vertical text-muted"></i>
                                        <span class="badge rounded-circle d-flex align-items-center justify-content-center" style="width:28px;height:28px;background:linear-gradient(135deg,#ef4444,#f97316);color:white;font-size:11px;">2</span>
                                        <div class="flex-grow-1">
                                            <div class="fw-bold small">🔥 Bán chạy nhất</div>
                                            <div class="text-muted" style="font-size:0.75rem;">Ưu tiên sự kiện có tỉ lệ bán cao</div>
                                        </div>
                                        <div class="form-check form-switch"><input class="form-check-input" type="checkbox" checked style="width:2rem;height:1rem;"></div>
                                    </li>
                                    <li class="sort-item d-flex align-items-center gap-3 p-3 mb-2 rounded-3" draggable="true" data-value="newest" style="background: rgba(16,185,129,0.06); border: 1px solid rgba(16,185,129,0.15); cursor: grab;">
                                        <i class="fas fa-grip-vertical text-muted"></i>
                                        <span class="badge rounded-circle d-flex align-items-center justify-content-center" style="width:28px;height:28px;background:linear-gradient(135deg,#10b981,#06b6d4);color:white;font-size:11px;">3</span>
                                        <div class="flex-grow-1">
                                            <div class="fw-bold small">🆕 Mới nhất</div>
                                            <div class="text-muted" style="font-size:0.75rem;">Sự kiện vừa được duyệt hiện trước</div>
                                        </div>
                                        <div class="form-check form-switch"><input class="form-check-input" type="checkbox" checked style="width:2rem;height:1rem;"></div>
                                    </li>
                                    <li class="sort-item d-flex align-items-center gap-3 p-3 mb-2 rounded-3" draggable="true" data-value="nearest_expiry" style="background: rgba(245,158,11,0.06); border: 1px solid rgba(245,158,11,0.15); cursor: grab;">
                                        <i class="fas fa-grip-vertical text-muted"></i>
                                        <span class="badge rounded-circle d-flex align-items-center justify-content-center" style="width:28px;height:28px;background:linear-gradient(135deg,#f59e0b,#d97706);color:white;font-size:11px;">4</span>
                                        <div class="flex-grow-1">
                                            <div class="fw-bold small">⏰ Gần hết hạn</div>
                                            <div class="text-muted" style="font-size:0.75rem;">Sự kiện chuẩn bị diễn ra → tạo urgency</div>
                                        </div>
                                        <div class="form-check form-switch"><input class="form-check-input" type="checkbox" checked style="width:2rem;height:1rem;"></div>
                                    </li>
                                    <li class="sort-item d-flex align-items-center gap-3 p-3 mb-2 rounded-3" draggable="true" data-value="price_low" style="background: rgba(59,130,246,0.06); border: 1px solid rgba(59,130,246,0.15); cursor: grab;">
                                        <i class="fas fa-grip-vertical text-muted"></i>
                                        <span class="badge rounded-circle d-flex align-items-center justify-content-center" style="width:28px;height:28px;background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;font-size:11px;">5</span>
                                        <div class="flex-grow-1">
                                            <div class="fw-bold small">💰 Giá thấp → cao</div>
                                            <div class="text-muted" style="font-size:0.75rem;">Hiển thị theo giá tăng dần</div>
                                        </div>
                                        <div class="form-check form-switch"><input class="form-check-input" type="checkbox" style="width:2rem;height:1rem;"></div>
                                    </li>
                                </ul>
                                <input type="hidden" name="sortRanking" id="sortRanking" value="pinned,best_sellers,newest,nearest_expiry,price_low">

                                <div class="row g-3 mb-3">
                                    <div class="col-md-4">
                                        <label class="form-label fw-medium">Số sự kiện nổi bật</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="featuredCount" value="6" min="1" max="20">
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-medium">Sự kiện/trang</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="eventsPerPage" value="12" min="6" max="48" step="6">
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-medium">Banner xoay (giây)</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="bannerInterval" value="5" min="3" max="15">
                                    </div>
                                </div>

                                <hr style="border-color: rgba(0,0,0,0.06);">
                                <h6 class="fw-bold mb-3">🔧 Quy tắc hiển thị</h6>

                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Tự động ẩn sự kiện hết hạn</p>
                                        <p class="text-muted small mb-0">Sự kiện đã qua ngày sẽ không xuất hiện trên trang công khai</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="autoHideExpired" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Hiển thị số vé còn lại</p>
                                        <p class="text-muted small mb-0">Người dùng thấy số vé con trên thẻ sự kiện</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="showRemaining" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Hiển thị countdown trên thẻ</p>
                                        <p class="text-muted small mb-0">Bộ đếm ngược trên thẻ sự kiện tạo cảm giác gấp rút</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="showCountdown" style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center py-3">
                                    <div>
                                        <p class="fw-medium mb-1">Sắp xếp thông minh (AI)</p>
                                        <p class="text-muted small mb-0">Tự động ưu tiên sự kiện có tỉ lệ chuyển đổi cao</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="smartSort" style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>

                    <%-- Security Tab --%>
                    <div class="tab-pane fade" id="security" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-shield-alt text-primary me-2"></i>Cài đặt bảo mật</h5>

                                <h6 class="fw-bold mb-3">Chính sách mật khẩu</h6>
                                <div class="row g-3 mb-4">
                                    <div class="col-md-4">
                                        <label class="form-label fw-medium">Chiều dài tối thiểu</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="minPasswordLength" value="8" min="6" max="32">
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-medium">Chiều dài tối đa</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="maxPasswordLength" value="128" min="16" max="256">
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-medium">Độ phức tạp</label>
                                        <select class="form-select glass-input rounded-3" name="passwordComplexity">
                                            <option value="basic">Cơ bản (chữ + số)</option>
                                            <option value="medium" selected>Trung bình (+ ký tự đặc biệt)</option>
                                            <option value="strong">Mạnh (+ chữ hoa/thường)</option>
                                        </select>
                                    </div>
                                </div>

                                <hr style="border-color: rgba(0,0,0,0.06);">
                                <h6 class="fw-bold mb-3">Phiên đăng nhập</h6>
                                <div class="row g-3 mb-4">
                                    <div class="col-md-6">
                                        <label class="form-label fw-medium">Session timeout (phút)</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="sessionTimeout" value="30" min="5" max="1440">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-medium">Số lần đăng nhập sai tối đa</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="maxLoginAttempts" value="5" min="3" max="20">
                                    </div>
                                </div>

                                <hr style="border-color: rgba(0,0,0,0.06);">
                                <h6 class="fw-bold mb-3">Tùy chọn nâng cao</h6>
                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Khóa tài khoản sau nhiều lần sai</p>
                                        <p class="text-muted small mb-0">Tự động khóa 15 phút sau khi vượt giới hạn</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="lockOnFailure" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Rate limiting theo IP</p>
                                        <p class="text-muted small mb-0">Giới hạn số request từ một IP để chống brute-force</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="ipRateLimit" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center py-3">
                                    <div>
                                        <p class="fw-medium mb-1">Chống open redirect</p>
                                        <p class="text-muted small mb-0">Chỉ cho phép redirect đến URL nội bộ</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="preventOpenRedirect" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Notifications Tab --%>
                    <div class="tab-pane fade" id="notifications" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-bell text-primary me-2"></i>Cài đặt thông báo</h5>

                                <h6 class="fw-bold mb-3">Email thông báo</h6>
                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Đơn hàng mới</p>
                                        <p class="text-muted small mb-0">Gửi email khi có đơn hàng mới</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="notifyNewOrder" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Sự kiện chờ duyệt</p>
                                        <p class="text-muted small mb-0">Thông báo admin khi có sự kiện mới chờ xét duyệt</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="notifyPendingEvent" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Kết quả duyệt sự kiện</p>
                                        <p class="text-muted small mb-0">Gửi email cho organizer khi sự kiện được duyệt/từ chối</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="notifyEventResult" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center py-3" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Đăng ký người dùng mới</p>
                                        <p class="text-muted small mb-0">Thông báo khi có người dùng đăng ký tài khoản</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="notifyNewUser" style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <hr style="border-color: rgba(0,0,0,0.06);">
                                <h6 class="fw-bold mb-3">Thông báo trong app</h6>
                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Bật thông báo realtime</p>
                                        <p class="text-muted small mb-0">Hiển thị thông báo trực tiếp trên dashboard</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="realtimeNotify" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center py-3">
                                    <div>
                                        <p class="fw-medium mb-1">Báo cáo hàng tuần</p>
                                        <p class="text-muted small mb-0">Gửi email tổng kết hàng tuần cho admin</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="weeklyReport" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
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

<script>
// Drag-and-drop sortable list
(function() {
    var list = document.getElementById('sortableList');
    if (!list) return;
    var dragItem = null;

    list.querySelectorAll('.sort-item').forEach(function(item) {
        item.addEventListener('dragstart', function(e) {
            dragItem = this;
            this.style.opacity = '0.4';
            e.dataTransfer.effectAllowed = 'move';
        });
        item.addEventListener('dragend', function() {
            this.style.opacity = '1';
            dragItem = null;
            list.querySelectorAll('.sort-item').forEach(function(el) { el.style.borderTop = ''; });
            updateRanking();
        });
        item.addEventListener('dragover', function(e) {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'move';
            this.style.borderTop = '3px solid #9333ea';
        });
        item.addEventListener('dragleave', function() {
            this.style.borderTop = '';
        });
        item.addEventListener('drop', function(e) {
            e.preventDefault();
            this.style.borderTop = '';
            if (dragItem !== this) {
                list.insertBefore(dragItem, this);
            }
            updateRanking();
        });
    });

    function updateRanking() {
        var items = list.querySelectorAll('.sort-item');
        var values = [];
        items.forEach(function(item, idx) {
            item.querySelector('.badge').textContent = idx + 1;
            values.push(item.dataset.value);
        });
        document.getElementById('sortRanking').value = values.join(',');
    }
})();
</script>

<jsp:include page="../footer.jsp" />
