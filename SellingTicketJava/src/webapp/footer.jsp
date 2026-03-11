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
                        <a href="#" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-facebook-f text-primary"></i>
                        </a>
                        <a href="#" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-instagram text-danger"></i>
                        </a>
                        <a href="#" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-youtube text-danger"></i>
                        </a>
                        <a href="#" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-tiktok"></i>
                        </a>
                    </div>
                </div>
                
                <!-- Discovery -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Khám phá</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events" class="text-muted text-decoration-none hover-primary">Sự kiện</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=music" class="text-muted text-decoration-none hover-primary">Âm nhạc</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=sports" class="text-muted text-decoration-none hover-primary">Thể thao</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=workshop" class="text-muted text-decoration-none hover-primary">Workshop</a></li>
                    </ul>
                </div>
                
                <!-- Organizer -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Ban tổ chức</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/organizer/create-event" class="text-muted text-decoration-none hover-primary" onclick="return requireLogin(this)">Tạo sự kiện</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/organizer/events" class="text-muted text-decoration-none hover-primary" onclick="return requireLogin(this)">Quản lý sự kiện</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/about" class="text-muted text-decoration-none hover-primary">Tính năng</a></li>
                    </ul>
                </div>
                
                <!-- Support -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Hỗ trợ</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/faq" class="text-muted text-decoration-none hover-primary">Trung tâm trợ giúp</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/terms" class="text-muted text-decoration-none hover-primary">Điều khoản</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/terms" class="text-muted text-decoration-none hover-primary">Chính sách</a></li>
                    </ul>
                </div>
                
                <!-- Contact -->
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
                    </ul>
                </div>
            </div>
            
            <hr class="my-4 opacity-25">
            
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3">
                <p class="small text-muted mb-0">&copy; 2026 Ticketbox. All rights reserved.</p>
                <div class="d-flex gap-3">
                    <a href="${pageContext.request.contextPath}/terms" class="small text-muted text-decoration-none hover-primary">Privacy</a>
                    <a href="${pageContext.request.contextPath}/terms" class="small text-muted text-decoration-none hover-primary">Terms</a>
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
            style="width:56px;height:56px;background:linear-gradient(135deg,#3b82f6,#6366f1);border:none;">
            <i class="fas fa-comments text-white fa-lg"></i>
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
                        onkeydown="if(event.key==='Enter')sendChatMsg()" oninput="updateCharCount()">
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
    const CTX='${pageContext.request.contextPath}', MY_ID=${sessionScope.user.userId};

    function toggleChat(){
        const w=document.getElementById('chatWindow');
        w.style.display=w.style.display==='none'?'block':'none';
    }
    function openEventChat(eventId, eventTitle){
        chatEventId=eventId;
        const lbl=document.getElementById('chatHeaderLabel');
        if(lbl) lbl.textContent=eventTitle?'Chat · '+eventTitle:'Chat sự kiện';
        const w=document.getElementById('chatWindow');
        if(w.style.display==='none') w.style.display='block';
        // Auto-start if not already in a session
        if(!chatSessionId) startChat();
    }
    function startChat(){
        const btn=document.querySelector('#chatStartArea button');
        btn.disabled=true; btn.innerHTML='<i class="fas fa-spinner fa-spin me-1"></i>Đang kết nối...';
        let body='';
        if(chatEventId) body='eventId='+chatEventId;
        fetch(CTX+'/api/chat/start',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:body})
        .then(r=>r.json()).then(d=>{
            if(d.blocked){
                document.getElementById('chatStartArea').style.display='none';
                document.getElementById('chatBlockedArea').style.display='block';
                const msg=d.reason==='cooldown'
                    ?'Vui lòng chờ '+d.retryAfter+' phút trước khi chat lại'
                    : d.reason==='active_session_exists'?'Bạn đang có phiên chat khác đang mở':'Không thể tạo phiên chat';
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
        }).catch(()=>{btn.disabled=false;btn.innerHTML='<i class="fas fa-play me-1"></i>Bắt đầu chat';});
    }
    function updateChatUI(){
        const inp=document.getElementById('chatInput'), btn=document.getElementById('chatSendBtn'),
              st=document.getElementById('chatStatus');
        if(chatSessionStatus==='active'){
            inp.disabled=false; btn.disabled=false; inp.placeholder='Nhập tin nhắn...';
            st.textContent='Đang kết nối'; st.style.background='rgba(16,185,129,0.7)';
        } else {
            inp.disabled=true; btn.disabled=true; inp.placeholder='Chờ tư vấn viên chấp nhận...';
            st.textContent='Đang chờ'; st.style.background='rgba(245,158,11,0.7)';
        }
    }
    function updateCharCount(){
        const len=document.getElementById('chatInput').value.length;
        const el=document.getElementById('chatCharCount');
        el.textContent=len+'/500';
        el.style.color=len>450?'#ef4444':'';
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
        if(!msg||!chatSessionId||chatSessionStatus!=='active')return;
        lastSendTime=now; inp.value=''; updateCharCount();
        appendMsg(msg,'me');
        fetch(CTX+'/api/chat/send',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:'sessionId='+chatSessionId+'&content='+encodeURIComponent(msg)})
        .then(r=>r.json()).then(d=>{
            if(d.error) appendMsg('⚠ '+d.error,'system');
        });
    }
    function loadInitialMessages(){
        document.getElementById('chatMessages').innerHTML='';
        fetch(CTX+'/api/chat/messages?sessionId='+chatSessionId+'&after=0')
        .then(r=>r.json()).then(msgs=>{
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
        });
    }
    function pollMessages(){
        if(!chatSessionId)return;
        fetch(CTX+'/api/chat/messages?sessionId='+chatSessionId+'&after='+chatLastMsgId)
        .then(r=>r.json()).then(msgs=>{
            msgs.forEach(m=>{
                if(m.senderId!==MY_ID) appendMsg(m.content,'agent',m.senderName,m.time);
                chatLastMsgId=Math.max(chatLastMsgId,m.id);
                // If agent replied, session is now active
                if(chatSessionStatus!=='active'&&m.senderRole!=='customer'){
                    chatSessionStatus='active'; updateChatUI();
                }
            });
        });
    }
    function loadMore(){
        if(!chatSessionId||!chatFirstMsgId)return;
        fetch(CTX+'/api/chat/history?sessionId='+chatSessionId+'&before='+chatFirstMsgId+'&limit=30')
        .then(r=>r.json()).then(msgs=>{
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
                    +(m.senderId!==MY_ID?'<small class="fw-bold d-block text-primary">'+m.senderName+'</small>':'')
                    +m.content+'</div>';
                frag.appendChild(d);
            });
            const loadBtn=document.getElementById('chatLoadMore');
            if(loadBtn)box.insertBefore(frag,loadBtn.nextSibling);
            else box.insertBefore(frag,box.firstChild);
            box.scrollTop=box.scrollHeight-oldH;
            if(msgs.length<30)document.getElementById('chatLoadMore')?.remove();
        });
    }
    function appendMsg(text,type,name,time){
        const box=document.getElementById('chatMessages');
        // Remove placeholder
        const ph=box.querySelector('.text-center.text-muted');
        if(ph&&!document.getElementById('chatLoadMore'))ph.remove();
        const d=document.createElement('div');
        d.className='mb-2 d-flex '+(type==='me'?'justify-content-end':'');
        if(type==='system'){d.className='mb-2 text-center';d.innerHTML='<small class="text-muted">'+text+'</small>';box.appendChild(d);return;}
        const bg=type==='me'?'background:rgba(59,130,246,0.1);':'background:rgba(0,0,0,0.03);';
        d.innerHTML='<div class="rounded-3 px-3 py-2 small" style="max-width:80%;'+bg+'">'
            +(name&&type!=='me'?'<small class="fw-bold d-block text-primary">'+name+'</small>':'')
            +text+'</div>';
        box.appendChild(d);
        box.scrollTop=box.scrollHeight;
    }
    </script>
    </c:if>
</body>
</html>
