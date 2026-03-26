<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />
<script src="https://unpkg.com/html5-qrcode"></script>

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="check-in"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <c:choose>
                <%-- NO EVENT SELECTED — Show Event Selector --%>
                <c:when test="${noEventSelected}">
                    <div class="row justify-content-center">
                        <div class="col-lg-8">
                            <!-- Header -->
                            <div class="text-center mb-4 animate-fadeInDown">
                                <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                                     style="width: 72px; height: 72px; background: linear-gradient(135deg, #10b981, #059669);">
                                    <i class="fas fa-qrcode text-white fa-2x"></i>
                                </div>
                                <h3 class="fw-bold mb-1">Chọn sự kiện để Check-in</h3>
                                <p class="text-muted">Vui lòng chọn sự kiện bạn muốn thực hiện check-in</p>
                            </div>

                            <!-- Event List -->
                            <c:forEach var="ev" items="${assignedEvents}" varStatus="loop">
                            <a href="${pageContext.request.contextPath}/staff/check-in?eventId=${ev.eventId}"
                               class="card glass-strong border-0 rounded-4 mb-3 text-decoration-none animate-fadeInDown hover-glow"
                               style="animation-delay: ${loop.index * 0.08}s; transition: all 0.3s;">
                                <div class="card-body p-4">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="flex-shrink-0 d-flex align-items-center justify-content-center rounded-3"
                                             style="width: 52px; height: 52px; background: linear-gradient(135deg, #10b981, #059669);">
                                            <i class="fas fa-calendar-check text-white fa-lg"></i>
                                        </div>
                                        <div class="flex-grow-1 min-width-0">
                                            <h6 class="fw-bold mb-1 text-dark">${ev.eventName}</h6>
                                            <div class="d-flex flex-wrap gap-3 text-muted small">
                                                <span><i class="fas fa-map-marker-alt me-1"></i>${ev.venue}</span>
                                                <span><i class="fas fa-clock me-1"></i><fmt:formatDate value="${ev.startDate}" pattern="dd/MM/yyyy HH:mm"/></span>
                                            </div>
                                        </div>
                                        <div class="flex-shrink-0 d-flex align-items-center gap-3">
                                            <div class="text-center">
                                                <div class="fw-bold fs-5" style="color: #3b82f6;">${ev.ticketsSold}</div>
                                                <div class="text-muted" style="font-size: 0.65rem;">Vé bán</div>
                                            </div>
                                            <div class="text-center">
                                                <div class="fw-bold fs-5" style="color: #10b981;">${ev.ticketsChecked}</div>
                                                <div class="text-muted" style="font-size: 0.65rem;">Check-in</div>
                                            </div>
                                            <i class="fas fa-chevron-right text-muted"></i>
                                        </div>
                                    </div>
                                    <c:if test="${ev.ticketsSold > 0}">
                                    <div class="progress mt-3" style="height: 5px; border-radius: 3px;">
                                        <div class="progress-bar" role="progressbar"
                                             style="width: ${ev.ticketsChecked * 100 / ev.ticketsSold}%; background: linear-gradient(90deg, #10b981, #059669); border-radius: 3px;"></div>
                                    </div>
                                    </c:if>
                                </div>
                            </a>
                            </c:forEach>

                            <c:if test="${empty assignedEvents}">
                            <div class="card glass-strong border-0 rounded-4">
                                <div class="card-body text-center py-5 text-muted">
                                    <i class="fas fa-inbox fa-3x mb-3 opacity-25"></i>
                                    <p class="mb-1 fw-semibold">Chưa có sự kiện nào</p>
                                    <p class="mb-0 small">Bạn chưa được phân công sự kiện nào để check-in.</p>
                                </div>
                            </div>
                            </c:if>
                        </div>
                    </div>
                </c:when>

                <%-- EVENT SELECTED — Show Check-in Interface --%>
                <c:otherwise>
                    <div class="row justify-content-center">
                        <div class="col-lg-8 col-xl-7">
                            <!-- Event Header -->
                            <div class="card glass-strong border-0 rounded-4 mb-3 animate-fadeInDown">
                                <div class="card-body p-4">
                                    <div class="d-flex align-items-start justify-content-between">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="d-flex align-items-center justify-content-center rounded-3"
                                                 style="width: 52px; height: 52px; background: linear-gradient(135deg, #10b981, #059669);">
                                                <i class="fas fa-calendar-check text-white fa-lg"></i>
                                            </div>
                                            <div>
                                                <h5 class="fw-bold mb-1">${selectedEvent.eventName}</h5>
                                                <div class="d-flex flex-wrap gap-3 text-muted small">
                                                    <span><i class="fas fa-map-marker-alt me-1"></i>${selectedEvent.venue}</span>
                                                    <span><i class="fas fa-clock me-1"></i><fmt:formatDate value="${selectedEvent.startDate}" pattern="dd/MM/yyyy HH:mm"/></span>
                                                </div>
                                            </div>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/staff/check-in" class="btn btn-sm btn-outline-secondary rounded-pill">
                                            <i class="fas fa-exchange-alt me-1"></i>Đổi sự kiện
                                        </a>
                                    </div>

                                    <!-- Stats Bar -->
                                    <div class="row g-2 mt-3">
                                        <div class="col-4">
                                            <div class="text-center p-2 rounded-3" style="background: rgba(59,130,246,0.08);">
                                                <div class="fw-bold fs-5" style="color: #3b82f6;" id="stat-sold">${selectedEvent.ticketsSold}</div>
                                                <div class="text-muted" style="font-size: 0.7rem;">Vé đã bán</div>
                                            </div>
                                        </div>
                                        <div class="col-4">
                                            <div class="text-center p-2 rounded-3" style="background: rgba(16,185,129,0.08);">
                                                <div class="fw-bold fs-5" style="color: #10b981;" id="stat-checked">${selectedEvent.ticketsChecked}</div>
                                                <div class="text-muted" style="font-size: 0.7rem;">Đã check-in</div>
                                            </div>
                                        </div>
                                        <div class="col-4">
                                            <div class="text-center p-2 rounded-3" style="background: rgba(245,158,11,0.08);">
                                                <c:set var="sold" value="${selectedEvent.ticketsSold}" />
                                                <c:set var="checked" value="${selectedEvent.ticketsChecked}" />
                                                <div class="fw-bold fs-5" style="color: #f59e0b;" id="stat-pct">
                                                    <c:choose>
                                                        <c:when test="${sold > 0}"><fmt:formatNumber value="${checked * 100.0 / sold}" maxFractionDigits="1"/>%</c:when>
                                                        <c:otherwise>0%</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="text-muted" style="font-size: 0.7rem;">Tỷ lệ</div>
                                            </div>
                                        </div>
                                    </div>
                                <!-- Check-in Form & Scanner -->
                            <div class="card glass-strong border-0 rounded-4 mb-3 animate-fadeInDown" style="animation-delay: 0.1s;">
                                <div class="card-body p-4">
                                    <ul class="nav nav-pills nav-fill mb-4 p-1 rounded-3" style="background: rgba(0,0,0,0.05);">
                                        <li class="nav-item">
                                            <button class="nav-link active rounded-3 py-2 fw-semibold" id="tab-scan" data-bs-toggle="pill" data-bs-target="#pane-scan">
                                                <i class="fas fa-qrcode me-2"></i>Quét QR
                                            </button>
                                        </li>
                                        <li class="nav-item">
                                            <button class="nav-link rounded-3 py-2 fw-semibold" id="tab-manual" data-bs-toggle="pill" data-bs-target="#pane-manual">
                                                <i class="fas fa-keyboard me-2"></i>Nhập mã
                                            </button>
                                        </li>
                                    </ul>

                                    <div class="tab-content">
                                        <!-- Scan Pane -->
                                        <div class="tab-pane fade show active" id="pane-scan">
                                            <div id="reader-container" class="position-relative overflow-hidden rounded-4 bg-black mb-3"
                                                 style="min-height: 250px; border: 2px dashed rgba(255,255,255,0.2);">
                                                <div id="reader" style="width: 100%;"></div>
                                                <div id="scan-placeholder" class="position-absolute top-50 start-50 translate-middle text-center text-white-50">
                                                    <i class="fas fa-camera fa-3x mb-3"></i>
                                                    <p class="mb-0">Đang khởi động camera...</p>
                                                </div>
                                            </div>
                                            <button id="btn-toggle-camera" class="btn btn-light w-100 rounded-pill mb-2">
                                                <i class="fas fa-video-slash me-2"></i>Dừng camera
                                            </button>
                                        </div>

                                        <!-- Manual Pane -->
                                        <div class="tab-pane fade" id="pane-manual">
                                            <form id="checkin-form" onsubmit="return false;">
                                                <input type="hidden" name="eventId" value="${eventId}"/>
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Mã đơn hàng / Mã vé</label>
                                                    <div class="input-group input-group-lg">
                                                        <span class="input-group-text glass border-0"><i class="fas fa-search"></i></span>
                                                        <input type="text" id="order-code-input" name="orderCode"
                                                               class="form-control glass border-0 rounded-end-3"
                                                               placeholder="VD: ORD-1234..." autofocus>
                                                    </div>
                                                </div>
                                                <button type="submit" id="btn-lookup" class="btn w-100 py-3 fw-semibold text-white rounded-3"
                                                        style="background: linear-gradient(135deg, #3b82f6, #2563eb);">
                                                    <i class="fas fa-search me-2"></i>Tra cứu
                                                </button>
                                            </form>
                                        </div>
                                    </div>

                                    <!-- Result Area -->
                                    <div id="result-area" class="mt-4 d-none">
                                        <div id="result-content" class="alert rounded-3 d-flex align-items-center gap-3"></div>
                                        <div id="lookup-results" class="mt-3 d-none">
                                            <h6 class="fw-bold mb-2">Danh sách vé:</h6>
                                            <div id="ticket-list" class="list-group list-group-flush border rounded-3 overflow-hidden">
                                                <!-- Tickets will be injected here -->
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>        </div>
                                </div>
                            </div>

                            <!-- Session Check-in History -->
                            <div class="card glass-strong border-0 rounded-4 animate-fadeInDown" style="animation-delay: 0.15s;">
                                <div class="card-header bg-transparent border-0 py-3 px-4 d-flex justify-content-between align-items-center">
                                    <h6 class="mb-0 fw-bold"><i class="fas fa-history me-2"></i>Lịch sử check-in phiên này</h6>
                                    <span class="badge rounded-pill px-3 py-1 fw-bold" style="background: linear-gradient(135deg, #10b981, #059669); color: white;">
                                        <span id="checkin-count">0</span> vé
                                    </span>
                                </div>
                                <div class="card-body p-0" id="history-body">
                                    <div class="text-center py-4 text-muted" id="history-empty">
                                        <i class="fas fa-clipboard-list opacity-25 mb-2" style="font-size: 1.5rem;"></i>
                                        <p class="mb-0 small">Chưa có check-in nào trong phiên này</p>
                                    </div>
                                    <div class="table-responsive d-none" id="history-table">
                                        <table class="table table-hover align-middle mb-0">
                                            <thead>
                                                <tr class="text-muted small" style="border-bottom: 2px solid rgba(0,0,0,0.05);">
                                                    <th class="ps-4">#</th>
                                                    <th>Mã vé</th>
                                                    <th>Thời gian</th>
                                                    <th class="text-center">Trạng thái</th>
                                                </tr>
                                            </thead>
                                            <tbody id="history-rows"></tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<c:if test="${!noEventSelected}">
