<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

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
            </div>

            <%-- Success/Error Alerts --%>
            <c:if test="${param.success != null}">
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="background: rgba(16,185,129,0.1); border-left: 4px solid #10b981 !important;">
                    <i class="fas fa-check-circle text-success me-2"></i>
                    <c:choose>
                        <c:when test="${param.success == 'deactivated'}">Người dùng đã bị khóa!</c:when>
                        <c:when test="${param.success == 'activated'}">Người dùng đã được mở khóa!</c:when>
                        <c:when test="${param.success == 'role_updated'}">Cập nhật vai trò thành công!</c:when>
                        <c:otherwise>Thao tác thành công!</c:otherwise>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.error != null}">
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="background: rgba(239,68,68,0.1); border-left: 4px solid #ef4444 !important;">
                    <i class="fas fa-exclamation-circle text-danger me-2"></i>
                    <c:choose>
                        <c:when test="${param.error == 'deactivate_failed'}">Khóa tài khoản thất bại!</c:when>
                        <c:when test="${param.error == 'activate_failed'}">Mở khóa tài khoản thất bại!</c:when>
                        <c:when test="${param.error == 'update_failed'}">Cập nhật vai trò thất bại!</c:when>
                        <c:otherwise>Có lỗi xảy ra!</c:otherwise>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Stats -->
            <div class="row g-3 mb-4">
                <div class="col-md-3 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #3b82f6, #6366f1);">
                                <i class="fas fa-users text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">${totalUsers != null ? totalUsers : 0}</h4>
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
                                <h4 class="fw-bold mb-0">${activeUsers != null ? activeUsers : 0}</h4>
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
                                <h4 class="fw-bold mb-0">${organizerCount != null ? organizerCount : 0}</h4>
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
                                <h4 class="fw-bold mb-0">${lockedUsers != null ? lockedUsers : 0}</h4>
                                <small class="text-muted">Bị khóa</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Search & Filter -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body d-flex gap-3 align-items-center flex-wrap p-3">
                    <form action="${pageContext.request.contextPath}/admin/users/search" method="GET" class="d-flex w-100 gap-3">
                        <div class="input-group" style="max-width: 320px;">
                            <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                            <input type="text" name="q" value="${searchKeyword}" class="form-control glass border-0" placeholder="Tìm kiếm tên, email, SDT...">
                        </div>
                        <button type="submit" class="btn btn-primary rounded-3 px-4">Tìm</button>
                        <c:if test="${not empty searchKeyword}">
                            <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-light rounded-3">Xóa bộ lọc</a>
                        </c:if>
                    </form>
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
                                <c:choose>
                                    <c:when test="${empty users}">
                                        <tr>
                                            <td colspan="6" class="text-center py-5">
                                                <div class="dash-icon-box mx-auto mb-3" style="width: 64px; height: 64px; background: rgba(148,163,184,0.1);">
                                                    <i class="fas fa-users fa-2x text-muted"></i>
                                                </div>
                                                <h5 class="fw-bold text-muted">Không tìm thấy người dùng nào.</h5>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="user" items="${users}">
                                            <tr class="hover-lift" style="transition: all 0.2s;">
                                                <td>
                                                    <div class="d-flex align-items-center gap-3">
                                                        <c:choose>
                                                            <c:when test="${not empty user.avatar}">
                                                                <img src="${user.avatar}" alt="Avatar" class="rounded-circle object-fit-cover shadow-sm" style="width: 40px; height: 40px;">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold shadow-sm" 
                                                                     style="width: 40px; height: 40px; background: linear-gradient(135deg, var(--primary), var(--secondary)); font-size: 0.85rem;">
                                                                    ${user.fullName.substring(0, 1).toUpperCase()}
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <span class="fw-medium">${user.fullName}</span>
                                                    </div>
                                                </td>
                                                <td class="text-muted">${user.email}</td>
                                                <td>
                                                    <c:set var="roleClass" value="bg-secondary" />
                                                    <c:set var="roleStyle" value="" />
                                                    <c:choose>
                                                        <c:when test="${user.role == 'ADMIN'}">
                                                            <c:set var="roleStyle" value="background: linear-gradient(135deg,#ef4444,#f97316); color: white;" />
                                                        </c:when>
                                                        <c:when test="${user.role == 'ORGANIZER'}">
                                                            <c:set var="roleStyle" value="background: linear-gradient(135deg,#9333ea,#a855f7); color: white;" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:set var="roleStyle" value="background: linear-gradient(135deg,#3b82f6,#6366f1); color: white;" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <span class="badge rounded-pill px-3 py-2" style="${roleStyle}">
                                                        ${user.role}
                                                    </span>
                                                </td>
                                                <td class="text-muted"><fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy" /></td>
                                                <td>
                                                    <span class="badge ${user.active ? 'bg-success' : 'bg-danger'} rounded-pill px-3 py-2">
                                                        ${user.active ? 'Hoạt động' : 'Bị khóa'}
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <div class="d-flex justify-content-center gap-2 flex-wrap">
                                                        <c:choose>
                                                            <c:when test="${user.userId == sessionScope.adminUser.userId}">
                                                                <span class="badge bg-light text-muted border">Bạn</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <%-- Role Change --%>
                                                                <form action="${pageContext.request.contextPath}/admin/users/update-role" method="POST" class="d-flex gap-1 align-items-center">
                                                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                                                    <input type="hidden" name="userId" value="${user.userId}">
                                                                    <select name="role" class="form-select form-select-sm rounded-3" style="font-size:0.75rem; width:110px;"
                                                                            onchange="if(confirm('Đổi vai trò người dùng này?')) this.form.submit();">
                                                                        <option value="customer" ${user.role == 'CUSTOMER' ? 'selected' : ''}>Khách hàng</option>
                                                                        <option value="organizer" ${user.role == 'ORGANIZER' ? 'selected' : ''}>Organizer</option>
                                                                        <c:if test="${sessionScope.adminUser.role == 'ADMIN'}">
                                                                            <option value="admin" ${user.role == 'ADMIN' ? 'selected' : ''}>Admin</option>
                                                                        </c:if>
                                                                    </select>
                                                                </form>
                                                                <%-- Lock/Unlock --%>
                                                                <c:choose>
                                                                    <c:when test="${user.active}">
                                                                        <form action="${pageContext.request.contextPath}/admin/users/deactivate" method="POST" class="d-inline">
                                                                            <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                                                            <input type="hidden" name="userId" value="${user.userId}">
                                                                            <button class="btn btn-sm btn-light text-warning rounded-circle shadow-sm" title="Khóa tài khoản"
                                                                                    onclick="return confirm('Bạn có chắc chắn muốn khóa tài khoản này?');">
                                                                                <i class="fas fa-ban"></i>
                                                                            </button>
                                                                        </form>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <form action="${pageContext.request.contextPath}/admin/users/activate" method="POST" class="d-inline">
                                                                            <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                                                            <input type="hidden" name="userId" value="${user.userId}">
                                                                            <button class="btn btn-sm btn-light text-success rounded-circle shadow-sm" title="Mở khóa tài khoản"
                                                                                    onclick="return confirm('Bạn có muốn mở khóa tài khoản này?');">
                                                                                <i class="fas fa-unlock"></i>
                                                                            </button>
                                                                        </form>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
