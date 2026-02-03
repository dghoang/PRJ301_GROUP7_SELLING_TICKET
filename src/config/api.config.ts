// ==========================================
// API CONFIGURATION
// ==========================================

// Base URL for Java backend API
// Change this to your actual Java backend URL
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:8080/api";

// API Version
export const API_VERSION = "v1";

// Full API URL
export const API_URL = `${API_BASE_URL}/${API_VERSION}`;

// Request timeout in milliseconds
export const REQUEST_TIMEOUT = 30000;

// ==========================================
// API ENDPOINTS
// ==========================================

export const API_ENDPOINTS = {
  // Auth
  AUTH: {
    LOGIN: "/auth/login",
    REGISTER: "/auth/register",
    LOGOUT: "/auth/logout",
    REFRESH_TOKEN: "/auth/refresh",
    FORGOT_PASSWORD: "/auth/forgot-password",
    RESET_PASSWORD: "/auth/reset-password",
    VERIFY_EMAIL: "/auth/verify-email",
    RESEND_VERIFICATION: "/auth/resend-verification",
    ME: "/auth/me",
  },

  // Users
  USERS: {
    BASE: "/users",
    BY_ID: (id: string) => `/users/${id}`,
    PROFILE: "/users/profile",
    CHANGE_PASSWORD: "/users/change-password",
    UPLOAD_AVATAR: "/users/avatar",
  },

  // Events
  EVENTS: {
    BASE: "/events",
    BY_ID: (id: string) => `/events/${id}`,
    BY_SLUG: (slug: string) => `/events/slug/${slug}`,
    FEATURED: "/events/featured",
    UPCOMING: "/events/upcoming",
    BY_CATEGORY: (categoryId: string) => `/events/category/${categoryId}`,
    BY_ORGANIZER: (organizerId: string) => `/events/organizer/${organizerId}`,
    SCHEDULES: (eventId: string) => `/events/${eventId}/schedules`,
    TICKET_TYPES: (eventId: string) => `/events/${eventId}/ticket-types`,
    CHECK_ACCESS: (eventId: string) => `/events/${eventId}/check-access`,
  },

  // Categories
  CATEGORIES: {
    BASE: "/categories",
    BY_ID: (id: string) => `/categories/${id}`,
  },

  // Orders
  ORDERS: {
    BASE: "/orders",
    BY_ID: (id: string) => `/orders/${id}`,
    BY_ORDER_NUMBER: (orderNumber: string) => `/orders/number/${orderNumber}`,
    MY_ORDERS: "/orders/my-orders",
    CANCEL: (id: string) => `/orders/${id}/cancel`,
    APPLY_VOUCHER: "/orders/apply-voucher",
    CALCULATE: "/orders/calculate",
  },

  // Tickets
  TICKETS: {
    BASE: "/tickets",
    BY_ID: (id: string) => `/tickets/${id}`,
    MY_TICKETS: "/tickets/my-tickets",
    BY_CODE: (code: string) => `/tickets/code/${code}`,
    CHECK_IN: "/tickets/check-in",
  },

  // Vouchers
  VOUCHERS: {
    BASE: "/vouchers",
    BY_ID: (id: string) => `/vouchers/${id}`,
    BY_CODE: (code: string) => `/vouchers/code/${code}`,
    VALIDATE: "/vouchers/validate",
  },

  // Organizer
  ORGANIZER: {
    BASE: "/organizer",
    PROFILE: "/organizer/profile",
    DASHBOARD: "/organizer/dashboard",
    EVENTS: "/organizer/events",
    EVENT_BY_ID: (id: string) => `/organizer/events/${id}`,
    ORDERS: "/organizer/orders",
    ORDER_BY_ID: (id: string) => `/organizer/orders/${id}`,
    STATISTICS: "/organizer/statistics",
    TEAM: "/organizer/team",
    TEAM_MEMBER: (id: string) => `/organizer/team/${id}`,
    INVITE_MEMBER: "/organizer/team/invite",
    VOUCHERS: "/organizer/vouchers",
    CHECK_IN_STATS: (eventId: string) => `/organizer/events/${eventId}/check-in-stats`,
    SETTINGS: "/organizer/settings",
    BANKING: "/organizer/banking",
  },

  // Admin
  ADMIN: {
    DASHBOARD: "/admin/dashboard",
    EVENTS: "/admin/events",
    EVENT_APPROVE: (id: string) => `/admin/events/${id}/approve`,
    EVENT_REJECT: (id: string) => `/admin/events/${id}/reject`,
    USERS: "/admin/users",
    USER_BY_ID: (id: string) => `/admin/users/${id}`,
    USER_BAN: (id: string) => `/admin/users/${id}/ban`,
    USER_UNBAN: (id: string) => `/admin/users/${id}/unban`,
    ORGANIZERS: "/admin/organizers",
    ORGANIZER_VERIFY: (id: string) => `/admin/organizers/${id}/verify`,
    SHIPPING_PROVIDERS: "/admin/shipping-providers",
    SHIPPING_PROVIDER_BY_ID: (id: string) => `/admin/shipping-providers/${id}`,
    REPORTS: "/admin/reports",
    REPORTS_REVENUE: "/admin/reports/revenue",
    REPORTS_USERS: "/admin/reports/users",
    REPORTS_EVENTS: "/admin/reports/events",
  },

  // Shipping
  SHIPPING: {
    PROVIDERS: "/shipping/providers",
    CALCULATE_FEE: "/shipping/calculate-fee",
    TRACK: (trackingNumber: string) => `/shipping/track/${trackingNumber}`,
  },

  // Upload
  UPLOAD: {
    IMAGE: "/upload/image",
    IMAGES: "/upload/images",
    FILE: "/upload/file",
  },

  // Payment
  PAYMENT: {
    CREATE: "/payment/create",
    CALLBACK: "/payment/callback",
    STATUS: (orderId: string) => `/payment/status/${orderId}`,
  },
} as const;

// ==========================================
// HTTP HEADERS
// ==========================================

export const getAuthHeader = (token: string) => ({
  Authorization: `Bearer ${token}`,
});

export const getDefaultHeaders = () => ({
  "Content-Type": "application/json",
  Accept: "application/json",
});
