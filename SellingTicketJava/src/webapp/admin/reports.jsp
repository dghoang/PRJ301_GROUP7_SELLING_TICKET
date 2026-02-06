<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="reports"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <h2 class="fw-bold mb-4">Báo cáo thống kê</h2>

            <!-- Date Filter -->
            <div class="card glass-strong border-0 rounded-4 mb-4">
                <div class="card-body d-flex gap-3 align-items-center flex-wrap">
                    <span class="fw-medium">Thời gian:</span>
                    <div class="btn-group">
                        <button class="btn btn-outline-primary btn-sm">Hôm nay</button>
                        <button class="btn btn-outline-primary btn-sm">7 ngày</button>
                        <button class="btn btn-outline-primary btn-sm active">30 ngày</button>
                        <button class="btn btn-outline-primary btn-sm">Năm</button>
                    </div>
                    <div class="ms-auto d-flex gap-2">
                        <input type="date" class="form-control form-control-sm" value="2026-01-01">
                        <span class="align-self-center">-</span>
                        <input type="date" class="form-control form-control-sm" value="2026-02-04">
                        <button class="btn btn-gradient btn-sm rounded-pill px-3">Áp dụng</button>
                    </div>
                </div>
            </div>

            <!-- Stats Row -->
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4">
                        <h2 class="fw-bold text-primary mb-1">2.5 tỷ</h2>
                        <p class="text-muted small mb-0">Tổng doanh thu</p>
                        <small class="text-success"><i class="fas fa-arrow-up"></i> +15% so với kỳ trước</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4">
                        <h2 class="fw-bold text-success mb-1">45,892</h2>
                        <p class="text-muted small mb-0">Vé bán ra</p>
                        <small class="text-success"><i class="fas fa-arrow-up"></i> +8% so với kỳ trước</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4">
                        <h2 class="fw-bold text-warning mb-1">156</h2>
                        <p class="text-muted small mb-0">Sự kiện diễn ra</p>
                        <small class="text-success"><i class="fas fa-arrow-up"></i> +12 events</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4">
                        <h2 class="fw-bold text-info mb-1">2,458</h2>
                        <p class="text-muted small mb-0">Users mới</p>
                        <small class="text-success"><i class="fas fa-arrow-up"></i> +20% growth</small>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <!-- Top Events -->
                <div class="col-lg-6">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0">
                            <h5 class="fw-bold mb-0">Top sự kiện bán chạy</h5>
                        </div>
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                                <div class="d-flex align-items-center gap-3">
                                    <span class="badge bg-primary rounded-circle" style="width: 28px; height: 28px; line-height: 20px;">1</span>
                                    <div>
                                        <p class="fw-medium mb-0">Đêm nhạc Acoustic</p>
                                        <small class="text-muted">Live Nation</small>
                                    </div>
                                </div>
                                <span class="fw-bold">5,200 vé</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                                <div class="d-flex align-items-center gap-3">
                                    <span class="badge bg-secondary rounded-circle" style="width: 28px; height: 28px; line-height: 20px;">2</span>
                                    <div>
                                        <p class="fw-medium mb-0">Tech Conference 2026</p>
                                        <small class="text-muted">TechVN</small>
                                    </div>
                                </div>
                                <span class="fw-bold">3,800 vé</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="d-flex align-items-center gap-3">
                                    <span class="badge bg-warning text-dark rounded-circle" style="width: 28px; height: 28px; line-height: 20px;">3</span>
                                    <div>
                                        <p class="fw-medium mb-0">EDM Festival</p>
                                        <small class="text-muted">Ravolution</small>
                                    </div>
                                </div>
                                <span class="fw-bold">2,500 vé</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Revenue by Category -->
                <div class="col-lg-6">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0">
                            <h5 class="fw-bold mb-0">Doanh thu theo danh mục</h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>Âm nhạc</span>
                                    <span class="fw-bold">45%</span>
                                </div>
                                <div class="progress" style="height: 8px;">
                                    <div class="progress-bar bg-primary" style="width: 45%;"></div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>Workshop</span>
                                    <span class="fw-bold">25%</span>
                                </div>
                                <div class="progress" style="height: 8px;">
                                    <div class="progress-bar bg-success" style="width: 25%;"></div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>Thể thao</span>
                                    <span class="fw-bold">18%</span>
                                </div>
                                <div class="progress" style="height: 8px;">
                                    <div class="progress-bar bg-warning" style="width: 18%;"></div>
                                </div>
                            </div>
                            <div>
                                <div class="d-flex justify-content-between mb-1">
                                    <span>Khác</span>
                                    <span class="fw-bold">12%</span>
                                </div>
                                <div class="progress" style="height: 8px;">
                                    <div class="progress-bar bg-info" style="width: 12%;"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
