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
        this.externalPageSizeSelector = config.pageSizeSelector ? document.querySelector(config.pageSizeSelector) : null;
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
        
        // Bind external page size selector if any
        if (this.externalPageSizeSelector) {
            this.externalPageSizeSelector.addEventListener('change', (e) => {
                const newSize = parseInt(e.target.value);
                if (newSize && newSize !== this.pageSize) {
                    this.pageSize = newSize;
                    this.currentPage = 1;
                    this.load();
                }
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
        if (params.has('size')) {
            this.pageSize = Math.max(1, Math.min(200, parseInt(params.get('size')) || 20));
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
        if (this.totalPages <= 0) {
            this.paginationContainer.innerHTML = '';
            return;
        }

        let html = '<div class="d-flex flex-column flex-md-row justify-content-between align-items-center">';
        
        // Items Display Info
        const startRow = (this.currentPage - 1) * this.pageSize + 1;
        const endRow = Math.min(this.currentPage * this.pageSize, this.totalItems);
        html += `<div class="text-muted small mb-3 mb-md-0">Hiển thị <b class="text-dark">${startRow} - ${endRow}</b> trong tổng số <b class="text-dark">${this.totalItems}</b> kết quả</div>`;

        html += '<div class="d-flex align-items-center gap-3">';
        
        // Page Size Selector (Optional inline)
        html += '<div class="d-flex align-items-center gap-2">';
        html += '<span class="text-muted small">Cỡ trang:</span>';
        html += '<select class="form-select form-select-sm glass border-0 rounded-3 text-center fw-bold ajax-page-size-select" style="width: 70px; cursor: pointer;">';
        [10, 20, 50, 100, 200].forEach(size => {
            let selected = (parseInt(size) === parseInt(this.pageSize)) ? 'selected' : '';
            html += `<option value="${size}" ${selected}>${size}</option>`;
        });
        html += '</select></div>';

        // Pagination Controls
        html += '<nav aria-label="Page navigation"><ul class="pagination mb-0 shadow-sm rounded-3 overflow-hidden">';
        
        // First & Prev
        html += `<li class="page-item ${this.currentPage <= 1 ? 'disabled' : ''}"><a class="page-link glass px-3 border-0 py-2" href="#" data-page="1" title="Trang đầu"><i class="fas fa-angle-double-left"></i></a></li>`;
        html += `<li class="page-item ${this.currentPage <= 1 ? 'disabled' : ''}"><a class="page-link glass px-3 border-0 py-2" href="#" data-page="${this.currentPage - 1}" title="Trang trước"><i class="fas fa-chevron-left"></i></a></li>`;

        const pages = this._getPageNumbers();
        for (const p of pages) {
            if (p === '...') {
                html += '<li class="page-item disabled"><span class="page-link glass px-3 border-0 py-2 text-muted">...</span></li>';
            } else {
                if (parseInt(p) === parseInt(this.currentPage)) {
                    html += `<li class="page-item active" style="z-index: 1;"><a class="page-link fw-bold border-0 py-2 px-3 shadow" href="#" style="background: linear-gradient(135deg, var(--primary), var(--secondary)); color: white;">${p}</a></li>`;
                } else {
                    html += `<li class="page-item"><a class="page-link glass px-3 border-0 py-2 fw-medium text-dark hover-primary" href="#" data-page="${p}">${p}</a></li>`;
                }
            }
        }

        // Next & Last
        html += `<li class="page-item ${this.currentPage >= this.totalPages ? 'disabled' : ''}"><a class="page-link glass px-3 border-0 py-2" href="#" data-page="${this.currentPage + 1}" title="Trang sau"><i class="fas fa-chevron-right"></i></a></li>`;
        html += `<li class="page-item ${this.currentPage >= this.totalPages ? 'disabled' : ''}"><a class="page-link glass px-3 border-0 py-2" href="#" data-page="${this.totalPages}" title="Trang cuối"><i class="fas fa-angle-double-right"></i></a></li>`;
        html += '</ul></nav>';
        html += '</div></div>';

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
                    const tableContainer = this.tableBody.closest('.card, .container, .container-fluid');
                    if (tableContainer) {
                        tableContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                }
            });
        });

        // Bind page size select in pagination container
        const sizeSelect = this.paginationContainer.querySelector('.ajax-page-size-select');
        if (sizeSelect) {
            sizeSelect.addEventListener('change', (e) => {
                const newSize = parseInt(e.target.value);
                if (newSize && newSize !== this.pageSize) {
                    this.pageSize = newSize;
                    if (this.externalPageSizeSelector) this.externalPageSizeSelector.value = newSize;
                    this.currentPage = 1; // Reset to page 1 on size change
                    this.load();
                }
            });
        }
        
        // Sync external page size selector if it exists
        if (this.externalPageSizeSelector) {
            this.externalPageSizeSelector.value = this.pageSize;
        }
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
