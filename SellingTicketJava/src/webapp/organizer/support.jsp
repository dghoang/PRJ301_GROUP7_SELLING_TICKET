<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="support"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-headset text-primary me-2"></i>Hỗ trợ</h2>
                    <p class="text-muted mb-0">Gửi yêu cầu hỗ trợ trực tiếp đến Admin hệ thống</p>
                </div>
                <button class="btn btn-gradient rounded-pill px-3 hover-glow" data-bs-toggle="modal" data-bs-target="#newTicketModal">
                    <i class="fas fa-plus me-2"></i>Tạo yêu cầu
                </button>
            </div>

            <%-- Toast --%>
            <c:if test="${not empty sessionScope.toastMessage}">
                <c:set var="toastBg" value="rgba(239,68,68,0.1)"/>
                <c:set var="toastBorder" value="#ef4444"/>
                <c:set var="toastIcon" value="exclamation-circle text-danger"/>
                <c:if test="${sessionScope.toastType == 'success'}">
                    <c:set var="toastBg" value="rgba(16,185,129,0.1)"/>
                    <c:set var="toastBorder" value="#10b981"/>
                    <c:set var="toastIcon" value="check-circle text-success"/>
                </c:if>
                <c:set var="alertStyle" value="background: ${toastBg}; border-left: 4px solid ${toastBorder} !important;"/>
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="${alertStyle}">
                    <i class="fas fa-${sessionScope.toastType == 'success' ? 'check-circle text-success' : 'exclamation-circle text-danger'} me-2"></i>
                    ${sessionScope.toastMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="toastMessage" scope="session"/>
                <c:remove var="toastType" scope="session"/>
            </c:if>

            <%-- Priority Info Banner --%>
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll" style="border-left: 4px solid #f59e0b !important;">
                <div class="card-body p-3 d-flex align-items-center gap-3">
                    <div class="d-inline-flex align-items-center justify-content-center rounded-3"
                         style="width: 40px; height: 40px; background: rgba(245,158,11,0.15); flex-shrink: 0;">
                        <i class="fas fa-star" style="color: #f59e0b;"></i>
                    </div>
                    <div>
                        <p class="fw-medium mb-0">Ưu tiên cao</p>
                        <p class="text-muted small mb-0">Yêu cầu từ ban tổ chức sẽ được ưu tiên xử lý bởi Admin</p>
                    </div>
                </div>
            </div>

            <%-- Tickets List --%>
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty tickets}">
                            <div class="text-center py-5">
                                <i class="fas fa-ticket-alt fa-3x mb-3 opacity-25"></i>
                                <h5 class="fw-bold text-muted">Chưa có yêu cầu nào</h5>
                                <p class="text-muted">Nhấn "Tạo yêu cầu" để gửi hỗ trợ đến Admin</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table table-glass align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th>Mã ticket</th>
                                            <th>Tiêu đề</th>
                                            <th>Danh mục</th>
                                            <th>Trạng thái</th>
                                            <th>Ngày tạo</th>
                                            <th class="text-center">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="t" items="${tickets}">
                                            <tr>
                                                <td>
                                                    <span class="fw-bold text-primary" style="font-family: monospace; font-size: 0.85rem;">
                                                        ${t.ticketCode}
                                                    </span>
                                                </td>
                                                <td class="fw-medium">${t.subject}</td>
                                                <td>
                                                    <span class="badge bg-light text-dark border rounded-pill px-2">${t.categoryLabel}</span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${t.status == 'open'}">
                                                            <span class="badge rounded-pill px-3 py-2" style="background: rgba(59,130,246,0.15); color: #3b82f6;">
                                                                <i class="fas fa-circle fa-xs me-1"></i>Mở
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${t.status == 'in_progress'}">
                                                            <span class="badge rounded-pill px-3 py-2" style="background: rgba(245,158,11,0.15); color: #f59e0b;">
                                                                <i class="fas fa-spinner fa-spin fa-xs me-1"></i>Đang xử lý
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${t.status == 'resolved'}">
                                                            <span class="badge rounded-pill px-3 py-2" style="background: rgba(16,185,129,0.15); color: #10b981;">
                                                                <i class="fas fa-check-circle fa-xs me-1"></i>Đã giải quyết
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary rounded-pill px-3 py-2">${t.statusLabel}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-muted small">
                                                    <fmt:formatDate value="${t.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/organizer/support/ticket/${t.ticketId}" 
                                                       class="btn btn-sm btn-outline-primary rounded-pill px-3">
                                                        <i class="fas fa-comments me-1"></i>Xem
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <tags:pagination currentPage="${currentPage}" totalPages="${totalPages}" pageSize="${pageSize}" totalRecords="${totalRecords}"/>
        </div>
    </div>
</div>

<%-- New Ticket Modal --%>
<div class="modal fade" id="newTicketModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="fas fa-headset text-primary me-2"></i>Gửi yêu cầu hỗ trợ</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/organizer/support/create">
                <div class="modal-body">
                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>

                    <div class="mb-3">
                        <label class="form-label fw-medium">Danh mục</label>
                        <select class="form-select glass-input rounded-3" name="category" required>
                            <option value="account_issue">Vấn đề tài khoản</option>
                            <option value="technical">Lỗi kỹ thuật</option>
                            <option value="payment_error">Vấn đề thanh toán</option>
                            <option value="event_issue">Vấn đề sự kiện</option>
                            <option value="feedback">Góp ý / Đề xuất</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-medium">Tiêu đề</label>
                        <input type="text" class="form-control glass-input rounded-3" name="subject" 
                               required maxlength="200" placeholder="Mô tả ngắn gọn vấn đề">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-medium">Mô tả chi tiết</label>
                        <textarea class="form-control glass-input rounded-3" name="description" 
                                  rows="4" required placeholder="Mô tả chi tiết vấn đề bạn gặp phải..."></textarea>
                    </div>

                    <div class="d-flex align-items-center gap-2 p-2 rounded-3" style="background: rgba(245,158,11,0.1);">
                        <i class="fas fa-bolt" style="color: #f59e0b;"></i>
                        <small class="text-muted">Yêu cầu từ BTC sẽ được ưu tiên xử lý cao nhất</small>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light rounded-pill px-3" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-gradient rounded-pill px-4 hover-glow">
                        <i class="fas fa-paper-plane me-2"></i>Gửi yêu cầu
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
