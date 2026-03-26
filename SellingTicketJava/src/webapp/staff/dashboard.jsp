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
            <div class="row g-3 mb-4 animate-fadeInDown" style="animation-delay: 0.1s;">
                <div class="col-md-3">
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
                <div class="col-md-3">
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
                <div class="col-md-3">
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
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="background: rgba(139,92,246,0.15);">
                                <i class="fas fa-chart-line" style="color: #8b5cf6;"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Tỷ lệ check-in</div>
                                <div class="fw-bold fs-4">
                                    <c:choose>
                                        <c:when test="${totalTicketsSold > 0}">
                                            <fmt:formatNumber value="${totalTicketsChecked * 100.0 / totalTicketsSold}" maxFractionDigits="1"/>%
                                        </c:when>
                                        <c:otherwise>0%</c:otherwise>
                                    </c:choose>
                                </div>
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
                                        <span class="badge rounded-pill px-2 py-1" style="background: ${ev.staffRole == 'owner' ? 'rgba(234,179,8,0.15); color:#ca8a04' :
                                            ev.staffRole == 'manager' ? 'rgba(139,92,246,0.15); color:#8b5cf6' :
                                            ev.staffRole == 'scanner' ? 'rgba(16,185,129,0.15); color:#10b981' :
                                            'rgba(59,130,246,0.15); color:#3b82f6'};">
                                            <i class="fas ${ev.staffRole == 'owner' ? 'fa-crown' : ev.staffRole == 'manager' ? 'fa-user-shield' : ev.staffRole == 'scanner' ? 'fa-qrcode' : 'fa-user'} me-1"></i>${ev.staffRole}
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
                                            <c:if test="${ev.staffRole == 'owner' || ev.staffRole == 'manager' || ev.staffRole == 'scanner'}">
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
            <!-- Overall Check-in Chart -->
            <c:if test="${totalTicketsSold > 0}">
            <div class="row g-3 mt-3 animate-fadeInDown" style="animation-delay: 0.3s;">
                <div class="col-md-4">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0 py-3 px-4">
                            <h6 class="mb-0 fw-bold"><i class="fas fa-chart-pie me-2 text-success"></i>Tổng quan check-in</h6>
                        </div>
                        <div class="card-body d-flex align-items-center justify-content-center" style="min-height: 220px;">
                            <canvas id="dash-donut" width="200" height="200"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0 py-3 px-4">
                            <h6 class="mb-0 fw-bold"><i class="fas fa-chart-bar me-2 text-primary"></i>Check-in theo sự kiện</h6>
                        </div>
                        <div class="card-body" style="min-height: 220px;">
                            <canvas id="dash-bar"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            </c:if>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
(function() {
    // Donut chart
    var donutCanvas = document.getElementById('dash-donut');
    if (donutCanvas) {
        var sold = parseInt('${totalTicketsSold}') || 0;
        var checked = parseInt('${totalTicketsChecked}') || 0;
        new Chart(donutCanvas, {
            type: 'doughnut',
            data: {
                labels: ['Đã check-in', 'Chưa check-in'],
                datasets: [{
                    data: [checked, sold - checked],
                    backgroundColor: ['#10b981', 'rgba(148,163,184,0.25)'],
                    borderWidth: 0,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: false,
                cutout: '70%',
                plugins: {
                    legend: { position: 'bottom', labels: { padding: 16, usePointStyle: true, font: { size: 12 } } }
                }
            },
            plugins: [{
                id: 'centerText',
                beforeDraw: function(chart) {
                    var ctx = chart.ctx;
                    var pct = sold > 0 ? (checked * 100 / sold).toFixed(1) : '0';
                    ctx.save();
                    ctx.font = 'bold 22px Inter, sans-serif';
                    ctx.fillStyle = '#10b981';
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    var cx = (chart.chartArea.left + chart.chartArea.right) / 2;
                    var cy = (chart.chartArea.top + chart.chartArea.bottom) / 2;
                    ctx.fillText(pct + '%', cx, cy);
                    ctx.restore();
                }
            }]
        });
    }

    // Bar chart per event
    var barCanvas = document.getElementById('dash-bar');
    if (barCanvas) {
        var names = [], soldArr = [], checkedArr = [];
        <c:forEach var="ev" items="${assignedEvents}">
        names.push('${ev.eventName}');
        soldArr.push(${ev.ticketsSold});
        checkedArr.push(${ev.ticketsChecked});
        </c:forEach>
        new Chart(barCanvas, {
            type: 'bar',
            data: {
                labels: names,
                datasets: [
                    { label: 'Đã check-in', data: checkedArr, backgroundColor: '#10b981', borderRadius: 6 },
                    { label: 'Tổng bán', data: soldArr, backgroundColor: 'rgba(59,130,246,0.3)', borderRadius: 6 }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, font: { size: 11 } } } },
                scales: {
                    y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' } },
                    x: { grid: { display: false } }
                }
            }
        });
    }
})();
</script>

<jsp:include page="../footer.jsp" />
