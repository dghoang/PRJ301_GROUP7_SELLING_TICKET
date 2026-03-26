<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

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
            <!-- Welcome Banner -->
            <div class="glass-gradient rounded-4 p-4 mb-4 position-relative overflow-hidden animate-fadeInDown">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h2 class="fw-bold mb-1" id="dashGreeting">Xin chào, Admin <i class="fas fa-hand-peace text-warning"></i></h2>
                        <p class="text-muted mb-0">Đây là tổng quan hệ thống của bạn hôm nay.</p>
                    </div>
                    <script>
                    (function(){
                        var h = new Date().getHours();
                        var g = h < 12 ? 'Chào buổi sáng' : h < 18 ? 'Chào buổi chiều' : 'Chào buổi tối';
                        var icon = h < 12 ? 'fa-sun text-warning' : h < 18 ? 'fa-cloud-sun text-info' : 'fa-moon text-primary';
                        document.getElementById('dashGreeting').innerHTML = g + ', Admin <i class="fas ' + icon + '"></i>';
                    })();
                    </script>
                    <div class="col-md-4 text-end d-none d-md-block">
                        <span class="badge glass rounded-pill px-3 py-2">
                            <i class="far fa-calendar me-1"></i>
                            <script>document.write(new Date().toLocaleDateString('vi-VN',{weekday:'long',year:'numeric',month:'long',day:'numeric'}))</script>
                        </span>
                    </div>
                </div>
                <div class="floating-element" style="top: -20px; right: 60px;"><i class="fas fa-chart-line text-primary" style="font-size: 3rem; opacity: 0.1;"></i></div>
            </div>

            <%-- Success/Error Alerts for Event Actions --%>
            <c:if test="${not empty flashSuccess}">
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="background: rgba(16,185,129,0.1); border-left: 4px solid #10b981 !important;">
                    <i class="fas fa-check-circle text-success me-2"></i>${flashSuccess}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty flashError}">
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="background: rgba(239,68,68,0.1); border-left: 4px solid #ef4444 !important;">
                    <i class="fas fa-exclamation-circle text-danger me-2"></i>${flashError}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Stats Cards -->
            <div class="row g-4 mb-4">
                <div class="col-md-6 col-xl-3 animate-on-scroll">
                    <a href="${pageContext.request.contextPath}/admin/events" class="text-decoration-none">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift" style="cursor:pointer;">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #9333ea, #a855f7);">
                                <i class="fas fa-calendar-alt fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0 counter" data-target="${totalEvents}">0</h3>
                                <small class="text-muted">Tổng sự kiện</small>
                                <div class="mt-1"><small class="text-info fw-medium"><i class="fas fa-clock"></i> ${pendingEvents} chờ duyệt</small></div>
                            </div>
                        </div>
                    </div>
                    </a>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-1">
                    <a href="${pageContext.request.contextPath}/admin/users" class="text-decoration-none">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift" style="cursor:pointer;">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-users fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0 counter" data-target="${totalUsers}">0</h3>
                                <small class="text-muted">Người dùng</small>
                                <div class="mt-1"><small class="text-success fw-medium"><i class="fas fa-user-plus"></i> Đã đăng ký</small></div>
                            </div>
                        </div>
                    </div>
                    </a>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-2">
                    <a href="${pageContext.request.contextPath}/admin/orders" class="text-decoration-none">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift" style="cursor:pointer;">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #f59e0b, #f97316);">
                                <i class="fas fa-ticket-alt fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0 counter" data-target="${paidOrders}">0</h3>
                                <small class="text-muted">Vé bán ra</small>
                                <div class="mt-1"><small class="text-warning fw-medium"><i class="fas fa-hourglass-half"></i> ${pendingOrders} chờ xử lý</small></div>
                            </div>
                        </div>
                    </div>
                    </a>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-3">
                    <a href="${pageContext.request.contextPath}/admin/orders" class="text-decoration-none">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift" style="cursor:pointer;">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #3b82f6, #6366f1);">
                                <i class="fas fa-dollar-sign fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0"><fmt:formatNumber value="${totalRevenue}" type="number" groupingUsed="true" /> đ</h3>
                                <small class="text-muted">Doanh thu (VNĐ)</small>
                                <div class="mt-1"><small class="text-success fw-medium"><i class="fas fa-chart-line"></i> Từ đơn đã thanh toán</small></div>
                            </div>
                        </div>
                    </div>
                    </a>
                </div>
            </div>

            <!-- Dashboard 2.0: Quick Metrics Row -->
            <div class="row g-4 mb-4">
                <div class="col-md-4 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #06b6d4, #22d3ee);">
                                <i class="fas fa-user-clock fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0 counter" data-target="${activeUsersToday}">0</h3>
                                <small class="text-muted">Active Users Today</small>
                                <div class="mt-1"><small class="text-info fw-medium"><i class="fas fa-signal"></i> Đăng nhập hôm nay</small></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #10b981, #34d399);">
                                <i class="fas fa-funnel-dollar fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">${conversionRate}%</h3>
                                <small class="text-muted">Conversion Rate</small>
                                <div class="mt-1"><small class="text-success fw-medium"><i class="fas fa-percentage"></i> Tỷ lệ thanh toán</small></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-bolt text-warning me-2"></i>Quick Actions</h6>
                            <div class="d-flex flex-wrap gap-2">
                                <a href="${pageContext.request.contextPath}/admin/events?status=pending" class="btn btn-sm rounded-pill" style="background:linear-gradient(135deg,#f59e0b,#f97316);color:#fff;">
                                    <i class="fas fa-check-circle me-1"></i>Duyệt sự kiện <span class="badge bg-white text-dark ms-1">${pendingCount}</span>
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/orders?status=pending" class="btn btn-sm rounded-pill" style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:#fff;">
                                    <i class="fas fa-receipt me-1"></i>Xử lý đơn
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/support" class="btn btn-sm btn-outline-secondary rounded-pill">
                                    <i class="fas fa-headset me-1"></i>Support
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="row g-4 mb-4">
                <!-- Revenue Chart -->
                <div class="col-lg-8 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center pt-4 px-4">
                            <h5 class="fw-bold mb-0"><i class="fas fa-chart-area text-primary me-2"></i>Doanh thu & Vé bán</h5>
                            <div class="btn-group btn-group-sm">
                                <button class="btn btn-outline-primary rounded-start-pill active" onclick="updateChart('week')">Tuần</button>
                                <button class="btn btn-outline-primary" onclick="updateChart('month')">Tháng</button>
                                <button class="btn btn-outline-primary rounded-end-pill" onclick="updateChart('year')">Năm</button>
                            </div>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <canvas id="revenueChart" height="280"></canvas>
                        </div>
                    </div>
                </div>
                <!-- Category Distribution -->
                <div class="col-lg-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0"><i class="fas fa-bullseye text-primary me-2"></i>Phân bổ danh mục</h5>
                        </div>
                        <div class="card-body d-flex align-items-center justify-content-center px-4 pb-4">
                            <canvas id="categoryChart" height="250"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Dashboard 2.0: Event Status + Hourly Orders Row -->
            <div class="row g-4 mb-4">
                <div class="col-lg-4 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0"><i class="fas fa-signal text-info me-2"></i>Trạng thái sự kiện</h5>
                        </div>
                        <div class="card-body d-flex align-items-center justify-content-center px-4 pb-4">
                            <canvas id="eventStatusChart" height="250"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-8 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0"><i class="fas fa-chart-bar text-success me-2"></i>Đơn hàng theo giờ (Hôm nay)</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <canvas id="hourlyOrdersChart" height="250"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pending Approvals + Activity -->
            <div class="row g-4">
                <div class="col-lg-8 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center pt-4 px-4">
                            <h5 class="fw-bold mb-0"><i class="fas fa-bell text-warning me-2"></i>Sự kiện chờ duyệt</h5>
                            <a href="${pageContext.request.contextPath}/admin/events?status=pending" class="btn btn-sm btn-outline-primary rounded-pill">Xem tất cả</a>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <div class="table-responsive">
                                <table class="table table-glass align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th>Sự kiện</th>
                                            <th>Organizer</th>
                                            <th>Ngày gửi</th>
                                            <th class="text-center">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="event" items="${pendingEventsList}">
                                        <tr class="hover-lift" style="transition: all 0.2s;">
                                            <td>
                                                <div class="d-flex align-items-center gap-3">
                                                    <img src="${event.bannerImage != null ? event.bannerImage : 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100'}" class="rounded-3 shadow-sm" style="width: 44px; height: 44px; object-fit: cover;">
                                                    <span class="fw-medium">${event.title}</span>
                                                </div>
                                            </td>
                                            <td class="text-muted">${event.organizerName}</td>
                                            <td class="text-muted">${event.createdAt}</td>
                                            <td class="text-center">
                                                <form method="POST" action="${pageContext.request.contextPath}/admin/events/approve" class="d-inline">
                                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                                    <input type="hidden" name="eventId" value="${event.eventId}"/>
                                                    <button type="submit" class="btn btn-sm rounded-pill px-3 me-1" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">
                                                        <i class="fas fa-check me-1"></i>Duyệt
                                                    </button>
                                                </form>
                                                <form method="POST" action="${pageContext.request.contextPath}/admin/events/reject" class="d-inline">
                                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                                    <input type="hidden" name="eventId" value="${event.eventId}"/>
                                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3">
                                                        <i class="fas fa-times me-1"></i>Từ chối
                                                    </button>
                                                </form>
                                                <a href="${pageContext.request.contextPath}/admin/events/${event.eventId}" class="btn btn-sm glass rounded-pill px-2 ms-1">
                                                    <i class="fas fa-eye text-primary"></i>
                                                </a>
                                            </td>
                                        </tr>
                                        </c:forEach>
                                        <c:if test="${empty pendingEventsList}">
                                        <tr>
                                            <td colspan="4" class="text-center py-4 text-muted">
                                                <i class="fas fa-check-circle fa-2x mb-2 opacity-25"></i>
                                                <p class="mb-0">Không có sự kiện chờ duyệt</p>
                                            </td>
                                        </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Orders Feed -->
                <div class="col-lg-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 mb-4">
                        <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center pt-4 px-4">
                            <h5 class="fw-bold mb-0"><i class="fas fa-shopping-cart text-primary me-2"></i>Đơn hàng gần đây</h5>
                            <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-sm btn-outline-primary rounded-pill">Xem tất cả</a>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <c:forEach var="order" items="${recentOrders}">
                                <c:set var="statusBg" value="linear-gradient(135deg,#ef4444,#f97316)" />
                                <c:set var="statusIcon" value="fa-times" />
                                <c:if test="${order.status == 'paid'}">
                                    <c:set var="statusBg" value="linear-gradient(135deg,#10b981,#06b6d4)" />
                                    <c:set var="statusIcon" value="fa-check" />
                                </c:if>
                                <c:if test="${order.status == 'pending'}">
                                    <c:set var="statusBg" value="linear-gradient(135deg,#f59e0b,#f97316)" />
                                    <c:set var="statusIcon" value="fa-clock" />
                                </c:if>
                            <div class="d-flex align-items-center gap-3 mb-3 p-2 rounded-3 hover-lift" style="transition: all 0.2s; background: rgba(0,0,0,0.015);">
                                <div class="dash-icon-box" style="--bg: ${statusBg}; width:36px;height:36px;min-width:36px;border-radius:10px;background:var(--bg);">
                                    <i class="fas ${statusIcon} text-white" style="font-size:0.75rem;"></i>
                                </div>
                                <div class="flex-grow-1" style="min-width:0;">
                                    <p class="mb-0 small fw-medium text-truncate">${order.buyerName}</p>
                                    <small class="text-muted" style="font-family:monospace;font-size:0.7rem;">${order.orderCode}</small>
                                </div>
                                <div class="text-end">
                                    <p class="mb-0 small fw-bold text-success"><fmt:formatNumber value="${order.finalAmount}" type="number" maxFractionDigits="0" groupingUsed="true"/>đ</p>
                                    <small class="text-muted"><fmt:formatDate value="${order.createdAt}" pattern="dd/MM HH:mm"/></small>
                                </div>
                            </div>
                            </c:forEach>
                            <c:if test="${empty recentOrders}">
                            <div class="text-center text-muted py-3">
                                <i class="fas fa-box-open fa-2x mb-2 opacity-25"></i>
                                <p class="mb-0 small">Chưa có đơn hàng nào</p>
                            </div>
                            </c:if>
                        </div>
                    </div>

                    <!-- Activity Feed -->
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0"><i class="fas fa-stream text-info me-2"></i>Hoạt động gần đây</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <c:forEach var="log" items="${activityFeed}">
                            <div class="d-flex align-items-start gap-2 mb-3 pb-2" style="border-bottom: 1px solid rgba(0,0,0,0.04);">
                                <div class="mt-1">
                                    <i class="fas fa-circle text-info" style="font-size: 6px;"></i>
                                </div>
                                <div class="flex-grow-1" style="min-width:0;">
                                    <p class="mb-0 small fw-medium text-truncate">${log.details}</p>
                                    <small class="text-muted">
                                        <i class="far fa-clock me-1"></i>
                                        <fmt:formatDate value="${log.createdAt}" pattern="dd/MM HH:mm"/>
                                        <span class="badge bg-light text-dark ms-1" style="font-size:0.65rem;">${log.action}</span>
                                    </small>
                                </div>
                            </div>
                            </c:forEach>
                            <c:if test="${empty activityFeed}">
                            <div class="text-center text-muted py-3">
                                <i class="fas fa-history fa-2x mb-2 opacity-25"></i>
                                <p class="mb-0 small">Chưa có hoạt động nào</p>
                            </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<script>
