<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="reports"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-chart-bar text-primary me-2"></i>Báo cáo hệ thống</h2>
                    <p class="text-muted mb-0">Tổng quan hiệu suất và thống kê toàn hệ thống</p>
                </div>
                <div class="d-flex gap-2">
                    <!-- Date filter -->
                    <div class="btn-group btn-group-sm">
                        <a href="${pageContext.request.contextPath}/admin/reports?period=week"
                           class="btn btn-outline-primary rounded-start-pill ${empty param.period || param.period == 'week' ? 'active' : ''}">7 ngày</a>
                        <a href="${pageContext.request.contextPath}/admin/reports?period=month"
                           class="btn btn-outline-primary ${param.period == 'month' ? 'active' : ''}">30 ngày</a>
                        <a href="${pageContext.request.contextPath}/admin/reports?period=year"
                           class="btn btn-outline-primary rounded-end-pill ${param.period == 'year' ? 'active' : ''}">365 ngày</a>
                    </div>
                    <!-- CSV Export -->
                    <a href="${pageContext.request.contextPath}/admin/reports/export" class="btn btn-sm btn-success rounded-pill px-3">
                        <i class="fas fa-download me-1"></i>Xuất CSV
                    </a>
                </div>
            </div>

            <!-- KPI Cards -->
            <div class="row g-4 mb-4">
                <div class="col-md-6 col-xl-3 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-coins fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">
                                    <fmt:formatNumber value="${totalRevenue}" type="number" groupingUsed="true"/>đ
                                </h3>
                                <small class="text-muted">Tổng doanh thu</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #3b82f6, #6366f1);">
                                <i class="fas fa-users fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">${totalUsers}</h3>
                                <small class="text-muted">Người dùng</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #f59e0b, #f97316);">
                                <i class="fas fa-shopping-cart fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">${totalPaidOrders}</h3>
                                <small class="text-muted">Đơn đã thanh toán</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3 animate-on-scroll stagger-3">
                    <div class="card glass-strong border-0 rounded-4 h-100 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #ef4444, #f97316);">
                                <i class="fas fa-calendar-alt fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">${totalEvents}</h3>
                                <small class="text-muted">Tổng sự kiện</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Revenue Chart + Order Breakdown -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4"><i class="fas fa-chart-line text-primary me-2"></i>Doanh thu theo ngày</h5>
                            <canvas id="revenueChart" height="110"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4"><i class="fas fa-chart-pie text-primary me-2"></i>Phân tích đơn hàng</h5>
                            <c:set var="orderTotal" value="${totalPaidOrders + totalPendingOrders + totalCancelledOrders}"/>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span class="small fw-medium"><i class="fas fa-check-circle text-success me-1"></i>Đã thanh toán</span>
                                    <span class="small fw-bold">${totalPaidOrders}</span>
                                </div>
                                <c:set var="paidPct" value="${orderTotal > 0 ? (totalPaidOrders * 100 / orderTotal) : 0}"/>
                                <div class="progress rounded-pill" style="height: 8px;">
                                    <div class="progress-bar" style="width:${paidPct}%; background: linear-gradient(90deg,#10b981,#06b6d4);"></div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span class="small fw-medium"><i class="fas fa-clock text-warning me-1"></i>Chờ thanh toán</span>
                                    <span class="small fw-bold">${totalPendingOrders}</span>
                                </div>
                                <c:set var="pendPct" value="${orderTotal > 0 ? (totalPendingOrders * 100 / orderTotal) : 0}"/>
                                <div class="progress rounded-pill" style="height: 8px;">
                                    <div class="progress-bar bg-warning" style="width:${pendPct}%;"></div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span class="small fw-medium"><i class="fas fa-times-circle text-danger me-1"></i>Đã hủy</span>
                                    <span class="small fw-bold">${totalCancelledOrders}</span>
                                </div>
                                <c:set var="cancelPct" value="${orderTotal > 0 ? (totalCancelledOrders * 100 / orderTotal) : 0}"/>
                                <div class="progress rounded-pill" style="height: 8px;">
                                    <div class="progress-bar bg-danger" style="width:${cancelPct}%;"></div>
                                </div>
                            </div>
                            <hr style="border-color: rgba(0,0,0,0.06);">
                            <div class="d-flex justify-content-between">
                                <span class="text-muted small">Tổng đơn</span>
                                <span class="fw-bold small">${orderTotal}</span>
                            </div>
                            <div class="d-flex justify-content-between mt-1">
                                <span class="text-muted small">TB doanh thu/đơn</span>
                                <span class="fw-bold small">
                                    <c:choose>
                                        <c:when test="${totalPaidOrders > 0}">
                                            <fmt:formatNumber value="${totalRevenue / totalPaidOrders}" type="number" maxFractionDigits="0" groupingUsed="true"/>đ
                                        </c:when>
                                        <c:otherwise>0đ</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Top Events Table -->
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <div class="d-flex justify-content-between align-items-center p-4 pb-2">
                        <h5 class="fw-bold mb-0"><i class="fas fa-trophy text-warning me-2"></i>Top sự kiện theo doanh thu</h5>
                        <a href="${pageContext.request.contextPath}/admin/events" class="btn btn-sm btn-outline-primary rounded-pill px-3">
                            Xem tất cả <i class="fas fa-arrow-right ms-1"></i>
                        </a>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th style="width:40px;">#</th>
                                    <th>Tên sự kiện</th>
                                    <th>Organizer</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Doanh thu</th>
                                    <th class="text-center">Số đơn</th>
                                    <th class="text-center">Xem</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty topEvents}">
                                        <tr>
                                            <td colspan="7" class="text-center py-5 text-muted">
                                                <i class="fas fa-chart-bar fa-2x mb-2 d-block opacity-25"></i>
                                                Chưa có dữ liệu sự kiện
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="ev" items="${topEvents}" varStatus="loop">
                                            <tr class="hover-lift" style="transition: all 0.2s;">
                                                <td>
                                                    <span class="fw-bold ${loop.index == 0 ? 'text-warning' : loop.index == 1 ? 'text-secondary' : loop.index == 2 ? 'text-danger' : 'text-muted'}">
                                                        <c:choose>
                                                            <c:when test="${loop.index == 0}"><span class="badge rounded-circle" style="width:24px;height:24px;line-height:24px;background:linear-gradient(135deg,#f59e0b,#f97316);color:white;font-size:0.7rem;">1</span></c:when>
                                                            <c:when test="${loop.index == 1}"><span class="badge rounded-circle" style="width:24px;height:24px;line-height:24px;background:linear-gradient(135deg,#94a3b8,#64748b);color:white;font-size:0.7rem;">2</span></c:when>
                                                            <c:when test="${loop.index == 2}"><span class="badge rounded-circle" style="width:24px;height:24px;line-height:24px;background:linear-gradient(135deg,#b45309,#a16207);color:white;font-size:0.7rem;">3</span></c:when>
                                                            <c:otherwise>${loop.count}</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td class="fw-medium" style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                    ${ev.title}
                                                </td>
                                                <td class="text-muted">${ev.organizerName}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${ev.status == 'approved'}">
                                                            <span class="badge rounded-pill px-3" style="background: linear-gradient(135deg,#10b981,#06b6d4); color:white;">Đã duyệt</span>
                                                        </c:when>
                                                        <c:when test="${ev.status == 'pending'}">
                                                            <span class="badge bg-warning text-dark rounded-pill px-3">Chờ duyệt</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-danger rounded-pill px-3">Từ chối</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end fw-bold text-success">
                                                    <fmt:formatNumber value="${ev.revenue}" type="number" maxFractionDigits="0" groupingUsed="true"/>đ
                                                </td>
                                                <td class="text-center">
                                                    <span class="badge bg-light text-dark border rounded-pill px-2">${ev.orderCount}</span>
                                                </td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/admin/events/${ev.eventId}"
                                                       class="btn btn-sm btn-light rounded-circle shadow-sm" title="Xem chi tiết">
                                                        <i class="fas fa-eye text-primary"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
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
(function() {
    const ctx = document.getElementById('revenueChart');
    if (!ctx) return;

    const isDark = document.documentElement.getAttribute('data-bs-theme') === 'dark'
        || window.matchMedia('(prefers-color-scheme: dark)').matches;
    const textColor = isDark ? 'rgba(248,250,252,0.7)' : 'rgba(15,23,42,0.6)';
    const gridColor = isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.06)';

    const days = ${empty param.period ? 7 : param.period == 'month' ? 30 : param.period == 'year' ? 365 : 7};

    fetch(`${pageContext.request.contextPath}/admin/dashboard/chart-data?type=revenue&days=` + days)
        .then(r => r.json())
        .then(data => {
            const labels = data.map(d => {
                const dt = new Date(d.date);
                return dt.toLocaleDateString('vi-VN', {day: '2-digit', month: '2-digit'});
            });
            const revenues = data.map(d => d.revenue);

            new Chart(ctx, {
                type: 'line',
                data: {
                    labels,
                    datasets: [{
                        label: 'Doanh thu (đ)',
                        data: revenues,
                        borderColor: '#6366f1',
                        backgroundColor: 'rgba(99,102,241,0.1)',
                        borderWidth: 2.5,
                        pointBackgroundColor: '#6366f1',
                        pointRadius: 4,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: ctx => ctx.parsed.y.toLocaleString('vi-VN') + 'đ'
                            }
                        }
                    },
                    scales: {
                        x: { grid: { color: gridColor }, ticks: { color: textColor } },
                        y: {
                            grid: { color: gridColor }, ticks: { color: textColor,
                                callback: v => (v >= 1e6 ? (v/1e6).toFixed(1) + 'M' : v.toLocaleString('vi-VN')) + 'đ'
                            }
                        }
                    }
                }
            });
        })
        .catch(() => {
            ctx.parentElement.innerHTML = '<p class="text-muted text-center py-4">Không thể tải dữ liệu biểu đồ.</p>';
        });
})();
</script>

<jsp:include page="../footer.jsp" />
