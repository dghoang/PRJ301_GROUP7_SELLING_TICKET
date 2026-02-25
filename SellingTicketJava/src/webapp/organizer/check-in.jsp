<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<style>
/* ======== CHECK-IN SYSTEM ======== */
.scanner-container {
    position: relative;
    border-radius: var(--radius-xl);
    overflow: hidden;
    background: #111;
    aspect-ratio: 4/3;
    max-height: 380px;
}
.scanner-container video {
    width: 100%; height: 100%;
    object-fit: cover;
}
.scanner-container #reader {
    width: 100% !important;
    border: none !important;
}
.scanner-container #reader video {
    border-radius: var(--radius-lg) !important;
}
.scan-overlay {
    position: absolute; inset: 0;
    display: flex; align-items: center; justify-content: center;
    pointer-events: none;
}
.scan-frame {
    width: 200px; height: 200px;
    border: 3px solid rgba(255,255,255,0.6);
    border-radius: 20px;
    position: relative;
}
.scan-frame::before {
    content: '';
    position: absolute;
    top: -1px; left: 50%;
    transform: translateX(-50%);
    width: 80%;
    height: 2px;
    background: linear-gradient(90deg, transparent, var(--primary), transparent);
    animation: scanLine 2.5s ease-in-out infinite;
}
@keyframes scanLine {
    0%, 100% { top: -1px; }
    50% { top: calc(100% - 1px); }
}

/* ======== RESULT CARDS ======== */
.result-card {
    border-radius: var(--radius-lg);
    padding: 1.5rem;
    text-align: center;
    animation: resultPop 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
    transition: all 0.3s;
}
@keyframes resultPop {
    from { opacity: 0; transform: scale(0.8); }
    to { opacity: 1; transform: scale(1); }
}
.result-success {
    background: rgba(16, 185, 129, 0.1);
    border: 1px solid rgba(16, 185, 129, 0.2);
}
.result-warning {
    background: rgba(245, 158, 11, 0.1);
    border: 1px solid rgba(245, 158, 11, 0.2);
}
.result-error {
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid rgba(239, 68, 68, 0.2);
}
.result-icon {
    width: 56px; height: 56px;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    margin: 0 auto 1rem;
    font-size: 1.5rem;
}

/* ======== STAT COUNTER ======== */
.checkin-stat {
    text-align: center;
    padding: 1rem;
}
.checkin-stat .stat-val {
    font-size: 2rem;
    font-weight: 800;
    line-height: 1;
    transition: transform 0.3s;
}
.checkin-stat .stat-val.bump {
    animation: countPulse 0.3s ease;
}
@keyframes countPulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.2); }
    100% { transform: scale(1); }
}
.checkin-stat .stat-lbl {
    font-size: 0.7rem;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.08em;
    margin-top: 0.25rem;
}

/* ======== DONUT ======== */
.donut-container {
    position: relative;
    width: 120px; height: 120px;
    margin: 0 auto;
}
.donut-container svg { width: 100%; height: 100%; transform: rotate(-90deg); }
.donut-container .donut-text {
    position: absolute; inset: 0;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.25rem; font-weight: 800;
}

/* ======== RECENT LIST ======== */
.checkin-feed {
    max-height: 340px;
    overflow-y: auto;
    scrollbar-width: thin;
}
.checkin-feed::-webkit-scrollbar { width: 4px; }
.checkin-feed::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.15); border-radius: 4px; }
.feed-item {
    display: flex; align-items: center; gap: 0.75rem;
    padding: 0.75rem;
    border-radius: var(--radius-sm);
    transition: background 0.2s;
    animation: wizardFadeIn 0.3s ease-out;
}
.feed-item:hover { background: rgba(0,0,0,0.03); }
.feed-icon {
    width: 32px; height: 32px;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.75rem;
    flex-shrink: 0;
}

