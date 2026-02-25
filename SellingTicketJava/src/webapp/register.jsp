<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - Ticketbox</title>
    
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
            left: -100px;
            animation: floatSmooth 15s ease-in-out infinite;
        }
        .auth-blob-2 {
            width: 300px;
            height: 300px;
            background: linear-gradient(135deg, #06b6d4, #3b82f6);
            bottom: -50px;
            right: -50px;
            animation: floatSmooth 12s ease-in-out infinite reverse;
        }
        
        .auth-card {
            position: relative;
            z-index: 10;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
        }
        
        .auth-image-overlay {
            background: linear-gradient(135deg, rgba(219, 39, 119, 0.8), rgba(147, 51, 234, 0.8));
        }
        
        .floating-icon {
            position: absolute;
            font-size: 1.5rem;
            opacity: 0.3;
            animation: floatSmooth 6s ease-in-out infinite;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(147, 51, 234, 0.1);
        }
        
        /* Password strength meter */
        .strength-meter {
            display: flex;
            gap: 4px;
            margin-top: 8px;
        }
        .strength-bar {
            height: 4px;
            flex: 1;
            border-radius: 2px;
            background: #e5e7eb;
            transition: all 0.3s ease;
        }
        .strength-bar.weak { background: #ef4444; }
        .strength-bar.medium { background: #f59e0b; }
        .strength-bar.strong { background: #10b981; }
        
        /* Step indicator */
        .step-indicator {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-bottom: 2rem;
        }
        .step-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #e5e7eb;
            transition: all 0.3s ease;
        }
        .step-dot.active {
            background: var(--primary);
            transform: scale(1.2);
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
                <img src="https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=1200" alt="Event" class="w-100 h-100 object-fit-cover position-absolute top-0 start-0">
                <div class="position-absolute top-0 start-0 w-100 h-100 auth-image-overlay"></div>
                
                <!-- Floating icons -->
                <div class="floating-icon text-white" style="top: 15%; right: 20%;"><i class="fas fa-heart"></i></div>
                <div class="floating-icon text-white" style="top: 45%; left: 15%; animation-delay: -2s;"><i class="fas fa-calendar-check"></i></div>
                <div class="floating-icon text-white" style="bottom: 25%; right: 25%; animation-delay: -4s;"><i class="fas fa-gift"></i></div>
                
                <div class="position-relative z-1 p-5 d-flex flex-column justify-content-end h-100 text-white">
                    <div class="d-flex align-items-center gap-3 mb-4 animate-fadeInLeft">
                        <div class="rounded-3 d-flex align-items-center justify-content-center text-white" style="width: 52px; height: 52px; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px);">
                            <i class="fas fa-ticket-alt fs-4"></i>
                        </div>
                        <span class="fw-bold fs-3">Ticketbox</span>
                    </div>
                    <h2 class="display-6 fw-bold mb-3 animate-fadeInLeft stagger-2">Tham gia ngay!</h2>
                    <p class="fs-5 opacity-75 animate-fadeInLeft stagger-3">Tạo tài khoản để bắt đầu khám phá hàng nghìn sự kiện hấp dẫn.</p>
                    
                    <!-- Benefits -->
                    <div class="mt-4 animate-fadeInUp stagger-4">
                        <div class="d-flex align-items-center gap-2 mb-2">
                            <i class="fas fa-check-circle text-white"></i>
                            <span class="small">Đặt vé nhanh chóng, an toàn</span>
                        </div>
                        <div class="d-flex align-items-center gap-2 mb-2">
                            <i class="fas fa-check-circle text-white"></i>
                            <span class="small">Nhận thông báo sự kiện hot</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="fas fa-check-circle text-white"></i>
                            <span class="small">Tích điểm đổi quà hấp dẫn</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right - Form -->
            <div class="col-lg-7 p-4 p-lg-5 d-flex align-items-center bg-white overflow-auto" style="max-height: 100vh;">
                <div class="w-100" style="max-width: 450px; margin: 0 auto;">
                    <!-- Mobile Logo -->
                    <div class="d-lg-none text-center mb-4 animate-fadeInDown">
                        <div class="d-inline-flex align-items-center gap-2">
                           <div class="rounded-3 d-flex align-items-center justify-content-center text-white btn-gradient" style="width: 44px; height: 44px;">
                                <i class="fas fa-ticket-alt"></i>
                            </div>
                            <span class="fw-bold fs-4 gradient-text-animate">Ticketbox</span>
                        </div>
                    </div>

                    <div class="text-center mb-4 animate-fadeInUp">
                        <h2 class="fw-bold mb-2">Tạo tài khoản mới</h2>
                        <p class="text-muted">
                            Đã có tài khoản? <a href="login.jsp" class="text-primary fw-medium text-decoration-none">Đăng nhập</a>
                        </p>
                    </div>
                    
                    <!-- Step Indicator -->
                    <div class="step-indicator animate-fadeInUp">
                        <div class="step-dot active"></div>
                        <div class="step-dot"></div>
                        <div class="step-dot"></div>
                    </div>

                    <!-- Error Message -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger d-flex align-items-center rounded-3 animate-shake" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>
                            <span>${error}</span>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/register" method="POST">
                        <input type="hidden" name="csrf_token" value="${csrf_token}"/>
                        <div class="mb-3 animate-fadeInUp stagger-1">
                            <label for="fullName" class="form-label fw-medium">Họ và tên</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-user text-muted"></i></span>
                                <input type="text" id="fullName" name="fullName" required placeholder="Nguyễn Văn A" class="form-control bg-light border-start-0 ps-0 rounded-end-3">
                            </div>
                        </div>

                        <div class="mb-3 animate-fadeInUp stagger-2">
                            <label for="email" class="form-label fw-medium">Email</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-envelope text-muted"></i></span>
                                <input type="email" id="email" name="email" required placeholder="email@example.com" class="form-control bg-light border-start-0 ps-0 rounded-end-3">
                            </div>
                        </div>

                        <div class="mb-3 animate-fadeInUp stagger-3">
                            <label for="phone" class="form-label fw-medium">Số điện thoại</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-phone text-muted"></i></span>
                                <input type="tel" id="phone" name="phone" required placeholder="0901234567" class="form-control bg-light border-start-0 ps-0 rounded-end-3">
                            </div>
                        </div>

                        <div class="row mb-3 animate-fadeInUp stagger-4">
                            <div class="col-6">
                                <label for="birthDate" class="form-label fw-medium">Ngày sinh</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-calendar text-muted"></i></span>
                                    <input type="date" id="birthDate" name="birthDate" required class="form-control bg-light border-start-0 ps-0 rounded-end-3">
                                </div>
                            </div>
                            <div class="col-6">
                                <label for="gender" class="form-label fw-medium">Giới tính</label>
                                <select id="gender" name="gender" required class="form-select bg-light rounded-3">
                                    <option value="">Chọn</option>
                                    <option value="male">Nam</option>
                                    <option value="female">Nữ</option>
                                    <option value="other">Khác</option>
                                </select>
                            </div>
                        </div>

                         <!-- Password -->
                        <div class="mb-3 animate-fadeInUp stagger-5">
                            <label for="password" class="form-label fw-medium">Mật khẩu</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-lock text-muted"></i></span>
                                <input type="password" id="password" name="password" required placeholder="Tối thiểu 8 ký tự" class="form-control bg-light border-start-0 border-end-0 ps-0" onkeyup="checkStrength(this.value)">
                                <button class="btn btn-light border border-start-0 rounded-end-3" type="button" onclick="togglePassword('password', 'eyeIcon1')">
                                    <i class="fas fa-eye text-muted" id="eyeIcon1"></i>
                                </button>
                            </div>
                            <!-- Strength meter -->
                            <div class="strength-meter">
                                <div class="strength-bar" id="bar1"></div>
                                <div class="strength-bar" id="bar2"></div>
                                <div class="strength-bar" id="bar3"></div>
                                <div class="strength-bar" id="bar4"></div>
                            </div>
                            <small id="strengthText" class="text-muted"></small>
                        </div>

                        <div class="mb-4 animate-fadeInUp stagger-6">
                            <label for="confirmPassword" class="form-label fw-medium">Xác nhận mật khẩu</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-lock text-muted"></i></span>
                                <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Nhập lại mật khẩu" class="form-control bg-light border-start-0 ps-0 rounded-end-3">
                            </div>
                        </div>

                        <div class="mb-4 form-check animate-fadeInUp stagger-7">
                            <input type="checkbox" id="agreeTerms" name="agreeTerms" class="form-check-input" required>
                             <label for="agreeTerms" class="form-check-label small">
                                Tôi đồng ý với <a href="#" class="text-primary text-decoration-none">Điều khoản sử dụng</a> và <a href="#" class="text-primary text-decoration-none">Chính sách bảo mật</a>
                            </label>
                        </div>

                        <!-- Submit -->
                        <button type="submit" class="btn btn-gradient w-100 py-3 rounded-3 fw-bold mb-4 hover-glow animate-fadeInUp stagger-8">
                            Tạo tài khoản <i class="fas fa-arrow-right ms-2"></i>
                        </button>
                    </form>
                    
                    <div class="text-center animate-fadeInUp">
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
        function togglePassword(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }
        
        function checkStrength(password) {
            let strength = 0;
            if (password.length >= 8) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;
            
            const bars = [
                document.getElementById('bar1'),
                document.getElementById('bar2'),
                document.getElementById('bar3'),
                document.getElementById('bar4')
            ];
            const text = document.getElementById('strengthText');
            
            bars.forEach((bar, i) => {
                bar.className = 'strength-bar';
                if (i < strength) {
                    if (strength <= 1) bar.classList.add('weak');
                    else if (strength <= 2) bar.classList.add('medium');
                    else bar.classList.add('strong');
                }
            });
            
            if (strength === 0) text.textContent = '';
            else if (strength === 1) text.textContent = 'Yếu';
            else if (strength === 2) text.textContent = 'Trung bình';
            else if (strength === 3) text.textContent = 'Mạnh';
            else text.textContent = 'Rất mạnh';
            
            text.className = 'small ' + (strength <= 1 ? 'text-danger' : strength <= 2 ? 'text-warning' : 'text-success');
        }
    </script>
</body>
</html>
