<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="dashboard"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <!-- Welcome Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h3 class="fw-bold mb-1"><i class="fas fa-id-badge me-2" style="color: #10b981;"></i>Staff Dashboard</h3>
                    <p class="text-muted mb-0">Xin chào, ${sessionScope.account.fullName}! Đây là sự kiện bạn được phân công.</p>
                </div>
            </div>

            <!-- Stats Row -->
            <div class="row g-3 mb-4 animate-fadeInDown" style="animation-delay: 0.1s;">
                <div class="col-md-4">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="background: rgba(16,185,129,0.15);">
                                <i class="fas fa-calendar-check" style="color: #10b981;"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Sự kiện đảm nhận</div>
                                <div class="fw-bold fs-4">${totalAssignedEvents}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="background: rgba(59,130,246,0.15);">
                                <i class="fas fa-ticket-alt" style="color: #3b82f6;"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Vé đã bán</div>
                                <div class="fw-bold fs-4"><fmt:formatNumber value="${totalTicketsSold}" /></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="background: rgba(245,158,11,0.15);">
                                <i class="fas fa-check-circle" style="color: #f59e0b;"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Đã check-in</div>
                                <div class="fw-bold fs-4"><fmt:formatNumber value="${totalTicketsChecked}" /></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Assigned Events Table -->
            <div class="card glass-strong border-0 rounded-4 animate-fadeInDown" style="animation-delay: 0.2s;">
                <div class="card-header bg-transparent border-0 py-3 px-4 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold"><i class="fas fa-list-alt me-2"></i>Sự kiện được phân công</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr class="text-muted small" style="border-bottom: 2px solid rgba(0,0,0,0.05);">
                                    <th class="ps-4">Sự kiện</th>
                                    <th>Vai trò</th>
                                    <th>Thời gian</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Vé bán</th>
                                    <th class="text-center">Check-in</th>
                                    <th class="text-end pe-4">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="ev" items="${assignedEvents}">
                                <tr>
                                    <td class="ps-4">
                                        <div class="fw-semibold">${ev.eventName}</div>
                                        <small class="text-muted"><i class="fas fa-map-marker-alt me-1"></i>${ev.venue}</small>
                                    </td>
                                    <td>
                                        <span class="badge rounded-pill px-2 py-1" style="background: ${ev.staffRole == 'manager' ? 'rgba(139,92,246,0.15); color:#8b5cf6' :
                                            ev.staffRole == 'scanner' ? 'rgba(16,185,129,0.15); color:#10b981' :
                                            'rgba(59,130,246,0.15); color:#3b82f6'};">
                                            <i class="fas ${ev.staffRole == 'manager' ? 'fa-user-shield' : ev.staffRole == 'scanner' ? 'fa-qrcode' : 'fa-user'} me-1"></i>${ev.staffRole}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="small"><fmt:formatDate value="${ev.startDate}" pattern="dd/MM/yyyy HH:mm"/></div>
                                        <div class="small text-muted">→ <fmt:formatDate value="${ev.endDate}" pattern="dd/MM/yyyy HH:mm"/></div>
                                    </td>
                                    <td>
                                        <span class="badge rounded-pill px-2 py-1" style="background: ${ev.status == 'approved' ? 'rgba(16,185,129,0.15); color:#10b981' :
                                            ev.status == 'pending' ? 'rgba(245,158,11,0.15); color:#f59e0b' :
                                            'rgba(100,116,139,0.15); color:#64748b'};">
                                            ${ev.status}
                                        </span>
                                    </td>
                                    <td class="text-center fw-semibold">${ev.ticketsSold}</td>
                                    <td class="text-center">
                                        <span class="fw-semibold">${ev.ticketsChecked}</span>
                                        <c:if test="${ev.ticketsSold > 0}">
                                            <div class="progress mt-1" style="height: 4px;">
                                                <div class="progress-bar" role="progressbar" 
                                                     style="width: ${ev.ticketsChecked * 100 / ev.ticketsSold}%; background: linear-gradient(90deg, #10b981, #059669);"></div>
                                            </div>
                                        </c:if>
                                    </td>
                                    <td class="text-end pe-4">
                                        <div class="d-flex gap-1 justify-content-end">
                                            <c:if test="${ev.staffRole == 'manager' || ev.staffRole == 'scanner'}">
                                            <a href="${pageContext.request.contextPath}/staff/check-in?eventId=${ev.eventId}" 
                                               class="btn btn-sm rounded-pill" style="background: rgba(16,185,129,0.1); color: #10b981; font-size: 0.75rem;">
                                                <i class="fas fa-qrcode me-1"></i>Check-in
                                            </a>
                                            </c:if>
                                            <a href="${pageContext.request.contextPath}/organizer/events/${ev.eventId}" 
                                               class="btn btn-sm btn-outline-secondary rounded-pill" style="font-size: 0.75rem;">
                                                <i class="fas fa-eye me-1"></i>Chi tiết
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                                </c:forEach>

                                <c:if test="${empty assignedEvents}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="fas fa-inbox fa-3x mb-3 opacity-25"></i>
                                        <p class="mb-0">Bạn chưa được phân công sự kiện nào.</p>
                                    </td>
                                </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
