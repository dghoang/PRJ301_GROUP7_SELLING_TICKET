<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="tickets"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">Quản lý loại vé</h2>
                    <p class="text-muted mb-0">Tạo và quản lý các loại vé cho sự kiện của bạn</p>
                </div>
                <button class="btn btn-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#ticketModal">
                    <i class="fas fa-plus me-2"></i>Thêm loại vé
                </button>
            </div>

            <!-- Event Filter -->
            <div class="card glass-strong border-0 rounded-4 mb-4">
                <div class="card-body p-3">
                    <div class="row align-items-center">
                        <div class="col-md-6">
                            <label class="form-label small fw-medium mb-2">Chọn sự kiện</label>
                            <select class="form-select glass-input rounded-3">
                                <option value="" selected>Tất cả sự kiện</option>
                                <option value="1">Đêm nhạc Acoustic - 15/02/2026</option>
                                <option value="2">Workshop Marketing - 20/02/2026</option>
                                <option value="3">Festival Mùa Xuân - 01/03/2026</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-medium mb-2">Trạng thái</label>
                            <select class="form-select glass-input rounded-3">
                                <option value="" selected>Tất cả trạng thái</option>
                                <option value="active">Đang bán</option>
                                <option value="soldout">Hết vé</option>
                                <option value="inactive">Tạm dừng</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket Types Table -->
            <div class="card glass-strong border-0 rounded-4">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th class="ps-4">Loại vé</th>
                                    <th>Sự kiện</th>
                                    <th>Giá</th>
                                    <th>Số lượng</th>
                                    <th>Đã bán</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end pe-4">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- VIP Ticket -->
                                <tr>
                                    <td class="ps-4">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="rounded-3 p-2 text-white" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                                                <i class="fas fa-crown"></i>
                                            </div>
                                            <div>
                                                <p class="fw-bold mb-0">VIP</p>
                                                <small class="text-muted">Hàng ghế đầu + Quà tặng</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>Đêm nhạc Acoustic</td>
                                    <td class="fw-bold">2,000,000 đ</td>
                                    <td>150</td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="progress flex-grow-1" style="height: 6px; width: 80px;">
                                                <div class="progress-bar bg-primary" style="width: 80%"></div>
                                            </div>
                                            <span class="small">120</span>
                                        </div>
                                    </td>
                                    <td><span class="badge badge-status-active rounded-pill px-3 py-2">Đang bán</span></td>
                                    <td class="text-end pe-4">
                                        <button class="btn btn-sm btn-light rounded-circle me-1"><i class="fas fa-edit"></i></button>
                                        <button class="btn btn-sm btn-light rounded-circle me-1"><i class="fas fa-pause"></i></button>
                                        <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                                    </td>
                                </tr>

                                <!-- Premium Ticket -->
                                <tr>
                                    <td class="ps-4">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="rounded-3 p-2 text-white" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">
                                                <i class="fas fa-star"></i>
                                            </div>
                                            <div>
                                                <p class="fw-bold mb-0">Premium</p>
                                                <small class="text-muted">Khu vực ưu tiên</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>Đêm nhạc Acoustic</td>
                                    <td class="fw-bold">1,200,000 đ</td>
                                    <td>300</td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="progress flex-grow-1" style="height: 6px; width: 80px;">
                                                <div class="progress-bar bg-primary" style="width: 93%"></div>
                                            </div>
                                            <span class="small">280</span>
                                        </div>
                                    </td>
                                    <td><span class="badge badge-status-active rounded-pill px-3 py-2">Đang bán</span></td>
                                    <td class="text-end pe-4">
                                        <button class="btn btn-sm btn-light rounded-circle me-1"><i class="fas fa-edit"></i></button>
                                        <button class="btn btn-sm btn-light rounded-circle me-1"><i class="fas fa-pause"></i></button>
                                        <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                                    </td>
                                </tr>

                                <!-- Standard Ticket -->
                                <tr>
                                    <td class="ps-4">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="rounded-3 p-2 text-white" style="background: linear-gradient(135deg, #3b82f6, #2563eb);">
                                                <i class="fas fa-ticket-alt"></i>
                                            </div>
                                            <div>
                                                <p class="fw-bold mb-0">Standard</p>
                                                <small class="text-muted">Vé thường</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>Đêm nhạc Acoustic</td>
                                    <td class="fw-bold">500,000 đ</td>
                                    <td>500</td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="progress flex-grow-1" style="height: 6px; width: 80px;">
                                                <div class="progress-bar bg-danger" style="width: 100%"></div>
                                            </div>
                                            <span class="small">500</span>
                                        </div>
                                    </td>
                                    <td><span class="badge badge-status-inactive rounded-pill px-3 py-2">Hết vé</span></td>
                                    <td class="text-end pe-4">
                                        <button class="btn btn-sm btn-light rounded-circle me-1"><i class="fas fa-edit"></i></button>
                                        <button class="btn btn-sm btn-light rounded-circle me-1"><i class="fas fa-play"></i></button>
                                        <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                                    </td>
                                </tr>

                                <!-- Economy Ticket -->
                                <tr>
                                    <td class="ps-4">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="rounded-3 p-2 text-white" style="background: linear-gradient(135deg, #10b981, #059669);">
                                                <i class="fas fa-tag"></i>
                                            </div>
                                            <div>
                                                <p class="fw-bold mb-0">Economy</p>
                                                <small class="text-muted">Vé tiết kiệm</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>Workshop Marketing</td>
                                    <td class="fw-bold">200,000 đ</td>
                                    <td>200</td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="progress flex-grow-1" style="height: 6px; width: 80px;">
                                                <div class="progress-bar bg-primary" style="width: 45%"></div>
                                            </div>
                                            <span class="small">90</span>
                                        </div>
                                    </td>
                                    <td><span class="badge badge-status-pending rounded-pill px-3 py-2">Tạm dừng</span></td>
                                    <td class="text-end pe-4">
                                        <button class="btn btn-sm btn-light rounded-circle me-1"><i class="fas fa-edit"></i></button>
                                        <button class="btn btn-sm btn-light rounded-circle me-1"><i class="fas fa-play"></i></button>
                                        <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Ticket Modal -->