// Animated counters
document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.counter').forEach(el => {
        const target = parseInt(el.dataset.target);
        const duration = 2000;
        const step = target / (duration / 16);
        let current = 0;
        const timer = setInterval(() => {
            current += step;
            if (current >= target) {
                current = target;
                clearInterval(timer);
            }
            el.textContent = Math.floor(current).toLocaleString('vi-VN');
        }, 16);
    });

    // Revenue Chart — fetch real data from API
    const ctx = document.getElementById('revenueChart').getContext('2d');
    const gradient1 = ctx.createLinearGradient(0, 0, 0, 280);
    gradient1.addColorStop(0, 'rgba(147, 51, 234, 0.3)');
    gradient1.addColorStop(1, 'rgba(147, 51, 234, 0.01)');
    const gradient2 = ctx.createLinearGradient(0, 0, 0, 280);
    gradient2.addColorStop(0, 'rgba(6, 182, 212, 0.3)');
    gradient2.addColorStop(1, 'rgba(6, 182, 212, 0.01)');

    const chartOpts = {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: 'index', intersect: false },
        plugins: {
            legend: {
                position: 'top',
                labels: { usePointStyle: true, padding: 20, font: { family: 'Inter', weight: '500' } }
            },
            tooltip: {
                backgroundColor: 'rgba(255,255,255,0.95)',
                titleColor: '#1e293b',
                bodyColor: '#64748b',
                borderColor: 'rgba(0,0,0,0.05)',
                borderWidth: 1,
                cornerRadius: 12,
                padding: 12,
                titleFont: { family: 'Inter', weight: '700' },
                bodyFont: { family: 'Inter' },
                boxPadding: 6
            }
        },
        scales: {
            x: { grid: { display: false }, ticks: { font: { family: 'Inter' } } },
            y: { grid: { color: 'rgba(0,0,0,0.04)' }, ticks: { font: { family: 'Inter' } }, beginAtZero: true }
        }
    };

    window.revenueChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'Doanh thu (VNĐ)',
                data: [],
                borderColor: '#9333ea',
                backgroundColor: gradient1,
                fill: true, tension: 0.4, borderWidth: 3,
                pointBackgroundColor: '#9333ea', pointBorderColor: '#fff',
                pointBorderWidth: 2, pointRadius: 5, pointHoverRadius: 8
            }, {
                label: 'Vé bán',
                data: [],
                borderColor: '#06b6d4',
                backgroundColor: gradient2,
                fill: true, tension: 0.4, borderWidth: 3,
                pointBackgroundColor: '#06b6d4', pointBorderColor: '#fff',
                pointBorderWidth: 2, pointRadius: 5, pointHoverRadius: 8
            }]
        },
        options: chartOpts
    });

    // Category Doughnut — fetch real data from API
    const ctx2 = document.getElementById('categoryChart').getContext('2d');
    window.categoryChart = new Chart(ctx2, {
        type: 'doughnut',
        data: {
            labels: [],
            datasets: [{
                data: [],
                backgroundColor: ['#9333ea', '#06b6d4', '#10b981', '#f59e0b', '#3b82f6', '#ef4444', '#8b5cf6', '#14b8a6'],
                borderWidth: 0,
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '65%',
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { usePointStyle: true, padding: 15, font: { family: 'Inter', size: 12, weight: '500' } }
                }
            }
        }
    });

    // Load real data
    loadRevenueChart(7);
    loadCategoryChart();
    loadEventStatusChart();
    loadHourlyOrdersChart();
});