/* Manual input */
.manual-input-wrapper {
    position: relative;
}
.manual-input-wrapper .form-control {
    padding-right: 3rem;
    font-size: 1rem;
    letter-spacing: 0.05em;
}
.manual-input-wrapper .submit-btn {
    position: absolute;
    right: 8px; top: 50%;
    transform: translateY(-50%);
    width: 36px; height: 36px;
    border-radius: 10px;
    border: none;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer;
    transition: all 0.2s;
}
.manual-input-wrapper .submit-btn:hover { transform: translateY(-50%) scale(1.05); }
</style>

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="checkin"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1">Check-in sự kiện</h2>
                    <p class="text-muted mb-0 small">
                        <c:if test="${event != null}">
                            <i class="fas fa-calendar-alt me-1"></i>${event.title}
                        </c:if>
                    </p>
                </div>
                <c:if test="${event != null}">
                    <a href="${pageContext.request.contextPath}/organizer/events/${event.eventId}" class="btn btn-outline-primary rounded-pill px-3">
                        <i class="fas fa-arrow-left me-1"></i>Chi tiết sự kiện
                    </a>
                </c:if>
            </div>

            <!-- Event Selector (if no event) -->
            <c:if test="${event == null}">
                <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible">
                    <div class="card-body p-4">
                        <h5 class="fw-bold mb-3"><i class="fas fa-calendar-alt text-primary me-2"></i>Chọn sự kiện</h5>
                        <select class="form-select form-select-lg" id="eventSelect" onchange="selectEvent(this.value)">
                            <option value="">Chọn sự kiện để check-in...</option>
                            <c:forEach var="e" items="${events}">
                                <option value="${e.eventId}" ${param.eventId == e.eventId ? 'selected' : ''}>${e.title}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </c:if>

            <c:if test="${event != null}">
            <div class="row g-4">
                <!-- Left: Scanner -->
                <div class="col-lg-7">
                    <!-- Scanner Card -->
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h6 class="fw-bold mb-0"><i class="fas fa-qrcode me-2 text-primary"></i>Quét mã QR</h6>
                                <button class="btn btn-sm btn-outline-primary rounded-pill px-3" id="cameraToggle" onclick="toggleCamera()">
                                    <i class="fas fa-video me-1"></i><span>Bật camera</span>
                                </button>
                            </div>
                            <div class="scanner-container" id="scannerArea">
                                <div id="reader"></div>
                                <div class="scan-overlay" id="scanOverlay" style="display:none;">
                                    <div class="scan-frame"></div>
                                </div>
                                <div class="d-flex align-items-center justify-content-center h-100" id="cameraPlaceholder">
                                    <div class="text-center text-white opacity-50 p-4">
                                        <i class="fas fa-camera fa-3x mb-3"></i>
                                        <p class="mb-0">Nhấn "Bật camera" để bắt đầu quét</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Manual Entry -->
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible stagger-1">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-keyboard me-2 text-primary"></i>Nhập mã thủ công</h6>
                            <div class="manual-input-wrapper">
                                <input type="text" class="form-control form-control-lg glass" id="manualCode"
                                       placeholder="VD: ORD-20260225-ABCD" onkeypress="if(event.key==='Enter'){checkInManual();}">
                                <button class="submit-btn" onclick="checkInManual()"><i class="fas fa-arrow-right"></i></button>
                            </div>
                        </div>
                    </div>

                    <!-- Result Display -->
                    <div id="resultArea" class="d-none mb-4"></div>
                </div>

                <!-- Right: Stats & Feed -->
                <div class="col-lg-5">
                    <!-- Live Stats -->
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible stagger-1">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-chart-pie me-2 text-primary"></i>Thống kê Check-in</h6>
                            <!-- Donut Chart -->
                            <div class="donut-container mb-3">
                                <svg viewBox="0 0 36 36">
                                    <path d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                                          fill="none" stroke="rgba(0,0,0,0.06)" stroke-width="3"/>
                                    <path id="donutPath" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                                          fill="none" stroke="url(#donutGrad)" stroke-width="3"
                                          stroke-dasharray="0, 100" stroke-linecap="round"
                                          style="transition: stroke-dasharray 0.6s ease;"/>
                                    <defs>
                                        <linearGradient id="donutGrad" x1="0%" y1="0%" x2="100%" y2="0%">
                                            <stop offset="0%" style="stop-color:var(--primary)"/>
                                            <stop offset="100%" style="stop-color:#10b981"/>
                                        </linearGradient>
                                    </defs>
                                </svg>
                                <div class="donut-text" id="donutPercent">0%</div>
                            </div>
                            <!-- Counters -->
                            <div class="row g-2">
                                <div class="col-4">
                                    <div class="checkin-stat">
                                        <div class="stat-val text-success" id="statCheckedIn">0</div>
                                        <div class="stat-lbl">Đã check-in</div>
                                    </div>
                                </div>
                                <div class="col-4">
                                    <div class="checkin-stat">
                                        <div class="stat-val text-primary" id="statTotal">${totalOrders != null ? totalOrders : 0}</div>
                                        <div class="stat-lbl">Tổng đơn</div>
                                    </div>
                                </div>
                                <div class="col-4">
                                    <div class="checkin-stat">
                                        <div class="stat-val text-warning" id="statRemaining">0</div>
                                        <div class="stat-lbl">Chưa check-in</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Recent Check-ins -->
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible stagger-2">
                        <div class="card-body p-4">
                            <h6 class="fw-bold mb-3"><i class="fas fa-history me-2 text-primary"></i>Lịch sử Check-in</h6>
                            <div class="checkin-feed" id="checkinFeed">
                                <div class="text-center text-muted py-4" id="feedEmpty">
                                    <i class="fas fa-inbox fa-2x opacity-25 mb-2"></i>
                                    <p class="small mb-0">Chưa có check-in nào</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            </c:if>
        </div>
    </div>
