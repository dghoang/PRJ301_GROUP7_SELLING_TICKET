<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<div class="container py-5" style="max-width: 900px;">
    <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
        <div>
            <h2 class="fw-bold mb-1"><i class="fas fa-headset text-primary me-2"></i>Yêu cầu hỗ trợ</h2>
            <p class="text-muted mb-0">Theo dõi trạng thái các yêu cầu của bạn</p>
        </div>
        <a href="${pageContext.request.contextPath}/support/new" class="btn rounded-pill px-4 py-2 fw-medium" style="background:linear-gradient(135deg,#f59e0b,#f97316);color:white;">
            <i class="fas fa-plus me-2"></i>Tạo yêu cầu mới
        </a>
    </div>

    <c:if test="${param.success == 'created'}">
        <div class="alert glass-strong rounded-4 border-0 mb-4 animate-fadeInDown" style="background:rgba(16,185,129,0.1);border-left:4px solid #10b981 !important;">
            <i class="fas fa-check-circle text-success me-2"></i>Yêu cầu hỗ trợ đã được gửi thành công! Chúng tôi sẽ phản hồi sớm nhất.
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty tickets}">
            <div class="glass-strong p-5 rounded-4 text-center animate-fadeInUp">
                <i class="fas fa-inbox fa-3x mb-3 opacity-25"></i>
                <h5 class="fw-bold mb-2">Chưa có yêu cầu nào</h5>
                <p class="text-muted mb-4">Bạn chưa gửi yêu cầu hỗ trợ nào. Nếu gặp vấn đề, hãy tạo yêu cầu mới.</p>
                <a href="${pageContext.request.contextPath}/support/new" class="btn rounded-pill px-4" style="background:linear-gradient(135deg,#f59e0b,#f97316);color:white;">
                    <i class="fas fa-plus me-2"></i>Tạo yêu cầu
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row g-3">
                <c:forEach var="t" items="${tickets}">
                    <div class="col-12 animate-on-scroll">
                        <a href="${pageContext.request.contextPath}/support/ticket/${t.ticketId}" class="text-decoration-none">
                            <div class="card glass-strong border-0 rounded-4 hover-lift" style="transition: all 0.3s;">
                                <div class="card-body p-4">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <div>
                                            <span class="font-monospace small fw-bold text-primary">${t.ticketCode}</span>
                                            <span class="badge glass rounded-pill ms-2 px-2 small">${t.categoryLabel}</span>
                                        </div>
                                        <c:choose>
                                            <c:when test="${t.status == 'open'}">
                                                <span class="badge rounded-pill px-3 py-1" style="background:linear-gradient(135deg,#f59e0b,#f97316);color:white;">
                                                    <i class="fas fa-circle me-1" style="font-size:0.5rem;"></i>Mở
                                                </span>
                                            </c:when>
                                            <c:when test="${t.status == 'in_progress'}">
                                                <span class="badge rounded-pill px-3 py-1" style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;">
                                                    <i class="fas fa-spinner me-1" style="font-size:0.5rem;"></i>Đang xử lý
                                                </span>
                                            </c:when>
                                            <c:when test="${t.status == 'resolved'}">
                                                <span class="badge rounded-pill px-3 py-1" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;">
                                                    <i class="fas fa-check me-1" style="font-size:0.5rem;"></i>Đã giải quyết
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary rounded-pill px-3 py-1">Đã đóng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <h6 class="fw-bold text-dark mb-1">${t.subject}</h6>
                                    <div class="d-flex gap-3 text-muted small">
                                        <span><i class="fas fa-calendar me-1"></i><fmt:formatDate value="${t.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                        <c:if test="${not empty t.orderCode}">
                                            <span><i class="fas fa-shopping-bag me-1"></i>${t.orderCode}</span>
                                        </c:if>
                                        <c:if test="${not empty t.eventTitle}">
                                            <span><i class="fas fa-calendar-alt me-1"></i>${t.eventTitle}</span>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="footer.jsp" />
