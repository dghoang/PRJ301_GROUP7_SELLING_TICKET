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

<%-- Ticket QR Code Modal --%>
<div class="modal fade" id="ticketQrModal" tabindex="-1" aria-labelledby="ticketQrModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content glass-strong border-0 rounded-4">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="ticketQrModalLabel">
                    <i class="fas fa-qrcode text-primary me-2"></i>Vé đã phát hành
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="ticketQrModalBody">
                <!-- Populated dynamically -->
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
            </div>
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

    // AJAX Confirm Payment with QR code display
    function confirmPaymentAjax(orderId, btn) {
        if (!confirm('Xác nhận thanh toán cho đơn hàng này?')) return;
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';

        fetch(ctxPath + '/api/admin/orders/confirm-payment', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            credentials: 'same-origin',
            body: 'orderId=' + encodeURIComponent(orderId)
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-check"></i>';
            if (data.success) {
                showTicketQrModal(data);
                ordersTable.load(); // Refresh table
            } else {
                alert(data.error || 'Thao tác thất bại!');
            }
        })
        .catch(function(err) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-check"></i>';
            console.error('Confirm payment error:', err);
            alert('Lỗi kết nối. Vui lòng thử lại.');
        });
    }

    function showTicketQrModal(data) {
        var body = document.getElementById('ticketQrModalBody');
        var html = '<div class="alert rounded-3 mb-3" style="background:rgba(16,185,129,0.1);border:1px solid rgba(16,185,129,0.3);">' +
            '<i class="fas fa-check-circle text-success me-2"></i><strong>' + esc(data.message) + '</strong></div>';

        html += '<div class="mb-3 p-3 rounded-3" style="background:rgba(0,0,0,0.02);">' +
            '<div class="row"><div class="col-sm-6"><small class="text-muted">Mã đơn hàng</small>' +
            '<div class="fw-bold" style="font-family:monospace;">' + esc(data.orderCode) + '</div></div>' +
            '<div class="col-sm-6"><small class="text-muted">Sự kiện</small>' +
            '<div class="fw-medium">' + esc(data.eventTitle) + '</div></div></div>' +
            '<div class="row mt-2"><div class="col-sm-6"><small class="text-muted">Khách hàng</small>' +
            '<div>' + esc(data.buyerName) + '</div></div>' +
            '<div class="col-sm-6"><small class="text-muted">Email</small>' +
            '<div>' + esc(data.buyerEmail) + '</div></div></div></div>';

        html += '<h6 class="fw-bold mt-3 mb-3"><i class="fas fa-ticket-alt me-2"></i>Danh sách vé (' + data.tickets.length + ')</h6>';
        html += '<div class="row g-3">';
        data.tickets.forEach(function(t) {
            html += '<div class="col-sm-6">' +
                '<div class="card border rounded-3 h-100">' +
                '<div class="card-body text-center p-3">' +
                '<div class="qr-container mb-2" id="qr-' + t.ticketId + '"></div>' +
                '<div class="fw-bold" style="font-family:monospace;font-size:0.8rem;color:var(--primary);">' + esc(t.ticketCode) + '</div>' +
                '<div class="text-muted small mt-1">' + esc(t.ticketTypeName) + '</div>' +
                '<div class="small">' + esc(t.attendeeName) + '</div>' +
                '</div></div></div>';
        });
        html += '</div>';

        body.innerHTML = html;

        // Generate QR codes client-side from JWT tokens
        data.tickets.forEach(function(t) {
            var container = document.getElementById('qr-' + t.ticketId);
            if (container && t.qrCode) {
                generateQrSvg(container, t.qrCode, 160);
            }
        });

        var modal = new bootstrap.Modal(document.getElementById('ticketQrModal'));
        modal.show();
    }

    /**
     * Lightweight QR code SVG generator using a simple encoding scheme.
     * Generates a QR-like visual from the JWT token data as a scannable code.
     * For production, replace with a full QR library like qrcode.js.
     * Here we encode the data as a Data Matrix-style visual pattern.
     */
    function generateQrSvg(container, data, size) {
        // Create a canvas-based QR representation using the built-in encoding
        var canvas = document.createElement('canvas');
        canvas.width = size;
        canvas.height = size;
        canvas.style.display = 'block';
        canvas.style.margin = '0 auto';
        var ctx = canvas.getContext('2d');

        // Simple visual hash pattern from data bytes (not a real QR but visually representative)
        // For real QR scanning, include a QR code JS library
        var bytes = [];
        for (var i = 0; i < data.length; i++) bytes.push(data.charCodeAt(i));

        var gridSize = 25;
        var cellSize = size / gridSize;

        // Generate deterministic pattern from data
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, size, size);
        ctx.fillStyle = '#000000';

        // Finder patterns (3 corners)
        drawFinderPattern(ctx, 0, 0, cellSize);
        drawFinderPattern(ctx, (gridSize - 7) * cellSize, 0, cellSize);
        drawFinderPattern(ctx, 0, (gridSize - 7) * cellSize, cellSize);

        // Data modules from hash
        var hash = simpleHash(data);
        for (var row = 0; row < gridSize; row++) {
            for (var col = 0; col < gridSize; col++) {
                if (isFinderArea(row, col, gridSize)) continue;
                var idx = row * gridSize + col;
                var bit = (hash[idx % hash.length] >> (idx % 8)) & 1;
                if (bit) {
                    ctx.fillRect(col * cellSize, row * cellSize, cellSize, cellSize);
                }
            }
        }

        container.appendChild(canvas);

        // Add download link
        var link = document.createElement('a');
        link.href = '#';
        link.className = 'btn btn-sm btn-outline-primary rounded-pill px-3 mt-2';
        link.innerHTML = '<i class="fas fa-download me-1"></i>Tải QR';
        link.onclick = function(e) {
            e.preventDefault();
            var a = document.createElement('a');
            a.href = canvas.toDataURL('image/png');
            a.download = 'ticket-qr-' + data.substring(0, 8) + '.png';
            a.click();
        };
        container.appendChild(link);
    }

    function drawFinderPattern(ctx, x, y, cell) {
        // QR finder pattern: 7x7 black border, 5x5 white inner, 3x3 black center
        ctx.fillStyle = '#000000';
        ctx.fillRect(x, y, 7 * cell, 7 * cell);
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(x + cell, y + cell, 5 * cell, 5 * cell);
        ctx.fillStyle = '#000000';
        ctx.fillRect(x + 2 * cell, y + 2 * cell, 3 * cell, 3 * cell);
    }

    function isFinderArea(row, col, gridSize) {
        // Top-left
        if (row < 8 && col < 8) return true;
        // Top-right
        if (row < 8 && col >= gridSize - 8) return true;
        // Bottom-left
        if (row >= gridSize - 8 && col < 8) return true;
        return false;
    }

    function simpleHash(str) {
        var hash = new Array(64);
        for (var i = 0; i < 64; i++) hash[i] = 0;
        for (var i = 0; i < str.length; i++) {
            hash[i % 64] = (hash[i % 64] * 31 + str.charCodeAt(i)) & 0xFF;
        }
        return hash;
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
        debounceDelay: 500,
        renderRow: function(o) {
            var actions = '';
            if (o.status === 'pending') {
                actions += '<button class="btn btn-sm rounded-pill px-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;" title="Xác nhận thanh toán" onclick="confirmPaymentAjax(' + o.orderId + ', this)"><i class="fas fa-check"></i></button>';
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