</div>

<!-- html5-qrcode CDN -->
<script src="https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js"></script>

<script>
const eventId = '${event != null ? event.eventId : ""}';
const contextPath = '${pageContext.request.contextPath}';
let csrfToken = '${csrf_token}';
let html5QrCode = null;
let cameraOn = false;
let checkedInCount = parseInt('${checkedInCount != null ? checkedInCount : 0}') || 0;
let totalOrders = parseInt('${totalOrders != null ? totalOrders : 0}') || 0;

/** Escape HTML to prevent XSS in template literals */
function escapeHTML(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
}

function selectEvent(id) {
    if (id) window.location = contextPath + '/organizer/check-in?eventId=' + id;
}

// ========== CAMERA ==========
function toggleCamera() {
    if (cameraOn) {
        stopCamera();
    } else {
        startCamera();
    }
}

function startCamera() {
    const btn = document.getElementById('cameraToggle');
    document.getElementById('cameraPlaceholder').style.display = 'none';

    html5QrCode = new Html5Qrcode("reader");
    html5QrCode.start(
        { facingMode: "environment" },
        { fps: 10, qrbox: { width: 250, height: 250 } },
        onScanSuccess,
        () => {}
    ).then(() => {
        cameraOn = true;
        btn.innerHTML = '<i class="fas fa-video-slash me-1"></i><span>Tắt camera</span>';
        btn.classList.replace('btn-outline-primary', 'btn-primary');
        document.getElementById('scanOverlay').style.display = 'flex';
    }).catch(err => {
        showResult('error', 'Không thể truy cập camera', err.message || 'Kiểm tra quyền truy cập camera');
        document.getElementById('cameraPlaceholder').style.display = 'flex';
    });
}

function stopCamera() {
    if (html5QrCode) {
        html5QrCode.stop().then(() => {
            html5QrCode.clear();
            cameraOn = false;
            const btn = document.getElementById('cameraToggle');
            btn.innerHTML = '<i class="fas fa-video me-1"></i><span>Bật camera</span>';
            btn.classList.replace('btn-primary', 'btn-outline-primary');
            document.getElementById('scanOverlay').style.display = 'none';
            document.getElementById('cameraPlaceholder').style.display = 'flex';
        });
    }
}

// ========== SCAN HANDLER ==========
let lastScanned = '';
let lastScanTime = 0;

function onScanSuccess(code) {
    const now = Date.now();
    if (code === lastScanned && now - lastScanTime < 3000) return;
    lastScanned = code;
    lastScanTime = now;
    processCheckIn(code);
}

function checkInManual() {
    const input = document.getElementById('manualCode');
    const code = input.value.trim();
    if (!code) return;
    processCheckIn(code);
    input.value = '';
}

