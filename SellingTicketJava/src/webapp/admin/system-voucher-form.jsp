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
                <jsp:param name="activePage" value="system-vouchers"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1">
                        <i class="fas fa-gift text-primary me-2"></i>
                        <c:choose>
                            <c:when test="${isEdit}">Chỉnh sửa Voucher Hệ thống</c:when>
                            <c:otherwise>Tạo Voucher Hệ thống</c:otherwise>
                        </c:choose>
                    </h2>
                    <p class="text-muted mb-0">Voucher hệ thống áp dụng toàn sàn — tiền giảm giá do hệ thống chi trả, không trừ doanh thu BTC.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/system-vouchers" class="btn glass rounded-pill px-4">
                    <i class="fas fa-arrow-left me-2"></i>Quay lại danh sách
                </a>
            </div>

            <!-- Info alert -->
            <div class="alert alert-info border-0 rounded-4 mb-4" style="background: rgba(59,130,246,0.08);">
                <div class="d-flex align-items-start gap-3">
                    <i class="fas fa-info-circle text-primary mt-1"></i>
                    <div>
                        <strong>Nguồn trừ tiền: Quỹ hệ thống (SYSTEM FUND)</strong>
                        <div class="mt-1 small text-muted">
                            Khi khách hàng sử dụng voucher này, tiền BTC nhận về = Giá vé gốc − Phí sàn. 
                            Khoản giảm giá voucher sẽ do quỹ hệ thống bù lỗ.
                        </div>
                    </div>
                </div>
            </div>

            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-4">
                    <form method="POST" action="${pageContext.request.contextPath}/admin/system-vouchers" class="row g-3">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                        <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}"/>
                        <c:if test="${isEdit}">
                            <input type="hidden" name="voucherId" value="${voucher.voucherId}"/>
                        </c:if>

                        <div class="col-md-6">
                            <label class="form-label fw-medium">Mã voucher</label>
                            <input type="text" class="form-control rounded-3" name="code" value="${isEdit ? voucher.code : ''}" required maxlength="50"
                                   placeholder="VD: SYSTEM-SALE-2025"/>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-medium">Phạm vi áp dụng</label>
                            <input type="text" class="form-control rounded-3" value="Toàn hệ thống (tất cả sự kiện)" disabled/>
                            <small class="text-muted">Voucher hệ thống tự động áp dụng cho mọi sự kiện trên sàn.</small>
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
                            <small class="text-muted">0 = không giới hạn</small>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-medium">Đơn tối thiểu (VNĐ)</label>
                            <input type="number" class="form-control rounded-3" name="minOrderAmount" min="0" step="0.01"
                                   value="${isEdit ? voucher.minOrderAmount : 0}"/>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-medium">Giảm tối đa (VNĐ)</label>
                            <input type="number" class="form-control rounded-3" name="maxDiscount" min="0" step="0.01"
                                   value="${isEdit ? voucher.maxDiscount : 0}"/>
                            <small class="text-muted">0 = không giới hạn</small>
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
                            <a href="${pageContext.request.contextPath}/admin/system-vouchers" class="btn btn-light rounded-pill px-4">Hủy</a>
                            <button type="submit" class="btn btn-gradient rounded-pill px-4">
                                <i class="fas ${isEdit ? 'fa-save' : 'fa-plus'} me-2"></i>
                                <c:choose>
                                    <c:when test="${isEdit}">Lưu thay đổi</c:when>
                                    <c:otherwise>Tạo voucher hệ thống</c:otherwise>
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
