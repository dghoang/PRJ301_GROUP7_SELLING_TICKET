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
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown flex-wrap gap-3">
                <h2 class="fw-bold mb-0"><i class="fas fa-chart-bar text-primary me-2"></i>Thống kê chi tiết</h2>
                <div class="d-flex align-items-center gap-3">
                    <select class="form-select rounded-pill px-3 glass-strong border-0 fw-medium" id="eventFilter"
                            style="min-width: 240px;" onchange="onEventFilterChange()">
                        <option value="0">📊 Tất cả sự kiện</option>
                        <c:forEach var="ev" items="${myEvents}">
                            <option value="${ev.eventId}" ${selectedEventId == ev.eventId ? 'selected' : ''}>${ev.title}</option>
                        </c:forEach>
                    </select>
                    <button class="btn glass rounded-pill px-4 hover-lift fw-medium">
                        <i class="fas fa-download me-2 text-primary"></i>Xuất báo cáo
                    </button>
                </div>
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

            <!-- ====== SETTLEMENT BREAKDOWN (Đối soát doanh thu) ====== -->
            <div class="col-12 animate-on-scroll">
                <div class="card glass-strong border-0 rounded-4">
                    <div class="card-body p-4">
                        <h5 class="fw-bold mb-3"><i class="fas fa-balance-scale text-primary me-2"></i>Chi tiết Doanh thu & Đối soát</h5>
                        <p class="text-muted small mb-3">Tách bạch rõ: [Giá vé] − [Voucher Sự kiện] − [Voucher Hệ thống] = [Doanh thu thực tế]</p>
                        <div class="row g-3">
                            <div class="col-md">
                                <div class="text-center p-3 rounded-4" style="background: rgba(16,185,129,0.06);">
                                    <div class="fw-bold text-success fs-5"><fmt:formatNumber value="${totalFaceValue}" type="number" maxFractionDigits="0" groupingUsed="true"/>đ</div>
                                    <small class="text-muted">Giá vé gốc (Face Value)</small>
                                </div>
                            </div>
                            <div class="col-md">
                                <div class="text-center p-3 rounded-4" style="background: rgba(245,158,11,0.06);">
                                    <div class="fw-bold text-warning fs-5">-<fmt:formatNumber value="${totalEventDiscount}" type="number" maxFractionDigits="0" groupingUsed="true"/>đ</div>
                                    <small class="text-muted">Voucher Sự kiện (bạn chịu)</small>
                                </div>
                            </div>
                            <div class="col-md">
                                <div class="text-center p-3 rounded-4" style="background: rgba(99,102,241,0.06);">
                                    <div class="fw-bold text-primary fs-5"><fmt:formatNumber value="${totalSystemDiscount}" type="number" maxFractionDigits="0" groupingUsed="true"/>đ</div>
                                    <small class="text-muted">Voucher Hệ thống (HT trợ giá)</small>
                                </div>
                            </div>
                            <div class="col-md">
                                <div class="text-center p-3 rounded-4" style="background: rgba(239,68,68,0.06);">
                                    <div class="fw-bold text-danger fs-5">-<fmt:formatNumber value="${totalPlatformFee}" type="number" maxFractionDigits="0" groupingUsed="true"/>đ</div>
                                    <small class="text-muted">Phí sàn</small>
                                </div>
                            </div>
                            <div class="col-md">
                                <div class="text-center p-3 rounded-4" style="background: rgba(6,182,212,0.08);">
                                    <div class="fw-bold fs-5" style="color:#06b6d4;"><fmt:formatNumber value="${totalPayout}" type="number" maxFractionDigits="0" groupingUsed="true"/>đ</div>
                                    <small class="text-muted fw-medium">Doanh thu thực nhận</small>
                                </div>
                            </div>
                        </div>
                        <div class="mt-3 p-3 rounded-3" style="background: rgba(99,102,241,0.04); border: 1px dashed rgba(99,102,241,0.2);">
                            <small class="text-muted">
                                <i class="fas fa-info-circle text-primary me-1"></i>
                                <strong>Ghi chú:</strong> Khi khách dùng voucher hệ thống, bạn vẫn nhận đủ giá vé gốc (trừ phí sàn). 
                                Khoản trợ giá do hệ thống chi trả, không trừ vào doanh thu của bạn.
                            </small>
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
                            <h5 class="fw-bold mb-0"><i class="fas fa-chart-line text-primary me-2"></i>Doanh thu & Chi phí</h5>
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
                            <h5 class="fw-bold mb-0"><i class="fas fa-ticket-alt text-primary me-2"></i>Tỷ lệ bán theo loại vé</h5>
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
                            <h5 class="fw-bold mb-0"><i class="fas fa-clock text-primary me-2"></i>Giờ mua vé phổ biến</h5>
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
                            <h5 class="fw-bold mb-0"><i class="fas fa-trophy text-primary me-2"></i>Hiệu suất bán vé theo sự kiện</h5>
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
                    <h5 class="fw-bold mb-0"><i class="fas fa-trophy text-warning me-2"></i>Hiệu suất sự kiện</h5>
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
const API_BASE = '${pageContext.request.contextPath}/organizer/statistics/chart-data';
const CHART_COLORS = ['#10b981', '#3b82f6', '#f59e0b', '#ef4444', '#06b6d4', '#8b5cf6', '#ec4899', '#14b8a6'];

