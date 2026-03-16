<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

<c:set var="pageTitle" value="Chat khách hàng" scope="request" />
<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="chat"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-comments text-primary me-2"></i>Chat khách hàng</h2>
                    <p class="text-muted mb-0">Trả lời câu hỏi từ khách hàng về sự kiện của bạn</p>
                </div>
            </div>

            <div class="row g-4">
                <%-- Sessions List --%>
                <div class="col-lg-4">
                    <div class="card glass-strong border-0 rounded-4 h-100">
                        <div class="card-header bg-transparent border-0 pt-4 px-4">
                            <h5 class="fw-bold mb-0"><i class="fas fa-list text-primary me-2"></i>Phiên chat</h5>
                        </div>
                        <div class="card-body px-4 pb-4" id="sessionsList" style="max-height: 500px; overflow-y: auto;">
                            <div class="text-center text-muted py-4">
                                <i class="fas fa-spinner fa-spin me-1"></i>Đang tải...
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Chat Window --%>
                <div class="col-lg-8">
                    <div class="card glass-strong border-0 rounded-4 h-100 d-flex flex-column">
                        <div class="card-header bg-transparent border-0 pt-4 px-4 d-flex justify-content-between align-items-center" id="chatHeader">
                            <h5 class="fw-bold mb-0"><i class="fas fa-comments text-primary me-2"></i>Tin nhắn</h5>
                            <button class="btn btn-sm btn-outline-danger rounded-pill px-3" id="orgCloseBtn" style="display:none;" onclick="orgCloseSession()">
                                <i class="fas fa-times me-1"></i>Đóng phiên
                            </button>
                        </div>
                        <div class="card-body px-4 pb-0 flex-grow-1" id="orgChatMessages" style="height: 420px; overflow-y: auto;">
                            <div class="text-center text-muted py-5">
                                <i class="fas fa-comment-dots fa-3x mb-3 opacity-25"></i>
                                <p class="fw-medium mb-1">Chọn một phiên chat</p>
                                <p class="small mb-0">Chọn phiên chat bên trái để bắt đầu hỗ trợ</p>
                            </div>
                        </div>
                        <div class="card-footer bg-transparent border-0 p-3" id="orgChatInput" style="display:none;">
                            <div class="d-flex gap-2">
                                <input type="text" id="orgAgentInput" class="form-control glass-input rounded-pill" placeholder="Nhập phản hồi..." onkeydown="if(event.key==='Enter')orgSend()" autocomplete="off">
                                <button class="btn btn-gradient rounded-circle hover-glow" style="width: 42px; height: 42px; flex-shrink: 0;" onclick="orgSend()">
                                    <i class="fas fa-paper-plane"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.org-session-item {
    cursor: pointer;
    transition: all 0.2s;
    border-radius: 12px !important;
}
.org-session-item:hover {
    background: rgba(59,130,246,0.06) !important;
}
.org-session-item.active-session {
    background: rgba(59,130,246,0.1) !important;
    border-left: 3px solid #3b82f6 !important;
}
.org-chat-bubble-me {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    border-radius: 16px 16px 4px 16px;
}
.org-chat-bubble-user {
    background: rgba(0,0,0,0.04);
    border-radius: 16px 16px 16px 4px;
}
@media (prefers-color-scheme: dark) {
    .org-chat-bubble-user { background: rgba(255,255,255,0.08); }
}
</style>

<script>
const CTX = '${pageContext.request.contextPath}';
const ORG_ID = ${sessionScope.user != null ? sessionScope.user.userId : 0};
const CSRF_TOKEN = '${sessionScope.csrf_token}';
let orgActiveSessionId = 0, orgLastMsgId = 0, orgPollTimer = null;

function withCsrf(body) {
    const base = body ? body + '&' : '';
    return base + 'csrf_token=' + encodeURIComponent(CSRF_TOKEN || '');
}

async function fetchJsonSafe(url, options) {
    const res = await fetch(url, options);
    const text = await res.text();
    if (!text) return [];
    try { return JSON.parse(text); } catch (e) { throw new Error('INVALID_JSON'); }
}

async function postFormSafe(url, body) {
    return fetchJsonSafe(url, {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        credentials:'same-origin',
        body
    });
}

