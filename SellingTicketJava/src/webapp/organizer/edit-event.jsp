<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="tags" tagdir="/WEB-INF/tags" %>

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

/* ======== CUSTOM RICH TEXT EDITOR ======== */
.desc-toolbar {
    display: flex; gap: 0.25rem; flex-wrap: wrap;
    padding: 0.5rem;
    background: rgba(0,0,0,0.02);
    border-radius: var(--radius-sm) var(--radius-sm) 0 0;
    border: 1px solid rgba(0,0,0,0.08);
    border-bottom: none;
    align-items: center;
}
.desc-toolbar button {
    width: 30px; height: 30px; border: none;
    background: transparent; border-radius: 6px;
    cursor: pointer; color: var(--text-muted);
    display: flex; align-items: center; justify-content: center;
    transition: all 0.2s;
}
.desc-toolbar button:hover {
    background: rgba(147, 51, 234, 0.1); color: var(--primary);
}
.desc-toolbar button.active {
    background: rgba(147, 51, 234, 0.15); color: var(--primary);
}
.desc-toolbar select {
    background-color: transparent;
    border: none;
    color: var(--text-muted);
    font-size: 0.85rem;
    cursor: pointer;
    outline: none;
    box-shadow: none;
}
.desc-toolbar select:focus { box-shadow: none; border-color: transparent; }
.desc-toolbar input[type="color"] {
    width: 24px; height: 24px; padding: 0; border: none; cursor: pointer;
    background: transparent; border-radius: 4px; border: 1px solid rgba(0,0,0,0.1);
}
.desc-toolbar .separator {
    width: 1px; background: rgba(0,0,0,0.1);
    margin: 0 4px; height: 20px; align-self: center;
}
.desc-editor {
    border: 1px solid rgba(0,0,0,0.08);
    border-radius: 0 0 var(--radius-sm) var(--radius-sm);
    min-height: 300px; padding: 1.25rem;
    background: white;
    outline: none;
    font-size: 1rem;
    line-height: 1.6;
    overflow-y: auto;
    max-height: 600px;
}
.desc-editor:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(147, 51, 234, 0.1);
}
.desc-editor img {
    max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0; box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}