function loadRevenueChart(days) {
    const basePath = document.body.dataset.contextPath || '';
    fetch(basePath + '/admin/dashboard/chart-data?type=revenue&days=' + days)
        .then(r => r.json())
        .then(data => {
            const labels = data.map(d => {
                const date = new Date(d.date);
                return date.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' });
            });
            window.revenueChart.data.labels = labels.length > 0 ? labels : ['Chưa có dữ liệu'];
            window.revenueChart.data.datasets[0].data = data.map(d => d.revenue);
            window.revenueChart.data.datasets[1].data = data.map(d => d.ticketCount);
            window.revenueChart.update();
        })
        .catch(err => console.error('Failed to load revenue chart:', err));
}

function loadCategoryChart() {
    const basePath = document.body.dataset.contextPath || '';
    fetch(basePath + '/admin/dashboard/chart-data?type=category')
        .then(r => r.json())
        .then(data => {
            window.categoryChart.data.labels = data.map(d => d.name);
            window.categoryChart.data.datasets[0].data = data.map(d => d.count);
            window.categoryChart.update();
        })
        .catch(err => console.error('Failed to load category chart:', err));
}

function updateChart(period) {
    const daysMap = { 'week': 7, 'month': 30, 'year': 365 };
    loadRevenueChart(daysMap[period] || 7);

    document.querySelectorAll('.btn-group .btn').forEach(b => b.classList.remove('active'));
    event.target.classList.add('active');
}

