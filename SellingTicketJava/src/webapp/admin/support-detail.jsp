<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="support"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <%-- Breadcrumb --%>
            <nav aria-label="breadcrumb" class="mb-4 animate-fadeInDown">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/support" class="text-decoration-none">Hỗ trợ</a></li>
                    <li class="breadcrumb-item active">${ticket.ticketCode}</li>
                </ol>
            </nav>

            <div class="row g-4">
                <%-- Main Content --%>
                <div class="col-lg-8">
                    <%-- Ticket Info --%>
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-fadeInUp">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div>
                                    <span class="font-monospace fw-bold text-primary">${ticket.ticketCode}</span>
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
                                    <c:if test="${ticket.priority == 'urgent'}">
                                        <span class="badge bg-danger rounded-pill px-2 py-1 ms-1"><i class="fas fa-bolt me-1"></i>Khẩn cấp</span>
                                    </c:if>
                                </div>
                                <span class="badge glass rounded-pill px-2">${ticket.categoryLabel}</span>
                            </div>
                            <h4 class="fw-bold mb-3">${ticket.subject}</h4>
                            <div class="glass rounded-3 p-3 mb-3" style="line-height:1.7;">${ticket.description}</div>
                            <div class="d-flex gap-4 text-muted small flex-wrap">
                                <span><i class="fas fa-user me-1"></i>${ticket.userName} (${ticket.userEmail})</span>
                                <span><i class="fas fa-calendar me-1"></i><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                <span><i class="fas fa-route me-1"></i>${ticket.routedToLabel}</span>
                            </div>
                            <c:if test="${not empty ticket.orderCode}">
                                <div class="mt-2"><span class="badge glass rounded-pill"><i class="fas fa-link me-1"></i>Đơn hàng: ${ticket.orderCode}</span></div>
                            </c:if>
                            <c:if test="${not empty ticket.eventTitle}">
                                <div class="mt-1"><span class="badge glass rounded-pill"><i class="fas fa-calendar-alt me-1"></i>${ticket.eventTitle}</span></div>
                            </c:if>
                        </div>
                    </div>

                    <%-- Messages --%>
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0"><i class="fas fa-comments text-primary me-2"></i>Trao đổi</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <c:forEach var="msg" items="${ticket.messages}">
                                <div class="d-flex gap-3 mb-4 ${msg.senderRole != 'customer' ? 'flex-row-reverse' : ''}">
                                    <div class="flex-shrink-0">
                                        <div class="rounded-circle d-flex align-items-center justify-content-center" style="width:36px;height:36px;
                                            background:${msg.senderRole == 'admin' ? 'linear-gradient(135deg,#ef4444,#f97316)' : msg.senderRole == 'support_agent' ? 'linear-gradient(135deg,#3b82f6,#6366f1)' : 'linear-gradient(135deg,#10b981,#06b6d4)'};">
                                            <i class="fas ${msg.senderRole == 'admin' ? 'fa-shield-alt' : msg.senderRole == 'support_agent' ? 'fa-headset' : 'fa-user'} text-white" style="font-size:0.75rem;"></i>
                                        </div>
                                    </div>
                                    <div style="max-width:75%;">
                                        <div class="d-flex align-items-center gap-2 mb-1 ${msg.senderRole != 'customer' ? 'justify-content-end' : ''}">
                                            <span class="fw-medium small">${msg.senderName}</span>
                                            <c:if test="${msg.senderRole == 'admin'}"><span class="badge bg-danger rounded-pill px-2" style="font-size:0.6rem;">Admin</span></c:if>
                                            <c:if test="${msg.senderRole == 'support_agent'}"><span class="badge rounded-pill px-2" style="font-size:0.6rem;background:#3b82f6;color:white;">Hỗ trợ viên</span></c:if>
                                            <c:if test="${msg.internal}"><span class="badge bg-dark rounded-pill px-2" style="font-size:0.6rem;">Nội bộ</span></c:if>
                                            <small class="text-muted"><fmt:formatDate value="${msg.createdAt}" pattern="dd/MM HH:mm"/></small>
                                        </div>
                                        <div class="glass rounded-3 p-3 small ${msg.internal ? 'border border-dark border-opacity-25' : ''}" style="line-height:1.6;">
                                            ${msg.content}
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty ticket.messages}">
                                <div class="text-center text-muted py-3">
                                    <i class="fas fa-comment-dots fa-2x mb-2 opacity-25"></i>
                                    <p class="mb-0 small">Chưa có phản hồi nào</p>
                                </div>
                            </c:if>

                            <%-- Reply Form --%>
                            <c:if test="${ticket.status != 'closed'}">
                                <form method="POST" action="${pageContext.request.contextPath}/admin/support/reply" class="mt-4 pt-3 border-top">
                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                                    <div class="mb-3">
                                        <textarea name="content" class="form-control glass-input rounded-3" rows="4" placeholder="Nhập phản hồi cho khách hàng..." required></textarea>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" name="internal" id="internalNote">
                                            <label class="form-check-label small text-muted" for="internalNote">
                                                <i class="fas fa-lock me-1"></i>Ghi chú nội bộ (ẩn với khách)
                                            </label>
                                        </div>
                                        <button type="submit" class="btn btn-gradient rounded-pill px-4 hover-glow">
                                            <i class="fas fa-reply me-2"></i>Gửi phản hồi
                                        </button>
                                    </div>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </div>

                <%-- Sidebar Actions --%>
                <div class="col-lg-4">
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll stagger-1">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-bolt text-warning me-2"></i>Thao tác nhanh</h6>

                            <c:if test="${empty ticket.assignedTo || ticket.assignedTo != sessionScope.user.userId}">
                                <form method="POST" action="${pageContext.request.contextPath}/admin/support/assign" class="mb-2">
                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                                    <button class="btn glass w-100 rounded-3 py-2 small text-start">
                                        <i class="fas fa-hand-paper text-primary me-2"></i>Nhận xử lý
                                    </button>
                                </form>
                            </c:if>

                            <form method="POST" action="${pageContext.request.contextPath}/admin/support/status" class="mb-2">
                                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                                <select name="status" class="form-select glass-input rounded-3 small" onchange="this.form.submit()">
                                    <option value="" disabled selected>Đổi trạng thái...</option>
                                    <option value="open" ${ticket.status == 'open' ? 'disabled' : ''}>Mở lại</option>
                                    <option value="in_progress" ${ticket.status == 'in_progress' ? 'disabled' : ''}>Đang xử lý</option>
                                    <option value="resolved" ${ticket.status == 'resolved' ? 'disabled' : ''}>Đã giải quyết</option>
                                    <option value="closed" ${ticket.status == 'closed' ? 'disabled' : ''}>Đóng</option>
                                </select>
                            </form>

                            <form method="POST" action="${pageContext.request.contextPath}/admin/support/priority">
                                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                                <select name="priority" class="form-select glass-input rounded-3 small" onchange="this.form.submit()">
                                    <option value="" disabled selected>Đổi ưu tiên...</option>
                                    <option value="low" ${ticket.priority == 'low' ? 'disabled' : ''}>Thấp</option>
                                    <option value="normal" ${ticket.priority == 'normal' ? 'disabled' : ''}>Bình thường</option>
                                    <option value="high" ${ticket.priority == 'high' ? 'disabled' : ''}>Cao</option>
                                    <option value="urgent" ${ticket.priority == 'urgent' ? 'disabled' : ''}>Khẩn cấp</option>
                                </select>
                            </form>
                        </div>
                    </div>

                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll stagger-2">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-info-circle text-primary me-2"></i>Chi tiết</h6>
                            <div class="d-flex justify-content-between py-2 border-bottom" style="border-color:rgba(0,0,0,0.05) !important;">
                                <span class="text-muted small">Ưu tiên</span>
                                <c:choose>
                                    <c:when test="${ticket.priority == 'urgent'}"><span class="badge bg-danger rounded-pill px-2">Khẩn cấp</span></c:when>
                                    <c:when test="${ticket.priority == 'high'}"><span class="badge bg-warning text-dark rounded-pill px-2">Cao</span></c:when>
                                    <c:when test="${ticket.priority == 'normal'}"><span class="badge bg-info text-dark rounded-pill px-2">Bình thường</span></c:when>
                                    <c:otherwise><span class="badge bg-light text-dark rounded-pill px-2">Thấp</span></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="d-flex justify-content-between py-2 border-bottom" style="border-color:rgba(0,0,0,0.05) !important;">
                                <span class="text-muted small">Chuyển đến</span>
                                <strong class="small">${ticket.routedToLabel}</strong>
                            </div>
                            <c:if test="${not empty ticket.assignedToName}">
                                <div class="d-flex justify-content-between py-2 border-bottom" style="border-color:rgba(0,0,0,0.05) !important;">
                                    <span class="text-muted small">Phụ trách</span>
                                    <strong class="small">${ticket.assignedToName}</strong>
                                </div>
                            </c:if>
                            <c:if test="${not empty ticket.resolvedAt}">
                                <div class="d-flex justify-content-between py-2 border-bottom" style="border-color:rgba(0,0,0,0.05) !important;">
                                    <span class="text-muted small">Giải quyết</span>
                                    <strong class="small"><fmt:formatDate value="${ticket.resolvedAt}" pattern="dd/MM/yyyy"/></strong>
                                </div>
                            </c:if>
                            <div class="d-flex justify-content-between py-2">
                                <span class="text-muted small">Cập nhật</span>
                                <strong class="small"><fmt:formatDate value="${ticket.updatedAt}" pattern="dd/MM HH:mm"/></strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
