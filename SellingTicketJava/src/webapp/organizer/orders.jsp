<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="orders"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <h2 class="fw-bold mb-0"><i class="fas fa-shopping-cart text-primary me-2"></i>Đơn hàng</h2>
                <button class="btn glass rounded-pill px-4 hover-lift fw-medium">
                    <i class="fas fa-download me-2 text-success"></i>Xuất Excel
                </button>
            </div>

            <!-- Stats mini -->
            <div class="row g-3 mb-4">
                <div class="col-md-3 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-check-circle text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0 counter" data-target="${totalPaid != null ? totalPaid : 0}">0</h4>
                                <small class="text-muted">Đã thanh toán</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #f59e0b, #f97316);">
                                <i class="fas fa-clock text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0 counter" data-target="${totalPending != null ? totalPending : 0}">0</h4>
                                <small class="text-muted">Chờ thanh toán</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #ef4444, #f97316);">
                                <i class="fas fa-times-circle text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0 counter" data-target="${totalCanceled != null ? totalCanceled : 0}">0</h4>
                                <small class="text-muted">Đã hủy</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 animate-on-scroll stagger-3">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #9333ea, #a855f7);">
                                <i class="fas fa-dollar-sign text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0"><span class="counter" data-target="${totalRevenue != null ? totalRevenue : 0}">0</span>đ</h4>
                                <small class="text-muted">Tổng doanh thu</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filters -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body d-flex gap-3 flex-wrap align-items-center p-3">
                    <form action="${pageContext.request.contextPath}/organizer/orders" method="GET" class="d-flex gap-3 align-items-center m-0 p-0" id="filterForm">
                        <select name="eventId" class="form-select glass border-0 rounded-3" style="max-width: 250px;" onchange="document.getElementById('filterForm').submit()">
                            <option value="">-- Chọn sự kiện --</option>
                            <c:forEach var="evt" items="${myEvents}">
                                <option value="${evt.eventId}" ${selectedEventId == evt.eventId ? 'selected' : ''}>${evt.title}</option>
                            </c:forEach>
                        </select>
                    </form>
                    <select class="form-select glass border-0 rounded-3" style="max-width: 170px;">
                        <option>Tất cả trạng thái</option>
                        <option>Đã thanh toán</option>
                        <option>Chờ thanh toán</option>
                        <option>Đã hủy</option>
                    </select>
                    <div class="input-group ms-auto" style="max-width: 260px;">
                        <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" class="form-control glass border-0" placeholder="Tìm theo mã đơn..." id="orderSearch">
                    </div>
                </div>
            </div>

            <!-- Orders Table -->
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Sự kiện</th>
                                    <th>Vé</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="order" items="${orders}">
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td><code class="text-primary fw-bold">#${order.orderId}</code></td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold" style="width: 32px; height: 32px; background: linear-gradient(135deg, var(--primary), var(--secondary)); font-size: 0.75rem;">
                                                <c:out value="${order.buyerName != null && !order.buyerName.isEmpty() ? order.buyerName.substring(0,1).toUpperCase() : 'U'}" />
                                            </div>
                                            <div>
                                                <span class="fw-medium">${order.buyerName}</span>
                                                <br><small class="text-muted">${order.buyerEmail}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="fw-medium">${order.eventTitle}</td>
                                    <td>
                                        <c:forEach var="item" items="${order.items}">
                                            ${item.ticketTypeName} x ${item.quantity}<br>
                                        </c:forEach>
                                    </td>
                                    <td class="fw-bold text-primary">
                                        <fmt:formatNumber value="${order.finalAmount}" type="number" maxFractionDigits="0"/>đ
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${order.status == 'PAID'}">
                                                <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg,#10b981,#06b6d4); color: transparent; background-clip: padding-box; -webkit-text-fill-color: white;">Đã thanh toán</span>
                                            </c:when>
                                            <c:when test="${order.status == 'PENDING'}">
                                                <span class="badge rounded-pill px-3 py-2 bg-warning text-dark">Chờ thanh toán</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge rounded-pill px-3 py-2 bg-danger">Đã hủy</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-muted"><fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/organizer/orders/${order.eventId}" class="btn btn-sm glass rounded-pill px-3" title="Xem chi tiết đơn theo sự kiện"><i class="fas fa-eye text-primary"></i></a>
                                    </td>
                                </tr>
                                </c:forEach>
                                <c:if test="${empty orders}">
                                <tr>
                                    <td colspan="8" class="text-center py-5">
                                        <i class="fas fa-box-open fa-3x text-muted opacity-25 mb-3"></i>
                                        <p class="text-muted mb-0">Chưa có đơn hàng nào.</p>
                                    </td>
                                </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Pagination -->
            <nav class="mt-4 d-flex justify-content-center animate-on-scroll">
                <ul class="pagination">
                    <li class="page-item disabled"><a class="page-link glass rounded-start-3" href="#"><i class="fas fa-chevron-left"></i></a></li>
                    <li class="page-item active"><a class="page-link" href="#" style="background: linear-gradient(135deg, var(--primary), var(--secondary)); border: none;">1</a></li>
                    <li class="page-item"><a class="page-link glass" href="#">2</a></li>
                    <li class="page-item"><a class="page-link glass" href="#">3</a></li>
                    <li class="page-item"><a class="page-link glass rounded-end-3" href="#"><i class="fas fa-chevron-right"></i></a></li>
                </ul>
            </nav>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.counter').forEach(el => {
        const target = parseInt(el.dataset.target);
        const duration = 1500;
        const step = target / (duration / 16);
        let current = 0;
        const timer = setInterval(() => {
            current += step;
            if (current >= target) { current = target; clearInterval(timer); }
            el.textContent = Math.floor(current).toLocaleString('vi-VN');
        }, 16);
    });

    const search = document.getElementById('orderSearch');
    if (search) {
        search.addEventListener('input', function() {
            const q = this.value.toLowerCase();
            document.querySelectorAll('.table-glass tbody tr').forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
            });
        });
    }
});
</script>

<jsp:include page="../footer.jsp" />
