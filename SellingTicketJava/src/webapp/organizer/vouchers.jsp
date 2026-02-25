<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

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
                    <p class="text-muted mb-0">Tạo mã giảm giá để tăng doanh thu bán vé</p>
                </div>
                <button class="btn btn-gradient rounded-pill px-4 hover-glow" data-bs-toggle="modal" data-bs-target="#createVoucherModal">
                    <i class="fas fa-plus me-2"></i>Tạo Voucher
                </button>
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
                            <button class="btn btn-gradient rounded-pill px-4 hover-glow" data-bs-toggle="modal" data-bs-target="#createVoucherModal">
                                <i class="fas fa-plus me-2"></i>Tạo Voucher
                            </button>
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
                                        <div class="dash-icon-box" style="background: linear-gradient(135deg, ${v.discountType == 'percent' ? '#3b82f6, #6366f1' : '#10b981, #06b6d4'});">
                                            <i class="fas ${v.discountType == 'percent' ? 'fa-percent' : 'fa-tag'} fa-lg text-white"></i>
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
                                        Giảm ${v.discountType == 'percent' ? v.discountValue.intValue() += '%' : ''}
                                        <c:if test="${v.discountType != 'percent'}">
                                            <fmt:formatNumber value="${v.discountValue}" type="number" groupingUsed="true"/>đ
                                        </c:if>
                                        <c:if test="${not empty v.eventName}"> • ${v.eventName}</c:if>
                                    </p>

                                    <%-- Usage progress --%>
                                    <div class="mb-3">
                                        <c:set var="usagePercent" value="${v.maxUsage > 0 ? (v.usedCount * 100 / v.maxUsage) : 0}"/>
                                        <div class="d-flex justify-content-between small mb-1">
                                            <span>Đã dùng: ${v.usedCount}/${v.maxUsage}</span>
                                            <span><fmt:formatNumber value="${usagePercent}" maxFractionDigits="0"/>%</span>
                                        </div>
                                        <div class="progress" style="height: 6px; border-radius: 3px;">
                                            <div class="progress-bar" style="width: ${usagePercent}%; background: linear-gradient(90deg, #3b82f6, #6366f1); border-radius: 3px;"></div>
                                        </div>
                                    </div>

                                    <div class="text-muted small mb-3">
                                        <i class="far fa-calendar me-1"></i>
                                        <fmt:formatDate value="${v.startDate}" pattern="dd/MM"/> - <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy"/>
                                    </div>

                                    <c:if test="${v.usable}">
                                        <div class="d-flex gap-2">
                                            <a href="${pageContext.request.contextPath}/organizer/vouchers?action=edit&id=${v.voucherId}"
                                               class="btn btn-outline-primary btn-sm flex-grow-1 rounded-pill">
                                                <i class="fas fa-edit me-1"></i>Sửa
                                            </a>
                                            <form method="POST" action="${pageContext.request.contextPath}/organizer/vouchers" style="display:inline;">
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
        </div>
    </div>
</div>

<%-- Create Voucher Modal --%>
<div class="modal fade modal-glass" id="createVoucherModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form method="POST" action="${pageContext.request.contextPath}/organizer/vouchers">
                <input type="hidden" name="action" value="create"/>
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-tags text-primary me-2"></i>Tạo Voucher mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-medium">Mã voucher <span class="text-danger">*</span></label>
                        <input type="text" class="form-control glass-input rounded-3" name="code" placeholder="VD: GIAMGIA20" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Sự kiện áp dụng</label>
                        <select class="form-select glass-input rounded-3" name="eventId">
                            <option value="">Tất cả sự kiện</option>
                            <c:forEach var="e" items="${events}">
                                <option value="${e.eventId}">${e.title}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="row g-3">
                        <div class="col-6">
                            <label class="form-label fw-medium">Loại giảm giá</label>
                            <select class="form-select glass-input rounded-3" name="discountType">
                                <option value="percent">Phần trăm (%)</option>
                                <option value="fixed">Số tiền (VNĐ)</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-medium">Giá trị <span class="text-danger">*</span></label>
                            <input type="number" class="form-control glass-input rounded-3" name="discountValue" placeholder="20" required>
                        </div>
                    </div>
                    <div class="row g-3 mt-1">
                        <div class="col-6">
                            <label class="form-label fw-medium">Ngày bắt đầu <span class="text-danger">*</span></label>
                            <input type="date" class="form-control glass-input rounded-3" name="startDate" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-medium">Ngày kết thúc <span class="text-danger">*</span></label>
                            <input type="date" class="form-control glass-input rounded-3" name="endDate" required>
                        </div>
                    </div>
                    <div class="mb-3 mt-3">
                        <label class="form-label fw-medium">Số lượng <span class="text-danger">*</span></label>
                        <input type="number" class="form-control glass-input rounded-3" name="maxUsage" placeholder="100" required>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-gradient rounded-pill px-4 hover-glow">
                        <i class="fas fa-plus me-2"></i>Tạo voucher
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
