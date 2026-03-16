<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="team"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">Điều hành viên</h2>
                    <p class="text-muted mb-0">Quản lý thành viên trong ban tổ chức</p>
                </div>
                <c:if test="${not empty selectedEventId}">
                    <button class="btn btn-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addMemberModal">
                        <i class="fas fa-user-plus me-2"></i>Thêm thành viên
                    </button>
                </c:if>
            </div>

            <!-- Event Picker -->
            <div class="card glass-strong border-0 rounded-4 mb-4">
                <div class="card-body p-4">
                    <h6 class="fw-bold mb-3"><i class="fas fa-calendar-alt text-primary me-2"></i>Chọn sự kiện</h6>
                    <div class="row g-2">
                        <c:forEach var="ev" items="${events}">
                            <div class="col-md-4 col-lg-3">
                                <a href="${pageContext.request.contextPath}/organizer/team?eventId=${ev.eventId}"
                                   class="d-block p-3 rounded-3 text-decoration-none small ${ev.eventId == selectedEventId ? 'fw-bold' : ''}"
                                   style="background:${ev.eventId == selectedEventId ? 'rgba(59,130,246,0.12)' : 'rgba(0,0,0,0.02)'};border:1px solid ${ev.eventId == selectedEventId ? 'rgba(59,130,246,0.3)' : 'transparent'};">
                                    <span class="text-truncate d-block">${ev.title}</span>
                                    <small class="text-muted"><fmt:formatDate value="${ev.startDate}" pattern="dd/MM/yyyy"/></small>
                                </a>
                            </div>
                        </c:forEach>
                        <c:if test="${empty events}">
                            <div class="col-12 text-center text-muted py-3">
                                <i class="fas fa-inbox me-1"></i>Chưa có sự kiện nào
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <c:if test="${not empty selectedEventId}">
                <!-- Role Legend -->
                <div class="card glass-strong border-0 rounded-4 mb-4">
                    <div class="card-body p-4">
                        <h6 class="fw-bold mb-3">Phân quyền vai trò — ${selectedEventTitle}</h6>
                        <div class="row g-3">
                            <div class="col-md-3">
                                <div class="d-flex align-items-start gap-3 p-3 rounded-3" style="background: rgba(239, 68, 68, 0.1);">
                                    <div class="rounded-3 p-2 badge-admin"><i class="fas fa-shield-alt"></i></div>
                                    <div><p class="fw-medium small mb-1">Quản trị viên</p><p class="text-muted small mb-0">Toàn quyền quản lý</p></div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="d-flex align-items-start gap-3 p-3 rounded-3" style="background: rgba(168, 85, 247, 0.1);">
                                    <div class="rounded-3 p-2 badge-manager"><i class="fas fa-edit"></i></div>
                                    <div><p class="fw-medium small mb-1">Quản lý</p><p class="text-muted small mb-0">Chỉnh sửa sự kiện, vé</p></div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="d-flex align-items-start gap-3 p-3 rounded-3" style="background: rgba(59, 130, 246, 0.1);">
                                    <div class="rounded-3 p-2 badge-checkin"><i class="fas fa-qrcode"></i></div>
                                    <div><p class="fw-medium small mb-1">Scanner</p><p class="text-muted small mb-0">Chỉ soát vé tại sự kiện</p></div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="d-flex align-items-start gap-3 p-3 rounded-3" style="background: rgba(34, 197, 94, 0.1);">
                                    <div class="rounded-3 p-2 badge-viewer"><i class="fas fa-eye"></i></div>
                                    <div><p class="fw-medium small mb-1">Staff</p><p class="text-muted small mb-0">Hỗ trợ vận hành và chỉnh sửa nội dung</p></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Team Members Grid -->
                <div class="row g-4">
                    <c:forEach var="staff" items="${staffList}">
                        <div class="col-md-6">
                            <div class="card glass-strong border-0 rounded-4 card-hover">
                                <div class="card-body p-4">
                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="avatar-placeholder rounded-circle" style="width: 48px; height: 48px;">
                                                ${staff.fullName != null ? staff.fullName.substring(0, 1) : '?'}
                                            </div>
                                            <div>
                                                <p class="fw-bold mb-0">${staff.fullName}</p>
                                                <p class="text-muted small mb-0"><i class="fas fa-envelope me-1"></i>${staff.userEmail}</p>
                                            </div>
                                        </div>
                                        <div class="dropdown">
                                            <button class="btn btn-sm btn-light rounded-circle" data-bs-toggle="dropdown">
                                                <i class="fas fa-ellipsis-v"></i>
                                            </button>
                                            <ul class="dropdown-menu dropdown-menu-end">
                                                <li>
                                                    <form method="POST" action="${pageContext.request.contextPath}/organizer/team"
                                                          onsubmit="return confirm('Xóa thành viên này?')">
                                                        <input type="hidden" name="action" value="remove">
                                                        <input type="hidden" name="eventId" value="${selectedEventId}">
                                                        <input type="hidden" name="userId" value="${staff.userId}">
                                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                                        <button type="submit" class="dropdown-item text-danger">
                                                            <i class="fas fa-trash me-2"></i>Xóa khỏi nhóm
                                                        </button>
                                                    </form>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                                        <c:choose>
                                            <c:when test="${staff.role == 'admin'}">
                                                <span class="badge rounded-pill badge-admin px-3 py-2"><i class="fas fa-shield-alt me-1"></i>Quản trị viên</span>
                                            </c:when>
                                            <c:when test="${staff.role == 'manager'}">
                                                <span class="badge rounded-pill badge-manager px-3 py-2"><i class="fas fa-edit me-1"></i>Quản lý</span>
                                            </c:when>
                                            <c:when test="${staff.role == 'scanner'}">
                                                <span class="badge rounded-pill badge-checkin px-3 py-2"><i class="fas fa-qrcode me-1"></i>Check-in</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge rounded-pill badge-viewer px-3 py-2"><i class="fas fa-eye me-1"></i>Staff</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <small class="text-muted">
                                            Thêm: <fmt:formatDate value="${staff.createdAt}" pattern="dd/MM/yyyy"/>
                                        </small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty staffList}">
                        <div class="col-12">
                            <div class="text-center text-muted py-5">
                                <i class="fas fa-users fa-3x mb-3 opacity-25"></i>
                                <p class="mb-0">Chưa có thành viên nào. Nhấn "Thêm thành viên" để bắt đầu.</p>
                            </div>
                        </div>
                    </c:if>
                </div>
            </c:if>

            <c:if test="${empty selectedEventId}">
                <div class="text-center text-muted py-5">
                    <i class="fas fa-hand-pointer fa-3x mb-3 opacity-25"></i>
                    <p>Chọn một sự kiện ở trên để quản lý đội ngũ</p>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Add Member Modal -->
<c:if test="${not empty selectedEventId}">
<div class="modal fade modal-glass" id="addMemberModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form method="POST" action="${pageContext.request.contextPath}/organizer/team">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="eventId" value="${selectedEventId}">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold">Thêm điều hành viên</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-medium">Email <span class="text-danger">*</span></label>
                        <input type="email" name="email" class="form-control glass-input rounded-3" placeholder="email@example.com" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Vai trò <span class="text-danger">*</span></label>
                        <select name="role" class="form-select glass-input rounded-3" required>
                            <option value="" selected disabled>Chọn vai trò</option>
                            <option value="manager">Quản lý - Toàn quyền trên sự kiện</option>
                            <option value="staff">Staff - Chỉnh sửa nội dung, hỗ trợ vận hành</option>
                            <option value="scanner">Scanner - Chỉ soát vé tại sự kiện</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-gradient rounded-pill px-4">
                        <i class="fas fa-paper-plane me-2"></i>Thêm thành viên
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
</c:if>

<jsp:include page="../footer.jsp" />
