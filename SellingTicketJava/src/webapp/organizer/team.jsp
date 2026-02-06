<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="team"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">Điều hành viên</h2>
                    <p class="text-muted mb-0">Quản lý thành viên trong ban tổ chức</p>
                </div>
                <button class="btn btn-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addMemberModal">
                    <i class="fas fa-user-plus me-2"></i>Thêm thành viên
                </button>
            </div>

            <!-- Role Legend -->
            <div class="card glass-strong border-0 rounded-4 mb-4">
                <div class="card-body p-4">
                    <h6 class="fw-bold mb-3">Phân quyền vai trò</h6>
                    <div class="row g-3">
                        <div class="col-md-3">
                            <div class="d-flex align-items-start gap-3 p-3 rounded-3" style="background: rgba(239, 68, 68, 0.1);">
                                <div class="rounded-3 p-2 badge-admin">
                                    <i class="fas fa-shield-alt"></i>
                                </div>
                                <div>
                                    <p class="fw-medium small mb-1">Quản trị viên</p>
                                    <p class="text-muted small mb-0">Toàn quyền quản lý</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="d-flex align-items-start gap-3 p-3 rounded-3" style="background: rgba(168, 85, 247, 0.1);">
                                <div class="rounded-3 p-2 badge-manager">
                                    <i class="fas fa-edit"></i>
                                </div>
                                <div>
                                    <p class="fw-medium small mb-1">Quản lý</p>
                                    <p class="text-muted small mb-0">Chỉnh sửa sự kiện, vé</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="d-flex align-items-start gap-3 p-3 rounded-3" style="background: rgba(59, 130, 246, 0.1);">
                                <div class="rounded-3 p-2 badge-checkin">
                                    <i class="fas fa-qrcode"></i>
                                </div>
                                <div>
                                    <p class="fw-medium small mb-1">Check-in</p>
                                    <p class="text-muted small mb-0">Chỉ soát vé tại sự kiện</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="d-flex align-items-start gap-3 p-3 rounded-3" style="background: rgba(34, 197, 94, 0.1);">
                                <div class="rounded-3 p-2 badge-viewer">
                                    <i class="fas fa-eye"></i>
                                </div>
                                <div>
                                    <p class="fw-medium small mb-1">Xem báo cáo</p>
                                    <p class="text-muted small mb-0">Chỉ xem thống kê</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Team Members Grid -->
            <div class="row g-4">
                <!-- Member 1 - Admin -->
                <div class="col-md-6">
                    <div class="card glass-strong border-0 rounded-4 card-hover">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="avatar-placeholder rounded-circle" style="width: 48px; height: 48px;">NV</div>
                                    <div>
                                        <p class="fw-bold mb-0">Nguyễn Văn A</p>
                                        <p class="text-muted small mb-0"><i class="fas fa-envelope me-1"></i>nguyenvana@email.com</p>
                                    </div>
                                </div>
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-light rounded-circle" data-bs-toggle="dropdown">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end">
                                        <li><a class="dropdown-item" href="#"><i class="fas fa-edit me-2"></i>Đổi vai trò</a></li>
                                        <li><a class="dropdown-item text-danger" href="#"><i class="fas fa-trash me-2"></i>Xóa khỏi nhóm</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                                <span class="badge rounded-pill badge-admin px-3 py-2">
                                    <i class="fas fa-shield-alt me-1"></i>Quản trị viên
                                </span>
                                <small class="text-muted">Hoạt động: Hôm nay</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Member 2 - Manager -->
                <div class="col-md-6">
                    <div class="card glass-strong border-0 rounded-4 card-hover">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="avatar-placeholder rounded-circle" style="width: 48px; height: 48px;">TT</div>
                                    <div>
                                        <p class="fw-bold mb-0">Trần Thị B</p>
                                        <p class="text-muted small mb-0"><i class="fas fa-envelope me-1"></i>tranthib@email.com</p>
                                    </div>
                                </div>
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-light rounded-circle" data-bs-toggle="dropdown">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end">
                                        <li><a class="dropdown-item" href="#"><i class="fas fa-edit me-2"></i>Đổi vai trò</a></li>
                                        <li><a class="dropdown-item text-danger" href="#"><i class="fas fa-trash me-2"></i>Xóa khỏi nhóm</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                                <span class="badge rounded-pill badge-manager px-3 py-2">
                                    <i class="fas fa-edit me-1"></i>Quản lý
                                </span>
                                <small class="text-muted">Hoạt động: Hôm qua</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Member 3 - Check-in -->
                <div class="col-md-6">
                    <div class="card glass-strong border-0 rounded-4 card-hover">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="avatar-placeholder rounded-circle" style="width: 48px; height: 48px;">LV</div>
                                    <div>
                                        <p class="fw-bold mb-0">Lê Văn C</p>
                                        <p class="text-muted small mb-0"><i class="fas fa-envelope me-1"></i>levanc@email.com</p>
                                    </div>
                                </div>
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-light rounded-circle" data-bs-toggle="dropdown">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end">
                                        <li><a class="dropdown-item" href="#"><i class="fas fa-edit me-2"></i>Đổi vai trò</a></li>
                                        <li><a class="dropdown-item text-danger" href="#"><i class="fas fa-trash me-2"></i>Xóa khỏi nhóm</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                                <span class="badge rounded-pill badge-checkin px-3 py-2">
                                    <i class="fas fa-qrcode me-1"></i>Check-in
                                </span>
                                <small class="text-muted">Hoạt động: 3 ngày trước</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Member 4 - Viewer -->
                <div class="col-md-6">
                    <div class="card glass-strong border-0 rounded-4 card-hover">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="avatar-placeholder rounded-circle" style="width: 48px; height: 48px;">PT</div>
                                    <div>
                                        <p class="fw-bold mb-0">Phạm Thị D</p>
                                        <p class="text-muted small mb-0"><i class="fas fa-envelope me-1"></i>phamthid@email.com</p>
                                    </div>
                                </div>
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-light rounded-circle" data-bs-toggle="dropdown">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end">
                                        <li><a class="dropdown-item" href="#"><i class="fas fa-edit me-2"></i>Đổi vai trò</a></li>
                                        <li><a class="dropdown-item text-danger" href="#"><i class="fas fa-trash me-2"></i>Xóa khỏi nhóm</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                                <span class="badge rounded-pill badge-viewer px-3 py-2">
                                    <i class="fas fa-eye me-1"></i>Xem báo cáo
                                </span>
                                <small class="text-muted">Hoạt động: 1 tuần trước</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add Member Modal -->
<div class="modal fade modal-glass" id="addMemberModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Thêm điều hành viên</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Email <span class="text-danger">*</span></label>
                        <input type="email" class="form-control glass-input rounded-3" placeholder="email@example.com">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Vai trò <span class="text-danger">*</span></label>
                        <select class="form-select glass-input rounded-3">
                            <option value="" selected disabled>Chọn vai trò</option>
                            <option value="admin">Quản trị viên - Toàn quyền quản lý</option>
                            <option value="manager">Quản lý - Chỉnh sửa sự kiện, vé, voucher</option>
                            <option value="checkin">Check-in - Chỉ soát vé tại sự kiện</option>
                            <option value="viewer">Xem báo cáo - Chỉ xem thống kê, báo cáo</option>
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-gradient rounded-pill px-4">
                    <i class="fas fa-paper-plane me-2"></i>Gửi lời mời
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
