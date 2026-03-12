<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

<jsp:include page="../header.jsp" />

<style>
/* ======== DETAIL HERO ======== */
.detail-hero {
    position: relative;
    border-radius: var(--radius-xl);
    overflow: hidden;
    height: 260px;
}
.detail-hero img {
    width: 100%; height: 100%; object-fit: cover;
}
.detail-hero .hero-overlay {
    position: absolute; inset: 0;
    background: linear-gradient(to top, rgba(0,0,0,0.75) 0%, rgba(0,0,0,0.1) 60%);
    display: flex; flex-direction: column;
    justify-content: flex-end;
    padding: 1.5rem 2rem;
    color: white;
}
.detail-hero .hero-overlay h2 { color: white; text-shadow: 0 2px 12px rgba(0,0,0,0.3); }

/* ======== STAT METRIC ======== */
.stat-metric {
    background: rgba(255,255,255,0.7);
    border-radius: var(--radius-lg);
    padding: 1.25rem;
    text-align: center;
    border: 1px solid rgba(0,0,0,0.04);
    transition: all 0.3s;
}
.stat-metric:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
}
.stat-metric .metric-icon {
    width: 44px; height: 44px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    margin: 0 auto 0.75rem;
    font-size: 1.1rem;
}
.stat-metric .metric-value {
    font-size: 1.5rem; font-weight: 800;
    line-height: 1;
}
.stat-metric .metric-label {
    font-size: 0.75rem; color: var(--text-muted);
    margin-top: 0.25rem;
}

