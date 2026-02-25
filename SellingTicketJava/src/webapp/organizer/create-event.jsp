<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<style>
/* ======== WIZARD STEPPER ======== */
.wizard-stepper {
    display: flex;
    justify-content: center;
    gap: 0;
    position: relative;
    padding: 0 2rem;
}
.wizard-step {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    cursor: pointer;
    padding: 0.75rem 1.25rem;
    border-radius: 50rem;
    transition: all 0.3s ease;
    position: relative;
    z-index: 1;
    white-space: nowrap;
}
.wizard-step .step-number {
    width: 36px; height: 36px;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-weight: 700; font-size: 0.85rem;
    background: rgba(0,0,0,0.06);
    color: var(--text-muted);
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    flex-shrink: 0;
}
.wizard-step .step-label {
    font-weight: 600; font-size: 0.85rem;
    color: var(--text-muted);
    transition: color 0.3s;
}
.wizard-step.active .step-number {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    box-shadow: 0 4px 15px rgba(147, 51, 234, 0.35);
    transform: scale(1.1);
}
.wizard-step.active .step-label { color: var(--primary); }
.wizard-step.completed .step-number {
    background: #10b981; color: white;
}
.wizard-step.completed .step-label { color: #10b981; }
.wizard-connector {
    flex: 1; height: 3px; min-width: 40px; max-width: 80px;
    background: rgba(0,0,0,0.08);
    border-radius: 3px;
    align-self: center;
    position: relative;
    overflow: hidden;
}
.wizard-connector .connector-fill {
    position: absolute; top: 0; left: 0; height: 100%; width: 0;
    background: linear-gradient(90deg, #10b981, var(--primary));
    border-radius: 3px;
    transition: width 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}
.wizard-connector.filled .connector-fill { width: 100%; }

/* ======== WIZARD PANELS ======== */
.wizard-panel {
    display: none;
    animation: wizardFadeIn 0.4s ease-out;
}
.wizard-panel.active { display: block; }
@keyframes wizardFadeIn {
    from { opacity: 0; transform: translateY(15px); }
    to { opacity: 1; transform: translateY(0); }
}

/* ======== DRAG-DROP ZONE ======== */
.upload-zone {
    border: 2px dashed rgba(147, 51, 234, 0.25);
    border-radius: var(--radius-lg);
    padding: 2.5rem;
    text-align: center;
    cursor: pointer;
    transition: all 0.3s ease;
    background: rgba(147, 51, 234, 0.03);
    position: relative;
    overflow: hidden;
}
.upload-zone:hover, .upload-zone.dragover {
    border-color: var(--primary);
    background: rgba(147, 51, 234, 0.06);
    transform: scale(1.01);
}
.upload-zone .preview-img {
    max-height: 220px; border-radius: var(--radius-md);
    object-fit: cover; width: 100%;
    box-shadow: 0 8px 24px rgba(0,0,0,0.12);
}
.upload-zone .upload-placeholder {
    transition: opacity 0.3s;
}
.upload-zone.has-image .upload-placeholder { display: none; }

/* ======== TICKET CARD ======== */
.ticket-type-card {
    background: rgba(255,255,255,0.7);
    border: 1px solid rgba(0,0,0,0.06);
    border-radius: var(--radius-lg);
    padding: 1.25rem;
    transition: all 0.3s ease;
    position: relative;
    border-left: 4px solid var(--primary);
}
.ticket-type-card:hover {
    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
    transform: translateY(-2px);
}
.ticket-type-card .remove-ticket {
    position: absolute; top: 0.75rem; right: 0.75rem;
    width: 28px; height: 28px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    border: none; background: rgba(239, 68, 68, 0.1);
    color: #ef4444; cursor: pointer;
    transition: all 0.2s;
}
.ticket-type-card .remove-ticket:hover {
    background: #ef4444; color: white;
    transform: scale(1.1);
}

/* ======== REVIEW SECTION ======== */
.review-section {
    background: rgba(255,255,255,0.6);
    border-radius: var(--radius-lg);
    padding: 1.25rem;
    margin-bottom: 1rem;
    border: 1px solid rgba(0,0,0,0.05);
}
.review-section h6 {
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--text-muted);
    margin-bottom: 0.75rem;
}
.review-edit-btn {
    font-size: 0.75rem;
    cursor: pointer;
    color: var(--primary);
    font-weight: 600;
}

/* ======== RUNNING TOTAL ======== */
.running-total {
    position: sticky; bottom: 0;
    background: rgba(255,255,255,0.95);
    backdrop-filter: blur(12px);
    border-top: 1px solid rgba(0,0,0,0.05);
    padding: 1rem 1.25rem;
    border-radius: 0 0 var(--radius-lg) var(--radius-lg);
}

/* ======== TOOLBAR ======== */
.desc-toolbar {
    display: flex; gap: 0.25rem;
    padding: 0.5rem;
    background: rgba(0,0,0,0.03);
    border-radius: var(--radius-sm) var(--radius-sm) 0 0;
    border: 1px solid rgba(0,0,0,0.08);
    border-bottom: none;
}
.desc-toolbar button {
    width: 32px; height: 32px; border: none;
    background: transparent; border-radius: 6px;
    cursor: pointer; color: var(--text-muted);
    display: flex; align-items: center; justify-content: center;
    transition: all 0.2s;
}
.desc-toolbar button:hover {
    background: rgba(147, 51, 234, 0.1); color: var(--primary);
}
.desc-editor {
    border: 1px solid rgba(0,0,0,0.08);
    border-radius: 0 0 var(--radius-sm) var(--radius-sm);
    min-height: 150px; padding: 1rem;
    background: white;
    outline: none;
    font-size: 0.9rem;
    line-height: 1.6;
}
.desc-editor:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(147, 51, 234, 0.1);
}

