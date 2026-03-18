const fs = require("fs");
const path = require("path");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  ImageRun, Header, Footer, AlignmentType, HeadingLevel, BorderStyle,
  WidthType, ShadingType, VerticalAlign, PageNumber, PageBreak, LevelFormat,
  TableOfContents
} = require("docx");

// ─── Constants ───
const IMG_DIR = path.join(__dirname, "diagrams", "images");
const OUT_FILE = path.join(__dirname, "UseCase_Specification_SellingTicket.docx");

const tableBorder = { style: BorderStyle.SINGLE, size: 1, color: "BBBBBB" };
const cellBorders = { top: tableBorder, bottom: tableBorder, left: tableBorder, right: tableBorder };
const headerShading = { fill: "1565C0", type: ShadingType.CLEAR };
const subHeaderShading = { fill: "E3F2FD", type: ShadingType.CLEAR };
const altRowShading = { fill: "F5F5F5", type: ShadingType.CLEAR };

// ─── Helpers ───
function heading1(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_1, spacing: { before: 400, after: 200 }, children: [new TextRun({ text, bold: true, size: 32, font: "Arial", color: "1565C0" })] });
}
function heading2(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_2, spacing: { before: 300, after: 150 }, children: [new TextRun({ text, bold: true, size: 26, font: "Arial", color: "1976D2" })] });
}
function heading3(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_3, spacing: { before: 200, after: 100 }, children: [new TextRun({ text, bold: true, size: 22, font: "Arial", color: "2196F3" })] });
}
function para(text, opts = {}) {
  return new Paragraph({ spacing: { after: 80 }, ...opts, children: [new TextRun({ text, size: 22, font: "Arial", ...opts.run })] });
}
function boldPara(label, value) {
  return new Paragraph({ spacing: { after: 60 }, children: [
    new TextRun({ text: label, bold: true, size: 22, font: "Arial" }),
    new TextRun({ text: value, size: 22, font: "Arial" })
  ]});
}

function makeCell(text, width, opts = {}) {
  return new TableCell({
    borders: cellBorders,
    width: { size: width, type: WidthType.DXA },
    shading: opts.shading,
    verticalAlign: VerticalAlign.CENTER,
    children: [new Paragraph({
      alignment: opts.align || AlignmentType.LEFT,
      spacing: { before: 40, after: 40 },
      children: [new TextRun({ text: String(text), size: 20, font: "Arial", bold: !!opts.bold, color: opts.color || "000000" })]
    })]
  });
}

function simpleTable(headers, rows, widths) {
  const total = widths.reduce((a, b) => a + b, 0);
  return new Table({
    columnWidths: widths,
    rows: [
      new TableRow({
        tableHeader: true,
        children: headers.map((h, i) => makeCell(h, widths[i], { shading: headerShading, bold: true, color: "FFFFFF", align: AlignmentType.CENTER }))
      }),
      ...rows.map((row, ri) => new TableRow({
        children: row.map((cell, ci) => makeCell(cell, widths[ci], { shading: ri % 2 === 1 ? altRowShading : undefined }))
      }))
    ]
  });
}

function ucSpecTable(spec) {
  const w1 = 2800, w2 = 6560;
  const fields = [
    ["ID", spec.id], ["Tên Use Case", spec.name], ["Actor chính", spec.actor],
    ["Mô tả", spec.desc], ["Tiền điều kiện", spec.pre || "—"], ["Hậu điều kiện", spec.post || "—"]
  ];
  if (spec.include) fields.push(["Include", spec.include]);
  if (spec.extend) fields.push(["Extend", spec.extend]);
  return new Table({
    columnWidths: [w1, w2],
    rows: fields.map(([label, val], i) => new TableRow({
      children: [
        makeCell(label, w1, { shading: subHeaderShading, bold: true }),
        makeCell(val, w2, { shading: i % 2 === 1 ? altRowShading : undefined })
      ]
    }))
  });
}

function flowTable(steps) {
  return simpleTable(["Bước", "Hành động"], steps.map((s, i) => [String(i + 1), s]), [900, 8460]);
}

function altFlowTable(alts) {
  return simpleTable(["ID", "Điều kiện", "Xử lý"], alts, [900, 3780, 4680]);
}

