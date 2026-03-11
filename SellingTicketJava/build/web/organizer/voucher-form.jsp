<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<c:set var="isEdit" value="${not empty voucher}"/>
<fmt:formatDate value="${voucher.startDate}" pattern="yyyy-MM-dd" var="startDateVal"/>
<fmt:formatDate value="${voucher.endDate}" pattern="yyyy-MM-dd" var="endDateVal"/>

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="vouchers"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1">
                        <i class="fas fa-tags text-primary me-2"></i>
                        <c:choose>
                            <c:when test="${isEdit}">Chỉnh sửa Voucher</c:when>
                            <c:otherwise>Tạo Voucher mới</c:otherwise>
                        </c:choose>
                    </h2>
                    <p class="text-muted mb-0">Thiết lập mã giảm giá cho sự kiện của bạn</p>
                </div>
                <a href="${pageContext.request.contextPath}/organizer/vouchers" class="btn glass rounded-pill px-4">
                    <i class="fas fa-arrow-left me-2"></i>Quay lại danh sách
                </a>
            </div>

            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-4">
                    <form method="POST" action="${pageContext.request.contextPath}/organizer/vouchers" class="row g-3">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                        <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}"/>
                        <c:if test="${isEdit}">
                            <input type="hidden" name="voucherId" value="${voucher.voucherId}"/>
                        </c:if>

                        <div class="col-md-6">
                            <label class="form-label fw-medium">Mã voucher</label>
                            <input type="text" class="form-control rounded-3" name="code" value="${isEdit ? voucher.code : ''}" required maxlength="50"/>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-medium">Sự kiện áp dụng</label>
                            <c:choose>
                                <c:when test="${isEdit}">
                                    <input type="hidden" name="eventId" value="${voucher.eventId}"/>
                                    <select class="form-select rounded-3" disabled>
                                        <c:forEach var="e" items="${events}">
                                            <option value="${e.eventId}" ${e.eventId == voucher.eventId ? 'selected' : ''}>${e.title}</option>
                                        </c:forEach>
                                    </select>
                                    <small class="text-muted">Sự kiện gốc được giữ cố định khi cập nhật.</small>
                                </c:when>
                                <c:otherwise>
                                    <select class="form-select rounded-3" name="eventId" required>
                                        <option value="">-- Chọn sự kiện --</option>
                                        <c:forEach var="e" items="${events}">
                                            <option value="${e.eventId}">${e.title}</option>
                                        </c:forEach>
                                    </select>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-medium">Loại giảm giá</label>
                            <select class="form-select rounded-3" name="discountType" required>
                                <option value="percentage" ${(isEdit && voucher.discountType == 'percentage') ? 'selected' : ''}>Phần trăm (%)</option>
                                <option value="fixed" ${(isEdit && voucher.discountType == 'fixed') ? 'selected' : ''}>Số tiền cố định (VNĐ)</option>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-medium">Giá trị giảm</label>
                            <input type="number" class="form-control rounded-3" name="discountValue" min="0" step="0.01"
                                   value="${isEdit ? voucher.discountValue : ''}" required/>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-medium">Số lượt dùng tối đa</label>
                            <input type="number" class="form-control rounded-3" name="usageLimit" min="0" step="1"
                                   value="${isEdit ? voucher.usageLimit : ''}" required/>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-medium">Đơn tối thiểu</label>
                            <input type="number" class="form-control rounded-3" name="minOrderAmount" min="0" step="0.01"
                                   value="${isEdit ? voucher.minOrderAmount : 0}"/>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-medium">Giảm tối đa</label>
                            <input type="number" class="form-control rounded-3" name="maxDiscount" min="0" step="0.01"
                                   value="${isEdit ? voucher.maxDiscount : 0}"/>
                        </div>

                        <div class="col-md-4 d-flex align-items-end">
                            <c:if test="${isEdit}">
                                <div class="form-check form-switch mb-2">
                                    <input class="form-check-input" type="checkbox" name="isActive" id="isActive" ${voucher.active ? 'checked' : ''}/>
                                    <label class="form-check-label" for="isActive">Đang hoạt động</label>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-medium">Ngày bắt đầu</label>
                            <input type="date" class="form-control rounded-3" name="startDate" value="${isEdit ? startDateVal : ''}" required/>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-medium">Ngày kết thúc</label>
                            <input type="date" class="form-control rounded-3" name="endDate" value="${isEdit ? endDateVal : ''}" required/>
                        </div>

                        <div class="col-12 pt-2 d-flex gap-2 justify-content-end">
                            <a href="${pageContext.request.contextPath}/organizer/vouchers" class="btn btn-light rounded-pill px-4">Hủy</a>
                            <button type="submit" class="btn btn-gradient rounded-pill px-4">
                                <i class="fas ${isEdit ? 'fa-save' : 'fa-plus'} me-2"></i>
                                <c:choose>
                                    <c:when test="${isEdit}">Lưu thay đổi</c:when>
                                    <c:otherwise>Tạo voucher</c:otherwise>
                                </c:choose>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
