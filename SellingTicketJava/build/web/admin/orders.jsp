<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="orders"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-shopping-bag text-primary me-2"></i>Quản lý đơn hàng</h2>
                    <p class="text-muted mb-0">Theo dõi và xử lý tất cả đơn hàng trong hệ thống</p>
                </div>
            </div>

            <%-- Toast Messages --%>
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

            <%-- Stats Cards as Filters --%>
            <div class="row g-3 mb-4">
                <%-- Tất cả --%>
                <div class="col-6 col-xl animate-on-scroll">
                    <a href="${pageContext.request.contextPath}/admin/orders" class="text-decoration-none">
                        <div class="card glass-strong border-0 rounded-4 hover-lift h-100 ${empty statusFilter ? 'shadow-lg' : ''}"
                             style="${empty statusFilter ? 'background: rgba(59,130,246,0.1); border: 2px solid var(--primary) !important;' : 'transition: all 0.3s;'}">
                            <div class="card-body d-flex align-items-center gap-3 p-3">
                                <div class="dash-icon-box flex-shrink-0" style="width:42px;height:42px;background:linear-gradient(135deg,#3b82f6,#6366f1);border-radius:12px;">
                                    <i class="fas fa-box text-white"></i>
                                </div>
                                <div class="min-w-0">
                                    <h4 class="fw-bold mb-0 text-dark">${totalOrders}</h4>
                                    <small class="text-muted d-block text-truncate">Tổng đơn</small>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
                <%-- Đã thanh toán --%>
                <div class="col-6 col-xl animate-on-scroll stagger-1">
                    <a href="${pageContext.request.contextPath}/admin/orders?status=paid" class="text-decoration-none">
                        <div class="card glass-strong border-0 rounded-4 hover-lift h-100 ${statusFilter == 'paid' ? 'shadow-lg' : ''}"
                             style="${statusFilter == 'paid' ? 'background: rgba(16,185,129,0.1); border: 2px solid #10b981 !important;' : 'transition: all 0.3s;'}">
                            <div class="card-body d-flex align-items-center gap-3 p-3">
                                <div class="dash-icon-box flex-shrink-0" style="width:42px;height:42px;background:linear-gradient(135deg,#10b981,#06b6d4);border-radius:12px;">
                                    <i class="fas fa-check-circle text-white"></i>
                                </div>
                                <div class="min-w-0">
                                    <h4 class="fw-bold mb-0 text-dark">${paidOrders}</h4>
                                    <small class="text-muted d-block text-truncate">Đã thanh toán</small>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
                <%-- Chờ thanh toán --%>
                <div class="col-6 col-xl animate-on-scroll stagger-2">
                    <a href="${pageContext.request.contextPath}/admin/orders?status=pending" class="text-decoration-none">
                        <div class="card glass-strong border-0 rounded-4 hover-lift h-100 ${statusFilter == 'pending' ? 'shadow-lg' : ''}"
                             style="${statusFilter == 'pending' ? 'background: rgba(245,158,11,0.1); border: 2px solid #f59e0b !important;' : 'transition: all 0.3s;'}">
                            <div class="card-body d-flex align-items-center gap-3 p-3">
                                <div class="dash-icon-box flex-shrink-0" style="width:42px;height:42px;background:linear-gradient(135deg,#f59e0b,#f97316);border-radius:12px;">
                                    <i class="fas fa-clock text-white"></i>
                                </div>
                                <div class="min-w-0">
                                    <h4 class="fw-bold mb-0 text-dark">${pendingOrders}</h4>
                                    <small class="text-muted d-block text-truncate">Chờ thanh toán</small>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
                <%-- Đã hủy --%>
                <div class="col-6 col-xl animate-on-scroll stagger-3">
                    <a href="${pageContext.request.contextPath}/admin/orders?status=cancelled" class="text-decoration-none">
                        <div class="card glass-strong border-0 rounded-4 hover-lift h-100 ${statusFilter == 'cancelled' ? 'shadow-lg' : ''}"
                             style="${statusFilter == 'cancelled' ? 'background: rgba(239,68,68,0.1); border: 2px solid #ef4444 !important;' : 'transition: all 0.3s;'}">
                            <div class="card-body d-flex align-items-center gap-3 p-3">
                                <div class="dash-icon-box flex-shrink-0" style="width:42px;height:42px;background:linear-gradient(135deg,#ef4444,#f97316);border-radius:12px;">
                                    <i class="fas fa-times-circle text-white"></i>
                                </div>
                                <div class="min-w-0">
                                    <h4 class="fw-bold mb-0 text-dark">${cancelledOrders}</h4>
                                    <small class="text-muted d-block text-truncate">Đã hủy</small>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
                <%-- Chờ hoàn tiền --%>
                <div class="col-6 col-xl animate-on-scroll stagger-3">
                    <a href="${pageContext.request.contextPath}/admin/orders?status=refund_requested" class="text-decoration-none">
                        <div class="card glass-strong border-0 rounded-4 hover-lift h-100 ${statusFilter == 'refund_requested' ? 'shadow-lg' : ''}"
                             style="${statusFilter == 'refund_requested' ? 'background: rgba(147,51,234,0.1); border: 2px solid #9333ea !important;' : 'transition: all 0.3s;'}">
                            <div class="card-body d-flex align-items-center gap-3 p-3">
                                <div class="dash-icon-box flex-shrink-0" style="width:42px;height:42px;background:linear-gradient(135deg,#9333ea,#a855f7);border-radius:12px;">
                                    <i class="fas fa-undo text-white"></i>
                                </div>
                                <div class="min-w-0">
                                    <h4 class="fw-bold mb-0 text-dark">${refundRequested}</h4>
                                    <small class="text-muted d-block text-truncate">Chờ hoàn tiền</small>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </div>

            <%-- Search Bar --%>
            <div class="d-flex justify-content-between align-items-center mb-4 animate-on-scroll flex-wrap gap-3">
                <div class="d-flex align-items-center gap-2 flex-wrap" data-filter-group="status">
                    <label class="btn btn-sm glass rounded-pill px-3 mb-0">
                        <input type="checkbox" value="paid" class="d-none"> <i class="fas fa-check-circle me-1 text-success"></i>Đã TT
                    </label>
                    <label class="btn btn-sm glass rounded-pill px-3 mb-0">
                        <input type="checkbox" value="pending" class="d-none"> <i class="fas fa-clock me-1 text-warning"></i>Chờ TT
                    </label>
                    <label class="btn btn-sm glass rounded-pill px-3 mb-0">
                        <input type="checkbox" value="cancelled" class="d-none"> <i class="fas fa-times-circle me-1 text-danger"></i>Đã hủy
                    </label>
                    <label class="btn btn-sm glass rounded-pill px-3 mb-0">
                        <input type="checkbox" value="refund_requested" class="d-none"> <i class="fas fa-undo me-1 text-purple"></i>Chờ hoàn
                    </label>
                </div>
                <div class="d-flex gap-2 align-items-center">
                    <input type="date" class="form-control form-control-sm rounded-3" data-filter-date="dateFrom" style="width:auto" placeholder="Từ ngày">
                    <input type="date" class="form-control form-control-sm rounded-3" data-filter-date="dateTo" style="width:auto" placeholder="Đến ngày">
                    <div class="input-group shadow-sm rounded-pill overflow-hidden" style="max-width: 280px;">
                        <span class="input-group-text glass border-0 bg-white"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" id="admin-order-search" class="form-control glass border-0 bg-white shadow-none ps-0" placeholder="Tìm mã đơn hàng...">
                    </div>
                </div>
            </div>

            <%-- Orders Table --%>
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Sự kiện</th>
                                    <th class="text-end">Tổng tiền</th>
                                    <th>Thanh toán</th>
                                    <th>Trạng thái</th>
                                    <th class="text-muted small">Ngày tạo</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody id="admin-orders-tbody">
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <%-- Pagination --%>
            <div id="admin-orders-pagination" class="d-flex justify-content-center mt-4"></div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/ajax-table.js"></script>
