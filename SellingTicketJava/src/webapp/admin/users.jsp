<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="users"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="fw-bold mb-0">Quản lý Users</h2>
                <div class="d-flex gap-2">
                    <div class="input-group" style="width: 250px;">
                        <span class="input-group-text glass"><i class="fas fa-search"></i></span>
                        <input type="text" class="form-control" placeholder="Tìm kiếm user...">
                    </div>
                    <button class="btn btn-gradient rounded-pill px-4">
                        <i class="fas fa-plus me-2"></i>Thêm User
                    </button>
                </div>
            </div>

            <!-- Users Table -->
            <div class="card glass-strong border-0 rounded-4">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>User</th>
                                    <th>Email</th>
                                    <th>Vai trò</th>
                                    <th>Ngày đăng ký</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100" class="rounded-circle" style="width: 40px; height: 40px; object-fit: cover;">
                                            <span class="fw-medium">Nguyễn Văn A</span>
                                        </div>
                                    </td>
                                    <td>nguyenvana@email.com</td>
                                    <td><span class="badge bg-primary rounded-pill">Customer</span></td>
                                    <td>01/01/2026</td>
                                    <td><span class="badge bg-success rounded-pill">Active</span></td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></button>
                                        <button class="btn btn-sm btn-outline-danger"><i class="fas fa-ban"></i></button>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <img src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100" class="rounded-circle" style="width: 40px; height: 40px; object-fit: cover;">
                                            <span class="fw-medium">Trần Thị B</span>
                                        </div>
                                    </td>
                                    <td>tranthib@email.com</td>
                                    <td><span class="badge bg-warning text-dark rounded-pill">Organizer</span></td>
                                    <td>15/12/2025</td>
                                    <td><span class="badge bg-success rounded-pill">Active</span></td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></button>
                                        <button class="btn btn-sm btn-outline-danger"><i class="fas fa-ban"></i></button>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100" class="rounded-circle" style="width: 40px; height: 40px; object-fit: cover;">
                                            <span class="fw-medium">Admin User</span>
                                        </div>
                                    </td>
                                    <td>admin@ticketbox.vn</td>
                                    <td><span class="badge bg-danger rounded-pill">Admin</span></td>
                                    <td>01/01/2025</td>
                                    <td><span class="badge bg-success rounded-pill">Active</span></td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary"><i class="fas fa-edit"></i></button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination -->
                    <nav class="mt-4">
                        <ul class="pagination justify-content-center mb-0">
                            <li class="page-item disabled"><a class="page-link" href="#">Trước</a></li>
                            <li class="page-item active"><a class="page-link" href="#">1</a></li>
                            <li class="page-item"><a class="page-link" href="#">2</a></li>
                            <li class="page-item"><a class="page-link" href="#">3</a></li>
                            <li class="page-item"><a class="page-link" href="#">Sau</a></li>
                        </ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
