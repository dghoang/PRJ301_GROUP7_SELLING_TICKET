<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

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
                        <h2 class="fw-bold mb-1">Dashboard Organizer 🎤</h2>
                        <p class="text-muted mb-0">Quản lý sự kiện và theo dõi hiệu suất bán vé.</p>
                    </div>
                    <div class="col-md-4 text-end d-none d-md-block">
                        <a href="${pageContext.request.contextPath}/organizer/create-event" class="btn btn-gradient rounded-pill px-4 hover-glow">
                            <i class="fas fa-plus me-2"></i>Tạo sự kiện
                        </a>
                    </div>
                </div>
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
                                <h3 class="fw-bold mb-0 counter" data-target="12">0</h3>
                                <small class="text-muted">Sự kiện đang bán</small>
                                <div class="mt-1"><small class="text-success fw-medium"><i class="fas fa-arrow-up"></i> +3 tuần này</small></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-ticket-alt fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0 counter" data-target="2458">0</h3>
                                <small class="text-muted">Vé đã bán</small>
                                <div class="mt-1"><small class="text-success fw-medium"><i class="fas fa-arrow-up"></i> +12% tháng này</small></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #f59e0b, #f97316);">
                                <i class="fas fa-dollar-sign fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0"><span class="counter" data-target="850">0</span>M</h3>
                                <small class="text-muted">Doanh thu (VNĐ)</small>
                                <div class="mt-1"><small class="text-success fw-medium"><i class="fas fa-arrow-up"></i> +18% so kỳ trước</small></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-3">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #3b82f6, #6366f1);">
                                <i class="fas fa-users fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0 counter" data-target="1845">0</h3>
                                <small class="text-muted">Khách tham dự</small>
                                <div class="mt-1"><small class="text-success fw-medium"><i class="fas fa-arrow-up"></i> +220 tuần này</small></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center pt-4 px-4">
                            <h5 class="fw-bold mb-0">📈 Hiệu suất bán vé</h5>
                            <div class="btn-group btn-group-sm">
                                <button class="btn btn-outline-primary rounded-start-pill active" onclick="updateOrgChart('week')">Tuần</button>
                                <button class="btn btn-outline-primary" onclick="updateOrgChart('month')">Tháng</button>
                                <button class="btn btn-outline-primary rounded-end-pill" onclick="updateOrgChart('quarter')">Quý</button>
                            </div>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <canvas id="salesChart" height="280"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0">🎫 Loại vé bán ra</h5>
                        </div>
                        <div class="card-body d-flex align-items-center justify-content-center px-4 pb-4">
                            <canvas id="ticketTypeChart" height="250"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions + Recent Events -->
            <div class="row g-4 mb-4">
                <div class="col-12 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3">⚡ Hành động nhanh</h5>
                            <div class="d-flex gap-3 flex-wrap">
                                <a href="${pageContext.request.contextPath}/organizer/create-event" class="btn btn-gradient rounded-pill px-4 hover-glow">
                                    <i class="fas fa-plus me-2"></i>Tạo sự kiện mới
                                </a>
                                <a href="${pageContext.request.contextPath}/organizer/check-in" class="btn glass rounded-pill px-4 hover-lift fw-medium">
                                    <i class="fas fa-qrcode me-2 text-primary"></i>Quét check-in
                                </a>
                                <button class="btn glass rounded-pill px-4 hover-lift fw-medium">
                                    <i class="fas fa-download me-2 text-success"></i>Xuất báo cáo
                                </button>
                                <a href="${pageContext.request.contextPath}/organizer/vouchers" class="btn glass rounded-pill px-4 hover-lift fw-medium">
                                    <i class="fas fa-tags me-2 text-warning"></i>Quản lý voucher
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Events Table -->
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center pt-4 px-4">
                    <h5 class="fw-bold mb-0">📋 Sự kiện gần đây</h5>
                    <a href="${pageContext.request.contextPath}/organizer/events" class="btn btn-sm btn-outline-primary rounded-pill">Xem tất cả</a>
                </div>
                <div class="card-body px-4 pb-4">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Sự kiện</th>
                                    <th>Ngày diễn ra</th>
                                    <th>Vé bán</th>
                                    <th>Doanh thu</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="event" items="${recentEvents}">
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="${event.bannerUrl != null ? event.bannerUrl : 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100'}" 
                                                 class="rounded-3 shadow-sm" style="width: 44px; height: 44px; object-fit: cover;">
                                            <span class="fw-medium">${event.title}</span>
                                        </div>
                                    </td>
                                    <td class="text-muted">${event.eventDate}</td>
                                    <td><span class="fw-medium">${event.soldTickets}/${event.totalTickets}</span></td>
                                    <td class="fw-bold text-success">${event.revenue}</td>
                                    <td><span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">Đang bán</span></td>
                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/organizer/events?action=edit&id=${event.eventId}" class="btn btn-sm glass rounded-pill px-3">
                                            <i class="fas fa-edit text-primary"></i>
                                        </a>
                                    </td>
                                </tr>
                                </c:forEach>
                                <!-- Static fallback -->
                                <c:if test="${empty recentEvents}">
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100" class="rounded-3 shadow-sm" style="width: 44px; height: 44px; object-fit: cover;">
                                            <span class="fw-medium">Đêm nhạc Acoustic</span>
                                        </div>
                                    </td>
                                    <td class="text-muted">15/02/2026</td>
                                    <td><span class="fw-medium">450/500</span></td>
                                    <td class="fw-bold text-success">180M</td>
                                    <td><span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">Đang bán</span></td>
                                    <td class="text-center">
                                        <button class="btn btn-sm glass rounded-pill px-3"><i class="fas fa-edit text-primary"></i></button>
                                    </td>
                                </tr>
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=100" class="rounded-3 shadow-sm" style="width: 44px; height: 44px; object-fit: cover;">
                                            <span class="fw-medium">Workshop Marketing</span>
                                        </div>
                                    </td>
                                    <td class="text-muted">20/02/2026</td>
                                    <td><span class="fw-medium">80/100</span></td>
                                    <td class="fw-bold text-success">40M</td>
                                    <td><span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">Đang bán</span></td>
                                    <td class="text-center">
                                        <button class="btn btn-sm glass rounded-pill px-3"><i class="fas fa-edit text-primary"></i></button>
                                    </td>
                                </tr>
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=100" class="rounded-3 shadow-sm" style="width: 44px; height: 44px; object-fit: cover;">
                                            <span class="fw-medium">EDM Night Festival</span>
                                        </div>
                                    </td>
                                    <td class="text-muted">28/02/2026</td>
                                    <td><span class="fw-medium">1200/2000</span></td>
                                    <td class="fw-bold text-success">600M</td>
                                    <td><span class="badge bg-warning text-dark rounded-pill px-3 py-2">Chờ duyệt</span></td>
                                    <td class="text-center">
                                        <button class="btn btn-sm glass rounded-pill px-3"><i class="fas fa-edit text-primary"></i></button>
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

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<script>
document.addEventListener('DOMContentLoaded', () => {
    // Animated counters
    document.querySelectorAll('.counter').forEach(el => {
        const target = parseInt(el.dataset.target);
        const duration = 2000;
        const step = target / (duration / 16);
        let current = 0;
        const timer = setInterval(() => {
            current += step;
            if (current >= target) { current = target; clearInterval(timer); }
            el.textContent = Math.floor(current).toLocaleString('vi-VN');
        }, 16);
    });

    // Sales Performance Chart
    const ctx = document.getElementById('salesChart').getContext('2d');
    const gradient = ctx.createLinearGradient(0, 0, 0, 280);
    gradient.addColorStop(0, 'rgba(147, 51, 234, 0.3)');
    gradient.addColorStop(1, 'rgba(147, 51, 234, 0.01)');

    window.salesChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
            datasets: [{
                label: 'Vé bán',
                data: [45, 72, 58, 95, 82, 120, 105],
                backgroundColor: ['rgba(147,51,234,0.8)', 'rgba(6,182,212,0.8)', 'rgba(16,185,129,0.8)', 'rgba(245,158,11,0.8)', 'rgba(59,130,246,0.8)', 'rgba(239,68,68,0.8)', 'rgba(147,51,234,0.8)'],
                borderRadius: 8,
                borderSkipped: false,
                barPercentage: 0.6
            }, {
                label: 'Doanh thu (triệu)',
                data: [22, 36, 29, 48, 41, 60, 52],
                type: 'line',
                borderColor: '#9333ea',
                backgroundColor: gradient,
                fill: true,
                tension: 0.4,
                borderWidth: 3,
                pointBackgroundColor: '#9333ea',
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                pointRadius: 5,
                pointHoverRadius: 8,
                yAxisID: 'y1'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { mode: 'index', intersect: false },
            plugins: {
                legend: { position: 'top', labels: { usePointStyle: true, padding: 20, font: { family: 'Inter', weight: '500' } } },
                tooltip: { backgroundColor: 'rgba(255,255,255,0.95)', titleColor: '#1e293b', bodyColor: '#64748b', borderColor: 'rgba(0,0,0,0.05)', borderWidth: 1, cornerRadius: 12, padding: 12, boxPadding: 6 }
            },
            scales: {
                x: { grid: { display: false }, ticks: { font: { family: 'Inter' } } },
                y: { grid: { color: 'rgba(0,0,0,0.04)' }, ticks: { font: { family: 'Inter' } }, beginAtZero: true },
                y1: { position: 'right', grid: { display: false }, ticks: { font: { family: 'Inter' } }, beginAtZero: true }
            }
        }
    });

    // Ticket Type Doughnut
    const ctx2 = document.getElementById('ticketTypeChart').getContext('2d');
    new Chart(ctx2, {
        type: 'doughnut',
        data: {
            labels: ['VIP', 'Standard', 'Economy', 'Group'],
            datasets: [{
                data: [30, 40, 20, 10],
                backgroundColor: ['#9333ea', '#3b82f6', '#10b981', '#f59e0b'],
                borderWidth: 0,
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '65%',
            plugins: {
                legend: { position: 'bottom', labels: { usePointStyle: true, padding: 15, font: { family: 'Inter', size: 12, weight: '500' } } },
                tooltip: { backgroundColor: 'rgba(255,255,255,0.95)', titleColor: '#1e293b', bodyColor: '#64748b', borderColor: 'rgba(0,0,0,0.05)', borderWidth: 1, cornerRadius: 12, padding: 12, boxPadding: 6 }
            }
        }
    });
});

function updateOrgChart(period) {
    const dataMap = {
        week: { labels: ['T2','T3','T4','T5','T6','T7','CN'], d1: [45,72,58,95,82,120,105], d2: [22,36,29,48,41,60,52] },
        month: { labels: ['Tuần 1','Tuần 2','Tuần 3','Tuần 4'], d1: [280,350,310,420], d2: [140,175,155,210] },
        quarter: { labels: ['Tháng 1','Tháng 2','Tháng 3'], d1: [1100,1350,1500], d2: [550,680,750] }
    };
    const d = dataMap[period];
    window.salesChart.data.labels = d.labels;
    window.salesChart.data.datasets[0].data = d.d1;
    window.salesChart.data.datasets[1].data = d.d2;
    window.salesChart.update();

    document.querySelectorAll('.btn-group .btn').forEach(b => b.classList.remove('active'));
    event.target.classList.add('active');
}
</script>

<jsp:include page="../footer.jsp" />
