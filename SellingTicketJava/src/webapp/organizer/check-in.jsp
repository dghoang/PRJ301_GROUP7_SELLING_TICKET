<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

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

            <%-- Event Expired Warning --%>
            <c:if test="${eventExpired}">
                <div class="alert border-0 rounded-4 mb-4" style="background: rgba(239,68,68,0.08); border-left: 4px solid #ef4444 !important;">
                    <div class="d-flex align-items-center gap-2">
                        <i class="fas fa-exclamation-triangle text-danger fs-4"></i>
                        <div>
                            <strong class="text-danger">${expiredMessage}</strong>
                            <p class="text-muted small mb-0">Bạn chỉ có thể check-in cho sự kiện chưa kết thúc.</p>
                        </div>
                    </div>
                </div>
            </c:if>

            <%-- Event Date Check --%>
            <c:if test="${event != null}">
                <tags:eventDateCheck event="${event}" />
            </c:if>

            <!-- Mobile Access Banner (dynamic IPs) -->
            <c:if test="${not empty serverIPs}">
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll visible" style="border-left: 4px solid var(--primary) !important;">
                <div class="card-body p-3 d-flex align-items-center gap-3">
                    <div class="dash-icon-box" style="background: linear-gradient(135deg, #3b82f6, #06b6d4); width: 40px; height: 40px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                        <i class="fas fa-mobile-alt text-white"></i>
                    </div>
                    <div class="flex-grow-1">
                        <div class="fw-bold small mb-1"><i class="fas fa-wifi me-1"></i>Truy cập từ điện thoại (cùng WiFi):</div>
                        <c:forEach var="ip" items="${serverIPs}">
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <code class="text-primary" style="font-size: 0.85rem; user-select: all;" id="mobileUrl_${ip}">http://${ip}:${serverPort}${contextPath}/organizer/check-in</code>
                            <button class="btn btn-sm btn-outline-primary rounded-pill px-2 py-0" onclick="copyIP('mobileUrl_${ip}')" title="Copy">
                                <i class="fas fa-copy" style="font-size: 0.7rem;"></i>
                            </button>
                        </div>
                        </c:forEach>
                        <div class="text-muted mt-1" style="font-size: 0.7rem;">
                            <i class="fas fa-info-circle me-1"></i>Nếu trình duyệt báo lỗi "HTTPS-Only":
                            <strong>Chrome</strong> → Cài đặt → Bảo mật → Tắt "Luôn dùng kết nối an toàn" |
                            <strong>Firefox</strong> → Nhấn "Tiếp tục với HTTP"
                        </div>
                    </div>
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
                                <div class="d-flex gap-2">
                                    <button class="btn btn-sm btn-outline-secondary rounded-pill px-3" id="cameraSwitch" onclick="switchCamera()" style="display:none;">
                                        <i class="fas fa-sync-alt me-1"></i><span>Đổi camera</span>
                                    </button>
                                    <button class="btn btn-sm btn-outline-primary rounded-pill px-3" id="cameraToggle" onclick="toggleCamera()">
                                        <i class="fas fa-video me-1"></i><span>Bật camera</span>
                                    </button>
                                </div>
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
                                        placeholder="VD: ORD-... hoặc TIX-..." onkeypress="if(event.key==='Enter'){checkInManual();}">
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
                                        <div class="stat-val text-primary" id="statTotal">${totalTickets != null ? totalTickets : 0}</div>
                                        <div class="stat-lbl">Tổng vé</div>
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
var csrfToken = '${sessionScope.csrf_token}';
let html5QrCode = null;
let cameraOn = false;
let checkedInCount = parseInt('${checkedInCount != null ? checkedInCount : 0}') || 0;
let totalTickets = parseInt('${totalTickets != null ? totalTickets : 0}') || 0;
let availableCameras = [];
let activeCameraId = null;
let isProcessingScan = false;
let lastScanKey = '';
let lastScanAt = 0;
let scannerUnlockedAt = 0;

const SCAN_DEDUP_MS = 2500;
const SCAN_LOCK_MS = 900;
const MAX_FEED_ITEMS = 80;

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
        stopCamera(true);
    } else {
        startCamera();
    }
}

