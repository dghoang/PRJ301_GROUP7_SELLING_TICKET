<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <c:choose>
            <c:when test="${not empty pageTitle}">
                <c:out value="${pageTitle} | Ticketbox"/>
            </c:when>
            <c:otherwise>
                Ticketbox - Nền tảng đặt vé sự kiện hàng đầu
            </c:otherwise>
        </c:choose>
    </title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
            integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    
    <!-- Font Awesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet"
          integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg==" crossorigin="anonymous" referrerpolicy="no-referrer">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
    
    <link href="${pageContext.request.contextPath}/assets/css/navbar.css" rel="stylesheet">
</head>
<body class="d-flex flex-column" data-context-path="${pageContext.request.contextPath}">
    
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-light fixed-top navbar-glass" id="mainNavbar">
        <div class="container">
            <!-- Logo -->
            <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/">
                <div class="rounded-3 d-flex align-items-center justify-content-center text-white btn-gradient" style="width: 40px; height: 40px;">
                    <i class="fas fa-ticket-alt"></i>
                </div>
                <span class="fw-bold fs-5 text-gradient">Ticketbox</span>
            </a>
            
            <!-- Mobile Toggle -->
            <button class="navbar-toggler border-0 glass rounded-3" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <!-- Nav Links -->
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav mx-auto mb-2 mb-lg-0 gap-1">
                    <li class="nav-item">
                        <a class="nav-link fw-medium px-3" href="${pageContext.request.contextPath}/events">
                            <i class="fas fa-calendar-alt me-1 d-lg-none"></i><span data-i18n="nav.events">Sự kiện</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link fw-medium px-3" href="${pageContext.request.contextPath}/about">
                            <i class="fas fa-info-circle me-1 d-lg-none"></i><span data-i18n="nav.about">Về chúng tôi</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link fw-medium px-3" href="${pageContext.request.contextPath}/faq">
                            <i class="fas fa-question-circle me-1 d-lg-none"></i><span data-i18n="nav.faq">FAQ</span>
                        </a>
                    </li>
                    
                    <!-- Tạo sự kiện - All logged-in users can create events -->
                    <c:if test="${sessionScope.account != null}">
                        <li class="nav-item">
                            <a class="nav-link nav-cta fw-medium px-3" href="${pageContext.request.contextPath}/organizer/create-event">
                                <i class="fas fa-plus-circle me-1"></i><span data-i18n="nav.create_event">Tạo sự kiện</span>
                            </a>
                        </li>
                    </c:if>
                </ul>
                
                <!-- Language & Auth -->
                <div class="d-flex align-items-center gap-3">
                    <div class="d-flex align-items-center gap-2 nav-language-switch glass px-2 py-1">
                        <i class="fas fa-language text-primary small"></i>
                        <select class="form-select form-select-sm border-0 bg-transparent shadow-none" id="navLanguageSelect" aria-label="Language switcher">
                            <option value="vi">🇻🇳 Tiếng Việt (VN)</option>
                            <option value="en">🇬🇧 English (EN)</option>
                            <option value="ja">🇯🇵 日本語 (JP)</option>
                        </select>
                    </div>
                    
                    <c:choose>
                        <c:when test="${sessionScope.account != null}">
                            <!-- Notification Bell (all logged-in users) -->
                            <a href="${pageContext.request.contextPath}/notifications" class="btn btn-link position-relative p-1 me-1 text-dark" title="Thông báo" id="notif-bell">
                                <i class="fas fa-bell" style="font-size:1.1rem;"></i>
                                <span id="notif-badge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill d-none" style="background: linear-gradient(135deg, #ef4444, #f97316); font-size:0.6rem;">0</span>
                            </a>
                            <script>
                            (function(){
                                var ctx = document.body.dataset.contextPath || '';
                                fetch(ctx + '/notifications/count')
                                .then(function(r){return r.json()})
                                .then(function(d){
                                    if(d.unread > 0){
                                        var b = document.getElementById('notif-badge');
                                        b.textContent = d.unread > 99 ? '99+' : d.unread;
                                        b.classList.remove('d-none');
                                    }
                                }).catch(function(){});
                            })();
                            </script>
                            <div class="dropdown">
                                <button class="btn d-flex align-items-center gap-2 p-0" type="button" data-bs-toggle="dropdown">
                                    <div class="user-avatar">${sessionScope.account.fullName.substring(0,1)}</div>
                                    <span class="fw-medium small d-none d-md-inline">${sessionScope.account.fullName}</span>
                                    <i class="fas fa-chevron-down small text-muted"></i>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end glass-strong border-0 rounded-4 p-2 mt-2 shadow" style="min-width: 220px;">
                                    <li><a class="dropdown-item rounded-3 py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/profile"><span class="d-inline-flex align-items-center justify-content-center rounded-circle" style="width:28px;height:28px;background:rgba(59,130,246,0.12);"><i class="fas fa-user" style="font-size:0.75rem;color:#3b82f6;"></i></span><span data-i18n="nav.profile">Hồ sơ</span></a></li>
                                    <li><a class="dropdown-item rounded-3 py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/my-tickets"><span class="d-inline-flex align-items-center justify-content-center rounded-circle" style="width:28px;height:28px;background:rgba(168,85,247,0.12);"><i class="fas fa-ticket-alt" style="font-size:0.75rem;color:#a855f7;"></i></span><span data-i18n="nav.my_tickets">Vé của tôi</span></a></li>
                                    <li><a class="dropdown-item rounded-3 py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/organizer/events"><span class="d-inline-flex align-items-center justify-content-center rounded-circle" style="width:28px;height:28px;background:rgba(245,158,11,0.12);"><i class="fas fa-calendar-check" style="font-size:0.75rem;color:#f59e0b;"></i></span><span data-i18n="nav.my_events">Sự kiện của tôi</span></a></li>
                                    <c:if test="${sessionScope.account.role == 'admin'}">
                                    <li><a class="dropdown-item rounded-3 py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/admin/dashboard"><span class="d-inline-flex align-items-center justify-content-center rounded-circle" style="width:28px;height:28px;background:rgba(239,68,68,0.12);"><i class="fas fa-shield-alt" style="font-size:0.75rem;color:#ef4444;"></i></span><span data-i18n="nav.admin">Quản trị</span></a></li>
                                    </c:if>
                                    <li><a class="dropdown-item rounded-3 py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/staff/dashboard"><span class="d-inline-flex align-items-center justify-content-center rounded-circle" style="width:28px;height:28px;background:rgba(16,185,129,0.12);"><i class="fas fa-id-badge" style="font-size:0.75rem;color:#10b981;"></i></span><span data-i18n="nav.staff_portal">Cổng nhân viên</span></a></li>
                                    <li><hr class="dropdown-divider my-2"></li>
                                    <li><a class="dropdown-item rounded-3 py-2 d-flex align-items-center gap-2 text-danger" href="${pageContext.request.contextPath}/logout"><span class="d-inline-flex align-items-center justify-content-center rounded-circle" style="width:28px;height:28px;background:rgba(239,68,68,0.08);"><i class="fas fa-sign-out-alt" style="font-size:0.75rem;"></i></span><span data-i18n="nav.logout">Đăng xuất</span></a></li>
                                </ul>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-link text-dark text-decoration-none fw-medium" data-i18n="nav.login">Đăng nhập</a>
                            <a href="${pageContext.request.contextPath}/register" class="btn btn-gradient rounded-3 px-4 hover-glow" data-i18n="nav.register">Đăng ký</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </nav>
    
    <!-- Spacer for fixed navbar -->
    <div style="height: 76px;"></div>
    
    <!-- Server-side Toast (uses unified toast.js system) -->
    <c:if test="${not empty sessionScope.toastMessage}">
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var type = "${fn:escapeXml(sessionScope.toastType)}" || 'success';
        var msg = "${fn:escapeXml(sessionScope.toastMessage)}";
        showToast(msg, type);
    });
    </script>
    </c:if>
    <%
        // Clear toast after rendering
        if (session.getAttribute("toastMessage") != null) {
            session.removeAttribute("toastMessage");
            session.removeAttribute("toastType");
        }
    %>

    <!-- Main Content Wrapper -->
    <main class="flex-grow-1">

<script src="${pageContext.request.contextPath}/assets/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/i18n.js"></script>