<script>
(function() {
    var ctxPath = '${pageContext.request.contextPath}';
    var csrfToken = '${sessionScope.csrf_token}';

    function esc(v) { if (!v) return ''; var d = document.createElement('div'); d.textContent = v; return d.innerHTML; }
    function fmtDate(s) {
        if (!s) return '';
        var d = new Date(s), pad = function(n) { return String(n).padStart(2,'0'); };
        return pad(d.getDate()) + '/' + pad(d.getMonth()+1) + '/' + d.getFullYear() + ' ' + pad(d.getHours()) + ':' + pad(d.getMinutes());
    }
    function fmtMoney(n) { return new Intl.NumberFormat('vi-VN').format(n) + 'đ'; }
    function paymentBadge(method) {
        if (method === 'vnpay') return '<span class="badge bg-light text-dark border rounded-pill px-2"><i class="fas fa-university me-1"></i>VNPay</span>';
        if (method === 'momo') return '<span class="badge rounded-pill px-2" style="background:#a50064;color:white;"><i class="fas fa-wallet me-1"></i>MoMo</span>';
        return '<span class="badge bg-light text-dark border rounded-pill px-2">' + esc(method) + '</span>';
    }
    function statusBadge(s) {
        switch(s) {
            case 'paid': return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;"><i class="fas fa-check-circle me-1"></i>Đã TT</span>';
            case 'pending': return '<span class="badge bg-warning text-dark rounded-pill px-3 py-2"><i class="fas fa-clock me-1"></i>Chờ TT</span>';
            case 'cancelled': return '<span class="badge bg-danger rounded-pill px-3 py-2"><i class="fas fa-times-circle me-1"></i>Đã hủy</span>';
            case 'refund_requested': return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#9333ea,#a855f7);color:white;"><i class="fas fa-undo me-1"></i>Chờ hoàn</span>';
            case 'refunded': return '<span class="badge bg-secondary rounded-pill px-3 py-2"><i class="fas fa-undo me-1"></i>Đã hoàn</span>';
            case 'checked_in': return '<span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;"><i class="fas fa-qrcode me-1"></i>Checked-in</span>';
            default: return '<span class="badge bg-secondary rounded-pill px-3 py-2">' + esc(s) + '</span>';
        }
    }

    // Toggle filter checkbox styling
    document.querySelectorAll('[data-filter-group="status"] label').forEach(function(label) {
        var cb = label.querySelector('input[type="checkbox"]');
        cb.addEventListener('change', function() {
            label.classList.toggle('active', cb.checked);
            label.style.background = cb.checked ? 'var(--primary)' : '';
            label.style.color = cb.checked ? 'white' : '';
        });
    });

    var ordersTable = new AjaxTable({
        apiUrl: ctxPath + '/api/admin/orders',
        tableBody: '#admin-orders-tbody',
        paginationContainer: '#admin-orders-pagination',
        searchInput: '#admin-order-search',
        pageSize: 20,
        skeletonCols: 8,
        renderRow: function(o) {
            var actions = '';
            if (o.status === 'pending') {
                actions += '<form action="' + ctxPath + '/admin/orders/mark-paid" method="POST" class="d-inline"><input type="hidden" name="csrf_token" value="' + csrfToken + '"><input type="hidden" name="orderId" value="' + o.orderId + '"><button class="btn btn-sm rounded-pill px-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;" title="Đã TT" onclick="return confirm(\'Đánh dấu đã thanh toán?\')"><i class="fas fa-check"></i></button></form>';
            }
            if (o.status === 'pending' || o.status === 'paid') {
                actions += '<form action="' + ctxPath + '/admin/orders/cancel" method="POST" class="d-inline"><input type="hidden" name="csrf_token" value="' + csrfToken + '"><input type="hidden" name="orderId" value="' + o.orderId + '"><button class="btn btn-sm btn-outline-danger rounded-pill px-2" title="Hủy" onclick="return confirm(\'Hủy đơn hàng?\')"><i class="fas fa-ban"></i></button></form>';
            }
            if (o.status === 'refund_requested') {
                actions += '<form action="' + ctxPath + '/admin/orders/approve-refund" method="POST" class="d-inline"><input type="hidden" name="csrf_token" value="' + csrfToken + '"><input type="hidden" name="orderId" value="' + o.orderId + '"><button class="btn btn-sm rounded-pill px-2" style="background:linear-gradient(135deg,#9333ea,#a855f7);color:white;" title="Hoàn tiền" onclick="return confirm(\'Phê duyệt hoàn tiền?\')"><i class="fas fa-undo"></i></button></form>';
            }

            return '<tr class="hover-lift" style="transition:all 0.2s;">' +
                '<td><span class="fw-bold text-primary" style="font-family:monospace;font-size:0.85rem;">' + esc(o.orderCode) + '</span></td>' +
                '<td><div><span class="fw-medium">' + esc(o.buyerName) + '</span><div class="text-muted small">' + esc(o.buyerEmail) + '</div></div></td>' +
                '<td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + esc(o.eventTitle) + '</td>' +
                '<td class="text-end fw-bold">' + fmtMoney(o.finalAmount) + '</td>' +
                '<td>' + paymentBadge(o.paymentMethod) + '</td>' +
                '<td>' + statusBadge(o.status) + '</td>' +
                '<td class="text-muted small">' + fmtDate(o.createdAt) + '</td>' +
                '<td class="text-center"><div class="d-flex justify-content-center gap-1 flex-wrap">' + actions + '</div></td>' +
            '</tr>';
        }
    });
    ordersTable.init();
})();
</script>

<jsp:include page="../footer.jsp" />