// Dashboard 2.0: Event Status Doughnut
function loadEventStatusChart() {
    const basePath = document.body.dataset.contextPath || '';
    fetch(basePath + '/admin/dashboard/chart-data?type=event-status')
        .then(r => r.json())
        .then(data => {
            const ctx = document.getElementById('eventStatusChart').getContext('2d');
            const statusColors = {
                'approved': '#10b981', 'pending': '#f59e0b', 'rejected': '#ef4444',
                'cancelled': '#94a3b8', 'completed': '#3b82f6'
            };
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: data.map(d => d.status),
                    datasets: [{
                        data: data.map(d => d.count),
                        backgroundColor: data.map(d => statusColors[d.status] || '#8b5cf6'),
                        borderWidth: 0, hoverOffset: 8
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false, cutout: '65%',
                    plugins: {
                        legend: { position: 'bottom', labels: { usePointStyle: true, padding: 12, font: { family: 'Inter', size: 11, weight: '500' } } }
                    }
                }
            });
        })
        .catch(err => console.error('Failed to load event status chart:', err));
}

// Dashboard 2.0: Hourly Orders Bar Chart
function loadHourlyOrdersChart() {
    const basePath = document.body.dataset.contextPath || '';
    fetch(basePath + '/admin/dashboard/chart-data?type=hourly-orders')
        .then(r => r.json())
        .then(data => {
            const ctx = document.getElementById('hourlyOrdersChart').getContext('2d');
            const hours = Array.from({length: 24}, (_, i) => i + 'h');
            const counts = new Array(24).fill(0);
            data.forEach(d => { counts[d.hour] = d.count; });

            const gradient = ctx.createLinearGradient(0, 0, 0, 250);
            gradient.addColorStop(0, 'rgba(16, 185, 129, 0.7)');
            gradient.addColorStop(1, 'rgba(16, 185, 129, 0.1)');

            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: hours,
                    datasets: [{
                        label: 'Đơn hàng',
                        data: counts,
                        backgroundColor: gradient,
                        borderRadius: 4, borderSkipped: false
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { grid: { display: false }, ticks: { font: { family: 'Inter', size: 10 } } },
                        y: { grid: { color: 'rgba(0,0,0,0.04)' }, beginAtZero: true, ticks: { stepSize: 1, font: { family: 'Inter' } } }
                    }
                }
            });
        })
        .catch(err => console.error('Failed to load hourly orders chart:', err));
}
</script>

<jsp:include page="../footer.jsp" />
