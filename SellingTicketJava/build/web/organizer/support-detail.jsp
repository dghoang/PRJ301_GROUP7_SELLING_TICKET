<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<style>
.chat-bubble {
    max-width: 75%;
    padding: 12px 16px;
    border-radius: 16px;
    position: relative;
    word-wrap: break-word;
}
.chat-mine {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    border-bottom-right-radius: 4px;
    margin-left: auto;
}
.chat-theirs {
    background: rgba(0,0,0,0.04);
    border-bottom-left-radius: 4px;
}
@media (prefers-color-scheme: dark) {
    .chat-theirs { background: rgba(255,255,255,0.08); }
}
.chat-container {
    max-height: 450px;
    overflow-y: auto;
    scroll-behavior: smooth;
}
</style>

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="support"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <%-- Header --%>
            <div class="d-flex align-items-center gap-3 mb-4 animate-fadeInDown">
                <a href="${pageContext.request.contextPath}/organizer/support" class="btn btn-light rounded-circle" style="width: 40px; height: 40px;">
                    <i class="fas fa-arrow-left"></i>
                </a>
                <div>
                    <h4 class="fw-bold mb-0">${ticket.subject}</h4>
                    <div class="d-flex gap-2 mt-1">
                        <span class="badge bg-light text-dark border rounded-pill px-2" style="font-family: monospace; font-size: 0.75rem;">${ticket.ticketCode}</span>
                        <span class="badge rounded-pill px-2" style="background: rgba(245,158,11,0.15); color: #f59e0b;">
                            <i class="fas fa-bolt me-1"></i>Ưu tiên cao
                        </span>
                        <c:choose>
                            <c:when test="${ticket.status == 'open'}">
                                <span class="badge rounded-pill px-2" style="background: rgba(59,130,246,0.15); color: #3b82f6;">Mở</span>
                            </c:when>
                            <c:when test="${ticket.status == 'in_progress'}">
                                <span class="badge rounded-pill px-2" style="background: rgba(245,158,11,0.15); color: #f59e0b;">Đang xử lý</span>
                            </c:when>
                            <c:when test="${ticket.status == 'resolved'}">
                                <span class="badge rounded-pill px-2" style="background: rgba(16,185,129,0.15); color: #10b981;">Đã giải quyết</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary rounded-pill px-2">${ticket.statusLabel}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <%-- Chat Column --%>
                <div class="col-lg-8">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-comments text-primary me-2"></i>Cuộc trò chuyện</h6>

                            <%-- Initial description --%>
                            <div class="p-3 rounded-3 mb-3" style="background: rgba(59,130,246,0.05); border-left: 3px solid #3b82f6;">
                                <small class="text-muted d-block mb-1">Mô tả ban đầu</small>
                                <p class="mb-0">${ticket.description}</p>
                            </div>

                            <%-- Messages --%>
                            <div class="chat-container" id="chatContainer">
                                <c:choose>
                                    <c:when test="${empty ticket.messages}">
                                        <div class="text-center py-4 text-muted">
                                            <i class="fas fa-comments fa-2x mb-2 opacity-25 d-block"></i>
                                            <p class="mb-0">Chưa có tin nhắn nào. Hãy gửi tin nhắn để bắt đầu!</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="msg" items="${ticket.messages}">
                                            <div class="d-flex flex-column mb-3 ${msg.senderId == currentUserId ? 'align-items-end' : 'align-items-start'}">
                                                <div class="chat-bubble ${msg.senderId == currentUserId ? 'chat-mine' : 'chat-theirs'}">
                                                    <c:if test="${msg.senderId != currentUserId}">
                                                        <small class="fw-bold d-block mb-1" style="opacity: 0.8;">
                                                            <i class="fas fa-shield-alt me-1"></i>Admin
                                                        </small>
                                                    </c:if>
                                                    <p class="mb-0">${msg.content}</p>
                                                </div>
                                                <small class="text-muted mt-1 px-1" style="font-size: 0.7rem;">
                                                    <fmt:formatDate value="${msg.createdAt}" pattern="dd/MM HH:mm"/>
                                                </small>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <%-- Reply Form --%>
                            <c:if test="${ticket.status != 'closed'}">
                                <form method="POST" action="${pageContext.request.contextPath}/organizer/support/reply" class="mt-3">
                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                    <input type="hidden" name="ticketId" value="${ticket.ticketId}"/>
                                    <div class="d-flex gap-2">
                                        <input type="text" class="form-control glass-input rounded-pill" name="content" 
                                               placeholder="Nhập tin nhắn..." required autocomplete="off">
                                        <button type="submit" class="btn btn-gradient rounded-circle hover-glow" style="width: 42px; height: 42px; flex-shrink: 0;">
                                            <i class="fas fa-paper-plane"></i>
                                        </button>
                                    </div>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </div>

                <%-- Info Column --%>
                <div class="col-lg-4">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-info-circle text-primary me-2"></i>Thông tin ticket</h6>
                            <div class="mb-3">
                                <small class="text-muted d-block">Mã ticket</small>
                                <span class="fw-medium" style="font-family: monospace;">${ticket.ticketCode}</span>
                            </div>
                            <div class="mb-3">
                                <small class="text-muted d-block">Danh mục</small>
                                <span class="fw-medium">${ticket.categoryLabel}</span>
                            </div>
                            <div class="mb-3">
                                <small class="text-muted d-block">Ưu tiên</small>
                                <span class="badge rounded-pill px-2" style="background: rgba(239,68,68,0.15); color: #ef4444;">
                                    <i class="fas fa-arrow-up me-1"></i>Urgent
                                </span>
                            </div>
                            <div class="mb-3">
                                <small class="text-muted d-block">Chuyển đến</small>
                                <span class="fw-medium"><i class="fas fa-user-shield me-1 text-primary"></i>Admin hệ thống</span>
                            </div>
                            <div class="mb-0">
                                <small class="text-muted d-block">Ngày tạo</small>
                                <span class="fw-medium"><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Auto-scroll chat to bottom
const chat = document.getElementById('chatContainer');
if (chat) chat.scrollTop = chat.scrollHeight;
</script>

<jsp:include page="../footer.jsp" />
