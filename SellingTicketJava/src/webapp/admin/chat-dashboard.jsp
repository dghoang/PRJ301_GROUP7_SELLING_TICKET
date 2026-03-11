<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

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
                    <h2 class="fw-bold mb-1"><i class="fas fa-comments text-primary me-2"></i>Chat Dashboard</h2>
                    <p class="text-muted mb-0">Quản lý các phiên chat hỗ trợ khách hàng</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin/chat-dashboard?type=system" class="btn ${param.type == 'system' || empty param.type ? 'btn-gradient' : 'glass'} rounded-pill px-3 small">
                        <i class="fas fa-cog me-1"></i>Hệ thống
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/chat-dashboard?type=event" class="btn ${param.type == 'event' ? 'btn-gradient' : 'glass'} rounded-pill px-3 small">
                        <i class="fas fa-calendar me-1"></i>Sự kiện
                    </a>
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
                        </div>
                        <div class="card-body px-4 pb-0 flex-grow-1" id="adminChatMessages" style="height: 420px; overflow-y: auto;">
                            <div class="text-center text-muted py-5">
                                <i class="fas fa-comment-dots fa-3x mb-3 opacity-25"></i>
                                <p class="fw-medium mb-1">Chọn một phiên chat</p>
                                <p class="small mb-0">Chọn phiên chat bên trái để bắt đầu hỗ trợ</p>
                            </div>
                        </div>
                        <div class="card-footer bg-transparent border-0 p-3" id="adminChatInput" style="display:none;">
                            <div class="d-flex gap-2">
                                <input type="text" id="agentInput" class="form-control glass-input rounded-pill" placeholder="Nhập phản hồi..." onkeydown="if(event.key==='Enter')agentSend()" autocomplete="off">
                                <button class="btn btn-gradient rounded-circle hover-glow" style="width: 42px; height: 42px; flex-shrink: 0;" onclick="agentSend()">
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
.chat-session-item {
    cursor: pointer;
    transition: all 0.2s;
    border-radius: 12px !important;
}
.chat-session-item:hover {
    background: rgba(59,130,246,0.06) !important;
}
.chat-session-item.active-session {
    background: rgba(59,130,246,0.1) !important;
    border-left: 3px solid #3b82f6 !important;
}
.chat-bubble-admin {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    border-radius: 16px 16px 4px 16px;
}
.chat-bubble-user {
    background: rgba(0,0,0,0.04);
    border-radius: 16px 16px 16px 4px;
}
@media (prefers-color-scheme: dark) {
    .chat-bubble-user { background: rgba(255,255,255,0.08); }
}
</style>

<script>
const CTX = '${pageContext.request.contextPath}';
const AGENT_ID = ${sessionScope.user != null ? sessionScope.user.userId : 0};
let activeSessionId = 0, agentLastMsgId = 0, agentPollTimer = null;
const chatType = new URLSearchParams(window.location.search).get('type') || 'system';

function loadSessions() {
    fetch(CTX + '/api/chat/sessions?type=' + chatType)
    .then(r => r.json()).then(sessions => {
        const box = document.getElementById('sessionsList');
        if (!sessions || sessions.length === 0) {
            box.innerHTML = '<div class="text-center text-muted py-4"><i class="fas fa-inbox fa-2x mb-2 opacity-25 d-block"></i><p class="mb-0 small">Không có phiên chat nào</p></div>';
            return;
        }
        box.innerHTML = sessions.map(s => {
            const isActive = s.id === activeSessionId;
            const statusColor = s.status === 'waiting' ? 'linear-gradient(135deg,#f59e0b,#f97316)' : 'linear-gradient(135deg,#10b981,#06b6d4)';
            const statusLabel = s.status === 'waiting' ? 'Chờ' : 'Active';
            return '<div class="chat-session-item d-flex align-items-center gap-3 p-3 mb-2 ' + (isActive ? 'active-session' : '') + '" onclick="selectSession(' + s.id + ')">'
            + '<div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width:40px;height:40px;background:' + statusColor + ';"><i class="fas fa-user text-white" style="font-size:0.8rem;"></i></div>'
            + '<div class="flex-grow-1" style="min-width:0;">'
            + '<div class="fw-medium small text-truncate">' + (s.customerName || 'Khách') + '</div>'
            + '<small class="text-muted">' + (s.eventTitle || 'Hệ thống') + ' · ' + (s.time || '') + '</small></div>'
            + '<span class="badge rounded-pill px-2" style="background:' + statusColor + ';color:white;font-size:0.6rem;">' + statusLabel + '</span>'
            + '</div>';
        }).join('');
    }).catch(() => {
        document.getElementById('sessionsList').innerHTML = '<div class="text-center text-muted py-4"><i class="fas fa-exclamation-triangle fa-2x mb-2 opacity-25 d-block"></i><p class="mb-0 small">Lỗi tải phiên chat</p></div>';
    });
}

function selectSession(id) {
    activeSessionId = id;
    agentLastMsgId = 0;
    document.getElementById('adminChatInput').style.display = 'block';
    fetch(CTX + '/api/chat/accept', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'sessionId=' + id}).catch(() => {});
    loadMessages();
    if (agentPollTimer) clearInterval(agentPollTimer);
    agentPollTimer = setInterval(loadMessages, 5000);
    loadSessions();
}

function loadMessages() {
    if (!activeSessionId) return;
    fetch(CTX + '/api/chat/messages?sessionId=' + activeSessionId + '&after=' + agentLastMsgId)
    .then(r => r.json()).then(msgs => {
        const box = document.getElementById('adminChatMessages');
        if (agentLastMsgId === 0) box.innerHTML = '';
        if (!msgs || msgs.length === 0) {
            if (agentLastMsgId === 0) {
                box.innerHTML = '<div class="text-center text-muted py-4"><p class="mb-0 small">Chưa có tin nhắn</p></div>';
            }
            return;
        }
        msgs.forEach(m => {
            agentLastMsgId = Math.max(agentLastMsgId, m.id);
            const isMe = m.senderId === AGENT_ID;
            const div = document.createElement('div');
            div.className = 'd-flex mb-3 ' + (isMe ? 'justify-content-end' : 'justify-content-start');
            div.innerHTML = '<div class="px-3 py-2 small ' + (isMe ? 'chat-bubble-admin' : 'chat-bubble-user') + '" style="max-width:75%;word-wrap:break-word;">'
                + '<div class="d-flex justify-content-between gap-3 mb-1"><small class="fw-bold" style="opacity:0.85;">' + (m.senderName || '') + '</small><small style="opacity:0.6;font-size:0.7rem;">' + (m.time || '') + '</small></div>'
                + '<div>' + (m.content || '') + '</div></div>';
            box.appendChild(div);
        });
        box.scrollTop = box.scrollHeight;
    }).catch(() => {});
}

function agentSend() {
    const inp = document.getElementById('agentInput');
    const msg = inp.value.trim();
    if (!msg || !activeSessionId) return;
    inp.value = '';
    fetch(CTX + '/api/chat/send', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'sessionId=' + activeSessionId + '&content=' + encodeURIComponent(msg)})
    .then(() => loadMessages()).catch(() => {});
}

// Init
loadSessions();
setInterval(loadSessions, 10000);
</script>

<jsp:include page="../footer.jsp" />
