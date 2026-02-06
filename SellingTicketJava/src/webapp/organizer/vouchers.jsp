<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="vouchers"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="fw-bold mb-0">Quản lý Vouchers</h2>
                <button class="btn btn-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#createVoucherModal">
                    <i class="fas fa-plus me-2"></i>Tạo Voucher
                </button>
            </div>

            <!-- Vouchers Grid -->
            <div class="row g-4">
                <div class="col-md-6 col-lg-4">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="bg-primary bg-opacity-10 rounded-3 p-3">
                                    <i class="fas fa-percent fa-2x text-primary"></i>
                                </div>
                                <span class="badge bg-success rounded-pill">Đang hoạt động</span>
                            </div>
                            <h5 class="fw-bold mb-1">GIAMGIA20</h5>
                            <p class="text-muted small mb-3">Giảm 20% cho tất cả vé</p>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between small mb-1">
                                    <span>Đã dùng: 45/100</span>
                                    <span>45%</span>
                                </div>
                                <div class="progress" style="height: 6px;">
                                    <div class="progress-bar bg-primary" style="width: 45%;"></div>
                                </div>
                            </div>
                            <div class="text-muted small mb-3">
                                <i class="far fa-calendar me-1"></i>01/02 - 28/02/2026
                            </div>
                            <div class="d-flex gap-2">
                                <button class="btn btn-outline-primary btn-sm flex-grow-1 rounded-pill">
                                    <i class="fas fa-edit me-1"></i>Sửa
                                </button>
                                <button class="btn btn-outline-danger btn-sm rounded-pill">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-6 col-lg-4">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="bg-success bg-opacity-10 rounded-3 p-3">
                                    <i class="fas fa-tag fa-2x text-success"></i>
                                </div>
                                <span class="badge bg-success rounded-pill">Đang hoạt động</span>
                            </div>
                            <h5 class="fw-bold mb-1">FREESHIP</h5>
                            <p class="text-muted small mb-3">Miễn phí vận chuyển</p>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between small mb-1">
                                    <span>Đã dùng: 80/200</span>
                                    <span>40%</span>
                                </div>
                                <div class="progress" style="height: 6px;">
                                    <div class="progress-bar bg-success" style="width: 40%;"></div>
                                </div>
                            </div>
                            <div class="text-muted small mb-3">
                                <i class="far fa-calendar me-1"></i>01/02 - 15/02/2026
                            </div>
                            <div class="d-flex gap-2">
                                <button class="btn btn-outline-primary btn-sm flex-grow-1 rounded-pill">
                                    <i class="fas fa-edit me-1"></i>Sửa
                                </button>
                                <button class="btn btn-outline-danger btn-sm rounded-pill">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-6 col-lg-4">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                                    <i class="fas fa-gift fa-2x text-warning"></i>
                                </div>
                                <span class="badge bg-secondary rounded-pill">Hết hạn</span>
                            </div>
                            <h5 class="fw-bold mb-1">NEWYEAR50K</h5>
                            <p class="text-muted small mb-3">Giảm 50.000đ</p>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between small mb-1">
                                    <span>Đã dùng: 100/100</span>
                                    <span>100%</span>
                                </div>
                                <div class="progress" style="height: 6px;">
                                    <div class="progress-bar bg-secondary" style="width: 100%;"></div>
                                </div>
                            </div>
                            <div class="text-muted small mb-3">
                                <i class="far fa-calendar me-1"></i>01/01 - 07/01/2026
                            </div>
                            <div class="d-flex gap-2">
                                <button class="btn btn-outline-secondary btn-sm flex-grow-1 rounded-pill" disabled>
                                    Đã hết hạn
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Create Voucher Modal -->
<div class="modal fade" id="createVoucherModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content glass-strong border-0 rounded-4">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold">Tạo Voucher mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">Mã voucher</label>
                    <input type="text" class="form-control" placeholder="VD: GIAMGIA20">
                </div>
                <div class="mb-3">
                    <label class="form-label">Loại giảm giá</label>
                    <select class="form-select">
                        <option>Phần trăm (%)</option>
                        <option>Số tiền cố định (VNĐ)</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label">Giá trị</label>
                    <input type="number" class="form-control" placeholder="20">
                </div>
                <div class="row g-3">
                    <div class="col-6">
                        <label class="form-label">Ngày bắt đầu</label>
                        <input type="date" class="form-control">
                    </div>
                    <div class="col-6">
                        <label class="form-label">Ngày kết thúc</label>
                        <input type="date" class="form-control">
                    </div>
                </div>
                <div class="mb-3 mt-3">
                    <label class="form-label">Số lượng</label>
                    <input type="number" class="form-control" placeholder="100">
                </div>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-outline-secondary rounded-pill" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-gradient rounded-pill px-4">Tạo voucher</button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
