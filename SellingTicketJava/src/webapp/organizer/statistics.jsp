<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="statistics"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <h2 class="fw-bold mb-0">📊 Thống kê chi tiết</h2>
                <button class="btn glass rounded-pill px-4 hover-lift fw-medium">
                    <i class="fas fa-download me-2 text-primary"></i>Xuất báo cáo
                </button>
            </div>

            <!-- Stats Row -->
            <div class="row g-4 mb-4">
                <div class="col-md-6 col-xl-3 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 hover-lift h-100">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #9333ea, #a855f7);">
                                <i class="fas fa-eye fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0"><fmt:formatNumber value="${totalRevenue}" type="number" groupingUsed="true" /> đ</h3>
                                <small class="text-muted">Tổng doanh thu</small>
                                <div class="mt-1"><small class="text-success fw-medium"><i class="fas fa-chart-line"></i> Từ đơn đã thanh toán</small></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 hover-lift h-100">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-percentage fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0 counter" data-target="${totalOrders}">0</h3>
                                <small class="text-muted">Tổng đơn hàng</small>
                                <div class="mt-1"><small class="text-info fw-medium"><i class="fas fa-shopping-cart"></i> Tất cả trạng thái</small></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 hover-lift h-100">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #f59e0b, #f97316);">
                                <i class="fas fa-wallet fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0 counter" data-target="${totalEvents}">0</h3>
                                <small class="text-muted">Tổng sự kiện</small>
                                <div class="mt-1"><small class="text-info fw-medium"><i class="fas fa-calendar"></i> Đang quản lý</small></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-3">
                    <div class="card glass-strong border-0 rounded-4 hover-lift h-100">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #3b82f6, #6366f1);">
                                <i class="fas fa-star fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0"><fmt:formatNumber value="${totalRevenue / (totalOrders > 0 ? totalOrders : 1)}" type="number" maxFractionDigits="0" groupingUsed="true" /> đ</h3>
                                <small class="text-muted">Giá trị đơn TB</small>
                                <div class="mt-1"><small class="text-success fw-medium"><i class="fas fa-star"></i> Trung bình mỗi đơn</small></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center pt-4 px-4">
                            <h5 class="fw-bold mb-0">📈 Doanh thu & Chi phí</h5>
                            <div class="btn-group btn-group-sm">
                                <button class="btn btn-outline-primary rounded-start-pill active" onclick="updateStatsChart('7d')">7 ngày</button>
                                <button class="btn btn-outline-primary" onclick="updateStatsChart('30d')">30 ngày</button>
                                <button class="btn btn-outline-primary rounded-end-pill" onclick="updateStatsChart('90d')">90 ngày</button>
                            </div>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <canvas id="revenueCostChart" height="300"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0">🎫 Tỷ lệ bán theo loại vé</h5>
                        </div>
                        <div class="card-body d-flex align-items-center justify-content-center px-4 pb-4">
                            <canvas id="ticketRatioChart" height="260"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4 mb-4">
                <!-- Hourly pattern -->
                <div class="col-lg-6 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0">🕐 Giờ mua vé phổ biến</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <canvas id="hourlyChart" height="250"></canvas>
                        </div>
                    </div>
                </div>
                <!-- Source channel -->
                <div class="col-lg-6 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0">📱 Nguồn truy cập</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <canvas id="sourceChart" height="250"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Event Performance Table -->
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-header bg-transparent border-0 pt-4 px-4">
                    <h5 class="fw-bold mb-0">🏆 Hiệu suất sự kiện</h5>
                </div>
                <div class="card-body px-4 pb-4">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Sự kiện</th>
                                    <th>Lượt xem</th>
                                    <th>Vé bán / Tổng</th>
                                    <th>Tỉ lệ bán</th>
                                    <th>Doanh thu</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="stat" items="${eventStats}">
                                <c:set var="evt" value="${stat.event}" />
                                <c:set var="pct" value="${evt.totalTickets > 0 ? (evt.soldTickets * 100 / evt.totalTickets) : 0}" />
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td class="fw-medium">${evt.title}</td>
                                    <td>${stat.orderCount}</td>
                                    <td>${evt.soldTickets} / ${evt.totalTickets}</td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="progress flex-grow-1" style="height: 8px; border-radius: 4px; background: rgba(0,0,0,0.05);">
                                                <div class="progress-bar" style="width: ${pct}%; background: linear-gradient(90deg, ${pct >= 70 ? '#10b981, #06b6d4' : '#f59e0b, #f97316'}); border-radius: 4px;"></div>
                                            </div>
                                            <small class="fw-bold ${pct >= 70 ? 'text-success' : 'text-warning'}">${pct}%</small>
                                        </div>
                                    </td>
                                    <td class="fw-bold text-primary"><fmt:formatNumber value="${stat.revenue}" type="number" groupingUsed="true" /> đ</td>
                                </tr>
                                </c:forEach>
                                <c:if test="${empty eventStats}">
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">
                                        <i class="fas fa-chart-bar fa-2x mb-2 opacity-25"></i>
                                        <p class="mb-0">Chưa có dữ liệu thống kê</p>
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

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', () => {
    // Counters
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

    // Revenue & Cost
    const ctx1 = document.getElementById('revenueCostChart').getContext('2d');
    const g1 = ctx1.createLinearGradient(0, 0, 0, 300);
    g1.addColorStop(0, 'rgba(16, 185, 129, 0.3)');
    g1.addColorStop(1, 'rgba(16, 185, 129, 0.01)');

    window.statsChart = new Chart(ctx1, {
        type: 'line',
        data: {
            labels: ['T2','T3','T4','T5','T6','T7','CN'],
            datasets: [{
                label: 'Doanh thu (triệu)',
                data: [45, 72, 58, 95, 82, 120, 105],
                borderColor: '#10b981',
                backgroundColor: g1,
                fill: true,
                tension: 0.4,
                borderWidth: 3,
                pointBackgroundColor: '#10b981',
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                pointRadius: 5,
                pointHoverRadius: 8
            }, {
                label: 'Chi phí (triệu)',
                data: [15, 22, 18, 30, 25, 35, 32],
                borderColor: '#ef4444',
                borderDash: [5, 5],
                tension: 0.4,
                borderWidth: 2,
                pointRadius: 3,
                fill: false
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { position: 'top', labels: { usePointStyle: true, padding: 20, font: { family: 'Inter', weight: '500' } } }, tooltip: { backgroundColor: 'rgba(255,255,255,0.95)', titleColor: '#1e293b', bodyColor: '#64748b', borderColor: 'rgba(0,0,0,0.05)', borderWidth: 1, cornerRadius: 12, padding: 12, boxPadding: 6 } },
            scales: { x: { grid: { display: false } }, y: { grid: { color: 'rgba(0,0,0,0.04)' }, beginAtZero: true } }
        }
    });

    // Ticket Ratio
    new Chart(document.getElementById('ticketRatioChart'), {
        type: 'doughnut',
        data: {
            labels: ['VIP', 'Standard', 'Economy', 'Group', 'Early Bird'],
            datasets: [{ data: [25, 35, 22, 8, 10], backgroundColor: ['#9333ea', '#3b82f6', '#10b981', '#f59e0b', '#06b6d4'], borderWidth: 0, hoverOffset: 8 }]
        },
        options: { responsive: true, maintainAspectRatio: false, cutout: '65%', plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, padding: 12, font: { family: 'Inter', size: 12, weight: '500' } } } } }
    });

    // Hourly Pattern
    new Chart(document.getElementById('hourlyChart'), {
        type: 'bar',
        data: {
            labels: ['6h','8h','10h','12h','14h','16h','18h','20h','22h','0h'],
            datasets: [{
                label: 'Đơn hàng',
                data: [5, 15, 35, 45, 30, 25, 55, 80, 65, 20],
                backgroundColor: (ctx) => {
                    const val = ctx.raw;
                    return val > 50 ? 'rgba(147,51,234,0.8)' : val > 30 ? 'rgba(59,130,246,0.6)' : 'rgba(148,163,184,0.4)';
                },
                borderRadius: 6,
                barPercentage: 0.7
            }]
        },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { x: { grid: { display: false } }, y: { grid: { color: 'rgba(0,0,0,0.04)' }, beginAtZero: true } } }
    });

    // Source Channel
    new Chart(document.getElementById('sourceChart'), {
        type: 'polarArea',
        data: {
            labels: ['Website', 'Facebook', 'Google', 'Zalo', 'Khác'],
            datasets: [{ data: [40, 25, 18, 12, 5], backgroundColor: ['rgba(147,51,234,0.7)', 'rgba(59,130,246,0.7)', 'rgba(16,185,129,0.7)', 'rgba(245,158,11,0.7)', 'rgba(148,163,184,0.5)'], borderWidth: 0 }]
        },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, padding: 12, font: { family: 'Inter', size: 12, weight: '500' } } } } }
    });
});

function updateStatsChart(range) {
    const dataMap = {
        '7d': { labels: ['T2','T3','T4','T5','T6','T7','CN'], d1: [45,72,58,95,82,120,105], d2: [15,22,18,30,25,35,32] },
        '30d': { labels: ['Tuần 1','Tuần 2','Tuần 3','Tuần 4'], d1: [280,350,310,420], d2: [85,110,95,130] },
        '90d': { labels: ['Tháng 1','Tháng 2','Tháng 3'], d1: [1100,1350,1500], d2: [340,420,460] }
    };
    const d = dataMap[range];
    window.statsChart.data.labels = d.labels;
    window.statsChart.data.datasets[0].data = d.d1;
    window.statsChart.data.datasets[1].data = d.d2;
    window.statsChart.update();
    document.querySelectorAll('.btn-group .btn').forEach(b => b.classList.remove('active'));
    event.target.classList.add('active');
}
</script>

<jsp:include page="../footer.jsp" />
