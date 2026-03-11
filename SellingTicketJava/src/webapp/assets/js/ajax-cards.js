/**
 * AjaxCards — Reusable AJAX-powered card grid with search, filter, pagination.
 * Used for public events page, organizer events, and my-tickets page.
 * 
 * Features:
 * - Debounced search (300ms)
 * - Category pill toggle filters
 * - Dropdown sort
 * - Date range & price range filters
 * - Server-side pagination
 * - URL state sync (History API)
 * - Skeleton card loading animation
 * - Empty state display
 * 
 * Usage:
 *   const cards = new AjaxCards({
 *       apiUrl: '/api/events',
 *       container: '#cards-container',
 *       paginationContainer: '#pagination',
 *       searchInput: '#search-input',
 *       renderCard: (item) => '<div class="col-md-4">...</div>',
 *       pageSize: 12
 *   });
 *   cards.init();
 */
class AjaxCards {
    constructor(config) {
        this.apiUrl = config.apiUrl;
        this.container = document.querySelector(config.container);
        this.paginationContainer = document.querySelector(config.paginationContainer);
        this.searchInput = document.querySelector(config.searchInput);
        this.renderCard = config.renderCard;
        this.renderEmpty = config.renderEmpty || this._defaultEmpty;
        this.onDataLoaded = config.onDataLoaded || null;
        this.pageSize = config.pageSize || 12;
        this.currentPage = 1;
        this.totalPages = 0;
        this.totalItems = 0;
        this.debounceTimer = null;
        this.isLoading = false;
        this.skeletonCount = config.skeletonCount || 6;
        this.skeletonHtml = config.skeletonHtml || this._defaultSkeleton();
        this.totalItemsEl = config.totalItemsEl ? document.querySelector(config.totalItemsEl) : null;
    }

    init() {
        this._loadFromURL();
        this._bindSearch();
        this._bindFilters();
        this._bindPills();
        this._bindPopState();
        this.load();
    }

    // ========================
    // DATA LOADING
    // ========================

    load() {
        if (this.isLoading) return;
        this.isLoading = true;
        this._showSkeleton();

        const params = this._buildParams();
        const url = this.apiUrl + '?' + params.toString();

        fetch(url, { credentials: 'same-origin' })
            .then(res => res.json())
            .then(data => {
                this.isLoading = false;
                if (data.success) {
                    this.totalItems = data.totalItems;
                    this.totalPages = data.totalPages;
                    this.currentPage = data.currentPage;
                    this._renderCards(data.items);
                    this._renderPagination();
                    this._updateURL();
                    if (this.totalItemsEl) {
                        this.totalItemsEl.textContent = data.totalItems;
                    }
                    if (this.onDataLoaded) this.onDataLoaded(data);
                } else {
                    this._showError(data.error || 'Có lỗi xảy ra');
                }
            })
            .catch(err => {
                this.isLoading = false;
                console.error('AjaxCards fetch error:', err);
                this._showError('Không thể tải dữ liệu. Vui lòng thử lại.');
            });
    }

    // ========================
    // SEARCH
    // ========================

    _bindSearch() {
        if (!this.searchInput) return;
        this.searchInput.addEventListener('input', () => {
            clearTimeout(this.debounceTimer);
            this.debounceTimer = setTimeout(() => {
                this.currentPage = 1;
                this.load();
            }, 300);
        });

        const clearBtn = this.searchInput.parentElement?.querySelector('.search-clear');
        if (clearBtn) {
            clearBtn.addEventListener('click', () => {
                this.searchInput.value = '';
                this.currentPage = 1;
                this.load();
            });
        }
    }

    // ========================
    // PILL FILTERS (category pills, status tabs)
    // ========================

    _bindPills() {
        document.querySelectorAll('[data-pill-group]').forEach(group => {
            const paramName = group.dataset.pillGroup;
            const isMulti = group.dataset.pillMulti === 'true';

            group.querySelectorAll('[data-pill-value]').forEach(pill => {
                pill.addEventListener('click', (e) => {
                    e.preventDefault();
                    const value = pill.dataset.pillValue;

                    if (isMulti) {
                        pill.classList.toggle('active');
                    } else {
                        // Single select: deactivate siblings
                        group.querySelectorAll('[data-pill-value]').forEach(p => p.classList.remove('active'));
                        if (value) pill.classList.add('active');
                    }

                    this.currentPage = 1;
                    this.load();
                });
            });
        });
    }

