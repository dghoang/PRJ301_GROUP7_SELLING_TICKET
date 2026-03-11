<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<style>
.staff-card {
    display: flex; align-items: center; gap: 1rem;
    padding: 1rem 1.25rem;
    border-radius: var(--radius-md);
    background: rgba(255,255,255,0.6);
    border: 1px solid rgba(0,0,0,0.04);
    transition: all 0.3s;
}
.staff-card:hover {
    background: rgba(255,255,255,0.85);
    box-shadow: 0 6px 20px rgba(0,0,0,0.06);
    transform: translateY(-2px);
}
.staff-avatar {
    width: 44px; height: 44px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-weight: 700;
    color: white;
    font-size: 1rem;
    flex-shrink: 0;
}
.role-badge {
    display: inline-flex; align-items: center; gap: 0.35rem;
    padding: 0.25rem 0.65rem;
    border-radius: 50rem;
    font-size: 0.7rem;
    font-weight: 600;
}
.role-manager { background: rgba(147,51,234,0.1); color: var(--primary); }
.role-editor { background: rgba(59,130,246,0.1); color: #3b82f6; }
.role-checkin { background: rgba(16,185,129,0.1); color: #10b981; }
.invite-card {
    border: 2px dashed rgba(147,51,234,0.2);
    border-radius: var(--radius-lg);
    padding: 1.5rem;
    transition: all 0.3s;
}
.invite-card:hover { border-color: var(--primary); }
</style>

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="events"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <!-- Header -->
            <div class="mb-4 animate-fadeInDown">
                <nav aria-label="breadcrumb" class="mb-2">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/organizer/events" class="text-decoration-none">Sự kiện</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/organizer/events/${event.eventId}" class="text-decoration-none">${event.title}</a></li>
                        <li class="breadcrumb-item active">Nhân sự</li>
                    </ol>
                </nav>
                <h2 class="fw-bold mb-1">Quản lý nhân sự</h2>
                <p class="text-muted small mb-0">Mời và quản lý cộng tác viên cho sự kiện <strong>${event.title}</strong></p>
            </div>

            <div class="row g-4">
                <!-- Staff List -->
                <div class="col-lg-7">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h6 class="fw-bold mb-0"><i class="fas fa-users me-2 text-primary"></i>Thành viên (${staff != null ? staff.size() : 0})</h6>
                            </div>

                            <div class="d-flex flex-column gap-3">
                                <!-- Owner -->
                                <div class="staff-card" style="border-left: 4px solid #ef4444;">
                                    <div class="staff-avatar" style="background: linear-gradient(135deg, #ef4444, #f97316);">
                                        ${event.organizerName != null ? event.organizerName.substring(0,1) : 'O'}
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="fw-bold small">${event.organizerName != null ? event.organizerName : 'Chủ sở hữu'}</div>
                                        <div class="text-muted" style="font-size: 0.75rem;">Chủ sở hữu sự kiện</div>
                                    </div>
                                    <span class="role-badge" style="background: rgba(239,68,68,0.1); color: #ef4444;">
                                        <i class="fas fa-crown"></i>Chủ sở hữu
                                    </span>
                                </div>

                                <!-- Staff Members -->
                                <c:forEach var="s" items="${staff}">
                                    <div class="staff-card" style="border-left: 4px solid
                                        ${s.role == 'manager' ? 'var(--primary)' : s.role == 'editor' ? '#3b82f6' : '#10b981'};">
                                        <div class="staff-avatar" style="background: linear-gradient(135deg,
                                            ${s.role == 'manager' ? 'var(--primary), var(--secondary)' : s.role == 'editor' ? '#3b82f6, #06b6d4' : '#10b981, #14b8a6'});">
                                            ${s.userName != null ? s.userName.substring(0,1) : '?'}
                                        </div>
                                        <div class="flex-grow-1">
                                            <div class="fw-bold small">${s.userName}</div>
                                            <div class="text-muted" style="font-size: 0.75rem;">${s.userEmail}</div>
                                        </div>
                                        <span class="role-badge role-${s.role}">
                                            <i class="fas ${s.role == 'manager' ? 'fa-shield-alt' : s.role == 'editor' ? 'fa-pen' : 'fa-qrcode'}"></i>
                                            ${s.role == 'manager' ? 'Quản lý' : s.role == 'editor' ? 'Biên tập' : 'Soát vé'}
                                        </span>
                                        <c:if test="${userEventRole == 'admin' || userEventRole == 'owner' || userEventRole == 'manager'}">
                                            <button class="btn btn-sm btn-outline-danger rounded-pill px-2"
                                                    onclick="confirmRemoveStaff(${s.userId}, '${s.userName}')" title="Xóa">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </c:forEach>

                                <c:if test="${empty staff}">
                                    <div class="text-center py-4">
                                        <i class="fas fa-user-plus fa-2x text-muted opacity-25 mb-2"></i>
                                        <p class="text-muted small mb-0">Chưa có cộng tác viên nào</p>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Invite Form -->
                <div class="col-lg-5">
                    <c:if test="${userEventRole == 'admin' || userEventRole == 'owner' || userEventRole == 'manager'}">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible stagger-1">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-4"><i class="fas fa-user-plus me-2 text-primary"></i>Mời cộng tác viên</h6>
                            <form method="POST" action="${pageContext.request.contextPath}/organizer/events/${event.eventId}/staff/add" id="inviteForm">
                                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                <div class="mb-3">
                                    <label class="form-label small fw-medium">Email</label>
                                    <input type="email" class="form-control" name="email" placeholder="example@email.com" required>
                                </div>
                                <div class="mb-4">
                                    <label class="form-label small fw-medium">Vai trò</label>
                                    <div class="d-flex flex-column gap-2">
                                        <label class="invite-card d-flex align-items-center gap-3 cursor-pointer m-0" style="cursor:pointer;">
                                            <input type="radio" name="role" value="manager" class="form-check-input" checked>
                                            <div style="width:36px;height:36px;border-radius:10px;background:rgba(147,51,234,0.1);display:flex;align-items:center;justify-content:center;color:var(--primary);flex-shrink:0;">
                                                <i class="fas fa-shield-alt"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold small">Quản lý</div>
                                                <div class="text-muted" style="font-size:0.7rem;">Toàn quyền: sửa, xóa, nhân sự, check-in</div>
                                            </div>
                                        </label>
                                        <label class="invite-card d-flex align-items-center gap-3 m-0" style="cursor:pointer;">
                                            <input type="radio" name="role" value="editor" class="form-check-input">
                                            <div style="width:36px;height:36px;border-radius:10px;background:rgba(59,130,246,0.1);display:flex;align-items:center;justify-content:center;color:#3b82f6;flex-shrink:0;">
                                                <i class="fas fa-pen"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold small">Biên tập viên</div>
                                                <div class="text-muted" style="font-size:0.7rem;">Chỉnh sửa thông tin, vé, mô tả sự kiện</div>
                                            </div>
                                        </label>
                                        <label class="invite-card d-flex align-items-center gap-3 m-0" style="cursor:pointer;">
                                            <input type="radio" name="role" value="checkin" class="form-check-input">
                                            <div style="width:36px;height:36px;border-radius:10px;background:rgba(16,185,129,0.1);display:flex;align-items:center;justify-content:center;color:#10b981;flex-shrink:0;">
                                                <i class="fas fa-qrcode"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold small">Soát vé</div>
                                                <div class="text-muted" style="font-size:0.7rem;">Chỉ có quyền check-in, xem danh sách</div>
                                            </div>
                                        </label>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-gradient w-100 rounded-pill py-2">
                                    <i class="fas fa-paper-plane me-2"></i>Gửi lời mời
                                </button>
                            </form>
                        </div>
                    </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Remove Confirmation Modal -->
<div class="modal fade" id="removeModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content glass-strong border-0 rounded-4 shadow-lg">
            <div class="modal-body text-center p-4">
                <div style="width:56px;height:56px;border-radius:50%;background:rgba(239,68,68,0.1);display:flex;align-items:center;justify-content:center;margin:0 auto 1rem;">
                    <i class="fas fa-user-minus fa-xl text-danger"></i>
                </div>
                <h6 class="fw-bold mb-1">Xóa cộng tác viên?</h6>
                <p class="text-muted small mb-3">Xóa <strong id="removeStaffName"></strong> khỏi sự kiện?</p>
                <div class="d-flex gap-2 justify-content-center">
                    <button class="btn btn-sm btn-outline-secondary rounded-pill px-3" data-bs-dismiss="modal">Hủy</button>
                    <form id="removeForm" method="POST">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                        <button type="submit" class="btn btn-sm btn-danger rounded-pill px-3">Xóa</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function confirmRemoveStaff(userId, userName) {
    document.getElementById('removeStaffName').textContent = userName;
    document.getElementById('removeForm').action = '${pageContext.request.contextPath}/organizer/events/${event.eventId}/staff/remove?userId=' + userId;
    new bootstrap.Modal(document.getElementById('removeModal')).show();
}
</script>

<jsp:include page="../footer.jsp" />
