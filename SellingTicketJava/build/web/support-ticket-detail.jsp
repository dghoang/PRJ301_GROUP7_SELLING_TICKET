<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<div class="container py-5" style="max-width: 850px;">
    <nav aria-label="breadcrumb" class="mb-4 animate-fadeInDown">
        <ol class="breadcrumb mb-0">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/support/my-tickets" class="text-decoration-none">Hỗ trợ</a></li>
            <li class="breadcrumb-item active">${ticket.ticketCode}</li>
        </ol>
    </nav>

    <div class="row g-4">
        <%-- Ticket Info --%>
        <div class="col-lg-8">
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-fadeInUp">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-start mb-3">
                        <div>
                            <span class="font-monospace small fw-bold text-primary">${ticket.ticketCode}</span>
                            <c:choose>
                                <c:when test="${ticket.status == 'open'}">
                                    <span class="badge rounded-pill px-3 py-1 ms-2" style="background:linear-gradient(135deg,#f59e0b,#f97316);color:white;">Mở</span>
                                </c:when>
                                <c:when test="${ticket.status == 'in_progress'}">
                                    <span class="badge rounded-pill px-3 py-1 ms-2" style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;">Đang xử lý</span>
                                </c:when>
                                <c:when test="${ticket.status == 'resolved'}">
                                    <span class="badge rounded-pill px-3 py-1 ms-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;">Đã giải quyết</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary rounded-pill px-3 py-1 ms-2">Đã đóng</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <span class="badge glass rounded-pill px-2">${ticket.categoryLabel}</span>
                    </div>
                    <h4 class="fw-bold mb-3">${ticket.subject}</h4>
                    <div class="glass rounded-3 p-3 mb-3" style="line-height:1.7;">
                        ${ticket.description}
                    </div>
                    <div class="d-flex gap-4 text-muted small">
                        <span><i class="fas fa-calendar me-1"></i><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                        <c:if test="${not empty ticket.orderCode}">
                            <span><i class="fas fa-shopping-bag me-1"></i>${ticket.orderCode}</span>
                        </c:if>
                        <c:if test="${not empty ticket.eventTitle}">
                            <span><i class="fas fa-calendar-alt me-1"></i>${ticket.eventTitle}</span>
                        </c:if>
                    </div>
                </div>
            </div>

            <%-- Messages Thread --%>
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-header bg-transparent border-0 pt-4 px-4">
                    <h5 class="fw-bold mb-0"><i class="fas fa-comments text-primary me-2"></i>Trao đổi</h5>
                </div>
                <div class="card-body px-4 pb-4">
                    <c:choose>
                        <c:when test="${empty ticket.messages}">
                            <div class="text-center text-muted py-4">
                                <i class="fas fa-comment-dots fa-2x mb-2 opacity-25"></i>
                                <p class="mb-0 small">Chưa có phản hồi nào. Chúng tôi sẽ trả lời sớm nhất!</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="msg" items="${ticket.messages}">
                                <div class="d-flex gap-3 mb-4 ${msg.senderId == sessionScope.user.userId ? 'flex-row-reverse' : ''}">
                                    <div class="flex-shrink-0">
                                        <div class="rounded-circle d-flex align-items-center justify-content-center" style="width:36px;height:36px;
                                            background:${msg.senderRole == 'admin' ? 'linear-gradient(135deg,#ef4444,#f97316)' : msg.senderRole == 'support_agent' ? 'linear-gradient(135deg,#3b82f6,#6366f1)' : 'linear-gradient(135deg,#10b981,#06b6d4)'};">
                                            <i class="fas ${msg.senderRole == 'admin' ? 'fa-shield-alt' : msg.senderRole == 'support_agent' ? 'fa-headset' : 'fa-user'} text-white" style="font-size:0.75rem;"></i>
                                        </div>
                                    </div>
                                    <div style="max-width:75%;">
                                        <div class="d-flex align-items-center gap-2 mb-1 ${msg.senderId == sessionScope.user.userId ? 'justify-content-end' : ''}">
                                            <span class="fw-medium small">${msg.senderName}</span>
                                            <c:if test="${msg.senderRole == 'admin'}">
                                                <span class="badge bg-danger rounded-pill px-2" style="font-size:0.6rem;">Admin</span>
                                            </c:if>
                                            <c:if test="${msg.senderRole == 'support_agent'}">
                                                <span class="badge rounded-pill px-2" style="font-size:0.6rem;background:#3b82f6;color:white;">Hỗ trợ</span>
                                            </c:if>
                                            <small class="text-muted"><fmt:formatDate value="${msg.createdAt}" pattern="dd/MM HH:mm"/></small>
                                        </div>
                                        <div class="glass rounded-3 p-3 small" style="line-height:1.6;
                                            ${msg.senderId == sessionScope.user.userId ? 'background:rgba(59,130,246,0.06);' : ''}">
                                            ${msg.content}
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>

                    <%-- Reply Form (only if not closed) --%>
                    <c:if test="${ticket.status != 'closed'}">
                        <form method="POST" action="${pageContext.request.contextPath}/support/reply" class="mt-4 pt-3 border-top">
                            <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <div class="mb-3">
                                <textarea name="content" class="form-control glass rounded-3" rows="3" placeholder="Nhập phản hồi..." required></textarea>
                            </div>
                            <button type="submit" class="btn rounded-pill px-4" style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;">
                                <i class="fas fa-reply me-2"></i>Gửi phản hồi
                            </button>
                        </form>
                    </c:if>
                </div>
            </div>
        </div>

        <%-- Sidebar --%>
        <div class="col-lg-4">
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll stagger-1">
                <div class="card-body p-4">
                    <h6 class="fw-bold mb-3"><i class="fas fa-info-circle text-primary me-2"></i>Thông tin</h6>
                    <div class="d-flex justify-content-between py-2 border-bottom" style="border-color:rgba(0,0,0,0.05) !important;">
                        <span class="text-muted small">Trạng thái</span>
                        <strong class="small">${ticket.statusLabel}</strong>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom" style="border-color:rgba(0,0,0,0.05) !important;">
                        <span class="text-muted small">Ưu tiên</span>
                        <strong class="small">
                            <c:choose>
                                <c:when test="${ticket.priority == 'urgent'}"><span class="text-danger"><i class="fas fa-circle fa-xs me-1"></i>Khẩn cấp</span></c:when>
                                <c:when test="${ticket.priority == 'high'}"><span class="text-warning"><i class="fas fa-circle fa-xs me-1"></i>Cao</span></c:when>
                                <c:when test="${ticket.priority == 'normal'}"><i class="fas fa-circle fa-xs text-success me-1"></i>Bình thường</c:when>
                                <c:otherwise>⚪ Thấp</c:otherwise>
                            </c:choose>
                        </strong>
                    </div>
                    <c:if test="${not empty ticket.assignedToName}">
                        <div class="d-flex justify-content-between py-2 border-bottom" style="border-color:rgba(0,0,0,0.05) !important;">
                            <span class="text-muted small">Phụ trách</span>
                            <strong class="small">${ticket.assignedToName}</strong>
                        </div>
                    </c:if>
                    <div class="d-flex justify-content-between py-2">
                        <span class="text-muted small">Ngày tạo</span>
                        <strong class="small"><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy"/></strong>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
