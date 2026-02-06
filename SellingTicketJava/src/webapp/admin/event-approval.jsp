<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="event-approval"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">Duyệt sự kiện</h2>
                    <p class="text-muted mb-0">Xét duyệt các sự kiện mới từ ban tổ chức</p>
                </div>
            </div>

            <!-- Stats Cards -->
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="rounded-3 p-3" style="background: rgba(234, 179, 8, 0.15);">
                                <i class="fas fa-clock fa-lg text-warning"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">12</h4>
                                <small class="text-muted">Chờ duyệt</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="rounded-3 p-3" style="background: rgba(34, 197, 94, 0.15);">
                                <i class="fas fa-check fa-lg text-success"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">156</h4>
                                <small class="text-muted">Đã duyệt</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="rounded-3 p-3" style="background: rgba(239, 68, 68, 0.15);">
                                <i class="fas fa-times fa-lg text-danger"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">8</h4>
                                <small class="text-muted">Từ chối</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="rounded-3 p-3" style="background: rgba(59, 130, 246, 0.15);">
                                <i class="fas fa-calendar fa-lg text-primary"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">176</h4>
                                <small class="text-muted">Tổng số</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filter Tabs -->
            <ul class="nav nav-tabs-glass mb-4" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#pending" type="button">
                        <i class="fas fa-clock me-2"></i>Chờ duyệt <span class="badge bg-warning text-dark ms-2">12</span>
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#approved" type="button">
                        <i class="fas fa-check me-2"></i>Đã duyệt
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#rejected" type="button">
                        <i class="fas fa-times me-2"></i>Từ chối
                    </button>
                </li>
            </ul>

            <!-- Tab Content -->
            <div class="tab-content">
                <!-- Pending Tab -->
                <div class="tab-pane fade show active" id="pending" role="tabpanel">
                    <div class="row g-4">
                        <!-- Pending Event 1 -->
                        <div class="col-lg-6">
                            <div class="card glass-strong border-0 rounded-4 card-hover overflow-hidden">
                                <div class="position-relative">
                                    <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600" class="card-img-top" style="height: 180px; object-fit: cover;">
                                    <span class="badge badge-status-pending position-absolute top-0 end-0 m-3 px-3 py-2"><i class="fas fa-clock me-1"></i>Chờ duyệt</span>
                                </div>
                                <div class="card-body p-4">
                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                        <div>
                                            <h5 class="fw-bold mb-1">Festival Âm nhạc Mùa Hè 2026</h5>
                                            <p class="text-muted small mb-0">Bởi: <strong>ABC Entertainment</strong></p>
                                        </div>
                                    </div>
                                    <div class="row g-2 mb-3">
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="far fa-calendar me-2 text-primary"></i>15/06/2026
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="fas fa-map-marker-alt me-2 text-primary"></i>Phú Thọ, HCM
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="fas fa-ticket-alt me-2 text-primary"></i>5,000 vé
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="fas fa-money-bill me-2 text-primary"></i>500K - 2M đ
                                            </div>
                                        </div>
                                    </div>
                                    <p class="text-muted small mb-3">Gửi lúc: 05/02/2026 14:30</p>
                                    <div class="d-flex gap-2">
                                        <button class="btn btn-success rounded-pill flex-grow-1" data-bs-toggle="modal" data-bs-target="#approveModal">
                                            <i class="fas fa-check me-2"></i>Duyệt
                                        </button>
                                        <button class="btn btn-outline-danger rounded-pill flex-grow-1" data-bs-toggle="modal" data-bs-target="#rejectModal">
                                            <i class="fas fa-times me-2"></i>Từ chối
                                        </button>
                                        <button class="btn btn-light rounded-pill">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Pending Event 2 -->
                        <div class="col-lg-6">
                            <div class="card glass-strong border-0 rounded-4 card-hover overflow-hidden">
                                <div class="position-relative">
                                    <img src="https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=600" class="card-img-top" style="height: 180px; object-fit: cover;">
                                    <span class="badge badge-status-pending position-absolute top-0 end-0 m-3 px-3 py-2"><i class="fas fa-clock me-1"></i>Chờ duyệt</span>
                                </div>
                                <div class="card-body p-4">
                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                        <div>
                                            <h5 class="fw-bold mb-1">Workshop Digital Marketing</h5>
                                            <p class="text-muted small mb-0">Bởi: <strong>Digital Academy</strong></p>
                                        </div>
                                    </div>
                                    <div class="row g-2 mb-3">
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="far fa-calendar me-2 text-primary"></i>20/03/2026
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="fas fa-map-marker-alt me-2 text-primary"></i>Quận 1, HCM
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="fas fa-ticket-alt me-2 text-primary"></i>100 vé
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="fas fa-money-bill me-2 text-primary"></i>500K đ
                                            </div>
                                        </div>
                                    </div>
                                    <p class="text-muted small mb-3">Gửi lúc: 04/02/2026 09:15</p>
                                    <div class="d-flex gap-2">
                                        <button class="btn btn-success rounded-pill flex-grow-1">
                                            <i class="fas fa-check me-2"></i>Duyệt
                                        </button>
                                        <button class="btn btn-outline-danger rounded-pill flex-grow-1">
                                            <i class="fas fa-times me-2"></i>Từ chối
                                        </button>
                                        <button class="btn btn-light rounded-pill">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Approved Tab -->
                <div class="tab-pane fade" id="approved" role="tabpanel">
                    <div class="empty-state glass-strong rounded-4 p-5">
                        <i class="fas fa-check-circle empty-state-icon text-success"></i>
                        <h4 class="fw-bold mb-2">Sự kiện đã duyệt</h4>
                        <p class="text-muted">Chuyển sang tab này để xem danh sách các sự kiện đã được phê duyệt.</p>
                    </div>
                </div>

                <!-- Rejected Tab -->
                <div class="tab-pane fade" id="rejected" role="tabpanel">
                    <div class="empty-state glass-strong rounded-4 p-5">
                        <i class="fas fa-times-circle empty-state-icon text-danger"></i>
                        <h4 class="fw-bold mb-2">Sự kiện bị từ chối</h4>
                        <p class="text-muted">Chuyển sang tab này để xem danh sách các sự kiện đã bị từ chối.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Approve Modal -->
<div class="modal fade modal-glass" id="approveModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold"><i class="fas fa-check-circle text-success me-2"></i>Xác nhận duyệt</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn duyệt sự kiện <strong>"Festival Âm nhạc Mùa Hè 2026"</strong>?</p>
                <p class="text-muted small">Sau khi duyệt, sự kiện sẽ được hiển thị công khai và mở bán vé.</p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-success rounded-pill px-4">
                    <i class="fas fa-check me-2"></i>Xác nhận duyệt
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Reject Modal -->
<div class="modal fade modal-glass" id="rejectModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold"><i class="fas fa-times-circle text-danger me-2"></i>Từ chối sự kiện</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn từ chối sự kiện <strong>"Festival Âm nhạc Mùa Hè 2026"</strong>?</p>
                <div class="mb-3">
                    <label class="form-label fw-medium">Lý do từ chối <span class="text-danger">*</span></label>
                    <textarea class="form-control glass-input rounded-3" rows="3" placeholder="Nhập lý do từ chối..."></textarea>
                </div>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-danger rounded-pill px-4">
                    <i class="fas fa-times me-2"></i>Xác nhận từ chối
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
