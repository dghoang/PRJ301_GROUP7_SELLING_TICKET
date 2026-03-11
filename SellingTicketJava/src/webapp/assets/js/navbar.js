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

    // Search redirect - updated to use ?search= instead of ?q=
    const navSearchInput = document.getElementById('navSearchInput');
    if (navSearchInput) {
        navSearchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && this.value.trim()) {
                const contextPath = document.body.dataset.contextPath || '';
                window.location.href = contextPath + '/events?search=' + encodeURIComponent(this.value.trim());
            }
        });
    }
});
