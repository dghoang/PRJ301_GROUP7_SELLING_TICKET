<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

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
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-user text-primary me-2"></i>Chi tiết người dùng</h2>
                    <p class="text-muted mb-0">Theo dõi thông tin và quản trị vai trò/trạng thái tài khoản</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users" class="btn glass rounded-pill px-4">
                    <i class="fas fa-arrow-left me-2"></i>Quay lại danh sách
                </a>
            </div>

            <c:if test="${empty user}">
                <div class="alert alert-danger rounded-4">Không tìm thấy người dùng.</div>
            </c:if>

            <c:if test="${not empty user}">
                <c:set var="roleNormalized" value="${fn:toLowerCase(user.role)}"/>

                <div class="row g-4">
                    <div class="col-lg-8">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <div class="d-flex align-items-center gap-3 mb-4">
                                    <c:choose>
                                        <c:when test="${not empty user.avatar}">
                                            <img src="${user.avatar}" alt="avatar" class="rounded-circle object-fit-cover" style="width:72px;height:72px;">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="rounded-circle d-flex align-items-center justify-content-center text-white fw-bold"
                                                 style="width:72px;height:72px;background:linear-gradient(135deg,#3b82f6,#6366f1);font-size:1.5rem;">
                                                ${fn:substring(user.fullName, 0, 1)}
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <h4 class="fw-bold mb-1">${user.fullName}</h4>
                                        <div class="text-muted">${user.email}</div>
                                        <span class="badge ${user.deleted ? 'bg-secondary' : (user.active ? 'bg-success' : 'bg-danger')} rounded-pill mt-2">
                                            ${user.deleted ? 'Đã xóa' : (user.active ? 'Đang hoạt động' : 'Đã khóa')}
                                        </span>
                                    </div>
                                </div>

                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <div class="p-3 rounded-3" style="background:rgba(255,255,255,0.7);">
                                            <div class="small text-muted mb-1">ID người dùng</div>
                                            <div class="fw-bold">#${user.userId}</div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="p-3 rounded-3" style="background:rgba(255,255,255,0.7);">
                                            <div class="small text-muted mb-1">Vai trò hiện tại</div>
                                            <div class="fw-bold text-uppercase">${user.role}</div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="p-3 rounded-3" style="background:rgba(255,255,255,0.7);">
                                            <div class="small text-muted mb-1">Số điện thoại</div>
                                            <div class="fw-medium">${empty user.phone ? 'Chưa cập nhật' : user.phone}</div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="p-3 rounded-3" style="background:rgba(255,255,255,0.7);">
                                            <div class="small text-muted mb-1">Ngày tạo</div>
                                            <div class="fw-medium">
                                                <c:choose>
                                                    <c:when test="${not empty user.createdAt}">
                                                        <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </c:when>
                                                    <c:otherwise>Không rõ</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-3"><i class="fas fa-shield-alt text-primary me-2"></i>Quản trị tài khoản</h5>
                                <c:if test="${user.deleted}">
                                    <div class="alert alert-secondary rounded-3 mb-0">
                                        <i class="fas fa-trash me-2"></i>Tài khoản này đã được đánh dấu xóa mềm.
                                    </div>
                                </c:if>

                                <c:if test="${not user.deleted}">
                                    <form action="${pageContext.request.contextPath}/admin/users/update-role" method="POST" class="mb-3">
                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                        <input type="hidden" name="userId" value="${user.userId}">

                                        <label class="form-label fw-medium">Đổi vai trò</label>
                                        <select name="role" id="detailRoleSelect" class="form-select rounded-3 mb-2">
                                            <option value="customer" ${roleNormalized == 'customer' ? 'selected' : ''}>Khách hàng</option>
                                            <option value="support_agent" ${roleNormalized == 'support_agent' ? 'selected' : ''}>Hỗ trợ viên</option>
                                            <option value="admin" ${roleNormalized == 'admin' ? 'selected' : ''}>Admin</option>
                                        </select>
                                        <input type="password" id="detailAdminKey" name="adminKey" class="form-control rounded-3 mb-2 d-none" placeholder="Nhập mật khẩu admin">
                                        <button type="submit" class="btn btn-primary w-100 rounded-pill">Lưu vai trò</button>
                                    </form>

                                    <c:if test="${user.active}">
                                        <form action="${pageContext.request.contextPath}/admin/users/deactivate" method="POST">
                                            <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                            <input type="hidden" name="userId" value="${user.userId}">
                                            <button type="submit" class="btn btn-outline-warning w-100 rounded-pill"
                                                    onclick="return confirm('Khóa tài khoản này?');">
                                                <i class="fas fa-ban me-2"></i>Khóa tài khoản
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${not user.active}">
                                        <form action="${pageContext.request.contextPath}/admin/users/activate" method="POST">
                                            <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                            <input type="hidden" name="userId" value="${user.userId}">
                                            <button type="submit" class="btn btn-outline-success w-100 rounded-pill"
                                                    onclick="return confirm('Mở khóa tài khoản này?');">
                                                <i class="fas fa-unlock me-2"></i>Mở khóa tài khoản
                                            </button>
                                        </form>
                                    </c:if>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const roleSelect = document.getElementById('detailRoleSelect');
    const keyInput = document.getElementById('detailAdminKey');
    if (!roleSelect || !keyInput) return;

    const toggleAdminKey = () => {
        if (roleSelect.value === 'admin') {
            keyInput.classList.remove('d-none');
            keyInput.required = true;
        } else {
            keyInput.classList.add('d-none');
            keyInput.required = false;
            keyInput.value = '';
        }
    };

    roleSelect.addEventListener('change', toggleAdminKey);
    toggleAdminKey();
});
</script>

<jsp:include page="../footer.jsp" />