function loadImage(filename) {
  const p = path.join(IMG_DIR, filename);
  if (!fs.existsSync(p)) return null;
  return fs.readFileSync(p);
}

function imageBlock(filename, title, maxW = 580) {
  const data = loadImage(filename);
  if (!data) return [para(`[Hình ảnh không tìm thấy: ${filename}]`)];
  // Calculate proportional dimensions - reference: typical UC diagram ~800x600
  const sizeInfo = require("fs").statSync(path.join(IMG_DIR, filename));
  const w = maxW;
  const h = Math.round(w * 0.75); // Approximate 4:3 ratio
  return [
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 200, after: 100 }, children: [
      new ImageRun({ type: "png", data, transformation: { width: w, height: h }, altText: { title, description: title, name: filename } })
    ]}),
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 150 }, children: [
      new TextRun({ text: `Hình: ${title}`, italics: true, size: 20, font: "Arial", color: "666666" })
    ]})
  ];
}

function pageBreak() {
  return new Paragraph({ children: [new PageBreak()] });
}

// ─── Build Document Content ───
const children = [];

// TITLE PAGE
children.push(
  new Paragraph({ spacing: { before: 3000 }, children: [] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 200 }, children: [
    new TextRun({ text: "ĐẶC TẢ USE CASE", bold: true, size: 52, font: "Arial", color: "0D47A1" })
  ]}),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 100 }, children: [
    new TextRun({ text: "Hệ Thống Bán Vé Sự Kiện Trực Tuyến", bold: true, size: 36, font: "Arial", color: "1565C0" })
  ]}),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 400 }, children: [
    new TextRun({ text: "SellingTicket Platform", size: 28, font: "Arial", color: "1976D2", italics: true })
  ]}),
  new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "PRJ301 — Group 4 — FPT University", size: 24, font: "Arial" })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "Phiên bản: 1.0 — Ngày: 19/03/2026", size: 22, font: "Arial", color: "666666" })] }),
  pageBreak()
);

// TABLE OF CONTENTS
children.push(
  heading1("Mục Lục"),
  new TableOfContents("Mục Lục", { hyperlink: true, headingStyleRange: "1-3" }),
  pageBreak()
);

// ═══ SECTION 1: OVERVIEW ═══
children.push(heading1("1. Tổng Quan Hệ Thống"));
children.push(heading2("1.1 Mô tả hệ thống"));
children.push(para("SellingTicket Platform là nền tảng bán vé sự kiện trực tuyến, cho phép Organizer tạo và quản lý sự kiện, Customer duyệt và mua vé thanh toán qua VietQR, Staff scan QR check-in, Admin duyệt sự kiện và quản lý hệ thống."));

children.push(heading2("1.2 Các Actor"));
children.push(simpleTable(["Actor", "Mô tả", "Vai trò"], [
  ["Guest", "Khách chưa đăng nhập", "Duyệt sự kiện, đăng ký, đăng nhập"],
  ["Customer", "Người dùng đã đăng nhập (kế thừa Guest)", "Mua vé, xem đơn hàng, chat, profile"],
  ["Organizer", "Nhà tổ chức sự kiện", "Tạo/sửa/xóa sự kiện, quản lý vé, voucher, staff"],
  ["Staff", "Nhân viên soát vé", "Scan QR, check-in tại cổng sự kiện"],
  ["Admin", "Quản trị viên hệ thống", "Duyệt sự kiện, quản lý user, cấu hình"]
], [1800, 3780, 3780]));

children.push(heading2("1.3 Tổng quan Modules"));
children.push(simpleTable(["Module", "Số UC", "Mô tả"], [
  ["M1: Xác thực & Người dùng", "6", "Đăng ký, đăng nhập, OAuth, profile"],
  ["M2: Quản lý Sự kiện", "8", "Tạo, sửa, duyệt, tìm kiếm sự kiện"],
  ["M3: Quản lý Loại vé", "3", "CRUD loại vé cho sự kiện"],
  ["M4: Đặt vé & Thanh toán", "8", "Checkout, VietQR, webhook, phát vé"],
  ["M5: Check-in QR Code", "3", "Scan QR, check-in, danh sách"],
  ["M6: Chat & Giao tiếp", "4", "Chat realtime, support ticket"],
  ["M7: Voucher & Khuyến mãi", "4", "Event/System voucher, validate"],
  ["M8: Dashboard & Thống kê", "5", "Organizer/Admin/Staff dashboard"],
  ["M9: Quản trị Hệ thống", "7", "Users, categories, orders, config"]
], [2800, 1000, 5560]));

