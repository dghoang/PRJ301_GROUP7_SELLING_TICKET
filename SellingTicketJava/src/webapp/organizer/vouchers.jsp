<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <%-- Sidebar --%>
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="vouchers"/>
            </jsp:include>
        </div>

        <%-- Main Content --%>
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1">Quản lý Vouchers</h2>
                    <p class="text-muted mb-0">
                        <c:choose>
                            <c:when test="${isSystemAdmin}">Quản lý mã giảm giá sự kiện và mã toàn hệ thống</c:when>
                            <c:otherwise>Tạo mã giảm giá theo từng sự kiện bạn phụ trách</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/organizer/vouchers/create" class="btn btn-gradient rounded-pill px-4 hover-glow">
                    <i class="fas fa-plus me-2"></i>
                    <c:choose>
                        <c:when test="${isSystemAdmin}">Tạo mã mới</c:when>
                        <c:otherwise>Tạo Voucher</c:otherwise>
                    </c:choose>
                </a>
            </div>

            <%-- Vouchers Grid --%>
            <c:choose>
                <c:when test="${empty vouchers}">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                        <div class="card-body p-5 text-center">
                            <div class="dash-icon-box mx-auto mb-3" style="width: 80px; height: 80px; background: linear-gradient(135deg, #f59e0b, #f97316); border-radius: 20px;">
                                <i class="fas fa-tags fa-2x text-white"></i>
                            </div>
                            <h4 class="fw-bold">Chưa có voucher nào</h4>
                            <p class="text-muted mb-4">Tạo voucher đầu tiên để khuyến mãi cho sự kiện!</p>
                            <a href="${pageContext.request.contextPath}/organizer/vouchers/create" class="btn btn-gradient rounded-pill px-4 hover-glow">
                                <i class="fas fa-plus me-2"></i>Tạo Voucher
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="row g-4">
                        <c:forEach var="v" items="${vouchers}" varStatus="loop">
                        <div class="col-md-6 col-lg-4 animate-on-scroll stagger-${loop.index % 3}">
                            <div class="card glass-strong border-0 rounded-4 hover-lift h-100" style="transition: all 0.3s;">
                                <div class="card-body p-4">
                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                        <c:set var="iconBg" value="linear-gradient(135deg, #10b981, #06b6d4)"/>
                                        <c:if test="${v.discountType == 'percentage'}"><c:set var="iconBg" value="linear-gradient(135deg, #3b82f6, #6366f1)"/></c:if>
                                        <c:set var="iconStyle" value="background: ${iconBg};"/>
                                        <div class="dash-icon-box" style="${iconStyle}">
                                            <i class="fas ${v.discountType == 'percentage' ? 'fa-percent' : 'fa-tag'} fa-lg text-white"></i>
                                        </div>
                                        <c:choose>
                                            <c:when test="${v.usable}">
                                                <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">Đang hoạt động</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary rounded-pill px-3 py-2">Hết hạn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <h5 class="fw-bold mb-1">${v.code}</h5>
                                    <p class="text-muted small mb-3">
                                        Giảm ${v.discountType == 'percentage' ? v.discountValue.intValue().toString().concat('%') : ''}
                                        <c:if test="${v.discountType != 'percentage'}">
                                            <fmt:formatNumber value="${v.discountValue}" type="number" groupingUsed="true"/>đ
                                        </c:if>
                                        <c:choose>
                                            <c:when test="${v.eventId <= 0}">
                                                • <span class="badge rounded-pill px-2 py-1" style="background:linear-gradient(135deg,#9333ea,#6366f1);color:white;font-size:10px;">TOÀN HỆ THỐNG</span>
                                            </c:when>
                                            <c:when test="${not empty v.eventName}">
                                                • <span class="text-primary">${v.eventName}</span>
                                            </c:when>
                                            <c:otherwise>
                                                • <span class="text-muted">Sự kiện không xác định</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </p>

                                    <%-- Usage progress --%>
                                    <div class="mb-3">
                                        <c:set var="usagePercent" value="${v.usageLimit > 0 ? (v.usedCount * 100 / v.usageLimit) : 0}"/>
                                        <div class="d-flex justify-content-between small mb-1">
                                            <span>Đã dùng: ${v.usedCount}/${v.usageLimit}</span>
                                            <span><fmt:formatNumber value="${usagePercent}" maxFractionDigits="0"/>%</span>
                                        </div>
                                        <div class="progress" style="height: 6px; border-radius: 3px;">
                                            <c:set var="progressStyle" value="width: ${usagePercent}%; background: linear-gradient(90deg, #3b82f6, #6366f1); border-radius: 3px;"/>
                                            <div class="progress-bar" style="${progressStyle}"></div>
                                        </div>
                                    </div>

                                    <div class="text-muted small mb-3">
                                        <i class="far fa-calendar me-1"></i>
                                        <fmt:formatDate value="${v.startDate}" pattern="dd/MM"/> - <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy"/>
                                    </div>

                                    <c:if test="${v.usable}">
                                        <div class="d-flex gap-2">
                                            <a href="${pageContext.request.contextPath}/organizer/vouchers/edit/${v.voucherId}"
                                               class="btn btn-outline-primary btn-sm flex-grow-1 rounded-pill">
                                                <i class="fas fa-edit me-1"></i>Sửa
                                            </a>
                                            <form method="POST" action="${pageContext.request.contextPath}/organizer/vouchers" style="display:inline;">
                                                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                                <input type="hidden" name="action" value="delete"/>
                                                <input type="hidden" name="voucherId" value="${v.voucherId}"/>
                                                <button type="submit" class="btn btn-outline-danger btn-sm rounded-pill"
                                                        onclick="return confirm('Xóa voucher ${v.code}?')">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </c:if>
                                    <c:if test="${!v.usable}">
                                        <button class="btn btn-outline-secondary btn-sm w-100 rounded-pill" disabled>Đã hết hạn</button>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>

            <tags:pagination currentPage="${currentPage}" totalPages="${totalPages}" pageSize="${pageSize}" totalRecords="${totalRecords}"/>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
