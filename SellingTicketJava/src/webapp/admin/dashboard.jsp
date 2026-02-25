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
            <!-- Welcome Banner -->
            <div class="glass-gradient rounded-4 p-4 mb-4 position-relative overflow-hidden animate-fadeInDown">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h2 class="fw-bold mb-1">Xin chào, Admin 👋</h2>
                        <p class="text-muted mb-0">Đây là tổng quan hệ thống của bạn hôm nay.</p>
                    </div>
                    <div class="col-md-4 text-end d-none d-md-block">
                        <span class="badge glass rounded-pill px-3 py-2">
                            <i class="far fa-calendar me-1"></i>
                            <script>document.write(new Date().toLocaleDateString('vi-VN',{weekday:'long',year:'numeric',month:'long',day:'numeric'}))</script>
                        </span>
                    </div>
                </div>
                <div class="floating-element" style="top: -20px; right: 60px;"><i class="fas fa-chart-line text-primary" style="font-size: 3rem; opacity: 0.1;"></i></div>
            </div>

            <!-- Stats Cards -->
            <div class="row g-4 mb-4">
                <div class="col-md-6 col-xl-3 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
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
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
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
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
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
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-3">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
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
                </div>
            </div>

            <!-- Charts Row -->
            <div class="row g-4 mb-4">
                <!-- Revenue Chart -->
                <div class="col-lg-8 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center pt-4 px-4">
                            <h5 class="fw-bold mb-0">📊 Doanh thu & Vé bán</h5>
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
                            <h5 class="fw-bold mb-0">🎯 Phân bổ danh mục</h5>
                        </div>
                        <div class="card-body d-flex align-items-center justify-content-center px-4 pb-4">
                            <canvas id="categoryChart" height="250"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pending Approvals + Activity -->
            <div class="row g-4">
                <div class="col-lg-8 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center pt-4 px-4">
                            <h5 class="fw-bold mb-0">🔔 Sự kiện chờ duyệt</h5>
                            <a href="${pageContext.request.contextPath}/admin/event-approval" class="btn btn-sm btn-outline-primary rounded-pill">Xem tất cả</a>
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
                                                    <img src="${event.bannerUrl != null ? event.bannerUrl : 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100'}" class="rounded-3 shadow-sm" style="width: 44px; height: 44px; object-fit: cover;">
                                                    <span class="fw-medium">${event.title}</span>
                                                </div>
                                            </td>
                                            <td class="text-muted">${event.organizerName}</td>
                                            <td class="text-muted">${event.createdAt}</td>
                                            <td class="text-center">
                                                <button class="btn btn-sm rounded-pill px-3 me-1" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;" onclick="approveEvent(${event.eventId})">
                                                    <i class="fas fa-check me-1"></i>Duyệt
                                                </button>
                                                <button class="btn btn-sm btn-outline-danger rounded-pill px-3" onclick="rejectEvent(${event.eventId})">
                                                    <i class="fas fa-times me-1"></i>Từ chối
                                                </button>
                                            </td>
                                        </tr>
                                        </c:forEach>
                                        <c:if test="${empty pendingEventsList}">
                                        <tr>
                                            <td colspan="4" class="text-center py-4 text-muted">
                                                <i class="fas fa-check-circle fa-2x mb-2 opacity-25"></i>
                                                <p class="mb-0">Không có sự kiện chờ duyệt 🎉</p>
                                            </td>
                                        </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Activity Feed -->
                <div class="col-lg-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0">⚡ Hoạt động gần đây</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <div class="activity-feed">
                                <c:forEach var="pe" items="${pendingEventsList}" end="4">
                                <div class="activity-item d-flex gap-3 mb-4">
                                    <div class="activity-dot" style="background: linear-gradient(135deg, #f59e0b, #f97316);"></div>
                                    <div>
                                        <p class="mb-0 small fw-medium">Sự kiện chờ duyệt: <strong>${pe.title}</strong></p>
                                        <small class="text-muted"><fmt:formatDate value="${pe.createdAt}" pattern="dd/MM HH:mm" /></small>
                                    </div>
                                </div>
                                </c:forEach>
                                <c:if test="${empty pendingEventsList}">
                                <div class="text-center text-muted py-3">
                                    <i class="fas fa-check-circle fa-2x mb-2 opacity-25"></i>
                                    <p class="mb-0 small">Không có hoạt động mới</p>
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
});

function loadRevenueChart(days) {
    const basePath = document.querySelector('meta[name="ctx"]')?.content || '';
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
    const basePath = document.querySelector('meta[name="ctx"]')?.content || '';
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
</script>

<jsp:include page="../footer.jsp" />