/* ======== TIMELINE ======== */
.event-timeline {
    display: flex;
    align-items: center;
    gap: 0;
    padding: 1rem 0;
}
.timeline-dot {
    width: 32px; height: 32px;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.7rem;
    font-weight: 700;
    flex-shrink: 0;
    transition: all 0.3s;
}
.timeline-dot.done {
    background: #10b981; color: white;
}
.timeline-dot.current {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    box-shadow: 0 4px 12px rgba(147, 51, 234, 0.3);
    transform: scale(1.15);
}
.timeline-dot.future {
    background: rgba(0,0,0,0.06);
    color: var(--text-muted);
}
.timeline-line {
    flex: 1; height: 3px;
    border-radius: 3px;
    transition: background 0.3s;
}
.timeline-line.done { background: #10b981; }
.timeline-line.future { background: rgba(0,0,0,0.06); }
.timeline-label {
    font-size: 0.65rem;
    text-align: center;
    color: var(--text-muted);
    margin-top: 0.35rem;
}

/* ======== TICKET TYPE DISPLAY ======== */
.ticket-display {
    background: rgba(255,255,255,0.6);
    border-radius: var(--radius-md);
    padding: 1rem 1.25rem;
    border-left: 4px solid var(--primary);
    transition: all 0.2s;
}
.ticket-display:hover {
    background: rgba(255,255,255,0.85);
    box-shadow: 0 4px 12px rgba(0,0,0,0.06);
}
.avail-bar {
    height: 6px;
    border-radius: 6px;
    background: rgba(0,0,0,0.06);
    overflow: hidden;
}
.avail-bar .fill {
    height: 100%;
    border-radius: 6px;
    transition: width 0.6s ease;
}

/* Quick actions */
.quick-action {
    display: flex; flex-direction: column;
    align-items: center; gap: 0.5rem;
    padding: 1rem;
    border-radius: var(--radius-md);
    background: rgba(255,255,255,0.5);
    transition: all 0.3s;
    text-decoration: none;
    color: var(--text-main);
    border: 1px solid rgba(0,0,0,0.04);
    cursor: pointer;
}
.quick-action:hover {
    background: rgba(255,255,255,0.85);
    transform: translateY(-3px);
    box-shadow: 0 6px 16px rgba(0,0,0,0.08);
    color: var(--primary);
}
.quick-action .action-icon {
    width: 44px; height: 44px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem;
}
</style>

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="events"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <!-- Breadcrumb -->
            <nav aria-label="breadcrumb" class="mb-3 animate-fadeInDown">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/organizer/events" class="text-decoration-none">Sự kiện</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${event.title}</li>
                </ol>
            </nav>

            <!-- Hero Banner -->
            <div class="detail-hero mb-4 animate-on-scroll visible">
                <c:choose>
                    <c:when test="${not empty event.bannerImage}">
                        <img src="${event.bannerImage}" alt="${event.title}" style="width:100%;height:100%;object-fit:cover;">
                    </c:when>
                    <c:otherwise>
                        <div style="width:100%;height:100%;background:linear-gradient(135deg,#9333ea,#db2777);display:flex;align-items:center;justify-content:center;">
                            <i class="fas fa-calendar-alt fa-3x" style="color:rgba(255,255,255,0.4);"></i>
                        </div>
                    </c:otherwise>
                </c:choose>
                <div class="hero-overlay">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <tags:eventStatus status="${event.status}" />
                    </div>
                    <h2 class="fw-bold mb-1">${event.title}</h2>
                    <p class="mb-0 opacity-75">
                        <i class="far fa-calendar me-1"></i>${event.startDate}
                        <span class="mx-2">|</span>
                        <i class="fas fa-map-marker-alt me-1"></i>${event.location}
                    </p>
                </div>
            </div>

            <%-- Event date status banner --%>
            <tags:eventDateCheck event="${event}" showCountdown="true" />

            <!-- Stats Row -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-md-3 animate-on-scroll visible">
                    <div class="stat-metric">
                        <div class="metric-icon" style="background: rgba(59,130,246,0.1); color: #3b82f6;">
                            <i class="fas fa-ticket-alt"></i>
                        </div>
                        <div class="metric-value">${event.totalTickets != null ? event.totalTickets : 0}</div>
                        <div class="metric-label">Tổng vé</div>
                    </div>
                </div>
                <div class="col-6 col-md-3 animate-on-scroll visible stagger-1">
                    <div class="stat-metric">
                        <div class="metric-icon" style="background: rgba(16,185,129,0.1); color: #10b981;">
                            <i class="fas fa-shopping-bag"></i>
                        </div>
                        <div class="metric-value">${event.soldTickets != null ? event.soldTickets : 0}</div>
                        <div class="metric-label">Đã bán</div>
                    </div>
                </div>
                <div class="col-6 col-md-3 animate-on-scroll visible stagger-2">
                    <div class="stat-metric">
                        <div class="metric-icon" style="background: rgba(245,158,11,0.1); color: #f59e0b;">
                            <i class="fas fa-coins"></i>
                        </div>
                        <div class="metric-value"><fmt:formatNumber value="${event.revenue}" type="number" maxFractionDigits="0"/>đ</div>
                        <div class="metric-label">Doanh thu</div>
                    </div>
                </div>
                <div class="col-6 col-md-3 animate-on-scroll visible stagger-3">
                    <div class="stat-metric">
                        <div class="metric-icon" style="background: rgba(147,51,234,0.1); color: var(--primary);">
                            <i class="fas fa-user-check"></i>
                        </div>
                        <div class="metric-value">${checkInRate != null ? checkInRate : 0}%</div>
                        <div class="metric-label">Check-in</div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <!-- Left Column -->
                <div class="col-lg-8">
                    <!-- Event Timeline -->
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-stream me-2 text-primary"></i>Vòng đời sự kiện</h6>
                            <div class="event-timeline">
                                <div class="text-center">
                                    <div class="timeline-dot done"><i class="fas fa-check"></i></div>
                                    <div class="timeline-label">Tạo</div>
                                </div>
                                <div class="timeline-line ${event.status != 'draft' ? 'done' : 'future'}"></div>
                                <div class="text-center">
                                    <div class="timeline-dot ${event.status == 'pending' ? 'current' : event.status == 'approved' || event.status == 'ended' ? 'done' : 'future'}">
                                        ${event.status == 'pending' ? '<i class="fas fa-clock"></i>' : '<i class="fas fa-check"></i>'}
                                    </div>
                                    <div class="timeline-label">Duyệt</div>
                                </div>
                                <div class="timeline-line ${event.status == 'approved' || event.status == 'ended' ? 'done' : 'future'}"></div>
                                <div class="text-center">
                                    <div class="timeline-dot ${event.status == 'approved' ? 'current' : event.status == 'ended' ? 'done' : 'future'}">
                                        <i class="fas fa-play"></i>
                                    </div>
                                    <div class="timeline-label">Đang bán</div>
                                </div>
                                <div class="timeline-line ${event.status == 'ended' ? 'done' : 'future'}"></div>
                                <div class="text-center">
                                    <div class="timeline-dot ${event.status == 'ended' ? 'current' : 'future'}">
                                        <i class="fas fa-flag"></i>
                                    </div>
                                    <div class="timeline-label">Kết thúc</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Description -->
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-align-left me-2 text-primary"></i>Mô tả sự kiện</h6>
                            <div class="text-muted" style="line-height: 1.7;">
                                ${event.description != null ? event.description : '<p class="text-muted">Chưa có mô tả</p>'}
                            </div>
                        </div>
                    </div>

                    <!-- Ticket Types -->
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-ticket-alt me-2 text-primary"></i>Loại vé</h6>
                            <div class="d-flex flex-column gap-3">
                                <c:forEach var="ticket" items="${event.ticketTypes}">
                                    <div class="ticket-display">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <div>
                                                <strong>${ticket.name}</strong>
                                                <span class="badge bg-soft-primary text-primary ms-2 rounded-pill">${ticket.price} đ</span>
                                            </div>
                                            <span class="small text-muted">${ticket.soldQuantity}/${ticket.quantity} vé</span>
                                        </div>
                                        <div class="avail-bar">
                                            <c:set var="soldPct" value="${ticket.quantity > 0 ? ticket.soldQuantity * 100 / ticket.quantity : 0}"/>
                                            <c:set var="barColor" value="${ticket.soldQuantity >= ticket.quantity ? '#ef4444' : (ticket.soldQuantity * 10 > ticket.quantity * 8 ? '#f59e0b' : '#10b981')}"/>
                                            <div class="fill" style="width:${soldPct}%;background:${barColor};"></div>
                                        </div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty event.ticketTypes}">
                                    <p class="text-muted text-center py-3">Chưa có loại vé nào</p>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column -->
                <div class="col-lg-4">
                    <!-- Quick Actions (visibility based on role & event status) -->
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible stagger-1">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3">Thao tác nhanh</h6>
                            <div class="row g-3">
                                <c:if test="${canEdit}">
                                <div class="col-6">
                                    <a href="${pageContext.request.contextPath}/organizer/events/${event.eventId}/edit" class="quick-action">
                                        <div class="action-icon" style="background: rgba(59,130,246,0.1); color: #3b82f6;">
                                            <i class="fas fa-edit"></i>
                                        </div>
                                        <small class="fw-medium">Chỉnh sửa</small>
                                    </a>
                                </div>
                                </c:if>
                                <c:if test="${canEdit}">
                                <div class="col-6">
                                    <a href="${pageContext.request.contextPath}/organizer/events/${event.eventId}/staff" class="quick-action">
                                        <div class="action-icon" style="background: rgba(147,51,234,0.1); color: var(--primary);">
                                            <i class="fas fa-users"></i>
                                        </div>
                                        <small class="fw-medium">Nhân sự</small>
                                    </a>
                                </div>
                                </c:if>
                                <c:if test="${canCheckin && isApproved}">
                                <div class="col-6">
                                    <a href="${pageContext.request.contextPath}/organizer/check-in?eventId=${event.eventId}" class="quick-action">
                                        <div class="action-icon" style="background: rgba(16,185,129,0.1); color: #10b981;">
                                            <i class="fas fa-qrcode"></i>
                                        </div>
                                        <small class="fw-medium">Check-in</small>
                                    </a>
                                </div>
                                </c:if>
                                <c:if test="${canEdit && isApproved}">
                                <div class="col-6">
                                    <a href="${pageContext.request.contextPath}/organizer/statistics?eventId=${event.eventId}" class="quick-action">
                                        <div class="action-icon" style="background: rgba(245,158,11,0.1); color: #f59e0b;">
                                            <i class="fas fa-chart-line"></i>
                                        </div>
                                        <small class="fw-medium">Thống kê</small>
                                    </a>
                                </div>
                                </c:if>
                                <c:if test="${isDraft && canEdit}">
                                <div class="col-12">
                                    <form method="POST" action="${pageContext.request.contextPath}/organizer/events/submit-draft">
                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                        <input type="hidden" name="eventId" value="${event.eventId}"/>
                                        <button type="submit" class="quick-action w-100" style="border:none;background:rgba(16,185,129,0.08);">
                                            <div class="action-icon" style="background: rgba(16,185,129,0.12); color: #10b981;">
                                                <i class="fas fa-paper-plane"></i>
                                            </div>
                                            <small class="fw-medium text-success">Gửi duyệt</small>
                                        </button>
                                    </form>
                                </div>
                                </c:if>
                            </div>
                            <%-- Info banner for non-approved events --%>
                            <c:if test="${!isApproved && !isDraft}">
                                <div class="alert alert-warning border-0 rounded-3 mt-3 py-2 px-3 small">
                                    <i class="fas fa-clock me-2"></i>Sự kiện đang chờ Admin duyệt. Một số tính năng vận hành sẽ mở sau khi được duyệt.
                                </div>
                            </c:if>
                            <c:if test="${isDraft}">
                                <div class="alert alert-secondary border-0 rounded-3 mt-3 py-2 px-3 small">
                                    <i class="fas fa-file-alt me-2"></i>Đây là bản nháp. Chỉnh sửa xong rồi bấm <strong>Gửi duyệt</strong> để gửi lên Admin.
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <!-- Event Info Card -->
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible stagger-2">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3">Thông tin chi tiết</h6>
                            <div class="d-flex flex-column gap-3">
                                <div class="d-flex align-items-center gap-3">
                                    <div style="width:36px;height:36px;border-radius:10px;background:rgba(59,130,246,0.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;color:#3b82f6;">
                                        <i class="fas fa-calendar-alt"></i>
                                    </div>
                                    <div>
                                        <small class="text-muted d-block">Bắt đầu</small>
                                        <span class="fw-medium small">${event.startDate}</span>
                                    </div>
                                </div>
                                <c:if test="${event.endDate != null}">
                                    <div class="d-flex align-items-center gap-3">
                                        <div style="width:36px;height:36px;border-radius:10px;background:rgba(239,68,68,0.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;color:#ef4444;">
                                            <i class="fas fa-calendar-check"></i>
                                        </div>
                                        <div>
                                            <small class="text-muted d-block">Kết thúc</small>
                                            <span class="fw-medium small">${event.endDate}</span>
                                        </div>
                                    </div>
                                </c:if>
                                <div class="d-flex align-items-center gap-3">
                                    <div style="width:36px;height:36px;border-radius:10px;background:rgba(16,185,129,0.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;color:#10b981;">
                                        <i class="fas fa-map-marker-alt"></i>
                                    </div>
                                    <div>
                                        <small class="text-muted d-block">Địa điểm</small>
                                        <span class="fw-medium small">${event.location}</span>
                                    </div>
                                </div>
                                <c:if test="${event.address != null}">
                                    <div class="d-flex align-items-center gap-3">
                                        <div style="width:36px;height:36px;border-radius:10px;background:rgba(245,158,11,0.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;color:#f59e0b;">
                                            <i class="fas fa-directions"></i>
                                        </div>
                                        <div>
                                            <small class="text-muted d-block">Địa chỉ</small>
                                            <span class="fw-medium small">${event.address}</span>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