.desc-editor video {
    max-width: 100%; border-radius: 8px; margin: 10px 0; box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

/* ======== VALIDATION ======== */
.field-error { border-color: #ef4444 !important; }
.field-error-msg {
    color: #ef4444; font-size: 0.75rem;
    margin-top: 0.25rem; display: none;
}
.field-error + .field-error-msg { display: block; }

/* ======== CURRENT BANNER ======== */
.current-banner-preview {
    border-radius: var(--radius-md);
    max-height: 180px;
    width: 100%;
    object-fit: cover;
    box-shadow: 0 4px 16px rgba(0,0,0,0.1);
    margin-bottom: 1rem;
}
</style>

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="events"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="mb-4 animate-fadeInDown">
                <div class="d-flex align-items-center gap-3 mb-1">
                    <a href="${pageContext.request.contextPath}/organizer/events" class="btn btn-sm glass rounded-pill px-3">
                        <i class="fas fa-arrow-left me-1"></i>Quay lại
                    </a>
                    <h2 class="fw-bold mb-0">Chỉnh sửa sự kiện</h2>
                </div>
                <p class="text-muted mb-0 mt-2">Cập nhật thông tin sự kiện <strong>${event.title}</strong></p>
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
                        <span class="step-label d-none d-md-inline">Xem lại</span>
                    </div>
                </div>
            </div>

            <!-- ========== FORM ========== -->
            <form id="editEventForm" action="${pageContext.request.contextPath}/organizer/events/${event.eventId}/edit" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                <input type="hidden" name="eventId" value="${event.eventId}"/>

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
                                               placeholder="VD: Đêm nhạc Acoustic tháng 3" required maxlength="200"
                                               value="${event.title}">
                                        <div class="d-flex justify-content-between mt-1">
                                            <span class="field-error-msg">Vui lòng nhập tên sự kiện</span>
                                            <small class="text-muted"><span id="titleCount">0</span>/200</small>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label fw-medium">Danh mục <span class="text-danger">*</span></label>
                                        <select class="form-select" name="categoryId" id="eventCategory" required>
                                            <option value="">Chọn danh mục</option>
                                            <c:forEach var="c" items="${categories}">
                                                <option value="${c.categoryId}" ${c.categoryId == event.categoryId ? 'selected' : ''}>${c.name}</option>
                                            </c:forEach>
                                        </select>
                                        <span class="field-error-msg">Vui lòng chọn danh mục</span>
                                    </div>
                                    <div class="mb-0">
                                        <label class="form-label fw-medium">Mô tả sự kiện <span class="text-danger">*</span></label>
                                        <div class="desc-toolbar">
                                            <button type="button" onclick="formatDoc('undo')" title="Undo"><i class="fas fa-undo"></i></button>
                                            <button type="button" onclick="formatDoc('redo')" title="Redo"><i class="fas fa-redo"></i></button>
                                            <div class="separator"></div>
                                            <select class="form-select form-select-sm" style="width:auto;" onchange="formatDoc('fontName', this.value); this.selectedIndex=0;" title="Phông chữ">
                                                <option value="" hidden>Phông chữ</option>
                                                <option value="Arial">Arial</option>
                                                <option value="Times New Roman">Times New</option>
                                                <option value="Courier New">Courier</option>
                                                <option value="Verdana">Verdana</option>
                                                <option value="Georgia">Georgia</option>
                                            </select>
                                            <select class="form-select form-select-sm" style="width:auto;" onchange="formatDoc('formatBlock', this.value); this.selectedIndex=0;" title="Kiểu chữ">
                                                <option value="" hidden>Tiêu đề</option>
                                                <option value="H1">Tiêu đề 1 (Khổng lồ)</option>
                                                <option value="H2">Tiêu đề 2 (Mục lớn)</option>
                                                <option value="H3">Tiêu đề 3 (Mục phụ)</option>
                                                <option value="P">Bình thường</option>
                                            </select>
                                            <select class="form-select form-select-sm" style="width:auto;" onchange="formatDoc('fontSize', this.value); this.selectedIndex=0;" title="Kích cỡ">
                                                <option value="" hidden>Cỡ chữ</option>
                                                <option value="1">Rất nhỏ</option>
                                                <option value="2">Nhỏ</option>
                                                <option value="3">Vừa</option>
                                                <option value="4">Lớn</option>
                                                <option value="5">Rất lớn</option>
                                                <option value="6">Cực lớn</option>
                                                <option value="7">Khổng lồ</option>
                                            </select>
                                            <input type="color" id="editorTextColor" title="Màu chữ">
                                            <input type="color" id="editorBgColor" value="#ffffff" title="Màu nền">
                                            <div class="separator"></div>
                                            <button type="button" onclick="formatDoc('bold')" title="In đậm"><i class="fas fa-bold"></i></button>
                                            <button type="button" onclick="formatDoc('italic')" title="In nghiêng"><i class="fas fa-italic"></i></button>
                                            <button type="button" onclick="formatDoc('underline')" title="Gạch chân"><i class="fas fa-underline"></i></button>
                                            <button type="button" onclick="formatDoc('strikethrough')" title="Gạch ngang"><i class="fas fa-strikethrough"></i></button>
                                            <button type="button" onclick="formatDoc('removeFormat')" title="Xóa định dạng"><i class="fas fa-eraser"></i></button>
                                            <div class="separator"></div>
                                            <button type="button" onclick="formatDoc('justifyLeft')" title="Căn trái"><i class="fas fa-align-left"></i></button>
                                            <button type="button" onclick="formatDoc('justifyCenter')" title="Căn giữa"><i class="fas fa-align-center"></i></button>
                                            <button type="button" onclick="formatDoc('justifyRight')" title="Căn phải"><i class="fas fa-align-right"></i></button>
                                            <div class="separator"></div>
                                            <button type="button" onclick="formatDoc('indent')" title="Tăng lề"><i class="fas fa-indent"></i></button>
                                            <button type="button" onclick="formatDoc('outdent')" title="Giảm lề"><i class="fas fa-outdent"></i></button>
                                            <div class="separator"></div>
                                            <button type="button" onclick="formatDoc('insertUnorderedList')" title="Danh sách"><i class="fas fa-list-ul"></i></button>
                                            <button type="button" onclick="formatDoc('insertOrderedList')" title="Danh sách số"><i class="fas fa-list-ol"></i></button>
                                            <div class="separator"></div>
                                            <button type="button" onclick="formatDoc('subscript')" title="Chỉ số dưới"><i class="fas fa-subscript"></i></button>
                                            <button type="button" onclick="formatDoc('superscript')" title="Chỉ số trên"><i class="fas fa-superscript"></i></button>
                                            <button type="button" onclick="formatDoc('insertHorizontalRule')" title="Chèn dòng kẻ"><i class="fas fa-minus"></i></button>
                                            <button type="button" onclick="insertTable()" title="Chèn Bảng"><i class="fas fa-table"></i></button>
                                            <div class="separator"></div>
                                            <button type="button" onclick="addLink()" title="Chèn Link"><i class="fas fa-link"></i></button>
                                            <button type="button" onclick="formatDoc('unlink')" title="Xóa Link"><i class="fas fa-unlink"></i></button>
                                            <div class="separator"></div>
                                            <button type="button" onclick="document.getElementById('editorMediaUpload').click()" title="Chèn Ảnh/Video" class="text-primary"><i class="fas fa-photo-video"></i></button>
                                            <input type="file" id="editorMediaUpload" accept="image/*,video/*" style="display:none">
                                        </div>
                                        <div class="desc-editor" contenteditable="true" id="descEditor" spellcheck="false" placeholder="Mô tả chi tiết về sự kiện, chương trình, nghệ sĩ...">${event.description}</div>
                                        <textarea name="description" id="descHidden" class="d-none" required>${event.description}</textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-5">
                            <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible stagger-1">
                                <div class="card-body p-4">
                                    <h5 class="fw-bold mb-4"><i class="fas fa-image text-primary me-2"></i>Ảnh bìa</h5>
                                    <c:if test="${not empty event.bannerImage}">
                                        <img src="${event.bannerImage}" alt="Banner hiện tại" class="current-banner-preview" id="currentBanner">
                                        <input type="hidden" name="bannerImage" id="currentBannerUrl" value="${event.bannerImage}"/>
                                        <p class="text-muted small mb-3"><i class="fas fa-info-circle me-1"></i>Upload ảnh mới để thay thế</p>
                                    </c:if>
                                    <div class="upload-zone" id="uploadZone" onclick="document.getElementById('bannerInput').click()">
                                        <div class="upload-placeholder">
                                            <div class="mb-3">
                                                <i class="fas fa-cloud-upload-alt fa-3x" style="color: var(--primary); opacity: 0.5;"></i>
                                            </div>
                                            <p class="fw-medium mb-1">Kéo thả hoặc nhấn để chọn ảnh mới</p>
                                            <small class="text-muted">PNG, JPG, WEBP — Tối đa 5MB</small>
                                        </div>
                                        <img id="bannerPreview" class="preview-img d-none" alt="Preview">
                                    </div>
                                    <input type="file" class="d-none" name="banner" id="bannerInput" accept="image/*">
                                    <button type="button" id="removeBanner" class="btn btn-sm btn-outline-danger rounded-pill mt-3 d-none" onclick="removeBannerImage()">
                                        <i class="fas fa-trash me-1"></i>Xóa ảnh mới
                                    </button>
                                </div>
                            </div>

                            <!-- Event Status Info -->
                            <div class="card glass-strong border-0 rounded-4 mt-3 animate-on-scroll visible stagger-2">
                                <div class="card-body p-4">
                                    <h6 class="fw-bold mb-3"><i class="fas fa-cog text-primary me-2"></i>Trạng thái</h6>
                                    <div class="d-flex align-items-center gap-2 mb-2">
                                        <span class="badge rounded-pill
                                            ${event.status == 'approved' ? 'bg-success' : ''}
                                            ${event.status == 'pending' ? 'bg-warning text-dark' : ''}
                                            ${event.status == 'draft' ? 'bg-secondary' : ''}
                                            px-3 py-2">
                                            ${event.status == 'approved' ? 'Đã duyệt' : event.status == 'pending' ? 'Chờ duyệt' : 'Nháp'}
                                        </span>
                                    </div>
                                    <small class="text-muted">
                                        <i class="far fa-eye me-1"></i>${event.views} lượt xem
                                        <span class="mx-1">&bull;</span>
                                        <i class="far fa-calendar me-1"></i>Tạo: <fmt:formatDate value="${event.createdAt}" pattern="dd/MM/yyyy"/>
                                    </small>
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
                                    <input type="datetime-local" class="form-control form-control-lg" name="startDate" id="startDate" required
                                           value="<fmt:formatDate value='${event.startDate}' pattern='yyyy-MM-dd&#39;T&#39;HH:mm'/>">
                                    <span class="field-error-msg">Vui lòng chọn ngày bắt đầu</span>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Ngày kết thúc</label>
                                    <input type="datetime-local" class="form-control form-control-lg" name="endDate" id="endDate"
                                           value="<fmt:formatDate value='${event.endDate}' pattern='yyyy-MM-dd&#39;T&#39;HH:mm'/>">
                                    <span class="field-error-msg" id="endDateError">Ngày kết thúc phải sau ngày bắt đầu</span>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Địa điểm <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-lg" name="location" id="eventLocation"
                                           placeholder="VD: Nhà hát Thành phố" required
                                           value="${event.location}">
                                    <span class="field-error-msg">Vui lòng nhập địa điểm</span>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-medium">Địa chỉ chi tiết</label>
                                    <input type="text" class="form-control form-control-lg" name="address" id="eventAddress"
                                           placeholder="Số nhà, đường, quận..."
                                           value="${event.address}">
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Event Settings Card --%>
                    <div class="card glass-strong border-0 rounded-4 mt-4 animate-on-scroll visible">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3"><i class="fas fa-cog text-primary me-2"></i>Cài đặt vé</h5>
                            <div class="row g-3">
                                <div class="col-md-4">
                                     <label class="form-label small fw-medium">Giới hạn vé tối đa/mỗi khách</label>
                                    <input type="number" class="form-control" name="maxTicketsPerOrder" 
                                         value="${event.maxTicketsPerOrder}" min="0" max="50" placeholder="0 = mặc định hệ thống (4)">
                                     <small class="text-muted">Giới hạn tổng vé 1 khách được mua cho sự kiện này. 0 = mặc định hệ thống (4)</small>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small fw-medium">Tổng vé tối đa cho sự kiện</label>
                                    <input type="number" class="form-control" name="maxTotalTickets" 
                                           value="${event.maxTotalTickets}" min="0" placeholder="0 = không giới hạn">
                                    <small class="text-muted">0 = không giới hạn</small>
                                </div>
                                <div class="col-md-4 d-flex align-items-center">
                                    <div class="form-check form-switch mt-3">
                                        <input class="form-check-input" type="checkbox" name="preOrderEnabled" value="true" 
                                               id="editPreOrderSwitch" ${event.preOrderEnabled ? 'checked' : ''}
                                               style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                        <label class="form-check-label fw-medium" for="editPreOrderSwitch">Cho phép đặt trước</label>
                                        <br><small class="text-muted">Khách mua vé trước khi mở bán chính thức</small>
                                    </div>
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

                <!-- ====== STEP 3: Review ====== -->
                <div class="wizard-panel" data-panel="3">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll visible">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4"><i class="fas fa-check-double text-primary me-2"></i>Xem lại thay đổi</h5>

                            <div class="review-section">
                                <div class="d-flex justify-content-between align-items-center">
                                    <h6 class="mb-0">Thông tin sự kiện</h6>
                                    <span class="review-edit-btn" onclick="goToStep(1)"><i class="fas fa-pen me-1"></i>Sửa</span>
                                </div>
                                <div class="row mt-2">
                                    <div class="col-md-8">
                                        <p class="mb-1"><strong id="reviewTitle">&mdash;</strong></p>
                                        <p class="text-muted small mb-0" id="reviewCategory">&mdash;</p>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <img id="reviewBanner" class="rounded-3 d-none" style="max-height: 80px; object-fit: cover;" alt="Banner">
                                    </div>
                                </div>
                            </div>

                            <div class="review-section">
                                <div class="d-flex justify-content-between align-items-center">
                                    <h6 class="mb-0">Thời gian & Địa điểm</h6>
                                    <span class="review-edit-btn" onclick="goToStep(2)"><i class="fas fa-pen me-1"></i>Sửa</span>
                                </div>
                                <div class="row mt-2">
                                    <div class="col-md-6">
                                        <small class="text-muted">Bắt đầu</small>
                                        <p class="fw-medium mb-0" id="reviewStart">&mdash;</p>
                                    </div>
                                    <div class="col-md-6">
                                        <small class="text-muted">Địa điểm</small>
                                        <p class="fw-medium mb-0" id="reviewLocation">&mdash;</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Privacy toggle -->
                            <div class="review-section">
                                <h6>Tùy chọn</h6>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" name="isPrivate" id="isPrivate"
                                           ${event.private ? 'checked' : ''}>
                                    <label class="form-check-label small" for="isPrivate">Sự kiện riêng tư (chỉ truy cập qua link)</label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between mt-4">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4 py-2" onclick="prevStep()">
                            <i class="fas fa-arrow-left me-2"></i>Quay lại
                        </button>
                        <button type="submit" class="btn btn-gradient btn-lg rounded-pill px-5 py-2 hover-glow" id="submitBtn">
                            <i class="fas fa-save me-2"></i>Lưu thay đổi
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// ========== WIZARD NAVIGATION ==========
var currentStep = 1;
var totalSteps = 3;

function goToStep(step) {
    if (step > currentStep && !validateCurrentStep()) return;
    if (step < 1 || step > totalSteps) return;

    document.querySelectorAll('.wizard-panel').forEach(function(p) { p.classList.remove('active'); });
    document.querySelector('[data-panel="' + step + '"]').classList.add('active');

    document.querySelectorAll('.wizard-step').forEach(function(s) {
        var sNum = parseInt(s.dataset.step);
        s.classList.remove('active', 'completed');
        if (sNum === step) s.classList.add('active');
        else if (sNum < step) s.classList.add('completed');
    });

    document.querySelectorAll('.wizard-connector').forEach(function(c, i) {
        c.classList.toggle('filled', i < step - 1);
    });

    currentStep = step;
    if (step === 3) populateReview();
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function nextStep() { goToStep(currentStep + 1); }
function prevStep() { goToStep(currentStep - 1); }

// ========== VALIDATION ==========
function validateCurrentStep() {
    var valid = true;
    var panel = document.querySelector('[data-panel="' + currentStep + '"]');
    panel.querySelectorAll('.field-error').forEach(function(el) { el.classList.remove('field-error'); });

    if (currentStep === 1) {
        var title = document.getElementById('eventTitle');
        var cat = document.getElementById('eventCategory');
        if (!title.value.trim()) { title.classList.add('field-error'); valid = false; }
        if (!cat.value) { cat.classList.add('field-error'); valid = false; }
        document.getElementById('descHidden').value = document.getElementById('descEditor').innerHTML;
    }

    if (currentStep === 2) {
        var start = document.getElementById('startDate');
        var end = document.getElementById('endDate');
        var loc = document.getElementById('eventLocation');
        if (!start.value) { start.classList.add('field-error'); valid = false; }
        if (!loc.value.trim()) { loc.classList.add('field-error'); valid = false; }
        if (end.value && start.value && new Date(end.value) <= new Date(start.value)) {
            end.classList.add('field-error');
            document.getElementById('endDateError').style.display = 'block';
            valid = false;
        }
    }

    return valid;
}

// ========== IMAGE UPLOAD ==========
var uploadZone = document.getElementById('uploadZone');
var bannerInput = document.getElementById('bannerInput');
var bannerPreview = document.getElementById('bannerPreview');

['dragenter', 'dragover'].forEach(function(evt) {
    uploadZone.addEventListener(evt, function(e) { e.preventDefault(); uploadZone.classList.add('dragover'); });
});
['dragleave', 'drop'].forEach(function(evt) {
    uploadZone.addEventListener(evt, function(e) { e.preventDefault(); uploadZone.classList.remove('dragover'); });
});
uploadZone.addEventListener('drop', function(e) {
    var file = e.dataTransfer.files[0];
    if (file && file.type.startsWith('image/')) {
        var dt = new DataTransfer();
        dt.items.add(file);
        bannerInput.files = dt.files;
        previewImage(file);
    }
});

bannerInput.addEventListener('change', function(e) {
    if (e.target.files[0]) previewImage(e.target.files[0]);
});

function previewImage(file) {
    if (file.size > 5 * 1024 * 1024) return;
    var reader = new FileReader();
    reader.onload = function(e) {
        bannerPreview.src = e.target.result;
        bannerPreview.classList.remove('d-none');
        uploadZone.classList.add('has-image');
        document.getElementById('removeBanner').classList.remove('d-none');
        // Hide current banner when new one is uploaded
        var current = document.getElementById('currentBanner');
        if (current) current.style.display = 'none';
    };
    reader.readAsDataURL(file);
}

function removeBannerImage() {
    bannerInput.value = '';
    bannerPreview.classList.add('d-none');
    uploadZone.classList.remove('has-image');
    document.getElementById('removeBanner').classList.add('d-none');
    var current = document.getElementById('currentBanner');
    if (current) current.style.display = '';
}


// ========== CUSTOM RICH TEXT EDITOR ==========
function formatDoc(cmd, value) {
    document.execCommand(cmd, false, value);
    document.getElementById('descEditor').focus();
}

function addLink() {
    const url = prompt('Nhập đường dẫn URL:');
    if (url) formatDoc('createLink', url);
}

document.getElementById('editorTextColor').addEventListener('input', function() {
    formatDoc('foreColor', this.value);
});
document.getElementById('editorBgColor').addEventListener('input', function() {
    // Some browsers use hiliteColor, some use backColor
    formatDoc('hiliteColor', this.value);
    formatDoc('backColor', this.value);
});

function insertTable() {
    var rows = prompt("Nhập số hàng:", "3");
    var cols = prompt("Nhập số cột:", "3");
    if (rows > 0 && cols > 0) {
        var html = '<table border="1" style="width:100%; border-collapse: collapse; margin-bottom: 1rem;"><tbody>';
        for (var r = 0; r < rows; r++) {
            html += '<tr>';
            for (var c = 0; c < parseInt(cols); c++) {
                html += '<td style="padding: 8px; border: 1px solid #dee2e6;">&nbsp;</td>';
            }
            html += '</tr>';
        }
        html += '</tbody></table><br>';
        formatDoc('insertHTML', html);
    }
}

// Cloudinary Upload for Editor (Images & Videos)
document.getElementById('editorMediaUpload').addEventListener('change', async function(e) {
    var file = e.target.files[0];
    if (!file) return;

    var isVideo = file.type.startsWith('video/');
    var isImage = file.type.startsWith('image/');

    if (!isVideo && !isImage) {
        if (typeof showToast === 'function') showToast('Chỉ hỗ trợ file ảnh/video', 'error');
        return;
    }

    if (isVideo && file.size > 20 * 1024 * 1024) {
        if (typeof showToast === 'function') showToast('Video tối đa 20MB', 'error');
        return;
    }

    if (isImage && file.size > 5 * 1024 * 1024) {
        if (typeof showToast === 'function') showToast('Ảnh tối đa 5MB', 'error');
        return;
    }
    
    // Show loading state on button
    var btn = e.target.previousElementSibling;
    var ogIcon = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
    btn.disabled = true;

    var formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', 'sellingticket_assets'); 
    formData.append('cloud_name', 'dylx3m30s'); 

    var endpoint = isVideo 
        ? 'https://api.cloudinary.com/v1_1/dylx3m30s/video/upload'
        : 'https://api.cloudinary.com/v1_1/dylx3m30s/image/upload';

    try {
        var res = await fetch(endpoint, {
            method: 'POST',
            body: formData
        });
        var data = await res.json();
        if (data.secure_url) {
            if (isVideo) {
                // Ensure there's a space around video for proper DOM insertion
                var vidHtml = `<br><div contenteditable="false" style="display:inline-block; max-width:100%;"><video controls style="max-width:100%; border-radius:8px; margin:10px 0;"><source src="${data.secure_url}" type="${file.type}"></video></div><br>`;
                formatDoc('insertHTML', vidHtml);
            } else {
                formatDoc('insertImage', data.secure_url);
            }
        } else {
            console.error('Cloudinary upload err:', data);
            if (typeof showToast === 'function') showToast('Lỗi tải file lên', 'error');
        }
    } catch (err) {
        console.error(err);
        if (typeof showToast === 'function') showToast('Lỗi mạng khi tải', 'error');
    } finally {
        btn.innerHTML = ogIcon;
        btn.disabled = false;
        e.target.value = ''; // Reset input
    }
});

// Sync editor to hidden textarea before validation
document.getElementById('descEditor').addEventListener('input', function() {
    document.getElementById('descHidden').value = this.innerHTML;
});



// ========== TITLE COUNTER ==========
var titleInput = document.getElementById('eventTitle');
document.getElementById('titleCount').textContent = titleInput.value.length;
titleInput.addEventListener('input', function() {
    document.getElementById('titleCount').textContent = this.value.length;
});

// ========== REVIEW POPULATION ==========
function populateReview() {
    document.getElementById('reviewTitle').textContent = document.getElementById('eventTitle').value || '\u2014';
    var catSelect = document.getElementById('eventCategory');
    document.getElementById('reviewCategory').textContent = catSelect.options[catSelect.selectedIndex] ? catSelect.options[catSelect.selectedIndex].text : '\u2014';

    var banner = document.getElementById('reviewBanner');
    if (bannerPreview.src && !bannerPreview.classList.contains('d-none')) {
        banner.src = bannerPreview.src;
        banner.classList.remove('d-none');
    } else {
        var currentUrl = document.getElementById('currentBannerUrl');
        if (currentUrl && currentUrl.value) {
            banner.src = currentUrl.value;
            banner.classList.remove('d-none');
        } else {
            banner.classList.add('d-none');
        }
    }

    var startVal = document.getElementById('startDate').value;
    document.getElementById('reviewStart').textContent = startVal ? new Date(startVal).toLocaleString('vi-VN') : '\u2014';
    document.getElementById('reviewLocation').textContent = document.getElementById('eventLocation').value || '\u2014';
}

// ========== FORM SUBMIT ==========
document.getElementById('editEventForm').addEventListener('submit', function(e) {
    document.getElementById('descHidden').value = document.getElementById('descEditor').innerHTML;
    var btn = document.getElementById('submitBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>\u0110ang l\u01B0u...';
});
</script>



<jsp:include page="../footer.jsp" />
