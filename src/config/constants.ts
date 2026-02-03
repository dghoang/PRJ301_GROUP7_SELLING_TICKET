// ==========================================
// APP CONSTANTS
// ==========================================

// App Info
export const APP_NAME = "Ticketbox";
export const APP_DESCRIPTION = "Nền tảng bán vé sự kiện hàng đầu Việt Nam";
export const APP_VERSION = "1.0.0";

// Pagination
export const DEFAULT_PAGE_SIZE = 12;
export const PAGE_SIZE_OPTIONS = [12, 24, 48, 96];

// Image Sizes
export const IMAGE_SIZES = {
  EVENT_BANNER: { width: 1280, height: 720 },
  EVENT_LOGO: { width: 720, height: 958 },
  AVATAR: { width: 200, height: 200 },
  THUMBNAIL: { width: 400, height: 300 },
} as const;

// Max file sizes (in bytes)
export const MAX_FILE_SIZES = {
  IMAGE: 5 * 1024 * 1024, // 5MB
  DOCUMENT: 10 * 1024 * 1024, // 10MB
} as const;

// Allowed file types
export const ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"];
export const ALLOWED_DOCUMENT_TYPES = ["application/pdf", "application/msword"];

// Ticket hold time (in seconds)
export const TICKET_HOLD_TIME = 600; // 10 minutes

// OTP expiry (in seconds)
export const OTP_EXPIRY_TIME = 300; // 5 minutes

// Session timeout (in milliseconds)
export const SESSION_TIMEOUT = 24 * 60 * 60 * 1000; // 24 hours

// ==========================================
// VIETNAMESE CITIES
// ==========================================

export const VIETNAM_CITIES = [
  { value: "hanoi", label: "Hà Nội" },
  { value: "hochiminh", label: "Hồ Chí Minh" },
  { value: "danang", label: "Đà Nẵng" },
  { value: "haiphong", label: "Hải Phòng" },
  { value: "cantho", label: "Cần Thơ" },
  { value: "bienhoa", label: "Biên Hòa" },
  { value: "nhatrang", label: "Nha Trang" },
  { value: "hue", label: "Huế" },
  { value: "buonmethuot", label: "Buôn Ma Thuột" },
  { value: "vungtau", label: "Vũng Tàu" },
  { value: "dalat", label: "Đà Lạt" },
  { value: "quynhon", label: "Quy Nhơn" },
] as const;

// ==========================================
// EVENT CATEGORIES
// ==========================================

export const EVENT_CATEGORIES = [
  { id: "music", name: "Âm nhạc", icon: "🎵", color: "#EC4899" },
  { id: "workshop", name: "Workshop", icon: "📚", color: "#8B5CF6" },
  { id: "sports", name: "Thể thao", icon: "⚽", color: "#06B6D4" },
  { id: "art", name: "Nghệ thuật", icon: "🎨", color: "#F59E0B" },
  { id: "conference", name: "Hội thảo", icon: "🎤", color: "#10B981" },
  { id: "food", name: "Ẩm thực", icon: "🍜", color: "#EF4444" },
  { id: "travel", name: "Du lịch", icon: "✈️", color: "#3B82F6" },
  { id: "community", name: "Cộng đồng", icon: "👥", color: "#6366F1" },
  { id: "other", name: "Khác", icon: "📌", color: "#6B7280" },
] as const;

// ==========================================
// ORDER & PAYMENT STATUS
// ==========================================

export const ORDER_STATUS_LABELS = {
  pending: { label: "Chờ xử lý", color: "amber" },
  processing: { label: "Đang xử lý", color: "blue" },
  paid: { label: "Đã thanh toán", color: "emerald" },
  confirmed: { label: "Đã xác nhận", color: "green" },
  cancelled: { label: "Đã hủy", color: "red" },
  refunded: { label: "Đã hoàn tiền", color: "gray" },
} as const;

export const PAYMENT_STATUS_LABELS = {
  pending: { label: "Chờ thanh toán", color: "amber" },
  processing: { label: "Đang xử lý", color: "blue" },
  completed: { label: "Hoàn thành", color: "emerald" },
  failed: { label: "Thất bại", color: "red" },
  refunded: { label: "Đã hoàn", color: "gray" },
} as const;

// ==========================================
// PAYMENT METHODS
// ==========================================

export const PAYMENT_METHODS = [
  { id: "bank_transfer", name: "Chuyển khoản ngân hàng", icon: "🏦" },
  { id: "credit_card", name: "Thẻ tín dụng/Ghi nợ", icon: "💳" },
  { id: "momo", name: "Ví MoMo", icon: "📱" },
  { id: "zalopay", name: "ZaloPay", icon: "💰" },
  { id: "vnpay", name: "VNPay", icon: "🔐" },
] as const;

// ==========================================
// TEAM ROLES
// ==========================================

export const TEAM_ROLES = [
  { id: "admin", name: "Quản trị viên", description: "Toàn quyền quản lý" },
  { id: "manager", name: "Quản lý", description: "Quản lý sự kiện và đơn hàng" },
  { id: "check_in", name: "Soát vé", description: "Chỉ có quyền check-in" },
  { id: "viewer", name: "Xem báo cáo", description: "Chỉ xem thống kê" },
] as const;

// ==========================================
// STORAGE KEYS
// ==========================================

export const STORAGE_KEYS = {
  ACCESS_TOKEN: "ticketbox_access_token",
  REFRESH_TOKEN: "ticketbox_refresh_token",
  USER: "ticketbox_user",
  CART: "ticketbox_cart",
  THEME: "ticketbox_theme",
  LANGUAGE: "ticketbox_language",
  RECENT_SEARCHES: "ticketbox_recent_searches",
} as const;

// ==========================================
// ROUTES
// ==========================================

export const ROUTES = {
  // Public
  HOME: "/",
  LOGIN: "/login",
  REGISTER: "/register",
  FORGOT_PASSWORD: "/forgot-password",
  RESET_PASSWORD: "/reset-password",
  
  // Events
  EVENTS: "/events",
  EVENT_DETAIL: (id: string) => `/events/${id}`,
  EVENT_TICKETS: (id: string) => `/events/${id}/tickets`,
  EVENT_CHECKOUT: (id: string) => `/events/${id}/checkout`,
  EVENT_CONFIRMATION: (id: string) => `/events/${id}/confirmation`,
  
  // User
  PROFILE: "/profile",
  PROFILE_TAB: (tab: string) => `/profile/${tab}`,
  
  // Organizer
  ORGANIZER_DASHBOARD: "/organizer",
  ORGANIZER_CREATE_EVENT: "/organizer/create-event",
  ORGANIZER_EVENTS: "/organizer/events",
  ORGANIZER_EVENT_EDIT: (id: string) => `/organizer/events/${id}/edit`,
  ORGANIZER_TICKETS: "/organizer/tickets",
  ORGANIZER_VOUCHERS: "/organizer/vouchers",
  ORGANIZER_ORDERS: "/organizer/orders",
  ORGANIZER_STATISTICS: "/organizer/statistics",
  ORGANIZER_TEAM: "/organizer/team",
  ORGANIZER_CHECK_IN: "/organizer/check-in",
  ORGANIZER_SETTINGS: "/organizer/settings",
  
  // Admin
  ADMIN_DASHBOARD: "/admin",
  ADMIN_EVENTS: "/admin/events",
  ADMIN_USERS: "/admin/users",
  ADMIN_SHIPPING: "/admin/shipping",
  ADMIN_REPORTS: "/admin/reports",
} as const;