async function startCamera() {
    const btn = document.getElementById('cameraToggle');
    const switchBtn = document.getElementById('cameraSwitch');
    if (cameraOn) return;

    // Check if mediaDevices API is available (requires HTTPS or localhost)
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        const isLocalhost = ['localhost', '127.0.0.1', ''].includes(location.hostname);
        if (!isLocalhost) {
            showResult('error', 'Camera bị chặn do HTTP Local', 
                'Trên điện thoại, mở trình duyệt truy cập: <b class="text-primary mt-2 d-block user-select-all">chrome://flags/#unsafely-treat-insecure-origin-as-secure</b><br>Nhập IP: <b>http://' + location.hostname + (location.port ? ':' + location.port : '') + '</b> vào ô trống, chọn <b>Enable</b> rồi Relaunch. Hoặc sử dụng tính năng NHẬP MÃ THỦ CÔNG bên dưới.');
        } else {
            showResult('error', 'Trình duyệt không hỗ trợ',
                'Vui lòng sử dụng Chrome, Safari (trên iOS) hoặc Edge bản mới nhất');
        }
        return;
    }

    btn.disabled = true;
    document.getElementById('cameraPlaceholder').style.display = 'none';

    try {
        if (!html5QrCode) {
            html5QrCode = new Html5Qrcode("reader");
        }

        await refreshCameraList();
        if (!activeCameraId && availableCameras.length > 0) {
            const preferred = findPreferredCamera(availableCameras);
            activeCameraId = preferred.id;
        }

        const qrConfig = {
            fps: 8,
            aspectRatio: 4 / 3,
            disableFlip: true,
            qrbox: function(viewfinderWidth, viewfinderHeight) {
                const edge = Math.floor(Math.min(viewfinderWidth, viewfinderHeight) * 0.62);
                const size = Math.max(180, Math.min(260, edge));
                return { width: size, height: size };
            },
            formatsToSupport: [Html5QrcodeSupportedFormats.QR_CODE]
        };

        const cameraSource = activeCameraId ? { deviceId: { exact: activeCameraId } } : { facingMode: "environment" };

        await html5QrCode.start(
            cameraSource,
            qrConfig,
            onScanSuccess,
            () => {}
        );

        cameraOn = true;
        btn.innerHTML = '<i class="fas fa-video-slash me-1"></i><span>Tắt camera</span>';
        btn.classList.replace('btn-outline-primary', 'btn-primary');
        btn.disabled = false;
        if (switchBtn) {
            switchBtn.style.display = availableCameras.length > 1 ? 'inline-flex' : 'none';
            switchBtn.disabled = availableCameras.length <= 1;
        }
        document.getElementById('scanOverlay').style.display = 'flex';
        enforceCameraPreviewOrientation();
    } catch (err) {
        let msg = 'Kiểm tra quyền truy cập camera trong cài đặt trình duyệt';
        if (err.name === 'NotAllowedError') {
            msg = 'Bạn đã từ chối quyền camera. Nhấn biểu tượng 🔒 trên thanh địa chỉ để cấp lại';
        } else if (err.name === 'NotFoundError') {
            msg = 'Không tìm thấy camera. Kiểm tra webcam/camera thiết bị';
        } else if (err.name === 'NotReadableError') {
            msg = 'Camera đang được sử dụng bởi ứng dụng khác';
        }
        showResult('error', 'Không thể truy cập camera', msg);
        document.getElementById('cameraPlaceholder').style.display = 'flex';
        btn.disabled = false;
    }
}

async function stopCamera(resetActiveCamera) {
    const btn = document.getElementById('cameraToggle');
    const switchBtn = document.getElementById('cameraSwitch');

    if (html5QrCode) {
        try {
            await html5QrCode.stop();
            await html5QrCode.clear();
        } catch (e) {
            // Ignore stop/clear errors if stream is already closed.
        }
    }

    cameraOn = false;
    isProcessingScan = false;
    btn.innerHTML = '<i class="fas fa-video me-1"></i><span>Bật camera</span>';
    btn.classList.replace('btn-primary', 'btn-outline-primary');
    btn.disabled = false;
    if (switchBtn) {
        switchBtn.style.display = 'none';
        switchBtn.disabled = true;
    }
    if (resetActiveCamera) {
        activeCameraId = null;
    }
    document.getElementById('scanOverlay').style.display = 'none';
    document.getElementById('cameraPlaceholder').style.display = 'flex';
}