// System Overview Diagram
children.push(heading2("1.4 Biểu đồ Use Case tổng quan"));
children.push(...imageBlock("UC_00_TongQuan_SystemOverview.png", "UC-00: Tổng quan hệ thống", 560));
children.push(pageBreak());

// ═══ MODULE 1: Authentication ═══
children.push(heading1("2. Module 1: Xác Thực & Quản Lý Người Dùng"));
children.push(...imageBlock("UC_01_UserAuthentication.png", "UC Diagram — Module 1: Xác thực", 500));

// UC-1.1
children.push(heading2("UC-1.1: Đăng ký tài khoản"));
children.push(ucSpecTable({ id: "UC-1.1", name: "Đăng ký tài khoản", actor: "Guest", desc: "Khách tạo tài khoản mới bằng email và mật khẩu", pre: "Guest chưa đăng nhập, email chưa tồn tại", post: "Tài khoản tạo với role = customer, password BCrypt hash" }));
children.push(heading3("Luồng chính"));
children.push(flowTable([
  "Guest truy cập trang /register",
  "Guest nhập: email, password, confirmPassword, fullName, phone",
  "Hệ thống validate: email format, email unique, password ≥ 8 ký tự, password = confirmPassword",
  "Hệ thống hash mật khẩu bằng BCrypt (cost factor 12)",
  "Hệ thống INSERT vào bảng Users (role = customer, is_active = 1)",
  "Chuyển hướng → trang login với thông báo \"Đăng ký thành công\""
]));
children.push(heading3("Luồng thay thế"));
children.push(altFlowTable([
  ["1a", "Email đã tồn tại", "Hiển thị lỗi \"Email đã được sử dụng\""],
  ["1b", "Email format sai", "Hiển thị lỗi \"Email không hợp lệ\""],
  ["1c", "Password < 8 ký tự", "Hiển thị lỗi \"Mật khẩu phải ≥ 8 ký tự\""],
  ["1d", "Password ≠ confirm", "Hiển thị lỗi \"Mật khẩu xác nhận không khớp\""]
]));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_01_Registration.png", "SD-01: Đăng ký tài khoản", 560));

// UC-1.2
children.push(heading2("UC-1.2: Đăng nhập hệ thống"));
children.push(ucSpecTable({ id: "UC-1.2", name: "Đăng nhập hệ thống", actor: "Guest", desc: "Xác thực email/password, tạo session và JWT token", pre: "Guest có tài khoản hợp lệ, chưa bị khóa", post: "Session + JWT access/refresh token phát hành, redirect theo role", include: "Validate Input, Tạo Session & JWT Token", extend: "Progressive Lockout, Remember Me" }));
children.push(heading3("Luồng chính"));
children.push(flowTable([
  "Guest nhập email + password tại /login",
  "Hệ thống validate đầu vào: null check, length ≤ 255, email regex",
  "Hệ thống normalize: trim + toLowerCase(email)",
  "Kiểm tra rate limit: LoginAttemptTracker.isBlocked(email, ip)",
  "Gọi UserService.authenticate(email, password) → BCrypt.checkpw()",
  "Áp dụng minimum delay 200ms (chống timing attack)",
  "Reset rate limit counter",
  "Session Fixation Protection: invalidate session cũ → tạo mới",
  "Phát JWT: access token (7 ngày) + refresh token (30 ngày)",
  "Lưu refresh token vào bảng UserSessions",
  "Đặt cookie HttpOnly: st_access, st_refresh",
  "Redirect theo role: customer→/home, organizer→/organizer/dashboard, admin→/admin/dashboard"
]));
children.push(heading3("Luồng thay thế"));
children.push(altFlowTable([
  ["4a", "IP/email bị khóa (≥ 5 lần fail)", "Hiển thị \"Tài khoản tạm khóa, thử lại sau 15 phút\""],
  ["5a", "Sai email hoặc password", "Hiển thị \"Email hoặc mật khẩu không đúng\""],
  ["5b", "User bị vô hiệu hóa", "Hiển thị \"Tài khoản đã bị khóa\""]
]));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_02_Login.png", "SD-02: Đăng nhập hệ thống", 560));