document.addEventListener('DOMContentLoaded', () => {
    // Counters animation
    document.querySelectorAll('.counter').forEach(el => {
        const target = parseInt(el.dataset.target) || 0;
        if (target === 0) { el.textContent = '0'; return; }
        const duration = 2000;
        const step = target / (duration / 16);
        let current = 0;
        const timer = setInterval(() => {
            current += step;
            if (current >= target) { current = target; clearInterval(timer); }
            el.textContent = Math.floor(current).toLocaleString('vi-VN');
        }, 16);
    });

    loadRevenueChart(7);
    loadTicketRatioChart();
    loadHourlyChart();
    loadEventPerformanceChart();
});

// ========== REVENUE CHART ==========
var currentEventId = Number('<c:out value="${selectedEventId != null ? selectedEventId : 0}" />');

function loadRevenueChart(days) {
    var url = API_BASE + '?type=revenue&days=' + days;
    if (currentEventId > 0) url += '&eventId=' + currentEventId;
    fetch(url)
        .then(r => r.json())
        .then(data => {
            const labels = data.map(d => {
                const date = new Date(d.date);
                return date.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' });
            });
            const revenues = data.map(d => d.revenue / 1000000); // Convert to triệu
            const ticketCounts = data.map(d => d.ticketCount || 0);

            const ctx = document.getElementById('revenueCostChart').getContext('2d');
            const gradient = ctx.createLinearGradient(0, 0, 0, 300);
            gradient.addColorStop(0, 'rgba(16, 185, 129, 0.3)');
            gradient.addColorStop(1, 'rgba(16, 185, 129, 0.01)');

            if (window.statsChart) window.statsChart.destroy();

            window.statsChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels.length > 0 ? labels : ['Chưa có dữ liệu'],
                    datasets: [{
                        label: 'Doanh thu (triệu đ)',
                        data: revenues.length > 0 ? revenues : [0],
                        borderColor: '#10b981',
                        backgroundColor: gradient,
                        fill: true,
                        tension: 0.4,
                        borderWidth: 3,
                        pointBackgroundColor: '#10b981',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2,
                        pointRadius: 5,
                        pointHoverRadius: 8
                    }, {
                        label: 'Số vé bán',
                        data: ticketCounts.length > 0 ? ticketCounts : [0],
                        borderColor: '#3b82f6',
                        borderDash: [5, 5],
                        tension: 0.4,
                        borderWidth: 2,
                        pointRadius: 3,
                        fill: false
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'top', labels: { usePointStyle: true, padding: 20, font: { family: 'Inter', weight: '500' } } },
                        tooltip: { backgroundColor: 'rgba(255,255,255,0.95)', titleColor: '#1e293b', bodyColor: '#64748b', borderColor: 'rgba(0,0,0,0.05)', borderWidth: 1, cornerRadius: 12, padding: 12, boxPadding: 6 }
                    },
                    scales: { x: { grid: { display: false } }, y: { grid: { color: 'rgba(0,0,0,0.04)' }, beginAtZero: true } }
                }
            });
        })
        .catch(() => console.warn('Không thể tải dữ liệu doanh thu'));
}