    // ========================
    // FILTERS
    // ========================

    _bindFilters() {
        // Select dropdowns
        document.querySelectorAll('[data-filter-select]').forEach(select => {
            select.addEventListener('change', () => {
                this.currentPage = 1;
                this.load();
            });
        });

        // Date range
        document.querySelectorAll('[data-filter-date]').forEach(input => {
            input.addEventListener('change', () => {
                this.currentPage = 1;
                this.load();
            });
        });

        // Number range (price)
        document.querySelectorAll('[data-filter-number]').forEach(input => {
            let timer;
            input.addEventListener('input', () => {
                clearTimeout(timer);
                timer = setTimeout(() => {
                    this.currentPage = 1;
                    this.load();
                }, 500);
            });
        });

        // Checkbox groups
        document.querySelectorAll('[data-filter-group]').forEach(group => {
            group.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                cb.addEventListener('change', () => {
                    this.currentPage = 1;
                    this.load();
                });
            });
        });
    }

    _getFilterValues() {
        const filters = {};

        // Pill groups
        document.querySelectorAll('[data-pill-group]').forEach(group => {
            const name = group.dataset.pillGroup;
            const active = [];
            group.querySelectorAll('[data-pill-value].active').forEach(p => {
                if (p.dataset.pillValue) active.push(p.dataset.pillValue);
            });
            if (active.length === 1) filters[name] = active[0];
            else if (active.length > 1) filters[name] = active;
        });

        // Select dropdowns
        document.querySelectorAll('[data-filter-select]').forEach(select => {
            const name = select.dataset.filterSelect;
            if (select.value) filters[name] = select.value;
        });

        // Date range
        document.querySelectorAll('[data-filter-date]').forEach(input => {
            const name = input.dataset.filterDate;
            if (input.value) filters[name] = input.value;
        });

        // Number range
        document.querySelectorAll('[data-filter-number]').forEach(input => {
            const name = input.dataset.filterNumber;
            if (input.value) filters[name] = input.value;
        });

        // Checkbox groups
        document.querySelectorAll('[data-filter-group]').forEach(group => {
            const name = group.dataset.filterGroup;
            const checked = [];
            group.querySelectorAll('input[type="checkbox"]:checked').forEach(cb => {
                checked.push(cb.value);
            });
            if (checked.length > 0) filters[name] = checked;
        });

        return filters;
    }

    // ========================
    // URL STATE
    // ========================

    _buildParams() {
        const params = new URLSearchParams();
        params.set('page', this.currentPage);
        params.set('size', this.pageSize);

        if (this.searchInput && this.searchInput.value.trim()) {
            params.set('q', this.searchInput.value.trim());
        }

        const filters = this._getFilterValues();
        for (const [key, val] of Object.entries(filters)) {
            if (Array.isArray(val)) {
                val.forEach(v => params.append(key, v));
            } else {
                params.set(key, val);
            }
        }

        return params;
    }

    _updateURL() {
        const params = this._buildParams();
        const newUrl = window.location.pathname + '?' + params.toString();
        if (window.location.search !== '?' + params.toString()) {
            history.pushState({ page: this.currentPage }, '', newUrl);
        }
    }

    _loadFromURL() {
        const params = new URLSearchParams(window.location.search);

        if (params.has('page')) {
            this.currentPage = parseInt(params.get('page')) || 1;
        }
        if (params.has('q') && this.searchInput) {
            this.searchInput.value = params.get('q');
        }

        // Restore pill filters
        document.querySelectorAll('[data-pill-group]').forEach(group => {
            const name = group.dataset.pillGroup;
            const values = params.getAll(name);
            if (values.length > 0) {
                group.querySelectorAll('[data-pill-value]').forEach(p => {
                    p.classList.toggle('active', values.includes(p.dataset.pillValue));
                });
            }
        });

        // Restore select filters
        document.querySelectorAll('[data-filter-select]').forEach(select => {
            const name = select.dataset.filterSelect;
            if (params.has(name)) select.value = params.get(name);
        });

        // Restore date filters
        document.querySelectorAll('[data-filter-date]').forEach(input => {
            const name = input.dataset.filterDate;
            if (params.has(name)) input.value = params.get(name);
        });

        // Restore number filters
        document.querySelectorAll('[data-filter-number]').forEach(input => {
            const name = input.dataset.filterNumber;
            if (params.has(name)) input.value = params.get(name);
        });

        // Restore checkbox filters
        document.querySelectorAll('[data-filter-group]').forEach(group => {
            const name = group.dataset.filterGroup;
            const values = params.getAll(name);
            group.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                cb.checked = values.includes(cb.value);
            });
        });
    }

    _bindPopState() {
        window.addEventListener('popstate', () => {
            this._loadFromURL();
            this.load();
        });
    }

    // ========================
    // RENDERING
    // ========================

    _renderCards(items) {
        if (!items || items.length === 0) {
            this.container.innerHTML = this.renderEmpty();
            return;
        }
        this.container.innerHTML = items.map(item => this.renderCard(item)).join('');
    }

    _renderPagination() {
        if (!this.paginationContainer) return;
        if (this.totalPages <= 1) {
            this.paginationContainer.innerHTML = '';
            return;
        }

        let html = '<nav aria-label="Pagination"><ul class="pagination-ajax">';

        // Previous
        html += `<li class="${this.currentPage <= 1 ? 'disabled' : ''}">
            <a href="#" data-page="${this.currentPage - 1}" aria-label="Previous">
                <i class="fas fa-chevron-left"></i>
            </a></li>`;

        // Page numbers
        const pages = this._getPageNumbers();
        for (const p of pages) {
            if (p === '...') {
                html += '<li class="ellipsis"><span>...</span></li>';
            } else {
                html += `<li class="${p === this.currentPage ? 'active' : ''}">
                    <a href="#" data-page="${p}">${p}</a></li>`;
            }
        }

        // Next
        html += `<li class="${this.currentPage >= this.totalPages ? 'disabled' : ''}">
            <a href="#" data-page="${this.currentPage + 1}" aria-label="Next">
                <i class="fas fa-chevron-right"></i>
            </a></li>`;

        html += '</ul></nav>';
        this.paginationContainer.innerHTML = html;

        // Bind page clicks
        this.paginationContainer.querySelectorAll('a[data-page]').forEach(a => {
            a.addEventListener('click', (e) => {
                e.preventDefault();
                const page = parseInt(a.dataset.page);
                if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
                    this.currentPage = page;
                    this.load();
                    this.container.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });
    }

    _getPageNumbers() {
        const total = this.totalPages;
        const current = this.currentPage;
        const pages = [];

        if (total <= 7) {
            for (let i = 1; i <= total; i++) pages.push(i);
        } else {
            pages.push(1);
            if (current > 3) pages.push('...');

            const start = Math.max(2, current - 1);
            const end = Math.min(total - 1, current + 1);
            for (let i = start; i <= end; i++) pages.push(i);

            if (current < total - 2) pages.push('...');
            pages.push(total);
        }

        return pages;
    }

    _showSkeleton() {
        let html = '';
        for (let i = 0; i < this.skeletonCount; i++) {
            html += this.skeletonHtml;
        }
        this.container.innerHTML = html;
    }

    _showError(message) {
        this.container.innerHTML = `<div class="col-12">
            <div class="empty-state text-center py-5">
                <i class="fas fa-exclamation-triangle text-warning" style="font-size:2rem"></i>
                <p class="mt-2 text-muted">${message}</p>
            </div></div>`;
    }

    _defaultEmpty() {
        return `<div class="col-12">
            <div class="empty-state text-center py-5">
                <i class="fas fa-calendar-times" style="font-size:3.5rem;color:var(--text-light)"></i>
                <h5 class="mt-3" style="color:var(--text-muted)">Không tìm thấy kết quả</h5>
                <p class="small" style="color:var(--text-light)">Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm</p>
            </div></div>`;
    }

    _defaultSkeleton() {
        return `<div class="col-md-4 col-sm-6 mb-4">
            <div class="skeleton-card">
                <div class="skeleton-img"></div>
                <div class="skeleton-body">
                    <div class="skeleton-line w-75"></div>
                    <div class="skeleton-line w-50"></div>
                    <div class="skeleton-line w-100"></div>
                </div>
            </div></div>`;
    }
}
