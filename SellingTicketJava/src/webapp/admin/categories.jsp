<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="categories"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">Quản lý danh mục</h2>
                    <p class="text-muted mb-0">Tạo và quản lý các danh mục sự kiện</p>
                </div>
                <button class="btn btn-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#categoryModal">
                    <i class="fas fa-plus me-2"></i>Thêm danh mục
                </button>
            </div>

            <!-- Categories Grid -->
            <div class="row g-4">
                <!-- Category: Âm nhạc -->
                <div class="col-md-4 col-lg-3">
                    <div class="card glass-strong border-0 rounded-4 card-hover h-100">
                        <div class="card-body p-4 text-center">
                            <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, #ec4899, #a855f7);">
                                <i class="fas fa-music fa-lg text-white"></i>
                            </div>
                            <h6 class="fw-bold mb-1">Âm nhạc</h6>
                            <p class="text-muted small mb-3">45 sự kiện</p>
                            <div class="d-flex gap-2 justify-content-center">
                                <button class="btn btn-sm btn-light rounded-circle"><i class="fas fa-edit"></i></button>
                                <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Category: Workshop -->
                <div class="col-md-4 col-lg-3">
                    <div class="card glass-strong border-0 rounded-4 card-hover h-100">
                        <div class="card-body p-4 text-center">
                            <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, #3b82f6, #1d4ed8);">
                                <i class="fas fa-graduation-cap fa-lg text-white"></i>
                            </div>
                            <h6 class="fw-bold mb-1">Workshop</h6>
                            <p class="text-muted small mb-3">32 sự kiện</p>
                            <div class="d-flex gap-2 justify-content-center">
                                <button class="btn btn-sm btn-light rounded-circle"><i class="fas fa-edit"></i></button>
                                <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Category: Thể thao -->
                <div class="col-md-4 col-lg-3">
                    <div class="card glass-strong border-0 rounded-4 card-hover h-100">
                        <div class="card-body p-4 text-center">
                            <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, #10b981, #059669);">
                                <i class="fas fa-running fa-lg text-white"></i>
                            </div>
                            <h6 class="fw-bold mb-1">Thể thao</h6>
                            <p class="text-muted small mb-3">28 sự kiện</p>
                            <div class="d-flex gap-2 justify-content-center">
                                <button class="btn btn-sm btn-light rounded-circle"><i class="fas fa-edit"></i></button>
                                <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Category: Nghệ thuật -->
                <div class="col-md-4 col-lg-3">
                    <div class="card glass-strong border-0 rounded-4 card-hover h-100">
                        <div class="card-body p-4 text-center">
                            <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, #f59e0b, #d97706);">
                                <i class="fas fa-palette fa-lg text-white"></i>
                            </div>
                            <h6 class="fw-bold mb-1">Nghệ thuật</h6>
                            <p class="text-muted small mb-3">18 sự kiện</p>
                            <div class="d-flex gap-2 justify-content-center">
                                <button class="btn btn-sm btn-light rounded-circle"><i class="fas fa-edit"></i></button>
                                <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Category: Ẩm thực -->
                <div class="col-md-4 col-lg-3">
                    <div class="card glass-strong border-0 rounded-4 card-hover h-100">
                        <div class="card-body p-4 text-center">
                            <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, #ef4444, #dc2626);">
                                <i class="fas fa-utensils fa-lg text-white"></i>
                            </div>
                            <h6 class="fw-bold mb-1">Ẩm thực</h6>
                            <p class="text-muted small mb-3">15 sự kiện</p>
                            <div class="d-flex gap-2 justify-content-center">
                                <button class="btn btn-sm btn-light rounded-circle"><i class="fas fa-edit"></i></button>
                                <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Category: Kinh doanh -->
                <div class="col-md-4 col-lg-3">
                    <div class="card glass-strong border-0 rounded-4 card-hover h-100">
                        <div class="card-body p-4 text-center">
                            <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, #6366f1, #4f46e5);">
                                <i class="fas fa-briefcase fa-lg text-white"></i>
                            </div>
                            <h6 class="fw-bold mb-1">Kinh doanh</h6>
                            <p class="text-muted small mb-3">22 sự kiện</p>
                            <div class="d-flex gap-2 justify-content-center">
                                <button class="btn btn-sm btn-light rounded-circle"><i class="fas fa-edit"></i></button>
                                <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Category: Công nghệ -->
                <div class="col-md-4 col-lg-3">
                    <div class="card glass-strong border-0 rounded-4 card-hover h-100">
                        <div class="card-body p-4 text-center">
                            <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, #06b6d4, #0891b2);">
                                <i class="fas fa-laptop-code fa-lg text-white"></i>
                            </div>
                            <h6 class="fw-bold mb-1">Công nghệ</h6>
                            <p class="text-muted small mb-3">19 sự kiện</p>
                            <div class="d-flex gap-2 justify-content-center">
                                <button class="btn btn-sm btn-light rounded-circle"><i class="fas fa-edit"></i></button>
                                <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Category: Gia đình -->
                <div class="col-md-4 col-lg-3">
                    <div class="card glass-strong border-0 rounded-4 card-hover h-100">
                        <div class="card-body p-4 text-center">
                            <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center" style="width: 64px; height: 64px; background: linear-gradient(135deg, #f472b6, #ec4899);">
                                <i class="fas fa-users fa-lg text-white"></i>
                            </div>
                            <h6 class="fw-bold mb-1">Gia đình</h6>
                            <p class="text-muted small mb-3">12 sự kiện</p>
                            <div class="d-flex gap-2 justify-content-center">
                                <button class="btn btn-sm btn-light rounded-circle"><i class="fas fa-edit"></i></button>
                                <button class="btn btn-sm btn-light rounded-circle text-danger"><i class="fas fa-trash"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Category Modal -->
<div class="modal fade modal-glass" id="categoryModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Thêm danh mục mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Tên danh mục <span class="text-danger">*</span></label>
                        <input type="text" class="form-control glass-input rounded-3" placeholder="VD: Âm nhạc, Workshop...">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Icon (Font Awesome class)</label>
                        <input type="text" class="form-control glass-input rounded-3" placeholder="VD: fa-music, fa-running">
                        <small class="text-muted">Tham khảo: <a href="https://fontawesome.com/icons" target="_blank">fontawesome.com/icons</a></small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Màu nền (Gradient)</label>
                        <div class="row g-2">
                            <div class="col-6">
                                <input type="color" class="form-control form-control-color w-100" value="#ec4899" title="Màu bắt đầu">
                            </div>
                            <div class="col-6">
                                <input type="color" class="form-control form-control-color w-100" value="#a855f7" title="Màu kết thúc">
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Mô tả</label>
                        <textarea class="form-control glass-input rounded-3" rows="2" placeholder="Mô tả ngắn về danh mục..."></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-gradient rounded-pill px-4">
                    <i class="fas fa-save me-2"></i>Lưu danh mục
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