function orgLoadSessions() {
    fetchJsonSafe(CTX + '/api/chat/sessions?type=my-events')
    .then(sessions => {
        const box = document.getElementById('sessionsList');
        if (!sessions || sessions.length === 0) {
            box.innerHTML = '<div class="text-center text-muted py-4"><i class="fas fa-inbox fa-2x mb-2 opacity-25 d-block"></i><p class="mb-0 small">Không có phiên chat nào</p></div>';
            return;
        }
        box.innerHTML = sessions.map(s => {
            const isActive = s.id === orgActiveSessionId;
            const statusColor = s.status === 'waiting' ? 'linear-gradient(135deg,#f59e0b,#f97316)' : 'linear-gradient(135deg,#10b981,#06b6d4)';
            const statusLabel = s.status === 'waiting' ? 'Chờ' : 'Active';
            const unread = Number(s.unreadCount || 0);
            const unreadBadge = unread > 0
                ? '<span class="badge bg-danger rounded-pill ms-2" style="font-size:0.62rem;">' + unread + '</span>'
                : '';
            const onlineDot = s.customerOnline
                ? '<span class="d-inline-block rounded-circle ms-1" style="width:8px;height:8px;background:#10b981;" title="Online"></span>'
                : '<span class="d-inline-block rounded-circle ms-1" style="width:8px;height:8px;background:#9ca3af;" title="Offline"></span>';
            return '<div class="org-session-item d-flex align-items-center gap-3 p-3 mb-2 ' + (isActive ? 'active-session' : '') + '" onclick="orgSelectSession(' + s.id + ')">'
            + '<div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width:40px;height:40px;background:' + statusColor + ';"><i class="fas fa-user text-white" style="font-size:0.8rem;"></i></div>'
            + '<div class="flex-grow-1" style="min-width:0;">'
            + '<div class="fw-medium small text-truncate">' + escHtml(s.customerName || 'Khách') + onlineDot + unreadBadge + '</div>'
            + '<small class="text-muted">' + escHtml(s.eventTitle || 'Sự kiện') + ' · ' + escHtml(s.time || '') + '</small></div>'
            + '<span class="badge rounded-pill px-2" style="background:' + statusColor + ';color:white;font-size:0.6rem;">' + statusLabel + '</span>'
            + '</div>';
        }).join('');
    }).catch(() => {
        document.getElementById('sessionsList').innerHTML = '<div class="text-center text-muted py-4"><i class="fas fa-exclamation-triangle fa-2x mb-2 opacity-25 d-block"></i><p class="mb-0 small">Lỗi tải phiên chat</p></div>';
    });
}

function orgSelectSession(id) {
    orgActiveSessionId = id;
    orgLastMsgId = 0;
    document.getElementById('orgChatInput').style.display = 'block';
    document.getElementById('orgCloseBtn').style.display = 'inline-block';
    fetch(CTX + '/api/chat/accept', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:withCsrf('sessionId=' + id)}).catch(() => {});
    orgLoadMessages();
    if (orgPollTimer) clearInterval(orgPollTimer);
    orgPollTimer = setInterval(orgLoadMessages, 5000);
    orgLoadSessions();
}

function orgCloseSession() {
    if (!orgActiveSessionId || !confirm('Đóng phiên chat này?')) return;
    postFormSafe(CTX + '/api/chat/close', withCsrf('sessionId=' + orgActiveSessionId))
    .then(() => {
        orgActiveSessionId = 0;
        orgLastMsgId = 0;
        if (orgPollTimer) clearInterval(orgPollTimer);
        document.getElementById('orgChatInput').style.display = 'none';
        document.getElementById('orgCloseBtn').style.display = 'none';
        document.getElementById('orgChatMessages').innerHTML = '<div class="text-center text-muted py-5"><i class="fas fa-check-circle fa-3x mb-3 text-success opacity-50"></i><p class="fw-medium mb-1">Phiên chat đã đóng</p></div>';
        orgLoadSessions();
    }).catch(() => {});
}

function orgLoadMessages() {
    if (!orgActiveSessionId) return;
    fetchJsonSafe(CTX + '/api/chat/messages?sessionId=' + orgActiveSessionId + '&after=' + orgLastMsgId)
    .then(msgs => {
        const box = document.getElementById('orgChatMessages');
        if (orgLastMsgId === 0) box.innerHTML = '';
        if (!msgs || msgs.length === 0) {
            if (orgLastMsgId === 0) {
                box.innerHTML = '<div class="text-center text-muted py-4"><p class="mb-0 small">Chưa có tin nhắn</p></div>';
            }
            return;
        }
        msgs.forEach(m => {
            orgLastMsgId = Math.max(orgLastMsgId, m.id);
            const isMe = m.senderId === ORG_ID;
            const div = document.createElement('div');
            div.className = 'd-flex mb-3 ' + (isMe ? 'justify-content-end' : 'justify-content-start');
            div.innerHTML = '<div class="px-3 py-2 small ' + (isMe ? 'org-chat-bubble-me' : 'org-chat-bubble-user') + '" style="max-width:75%;word-wrap:break-word;">'
                + '<div class="d-flex justify-content-between gap-3 mb-1"><small class="fw-bold" style="opacity:0.85;">' + (m.senderName || '') + '</small><small style="opacity:0.6;font-size:0.7rem;">' + (m.time || '') + '</small></div>'
                + '<div>' + escHtml(m.content || '') + '</div></div>';
            box.appendChild(div);
        });
        box.scrollTop = box.scrollHeight;
    }).catch(() => {});
}

function orgSend() {
    const inp = document.getElementById('orgAgentInput');
    const msg = inp.value.trim();
    if (!msg || !orgActiveSessionId) return;
    inp.value = '';
    postFormSafe(CTX + '/api/chat/send', withCsrf('sessionId=' + orgActiveSessionId + '&content=' + encodeURIComponent(msg)))
    .then((res) => {
        if (res && res.error) {
            alert(res.error);
            return;
        }
        orgLoadMessages();
    }).catch(() => {});
}

function escHtml(text) {
    const d = document.createElement('div');
    d.textContent = text;
    return d.innerHTML;
}

// Initial load + auto-refresh sessions
orgLoadSessions();
setInterval(orgLoadSessions, 10000);
</script>

<jsp:include page="../footer.jsp" />