// UC-1.3
children.push(heading2("UC-1.3: Đăng nhập Google OAuth 2.0"));
children.push(ucSpecTable({ id: "UC-1.3", name: "Đăng nhập Google OAuth 2.0", actor: "Guest", desc: "Xác thực qua Google OAuth 2.0, tự tạo user nếu chưa tồn tại", pre: "Guest có tài khoản Google", post: "User đăng nhập thành công, session + JWT được tạo" }));
children.push(heading3("Luồng chính"));
children.push(flowTable([
  "Guest click \"Đăng nhập bằng Google\"",
  "Hệ thống redirect → Google OAuth consent screen (scopes: openid, email, profile)",
  "User đồng ý → Google redirect callback với authorization code",
  "Hệ thống trao đổi code → access_token → lấy thông tin user",
  "Kiểm tra email đã tồn tại → Nếu có: đăng nhập. Nếu không: tạo user mới",
  "Tạo session + JWT (giống UC-1.2 bước 8-12)"
]));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_03_GoogleOAuth.png", "SD-03: Google OAuth 2.0", 560));

// UC-1.4, 1.5, 1.6 (shorter)
children.push(heading2("UC-1.4: Đổi mật khẩu"));
children.push(ucSpecTable({ id: "UC-1.4", name: "Đổi mật khẩu", actor: "Customer, Organizer", desc: "Nhập current password + new password x2. BCrypt verify & hash.", pre: "User đã đăng nhập", post: "Mật khẩu được cập nhật" }));

