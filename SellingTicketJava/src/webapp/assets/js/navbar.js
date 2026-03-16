document.addEventListener('DOMContentLoaded', function() {
    // Navbar scroll effect
    window.addEventListener('scroll', function() {
        const navbar = document.getElementById('mainNavbar');
        if (navbar) {
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        }
    });

    // Full-page language switching (VN/EN/JP) via Google Translate cookie strategy.
    const navLanguageSelect = document.getElementById('navLanguageSelect');
    if (navLanguageSelect) {
        const storageKey = 'ticketbox.language';

        function getCookie(name) {
            const target = name + '=';
            const cookies = document.cookie ? document.cookie.split(';') : [];
            for (let i = 0; i < cookies.length; i++) {
                const c = cookies[i].trim();
                if (c.indexOf(target) === 0) return c.substring(target.length);
            }
            return '';
        }

        function detectLanguage() {
            const cookieLang = (getCookie('googtrans') || '').split('/').pop();
            if (cookieLang === 'vi' || cookieLang === 'en' || cookieLang === 'ja') {
                return cookieLang;
            }
            const saved = (localStorage.getItem(storageKey) || '').toLowerCase();
            if (saved === 'vi' || saved === 'en' || saved === 'ja') {
                return saved;
            }
            return 'vi';
        }

        function setLanguageCookie(lang) {
            const value = '/vi/' + lang;
            const contextPath = document.body.dataset.contextPath || '/';
            document.cookie = 'googtrans=' + value + '; path=/';
            document.cookie = 'googtrans=' + value + '; path=' + contextPath;
        }

        const savedLang = detectLanguage();
        if ([...navLanguageSelect.options].some(opt => opt.value === savedLang)) {
            navLanguageSelect.value = savedLang;
            document.documentElement.setAttribute('lang', savedLang);
        }

        navLanguageSelect.addEventListener('change', function() {
            const nextLang = this.value;
            localStorage.setItem(storageKey, nextLang);
            setLanguageCookie(nextLang);
            document.documentElement.setAttribute('lang', nextLang);
            window.location.reload();
        });
    }
});
