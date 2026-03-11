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
                            <i class="fas fa-calendar-alt me-1 d-lg-none"></i>Sự kiện
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link fw-medium px-3" href="${pageContext.request.contextPath}/about">
                            <i class="fas fa-info-circle me-1 d-lg-none"></i>Về chúng tôi
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link fw-medium px-3" href="${pageContext.request.contextPath}/faq">
                            <i class="fas fa-question-circle me-1 d-lg-none"></i>FAQ
                        </a>
                    </li>
                    
                    <!-- Tạo sự kiện - Only show when logged in -->
                    <c:if test="${sessionScope.account != null}">
                        <li class="nav-item">
                            <a class="nav-link nav-cta fw-medium px-3" href="${pageContext.request.contextPath}/organizer/create-event">
                                <i class="fas fa-plus-circle me-1"></i>Tạo sự kiện
                            </a>
                        </li>
                    </c:if>
                </ul>
                
                <!-- Search & Auth -->
                <div class="d-flex align-items-center gap-3">
                    <div class="input-group d-none d-lg-flex search-input-nav glass" style="max-width: 220px;">
                        <span class="input-group-text border-0 bg-transparent"><i class="fas fa-search text-primary"></i></span>
                        <input type="text" class="form-control border-0 bg-transparent py-2" placeholder="Tìm kiếm..." id="navSearchInput">
                    </div>
                    
                    <c:choose>
                        <c:when test="${sessionScope.account != null}">
                            <div class="dropdown">
                                <button class="btn d-flex align-items-center gap-2 p-0" type="button" data-bs-toggle="dropdown">
                                    <div class="user-avatar">${sessionScope.account.fullName.substring(0,1)}</div>
                                    <span class="fw-medium small d-none d-md-inline">${sessionScope.account.fullName}</span>
                                    <i class="fas fa-chevron-down small text-muted"></i>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end glass-strong border-0 rounded-4 p-2 mt-2 shadow">
                                    <li><a class="dropdown-item rounded-3 py-2" href="${pageContext.request.contextPath}/profile"><i class="fas fa-user me-2 text-primary"></i>Hồ sơ</a></li>
                                    <li><a class="dropdown-item rounded-3 py-2" href="${pageContext.request.contextPath}/my-tickets"><i class="fas fa-ticket-alt me-2 text-primary"></i>Vé của tôi</a></li>
                                    <li><a class="dropdown-item rounded-3 py-2" href="${pageContext.request.contextPath}/organizer/events"><i class="fas fa-calendar-check me-2 text-primary"></i>Quản lý sự kiện</a></li>
                                    <li><hr class="dropdown-divider my-2"></li>
                                    <li><a class="dropdown-item rounded-3 py-2 text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i>Đăng xuất</a></li>
                                </ul>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-link text-dark text-decoration-none fw-medium">Đăng nhập</a>
                            <a href="${pageContext.request.contextPath}/register" class="btn btn-gradient rounded-3 px-4 hover-glow">Đăng ký</a>
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
