<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="reports"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <h2 class="fw-bold mb-0">📊 Báo cáo thống kê</h2>
                <button class="btn glass rounded-pill px-4 hover-lift fw-medium">
                    <i class="fas fa-download me-2 text-primary"></i>Xuất PDF
                </button>
            </div>

            <!-- Date Filter -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body d-flex gap-3 align-items-center flex-wrap p-3">
                    <span class="fw-medium ms-1"><i class="far fa-calendar-alt me-2 text-primary"></i>Thời gian:</span>
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-primary rounded-start-pill" onclick="setDateRange('today')">Hôm nay</button>
                        <button class="btn btn-outline-primary" onclick="setDateRange('week')">7 ngày</button>
                        <button class="btn btn-outline-primary active" onclick="setDateRange('month')">30 ngày</button>
                        <button class="btn btn-outline-primary rounded-end-pill" onclick="setDateRange('year')">Năm</button>
                    </div>
                    <div class="ms-auto d-flex gap-2 align-items-center">
                        <input type="date" class="form-control form-control-sm glass rounded-3" value="2026-01-01" style="max-width: 150px;">
                        <span class="text-muted">→</span>
                        <input type="date" class="form-control form-control-sm glass rounded-3" value="2026-02-10" style="max-width: 150px;">
                        <button class="btn btn-gradient btn-sm rounded-pill px-3">Áp dụng</button>
                    </div>
                </div>
            </div>

            <!-- Stats Row -->
            <div class="row g-4 mb-4">
                <div class="col-md-6 col-xl-3 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4 hover-lift h-100">
                        <div class="dash-icon-box mx-auto mb-3" style="background: linear-gradient(135deg, #9333ea, #a855f7);">
                            <i class="fas fa-dollar-sign fa-lg text-white"></i>
                        </div>
                        <h2 class="fw-bold mb-1 counter" data-target="2500" data-suffix="M">0</h2>
                        <p class="text-muted small mb-1">Tổng doanh thu</p>
                        <small class="text-success fw-medium"><i class="fas fa-arrow-up"></i> +15% so với kỳ trước</small>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4 hover-lift h-100">
                        <div class="dash-icon-box mx-auto mb-3" style="background: linear-gradient(135deg, #10b981, #06b6d4);">
                            <i class="fas fa-ticket-alt fa-lg text-white"></i>
                        </div>
                        <h2 class="fw-bold mb-1 counter" data-target="45892">0</h2>
                        <p class="text-muted small mb-1">Vé bán ra</p>
                        <small class="text-success fw-medium"><i class="fas fa-arrow-up"></i> +8% so với kỳ trước</small>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4 hover-lift h-100">
                        <div class="dash-icon-box mx-auto mb-3" style="background: linear-gradient(135deg, #f59e0b, #f97316);">
                            <i class="fas fa-calendar-check fa-lg text-white"></i>
                        </div>
                        <h2 class="fw-bold mb-1 counter" data-target="156">0</h2>
                        <p class="text-muted small mb-1">Sự kiện diễn ra</p>
                        <small class="text-success fw-medium"><i class="fas fa-arrow-up"></i> +12 events</small>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-3">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4 hover-lift h-100">
                        <div class="dash-icon-box mx-auto mb-3" style="background: linear-gradient(135deg, #3b82f6, #6366f1);">
                            <i class="fas fa-user-plus fa-lg text-white"></i>
                        </div>
                        <h2 class="fw-bold mb-1 counter" data-target="2458">0</h2>
                        <p class="text-muted small mb-1">Users mới</p>
                        <small class="text-success fw-medium"><i class="fas fa-arrow-up"></i> +20% growth</small>
                    </div>
                </div>
            </div>

            <!-- Charts -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0">📈 Doanh thu theo thời gian</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <canvas id="revenueTimeChart" height="300"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0">🎯 Doanh thu theo danh mục</h5>
                        </div>
                        <div class="card-body d-flex align-items-center justify-content-center px-4 pb-4">
                            <canvas id="categoryRevenueChart" height="260"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <!-- Top Events -->
                <div class="col-lg-6 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0">🏆 Top sự kiện bán chạy</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="d-flex align-items-center justify-content-center rounded-circle fw-bold text-white" style="width: 32px; height: 32px; background: linear-gradient(135deg, #f59e0b, #f97316); font-size: 0.85rem;">1</div>
                                    <div>
                                        <p class="fw-medium mb-0">Đêm nhạc Acoustic</p>
                                        <small class="text-muted">Live Nation</small>
                                    </div>
                                </div>
                                <span class="fw-bold text-primary">5,200 vé</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="d-flex align-items-center justify-content-center rounded-circle fw-bold text-white" style="width: 32px; height: 32px; background: linear-gradient(135deg, #94a3b8, #64748b); font-size: 0.85rem;">2</div>
                                    <div>
                                        <p class="fw-medium mb-0">Tech Conference 2026</p>
                                        <small class="text-muted">TechVN</small>
                                    </div>
                                </div>
                                <span class="fw-bold text-primary">3,800 vé</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="d-flex align-items-center justify-content-center rounded-circle fw-bold text-white" style="width: 32px; height: 32px; background: linear-gradient(135deg, #b45309, #92400e); font-size: 0.85rem;">3</div>
                                    <div>
                                        <p class="fw-medium mb-0">EDM Festival</p>
                                        <small class="text-muted">Ravolution</small>
                                    </div>
                                </div>
                                <span class="fw-bold text-primary">2,500 vé</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="d-flex align-items-center justify-content-center rounded-circle fw-bold text-muted bg-light" style="width: 32px; height: 32px; font-size: 0.85rem;">4</div>
                                    <div>
                                        <p class="fw-medium mb-0">Workshop UX Design</p>
                                        <small class="text-muted">DesignVN</small>
                                    </div>
                                </div>
                                <span class="fw-bold text-primary">1,800 vé</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="d-flex align-items-center justify-content-center rounded-circle fw-bold text-muted bg-light" style="width: 32px; height: 32px; font-size: 0.85rem;">5</div>
                                    <div>
                                        <p class="fw-medium mb-0">Marathon Sài Gòn</p>
                                        <small class="text-muted">SportsVN</small>
                                    </div>
                                </div>
                                <span class="fw-bold text-primary">1,500 vé</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- User Growth -->
                <div class="col-lg-6 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0">👥 Tăng trưởng người dùng</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <canvas id="userGrowthChart" height="280"></canvas>
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
document.addEventListener('DOMContentLoaded', () => {
    // Counters
    document.querySelectorAll('.counter').forEach(el => {
        const target = parseInt(el.dataset.target);
        const suffix = el.dataset.suffix || '';
        const duration = 2000;
        const step = target / (duration / 16);
        let current = 0;
        const timer = setInterval(() => {
            current += step;
            if (current >= target) { current = target; clearInterval(timer); }
            el.textContent = Math.floor(current).toLocaleString('vi-VN') + suffix;
        }, 16);
    });

    // Revenue Time Chart
    const ctx1 = document.getElementById('revenueTimeChart').getContext('2d');
    const g1 = ctx1.createLinearGradient(0, 0, 0, 300);
    g1.addColorStop(0, 'rgba(147, 51, 234, 0.25)');
    g1.addColorStop(1, 'rgba(147, 51, 234, 0.01)');
    
    new Chart(ctx1, {
        type: 'line',
        data: {
            labels: ['T1','T2','T3','T4','T5','T6','T7','T8','T9','T10','T11','T12'],
            datasets: [{
                label: 'Doanh thu 2026 (tỷ)',
                data: [0.8, 1.2, 1.5, 1.8, 2.1, 1.9, 2.4, 2.8, 2.6, 3.1, 3.5, 4.0],
                borderColor: '#9333ea',
                backgroundColor: g1,
                fill: true,
                tension: 0.4,
                borderWidth: 3,
                pointBackgroundColor: '#9333ea',
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                pointRadius: 5,
                pointHoverRadius: 8
            }, {
                label: 'Doanh thu 2025 (tỷ)',
                data: [0.5, 0.8, 1.0, 1.3, 1.5, 1.4, 1.8, 2.1, 2.0, 2.4, 2.8, 3.2],
                borderColor: '#94a3b8',
                borderDash: [5, 5],
                tension: 0.4,
                borderWidth: 2,
                pointRadius: 0,
                fill: false
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { position: 'top', labels: { usePointStyle: true, padding: 20, font: { family: 'Inter', weight: '500' } } }, tooltip: { backgroundColor: 'rgba(255,255,255,0.95)', titleColor: '#1e293b', bodyColor: '#64748b', borderColor: 'rgba(0,0,0,0.05)', borderWidth: 1, cornerRadius: 12, padding: 12, boxPadding: 6 } },
            scales: { x: { grid: { display: false } }, y: { grid: { color: 'rgba(0,0,0,0.04)' }, beginAtZero: true } }
        }
    });

    // Category Revenue Doughnut
    new Chart(document.getElementById('categoryRevenueChart'), {
        type: 'doughnut',
        data: {
            labels: ['Âm nhạc', 'Workshop', 'Thể thao', 'Nghệ thuật', 'Khác'],
            datasets: [{ data: [45, 25, 18, 7, 5], backgroundColor: ['#9333ea', '#06b6d4', '#10b981', '#f59e0b', '#3b82f6'], borderWidth: 0, hoverOffset: 8 }]
        },
        options: { responsive: true, maintainAspectRatio: false, cutout: '65%', plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, padding: 12, font: { family: 'Inter', size: 12, weight: '500' } } } } }
    });

    // User Growth Bar
    const ctx3 = document.getElementById('userGrowthChart').getContext('2d');
    new Chart(ctx3, {
        type: 'bar',
        data: {
            labels: ['T1','T2','T3','T4','T5','T6','T7','T8','T9','T10','T11','T12'],
            datasets: [{
                label: 'Người dùng mới',
                data: [150, 220, 180, 290, 310, 280, 350, 420, 380, 450, 520, 600],
                backgroundColor: 'rgba(59, 130, 246, 0.7)',
                borderRadius: 6,
                barPercentage: 0.6
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false }, tooltip: { backgroundColor: 'rgba(255,255,255,0.95)', titleColor: '#1e293b', bodyColor: '#64748b', borderColor: 'rgba(0,0,0,0.05)', borderWidth: 1, cornerRadius: 12, padding: 12 } },
            scales: { x: { grid: { display: false } }, y: { grid: { color: 'rgba(0,0,0,0.04)' }, beginAtZero: true } }
        }
    });
});

function setDateRange(range) {
    document.querySelectorAll('.btn-group .btn').forEach(b => b.classList.remove('active'));
    event.target.classList.add('active');
}
</script>

<jsp:include page="../footer.jsp" />
