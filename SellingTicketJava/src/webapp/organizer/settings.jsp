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
            <h2 class="fw-bold mb-2">Cài đặt</h2>
            <p class="text-muted mb-4">Quản lý thông tin tổ chức và cấu hình</p>

            <!-- Tabs -->
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
                    <button class="nav-link" id="invoice-tab" data-bs-toggle="tab" data-bs-target="#invoice" type="button" role="tab">
                        <i class="fas fa-file-invoice me-2"></i>Hóa đơn
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="notification-tab" data-bs-toggle="tab" data-bs-target="#notification" type="button" role="tab">
                        <i class="fas fa-bell me-2"></i>Thông báo
                    </button>
                </li>
            </ul>

            <!-- Tab Content -->
            <div class="tab-content" id="settingsTabContent">
                <!-- Organization Tab -->
                <div class="tab-pane fade show active" id="org" role="tabpanel">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4">Thông tin ban tổ chức</h5>
                            <form>
                                <div class="row">
                                    <div class="col-md-3 mb-4">
                                        <label class="form-label fw-medium">Logo tổ chức</label>
                                        <div class="border-2 border-dashed rounded-4 p-4 text-center" style="border-style: dashed; border-color: rgba(0,0,0,0.1);">
                                            <i class="fas fa-cloud-upload-alt fa-2x text-muted mb-2"></i>
                                            <p class="small text-muted mb-0">Kéo thả hoặc click để upload</p>
                                        </div>
                                    </div>
                                    <div class="col-md-9">
                                        <div class="mb-3">
                                            <label class="form-label fw-medium">Tên tổ chức <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control glass-input rounded-3" value="Công ty ABC Entertainment">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label fw-medium">Mô tả</label>
                                            <textarea class="form-control glass-input rounded-3" rows="3">Chuyên tổ chức các sự kiện âm nhạc và giải trí hàng đầu Việt Nam</textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Email liên hệ</label>
                                        <input type="email" class="form-control glass-input rounded-3" value="contact@abc-ent.com">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Số điện thoại</label>
                                        <input type="tel" class="form-control glass-input rounded-3" value="1900 1234">
                                    </div>
                                    <div class="col-12 mb-3">
                                        <label class="form-label fw-medium">Website</label>
                                        <input type="url" class="form-control glass-input rounded-3" value="https://abc-ent.com">
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Bank Tab -->
                <div class="tab-pane fade" id="bank" role="tabpanel">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-2">Tài khoản ngân hàng</h5>
                            <p class="text-muted mb-4">Thông tin tài khoản để nhận thanh toán từ việc bán vé</p>
                            <form>
                                <div class="mb-3">
                                    <label class="form-label fw-medium">Tên chủ tài khoản <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control glass-input rounded-3" value="CONG TY TNHH ABC ENTERTAINMENT">
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Số tài khoản <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control glass-input rounded-3" value="0123456789">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-medium">Ngân hàng <span class="text-danger">*</span></label>
                                        <select class="form-select glass-input rounded-3">
                                            <option value="vcb" selected>Vietcombank</option>
                                            <option value="tcb">Techcombank</option>
                                            <option value="mb">MB Bank</option>
                                            <option value="acb">ACB</option>
                                            <option value="bidv">BIDV</option>
                                            <option value="vtb">VietinBank</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-medium">Chi nhánh</label>
                                    <input type="text" class="form-control glass-input rounded-3" value="Chi nhánh Hà Nội">
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Invoice Tab -->
                <div class="tab-pane fade" id="invoice" role="tabpanel">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <div>
                                    <h5 class="fw-bold mb-1">Xuất hóa đơn đỏ</h5>
                                    <p class="text-muted mb-0">Thông tin để xuất hóa đơn VAT</p>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" id="needInvoice" checked style="width: 3rem; height: 1.5rem;">
                                </div>
                            </div>
                            <hr>
                            <form id="invoiceForm">
                                <div class="mb-3">
                                    <label class="form-label fw-medium">Loại hình kinh doanh <span class="text-danger">*</span></label>
                                    <select class="form-select glass-input rounded-3">
                                        <option value="company" selected>Công ty</option>
                                        <option value="individual">Cá nhân</option>
                                        <option value="household">Hộ kinh doanh</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-medium">Tên công ty/cá nhân <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control glass-input rounded-3" value="CÔNG TY TNHH ABC ENTERTAINMENT">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-medium">Địa chỉ <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control glass-input rounded-3" value="123 Đường ABC, Quận 1, TP.HCM">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-medium">Mã số thuế <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control glass-input rounded-3" value="0123456789">
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Notifications Tab -->
                <div class="tab-pane fade" id="notification" role="tabpanel">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4">Cài đặt thông báo</h5>
                            
                            <div class="settings-item">
                                <div>
                                    <p class="fw-medium mb-1">Thông báo qua Email</p>
                                    <p class="text-muted small mb-0">Nhận email khi có đơn hàng mới hoặc cập nhật</p>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                            
                            <div class="settings-item">
                                <div>
                                    <p class="fw-medium mb-1">Thông báo qua SMS</p>
                                    <p class="text-muted small mb-0">Nhận tin nhắn khi có đơn hàng quan trọng</p>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                            
                            <div class="settings-item">
                                <div>
                                    <p class="fw-medium mb-1">Thông báo đơn hàng</p>
                                    <p class="text-muted small mb-0">Nhận thông báo mỗi khi có đơn hàng mới</p>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem;">
                                </div>
                            </div>
                            
                            <div class="settings-item">
                                <div>
                                    <p class="fw-medium mb-1">Báo cáo hàng ngày</p>
                                    <p class="text-muted small mb-0">Nhận email tổng kết doanh số mỗi ngày</p>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" checked style="width: 2.5rem; height: 1.25rem;">
                                </div>
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
