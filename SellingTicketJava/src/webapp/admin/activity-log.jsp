<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="activity-log"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h3 class="fw-bold mb-1"><i class="fas fa-stream text-primary me-2"></i>Nhật ký hoạt động</h3>
                    <p class="text-muted mb-0">Theo dõi mọi thao tác trong hệ thống</p>
                </div>
                <span class="badge glass rounded-pill px-3 py-2">
                    <i class="fas fa-database me-1"></i>${totalCount} bản ghi
                </span>
            </div>

            <!-- Filters -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-fadeInDown">
                <div class="card-body p-3">
                    <form method="GET" action="${pageContext.request.contextPath}/admin/activity-log" class="row g-2 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label small fw-medium">Loại hành động</label>
                            <select name="action" class="form-select form-select-sm rounded-pill">
                                <option value="">Tất cả</option>
                                <c:forEach var="act" items="${actionTypes}">
                                    <option value="${act}" ${filterAction == act ? 'selected' : ''}>${act}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-medium">Đối tượng</label>
                            <select name="entity" class="form-select form-select-sm rounded-pill">
                                <option value="">Tất cả</option>
                                <option value="event" ${filterEntity == 'event' ? 'selected' : ''}>Event</option>
                                <option value="order" ${filterEntity == 'order' ? 'selected' : ''}>Order</option>
                                <option value="user" ${filterEntity == 'user' ? 'selected' : ''}>User</option>
                                <option value="category" ${filterEntity == 'category' ? 'selected' : ''}>Category</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-medium">User ID</label>
                            <input type="text" name="userId" value="${filterUserId}" class="form-control form-control-sm rounded-pill" placeholder="Nhập User ID...">
                        </div>
                        <div class="col-md-3 d-flex gap-2">
                            <button type="submit" class="btn btn-sm btn-primary rounded-pill flex-grow-1">
                                <i class="fas fa-search me-1"></i>Lọc
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/activity-log" class="btn btn-sm btn-outline-secondary rounded-pill">
                                <i class="fas fa-undo"></i>
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Activity Log Table -->
            <div class="card glass-strong border-0 rounded-4">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th style="width:50px">#</th>
                                    <th>Hành động</th>
                                    <th>Chi tiết</th>
                                    <th>Đối tượng</th>
                                    <th>User ID</th>
                                    <th>IP</th>
                                    <th>Thời gian</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="log" items="${logs}" varStatus="loop">
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td class="text-muted small">${(currentPage - 1) * pageSize + loop.index + 1}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${log.action.contains('approve')}"><c:set var="bClass" value="bg-success"/></c:when>
                                            <c:when test="${log.action.contains('reject')}"><c:set var="bClass" value="bg-danger"/></c:when>
                                            <c:when test="${log.action.contains('delete')}"><c:set var="bClass" value="bg-danger"/></c:when>
                                            <c:when test="${log.action.contains('create')}"><c:set var="bClass" value="bg-primary"/></c:when>
                                            <c:when test="${log.action.contains('update')}"><c:set var="bClass" value="bg-warning text-dark"/></c:when>
                                            <c:otherwise><c:set var="bClass" value="bg-secondary"/></c:otherwise>
                                        </c:choose>
                                        <span class="badge rounded-pill px-2 py-1 ${bClass}" style="font-size: 0.75rem;">
                                            ${log.action}
                                        </span>
                                    </td>
                                    <td class="small" style="max-width: 300px;">
                                        <span class="text-truncate d-inline-block" style="max-width: 300px;" title="${log.details}">
                                            ${log.details}
                                        </span>
                                    </td>
                                    <td>
                                        <c:if test="${not empty log.entityType}">
                                            <span class="badge bg-light text-dark">${log.entityType}#${log.entityId}</span>
                                        </c:if>
                                    </td>
                                    <td class="text-muted small">${log.userId}</td>
                                    <td class="text-muted small" style="font-family:monospace;font-size:0.7rem;">${log.ipAddress}</td>
                                    <td class="text-muted small text-nowrap">
                                        <fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                    </td>
                                </tr>
                                </c:forEach>
                                <c:if test="${empty logs}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="fas fa-history fa-3x mb-3 opacity-25"></i>
                                        <p class="mb-0">Chưa có hoạt động nào được ghi nhận</p>
                                    </td>
                                </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <%-- Pagination --%>
                <tags:pagination currentPage="${currentPage}" totalPages="${totalPages}" pageSize="${pageSize}" totalRecords="${totalRecords}" formId="" />
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
