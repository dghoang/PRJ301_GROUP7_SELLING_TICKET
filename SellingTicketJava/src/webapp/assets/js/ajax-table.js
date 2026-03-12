/**
 * AjaxTable — Reusable AJAX-powered data table with search, filter, pagination.
 * Used for admin pages (users, orders, events management tables).
 * 
 * Features:
 * - Debounced search (300ms)
 * - Multi-select checkbox filters
 * - Dropdown filters
 * - Date range filters
 * - Server-side pagination with page controls
 * - URL state sync (History API)
 * - Loading skeleton animation
 * - Empty state display
 * 
 * Usage:
 *   const table = new AjaxTable({
 *       apiUrl: '/api/admin/users',
 *       tableBody: '#table-body',
 *       paginationContainer: '#pagination',
 *       searchInput: '#search-input',
 *       renderRow: (item) => '<tr>...</tr>',
 *       filters: { status: 'checkbox', role: 'checkbox', isActive: 'select' },
 *       pageSize: 20
 *   });
 *   table.init();
 */
class AjaxTable {
    constructor(config) {
        this.apiUrl = config.apiUrl;
        this.tableBody = document.querySelector(config.tableBody);
        this.paginationContainer = document.querySelector(config.paginationContainer);
        this.searchInput = document.querySelector(config.searchInput);
        this.renderRow = config.renderRow;
        this.renderEmpty = config.renderEmpty || this._defaultEmpty;
        this.onDataLoaded = config.onDataLoaded || null;
        this.pageSize = config.pageSize || 20;
        this.currentPage = 1;
        this.totalPages = 0;
        this.totalItems = 0;
        this.debounceDelay = config.debounceDelay || 500;
        this.debounceTimer = null;
        this.isLoading = false;
        this.filters = {};
        this.skeletonRows = config.skeletonRows || 5;
        this.skeletonCols = config.skeletonCols || 6;
        this.totalItemsEl = config.totalItemsEl ? document.querySelector(config.totalItemsEl) : null;
    }

    init() {
        this._loadFromURL();
        this._bindSearch();
        this._bindFilters();
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
                    this._renderData(data.items);
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
                console.error('AjaxTable fetch error:', err);
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
            }, this.debounceDelay);
        });

        // Also handle clear button
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
    // FILTERS
    // ========================

    _bindFilters() {
        // Checkbox filters: [data-filter="status"]
        document.querySelectorAll('[data-filter-group]').forEach(group => {
            group.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                cb.addEventListener('change', () => {
                    this.currentPage = 1;
                    this.load();
                });
            });
        });

        // Select dropdown filters: [data-filter-select]
        document.querySelectorAll('[data-filter-select]').forEach(select => {
            select.addEventListener('change', () => {
                this.currentPage = 1;
                this.load();
            });
        });

        // Date range inputs
        document.querySelectorAll('[data-filter-date]').forEach(input => {
            input.addEventListener('change', () => {
                this.currentPage = 1;
                this.load();
            });
        });
    }

    _getFilterValues() {
        const filters = {};

        // Checkbox groups
        document.querySelectorAll('[data-filter-group]').forEach(group => {
            const name = group.dataset.filterGroup;
            const checked = [];
            group.querySelectorAll('input[type="checkbox"]:checked').forEach(cb => {
                checked.push(cb.value);
            });
            if (checked.length > 0) filters[name] = checked;
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

        // Restore checkbox filters
        document.querySelectorAll('[data-filter-group]').forEach(group => {
            const name = group.dataset.filterGroup;
            const values = params.getAll(name);
            group.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                cb.checked = values.includes(cb.value);
            });
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

    _renderData(items) {
        if (!items || items.length === 0) {
            this.tableBody.innerHTML = this.renderEmpty();
            return;
        }
        this.tableBody.innerHTML = items.map(item => this.renderRow(item)).join('');
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

        // Page numbers with ellipsis
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
                    // Scroll to top of table
                    this.tableBody.scrollIntoView({ behavior: 'smooth', block: 'start' });
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
        for (let i = 0; i < this.skeletonRows; i++) {
            html += '<tr class="skeleton-row">';
            for (let j = 0; j < this.skeletonCols; j++) {
                html += '<td><div class="skeleton-cell"></div></td>';
            }
            html += '</tr>';
        }
        this.tableBody.innerHTML = html;
    }

    _showError(message) {
        this.tableBody.innerHTML = `<tr><td colspan="${this.skeletonCols}" class="text-center py-4">
            <div class="empty-state">
                <i class="fas fa-exclamation-triangle text-warning" style="font-size:2rem"></i>
                <p class="mt-2 text-muted">${message}</p>
            </div></td></tr>`;
    }

    _defaultEmpty() {
        return `<tr><td colspan="100%" class="text-center py-5">
            <div class="empty-state">
                <i class="fas fa-inbox" style="font-size:3rem;color:var(--text-light)"></i>
                <p class="mt-3" style="color:var(--text-muted)">Không tìm thấy kết quả</p>
                <p class="small" style="color:var(--text-light)">Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm</p>
            </div></td></tr>`;
    }
}