async function switchCamera() {
    if (!cameraOn || availableCameras.length < 2) return;
    const currentIndex = availableCameras.findIndex(function(c) { return c.id === activeCameraId; });
    const nextIndex = currentIndex >= 0 ? (currentIndex + 1) % availableCameras.length : 0;
    activeCameraId = availableCameras[nextIndex].id;
    await stopCamera(false);
    await startCamera();
}

async function refreshCameraList() {
    try {
        const cameras = await Html5Qrcode.getCameras();
        availableCameras = (cameras || []).map(function(cam) {
            return { id: cam.id, label: cam.label || '' };
        });
    } catch (e) {
        availableCameras = [];
    }
}

function findPreferredCamera(cameras) {
    if (!cameras || cameras.length === 0) return null;
    const preferred = cameras.find(function(cam) {
        const label = (cam.label || '').toLowerCase();
        return label.includes('back') || label.includes('rear') || label.includes('environment');
    });
    return preferred || cameras[0];
}

function enforceCameraPreviewOrientation() {
    setTimeout(function() {
        const videoEl = document.querySelector('#reader video');
        if (videoEl) {
            videoEl.style.transform = 'none';
        }
    }, 80);
}

// ========== SCAN HANDLER ==========
function onScanSuccess(code) {
    const now = Date.now();
    if (isProcessingScan || now < scannerUnlockedAt) return;

    const parsed = parseScannedPayload(code);
    if (!parsed.value) return;

    const key = parsed.kind + ':' + parsed.value;
    if (key === lastScanKey && now - lastScanAt < SCAN_DEDUP_MS) return;
    lastScanKey = key;
    lastScanAt = now;
    isProcessingScan = true;

    const action = parsed.kind === 'order'
        ? lookupOrder(parsed.value)
        : processQrCheckIn(parsed.value);

    Promise.resolve(action).finally(function() {
        isProcessingScan = false;
        scannerUnlockedAt = Date.now() + SCAN_LOCK_MS;
    });
}

function checkInManual() {
    const input = document.getElementById('manualCode');
    const code = (input.value || '').trim();
    if (!code) return;

    const parsed = parseScannedPayload(code);
    if (parsed.kind === 'order') {
        lookupOrder(parsed.value);
    } else {
        processQrCheckIn(parsed.value);
    }
    input.value = '';
}

function parseScannedPayload(raw) {
    let value = (raw || '').trim();
    if (!value) return { kind: 'qr', value: '' };

    if ((value.startsWith('http://') || value.startsWith('https://')) && value.indexOf('?') > 0) {
        try {
            const u = new URL(value);
            const fromQuery = u.searchParams.get('qrToken')
                || u.searchParams.get('token')
                || u.searchParams.get('code')
                || u.searchParams.get('orderCode')
                || u.searchParams.get('ticketCode');
            if (fromQuery) {
                value = fromQuery.trim();
            }
        } catch (e) {
            // Keep original value if URL parse fails.
        }
    }

    if (value.indexOf('%') >= 0) {
        try {
            value = decodeURIComponent(value).trim();
        } catch (e) {
            // Keep encoded text when decode fails.
        }
    }

    const upper = value.toUpperCase();
    if (upper.startsWith('ORD-') || upper.startsWith('TIX-')) {
        return { kind: 'order', value: upper };
    }

    return { kind: 'qr', value: value };
}

// ========== QR SCAN CHECK-IN ==========
function postCheckInApi(fields) {
    const body = Object.keys(fields).map(function(key) {
        return encodeURIComponent(key) + '=' + encodeURIComponent(fields[key] == null ? '' : fields[key]);
    }).join('&') + '&csrf_token=' + encodeURIComponent(csrfToken);

    return fetch(contextPath + '/organizer/check-in', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        credentials: 'same-origin',
        body: body
    }).then(function(r) {
        if (r.status === 403) throw new Error('CSRF');
        return r.json();
    }).then(function(data) {
        if (data && data.csrfToken) csrfToken = data.csrfToken;
        return data;
    });
}

