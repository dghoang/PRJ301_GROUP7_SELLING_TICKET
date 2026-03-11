<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="support"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-headset text-primary me-2"></i>Quản lý hỗ trợ</h2>
                    <p class="text-muted mb-0">Tiếp nhận và xử lý yêu cầu hỗ trợ từ khách hàng</p>
                </div>
            </div>

            <!-- Stats Row -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-lg-3 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body p-3 d-flex align-items-center gap-3">
                            <div class="dash-icon-box" style="background:linear-gradient(135deg,#3b82f6,#6366f1);">
                                <i class="fas fa-inbox text-white"></i>
                            </div>
                            <div>
                                <div class="small text-muted">Tổng yêu cầu</div>
                                <div class="fs-4 fw-bold">${totalTickets}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body p-3 d-flex align-items-center gap-3">
                            <div class="dash-icon-box" style="background:linear-gradient(135deg,#f59e0b,#f97316);">
                                <i class="fas fa-exclamation-circle text-white"></i>
                            </div>
                            <div>
                                <div class="small text-muted">Mở</div>
                                <div class="fs-4 fw-bold">${openCount}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body p-3 d-flex align-items-center gap-3">
                            <div class="dash-icon-box" style="background:linear-gradient(135deg,#3b82f6,#06b6d4);">
                                <i class="fas fa-spinner text-white"></i>
                            </div>
                            <div>
                                <div class="small text-muted">Đang xử lý</div>
                                <div class="fs-4 fw-bold">${inProgressCount}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 animate-on-scroll stagger-3">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body p-3 d-flex align-items-center gap-3">
                            <div class="dash-icon-box" style="background:linear-gradient(135deg,#10b981,#06b6d4);">
                                <i class="fas fa-check-circle text-white"></i>
                            </div>
                            <div>
                                <div class="small text-muted">Đã giải quyết</div>
                                <div class="fs-4 fw-bold">${resolvedCount}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filter Tabs -->
            <div class="d-flex gap-2 mb-4 flex-wrap animate-on-scroll">
                <a href="${pageContext.request.contextPath}/admin/support" class="btn ${empty statusFilter ? 'btn-primary' : 'glass'} rounded-pill px-3 py-1 small">Tất cả</a>
                <a href="${pageContext.request.contextPath}/admin/support?status=open" class="btn ${statusFilter == 'open' ? 'btn-warning' : 'glass'} rounded-pill px-3 py-1 small">
                    Mở <span class="badge bg-white bg-opacity-25 ms-1">${openCount}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/support?status=in_progress" class="btn ${statusFilter == 'in_progress' ? 'btn-info' : 'glass'} rounded-pill px-3 py-1 small">Đang xử lý</a>
                <a href="${pageContext.request.contextPath}/admin/support?status=resolved" class="btn ${statusFilter == 'resolved' ? 'btn-success' : 'glass'} rounded-pill px-3 py-1 small">Đã giải quyết</a>
                <a href="${pageContext.request.contextPath}/admin/support?status=closed" class="btn ${statusFilter == 'closed' ? 'btn-secondary' : 'glass'} rounded-pill px-3 py-1 small">Đã đóng</a>
            </div>

            <!-- Tickets Table -->
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr class="text-muted small" style="border-bottom:2px solid rgba(0,0,0,0.05);">
                                    <th class="ps-4 py-3">Mã</th>
                                    <th class="py-3">Khách hàng</th>
                                    <th class="py-3">Loại</th>
                                    <th class="py-3">Tiêu đề</th>
                                    <th class="py-3">Trạng thái</th>
                                    <th class="py-3">Ưu tiên</th>
                                    <th class="py-3">Ngày tạo</th>
                                    <th class="pe-4 py-3 text-end">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${tickets}">
                                <tr>
                                    <td class="ps-4"><span class="font-monospace fw-bold small text-primary">${t.ticketCode}</span></td>
                                    <td>
                                        <div class="fw-medium small">${t.userName}</div>
                                        <small class="text-muted">${t.userEmail}</small>
                                    </td>
                                    <td><span class="badge glass rounded-pill px-2 small">${t.categoryLabel}</span></td>
                                    <td class="small fw-medium" style="max-width:250px;">
                                        <div class="text-truncate">${t.subject}</div>
                                        <c:if test="${not empty t.orderCode}">
                                            <small class="text-muted"><i class="fas fa-link me-1"></i>${t.orderCode}</small>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${t.status == 'open'}">
                                                <span class="badge rounded-pill px-2" style="background:linear-gradient(135deg,#f59e0b,#f97316);color:white;">Mở</span>
                                            </c:when>
                                            <c:when test="${t.status == 'in_progress'}">
                                                <span class="badge rounded-pill px-2" style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;">Đang xử lý</span>
                                            </c:when>
                                            <c:when test="${t.status == 'resolved'}">
                                                <span class="badge rounded-pill px-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;">Đã giải quyết</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary rounded-pill px-2">Đã đóng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${t.priority == 'urgent'}"><span class="badge bg-danger rounded-pill px-2">Khẩn cấp</span></c:when>
                                            <c:when test="${t.priority == 'high'}"><span class="badge bg-warning text-dark rounded-pill px-2">Cao</span></c:when>
                                            <c:when test="${t.priority == 'normal'}"><span class="badge bg-info text-dark rounded-pill px-2">Bình thường</span></c:when>
                                            <c:otherwise><span class="badge bg-light text-dark rounded-pill px-2">Thấp</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="small text-muted"><fmt:formatDate value="${t.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    <td class="pe-4 text-end">
                                        <a href="${pageContext.request.contextPath}/admin/support/${t.ticketId}" class="btn btn-sm glass rounded-pill px-3">
                                            <i class="fas fa-eye me-1"></i>Xem
                                        </a>
                                    </td>
                                </tr>
                                </c:forEach>
                                <c:if test="${empty tickets}">
                                <tr>
                                    <td colspan="8" class="text-center text-muted py-5">
                                        <i class="fas fa-inbox fa-2x mb-2 opacity-25"></i>
                                        <p class="mb-0">Không có yêu cầu hỗ trợ nào</p>
                                    </td>
                                </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