function processCheckIn(code) {
    showResult('loading', 'Đang xử lý...', escapeHTML(code));

    fetch(contextPath + '/organizer/check-in', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'eventId=' + encodeURIComponent(eventId)
            + '&orderCode=' + encodeURIComponent(code)
            + '&csrf_token=' + encodeURIComponent(csrfToken)
    })
    .then(r => {
        if (r.status === 403) throw new Error('CSRF');
        return r.json();
    })
    .then(data => {
        // Refresh CSRF token after successful validation (server rotates it)
        if (data.csrfToken) csrfToken = data.csrfToken;

        if (data.success) {
            showResult('success', 'Check-in thành công!', escapeHTML(data.customerName || code));
            addFeedItem(code, data.customerName, 'success');
            checkedInCount++;
            updateStats();
            playSound('success');
        } else if (data.alreadyCheckedIn) {
            showResult('warning', 'Đã check-in trước đó', 'Lúc ' + escapeHTML(data.checkInTime || 'trước đó'));
            addFeedItem(code, data.customerName, 'duplicate');
            playSound('error');
        } else {
            showResult('error', escapeHTML(data.message) || 'Mã không hợp lệ', escapeHTML(code));
            addFeedItem(code, null, 'invalid');
            playSound('error');
        }
    })
    .catch(err => {
        if (err.message === 'CSRF') {
            showResult('error', 'Phiên hết hạn', 'Vui lòng tải lại trang (F5)');
        } else {
            showResult('error', 'Lỗi kết nối', 'Vui lòng thử lại');
        }
        playSound('error');
    });
}

// ========== RESULT DISPLAY ==========
function showResult(type, title, subtitle) {
    const area = document.getElementById('resultArea');
    area.classList.remove('d-none');

    const configs = {
        success: { bg: 'result-success', icon: 'fa-check-circle', color: '#10b981' },
        warning: { bg: 'result-warning', icon: 'fa-exclamation-triangle', color: '#f59e0b' },
        error:   { bg: 'result-error',   icon: 'fa-times-circle', color: '#ef4444' },
        loading: { bg: '',               icon: 'fa-spinner fa-spin', color: 'var(--primary)' }
    };
    const cfg = configs[type];

    area.innerHTML = `
        <div class="result-card ${cfg.bg}">
            <div class="result-icon" style="background: ${cfg.color}20; color: ${cfg.color};">
                <i class="fas ${cfg.icon}"></i>
            </div>
            <h5 class="fw-bold mb-1">${escapeHTML(title)}</h5>
            <p class="text-muted small mb-0">${escapeHTML(subtitle)}</p>
        </div>
    `;

    if (type !== 'loading') {
        setTimeout(() => { area.classList.add('d-none'); }, 4000);
    }
}

// ========== STATS UPDATE ==========
function updateStats() {
    const el = document.getElementById('statCheckedIn');
    el.textContent = checkedInCount;
    el.classList.add('bump');
    setTimeout(() => el.classList.remove('bump'), 300);

    const remaining = Math.max(0, totalOrders - checkedInCount);
    document.getElementById('statRemaining').textContent = remaining;

    const pct = totalOrders > 0 ? Math.round(checkedInCount / totalOrders * 100) : 0;
    document.getElementById('donutPercent').textContent = pct + '%';
    document.getElementById('donutPath').setAttribute('stroke-dasharray', pct + ', 100');
}

// ========== FEED ==========
function addFeedItem(code, name, type) {
    const feed = document.getElementById('checkinFeed');
    document.getElementById('feedEmpty')?.remove();

    const colors = { success: '#10b981', duplicate: '#f59e0b', invalid: '#ef4444' };
    const icons = { success: 'fa-check', duplicate: 'fa-redo', invalid: 'fa-times' };
    const labels = { success: 'Thành công', duplicate: 'Đã check-in', invalid: 'Không hợp lệ' };

    const item = document.createElement('div');
    item.className = 'feed-item';
    item.innerHTML = `
        <div class="feed-icon" style="background: ${colors[type]}20; color: ${colors[type]};">
            <i class="fas ${icons[type]}"></i>
        </div>
        <div class="flex-grow-1">
            <div class="fw-medium small">${escapeHTML(name || code)}</div>
            <div class="text-muted" style="font-size:0.7rem;">${labels[type]} • ${new Date().toLocaleTimeString('vi-VN')}</div>
        </div>
    `;
    feed.insertBefore(item, feed.firstChild);
}

// ========== SOUND ==========
function playSound(type) {
    try {
        const ctx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.connect(gain); gain.connect(ctx.destination);
        gain.gain.setValueAtTime(0.15, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.3);
        osc.frequency.setValueAtTime(type === 'success' ? 880 : 220, ctx.currentTime);
        osc.start(); osc.stop(ctx.currentTime + 0.3);
    } catch(e) {}
}

// Init stats
updateStats();
</script>

<jsp:include page="../footer.jsp" />