children.push(heading2("UC-1.5: Quản lý Profile"));
children.push(ucSpecTable({ id: "UC-1.5", name: "Quản lý Profile", actor: "Customer, Organizer", desc: "Chỉnh sửa: fullName, phone, gender, dateOfBirth, avatar. Organizer thêm: bio, website, social links.", pre: "User đã đăng nhập", post: "Thông tin profile cập nhật", extend: "Upload Avatar (Cloudinary)" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_13_ProfileManagement.png", "SD-13: Quản lý Profile", 560));

children.push(heading2("UC-1.6: Đăng xuất"));
children.push(ucSpecTable({ id: "UC-1.6", name: "Đăng xuất", actor: "Customer, Organizer, Staff, Admin", desc: "Hủy session, xóa refresh token, xóa cookies. Redirect → trang chủ.", pre: "User đã đăng nhập", post: "Session hủy, cookies xóa, redirect /" }));
children.push(pageBreak());

// ═══ MODULE 2: Events ═══
children.push(heading1("3. Module 2: Quản Lý Sự Kiện"));
children.push(...imageBlock("UC_02_EventManagement.png", "UC Diagram — Module 2: Quản lý Sự kiện", 520));

children.push(heading2("UC-2.1: Tạo sự kiện mới"));
children.push(ucSpecTable({ id: "UC-2.1", name: "Tạo sự kiện mới", actor: "Organizer", desc: "Tạo sự kiện với thông tin chi tiết, upload banner, tạo loại vé", pre: "Organizer đã đăng nhập", post: "Sự kiện tạo với status = pending, chờ Admin duyệt", include: "Upload Banner (Cloudinary), Auto-generate Slug, Notify Admin" }));
children.push(heading3("Luồng chính"));
children.push(flowTable([
  "Organizer vào /organizer/events/create",
  "Nhập: title, shortDescription, description (HTML editor)",
  "Chọn category, nhập location, address, startDate, endDate",
  "Upload banner image → Cloudinary CDN",
  "Tạo ≥ 1 loại vé: name, price, quantity, saleStart, saleEnd",
  "Nhập cài đặt: maxTicketsPerOrder, isPrivate",
  "Hệ thống auto-generate slug URL-friendly",
  "INSERT vào bảng Events (status = pending)",
  "Gửi notification cho Admin: \"Sự kiện mới chờ duyệt\""
]));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_04_CreateEvent.png", "SD-04: Tạo sự kiện", 560));

children.push(heading2("UC-2.4: Duyệt/Từ chối sự kiện"));
children.push(ucSpecTable({ id: "UC-2.4", name: "Duyệt/Từ chối sự kiện", actor: "Admin", desc: "Admin review events pending. Approve → approved. Reject → kèm rejection_reason.", pre: "Sự kiện có status = pending", post: "Status chuyển sang approved hoặc rejected", include: "Gửi Notification cho Organizer" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_05_ApproveRejectEvent.png", "SD-05: Duyệt/Từ chối sự kiện", 560));

children.push(heading2("UC-2.6: Xem danh sách & Tìm kiếm sự kiện"));
children.push(ucSpecTable({ id: "UC-2.6/2.7/2.8", name: "Xem danh sách, chi tiết & Tìm kiếm sự kiện", actor: "Guest, Customer", desc: "Pagination, filter category, search title/location. Xem chi tiết: banner, mô tả, loại vé, organizer info. View count +1.", pre: "—", post: "Hiển thị kết quả" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_12_BrowseSearchEvents.png", "SD-12: Duyệt & Tìm kiếm sự kiện", 560));
children.push(pageBreak());

// ═══ MODULE 3: Ticket Types ═══
children.push(heading1("4. Module 3: Quản Lý Loại Vé"));
children.push(...imageBlock("UC_03_TicketTypeManagement.png", "UC Diagram — Module 3: Quản lý Loại Vé", 480));

children.push(heading2("UC-3.1: Tạo loại vé"));
children.push(ucSpecTable({ id: "UC-3.1", name: "Tạo loại vé", actor: "Organizer", desc: "Tạo nhiều loại vé cho 1 event: name, price, quantity, saleStart, saleEnd. VD: VIP, Standard, Early Bird.", pre: "Sự kiện đã được tạo", post: "Loại vé được tạo", include: "Validate Sale Window" }));
children.push(heading2("UC-3.2: Chỉnh sửa loại vé"));
children.push(ucSpecTable({ id: "UC-3.2", name: "Chỉnh sửa loại vé", actor: "Organizer", desc: "Cập nhật thông tin loại vé. Business Rule: newQuantity ≥ soldCount.", pre: "Loại vé đã tạo", post: "Loại vé cập nhật", include: "Validate Sale Window, Kiểm tra soldCount" }));
children.push(heading2("UC-3.3: Xóa/Vô hiệu hóa loại vé"));
children.push(ucSpecTable({ id: "UC-3.3", name: "Xóa/Vô hiệu hóa loại vé", actor: "Organizer", desc: "Soft-delete: isActive = false. Không xóa nếu soldCount > 0. Vé đã bán vẫn valid.", pre: "Loại vé đã tạo", post: "Loại vé bị vô hiệu hóa" }));
children.push(pageBreak());

// ═══ MODULE 4: Booking & Payment ═══
children.push(heading1("5. Module 4: Đặt Vé & Thanh Toán"));
children.push(...imageBlock("UC_04_BookingPayment.png", "UC Diagram — Module 4: Đặt Vé & Thanh Toán", 520));

children.push(heading2("UC-4.1: Chọn vé"));
children.push(ucSpecTable({ id: "UC-4.1", name: "Chọn vé", actor: "Customer", desc: "Chọn loại vé + số lượng. Validate: available qty, maxTicketsPerOrder, sale window.", pre: "Customer đã đăng nhập, sự kiện đang mở bán", post: "Chuyển sang trang Checkout" }));

children.push(heading2("UC-4.2: Checkout đơn hàng (Atomic Transaction)"));
children.push(ucSpecTable({ id: "UC-4.2", name: "Checkout đơn hàng", actor: "Customer", desc: "Tạo đơn hàng với Atomic Transaction: BEGIN → INSERT Order → INSERT Items → UPDATE soldCount → COMMIT", pre: "Đã chọn vé", post: "Đơn hàng tạo status = pending, chuyển trang thanh toán", include: "Validate Voucher, Atomic Transaction", extend: "Timeout 15 phút, Resume thanh toán" }));
children.push(heading3("Luồng chính"));
children.push(flowTable([
  "Customer nhập buyer info: buyerName, buyerEmail, buyerPhone, notes",
  "(Tùy chọn) Nhập mã voucher → validate (xem UC-7.3)",
  "Tính: totalAmount, discountAmount, finalAmount",
  "BEGIN TRANSACTION",
  "INSERT Orders (status = pending, payment_expires_at = NOW() + 15 phút)",
  "INSERT OrderItems (cho mỗi loại vé × số lượng)",
  "UPDATE TicketTypes SET sold_quantity += quantity (atomic)",
  "Nếu có voucher: INSERT VoucherUsages, UPDATE Vouchers.used_count",
  "COMMIT",
  "Chuyển sang trang thanh toán VietQR"
]));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_06_TicketPurchase.png", "SD-06: Mua vé (Checkout Atomic)", 560));

children.push(heading2("UC-4.3: Thanh toán VietQR (SePay)"));
children.push(ucSpecTable({ id: "UC-4.3", name: "Thanh toán VietQR", actor: "Customer", desc: "Tạo QR code qua SePay API. Customer scan QR bằng app ngân hàng → chuyển khoản.", pre: "Đơn hàng đã tạo, chưa hết hạn", post: "SePay gửi webhook → auto confirm", include: "Webhook IPN Validation" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_07_SepayPayment.png", "SD-07: Thanh toán SePay VietQR", 560));

children.push(heading2("UC-4.5: Phát vé điện tử (Ticket Issuance)"));
children.push(ucSpecTable({ id: "UC-4.5", name: "Phát vé điện tử", actor: "Hệ thống (tự động)", desc: "Sau payment confirmed: tạo N vé riêng lẻ. Mỗi vé: ticketCode unique + QR code (JWT, HMAC-SHA256).", pre: "Payment confirmed", post: "Vé được tạo, notification gửi cho customer" }));

children.push(heading2("UC-4.7: Xem lịch sử đơn hàng"));
children.push(ucSpecTable({ id: "UC-4.7", name: "Xem lịch sử đơn hàng", actor: "Customer", desc: "Danh sách orders: orderCode, event, totalAmount, status, paymentDate.", pre: "Customer đã đăng nhập", post: "Hiển thị danh sách đơn hàng" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_18_ViewOrderHistory.png", "SD-18: Xem lịch sử đơn hàng", 560));

children.push(heading2("UC-4.10: Hết hạn đơn hàng tự động"));
children.push(ucSpecTable({ id: "UC-4.10", name: "Hết hạn đơn hàng", actor: "Hệ thống (Background job)", desc: "Auto-cancel đơn hàng sau 15 phút không thanh toán. Hoàn trả soldCount vào TicketTypes.", pre: "Order status = pending, payment_expires_at < NOW()", post: "Order status = cancelled, soldCount hoàn trả" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_19_OrderExpiry.png", "SD-19: Hết hạn đơn hàng", 560));
children.push(pageBreak());

// ═══ MODULE 5: Check-in ═══
children.push(heading1("6. Module 5: Check-in QR Code"));
children.push(...imageBlock("UC_05_CheckIn.png", "UC Diagram — Module 5: Check-in QR Code", 480));

children.push(heading2("UC-5.1: Scan QR check-in"));
children.push(ucSpecTable({ id: "UC-5.1", name: "Scan QR check-in", actor: "Staff, Organizer", desc: "Camera scan QR code (jsQR library) → decode JWT → validate ticket → check-in", pre: "Staff được gán cho sự kiện", post: "Vé chuyển isCheckedIn = true", include: "Decode QR Code, Validate Ticket, Hiển thị thông tin, Xác nhận check-in", extend: "Manual Code Input, Duplicate Check-in Warning" }));
children.push(heading3("Luồng chính"));
children.push(flowTable([
  "Staff mở trang /staff/checkin/{eventId}",
  "Camera scan QR code trên vé (jsQR library, browser)",
  "Decode JWT token → extract ticketCode",
  "Validate: ticket tồn tại, đúng event, chưa check-in, order đã paid",
  "Hiển thị thông tin: attendee name, ticket type",
  "Staff xác nhận → UPDATE Tickets SET is_checked_in = 1, checked_in_at = NOW()",
  "Hiển thị ✓ Check-in thành công"
]));
children.push(heading3("Luồng thay thế"));
children.push(altFlowTable([
  ["4a", "Vé không tồn tại", "❌ Mã vé không hợp lệ"],
  ["4b", "Vé không thuộc sự kiện này", "❌ Vé không thuộc sự kiện này"],
  ["4c", "Vé đã check-in", "⚠ Vé đã sử dụng lúc {checked_in_at}"],
  ["4d", "Order chưa paid", "❌ Đơn hàng chưa thanh toán"]
]));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_08_QRCheckIn.png", "SD-08: Check-in QR Code", 560));
children.push(pageBreak());

// ═══ MODULE 6: Communication ═══
children.push(heading1("7. Module 6: Chat & Giao Tiếp"));
children.push(...imageBlock("UC_06_Communication.png", "UC Diagram — Module 6: Chat & Giao tiếp", 480));

children.push(heading2("UC-6.1: Tạo phiên chat"));
children.push(ucSpecTable({ id: "UC-6.1", name: "Tạo phiên chat", actor: "Customer", desc: "Customer mở cuộc chat với Organizer. 1 ChatSession per (event, customer, organizer).", pre: "Customer đã đăng nhập", post: "ChatSession tạo hoặc reopen" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_09_ChatSession.png", "SD-09: Chat Session", 560));

children.push(heading2("UC-6.3: Gửi Support Ticket"));
children.push(ucSpecTable({ id: "UC-6.3", name: "Gửi Support Ticket", actor: "Customer", desc: "Tạo ticket hỗ trợ. Category: payment_error, missing_ticket, cancellation, refund, ...", pre: "Customer đã đăng nhập", post: "Ticket tạo với code SUP-XXXXXX, auto-routed", include: "Auto-routing, Auto-generate Ticket Code" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_10_SupportTicket.png", "SD-10: Support Ticket", 560));
children.push(pageBreak());

// ═══ MODULE 7: Voucher ═══
children.push(heading1("8. Module 7: Voucher & Khuyến Mãi"));
children.push(...imageBlock("UC_07_VoucherManagement.png", "UC Diagram — Module 7: Voucher", 480));

children.push(heading2("UC-7.3: Validate & Áp dụng Voucher"));
children.push(ucSpecTable({ id: "UC-7.3", name: "Validate & Áp dụng Voucher", actor: "Customer", desc: "Validation chain 7 bước: code tồn tại, isActive, chưa hết hạn, usedCount, minOrderAmount, scope.", pre: "Customer nhập mã voucher khi checkout", post: "Discount applied, usedCount +1", include: "Tính Discount Amount, Tách nguồn chi phí, Cập nhật usedCount" }));
children.push(heading3("Validation Chain"));
children.push(simpleTable(["#", "Kiểm tra", "Lỗi nếu fail"], [
  ["1", "Code tồn tại?", "Mã voucher không hợp lệ"],
  ["2", "isActive == true?", "Mã đã bị vô hiệu hóa"],
  ["3", "NOW() ≥ startDate?", "Mã chưa bắt đầu"],
  ["4", "NOW() ≤ endDate?", "Mã đã hết hạn"],
  ["5", "usedCount < usageLimit?", "Đã hết lượt sử dụng"],
  ["6", "totalAmount ≥ minOrderAmount?", "Chưa đạt giá trị tối thiểu"],
  ["7", "Scope phù hợp (EVENT/SYSTEM)?", "Không áp dụng cho sự kiện này"]
], [600, 4180, 4580]));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_11_VoucherValidation.png", "SD-11: Validate Voucher", 560));
children.push(pageBreak());

// ═══ MODULE 8: Dashboard ═══
children.push(heading1("9. Module 8: Dashboard & Thống Kê"));
children.push(...imageBlock("UC_08_Dashboard.png", "UC Diagram — Module 8: Dashboard", 500));

children.push(heading2("UC-8.1: Organizer Dashboard"));
children.push(ucSpecTable({ id: "UC-8.1", name: "Organizer Dashboard", actor: "Organizer", desc: "KPIs: tổng sự kiện, vé bán, doanh thu. Biểu đồ: vé bán theo ngày, top events, conversion rate.", pre: "Organizer đã đăng nhập", post: "Dashboard hiển thị" }));
children.push(heading2("UC-8.2: Admin Dashboard"));
children.push(ucSpecTable({ id: "UC-8.2", name: "Admin Dashboard", actor: "Admin", desc: "KPIs toàn hệ thống: total users, events, orders, revenue. Monthly chart, category distribution.", pre: "Admin đã đăng nhập", post: "Dashboard hiển thị" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_14_DashboardAnalytics.png", "SD-14: Dashboard Analytics", 560));
children.push(pageBreak());

// ═══ MODULE 9: System Administration ═══
children.push(heading1("10. Module 9: Quản Trị Hệ Thống"));
children.push(...imageBlock("UC_09_SystemAdministration.png", "UC Diagram — Module 9: Quản trị", 500));

children.push(heading2("UC-9.1: Quản lý Users"));
children.push(ucSpecTable({ id: "UC-9.1", name: "Quản lý Users", actor: "Admin", desc: "Xem danh sách, search, filter, activate/deactivate/soft-delete/change role.", pre: "Admin đã đăng nhập", post: "Users được quản lý", include: "Pagination, Activity Log, Soft-delete", extend: "Bulk Operations" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_15_AdminUserManagement.png", "SD-15: Admin Quản lý Users", 560));

children.push(heading2("UC-9.7: Quản lý Staff sự kiện"));
children.push(ucSpecTable({ id: "UC-9.7", name: "Quản lý Staff sự kiện", actor: "Organizer", desc: "Search user by email → assign role (manager/staff/scanner) → INSERT EventStaff.", pre: "Organizer đã đăng nhập, sự kiện đã tạo", post: "Staff được gán cho sự kiện" }));
children.push(heading3("Sequence Diagram"));
children.push(...imageBlock("SD_20_StaffManagement.png", "SD-20: Quản lý Staff", 560));
children.push(pageBreak());

// ═══ SECURITY ═══
children.push(heading1("11. Phụ Lục: Bảo Mật & Notification"));
children.push(heading2("11.1 Security Filter Chain"));
children.push(para("Hệ thống sử dụng chuỗi filter bảo mật để xác thực và phân quyền mọi request."));
children.push(...imageBlock("SD_16_SecurityFilterChain.png", "SD-16: Security Filter Chain", 560));
children.push(heading2("11.2 Notification System"));
children.push(para("Hệ thống thông báo tự động gửi notification cho user khi có sự kiện: order confirmed, event approved/rejected, new message, etc."));
children.push(...imageBlock("SD_17_NotificationSystem.png", "SD-17: Notification System", 560));

// ═══ Build Document ═══
const doc = new Document({
  creator: "SellingTicket - PRJ301 Group 4",
  title: "Đặc Tả Use Case - Hệ Thống Bán Vé Sự Kiện",
  description: "Tài liệu đặc tả chi tiết tất cả UC của hệ thống SellingTicket",
  styles: {
    default: { document: { run: { font: "Arial", size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, color: "1565C0", font: "Arial" },
        paragraph: { spacing: { before: 400, after: 200 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 26, bold: true, color: "1976D2", font: "Arial" },
        paragraph: { spacing: { before: 300, after: 150 }, outlineLevel: 1 } },
      { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 22, bold: true, color: "2196F3", font: "Arial" },
        paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 2 } }
    ]
  },
  numbering: {
    config: [{
      reference: "bullet-list",
      levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 720, hanging: 360 } } } }]
    }]
  },
  sections: [{
    properties: {
      page: {
        margin: { top: 1200, right: 1100, bottom: 1200, left: 1200 },
        pageNumbers: { start: 1 }
      }
    },
    headers: {
      default: new Header({ children: [new Paragraph({
        alignment: AlignmentType.RIGHT,
        children: [new TextRun({ text: "Đặc Tả Use Case — SellingTicket Platform", size: 18, font: "Arial", color: "999999", italics: true })]
      })] })
    },
    footers: {
      default: new Footer({ children: [new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [
          new TextRun({ text: "PRJ301 Group 4 — FPT University  |  Trang ", size: 18, font: "Arial", color: "999999" }),
          new TextRun({ children: [PageNumber.CURRENT], size: 18, font: "Arial", color: "999999" }),
          new TextRun({ text: " / ", size: 18, font: "Arial", color: "999999" }),
          new TextRun({ children: [PageNumber.TOTAL_PAGES], size: 18, font: "Arial", color: "999999" })
        ]
      })] })
    },
    children
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(OUT_FILE, buffer);
  console.log(`Done! File saved to: ${OUT_FILE}`);
  console.log(`File size: ${(buffer.length / 1024 / 1024).toFixed(2)} MB`);
}).catch(err => {
  console.error("Error:", err);
});
