<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="dashboard"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <h2 class="fw-bold mb-4">Dashboard</h2>
            
            <!-- Stats -->
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="bg-primary bg-opacity-10 rounded-3 p-3">
                                <i class="fas fa-calendar fa-2x text-primary"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">12</h3>
                                <small class="text-muted">Sự kiện đang bán</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="bg-success bg-opacity-10 rounded-3 p-3">
                                <i class="fas fa-ticket-alt fa-2x text-success"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">2,458</h3>
                                <small class="text-muted">Vé đã bán</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                                <i class="fas fa-dollar-sign fa-2x text-warning"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">850M</h3>
                                <small class="text-muted">Doanh thu</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="bg-info bg-opacity-10 rounded-3 p-3">
                                <i class="fas fa-users fa-2x text-info"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">1,845</h3>
                                <small class="text-muted">Khách tham dự</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="card glass-strong border-0 rounded-4 mb-4">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">Hành động nhanh</h5>
                    <div class="d-flex gap-3 flex-wrap">
                        <a href="${pageContext.request.contextPath}/organizer/create-event" class="btn btn-gradient rounded-pill px-4">
                            <i class="fas fa-plus me-2"></i>Tạo sự kiện mới
                        </a>
                        <a href="${pageContext.request.contextPath}/organizer/check-in" class="btn btn-outline-primary rounded-pill px-4">
                            <i class="fas fa-qrcode me-2"></i>Quét check-in
                        </a>
                        <button class="btn btn-outline-success rounded-pill px-4">
                            <i class="fas fa-download me-2"></i>Xuất báo cáo
                        </button>
                    </div>
                </div>
            </div>

            <!-- Recent Events -->
            <div class="card glass-strong border-0 rounded-4">
                <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold mb-0">Sự kiện gần đây</h5>
                    <a href="${pageContext.request.contextPath}/organizer/events" class="btn btn-sm btn-outline-primary rounded-pill">Xem tất cả</a>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Sự kiện</th>
                                    <th>Ngày</th>
                                    <th>Vé bán</th>
                                    <th>Doanh thu</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100" class="rounded" style="width: 40px; height: 40px; object-fit: cover;">
                                            <span>Đêm nhạc Acoustic</span>
                                        </div>
                                    </td>
                                    <td>15/02/2026</td>
                                    <td>450/500</td>
                                    <td class="fw-bold text-success">180M</td>
                                    <td><span class="badge bg-success rounded-pill">Đang bán</span></td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=100" class="rounded" style="width: 40px; height: 40px; object-fit: cover;">
                                            <span>Workshop Marketing</span>
                                        </div>
                                    </td>
                                    <td>20/02/2026</td>
                                    <td>80/100</td>
                                    <td class="fw-bold text-success">40M</td>
                                    <td><span class="badge bg-success rounded-pill">Đang bán</span></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