<script src="https://unpkg.com/html5-qrcode"></script>
<script>
(function() {
    var count       = 0;
    var form        = document.getElementById('checkin-form');
    var input       = document.getElementById('order-code-input');
    var resArea     = document.getElementById('result-area');
    var resCont     = document.getElementById('result-content');
    var lookupRes   = document.getElementById('lookup-results');
    var ticketList  = document.getElementById('ticket-list');
    var btnLookup   = document.getElementById('btn-lookup');
    var histRows    = document.getElementById('history-rows');
    var histTable   = document.getElementById('history-table');
    var histEmpty   = document.getElementById('history-empty');
    var statChecked = document.getElementById('stat-checked');
    var statPct     = document.getElementById('stat-pct');
    var totalSold   = parseInt('${selectedEvent.ticketsSold}') || 0;
    var totalChecked = parseInt('${selectedEvent.ticketsChecked}') || 0;
    var eventId     = '${eventId}';
    var ctx         = '${pageContext.request.contextPath}';

    var html5QrCode = null;
    var isCameraOn  = false;

    // --- QR Scanner Setup ---
    function startScanner() {
        if (!document.getElementById('reader')) return;
        html5QrCode = new Html5Qrcode("reader");
        const config = { fps: 10, qrbox: { width: 250, height: 250 } };
        
        html5QrCode.start({ facingMode: "environment" }, config, onScanSuccess)
            .then(() => {
                isCameraOn = true;
                document.getElementById('scan-placeholder').classList.add('d-none');
            })
            .catch(err => {
                console.error("Camera error:", err);
                document.getElementById('scan-placeholder').innerHTML = '<i class="fas fa-exclamation-triangle fa-2x mb-2 text-warning"></i><p>Không thể mở camera</p>';
            });
    }

    function stopScanner() {
        if (html5QrCode && isCameraOn) {
            html5QrCode.stop().then(() => {
                isCameraOn = false;
                document.getElementById('btn-toggle-camera').innerHTML = '<i class="fas fa-video me-2"></i>Bật camera';
            });
        }
    }

    function onScanSuccess(decodedText) {
        // Debounce: flash UI to show scan detected
        resArea.classList.add('d-none');
        processCheckIn({ qrToken: decodedText });
    }

    document.getElementById('btn-toggle-camera').addEventListener('click', function() {
        if (isCameraOn) stopScanner(); else startScanner();
    });

    // Start scanner on load if tab active
    if (document.getElementById('pane-scan').classList.contains('show')) {
        setTimeout(startScanner, 500);
    }

    function updateStats() {
        if (statChecked) statChecked.textContent = totalChecked;
        if (statPct && totalSold > 0) {
            statPct.textContent = (totalChecked * 100 / totalSold).toFixed(1) + '%';
        }
    }

    function addHistoryRow(code, result) {
        var now = new Date();
        var time = now.getHours().toString().padStart(2,'0') + ':' +
                   now.getMinutes().toString().padStart(2,'0') + ':' +
                   now.getSeconds().toString().padStart(2,'0');
        var row = document.createElement('tr');
        row.style.animation = 'fadeInDown 0.3s ease-out';
        row.innerHTML = '<td class="ps-4 fw-semibold">' + (++count) + '</td>' +
                        '<td><code class="small">' + (code || 'QR Scan') + '</code></td>' +
                        '<td class="small text-muted">' + time + '</td>' +
                        '<td class="text-center">' +
                            (result.success ? '<span class="badge rounded-pill" style="background:rgba(16,185,129,0.15);color:#10b981;">Thành công</span>'
                                             : '<span class="badge rounded-pill" style="background:rgba(239,68,68,0.15);color:#ef4444;">Thất bại</span>') +
                        '</td>';
        histRows.insertBefore(row, histRows.firstChild);
        histTable.classList.remove('d-none');
        histEmpty.classList.add('d-none');
        document.getElementById('checkin-count').textContent = count;
    }

    function processCheckIn(params) {
        params.eventId = eventId;
        var body = Object.keys(params).map(k => k + '=' + encodeURIComponent(params[k])).join('&');

        fetch(ctx + '/staff/check-in', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body
        })
        .then(r => r.json())
        .then(data => {
            handleCheckInResult(data, params.orderCode || params.ticketCode || 'QR Scan');
        })
        .catch(err => {
            console.error(err);
            showResult('warning', 'Lỗi kết nối server');
        });
    }

    function handleCheckInResult(data, label) {
        resArea.classList.remove('d-none');
        lookupRes.classList.add('d-none');

        if (data.action === 'lookup') {
            showLookup(data);
            return;
        }

        if (data.success) {
            showResult('success', '<strong>' + (data.message || 'Check-in thành công!') + '</strong><br>' + 
                       '<span class="small">' + (data.customerName || '') + ' - ' + (data.ticketType || '') + '</span>');
            totalChecked++;
            updateStats();
            addHistoryRow(data.ticketCode || label, data);
        } else {
            var mode = data.alreadyCheckedIn ? 'warning' : 'danger';
            showResult(mode, '<strong>' + (data.message || data.error || 'Thất bại') + '</strong><br>' + 
                       '<span class="small">' + (data.customerName || '') + '</span>');
            addHistoryRow(label, data);
        }
    }

    function showResult(type, html) {
        resArea.classList.remove('d-none');
        resCont.className = 'alert rounded-3 d-flex align-items-center gap-3';
        if (type === 'success') {
            resCont.style.cssText = 'background:rgba(16,185,129,0.1);border:1px solid rgba(16,185,129,0.2);color:#065f46;';
            resCont.innerHTML = '<i class="fas fa-check-circle fa-2x text-success"></i><div>' + html + '</div>';
        } else if (type === 'warning') {
            resCont.style.cssText = 'background:rgba(245,158,11,0.1);border:1px solid rgba(245,158,11,0.2);color:#92400e;';
            resCont.innerHTML = '<i class="fas fa-exclamation-circle fa-2x text-warning"></i><div>' + html + '</div>';
        } else {
            resCont.style.cssText = 'background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.2);color:#991b1b;';
            resCont.innerHTML = '<i class="fas fa-times-circle fa-2x text-danger"></i><div>' + html + '</div>';
        }
    }

    function showLookup(data) {
        lookupRes.classList.remove('d-none');
        resCont.className = 'alert alert-info rounded-3 mb-2 small py-2';
        resCont.style.cssText = '';
        resCont.innerHTML = '<i class="fas fa-info-circle me-2"></i>Tìm thấy ' + data.tickets.length + ' vé cho <b>' + data.customerName + '</b>';
        
        ticketList.innerHTML = '';
        data.tickets.forEach(t => {
            var item = document.createElement('button');
            item.className = 'list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3';
            item.disabled = t.checkedIn;
            item.innerHTML = '<div><div class="fw-bold">' + t.attendeeName + '</div>' +
                             '<div class="small text-muted">' + t.ticketCode + ' • ' + t.ticketType + '</div></div>' +
                             (t.checkedIn ? '<span class="badge bg-secondary rounded-pill">Đã check-in</span>'
                                          : '<span class="btn btn-sm btn-primary rounded-pill px-3">Check-in</span>');
            
            if (!t.checkedIn) {
                item.onclick = () => {
                   processCheckIn({ action: 'checkin', orderCode: data.orderCode, ticketId: t.ticketId });
                };
            }
            ticketList.appendChild(item);
        });
    }

    form.addEventListener('submit', function() {
        var code = input.value.trim();
        if (!code) return;
        processCheckIn({ orderCode: code });
    });
})();
</script>
</c:if>

<jsp:include page="../footer.jsp" />