// ========== TICKET RATIO CHART ==========
function loadTicketRatioChart() {
    fetch(API_BASE + '?type=tickets')
        .then(r => r.json())
        .then(data => {
            const labels = data.map(d => d.name || 'Không rõ');
            const counts = data.map(d => d.count || 0);

            new Chart(document.getElementById('ticketRatioChart'), {
                type: 'doughnut',
                data: {
                    labels: labels.length > 0 ? labels : ['Chưa có dữ liệu'],
                    datasets: [{
                        data: counts.length > 0 ? counts : [1],
                        backgroundColor: labels.length > 0
                            ? CHART_COLORS.slice(0, labels.length)
                            : ['rgba(148,163,184,0.3)'],
                        borderWidth: 0,
                        hoverOffset: 8
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    cutout: '65%',
                    plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, padding: 12, font: { family: 'Inter', size: 12, weight: '500' } } } }
                }
            });
        })
        .catch(() => console.warn('Không thể tải dữ liệu phân phối vé'));
}

// ========== HOURLY CHART ==========
function loadHourlyChart() {
    fetch(API_BASE + '?type=hourly')
        .then(r => r.json())
        .then(data => {
            // Fill all 24 hours (0-23), defaulting to 0
            const hourlyData = new Array(24).fill(0);
            data.forEach(d => { hourlyData[d.hour] = d.count; });

            // Show only active hours (6h - 23h)
            const activeHours = [];
            const activeCounts = [];
            for (let h = 6; h <= 23; h++) {
                activeHours.push(h + 'h');
                activeCounts.push(hourlyData[h]);
            }

            new Chart(document.getElementById('hourlyChart'), {
                type: 'bar',
                data: {
                    labels: activeHours,
                    datasets: [{
                        label: 'Đơn hàng',
                        data: activeCounts,
                        backgroundColor: (ctx) => {
                            const max = Math.max(...activeCounts, 1);
                            const ratio = ctx.raw / max;
                            return ratio > 0.7 ? 'rgba(16,185,129,0.8)'
                                 : ratio > 0.4 ? 'rgba(59,130,246,0.6)'
                                 : 'rgba(148,163,184,0.4)';
                        },
                        borderRadius: 6,
                        barPercentage: 0.7
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { x: { grid: { display: false } }, y: { grid: { color: 'rgba(0,0,0,0.04)' }, beginAtZero: true } }
                }
            });
        })
        .catch(() => console.warn('Không thể tải dữ liệu giờ mua vé'));
}

// ========== EVENT PERFORMANCE (4th chart: replaces source channel) ==========
function loadEventPerformanceChart() {
    // Use data from the table (already server-rendered)
    const rows = document.querySelectorAll('.table-glass tbody tr');
    const labels = [];
    const sold = [];
    const total = [];

    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length >= 3) {
            labels.push(cells[0].textContent.trim().substring(0, 20));
            const parts = cells[2].textContent.trim().split('/');
            sold.push(parseInt(parts[0]) || 0);
            total.push(parseInt(parts[1]) || 0);
        }
    });

    if (labels.length === 0) {
        labels.push('Chưa có sự kiện');
        sold.push(0);
        total.push(1);
    }

    new Chart(document.getElementById('sourceChart'), {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Vé đã bán',
                data: sold,
                backgroundColor: 'rgba(16,185,129,0.7)',
                borderRadius: 6
            }, {
                label: 'Tổng vé',
                data: total,
                backgroundColor: 'rgba(59,130,246,0.2)',
                borderRadius: 6
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            indexAxis: 'y',
            plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, padding: 12, font: { family: 'Inter', size: 12, weight: '500' } } } },
            scales: { x: { grid: { color: 'rgba(0,0,0,0.04)' }, beginAtZero: true }, y: { grid: { display: false } } }
        }
    });
}

