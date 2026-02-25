<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="users"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <h2 class="fw-bold mb-0">👥 Quản lý người dùng</h2>
                <button class="btn btn-gradient rounded-pill px-4 hover-glow" data-bs-toggle="modal" data-bs-target="#addUserModal">
                    <i class="fas fa-plus me-2"></i>Thêm người dùng
                </button>
            </div>

            <!-- Stats -->
            <div class="row g-3 mb-4">
                <div class="col-md-3 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #3b82f6, #6366f1);">
                                <i class="fas fa-users text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0 counter" data-target="12458">0</h4>
                                <small class="text-muted">Tổng cộng</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-user-check text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0 counter" data-target="10234">0</h4>
                                <small class="text-muted">Hoạt động</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #9333ea, #a855f7);">
                                <i class="fas fa-microphone-alt text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0 counter" data-target="85">0</h4>
                                <small class="text-muted">Organizer</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 animate-on-scroll stagger-3">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #f59e0b, #f97316);">
                                <i class="fas fa-user-slash text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0 counter" data-target="24">0</h4>
                                <small class="text-muted">Bị khóa</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Search & Filter -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body d-flex gap-3 align-items-center flex-wrap p-3">
                    <div class="input-group" style="max-width: 320px;">
                        <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" class="form-control glass border-0" placeholder="Tìm kiếm user..." id="userSearch">
                    </div>
                    <select class="form-select glass border-0 rounded-3" style="max-width: 160px;" id="roleFilter">
                        <option value="">Tất cả vai trò</option>
                        <option>Admin</option>
                        <option>Organizer</option>
                        <option>Customer</option>
                    </select>
                    <select class="form-select glass border-0 rounded-3" style="max-width: 160px;" id="statusFilter">
                        <option value="">Tất cả trạng thái</option>
                        <option>Hoạt động</option>
                        <option>Bị khóa</option>
                    </select>
                </div>
            </div>

            <!-- Users Table -->
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Người dùng</th>
                                    <th>Email</th>
                                    <th>Vai trò</th>
                                    <th>Đăng ký</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="user" items="${users}">
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold" 
                                                 style="width: 40px; height: 40px; background: linear-gradient(135deg, var(--primary), var(--secondary)); font-size: 0.85rem;">
                                                ${user.fullName.charAt(0)}
                                            </div>
                                            <span class="fw-medium">${user.fullName}</span>
                                        </div>
                                    </td>
                                    <td class="text-muted">${user.email}</td>
                                    <td>
                                        <span class="badge rounded-pill px-3 py-2 ${user.role == 'ADMIN' ? '' : user.role == 'ORGANIZER' ? '' : ''}"
                                              style="background: ${user.role == 'ADMIN' ? 'linear-gradient(135deg,#ef4444,#f97316)' : user.role == 'ORGANIZER' ? 'linear-gradient(135deg,#9333ea,#a855f7)' : 'linear-gradient(135deg,#3b82f6,#6366f1)'}; color: white;">
                                            ${user.role}
                                        </span>
                                    </td>
                                    <td class="text-muted">${user.createdAt}</td>
                                    <td>
                                        <span class="badge ${user.isActive ? 'bg-success' : 'bg-danger'} rounded-pill px-3 py-2">
                                            ${user.isActive ? 'Hoạt động' : 'Bị khóa'}
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <div class="btn-group btn-group-sm">
                                            <button class="btn glass rounded-pill px-3" title="Chỉnh sửa"><i class="fas fa-edit text-primary"></i></button>
                                            <button class="btn glass rounded-pill px-3" title="Khóa"><i class="fas fa-ban text-warning"></i></button>
                                            <button class="btn glass rounded-pill px-3" title="Xóa"><i class="fas fa-trash text-danger"></i></button>
                                        </div>
                                    </td>
                                </tr>
                                </c:forEach>
                                <c:if test="${empty users}">
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold" style="width: 40px; height: 40px; background: linear-gradient(135deg, #ef4444, #f97316);">A</div>
                                            <span class="fw-medium">Admin System</span>
                                        </div>
                                    </td>
                                    <td class="text-muted">admin@sellingticket.vn</td>
                                    <td><span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg,#ef4444,#f97316); color: white;">ADMIN</span></td>
                                    <td class="text-muted">01/01/2026</td>
                                    <td><span class="badge bg-success rounded-pill px-3 py-2">Hoạt động</span></td>
                                    <td class="text-center">
                                        <div class="btn-group btn-group-sm">
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-edit text-primary"></i></button>
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-ban text-warning"></i></button>
                                        </div>
                                    </td>
                                </tr>
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold" style="width: 40px; height: 40px; background: linear-gradient(135deg, #9333ea, #a855f7);">L</div>
                                            <span class="fw-medium">Live Nation VN</span>
                                        </div>
                                    </td>
                                    <td class="text-muted">org@livenation.vn</td>
                                    <td><span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg,#9333ea,#a855f7); color: white;">ORGANIZER</span></td>
                                    <td class="text-muted">05/01/2026</td>
                                    <td><span class="badge bg-success rounded-pill px-3 py-2">Hoạt động</span></td>
                                    <td class="text-center">
                                        <div class="btn-group btn-group-sm">
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-edit text-primary"></i></button>
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-ban text-warning"></i></button>
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-trash text-danger"></i></button>
                                        </div>
                                    </td>
                                </tr>
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold" style="width: 40px; height: 40px; background: linear-gradient(135deg, #3b82f6, #6366f1);">N</div>
                                            <span class="fw-medium">Nguyễn Văn A</span>
                                        </div>
                                    </td>
                                    <td class="text-muted">nguyenvana@email.com</td>
                                    <td><span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg,#3b82f6,#6366f1); color: white;">CUSTOMER</span></td>
                                    <td class="text-muted">10/01/2026</td>
                                    <td><span class="badge bg-success rounded-pill px-3 py-2">Hoạt động</span></td>
                                    <td class="text-center">
                                        <div class="btn-group btn-group-sm">
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-edit text-primary"></i></button>
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-ban text-warning"></i></button>
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-trash text-danger"></i></button>
                                        </div>
                                    </td>
                                </tr>
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold" style="width: 40px; height: 40px; background: linear-gradient(135deg, #3b82f6, #6366f1);">T</div>
                                            <span class="fw-medium">Trần Thị B</span>
                                        </div>
                                    </td>
                                    <td class="text-muted">tranthib@email.com</td>
                                    <td><span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg,#3b82f6,#6366f1); color: white;">CUSTOMER</span></td>
                                    <td class="text-muted">12/01/2026</td>
                                    <td><span class="badge bg-danger rounded-pill px-3 py-2">Bị khóa</span></td>
                                    <td class="text-center">
                                        <div class="btn-group btn-group-sm">
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-edit text-primary"></i></button>
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-unlock text-success"></i></button>
                                            <button class="btn glass rounded-pill px-3"><i class="fas fa-trash text-danger"></i></button>
                                        </div>
                                    </td>
                                </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Pagination -->
            <nav class="mt-4 d-flex justify-content-center animate-on-scroll">
                <ul class="pagination">
                    <li class="page-item disabled"><a class="page-link glass rounded-start-3" href="#"><i class="fas fa-chevron-left"></i></a></li>
                    <li class="page-item active"><a class="page-link" href="#" style="background: linear-gradient(135deg, var(--primary), var(--secondary)); border: none;">1</a></li>
                    <li class="page-item"><a class="page-link glass" href="#">2</a></li>
                    <li class="page-item"><a class="page-link glass" href="#">3</a></li>
                    <li class="page-item"><a class="page-link glass rounded-end-3" href="#"><i class="fas fa-chevron-right"></i></a></li>
                </ul>
            </nav>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.counter').forEach(el => {
        const target = parseInt(el.dataset.target);
        const duration = 1500;
        const step = target / (duration / 16);
        let current = 0;
        const timer = setInterval(() => {
            current += step;
            if (current >= target) { current = target; clearInterval(timer); }
            el.textContent = Math.floor(current).toLocaleString('vi-VN');
        }, 16);
    });

    const searchInput = document.getElementById('userSearch');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            const q = this.value.toLowerCase();
            document.querySelectorAll('.table-glass tbody tr').forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
            });
        });
    }
});
</script>

<jsp:include page="../footer.jsp" />