<div class="modal fade modal-glass" id="ticketModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-strong border-0 rounded-4">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Thêm loại vé mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-medium">Sự kiện <span class="text-danger">*</span></label>
                            <select class="form-select glass-input rounded-3">
                                <option value="" selected disabled>Chọn sự kiện</option>
                                <option value="1">Đêm nhạc Acoustic - 15/02/2026</option>
                                <option value="2">Workshop Marketing - 20/02/2026</option>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-medium">Tên loại vé <span class="text-danger">*</span></label>
                            <input type="text" class="form-control glass-input rounded-3" placeholder="VD: VIP, Premium, Standard...">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Mô tả</label>
                        <textarea class="form-control glass-input rounded-3" rows="2" placeholder="Mô tả quyền lợi của loại vé này..."></textarea>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label fw-medium">Giá vé <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="number" class="form-control glass-input rounded-start-3" placeholder="0">
                                <span class="input-group-text bg-transparent border-0">đ</span>
                            </div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label fw-medium">Số lượng <span class="text-danger">*</span></label>
                            <input type="number" class="form-control glass-input rounded-3" placeholder="0">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label fw-medium">Số vé tối đa/đơn</label>
                            <input type="number" class="form-control glass-input rounded-3" placeholder="10" value="10">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-medium">Ngày bắt đầu bán</label>
                            <input type="datetime-local" class="form-control glass-input rounded-3">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-medium">Ngày kết thúc bán</label>
                            <input type="datetime-local" class="form-control glass-input rounded-3">
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-gradient rounded-pill px-4">
                    <i class="fas fa-save me-2"></i>Lưu loại vé
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