function updateStatsChart(range) {
    const daysMap = { '7d': 7, '30d': 30, '90d': 90 };
    loadRevenueChart(daysMap[range] || 7);
    document.querySelectorAll('.btn-group .btn').forEach(b => b.classList.remove('active'));
    event.target.classList.add('active');
}

// ========== EVENT FILTER ==========
var origRevenue = Number('<c:out value="${totalRevenue != null ? totalRevenue : 0}" />');
var origOrders = Number('<c:out value="${totalOrders != null ? totalOrders : 0}" />');
var origEvents = Number('<c:out value="${totalEvents != null ? totalEvents : 0}" />');
var origAvg = origOrders > 0 ? origRevenue / origOrders : 0;

function onEventFilterChange() {
    var sel = document.getElementById('eventFilter');
    currentEventId = parseInt(sel.value) || 0;

    if (currentEventId === 0) {
        updateCards(origRevenue, origOrders, origEvents, origAvg);
        loadRevenueChart(7);
        return;
    }

    fetch('${pageContext.request.contextPath}/organizer/statistics/event-stats?eventId=' + currentEventId)
        .then(r => r.json())
        .then(data => {
            var avg = data.paidOrders > 0 ? data.revenue / data.paidOrders : 0;
            updateCards(data.revenue, data.totalOrders, data.totalTickets, avg,
                        data.paidOrders, data.checkedIn);
            loadRevenueChart(7);
        })
        .catch(() => console.warn('Không thể tải thống kê sự kiện'));
}

function updateCards(revenue, orders, events, avg, paidOrders, checkedIn) {
    var cards = document.querySelectorAll('.row.g-4.mb-4 .card-body');
    if (cards.length >= 4) {
        // Card 1: Revenue
        cards[0].querySelector('h3').textContent = formatVN(revenue) + ' đ';
        // Card 2: Orders
        cards[1].querySelector('h3').textContent = formatVN(orders);
        if (currentEventId > 0 && paidOrders !== undefined) {
            cards[1].querySelector('small.text-info').innerHTML = '<i class="fas fa-check-circle"></i> ' + paidOrders + ' đã thanh toán';
        } else {
            cards[1].querySelector('small.text-info').innerHTML = '<i class="fas fa-shopping-cart"></i> Tất cả trạng thái';
        }
        // Card 3: Events/Tickets
        cards[2].querySelector('h3').textContent = formatVN(events);
        if (currentEventId > 0 && checkedIn !== undefined) {
            cards[2].querySelector('small.text-muted').textContent = 'Tổng vé';
            cards[2].querySelector('small.text-info').innerHTML = '<i class="fas fa-user-check"></i> ' + checkedIn + ' đã check-in';
        } else {
            cards[2].querySelector('small.text-muted').textContent = 'Tổng sự kiện';
            cards[2].querySelector('small.text-info').innerHTML = '<i class="fas fa-calendar"></i> Đang quản lý';
        }
        // Card 4: Average order value
        cards[3].querySelector('h3').textContent = formatVN(Math.round(avg)) + ' đ';
    }
}

function formatVN(n) {
    return Math.round(n).toLocaleString('vi-VN');
}
</script>

<jsp:include page="../footer.jsp" />
