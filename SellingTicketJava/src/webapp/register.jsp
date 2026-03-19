<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title data-i18n="auth.register_title_page">Đăng ký - Ticketbox</title>
    
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

        .field-inline-error {
            display: block;
            color: #dc2626;
            font-size: 0.8rem;
            margin-top: 0.25rem;
        }

        .field-inline-ok {
            display: block;
            color: #059669;
            font-size: 0.8rem;
            margin-top: 0.25rem;
        }
        
        /* Language switcher for auth pages */
        .auth-lang-switcher {
            position: fixed;
            top: 16px;
            right: 16px;
            z-index: 100;
        }
        .auth-lang-switcher .dropdown-toggle {
            background: rgba(255,255,255,0.85);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0,0,0,0.08);
            border-radius: 50rem;
            padding: 6px 14px;
            font-size: 0.85rem;
            color: #374151;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        .auth-lang-switcher .dropdown-toggle:hover {
            background: rgba(255,255,255,0.95);
        }
    </style>
</head>
<body class="auth-page d-flex align-items-center justify-content-center py-4" data-context-path="${pageContext.request.contextPath}">
    <!-- Language Switcher -->
    <div class="auth-lang-switcher dropdown">
        <button class="btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false" id="authLangBtn">
            <i class="fas fa-globe me-1"></i> <span id="authCurrentLang">VI</span>
        </button>
        <ul class="dropdown-menu dropdown-menu-end">
            <li><a class="dropdown-item" href="#" onclick="switchAuthLang('vi')">🇻🇳 Tiếng Việt</a></li>
            <li><a class="dropdown-item" href="#" onclick="switchAuthLang('en')">🇺🇸 English</a></li>
            <li><a class="dropdown-item" href="#" onclick="switchAuthLang('ja')">🇯🇵 日本語</a></li>
        </ul>
    </div>

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
                    <h2 class="display-6 fw-bold mb-3 animate-fadeInLeft stagger-2" data-i18n="auth.join_now">Tham gia ngay!</h2>
                    <p class="fs-5 opacity-75 animate-fadeInLeft stagger-3" data-i18n="auth.register_hero_desc">Tạo tài khoản để bắt đầu khám phá hàng nghìn sự kiện hấp dẫn.</p>
                    
                    <!-- Benefits -->
                    <div class="mt-4 animate-fadeInUp stagger-4">
                        <div class="d-flex align-items-center gap-2 mb-2">
                            <i class="fas fa-check-circle text-white"></i>
                            <span class="small" data-i18n="auth.benefit1">Đặt vé nhanh chóng, an toàn</span>
                        </div>
                        <div class="d-flex align-items-center gap-2 mb-2">
                            <i class="fas fa-check-circle text-white"></i>
                            <span class="small" data-i18n="auth.benefit2">Nhận thông báo sự kiện hot</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="fas fa-check-circle text-white"></i>
                            <span class="small" data-i18n="auth.benefit3">Tích điểm đổi quà hấp dẫn</span>
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
                        <h2 class="fw-bold mb-2" data-i18n="auth.create_account">Tạo tài khoản mới</h2>
                        <p class="text-muted">
                            <span data-i18n="auth.have_account">Đã có tài khoản?</span> <a href="login.jsp" class="text-primary fw-medium text-decoration-none" data-i18n="auth.login_link">Đăng nhập</a>
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

                    <form id="registerForm" action="${pageContext.request.contextPath}/register" method="POST">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                        <div class="mb-3 animate-fadeInUp stagger-1">
                            <label for="fullName" class="form-label fw-medium" data-i18n="auth.full_name">Họ và tên</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-user text-muted"></i></span>
                                <input type="text" id="fullName" name="fullName" required data-i18n-placeholder="auth.full_name_placeholder" placeholder="Nguyễn Văn A" class="form-control bg-light border-start-0 ps-0 rounded-end-3 ${not empty fieldErrors.fullName ? 'is-invalid' : ''}" value="<c:out value='${not empty formFullName ? formFullName : param.fullName}'/>">
                            </div>
                            <c:if test="${not empty fieldErrors.fullName}"><small class="field-inline-error"><c:out value='${fieldErrors.fullName}'/></small></c:if>
                        </div>

                        <div class="mb-3 animate-fadeInUp stagger-2">
                            <label for="email" class="form-label fw-medium" data-i18n="auth.email">Email</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-envelope text-muted"></i></span>
                                <input type="email" id="email" name="email" required placeholder="email@example.com" class="form-control bg-light border-start-0 ps-0 rounded-end-3 ${not empty fieldErrors.email ? 'is-invalid' : ''}" value="<c:out value='${not empty formEmail ? formEmail : param.email}'/>">
                            </div>
                            <small id="emailFeedback" class="${not empty fieldErrors.email ? 'field-inline-error' : ''}"><c:out value='${fieldErrors.email}'/></small>
                        </div>

                        <div class="mb-3 animate-fadeInUp stagger-3">
                            <label for="phone" class="form-label fw-medium" data-i18n="auth.phone">Số điện thoại</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-phone text-muted"></i></span>
                                <input type="tel" id="phone" name="phone" placeholder="0901234567" class="form-control bg-light border-start-0 ps-0 rounded-end-3 ${not empty fieldErrors.phone ? 'is-invalid' : ''}" value="<c:out value='${not empty formPhone ? formPhone : param.phone}'/>">
                            </div>
                            <c:if test="${not empty fieldErrors.phone}"><small class="field-inline-error"><c:out value='${fieldErrors.phone}'/></small></c:if>
                        </div>

                        <div class="row mb-3 animate-fadeInUp stagger-4">
                            <div class="col-6">
                                <label for="birthDate" class="form-label fw-medium" data-i18n="auth.birth_date">Ngày sinh</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-calendar text-muted"></i></span>
                                    <input type="date" id="birthDate" name="birthDate" required class="form-control bg-light border-start-0 ps-0 rounded-end-3 ${not empty fieldErrors.birthDate ? 'is-invalid' : ''}" value="<c:out value='${not empty formBirthDate ? formBirthDate : param.birthDate}'/>">
                                </div>
                                <small id="birthDateFeedback" class="${not empty fieldErrors.birthDate ? 'field-inline-error' : ''}"><c:out value='${fieldErrors.birthDate}'/></small>
                            </div>
                            <div class="col-6">
                                <label for="gender" class="form-label fw-medium" data-i18n="auth.gender">Giới tính</label>
                                <select id="gender" name="gender" class="form-select bg-light rounded-3 ${not empty fieldErrors.gender ? 'is-invalid' : ''}">
                                    <option value="" ${empty formGender && empty param.gender ? 'selected' : ''} data-i18n="auth.gender_select">Chọn</option>
                                    <option value="male" ${(formGender == 'male' || param.gender == 'male') ? 'selected' : ''} data-i18n="auth.gender_male">Nam</option>
                                    <option value="female" ${(formGender == 'female' || param.gender == 'female') ? 'selected' : ''} data-i18n="auth.gender_female">Nữ</option>
                                    <option value="other" ${(formGender == 'other' || param.gender == 'other') ? 'selected' : ''} data-i18n="auth.gender_other">Khác</option>
                                </select>
                                <c:if test="${not empty fieldErrors.gender}"><small class="field-inline-error"><c:out value='${fieldErrors.gender}'/></small></c:if>
                            </div>
                        </div>

                         <!-- Password -->
                        <div class="mb-3 animate-fadeInUp stagger-5">
                            <label for="password" class="form-label fw-medium" data-i18n="auth.password">Mật khẩu</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-lock text-muted"></i></span>
                                <input type="password" id="password" name="password" required data-i18n-placeholder="auth.password_min" placeholder="Tối thiểu 8 ký tự" class="form-control bg-light border-start-0 border-end-0 ps-0 ${not empty fieldErrors.password ? 'is-invalid' : ''}" onkeyup="checkStrength(this.value)">
                                <button class="btn btn-light border border-start-0 rounded-end-3" type="button" onclick="togglePassword('password', 'eyeIcon1')">
                                    <i class="fas fa-eye text-muted" id="eyeIcon1"></i>
                                </button>
                            </div>
                            <c:if test="${not empty fieldErrors.password}"><small class="field-inline-error"><c:out value='${fieldErrors.password}'/></small></c:if>
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
                            <label for="confirmPassword" class="form-label fw-medium" data-i18n="auth.confirm_password">Xác nhận mật khẩu</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 rounded-start-3"><i class="fas fa-lock text-muted"></i></span>
                                <input type="password" id="confirmPassword" name="confirmPassword" required data-i18n-placeholder="auth.confirm_password_placeholder" placeholder="Nhập lại mật khẩu" class="form-control bg-light border-start-0 ps-0 rounded-end-3 ${not empty fieldErrors.confirmPassword ? 'is-invalid' : ''}">
                            </div>
                            <c:if test="${not empty fieldErrors.confirmPassword}"><small class="field-inline-error"><c:out value='${fieldErrors.confirmPassword}'/></small></c:if>
                        </div>

                        <div class="mb-4 form-check animate-fadeInUp stagger-7">
                            <input type="checkbox" id="agreeTerms" name="agreeTerms" class="form-check-input" required ${param.agreeTerms == 'on' ? 'checked' : ''}>
                             <label for="agreeTerms" class="form-check-label small">
                                <span data-i18n="auth.agree_prefix">Tôi đồng ý với</span> <a href="#" class="text-primary text-decoration-none" data-i18n="auth.terms_link">Điều khoản sử dụng</a> <span data-i18n="auth.agree_and">và</span> <a href="#" class="text-primary text-decoration-none" data-i18n="auth.privacy_link">Chính sách bảo mật</a>
                            </label>
                        </div>

                        <!-- Submit -->
                        <button type="submit" class="btn btn-gradient w-100 py-3 rounded-3 fw-bold mb-4 hover-glow animate-fadeInUp stagger-8">
                            <span data-i18n="auth.register_btn">Tạo tài khoản</span> <i class="fas fa-arrow-right ms-2"></i>
                        </button>
                    </form>
                    
                    <div class="text-center animate-fadeInUp">
                        <a href="home" class="small text-muted text-decoration-none d-inline-flex align-items-center gap-2 hover-lift">
                            <i class="fas fa-arrow-left"></i> <span data-i18n="auth.back_home">Quay về trang chủ</span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/animations.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/i18n.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    <script>
        const REGISTER_CONTEXT_PATH = '${pageContext.request.contextPath}';
        const EMAIL_CACHE_TTL_MS = 5 * 60 * 1000;
        const emailAvailabilityCache = new Map();
        let emailCheckController = null;
        let emailExists = false;

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
        
        function _t(key, fallback) {
            return (typeof window.__i18n !== 'undefined' && window.__i18n[key]) ? window.__i18n[key] : fallback;
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
            else if (strength === 1) text.textContent = _t('auth.pw_weak', 'Yếu');
            else if (strength === 2) text.textContent = _t('auth.pw_medium', 'Trung bình');
            else if (strength === 3) text.textContent = _t('auth.pw_strong', 'Mạnh');
            else text.textContent = _t('auth.pw_very_strong', 'Rất mạnh');
            
            text.className = 'small ' + (strength <= 1 ? 'text-danger' : strength <= 2 ? 'text-warning' : 'text-success');
        }

        function getAge(dateString) {
            const dob = new Date(dateString);
            const now = new Date();
            let age = now.getFullYear() - dob.getFullYear();
            const monthDiff = now.getMonth() - dob.getMonth();
            if (monthDiff < 0 || (monthDiff === 0 && now.getDate() < dob.getDate())) {
                age--;
            }
            return age;
        }

        function validateBirthDateInline() {
            const birthDateInput = document.getElementById('birthDate');
            const feedback = document.getElementById('birthDateFeedback');
            if (!birthDateInput || !feedback) return true;
            if (!birthDateInput.value) {
                feedback.textContent = '';
                feedback.className = '';
                birthDateInput.classList.remove('is-invalid');
                return true;
            }

            const selected = new Date(birthDateInput.value + 'T00:00:00');
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            if (selected > today) {
                birthDateInput.classList.add('is-invalid');
                feedback.textContent = _t('auth.birthdate_future', 'Ngày sinh không thể ở tương lai');
                feedback.className = 'field-inline-error';
                return false;
            }

            const age = getAge(birthDateInput.value);
            if (age < 16) {
                birthDateInput.classList.add('is-invalid');
                feedback.textContent = _t('auth.birthdate_underage', 'Bạn phải đủ 16 tuổi để tạo tài khoản');
                feedback.className = 'field-inline-error';
                return false;
            }

            birthDateInput.classList.remove('is-invalid');
            feedback.textContent = '';
            feedback.className = '';
            return true;
        }

        function isValidEmailFormat(email) {
            return /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(email || '');
        }

        function getEmailTypoSuggestion(email) {
            if (!email || email.indexOf('@') < 1) return null;
            const at = email.lastIndexOf('@');
            const localPart = email.substring(0, at);
            const domain = email.substring(at + 1);
            const typoMap = {
                'mgail.com': 'gmail.com',
                'gamil.com': 'gmail.com',
                'gnail.com': 'gmail.com',
                'hotnail.com': 'hotmail.com',
                'yaho.com': 'yahoo.com',
                'outllok.com': 'outlook.com'
            };
            if (!typoMap[domain]) return null;
            return localPart + '@' + typoMap[domain];
        }

        function getCachedEmailResult(email) {
            const cached = emailAvailabilityCache.get(email);
            if (!cached) return null;
            if (Date.now() > cached.expiresAt) {
                emailAvailabilityCache.delete(email);
                return null;
            }
            return cached;
        }

        function setCachedEmailResult(email, exists, message) {
            emailAvailabilityCache.set(email, {
                exists: !!exists,
                message: message || (exists ? _t('auth.email_exists', 'Email đã tồn tại') : _t('auth.email_available', 'Email có thể sử dụng')),
                expiresAt: Date.now() + EMAIL_CACHE_TTL_MS
            });
            if (emailAvailabilityCache.size > 200) {
                const firstKey = emailAvailabilityCache.keys().next().value;
                if (firstKey) emailAvailabilityCache.delete(firstKey);
            }
        }

        function showEmailFeedback(emailInput, feedback, message, kind) {
            emailInput.classList.remove('is-valid', 'is-invalid');
            feedback.textContent = message || '';
            if (kind === 'error') {
                emailInput.classList.add('is-invalid');
                feedback.className = 'field-inline-error';
            } else if (kind === 'ok') {
                emailInput.classList.add('is-valid');
                feedback.className = 'field-inline-ok';
            } else {
                feedback.className = 'text-muted small';
            }
        }

        async function checkEmailAvailability(forceServer) {
            const emailInput = document.getElementById('email');
            const feedback = document.getElementById('emailFeedback');
            if (!emailInput || !feedback) return true;

            const email = (emailInput.value || '').trim().toLowerCase();
            emailExists = false;

            if (!email) {
                feedback.textContent = '';
                feedback.className = '';
                emailInput.classList.remove('is-invalid', 'is-valid');
                return true;
            }

            const typoSuggestion = getEmailTypoSuggestion(email);
            if (typoSuggestion) {
                showEmailFeedback(emailInput, feedback, _t('auth.email_typo', 'Bạn có muốn dùng: ') + typoSuggestion + ' ?', 'error');
                return false;
            }

            if (!isValidEmailFormat(email)) {
                showEmailFeedback(emailInput, feedback, _t('auth.email_invalid', 'Email không hợp lệ'), 'error');
                return false;
            }

            if (!forceServer) {
                const cached = getCachedEmailResult(email);
                if (cached) {
                    emailExists = cached.exists;
                    showEmailFeedback(emailInput, feedback, cached.message, cached.exists ? 'error' : 'ok');
                    return !cached.exists;
                }
            }

            feedback.textContent = _t('auth.email_checking', 'Đang kiểm tra email...');
            feedback.className = 'text-muted small';

            try {
                if (emailCheckController) {
                    emailCheckController.abort();
                }
                emailCheckController = new AbortController();

                const resp = await fetch(REGISTER_CONTEXT_PATH + '/api/auth/check-email?email=' + encodeURIComponent(email), {
                    method: 'GET',
                    credentials: 'same-origin',
                    signal: emailCheckController.signal,
                    headers: { 'Accept': 'application/json' }
                });
                const data = await resp.json();
                emailExists = !!data.exists;
                setCachedEmailResult(email, emailExists, data.message);

                if (emailExists) {
                    showEmailFeedback(emailInput, feedback, data.message || _t('auth.email_exists', 'Email đã tồn tại'), 'error');
                    return false;
                }

                showEmailFeedback(emailInput, feedback, data.message || _t('auth.email_available', 'Email có thể sử dụng'), 'ok');
                return true;
            } catch (e) {
                if (e && e.name === 'AbortError') {
                    return false;
                }
                emailInput.classList.remove('is-valid');
                feedback.textContent = '';
                feedback.className = '';
                return true;
            }
        }

        const emailInput = document.getElementById('email');
        if (emailInput) {
            emailInput.addEventListener('input', function() {
                const feedback = document.getElementById('emailFeedback');
                const normalized = (emailInput.value || '').trim().toLowerCase();
                emailExists = false;

                if (!normalized) {
                    emailInput.classList.remove('is-valid', 'is-invalid');
                    if (feedback) {
                        feedback.textContent = '';
                        feedback.className = '';
                    }
                    return;
                }

                const suggestion = getEmailTypoSuggestion(normalized);
                if (suggestion) {
                    showEmailFeedback(emailInput, feedback, _t('auth.email_typo', 'Bạn có muốn dùng: ') + suggestion + ' ?', 'error');
                    return;
                }

                if (!isValidEmailFormat(normalized)) {
                    showEmailFeedback(emailInput, feedback, _t('auth.email_invalid', 'Email không hợp lệ'), 'error');
                    return;
                }

                const cached = getCachedEmailResult(normalized);
                if (cached) {
                    emailExists = cached.exists;
                    showEmailFeedback(emailInput, feedback, cached.message, cached.exists ? 'error' : 'ok');
                    return;
                }

                emailInput.classList.remove('is-valid', 'is-invalid');
                if (feedback) {
                    feedback.textContent = _t('auth.email_valid_format', 'Định dạng hợp lệ. Rời ô để kiểm tra tồn tại.');
                    feedback.className = 'text-muted small';
                }
            });

            emailInput.addEventListener('blur', function() {
                emailInput.value = (emailInput.value || '').trim().toLowerCase();
                checkEmailAvailability(false);
            });
        }

        const birthDateInput = document.getElementById('birthDate');
        if (birthDateInput) {
            const today = new Date();
            const maxDate = new Date(today.getFullYear() - 16, today.getMonth(), today.getDate());
            const maxDateStr = maxDate.getFullYear()
                + '-' + String(maxDate.getMonth() + 1).padStart(2, '0')
                + '-' + String(maxDate.getDate()).padStart(2, '0');
            birthDateInput.max = maxDateStr;
            birthDateInput.addEventListener('change', validateBirthDateInline);
            if (birthDateInput.value) validateBirthDateInline();
        }

        const registerForm = document.getElementById('registerForm');
        if (registerForm) {
            registerForm.addEventListener('submit', async function(e) {
                const emailOk = await checkEmailAvailability(true);
                const ageOk = validateBirthDateInline();
                if (!emailOk || !ageOk || emailExists) {
                    e.preventDefault();
                    if (typeof showToast === 'function') {
                        showToast(_t('auth.check_info', 'Vui lòng kiểm tra lại thông tin đăng ký'), 'error');
                    }
                }
            });
        }
        
        // Auth page language switcher
        function switchAuthLang(lang) {
            if (typeof i18n !== 'undefined') {
                i18n.setLanguage(lang);
                const labelMap = { vi: 'VI', en: 'EN', ja: 'JA' };
                document.getElementById('authCurrentLang').textContent = labelMap[lang] || lang.toUpperCase();
            }
        }
        
        // Sync initial lang indicator
        document.addEventListener('DOMContentLoaded', function() {
            const savedLang = localStorage.getItem('ticketbox.language') || 'vi';
            const labelMap = { vi: 'VI', en: 'EN', ja: 'JA' };
            const el = document.getElementById('authCurrentLang');
            if (el) el.textContent = labelMap[savedLang] || savedLang.toUpperCase();
        });
    </script>
</body>
</html>