function processQrCheckIn(code) {
    showResult('loading', 'Đang xử lý QR...', '');

    return postCheckInApi({ eventId: eventId, qrToken: code })
    .then(data => {
        // Use ticketCode for display, NEVER the raw token
        const displayCode = data.ticketCode || 'QR vé';
        if (data.success) {
            showResult('success', 'Check-in thành công!', escapeHTML(data.customerName || '') + (data.ticketType ? ' — ' + escapeHTML(data.ticketType) : ''));
            addFeedItem(displayCode, data.customerName, 'success');
            checkedInCount++;
            updateStats();
            playSound('success');
        } else if (data.alreadyCheckedIn) {
            showResult('warning', 'Đã check-in trước đó', escapeHTML(data.customerName || displayCode));
            addFeedItem(displayCode, data.customerName, 'duplicate');
            playSound('error');
        } else {
            showResult('error', escapeHTML(data.message) || 'QR không hợp lệ', escapeHTML(displayCode));
            addFeedItem(displayCode, null, 'invalid');
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

// ========== ORDER LOOKUP → TICKET PICKER ==========
function lookupOrder(orderCode) {
    showResult('loading', 'Đang tra cứu đơn hàng...', escapeHTML(orderCode));

    return postCheckInApi({ eventId: eventId, orderCode: orderCode })
    .then(data => {
        if (data.success && data.action === 'lookup') {
            showTicketPicker(data);
        } else {
            showResult('error', escapeHTML(data.message) || 'Lỗi tra cứu', escapeHTML(orderCode));
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

function showTicketPicker(data) {
    const area = document.getElementById('resultArea');
    area.classList.remove('d-none');

    const allChecked = data.tickets.every(t => t.checkedIn);
    let html = '<div class="result-card" style="text-align:left;padding:16px;">'
        + '<div class="d-flex align-items-center gap-2 mb-3">'
        + '<div class="result-icon" style="background:#3b82f620;color:#3b82f6;width:36px;height:36px;"><i class="fas fa-user"></i></div>'
        + '<div><div class="fw-bold">' + escapeHTML(data.customerName) + '</div>'
        + '<div class="text-muted small">Đơn hàng: ' + escapeHTML(data.orderCode) + '</div></div></div>'
        + '<div class="mb-2 small fw-bold text-muted">Chọn vé để check-in:</div>';

    data.tickets.forEach(t => {
        const checked = t.checkedIn;
        html += '<div class="d-flex align-items-center gap-2 p-2 mb-2 rounded-3" style="background:' + (checked ? 'var(--bs-success-bg-subtle,#d1e7dd)' : 'var(--bs-light,#f8f9fa)') + ';">'
            + '<div style="width:36px;height:36px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:0.8rem;'
            + (checked ? 'background:#10b98120;color:#10b981;">' : 'background:#3b82f620;color:#3b82f6;">')
            + '<i class="fas ' + (checked ? 'fa-check-circle' : 'fa-ticket-alt') + '"></i></div>'
            + '<div class="flex-grow-1"><div class="fw-medium small">' + escapeHTML(t.attendeeName || 'Khách') + '</div>'
            + '<div class="text-muted" style="font-size:0.75rem;"><code style="font-size:0.7rem;color:var(--primary);">' + escapeHTML(t.ticketCode) + '</code> &bull; ' + escapeHTML(t.ticketType) + '</div></div>';
        if (checked) {
            html += '<span class="badge bg-success bg-opacity-75 rounded-pill">Đã check-in</span>';
        } else {
            html += '<button class="btn btn-sm btn-primary rounded-pill px-3" '
                + 'onclick="checkInTicket(\'' + escapeHTML(data.orderCode) + '\',' + t.ticketId + ',this)">'
                + '<i class="fas fa-check me-1"></i>Check-in</button>';
        }
        html += '</div>';
    });

    if (allChecked) {
        html += '<div class="text-center text-success small mt-2"><i class="fas fa-check-circle me-1"></i>Tất cả vé đã được check-in</div>';
    }

    html += '<button class="btn btn-sm btn-outline-secondary w-100 mt-2 rounded-pill" onclick="document.getElementById(\'resultArea\').classList.add(\'d-none\')"><i class="fas fa-times me-1"></i>Đóng</button>';
    html += '</div>';
    area.innerHTML = html;
}

function checkInTicket(orderCode, ticketId, btn) {
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';

    return postCheckInApi({
        eventId: eventId,
        orderCode: orderCode,
        action: 'checkin',
        ticketId: ticketId
    })
    .then(data => {
        if (data.success) {
            // Update button to checked state
            const row = btn.closest('.d-flex');
            row.style.background = 'var(--bs-success-bg-subtle,#d1e7dd)';
            const icon = row.querySelector('.fa-ticket-alt');
            if (icon) { icon.className = 'fas fa-check-circle'; icon.closest('div').style.color = '#10b981'; icon.closest('div').style.background = '#10b98120'; }
            btn.outerHTML = '<span class="badge bg-success bg-opacity-75 rounded-pill">Đã check-in</span>';
            addFeedItem(orderCode, data.customerName, 'success');
            checkedInCount++;
            updateStats();
            playSound('success');
        } else if (data.alreadyCheckedIn) {
            btn.outerHTML = '<span class="badge bg-warning bg-opacity-75 rounded-pill">Đã check-in</span>';
            playSound('error');
        } else {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-times me-1"></i>Thử lại';
            playSound('error');
        }
    })
    .catch(() => {
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-redo me-1"></i>Thử lại';
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

    area.innerHTML = '<div class="result-card ' + cfg.bg + '">'
        + '<div class="result-icon" style="background:' + cfg.color + '20;color:' + cfg.color + ';">'
        + '<i class="fas ' + cfg.icon + '"></i></div>'
        + '<h5 class="fw-bold mb-1">' + escapeHTML(title) + '</h5>'
        + '<p class="text-muted small mb-0">' + escapeHTML(subtitle) + '</p>'
        + '</div>';

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

    const remaining = Math.max(0, totalTickets - checkedInCount);
    document.getElementById('statRemaining').textContent = remaining;

    const pct = totalTickets > 0 ? Math.round(checkedInCount / totalTickets * 100) : 0;
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
    item.innerHTML = '<div class="feed-icon" style="background:' + colors[type] + '20;color:' + colors[type] + ';">'
        + '<i class="fas ' + icons[type] + '"></i></div>'
        + '<div class="flex-grow-1">'
        + '<div class="fw-medium small">' + escapeHTML(name || code) + '</div>'
        + '<div class="text-muted" style="font-size:0.7rem;">' + labels[type] + ' \u2022 ' + new Date().toLocaleTimeString('vi-VN') + '</div>'
        + '</div>';
    feed.insertBefore(item, feed.firstChild);

    while (feed.children.length > MAX_FEED_ITEMS) {
        feed.removeChild(feed.lastElementChild);
    }
}

// ========== SOUND ==========
let audioContext = null;
let lastSoundPlayedAt = 0;

function playSound(type) {
    try {
        const now = Date.now();
        if (now - lastSoundPlayedAt < 120) return;
        lastSoundPlayedAt = now;

        if (!audioContext) {
            audioContext = new (window.AudioContext || window.webkitAudioContext)();
        }
        if (audioContext.state === 'suspended') {
            audioContext.resume();
        }

        const osc = audioContext.createOscillator();
        const gain = audioContext.createGain();
        osc.connect(gain);
        gain.connect(audioContext.destination);
        gain.gain.setValueAtTime(0.12, audioContext.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.18);
        osc.frequency.setValueAtTime(type === 'success' ? 880 : 220, audioContext.currentTime);
        osc.start();
        osc.stop(audioContext.currentTime + 0.18);
    } catch(e) {}
}

// Init stats
updateStats();

window.addEventListener('beforeunload', function() {
    if (cameraOn) {
        stopCamera(false);
    }
});

// Copy IP to clipboard
function copyIP(elementId) {
    const el = document.getElementById(elementId);
    if (!el) return;
    const text = el.textContent;
    navigator.clipboard.writeText(text).then(() => {
        const btn = el.nextElementSibling;
        if (btn) {
            btn.innerHTML = '<i class="fas fa-check" style="font-size:0.7rem;"></i>';
            setTimeout(() => { btn.innerHTML = '<i class="fas fa-copy" style="font-size:0.7rem;"></i>'; }, 2000);
        }
    }).catch(() => {
        // Fallback for older browsers
        const range = document.createRange();
        range.selectNodeContents(el);
        window.getSelection().removeAllRanges();
        window.getSelection().addRange(range);
    });
}
</script>

<jsp:include page="../footer.jsp" />
