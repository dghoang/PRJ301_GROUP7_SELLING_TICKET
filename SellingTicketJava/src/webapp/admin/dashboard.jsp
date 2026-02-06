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
            
            <!-- Stats Cards -->
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="bg-primary bg-opacity-10 rounded-3 p-3">
                                <i class="fas fa-calendar fa-2x text-primary"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">156</h3>
                                <small class="text-muted">Sự kiện</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="bg-success bg-opacity-10 rounded-3 p-3">
                                <i class="fas fa-users fa-2x text-success"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">12,458</h3>
                                <small class="text-muted">Users</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                                <i class="fas fa-ticket-alt fa-2x text-warning"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">45,892</h3>
                                <small class="text-muted">Vé bán ra</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body d-flex align-items-center gap-3">
                            <div class="bg-info bg-opacity-10 rounded-3 p-3">
                                <i class="fas fa-dollar-sign fa-2x text-info"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">2.5B</h3>
                                <small class="text-muted">Doanh thu</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pending Approvals -->
            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                            <h5 class="fw-bold mb-0">Sự kiện chờ duyệt</h5>
                            <a href="${pageContext.request.contextPath}/admin/events" class="btn btn-sm btn-outline-primary rounded-pill">Xem tất cả</a>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle">
                                    <thead>
                                        <tr>
                                            <th>Sự kiện</th>
                                            <th>Organizer</th>
                                            <th>Ngày gửi</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100" class="rounded" style="width: 40px; height: 40px; object-fit: cover;">
                                                    <span>Đêm nhạc Rock</span>
                                                </div>
                                            </td>
                                            <td>Live Nation</td>
                                            <td>02/02/2026</td>
                                            <td>
                                                <button class="btn btn-sm btn-success me-1"><i class="fas fa-check"></i></button>
                                                <button class="btn btn-sm btn-danger"><i class="fas fa-times"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=100" class="rounded" style="width: 40px; height: 40px; object-fit: cover;">
                                                    <span>Tech Conference 2026</span>
                                                </div>
                                            </td>
                                            <td>TechVN</td>
                                            <td>01/02/2026</td>
                                            <td>
                                                <button class="btn btn-sm btn-success me-1"><i class="fas fa-check"></i></button>
                                                <button class="btn btn-sm btn-danger"><i class="fas fa-times"></i></button>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0">
                            <h5 class="fw-bold mb-0">Hoạt động gần đây</h5>
                        </div>
                        <div class="card-body">
                            <div class="d-flex gap-3 mb-3">
                                <div class="bg-success bg-opacity-10 rounded-circle p-2">
                                    <i class="fas fa-check text-success"></i>
                                </div>
                                <div>
                                    <p class="mb-0 small">Đã duyệt sự kiện <strong>EDM Festival</strong></p>
                                    <small class="text-muted">5 phút trước</small>
                                </div>
                            </div>
                            <div class="d-flex gap-3 mb-3">
                                <div class="bg-primary bg-opacity-10 rounded-circle p-2">
                                    <i class="fas fa-user-plus text-primary"></i>
                                </div>
                                <div>
                                    <p class="mb-0 small">User mới đăng ký: <strong>nguyenvana@email.com</strong></p>
                                    <small class="text-muted">15 phút trước</small>
                                </div>
                            </div>
                            <div class="d-flex gap-3">
                                <div class="bg-warning bg-opacity-10 rounded-circle p-2">
                                    <i class="fas fa-ticket-alt text-warning"></i>
                                </div>
                                <div>
                                    <p class="mb-0 small">1000 vé đã bán cho <strong>Music Show</strong></p>
                                    <small class="text-muted">1 giờ trước</small>
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
