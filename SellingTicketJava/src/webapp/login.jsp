<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Ticketbox</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
    
    <style>
        .auth-page {
            min-height: 100vh;
            background: linear-gradient(135deg, #f5f3ff 0%, #fdf2f8 50%, #f0f9ff 100%);
            position: relative;
            overflow: hidden;
        }
        
        /* Floating decorations */
        .auth-blob {
            position: fixed;
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.5;
            z-index: 0;
        }
        .auth-blob-1 {
            width: 400px;
            height: 400px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            top: -100px;
            right: -100px;
            animation: floatSmooth 15s ease-in-out infinite;
        }
        .auth-blob-2 {
            width: 300px;
            height: 300px;
            background: linear-gradient(135deg, #06b6d4, #3b82f6);
            bottom: -50px;
            left: -50px;
            animation: floatSmooth 12s ease-in-out infinite reverse;
        }
        
        /* Card styling */
        .auth-card {
            position: relative;
            z-index: 10;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
        }
        
        /* Left panel gradient overlay */
        .auth-image-overlay {
            background: linear-gradient(135deg, rgba(147, 51, 234, 0.8), rgba(219, 39, 119, 0.8));
        }
        
        /* Floating icons */
        .floating-icon {
            position: absolute;
            font-size: 1.5rem;
            opacity: 0.3;
            animation: floatSmooth 6s ease-in-out infinite;
        }
        
        /* Input focus effect */
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(147, 51, 234, 0.1);
        }
        
        /* Social button hover */
        .social-btn {
            transition: all 0.3s ease;
        }
        .social-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body class="auth-page d-flex align-items-center justify-content-center py-4">
    <!-- Floating Blobs -->
    <div class="auth-blob auth-blob-1"></div>
    <div class="auth-blob auth-blob-2"></div>

    <div class="container">
        <div class="row g-0 rounded-4 overflow-hidden shadow-lg auth-card animate-fadeInUp" style="max-width: 1000px; margin: 0 auto;">
            <!-- Left - Image -->
            <div class="col-lg-5 d-none d-lg-block position-relative">
                <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1200" alt="Event" class="w-100 h-100 object-fit-cover position-absolute top-0 start-0">
                <div class="position-absolute top-0 start-0 w-100 h-100 auth-image-overlay"></div>
                
                <!-- Floating icons -->
                <div class="floating-icon text-white" style="top: 20%; left: 20%;"><i class="fas fa-music"></i></div>
                <div class="floating-icon text-white" style="top: 40%; right: 15%; animation-delay: -2s;"><i class="fas fa-ticket-alt"></i></div>
                <div class="floating-icon text-white" style="bottom: 30%; left: 25%; animation-delay: -4s;"><i class="fas fa-star"></i></div>
                
                <div class="position-relative z-1 p-5 d-flex flex-column justify-content-end h-100 text-white">
                    <div class="d-flex align-items-center gap-3 mb-4 animate-fadeInLeft">
                        <div class="rounded-3 d-flex align-items-center justify-content-center text-white" style="width: 52px; height: 52px; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px);">
                            <i class="fas fa-ticket-alt fs-4"></i>
                        </div>
                        <span class="fw-bold fs-3">Ticketbox</span>
                    </div>
                    <h2 class="display-6 fw-bold mb-3 animate-fadeInLeft stagger-2">Chào mừng trở lại!</h2>
                    <p class="fs-5 opacity-75 animate-fadeInLeft stagger-3">Đăng nhập để tiếp tục khám phá và đặt vé cho những sự kiện tuyệt vời nhất.</p>
                    
                    <!-- Stats -->
                    <div class="d-flex gap-4 mt-4 animate-fadeInUp stagger-4">
                        <div class="text-center">
                            <div class="fs-4 fw-bold" data-counter="10000">0</div>
                            <small class="opacity-75">Sự kiện</small>
                        </div>
                        <div class="text-center">
                            <div class="fs-4 fw-bold" data-counter="500000">0</div>
                            <small class="opacity-75">Người dùng</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right - Form -->
            <div class="col-lg-7 p-4 p-lg-5 d-flex align-items-center bg-white">
                <div class="w-100" style="max-width: 420px; margin: 0 auto;">
                    <!-- Mobile Logo -->
                    <div class="d-lg-none text-center mb-4 animate-fadeInDown">
                        <div class="d-inline-flex align-items-center gap-2">
                           <div class="rounded-3 d-flex align-items-center justify-content-center text-white btn-gradient" style="width: 44px; height: 44px;">
                                <i class="fas fa-ticket-alt"></i>
                            </div>
                            <span class="fw-bold fs-4 gradient-text-animate">Ticketbox</span>
                        </div>
                    </div>

                    <div class="text-center mb-5 animate-fadeInUp">
                        <h2 class="fw-bold mb-2">Đăng nhập</h2>
                        <p class="text-muted">
                            Chưa có tài khoản? 
                            <a href="register.jsp" class="text-primary fw-medium text-decoration-none hover-underline">Đăng ký ngay</a>
                        </p>
                    </div>

                    <!-- Error Message -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger d-flex align-items-center rounded-3 animate-shake" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>
                            <span>${error}</span>
                        </div>
                    </c:if>

                    <c:set var="loginReturnUrl" value="${not empty param.returnUrl ? param.returnUrl : param.redirect}"/>
                    <form action="${pageContext.request.contextPath}/login" method="POST">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                        <input type="hidden" name="returnUrl" value="${loginReturnUrl}"/>
                        <!-- Email -->
                        <div class="mb-4 animate-fadeInUp stagger-1">
                            <label for="email" class="form-label fw-medium">Email</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-envelope text-muted"></i></span>
                                <input type="email" id="email" name="email" required placeholder="email@example.com" class="form-control bg-light border-start-0 ps-0 rounded-end-3">
                            </div>
                        </div>

                        <!-- Password -->
                        <div class="mb-4 animate-fadeInUp stagger-2">
                            <div class="d-flex justify-content-between">
                                <label for="password" class="form-label fw-medium">Mật khẩu</label>
                                <a href="javascript:void(0)" onclick="showInfo('Tính năng đặt lại mật khẩu sẽ sớm ra mắt!')" class="small text-primary text-decoration-none">Quên mật khẩu?</a>
                            </div>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-lock text-muted"></i></span>
                                <input type="password" id="password" name="password" required placeholder="••••••••" class="form-control bg-light border-start-0 border-end-0 ps-0">
                                <button class="btn btn-light border border-start-0 rounded-end-3" type="button" onclick="togglePassword()">
                                    <i class="fas fa-eye text-muted" id="eyeIcon"></i>
                                </button>
                            </div>
                        </div>

                        <!-- Remember me -->
                        <div class="mb-4 form-check animate-fadeInUp stagger-3">
                            <input type="checkbox" id="remember" name="remember" class="form-check-input">
                            <label for="remember" class="form-check-label small">Ghi nhớ đăng nhập</label>
                        </div>

                        <!-- Submit -->
                        <button type="submit" class="btn btn-gradient w-100 py-3 rounded-3 fw-bold mb-4 hover-glow animate-fadeInUp stagger-4">
                            Đăng nhập <i class="fas fa-arrow-right ms-2"></i>
                        </button>

                        <!-- Divider -->
                        <div class="position-relative text-center mb-4 animate-fadeInUp stagger-5">
                            <hr class="position-absolute top-50 start-0 w-100 z-0">
                            <span class="position-relative z-1 bg-white px-3 text-muted small">Hoặc tiếp tục với</span>
                        </div>

                        <!-- Social Login -->
                        <div class="animate-fadeInUp stagger-6">
                            <a href="${pageContext.request.contextPath}/auth/google" class="btn btn-outline-secondary w-100 py-2 rounded-3 social-btn text-decoration-none">
                                <i class="fab fa-google me-2 text-danger"></i> Đăng nhập với Google
                            </a>
                        </div>
                    </form>
                    
                     <div class="text-center mt-4 animate-fadeInUp stagger-7">
                        <a href="home" class="small text-muted text-decoration-none d-inline-flex align-items-center gap-2 hover-lift">
                            <i class="fas fa-arrow-left"></i> Quay về trang chủ
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/animations.js"></script>
    <script>
        function togglePassword() {
            const passwordInput = document.getElementById('password');
            const eyeIcon = document.getElementById('eyeIcon');
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.classList.remove('fa-eye');
                eyeIcon.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                eyeIcon.classList.remove('fa-eye-slash');
                eyeIcon.classList.add('fa-eye');
            }
        }
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
</body>
</html>
