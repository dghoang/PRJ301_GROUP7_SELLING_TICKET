/**
 * Ticketbox Toast Notification System v2.0
 * Premium bottom-right toast notifications with glassmorphism design.
 * Features: stacking (max 4), auto-dismiss, progress bar, accessibility.
 */

class ToastNotification {
    constructor() {
        this.container = null;
        this.maxToasts = 4;
        this.init();
    }

    init() {
        if (!document.getElementById('toast-container')) {
            this.container = document.createElement('div');
            this.container.id = 'toast-container';
            this.container.className = 'toast-container';
            this.container.setAttribute('aria-live', 'polite');
            this.container.setAttribute('aria-atomic', 'false');
            document.body.appendChild(this.container);
        } else {
            this.container = document.getElementById('toast-container');
        }
    }

    show(message, type = 'info', duration = 4000) {
        // Enforce max toasts — remove oldest if exceeded
        const existing = this.container.querySelectorAll('.toast-notification');
        if (existing.length >= this.maxToasts) {
            const oldest = existing[existing.length - 1];
            oldest.classList.remove('show');
            setTimeout(() => oldest.remove(), 300);
        }

        const toast = document.createElement('div');
        toast.className = `toast-notification toast-${type}`;
        toast.setAttribute('role', 'alert');
        toast.setAttribute('aria-live', 'assertive');

        const icons = {
            success: 'fa-check-circle',
            error: 'fa-times-circle',
            warning: 'fa-exclamation-triangle',
            info: 'fa-info-circle'
        };

        const titles = {
            success: 'Thành công',
            error: 'Lỗi',
            warning: 'Cảnh báo',
            info: 'Thông báo'
        };

        toast.innerHTML = `
            <div class="toast-icon">
                <i class="fas ${icons[type] || icons.info}"></i>
            </div>
            <div class="toast-content">
                <div class="toast-title">${titles[type] || titles.info}</div>
                <div class="toast-message">${message}</div>
            </div>
            <button class="toast-close" aria-label="Đóng thông báo">
                <i class="fas fa-times"></i>
            </button>
            <div class="toast-progress">
                <div class="toast-progress-bar" style="animation-duration: ${duration}ms"></div>
            </div>
        `;

        // Close button handler
        toast.querySelector('.toast-close').addEventListener('click', () => {
            this._dismiss(toast);
        });

        // Insert at the beginning (newest on bottom due to column-reverse)
        this.container.insertBefore(toast, this.container.firstChild);

        // Trigger slide-in animation
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                toast.classList.add('show');
            });
        });

        // Auto dismiss after duration
        const timer = setTimeout(() => this._dismiss(toast), duration);

        // Pause on hover
        toast.addEventListener('mouseenter', () => {
            clearTimeout(timer);
            const bar = toast.querySelector('.toast-progress-bar');
            if (bar) bar.style.animationPlayState = 'paused';
        });

        toast.addEventListener('mouseleave', () => {
            const bar = toast.querySelector('.toast-progress-bar');
            if (bar) bar.style.animationPlayState = 'running';
            setTimeout(() => this._dismiss(toast), 2000);
        });

        return toast;
    }

    _dismiss(toast) {
        if (!toast || !toast.parentElement) return;
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 400);
    }

    success(message, duration) { return this.show(message, 'success', duration); }
    error(message, duration)   { return this.show(message, 'error', duration); }
    warning(message, duration) { return this.show(message, 'warning', duration); }
    info(message, duration)    { return this.show(message, 'info', duration); }
}

// Global singleton
const toast = new ToastNotification();

// Helper functions
function showToast(message, type = 'info', duration = 4000) {
    return toast.show(message, type, duration);
}
function showSuccess(message) { return toast.success(message); }
function showError(message)   { return toast.error(message); }
function showWarning(message) { return toast.warning(message); }
function showInfo(message)    { return toast.info(message); }

// Auto-show toast from URL parameters (e.g. ?msg=Hello&msgType=success)
document.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const msg = urlParams.get('msg');
    const msgType = urlParams.get('msgType') || 'info';

    if (msg) {
        showToast(decodeURIComponent(msg), msgType);
        const url = new URL(window.location);
        url.searchParams.delete('msg');
        url.searchParams.delete('msgType');
        window.history.replaceState({}, '', url);
    }
});
