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
                <h2 class="fw-bold mb-2">Cài đặt</h2>
                <p class="text-muted mb-4">Quản lý thông tin tổ chức và cấu hình</p>
            </div>

            <%-- Tabs --%>
            <ul class="nav nav-tabs-glass mb-4" id="settingsTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="org-tab" data-bs-toggle="tab" data-bs-target="#org" type="button" role="tab">
                        <i class="fas fa-building me-2"></i>Tổ chức
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="bank-tab" data-bs-toggle="tab" data-bs-target="#bank" type="button" role="tab">
                        <i class="fas fa-credit-card me-2"></i>Ngân hàng
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="notification-tab" data-bs-toggle="tab" data-bs-target="#notification" type="button" role="tab">
                        <i class="fas fa-bell me-2"></i>Thông báo
                    </button>
                </li>
            </ul>

            <form method="POST" action="${pageContext.request.contextPath}/organizer/settings">
                <input type="hidden" name="csrf_token" value="${csrf_token}"/>
                <%-- Tab Content --%>
                <div class="tab-content" id="settingsTabContent">
                    <%-- Organization Tab --%>
                    <div class="tab-pane fade show active" id="org" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-building text-primary me-2"></i>Thông tin ban tổ chức</h5>
                                <div class="row">
                                    <div class="col-md-3 mb-4">
                                        <label class="form-label fw-medium">Logo tổ chức</label>
                                        <div class="rounded-4 p-4 text-center" style="border: 2px dashed rgba(59,130,246,0.3); background: rgba(59,130,246,0.05);">
                                            <c:choose>
                                                <c:when test="${not empty user.avatarUrl}">
                                                    <img src="${user.avatarUrl}" class="rounded-3 mb-2" style="width: 80px; height: 80px; object-fit: cover;">
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fas fa-cloud-upload-alt fa-2x mb-2" style="color: #3b82f6;"></i>
                                                </c:otherwise>
                                            </c:choose>
                                            <p class="small text-muted mb-0">Kéo thả hoặc click</p>
                                        </div>
                                    </div>
                                    <div class="col-md-9">
                                        <div class="mb-3">
                                            <label class="form-label fw-medium">Tên tổ chức</label>
                                            <input type="text" class="form-control glass-input rounded-3" name="fullName" value="${user.fullName}">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label fw-medium">Mô tả</label>
                                            <textarea class="form-control glass-input rounded-3" name="bio" rows="3" placeholder="Giới thiệu về tổ chức...">${user.bio}</textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Email liên hệ</label>
                                        <input type="email" class="form-control glass-input rounded-3" value="${user.email}" disabled>
                                        <small class="text-muted">Email không thể thay đổi</small>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Số điện thoại</label>
                                        <input type="tel" class="form-control glass-input rounded-3" name="phoneNumber" value="${user.phoneNumber}">
                                    </div>
                                    <div class="col-12 mb-3">
                                        <label class="form-label fw-medium">Website</label>
                                        <input type="url" class="form-control glass-input rounded-3" name="website" value="${user.website}" placeholder="https://...">
                                    </div>
                                </div>
                                <h6 class="fw-bold mt-4 mb-3"><i class="fas fa-share-alt text-primary me-2"></i>Mạng xã hội</h6>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium"><i class="fab fa-facebook text-primary me-1"></i>Facebook</label>
                                        <input type="url" class="form-control glass-input rounded-3" name="socialFacebook" value="${user.socialFacebook}" placeholder="https://facebook.com/...">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium"><i class="fab fa-instagram me-1" style="color: #e1306c;"></i>Instagram</label>
                                        <input type="url" class="form-control glass-input rounded-3" name="socialInstagram" value="${user.socialInstagram}" placeholder="https://instagram.com/...">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Bank Tab --%>
                    <div class="tab-pane fade" id="bank" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-2"><i class="fas fa-credit-card text-primary me-2"></i>Tài khoản ngân hàng</h5>
                                <p class="text-muted mb-4">Thông tin tài khoản để nhận thanh toán từ việc bán vé</p>
                                <div class="mb-3">
                                    <label class="form-label fw-medium">Tên chủ tài khoản</label>
                                    <input type="text" class="form-control glass-input rounded-3" placeholder="NGUYEN VAN A">
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Số tài khoản</label>
                                        <input type="text" class="form-control glass-input rounded-3" placeholder="0123456789">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Ngân hàng</label>
                                        <select class="form-select glass-input rounded-3">
                                            <option value="vcb">Vietcombank</option>
                                            <option value="tcb">Techcombank</option>
                                            <option value="mb">MB Bank</option>
                                            <option value="acb">ACB</option>
                                            <option value="bidv">BIDV</option>
                                            <option value="vtb">VietinBank</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Notifications Tab --%>
                    <div class="tab-pane fade" id="notification" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-bell text-primary me-2"></i>Cài đặt thông báo</h5>

                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Thông báo qua Email</p>
                                        <p class="text-muted small mb-0">Nhận email khi có đơn hàng mới</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Thông báo đơn hàng</p>
                                        <p class="text-muted small mb-0">Nhận thông báo mỗi khi có đơn hàng mới</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center py-3">
                                    <div>
                                        <p class="fw-medium mb-1">Báo cáo hàng ngày</p>
                                        <p class="text-muted small mb-0">Nhận email tổng kết doanh số mỗi ngày</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
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
