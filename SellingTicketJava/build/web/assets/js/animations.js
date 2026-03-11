/**
 * Ticketbox Animations - Modern Animation Utilities
 * Scroll animations, counters, and interactive effects
 */

(function() {
    'use strict';

    // ================================
    // SCROLL ANIMATIONS (Intersection Observer)
    // ================================
    
    const initScrollAnimations = () => {
        const animatedElements = document.querySelectorAll('.animate-on-scroll');
        
        if (!animatedElements.length) return;
        
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                    // Optionally unobserve after animation
                    // observer.unobserve(entry.target);
                }
            });
        }, observerOptions);
        
        animatedElements.forEach(el => observer.observe(el));
    };

    // ================================
    // COUNTER ANIMATION
    // ================================
    
    const animateCounter = (element, target, duration = 2000) => {
        const start = 0;
        const increment = target / (duration / 16);
        let current = start;
        
        const updateCounter = () => {
            current += increment;
            if (current < target) {
                element.textContent = formatNumber(Math.floor(current));
                requestAnimationFrame(updateCounter);
            } else {
                element.textContent = formatNumber(target);
            }
        };
        
        updateCounter();
    };
    
    const formatNumber = (num) => {
        if (num >= 1000000) {
            return (num / 1000000).toFixed(0) + 'M+';
        } else if (num >= 1000) {
            return (num / 1000).toFixed(0) + 'K+';
        }
        return num.toString();
    };
    
    const initCounterAnimations = () => {
        const counters = document.querySelectorAll('[data-counter]');
        
        if (!counters.length) return;
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting && !entry.target.dataset.animated) {
                    const target = parseInt(entry.target.dataset.counter, 10);
                    animateCounter(entry.target, target);
                    entry.target.dataset.animated = 'true';
                }
            });
        }, { threshold: 0.5 });
        
        counters.forEach(counter => observer.observe(counter));
    };

    // ================================
    // COUNTDOWN TIMER
    // ================================
    
    const initCountdown = () => {
        const countdownElements = document.querySelectorAll('[data-countdown]');
        
        countdownElements.forEach(element => {
            const targetDate = new Date(element.dataset.countdown).getTime();
            
            const updateCountdown = () => {
                const now = new Date().getTime();
                const distance = targetDate - now;
                
                if (distance < 0) {
                    element.innerHTML = '<span class="badge badge-sold-out">Đã kết thúc</span>';
                    return;
                }
                
                const days = Math.floor(distance / (1000 * 60 * 60 * 24));
                const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((distance % (1000 * 60)) / 1000);
                
                const daysEl = element.querySelector('.countdown-days');
                const hoursEl = element.querySelector('.countdown-hours');
                const minutesEl = element.querySelector('.countdown-minutes');
                const secondsEl = element.querySelector('.countdown-seconds');
                
                if (daysEl) daysEl.textContent = String(days).padStart(2, '0');
                if (hoursEl) hoursEl.textContent = String(hours).padStart(2, '0');
                if (minutesEl) minutesEl.textContent = String(minutes).padStart(2, '0');
                if (secondsEl) secondsEl.textContent = String(seconds).padStart(2, '0');
            };
            
            updateCountdown();
            setInterval(updateCountdown, 1000);
        });
    };

    // ================================
    // TYPED TEXT EFFECT
    // ================================
    
    const initTypedText = () => {
        const typedElements = document.querySelectorAll('[data-typed]');
        
        typedElements.forEach(element => {
            const texts = element.dataset.typed.split('|');
            let textIndex = 0;
            let charIndex = 0;
            let isDeleting = false;
            
            const type = () => {
                const currentText = texts[textIndex];
                
                if (isDeleting) {
                    element.textContent = currentText.substring(0, charIndex - 1);
                    charIndex--;
                } else {
                    element.textContent = currentText.substring(0, charIndex + 1);
                    charIndex++;
                }
                
                let typeSpeed = isDeleting ? 50 : 100;
                
                if (!isDeleting && charIndex === currentText.length) {
                    typeSpeed = 2000; // Pause at end
                    isDeleting = true;
                } else if (isDeleting && charIndex === 0) {
                    isDeleting = false;
                    textIndex = (textIndex + 1) % texts.length;
                    typeSpeed = 500;
                }
                
                setTimeout(type, typeSpeed);
            };
            
            type();
        });
    };

    // ================================
    // SMOOTH SCROLL
    // ================================
    
    const initSmoothScroll = () => {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                const targetId = this.getAttribute('href');
                if (targetId === '#') return;
                
                const target = document.querySelector(targetId);
                if (target) {
                    e.preventDefault();
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
    };

    // ================================
    // PARALLAX EFFECT
    // ================================
    
    const initParallax = () => {
        const parallaxElements = document.querySelectorAll('[data-parallax]');
        
        if (!parallaxElements.length) return;
        
        window.addEventListener('scroll', () => {
            const scrollY = window.pageYOffset;
            
            parallaxElements.forEach(element => {
                const speed = parseFloat(element.dataset.parallax) || 0.5;
                const yPos = -(scrollY * speed);
                element.style.transform = `translateY(${yPos}px)`;
            });
        }, { passive: true });
    };

    // ================================
    // NAVBAR SCROLL EFFECT
    // ================================
    
    const initNavbarScroll = () => {
        const navbar = document.querySelector('.navbar-glass');
        if (!navbar) return;
        
        let lastScroll = 0;
        
        window.addEventListener('scroll', () => {
            const currentScroll = window.pageYOffset;
            
            if (currentScroll > 100) {
                navbar.classList.add('navbar-scrolled');
            } else {
                navbar.classList.remove('navbar-scrolled');
            }
            
            // Hide/show on scroll
            if (currentScroll > lastScroll && currentScroll > 200) {
                navbar.style.transform = 'translateY(-100%)';
            } else {
                navbar.style.transform = 'translateY(0)';
            }
            
            lastScroll = currentScroll;
        }, { passive: true });
    };

    // ================================
    // CARD TILT EFFECT
    // ================================
    
    const initCardTilt = () => {
        const tiltCards = document.querySelectorAll('.card-3d');
        
        tiltCards.forEach(card => {
            card.addEventListener('mousemove', (e) => {
                const rect = card.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                
                const rotateX = (y - centerY) / 10;
                const rotateY = (centerX - x) / 10;
                
                card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
            });
            
            card.addEventListener('mouseleave', () => {
                card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0)';
            });
        });
    };

    // ================================
    // STAGGER CHILDREN ANIMATION
    // ================================
    
    const initStaggerAnimation = () => {
        const staggerContainers = document.querySelectorAll('[data-stagger-children]');
        
        staggerContainers.forEach(container => {
            const children = container.children;
            const delay = parseFloat(container.dataset.staggerChildren) || 0.1;
            
            Array.from(children).forEach((child, index) => {
                child.style.transitionDelay = `${index * delay}s`;
                child.style.animationDelay = `${index * delay}s`;
            });
        });
    };

    // ================================
    // RIPPLE EFFECT
    // ================================
    
    const initRippleEffect = () => {
        document.querySelectorAll('.btn-gradient, .btn-primary').forEach(button => {
            button.addEventListener('click', function(e) {
                const rect = this.getBoundingClientRect();
                const ripple = document.createElement('span');
                
                ripple.className = 'ripple-effect';
                ripple.style.left = `${e.clientX - rect.left}px`;
                ripple.style.top = `${e.clientY - rect.top}px`;
                
                this.appendChild(ripple);
                
                setTimeout(() => ripple.remove(), 600);
            });
        });
    };

    // ================================
    // LAZY LOAD IMAGES
    // ================================
    
    const initLazyLoad = () => {
        const lazyImages = document.querySelectorAll('img[data-src]');
        
        if (!lazyImages.length) return;
        
        const imageObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                    img.classList.add('loaded');
                    imageObserver.unobserve(img);
                }
            });
        });
        
        lazyImages.forEach(img => imageObserver.observe(img));
    };

    // ================================
    // INITIALIZE ALL
    // ================================
    
    const init = () => {
        initScrollAnimations();
        initCounterAnimations();
        initCountdown();
        initTypedText();
        initSmoothScroll();
        initParallax();
        initNavbarScroll();
        initCardTilt();
        initStaggerAnimation();
        initRippleEffect();
        initLazyLoad();
        
        console.log('🎨 Ticketbox Animations initialized');
    };

    // Run on DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
