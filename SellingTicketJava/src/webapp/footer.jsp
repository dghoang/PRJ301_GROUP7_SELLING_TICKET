<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

    </main>
    
    <!-- Footer -->
    <footer class="mt-auto glass-strong border-top">
        <div class="container py-5">
            <div class="row g-4">
                <!-- Brand -->
                <div class="col-lg-4">
                    <div class="d-flex align-items-center gap-2 mb-3">
                        <div class="rounded-3 d-flex align-items-center justify-content-center text-white btn-gradient" style="width: 40px; height: 40px;">
                            <i class="fas fa-ticket-alt"></i>
                        </div>
                        <span class="fw-bold fs-5 text-gradient">Ticketbox</span>
                    </div>
                    <p class="text-muted small mb-4" style="max-width: 280px;">
                        Nền tảng đặt vé sự kiện hàng đầu Việt Nam. Khám phá và đặt vé cho các sự kiện âm nhạc, thể thao, hội thảo và nhiều hơn nữa.
                    </p>
                    <div class="d-flex gap-2">
                        <a href="https://facebook.com" target="_blank" rel="noopener noreferrer" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-facebook-f text-primary"></i>
                        </a>
                        <a href="https://instagram.com" target="_blank" rel="noopener noreferrer" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-instagram text-danger"></i>
                        </a>
                        <a href="https://youtube.com" target="_blank" rel="noopener noreferrer" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-youtube text-danger"></i>
                        </a>
                        <a href="https://tiktok.com" target="_blank" rel="noopener noreferrer" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-tiktok"></i>
                        </a>
                    </div>
                </div>
                
                <!-- Discovery (categories) -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Khám phá</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events" class="text-muted text-decoration-none hover-primary">Tất cả sự kiện</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=music" class="text-muted text-decoration-none hover-primary"><i class="fas fa-music me-1" style="font-size:0.7rem;"></i>Âm nhạc</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=sports" class="text-muted text-decoration-none hover-primary"><i class="fas fa-futbol me-1" style="font-size:0.7rem;"></i>Thể thao</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=workshop" class="text-muted text-decoration-none hover-primary"><i class="fas fa-laptop me-1" style="font-size:0.7rem;"></i>Workshop</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=food" class="text-muted text-decoration-none hover-primary"><i class="fas fa-utensils me-1" style="font-size:0.7rem;"></i>Ẩm thực</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=art" class="text-muted text-decoration-none hover-primary"><i class="fas fa-palette me-1" style="font-size:0.7rem;"></i>Nghệ thuật</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=technology" class="text-muted text-decoration-none hover-primary"><i class="fas fa-microchip me-1" style="font-size:0.7rem;"></i>Công nghệ</a></li>
                    </ul>
                </div>
                
                <!-- Tài khoản - role-based -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Tài khoản</h6>
                    <ul class="list-unstyled small">
                        <c:choose>
                            <c:when test="${not empty sessionScope.account}">
                                <li class="mb-2"><a href="${pageContext.request.contextPath}/profile" class="text-muted text-decoration-none hover-primary"><i class="fas fa-user me-1" style="font-size:0.7rem;"></i>Hồ sơ</a></li>
                                <li class="mb-2"><a href="${pageContext.request.contextPath}/my-tickets" class="text-muted text-decoration-none hover-primary"><i class="fas fa-ticket-alt me-1" style="font-size:0.7rem;"></i>Vé của tôi</a></li>
                                <li class="mb-2"><a href="${pageContext.request.contextPath}/organizer/create-event" class="text-muted text-decoration-none hover-primary"><i class="fas fa-plus-circle me-1" style="font-size:0.7rem;"></i>Tạo sự kiện</a></li>
                                <li class="mb-2"><a href="${pageContext.request.contextPath}/organizer/events" class="text-muted text-decoration-none hover-primary"><i class="fas fa-calendar-check me-1" style="font-size:0.7rem;"></i>Sự kiện của tôi</a></li>
                                <c:if test="${sessionScope.account.role == 'admin'}">
                                <li class="mb-2"><a href="${pageContext.request.contextPath}/admin/dashboard" class="text-muted text-decoration-none hover-primary"><i class="fas fa-shield-alt me-1" style="font-size:0.7rem;"></i>Quản trị</a></li>
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                <li class="mb-2"><a href="${pageContext.request.contextPath}/login" class="text-muted text-decoration-none hover-primary"><i class="fas fa-sign-in-alt me-1" style="font-size:0.7rem;"></i>Đăng nhập</a></li>
                                <li class="mb-2"><a href="${pageContext.request.contextPath}/register" class="text-muted text-decoration-none hover-primary"><i class="fas fa-user-plus me-1" style="font-size:0.7rem;"></i>Đăng ký</a></li>
                                <li class="mb-2"><a href="${pageContext.request.contextPath}/about" class="text-muted text-decoration-none hover-primary"><i class="fas fa-info-circle me-1" style="font-size:0.7rem;"></i>Giới thiệu</a></li>
                            </c:otherwise>
                        </c:choose>
                    </ul>
                </div>
                
                <!-- Hỗ trợ -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Hỗ trợ</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/faq" class="text-muted text-decoration-none hover-primary"><i class="fas fa-question-circle me-1" style="font-size:0.7rem;"></i>Trung tâm trợ giúp</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/terms" class="text-muted text-decoration-none hover-primary"><i class="fas fa-file-contract me-1" style="font-size:0.7rem;"></i>Điều khoản sử dụng</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/terms#privacy" class="text-muted text-decoration-none hover-primary"><i class="fas fa-user-shield me-1" style="font-size:0.7rem;"></i>Chính sách bảo mật</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/about" class="text-muted text-decoration-none hover-primary"><i class="fas fa-building me-1" style="font-size:0.7rem;"></i>Về chúng tôi</a></li>
                        <c:if test="${not empty sessionScope.account}">
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/support/my-tickets" class="text-muted text-decoration-none hover-primary"><i class="fas fa-headset me-1" style="font-size:0.7rem;"></i>Yêu cầu hỗ trợ</a></li>
                        </c:if>
                    </ul>
                </div>
                
                <!-- Liên hệ -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Liên hệ</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-3">
                            <a href="mailto:support@ticketbox.vn" class="text-muted text-decoration-none d-flex align-items-center gap-2 hover-primary">
                                <i class="fas fa-envelope text-primary"></i>support@ticketbox.vn
                            </a>
                        </li>
                        <li class="mb-3">
                            <a href="tel:19006408" class="text-muted text-decoration-none d-flex align-items-center gap-2 hover-primary">
                                <i class="fas fa-phone text-primary"></i>1900 6408
                            </a>
                        </li>
                        <li class="mb-3">
                            <span class="text-muted d-flex align-items-start gap-2">
                                <i class="fas fa-map-marker-alt text-primary mt-1"></i>
                                <span>Hà Nội, Việt Nam</span>
                            </span>
                        </li>
                        <li>
                            <span class="text-muted d-flex align-items-center gap-2">
                                <i class="fas fa-clock text-primary"></i>
                                <span>8:00 - 22:00 hàng ngày</span>
                            </span>
                        </li>
                    </ul>
                </div>
            </div>
            
            <hr class="my-4 opacity-25">
            
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3">
                <p class="small text-muted mb-0">&copy; <%= java.time.Year.now().getValue() %> Ticketbox. All rights reserved.</p>
                <div class="d-flex gap-3">
                    <a href="${pageContext.request.contextPath}/terms#privacy" class="small text-muted text-decoration-none hover-primary">Bảo mật</a>
                    <a href="${pageContext.request.contextPath}/terms" class="small text-muted text-decoration-none hover-primary">Điều khoản</a>
                    <a href="javascript:void(0)" onclick="showInfo('Trang web sử dụng cookies để cải thiện trải nghiệm.')" class="small text-muted text-decoration-none hover-primary">Cookies</a>
                </div>
            </div>
        </div>
    </footer>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Toast Notifications -->
    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    
    <!-- Animations JS -->
    <script src="${pageContext.request.contextPath}/assets/js/animations.js"></script>
    
    <script>
    // Check login status (set by JSP)
    const isLoggedIn = "${sessionScope.account != null}" === "true";
    
    // Require login function for protected links
    function requireLogin(element) {
        if (!isLoggedIn) {
            const evt = window.event;
            if (evt) {
                evt.preventDefault();
            }

            let returnPath = '/home';
            try {
                const targetUrl = new URL(element.getAttribute('href') || element.href, window.location.origin);
                returnPath = targetUrl.pathname + targetUrl.search + targetUrl.hash;
            } catch (e) {
                // Keep safe fallback when URL parsing fails.
            }

            showWarning('Vui lòng đăng nhập để tiếp tục');
            setTimeout(() => {
                window.location.href = '${pageContext.request.contextPath}/login?returnUrl=' + encodeURIComponent(returnPath);
            }, 1500);
            return false;
        }
        return true;
    }
    </script>
    
    <style>
    .hover-primary:hover {
        color: var(--primary) !important;
        transition: color 0.2s ease;
    }
    </style>
    <!-- Floating Chat Widget (only for logged-in customers) -->
    <c:if test="${not empty sessionScope.user && sessionScope.user.role != 'admin'}">
    <div id="chatWidget" style="position:fixed;bottom:24px;right:24px;z-index:9999;">
        <button id="chatBubble" onclick="toggleChat()" class="btn rounded-circle shadow-lg" 
            style="width:56px;height:56px;background:linear-gradient(135deg,#3b82f6,#6366f1);border:none;position:relative;">
            <i class="fas fa-comments text-white fa-lg"></i>
            <span id="chatUnreadBadge" class="badge bg-danger rounded-pill" style="display:none;position:absolute;top:-4px;right:-6px;font-size:0.65rem;">0</span>
        </button>
        <div id="chatWindow" class="shadow-lg rounded-4 overflow-hidden" 
            style="display:none;position:absolute;bottom:70px;right:0;width:370px;background:var(--bg-primary,#fff);border:1px solid rgba(0,0,0,0.1);">
            <div class="d-flex align-items-center justify-content-between p-3" style="background:linear-gradient(135deg,#3b82f6,#6366f1);">
                <div class="d-flex align-items-center gap-2 text-white">
                    <i class="fas fa-headset"></i>
                    <strong class="small" id="chatHeaderLabel">Chat hỗ trợ</strong>
                    <span id="chatStatus" class="badge bg-white bg-opacity-25 rounded-pill px-2" style="font-size:0.6rem;"></span>
                </div>
                <button onclick="toggleChat()" class="btn btn-sm p-0 text-white"><i class="fas fa-times"></i></button>
            </div>
            <div id="chatMessages" class="p-3" style="height:320px;overflow-y:auto;font-size:0.85rem;">
                <div class="text-center text-muted py-4">
                    <i class="fas fa-comment-dots fa-2x mb-2 opacity-25"></i>
                    <p class="mb-0 small">Nhấn "Bắt đầu" để kết nối với tư vấn viên</p>
                </div>
            </div>
            <div class="p-2 border-top" id="chatInputArea" style="display:none;">
                <div class="d-flex justify-content-between mb-1">
                    <small id="chatCharCount" class="text-muted" style="font-size:0.7rem;">0/500</small>
                    <small id="chatThrottle" class="text-danger" style="font-size:0.7rem;display:none;">Chờ...</small>
                </div>
                <div class="input-group">
                    <input type="text" id="chatInput" class="form-control form-control-sm rounded-start-pill" 
                        placeholder="Chờ tư vấn viên..." disabled maxlength="500"
                        onkeydown="if(event.key==='Enter')sendChatMsg()" oninput="updateCharCount();notifyTypingInput()">
                    <button id="chatSendBtn" class="btn btn-sm rounded-end-pill px-3" disabled
                        style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;" onclick="sendChatMsg()">
                        <i class="fas fa-paper-plane"></i>
                    </button>
                </div>
            </div>
            <div class="p-2 border-top text-center" id="chatStartArea">
                <button class="btn btn-sm rounded-pill w-100" style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;" onclick="startChat()">
                    <i class="fas fa-play me-1"></i>Bắt đầu chat
                </button>
            </div>
            <div class="p-2 border-top text-center" id="chatBlockedArea" style="display:none;">
                <div class="glass rounded-3 p-2 small text-muted">
                    <i class="fas fa-clock me-1"></i><span id="chatBlockedMsg"></span>
                </div>
            </div>
        </div>
    </div>
    <script>
    let chatSessionId=0, chatLastMsgId=0, chatFirstMsgId=0, chatPollTimer=null, chatSessionStatus='', lastSendTime=0;
    let chatEventId=null;
    let chatUnreadCount=0, chatOtherOnline=false, chatOtherTyping=false, lastTypingPing=0;
    let lastOwnStatusEl=null;
    const CTX='${pageContext.request.contextPath}', MY_ID=${sessionScope.user.userId};
    const CHAT_CSRF='${sessionScope.csrf_token}';

    function withChatCsrf(body){
        const base = body ? body + '&' : '';
        return base + 'csrf_token=' + encodeURIComponent(CHAT_CSRF || '');
    }

    function toggleChat(){
        const w=document.getElementById('chatWindow');
        const opening = w.style.display==='none';
        w.style.display = opening ? 'block' : 'none';
        if(opening){
            clearUnreadBadge();
        }
    }
    function openSupportLiveChat(){
        const w=document.getElementById('chatWindow');
        if(!w) return;
        w.style.display='block';
        clearUnreadBadge();
        if(!chatSessionId){
            startChat();
            return;
        }
        updateChatUI();
        const input=document.getElementById('chatInput');
        if(input&&!input.disabled) input.focus();
    }
    function openEventChat(eventId, eventTitle){
        chatEventId=eventId;
        const lbl=document.getElementById('chatHeaderLabel');
        if(lbl) lbl.textContent=eventTitle?'Chat · '+eventTitle:'Chat sự kiện';
        const w=document.getElementById('chatWindow');
        if(w.style.display==='none') w.style.display='block';
        clearUnreadBadge();
        if(!chatSessionId) startChat();
    }

    async function fetchJsonWithMeta(url){
        const response = await fetch(url, {credentials:'same-origin'});
        const text = await response.text();
        let data = [];
        try { data = text ? JSON.parse(text) : []; } catch (e) { throw new Error('INVALID_JSON'); }
        return { data, headers: response.headers, status: response.status };
    }

    async function postFormJson(url, body){
        const response = await fetch(url, {
            method:'POST',
            headers:{'Content-Type':'application/x-www-form-urlencoded'},
            credentials:'same-origin',
            body
        });
        const text = await response.text();
        if(!text) return {};
        try { return JSON.parse(text); } catch (e) { throw new Error('INVALID_JSON'); }
    }

    function startChat(){
        const btn=document.querySelector('#chatStartArea button');
        btn.disabled=true; btn.innerHTML='<i class="fas fa-spinner fa-spin me-1"></i>Đang kết nối...';
        let body='';
        if(chatEventId) body='eventId='+chatEventId;
        postFormJson(CTX+'/api/chat/start', withChatCsrf(body)).then(d=>{
            if(d.blocked){
                document.getElementById('chatStartArea').style.display='none';
                document.getElementById('chatBlockedArea').style.display='block';
                const msg=d.reason==='cooldown'
                    ?'Vui lòng chờ '+d.retryAfter+' phút trước khi chat lại'
                    : d.reason==='active_session_exists'?'Bạn đang có phiên chat khác đang mở'
                    : d.reason==='chat_disabled'?'Chat hỗ trợ hiện đang tạm đóng'
                    :'Không thể tạo phiên chat';
                document.getElementById('chatBlockedMsg').textContent=msg;
                return;
            }
            if(d.sessionId){
                chatSessionId=d.sessionId;
                chatSessionStatus=d.status;
                document.getElementById('chatStartArea').style.display='none';
                document.getElementById('chatInputArea').style.display='block';
                updateChatUI();
                loadInitialMessages();
                chatPollTimer=setInterval(pollMessages,5000);
            }
        }).catch(()=>{
            btn.disabled=false;
            btn.innerHTML='<i class="fas fa-play me-1"></i>Bắt đầu chat';
            appendMsg('⚠ Không thể kết nối chat','system');
        });
    }

    function updateChatUI(){
        const inp=document.getElementById('chatInput'), btn=document.getElementById('chatSendBtn'), st=document.getElementById('chatStatus');
        if(chatSessionStatus==='active'){
            inp.disabled=false; btn.disabled=false; inp.placeholder='Nhập tin nhắn...';
            if(chatOtherTyping){
                st.textContent='Đang nhập...';
                st.style.background='rgba(245,158,11,0.75)';
            } else if(chatOtherOnline){
                st.textContent='Tư vấn viên online';
                st.style.background='rgba(16,185,129,0.75)';
            } else {
                st.textContent='Tư vấn viên tạm offline';
                st.style.background='rgba(107,114,128,0.75)';
            }
        } else if(chatSessionStatus==='waiting'){
            inp.disabled=false; btn.disabled=false; inp.placeholder='Nhập tin nhắn... (chờ tư vấn viên)';
            st.textContent='Đang chờ'; st.style.background='rgba(245,158,11,0.7)';
        } else {
            inp.disabled=true; btn.disabled=true; inp.placeholder='Phiên chat đã đóng';
            st.textContent='Đã đóng'; st.style.background='rgba(107,114,128,0.7)';
        }
    }

    function syncPresenceFromHeaders(headers){
        if(!headers) return;
        chatOtherOnline = headers.get('X-Chat-Other-Online') === '1';
        chatOtherTyping = headers.get('X-Chat-Other-Typing') === '1';
        updateChatUI();
    }

    function updateCharCount(){
        const len=document.getElementById('chatInput').value.length;
        const el=document.getElementById('chatCharCount');
        el.textContent=len+'/500';
        el.style.color=len>450?'#ef4444':'';
    }

    function notifyTypingInput(){
        if(!chatSessionId || (chatSessionStatus!=='active' && chatSessionStatus!=='waiting')) return;
        const now = Date.now();
        if(now - lastTypingPing < 1200) return;
        lastTypingPing = now;
        sendTypingState(true);
    }

    function sendTypingState(isTyping){
        if(!chatSessionId) return;
        fetch(CTX+'/api/chat/typing',{
            method:'POST',
            headers:{'Content-Type':'application/x-www-form-urlencoded'},
            credentials:'same-origin',
            body:withChatCsrf('sessionId='+chatSessionId+'&typing='+(isTyping?'1':'0'))
        }).catch(()=>{});
    }

    function sendChatMsg(){
        const now=Date.now();
        if(now-lastSendTime<3000){
            const el=document.getElementById('chatThrottle');
            el.style.display='inline'; setTimeout(()=>el.style.display='none',2000);
            return;
        }
        const inp=document.getElementById('chatInput');
        const msg=inp.value.trim();
        if(!msg||!chatSessionId||(chatSessionStatus!=='active'&&chatSessionStatus!=='waiting'))return;

        lastSendTime=now;
        inp.value='';
        updateCharCount();
        lastOwnStatusEl = appendMsg(msg,'me',null,null,'Đang gửi...');

        postFormJson(CTX+'/api/chat/send', withChatCsrf('sessionId='+chatSessionId+'&content='+encodeURIComponent(msg)))
        .then(d=>{
            if(d && d.error){
                if(lastOwnStatusEl) lastOwnStatusEl.textContent='Lỗi gửi';
                appendMsg('⚠ '+d.error,'system');
                return;
            }
            if(lastOwnStatusEl) lastOwnStatusEl.textContent='Đã gửi';
            sendTypingState(false);
        }).catch(()=>{
            if(lastOwnStatusEl) lastOwnStatusEl.textContent='Lỗi gửi';
            appendMsg('⚠ Gửi tin nhắn thất bại','system');
        });
    }

    function loadInitialMessages(){
        document.getElementById('chatMessages').innerHTML='';
        fetchJsonWithMeta(CTX+'/api/chat/messages?sessionId='+chatSessionId+'&after=0')
        .then(res=>{
            const msgs = Array.isArray(res.data) ? res.data : [];
            syncPresenceFromHeaders(res.headers);
            if(msgs.length>0){
                chatFirstMsgId=msgs[0].id;
                msgs.forEach(m=>{
                    appendMsg(m.content, m.senderId===MY_ID?'me':'agent', m.senderName, m.time);
                    chatLastMsgId=Math.max(chatLastMsgId,m.id);
                });
            } else {
                document.getElementById('chatMessages').innerHTML=
                    '<div class="text-center text-muted py-2 small"><i class="fas fa-clock me-1"></i>Đang chờ tư vấn viên...</div>';
            }
        }).catch(()=>appendMsg('⚠ Không tải được tin nhắn','system'));
    }

    function pollMessages(){
        if(!chatSessionId)return;
        fetchJsonWithMeta(CTX+'/api/chat/messages?sessionId='+chatSessionId+'&after='+chatLastMsgId)
        .then(res=>{
            const msgs = Array.isArray(res.data) ? res.data : [];
            syncPresenceFromHeaders(res.headers);
            msgs.forEach(m=>{
                if(m.senderId!==MY_ID){
                    appendMsg(m.content,'agent',m.senderName,m.time);
                    if(isChatWindowHidden()) incrementUnreadBadge();
                    if(lastOwnStatusEl) lastOwnStatusEl.textContent='Đã xem';
                }
                chatLastMsgId=Math.max(chatLastMsgId,m.id);
                if(chatSessionStatus!=='active'&&m.senderRole!=='customer'){
                    chatSessionStatus='active'; updateChatUI();
                }
            });
        }).catch(()=>{});
    }

    function loadMore(){
        if(!chatSessionId||!chatFirstMsgId)return;
        fetchJsonWithMeta(CTX+'/api/chat/history?sessionId='+chatSessionId+'&before='+chatFirstMsgId+'&limit=30')
        .then(res=>{
            const msgs = Array.isArray(res.data) ? res.data : [];
            if(msgs.length===0){document.getElementById('chatLoadMore')?.remove();return;}
            const box=document.getElementById('chatMessages');
            const oldH=box.scrollHeight;
            chatFirstMsgId=msgs[0].id;
            const frag=document.createDocumentFragment();
            msgs.forEach(m=>{
                const d=document.createElement('div');
                d.className='mb-2 d-flex '+(m.senderId===MY_ID?'justify-content-end':'');
                const bg=m.senderId===MY_ID?'background:rgba(59,130,246,0.1);':'background:rgba(0,0,0,0.03);';
                d.innerHTML='<div class="rounded-3 px-3 py-2 small" style="max-width:80%;'+bg+'">'
                    +(m.senderId!==MY_ID?'<small class="fw-bold d-block text-primary">'+escChat(m.senderName)+'</small>':'')
                    +escChat(m.content)+'</div>';
                frag.appendChild(d);
            });
            const loadBtn=document.getElementById('chatLoadMore');
            if(loadBtn)box.insertBefore(frag,loadBtn.nextSibling);
            else box.insertBefore(frag,box.firstChild);
            box.scrollTop=box.scrollHeight-oldH;
            if(msgs.length<30)document.getElementById('chatLoadMore')?.remove();
        }).catch(()=>{});
    }

    function escChat(t){var d=document.createElement('div');d.textContent=t;return d.innerHTML;}

    function appendMsg(text,type,name,time,status){
        const box=document.getElementById('chatMessages');
        const ph=box.querySelector('.text-center.text-muted');
        if(ph&&!document.getElementById('chatLoadMore'))ph.remove();

        const d=document.createElement('div');
        d.className='mb-2 d-flex '+(type==='me'?'justify-content-end':'');
        if(type==='system'){
            d.className='mb-2 text-center';
            d.innerHTML='<small class="text-muted">'+escChat(text)+'</small>';
            box.appendChild(d);
            return null;
        }

        const bg=type==='me'?'background:rgba(59,130,246,0.1);':'background:rgba(0,0,0,0.03);';
        d.innerHTML='<div class="rounded-3 px-3 py-2 small" style="max-width:80%;'+bg+'">'
            +(name&&type!=='me'?'<small class="fw-bold d-block text-primary">'+escChat(name)+'</small>':'')
            +escChat(text)
            +(type==='me'&&status?'<small data-chat-msg-status class="d-block text-muted mt-1" style="font-size:0.68rem;">'+escChat(status)+'</small>':'')
            +'</div>';

        box.appendChild(d);
        box.scrollTop=box.scrollHeight;
        return d.querySelector('[data-chat-msg-status]');
    }

    function isChatWindowHidden(){
        const w=document.getElementById('chatWindow');
        return !w || w.style.display==='none';
    }

    function incrementUnreadBadge(){
        chatUnreadCount += 1;
        const badge=document.getElementById('chatUnreadBadge');
        if(!badge) return;
        badge.textContent = chatUnreadCount > 99 ? '99+' : String(chatUnreadCount);
        badge.style.display='inline-block';
    }

    function clearUnreadBadge(){
        chatUnreadCount = 0;
        const badge=document.getElementById('chatUnreadBadge');
        if(!badge) return;
        badge.textContent='0';
        badge.style.display='none';
    }
    </script>
    </c:if>
</body>
</html>
