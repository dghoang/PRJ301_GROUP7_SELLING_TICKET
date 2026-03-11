<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

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

            <%-- Toast Messages --%>
            <tags:toast />

            <%-- Tabs --%>
            <ul class="nav nav-tabs-glass mb-4" id="settingsTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="org-tab" data-bs-toggle="tab" data-bs-target="#org" type="button" role="tab">
                        <i class="fas fa-building me-2"></i>Tổ chức
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="event-config-tab" data-bs-toggle="tab" data-bs-target="#event-config" type="button" role="tab">
                        <i class="fas fa-calendar-check me-2"></i>Sự kiện
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="notification-tab" data-bs-toggle="tab" data-bs-target="#notification" type="button" role="tab">
                        <i class="fas fa-bell me-2"></i>Thông báo
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="support-tab" data-bs-toggle="tab" data-bs-target="#support" type="button" role="tab">
                        <i class="fas fa-headset me-2"></i>Hỗ trợ
                    </button>
                </li>
            </ul>

            <form method="POST" action="${pageContext.request.contextPath}/organizer/settings">
                <tags:csrf />
                <div class="tab-content" id="settingsTabContent">

                    <%-- === Organization Tab === --%>
                    <div class="tab-pane fade show active" id="org" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-building text-primary me-2"></i>Thông tin ban tổ chức</h5>
                                <div class="row">
                                    <div class="col-md-3 mb-4">
                                        <label class="form-label fw-medium">Logo tổ chức</label>
                                        <div class="rounded-4 p-4 text-center" style="border: 2px dashed rgba(59,130,246,0.3); background: rgba(59,130,246,0.05);">
                                            <c:choose>
                                                <c:when test="${not empty user.avatar}">
                                                    <img src="${user.avatar}" class="rounded-3 mb-2" style="width: 80px; height: 80px; object-fit: cover;">
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
                                            <input type="text" class="form-control glass-input rounded-3" name="fullName" value="${organizer.fullName}">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label fw-medium">Mô tả</label>
                                            <textarea class="form-control glass-input rounded-3" name="bio" rows="3" placeholder="Giới thiệu về tổ chức...">${organizer.bio}</textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Email liên hệ</label>
                                        <input type="email" class="form-control glass-input rounded-3" value="${organizer.email}" disabled>
                                        <small class="text-muted">Email không thể thay đổi</small>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Số điện thoại</label>
                                        <input type="tel" class="form-control glass-input rounded-3" name="phone" value="${organizer.phone}">
                                    </div>
                                    <div class="col-12 mb-3">
                                        <label class="form-label fw-medium">Website</label>
                                        <input type="url" class="form-control glass-input rounded-3" name="website" value="${organizer.website}" placeholder="https://...">
                                    </div>
                                </div>
                                <h6 class="fw-bold mt-4 mb-3"><i class="fas fa-share-alt text-primary me-2"></i>Mạng xã hội</h6>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium"><i class="fab fa-facebook text-primary me-1"></i>Facebook</label>
                                        <input type="url" class="form-control glass-input rounded-3" name="socialFacebook" value="${organizer.socialFacebook}" placeholder="https://facebook.com/...">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium"><i class="fab fa-instagram me-1" style="color: #e1306c;"></i>Instagram</label>
                                        <input type="url" class="form-control glass-input rounded-3" name="socialInstagram" value="${organizer.socialInstagram}" placeholder="https://instagram.com/...">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- === Event Config Tab === --%>
                    <div class="tab-pane fade" id="event-config" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-calendar-check text-primary me-2"></i>Cấu hình sự kiện mặc định</h5>
                                <p class="text-muted mb-4">Cài đặt mặc định áp dụng khi tạo sự kiện mới</p>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Giới hạn vé mỗi đơn</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="defaultMaxTickets" value="${orgPrefs.defaultMaxTickets}" min="1" max="50">
                                        <small class="text-muted">Số vé tối đa mỗi lần mua</small>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Thời hạn thanh toán (phút)</label>
                                        <input type="number" class="form-control glass-input rounded-3" name="paymentTimeout" value="${orgPrefs.paymentTimeout}" min="5" max="60">
                                        <small class="text-muted">Tự động hủy đơn nếu chưa thanh toán</small>
                                    </div>
                                </div>

                                <h6 class="fw-bold mt-4 mb-3"><i class="fas fa-qrcode text-primary me-2"></i>Check-in</h6>
                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Cho phép check-in sớm</p>
                                        <p class="text-muted small mb-0">Khán giả có thể check-in trước 30 phút</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="allowEarlyCheckin" value="true"
                                               ${orgPrefs.allowEarlyCheckin == 'true' ? 'checked' : ''}
                                               style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center py-3">
                                    <div>
                                        <p class="fw-medium mb-1">Cho phép chuyển nhượng vé</p>
                                        <p class="text-muted small mb-0">Người mua có thể chuyển vé cho người khác</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="allowTicketTransfer" value="true"
                                               ${orgPrefs.allowTicketTransfer == 'true' ? 'checked' : ''}
                                               style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- Ticket Permissions --%>
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll mt-4">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-shield-alt text-primary me-2"></i>Quyền quản lý vé</h5>
                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Staff được hủy vé</p>
                                        <p class="text-muted small mb-0">Cho phép staff hủy và hoàn vé cho khách</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="staffCanCancel" value="true"
                                               ${orgPrefs.staffCanCancel == 'true' ? 'checked' : ''}
                                               style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center py-3">
                                    <div>
                                        <p class="fw-medium mb-1">Staff được xem doanh thu</p>
                                        <p class="text-muted small mb-0">Staff có thể truy cập thống kê doanh thu</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="staffCanViewRevenue" value="true"
                                               ${orgPrefs.staffCanViewRevenue == 'true' ? 'checked' : ''}
                                               style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- === Notifications Tab === --%>
                    <div class="tab-pane fade" id="notification" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-bell text-primary me-2"></i>Cài đặt thông báo</h5>

                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Thông báo đơn hàng mới</p>
                                        <p class="text-muted small mb-0">Nhận email khi có đơn hàng mới</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="notifyNewOrder" value="true"
                                               ${orgPrefs.notifyNewOrder == 'true' ? 'checked' : ''}
                                               style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Thông báo yêu cầu hỗ trợ</p>
                                        <p class="text-muted small mb-0">Nhận thông báo khi khách gửi ticket hỗ trợ về sự kiện</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="notifyTicketIssue" value="true"
                                               ${orgPrefs.notifyTicketIssue == 'true' ? 'checked' : ''}
                                               style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center py-3 border-bottom" style="border-color: rgba(0,0,0,0.06) !important;">
                                    <div>
                                        <p class="fw-medium mb-1">Thông báo check-in</p>
                                        <p class="text-muted small mb-0">Nhận thông báo realtime khi khách check-in</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="notifyCheckin" value="true"
                                               ${orgPrefs.notifyCheckin == 'true' ? 'checked' : ''}
                                               style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center py-3">
                                    <div>
                                        <p class="fw-medium mb-1">Báo cáo tổng kết hàng ngày</p>
                                        <p class="text-muted small mb-0">Nhận email tổng kết doanh số mỗi sáng</p>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="notifyDailyReport" value="true"
                                               ${orgPrefs.notifyDailyReport == 'true' ? 'checked' : ''}
                                               style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- === Support Tab === --%>
                    <div class="tab-pane fade" id="support" role="tabpanel">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4 text-center py-5">
                                <div class="mb-3">
                                    <div class="d-inline-flex align-items-center justify-content-center rounded-circle"
                                         style="width: 72px; height: 72px; background: linear-gradient(135deg, #3b82f6, #06b6d4);">
                                        <i class="fas fa-headset fa-2x text-white"></i>
                                    </div>
                                </div>
                                <h5 class="fw-bold mb-2">Cần hỗ trợ từ Admin?</h5>
                                <p class="text-muted mb-4" style="max-width: 400px; margin: 0 auto;">
                                    Gửi yêu cầu hỗ trợ trực tiếp đến admin hệ thống. 
                                    Ticket của ban tổ chức sẽ được <strong>ưu tiên xử lý</strong>.
                                </p>
                                <a href="${pageContext.request.contextPath}/organizer/support" class="btn btn-gradient rounded-pill px-4 hover-glow">
                                    <i class="fas fa-headset me-2"></i>Trung tâm hỗ trợ
                                </a>

                                <c:if test="${not empty orgTicketCount && orgTicketCount > 0}">
                                    <div class="mt-3">
                                        <span class="badge rounded-pill px-3 py-2" style="background: rgba(59,130,246,0.1); color: #3b82f6;">
                                            <i class="fas fa-ticket-alt me-1"></i>${orgTicketCount} ticket đang mở
                                        </span>
                                    </div>
                                </c:if>
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