/* ======== VALIDATION ======== */
.field-error { border-color: #ef4444 !important; }
.field-error-msg {
    color: #ef4444; font-size: 0.75rem;
    margin-top: 0.25rem; display: none;
}
.field-error + .field-error-msg { display: block; }
</style>

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="create-event"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="mb-4 animate-fadeInDown">
                <h2 class="fw-bold mb-1">Tạo sự kiện mới</h2>
                <p class="text-muted mb-0">Hoàn thành các bước bên dưới để tạo sự kiện của bạn</p>
            </div>

            <!-- ========== STEPPER ========== -->
            <div class="card glass-strong border-0 rounded-4 mb-4 p-3 animate-fadeInDown">
                <div class="wizard-stepper">
                    <div class="wizard-step active" data-step="1" onclick="goToStep(1)">
                        <span class="step-number">1</span>
                        <span class="step-label d-none d-md-inline">Thông tin</span>
                    </div>
                    <div class="wizard-connector"><div class="connector-fill"></div></div>
                    <div class="wizard-step" data-step="2" onclick="goToStep(2)">
                        <span class="step-number">2</span>
                        <span class="step-label d-none d-md-inline">Thời gian & Địa điểm</span>
                    </div>
                    <div class="wizard-connector"><div class="connector-fill"></div></div>
                    <div class="wizard-step" data-step="3" onclick="goToStep(3)">
                        <span class="step-number">3</span>
                        <span class="step-label d-none d-md-inline">Vé & Giá</span>
                    </div>
                    <div class="wizard-connector"><div class="connector-fill"></div></div>
                    <div class="wizard-step" data-step="4" onclick="goToStep(4)">
                        <span class="step-number">4</span>
                        <span class="step-label d-none d-md-inline">Xem lại</span>
                    </div>
                </div>
            </div>

            <!-- ========== FORM ========== -->
            <form id="createEventForm" action="${pageContext.request.contextPath}/organizer/create-event" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="csrf_token" value="${csrf_token}"/>

                <!-- ====== STEP 1: Basic Info ====== -->
                <div class="wizard-panel active" data-panel="1">
                    <div class="row g-4">
                        <div class="col-lg-7">
                            <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible">
                                <div class="card-body p-4">
                                    <h5 class="fw-bold mb-4"><i class="fas fa-info-circle text-primary me-2"></i>Thông tin cơ bản</h5>
                                    <div class="mb-3">
                                        <label class="form-label fw-medium">Tên sự kiện <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control form-control-lg" name="title" id="eventTitle"
                                               placeholder="VD: Đêm nhạc Acoustic tháng 3" required maxlength="200">
                                        <div class="d-flex justify-content-between mt-1">
                                            <span class="field-error-msg">Vui lòng nhập tên sự kiện</span>
                                            <small class="text-muted"><span id="titleCount">0</span>/200</small>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label fw-medium">Danh mục <span class="text-danger">*</span></label>
                                        <select class="form-select" name="category" id="eventCategory" required>
                                            <option value="">Chọn danh mục</option>
                                            <c:forEach var="c" items="${categories}">
                                                <option value="${c.categoryId}">${c.name}</option>
                                            </c:forEach>
                                        </select>
                                        <span class="field-error-msg">Vui lòng chọn danh mục</span>
                                    </div>
                                    <div class="mb-0">
                                        <label class="form-label fw-medium">Mô tả sự kiện <span class="text-danger">*</span></label>
                                        <div class="desc-toolbar">
                                            <button type="button" onclick="execCmd('bold')" title="In đậm"><i class="fas fa-bold"></i></button>
                                            <button type="button" onclick="execCmd('italic')" title="In nghiêng"><i class="fas fa-italic"></i></button>
                                            <button type="button" onclick="execCmd('insertUnorderedList')" title="Danh sách"><i class="fas fa-list-ul"></i></button>
                                            <button type="button" onclick="execCmd('insertOrderedList')" title="Danh sách số"><i class="fas fa-list-ol"></i></button>
                                        </div>
                                        <div class="desc-editor" contenteditable="true" id="descEditor" data-placeholder="Mô tả chi tiết về sự kiện, chương trình, nghệ sĩ..."></div>
                                        <textarea name="description" id="descHidden" class="d-none" required></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-5">
                            <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible stagger-1">
                                <div class="card-body p-4">
                                    <h5 class="fw-bold mb-4"><i class="fas fa-image text-primary me-2"></i>Ảnh bìa</h5>
                                    <div class="upload-zone" id="uploadZone" onclick="document.getElementById('bannerInput').click()">
                                        <div class="upload-placeholder">
                                            <div class="mb-3">
                                                <i class="fas fa-cloud-upload-alt fa-3x" style="color: var(--primary); opacity: 0.5;"></i>
                                            </div>
                                            <p class="fw-medium mb-1">Kéo thả hoặc nhấn để chọn ảnh</p>
                                            <small class="text-muted">PNG, JPG, WEBP — Tối đa 5MB</small>
                                        </div>
                                        <img id="bannerPreview" class="preview-img d-none" alt="Preview">
                                    </div>
                                    <input type="file" class="d-none" name="banner" id="bannerInput" accept="image/*">
                                    <button type="button" id="removeBanner" class="btn btn-sm btn-outline-danger rounded-pill mt-3 d-none" onclick="removeBannerImage()">
                                        <i class="fas fa-trash me-1"></i>Xóa ảnh
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex justify-content-end mt-4">
                        <button type="button" class="btn btn-gradient rounded-pill px-4 py-2" onclick="nextStep()">
                            Tiếp theo <i class="fas fa-arrow-right ms-2"></i>
                        </button>
                    </div>
                </div>

                <!-- ====== STEP 2: Date & Location ====== -->
                <div class="wizard-panel" data-panel="2">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4"><i class="fas fa-calendar-alt text-primary me-2"></i>Thời gian & Địa điểm</h5>
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Ngày bắt đầu <span class="text-danger">*</span></label>
                                    <input type="datetime-local" class="form-control form-control-lg" name="startDate" id="startDate" required>
                                    <span class="field-error-msg">Vui lòng chọn ngày bắt đầu</span>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Ngày kết thúc</label>
                                    <input type="datetime-local" class="form-control form-control-lg" name="endDate" id="endDate">
                                    <span class="field-error-msg" id="endDateError">Ngày kết thúc phải sau ngày bắt đầu</span>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Địa điểm <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-lg" name="location" id="eventLocation"
                                           placeholder="VD: Nhà hát Thành phố" required>
                                    <span class="field-error-msg">Vui lòng nhập địa điểm</span>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Địa chỉ chi tiết</label>
                                    <input type="text" class="form-control form-control-lg" name="address" id="eventAddress"
                                           placeholder="Số nhà, đường, quận...">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between mt-4">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4 py-2" onclick="prevStep()">
                            <i class="fas fa-arrow-left me-2"></i>Quay lại
                        </button>
                        <button type="button" class="btn btn-gradient rounded-pill px-4 py-2" onclick="nextStep()">
                            Tiếp theo <i class="fas fa-arrow-right ms-2"></i>
                        </button>
                    </div>
                </div>

                <!-- ====== STEP 3: Tickets ====== -->
                <div class="wizard-panel" data-panel="3">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible">
                        <div class="card-body p-4 pb-0">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h5 class="fw-bold mb-0"><i class="fas fa-ticket-alt text-primary me-2"></i>Loại vé</h5>
                                <button type="button" class="btn btn-sm btn-outline-primary rounded-pill px-3" onclick="addTicketType()">
                                    <i class="fas fa-plus me-1"></i>Thêm loại vé
                                </button>
                            </div>
                            <div id="ticketTypes">
                                <!-- Default ticket type -->
                                <div class="ticket-type-card mb-3" data-ticket-index="0">
                                    <button type="button" class="remove-ticket d-none" onclick="removeTicketType(this)" title="Xóa"><i class="fas fa-times"></i></button>
                                    <div class="row g-3">
                                        <div class="col-md-5">
                                            <label class="form-label small fw-medium">Tên loại vé</label>
                                            <input type="text" class="form-control" name="ticketName[]" placeholder="VD: Vé VIP" required>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small fw-medium">Giá (VNĐ)</label>
                                            <input type="number" class="form-control ticket-price" name="ticketPrice[]" placeholder="500000" min="0" required oninput="updateTotal()">
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label small fw-medium">Số lượng</label>
                                            <input type="number" class="form-control ticket-qty" name="ticketQuantity[]" placeholder="100" min="1" required oninput="updateTotal()">
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label small fw-medium">Mô tả ngắn</label>
                                            <input type="text" class="form-control" name="ticketDesc[]" placeholder="Khu vực A">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Running total -->
                            <div class="running-total d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="text-muted small">Tổng vé:</span>
                                    <strong id="totalTickets" class="ms-1">0</strong>
                                </div>
                                <div>
                                    <span class="text-muted small">Doanh thu dự kiến:</span>
                                    <strong id="totalRevenue" class="ms-1 text-success">0 đ</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between mt-4">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4 py-2" onclick="prevStep()">
                            <i class="fas fa-arrow-left me-2"></i>Quay lại
                        </button>
                        <button type="button" class="btn btn-gradient rounded-pill px-4 py-2" onclick="nextStep()">
                            Xem lại <i class="fas fa-arrow-right ms-2"></i>
                        </button>
                    </div>
                </div>

                <!-- ====== STEP 4: Review ====== -->
                <div class="wizard-panel" data-panel="4">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4"><i class="fas fa-check-double text-primary me-2"></i>Xem lại thông tin</h5>

                            <!-- Event Info Review -->
                            <div class="review-section">
                                <div class="d-flex justify-content-between align-items-center">
                                    <h6 class="mb-0">Thông tin sự kiện</h6>
                                    <span class="review-edit-btn" onclick="goToStep(1)"><i class="fas fa-pen me-1"></i>Sửa</span>
                                </div>
                                <div class="row mt-2">
                                    <div class="col-md-8">
                                        <p class="mb-1"><strong id="reviewTitle">—</strong></p>
                                        <p class="text-muted small mb-0" id="reviewCategory">—</p>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <img id="reviewBanner" class="rounded-3 d-none" style="max-height: 80px; object-fit: cover;" alt="Banner">
                                    </div>
                                </div>
                            </div>

                            <!-- Date & Location Review -->
                            <div class="review-section">
                                <div class="d-flex justify-content-between align-items-center">
                                    <h6 class="mb-0">Thời gian & Địa điểm</h6>
                                    <span class="review-edit-btn" onclick="goToStep(2)"><i class="fas fa-pen me-1"></i>Sửa</span>
                                </div>
                                <div class="row mt-2">
                                    <div class="col-md-6">
                                        <small class="text-muted">Bắt đầu</small>
                                        <p class="fw-medium mb-0" id="reviewStart">—</p>
                                    </div>
                                    <div class="col-md-6">
                                        <small class="text-muted">Địa điểm</small>
                                        <p class="fw-medium mb-0" id="reviewLocation">—</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Tickets Review -->
                            <div class="review-section">
                                <div class="d-flex justify-content-between align-items-center">
                                    <h6 class="mb-0">Loại vé</h6>
                                    <span class="review-edit-btn" onclick="goToStep(3)"><i class="fas fa-pen me-1"></i>Sửa</span>
                                </div>
                                <div class="table-responsive mt-2">
                                    <table class="table table-sm table-borderless mb-0">
                                        <thead><tr>
                                            <th class="text-muted small">Loại vé</th>
                                            <th class="text-muted small text-end">Giá</th>
                                            <th class="text-muted small text-end">SL</th>
                                            <th class="text-muted small text-end">Tổng</th>
                                        </tr></thead>
                                        <tbody id="reviewTickets"></tbody>
                                        <tfoot>
                                            <tr class="border-top">
                                                <td colspan="2" class="fw-bold">Tổng cộng</td>
                                                <td class="text-end fw-bold" id="reviewTotalQty">0</td>
                                                <td class="text-end fw-bold text-success" id="reviewTotalRev">0 đ</td>
                                            </tr>
                                        </tfoot>
                                    </table>
                                </div>
                            </div>

                            <!-- Publish Options -->
                            <div class="review-section">
                                <h6>Xuất bản</h6>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-medium">Trạng thái</label>
                                        <select class="form-select" name="status">
                                            <option value="draft">Bản nháp — Lưu lại để chỉnh sửa</option>
                                            <option value="pending">Gửi duyệt — Chờ Admin phê duyệt</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6 d-flex align-items-end">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" name="isPrivate" id="isPrivate">
                                            <label class="form-check-label small" for="isPrivate">Sự kiện riêng tư (chỉ truy cập qua link)</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between mt-4">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4 py-2" onclick="prevStep()">
                            <i class="fas fa-arrow-left me-2"></i>Quay lại
                        </button>
                        <button type="submit" class="btn btn-gradient btn-lg rounded-pill px-5 py-2 hover-glow" id="submitBtn">
                            <i class="fas fa-rocket me-2"></i>Tạo sự kiện
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// ========== WIZARD NAVIGATION ==========
let currentStep = 1;
const totalSteps = 4;

function goToStep(step) {
    if (step > currentStep && !validateCurrentStep()) return;
    if (step < 1 || step > totalSteps) return;

    // Update panels
    document.querySelectorAll('.wizard-panel').forEach(p => p.classList.remove('active'));
    document.querySelector(`[data-panel="${step}"]`).classList.add('active');

    // Update stepper
    document.querySelectorAll('.wizard-step').forEach(s => {
        const sNum = parseInt(s.dataset.step);
        s.classList.remove('active', 'completed');
        if (sNum === step) s.classList.add('active');
        else if (sNum < step) s.classList.add('completed');
    });

    // Update connectors
    document.querySelectorAll('.wizard-connector').forEach((c, i) => {
        c.classList.toggle('filled', i < step - 1);
    });

    currentStep = step;

    // Populate review on step 4
    if (step === 4) populateReview();
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function nextStep() { goToStep(currentStep + 1); }
function prevStep() { goToStep(currentStep - 1); }

// ========== VALIDATION ==========
function validateCurrentStep() {
    let valid = true;
    const panel = document.querySelector(`[data-panel="${currentStep}"]`);

    // Clear previous errors
    panel.querySelectorAll('.field-error').forEach(el => el.classList.remove('field-error'));

    if (currentStep === 1) {
        const title = document.getElementById('eventTitle');
        const cat = document.getElementById('eventCategory');
        if (!title.value.trim()) { title.classList.add('field-error'); valid = false; }
        if (!cat.value) { cat.classList.add('field-error'); valid = false; }
        // Sync description
        document.getElementById('descHidden').value = document.getElementById('descEditor').innerHTML;
    }

    if (currentStep === 2) {
        const start = document.getElementById('startDate');
        const end = document.getElementById('endDate');
        const loc = document.getElementById('eventLocation');
        if (!start.value) { start.classList.add('field-error'); valid = false; }
        if (!loc.value.trim()) { loc.classList.add('field-error'); valid = false; }
        if (end.value && start.value && new Date(end.value) <= new Date(start.value)) {
            end.classList.add('field-error');
            document.getElementById('endDateError').style.display = 'block';
            valid = false;
        }
    }

    if (currentStep === 3) {
        const cards = document.querySelectorAll('.ticket-type-card');
        if (cards.length === 0) {
            showToast('Vui lòng thêm ít nhất 1 loại vé', 'error');
            valid = false;
        }
        cards.forEach(card => {
            card.querySelectorAll('input[required]').forEach(inp => {
                if (!inp.value.trim()) { inp.classList.add('field-error'); valid = false; }
            });
        });
    }

    if (!valid) showToast('Vui lòng kiểm tra lại thông tin', 'error');
    return valid;
}

// ========== IMAGE UPLOAD ==========
const uploadZone = document.getElementById('uploadZone');
const bannerInput = document.getElementById('bannerInput');
const bannerPreview = document.getElementById('bannerPreview');

['dragenter', 'dragover'].forEach(evt => {
    uploadZone.addEventListener(evt, e => { e.preventDefault(); uploadZone.classList.add('dragover'); });
});
['dragleave', 'drop'].forEach(evt => {
    uploadZone.addEventListener(evt, e => { e.preventDefault(); uploadZone.classList.remove('dragover'); });
});
uploadZone.addEventListener('drop', e => {
    const file = e.dataTransfer.files[0];
    if (file && file.type.startsWith('image/')) {
        const dt = new DataTransfer();
        dt.items.add(file);
        bannerInput.files = dt.files;
        previewImage(file);
    }
});

bannerInput.addEventListener('change', e => {
    if (e.target.files[0]) previewImage(e.target.files[0]);
});

function previewImage(file) {
    if (file.size > 5 * 1024 * 1024) {
        showToast('Ảnh tối đa 5MB', 'error');
        return;
    }
    const reader = new FileReader();
    reader.onload = e => {
        bannerPreview.src = e.target.result;
        bannerPreview.classList.remove('d-none');
        uploadZone.classList.add('has-image');
        document.getElementById('removeBanner').classList.remove('d-none');
    };
    reader.readAsDataURL(file);
}

function removeBannerImage() {
    bannerInput.value = '';
    bannerPreview.classList.add('d-none');
    uploadZone.classList.remove('has-image');
    document.getElementById('removeBanner').classList.add('d-none');
}

// ========== RICH EDITOR ==========
function execCmd(cmd) {
    document.execCommand(cmd, false, null);
    document.getElementById('descEditor').focus();
}

// ========== TITLE COUNTER ==========
document.getElementById('eventTitle').addEventListener('input', function() {
    document.getElementById('titleCount').textContent = this.value.length;
});

// ========== TICKET TYPES ==========
let ticketIndex = 1;

function addTicketType() {
    const container = document.getElementById('ticketTypes');
    const card = document.createElement('div');
    card.className = 'ticket-type-card mb-3';
    card.dataset.ticketIndex = ticketIndex++;
    card.style.animation = 'wizardFadeIn 0.3s ease-out';
    card.innerHTML = `
        <button type="button" class="remove-ticket" onclick="removeTicketType(this)" title="Xóa"><i class="fas fa-times"></i></button>
        <div class="row g-3">
            <div class="col-md-5">
                <label class="form-label small fw-medium">Tên loại vé</label>
                <input type="text" class="form-control" name="ticketName[]" placeholder="VD: Vé thường" required>
            </div>
            <div class="col-md-3">
                <label class="form-label small fw-medium">Giá (VNĐ)</label>
                <input type="number" class="form-control ticket-price" name="ticketPrice[]" placeholder="300000" min="0" required oninput="updateTotal()">
            </div>
            <div class="col-md-2">
                <label class="form-label small fw-medium">Số lượng</label>
                <input type="number" class="form-control ticket-qty" name="ticketQuantity[]" placeholder="200" min="1" required oninput="updateTotal()">
            </div>
            <div class="col-md-2">
                <label class="form-label small fw-medium">Mô tả ngắn</label>
                <input type="text" class="form-control" name="ticketDesc[]" placeholder="Khu vực B">
            </div>
        </div>
    `;
    container.appendChild(card);
    // Show remove buttons if more than 1 ticket type
    updateRemoveButtons();
}

function removeTicketType(btn) {
    const card = btn.closest('.ticket-type-card');
    card.style.animation = 'wizardFadeIn 0.3s ease-out reverse';
    setTimeout(() => {
        card.remove();
        updateRemoveButtons();
        updateTotal();
    }, 250);
}

function updateRemoveButtons() {
    const cards = document.querySelectorAll('.ticket-type-card');
    cards.forEach(c => {
        const btn = c.querySelector('.remove-ticket');
        btn.classList.toggle('d-none', cards.length <= 1);
    });
}

function updateTotal() {
    let totalQty = 0, totalRev = 0;
    document.querySelectorAll('.ticket-type-card').forEach(card => {
        const price = parseInt(card.querySelector('.ticket-price')?.value) || 0;
        const qty = parseInt(card.querySelector('.ticket-qty')?.value) || 0;
        totalQty += qty;
        totalRev += price * qty;
    });
    document.getElementById('totalTickets').textContent = totalQty.toLocaleString('vi-VN');
    document.getElementById('totalRevenue').textContent = totalRev.toLocaleString('vi-VN') + ' đ';
}

// ========== REVIEW POPULATION ==========
function populateReview() {
    // Info
    document.getElementById('reviewTitle').textContent = document.getElementById('eventTitle').value || '—';
    const catSelect = document.getElementById('eventCategory');
    document.getElementById('reviewCategory').textContent = catSelect.options[catSelect.selectedIndex]?.text || '—';

    // Banner
    const banner = document.getElementById('reviewBanner');
    if (bannerPreview.src && !bannerPreview.classList.contains('d-none')) {
        banner.src = bannerPreview.src;
        banner.classList.remove('d-none');
    } else {
        banner.classList.add('d-none');
    }

    // Date & Location
    const startVal = document.getElementById('startDate').value;
    document.getElementById('reviewStart').textContent = startVal ? new Date(startVal).toLocaleString('vi-VN') : '—';
    document.getElementById('reviewLocation').textContent = document.getElementById('eventLocation').value || '—';

    // Tickets
    const tbody = document.getElementById('reviewTickets');
    tbody.innerHTML = '';
    let tQty = 0, tRev = 0;
    document.querySelectorAll('.ticket-type-card').forEach(card => {
        const name = card.querySelector('[name="ticketName[]"]').value || '—';
        const price = parseInt(card.querySelector('.ticket-price').value) || 0;
        const qty = parseInt(card.querySelector('.ticket-qty').value) || 0;
        const sub = price * qty;
        tQty += qty; tRev += sub;
        tbody.innerHTML += `<tr>
            <td>${name}</td>
            <td class="text-end">${price.toLocaleString('vi-VN')} đ</td>
            <td class="text-end">${qty.toLocaleString('vi-VN')}</td>
            <td class="text-end">${sub.toLocaleString('vi-VN')} đ</td>
        </tr>`;
    });
    document.getElementById('reviewTotalQty').textContent = tQty.toLocaleString('vi-VN');
    document.getElementById('reviewTotalRev').textContent = tRev.toLocaleString('vi-VN') + ' đ';
}

// ========== FORM SUBMIT ==========
document.getElementById('createEventForm').addEventListener('submit', function(e) {
    document.getElementById('descHidden').value = document.getElementById('descEditor').innerHTML;
    const btn = document.getElementById('submitBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Đang tạo...';
});

// ========== TOAST HELPER ==========
function showToast(msg, type) {
    const toast = document.getElementById('globalToast');
    if (!toast) return;
    const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
    const bg = type === 'success' ? 'bg-success' : 'bg-danger';
    toast.className = 'toast align-items-center text-white border-0 rounded-4 shadow-lg ' + bg;
    document.getElementById('toastIcon').className = 'fas ' + icon;
    document.getElementById('toastText').textContent = msg;
    new bootstrap.Toast(toast).show();
}
</script>

<jsp:include page="../footer.jsp" />
