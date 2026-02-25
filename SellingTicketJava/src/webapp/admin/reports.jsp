<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <%-- Sidebar --%>
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="reports"/>
            </jsp:include>
        </div>

        <%-- Main Content --%>
        <div class="col-lg-10">
            <div class="glass-gradient rounded-4 p-4 mb-4 position-relative overflow-hidden animate-fadeInDown">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h2 class="fw-bold mb-1"><i class="fas fa-chart-bar me-2"></i>Báo cáo hệ thống</h2>
                        <p class="text-muted mb-0">Tổng quan hiệu suất và thống kê toàn hệ thống</p>
                    </div>
                </div>
            </div>

            <%-- KPI Cards --%>
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
                                <i class="fas fa-exclamation-triangle fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">${totalPendingOrders + totalCancelledOrders}</h3>
                                <small class="text-muted">Đơn cần xử lý</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Order Breakdown --%>
            <div class="row g-4">
                <div class="col-lg-8 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4">Phân tích đơn hàng</h5>
                            <div class="table-responsive">
                                <table class="table table-glass align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th>Trạng thái</th>
                                            <th>Số lượng</th>
                                            <th>Tỷ lệ</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:set var="orderTotal" value="${totalPaidOrders + totalPendingOrders + totalCancelledOrders}"/>
                                        <tr>
                                            <td>
                                                <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">
                                                    <i class="fas fa-check-circle me-1"></i>Đã thanh toán
                                                </span>
                                            </td>
                                            <td class="fw-bold">${totalPaidOrders}</td>
                                            <td>
                                                <c:set var="paidPct" value="${orderTotal > 0 ? (totalPaidOrders * 100 / orderTotal) : 0}"/>
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="progress flex-grow-1" style="height: 6px; width: 100px;">
                                                        <div class="progress-bar" style="width: ${paidPct}%; background: linear-gradient(90deg, #10b981, #06b6d4);"></div>
                                                    </div>
                                                    <span class="small"><fmt:formatNumber value="${paidPct}" maxFractionDigits="0"/>%</span>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <span class="badge bg-warning text-dark rounded-pill px-3 py-2">
                                                    <i class="fas fa-clock me-1"></i>Chờ thanh toán
                                                </span>
                                            </td>
                                            <td class="fw-bold">${totalPendingOrders}</td>
                                            <td>
                                                <c:set var="pendPct" value="${orderTotal > 0 ? (totalPendingOrders * 100 / orderTotal) : 0}"/>
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="progress flex-grow-1" style="height: 6px; width: 100px;">
                                                        <div class="progress-bar bg-warning" style="width: ${pendPct}%;"></div>
                                                    </div>
                                                    <span class="small"><fmt:formatNumber value="${pendPct}" maxFractionDigits="0"/>%</span>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <span class="badge bg-danger rounded-pill px-3 py-2">
                                                    <i class="fas fa-times-circle me-1"></i>Đã hủy
                                                </span>
                                            </td>
                                            <td class="fw-bold">${totalCancelledOrders}</td>
                                            <td>
                                                <c:set var="cancelPct" value="${orderTotal > 0 ? (totalCancelledOrders * 100 / orderTotal) : 0}"/>
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="progress flex-grow-1" style="height: 6px; width: 100px;">
                                                        <div class="progress-bar bg-danger" style="width: ${cancelPct}%;"></div>
                                                    </div>
                                                    <span class="small"><fmt:formatNumber value="${cancelPct}" maxFractionDigits="0"/>%</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Quick Summary --%>
                <div class="col-lg-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4">Tổng quan nhanh</h5>

                            <div class="mb-4">
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="text-muted">Tổng đơn hàng</span>
                                    <span class="fw-bold">${orderTotal}</span>
                                </div>
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="text-muted">Doanh thu trung bình/đơn</span>
                                    <span class="fw-bold">
                                        <c:choose>
                                            <c:when test="${totalPaidOrders > 0}">
                                                <fmt:formatNumber value="${totalRevenue / totalPaidOrders}" type="number" maxFractionDigits="0" groupingUsed="true"/>đ
                                            </c:when>
                                            <c:otherwise>0đ</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>

                            <hr style="border-color: rgba(0,0,0,0.06);">

                            <div class="text-center mt-4">
                                <div class="dash-icon-box mx-auto mb-3" style="width: 64px; height: 64px; background: linear-gradient(135deg, #3b82f6, #6366f1); border-radius: 16px;">
                                    <i class="fas fa-chart-line fa-lg text-white"></i>
                                </div>
                                <p class="text-muted small">Biểu đồ chi tiết sẽ được cập nhật sau</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
