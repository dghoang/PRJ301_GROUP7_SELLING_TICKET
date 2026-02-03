// ==========================================
// USER & AUTHENTICATION TYPES
// ==========================================

export type UserRole = "customer" | "organizer" | "admin";
export type Gender = "male" | "female" | "other";

export interface User {
  id: string;
  email: string;
  fullName: string;
  phone?: string;
  dateOfBirth?: string;
  gender?: Gender;
  avatar?: string;
  role: UserRole;
  isVerified: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface AuthResponse {
  user: User;
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  fullName: string;
  phone: string;
  dateOfBirth?: string;
  gender?: Gender;
}

// ==========================================
// EVENT TYPES
// ==========================================

export type EventStatus = "draft" | "pending" | "approved" | "active" | "cancelled" | "completed";
export type EventPrivacy = "public" | "private" | "unlisted";
export type EventLocationType = "online" | "offline";

export interface EventCategory {
  id: string;
  name: string;
  slug: string;
  icon?: string;
  color?: string;
}

export interface EventLocation {
  type: EventLocationType;
  venueName?: string;
  address?: string;
  city?: string;
  district?: string;
  ward?: string;
  latitude?: number;
  longitude?: number;
  onlineUrl?: string;
  onlinePlatform?: string;
}

export interface EventSchedule {
  id: string;
  eventId: string;
  startTime: string;
  endTime: string;
  gateOpenTime?: string;
  isActive: boolean;
}

export interface Event {
  id: string;
  name: string;
  slug: string;
  description: string;
  shortDescription?: string;
  bannerImage: string;
  logoImage?: string;
  galleryImages?: string[];
  category: EventCategory;
  location: EventLocation;
  schedules: EventSchedule[];
  organizerId: string;
  organizer: Organizer;
  status: EventStatus;
  privacy: EventPrivacy;
  accessCode?: string;
  customUrl?: string;
  minPrice?: number;
  maxPrice?: number;
  totalCapacity: number;
  soldTickets: number;
  viewCount: number;
  isFeatured: boolean;
  tags?: string[];
  createdAt: string;
  updatedAt: string;
  publishedAt?: string;
}

export interface EventCreateRequest {
  name: string;
  description: string;
  categoryId: string;
  bannerImage: string;
  logoImage?: string;
  location: EventLocation;
  schedules: Omit<EventSchedule, "id" | "eventId">[];
  ticketTypes: TicketTypeCreateRequest[];
  privacy: EventPrivacy;
  accessCode?: string;
  customUrl?: string;
  organizerInfo: OrganizerInfo;
  bankingInfo: BankingInfo;
}

// ==========================================
// ORGANIZER TYPES
// ==========================================

export interface Organizer {
  id: string;
  userId: string;
  name: string;
  logo?: string;
  description?: string;
  email: string;
  phone?: string;
  website?: string;
  socialLinks?: SocialLinks;
  isVerified: boolean;
  status: "active" | "pending" | "suspended";
  totalEvents: number;
  totalRevenue: number;
  createdAt: string;
}

export interface OrganizerInfo {
  name: string;
  logo?: string;
  description?: string;
  email: string;
  phone?: string;
}

export interface SocialLinks {
  facebook?: string;
  instagram?: string;
  twitter?: string;
  youtube?: string;
  tiktok?: string;
}

export interface BankingInfo {
  bankName: string;
  accountNumber: string;
  accountHolder: string;
  branch?: string;
}

// ==========================================
// TICKET TYPES
// ==========================================

export type TicketStatus = "available" | "sold_out" | "hidden" | "expired";
export type TicketDeliveryType = "electronic" | "physical";

export interface TicketType {
  id: string;
  eventId: string;
  scheduleId?: string;
  name: string;
  description?: string;
  price: number;
  originalPrice?: number;
  quantity: number;
  soldQuantity: number;
  maxPerOrder: number;
  minPerOrder: number;
  saleStartTime: string;
  saleEndTime: string;
  status: TicketStatus;
  sortOrder: number;
  benefits?: string[];
}

export interface TicketTypeCreateRequest {
  name: string;
  description?: string;
  price: number;
  originalPrice?: number;
  quantity: number;
  maxPerOrder: number;
  minPerOrder: number;
  saleStartTime: string;
  saleEndTime: string;
  scheduleId?: string;
  benefits?: string[];
}

export interface Ticket {
  id: string;
  orderId: string;
  ticketTypeId: string;
  ticketType: TicketType;
  eventId: string;
  event: Event;
  scheduleId?: string;
  schedule?: EventSchedule;
  userId: string;
  code: string;
  qrCode: string;
  status: "valid" | "used" | "cancelled" | "expired";
  checkedInAt?: string;
  checkedInBy?: string;
  createdAt: string;
}

// ==========================================
// ORDER TYPES
// ==========================================

export type OrderStatus = "pending" | "processing" | "paid" | "confirmed" | "cancelled" | "refunded";
export type PaymentMethod = "bank_transfer" | "credit_card" | "momo" | "zalopay" | "vnpay";
export type PaymentStatus = "pending" | "processing" | "completed" | "failed" | "refunded";

export interface OrderItem {
  id: string;
  orderId: string;
  ticketTypeId: string;
  ticketType: TicketType;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

export interface Order {
  id: string;
  orderNumber: string;
  userId: string;
  user?: User;
  eventId: string;
  event: Event;
  scheduleId?: string;
  schedule?: EventSchedule;
  items: OrderItem[];
  subtotal: number;
  discount: number;
  shippingFee: number;
  totalAmount: number;
  voucherId?: string;
  voucher?: Voucher;
  deliveryType: TicketDeliveryType;
  shippingAddress?: ShippingAddress;
  shippingProviderId?: string;
  trackingNumber?: string;
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  status: OrderStatus;
  notes?: string;
  paidAt?: string;
  confirmedAt?: string;
  cancelledAt?: string;
  cancelReason?: string;
  createdAt: string;
  updatedAt: string;
}

export interface OrderCreateRequest {
  eventId: string;
  scheduleId?: string;
  items: { ticketTypeId: string; quantity: number }[];
  voucherCode?: string;
  deliveryType: TicketDeliveryType;
  shippingAddress?: ShippingAddress;
  shippingProviderId?: string;
  paymentMethod: PaymentMethod;
  customerInfo: CustomerInfo;
}

export interface CustomerInfo {
  fullName: string;
  email: string;
  phone: string;
}

export interface ShippingAddress {
  recipientName: string;
  phone: string;
  address: string;
  city: string;
  district: string;
  ward: string;
  notes?: string;
}

// ==========================================
// VOUCHER TYPES
// ==========================================

export type VoucherType = "percentage" | "fixed_amount";

export interface Voucher {
  id: string;
  eventId?: string;
  organizerId: string;
  code: string;
  name: string;
  description?: string;
  type: VoucherType;
  value: number;
  minOrderAmount?: number;
  maxDiscount?: number;
  quantity?: number;
  usedQuantity: number;
  maxUsagePerUser: number;
  startTime: string;
  endTime: string;
  isActive: boolean;
  createdAt: string;
}

export interface VoucherCreateRequest {
  eventId?: string;
  code: string;
  name: string;
  description?: string;
  type: VoucherType;
  value: number;
  minOrderAmount?: number;
  maxDiscount?: number;
  quantity?: number;
  maxUsagePerUser: number;
  startTime: string;
  endTime: string;
}

// ==========================================
// TEAM & PERMISSION TYPES
// ==========================================

export type TeamRole = "admin" | "manager" | "check_in" | "viewer";

export interface TeamMember {
  id: string;
  organizerId: string;
  userId: string;
  user: User;
  role: TeamRole;
  permissions: string[];
  invitedAt: string;
  acceptedAt?: string;
  isActive: boolean;
}

export interface TeamInviteRequest {
  email: string;
  role: TeamRole;
  eventIds?: string[];
}

// ==========================================
// SHIPPING TYPES
// ==========================================

export interface ShippingProvider {
  id: string;
  name: string;
  code: string;
  logo?: string;
  baseFee: number;
  feePerKm: number;
  estimatedDays: string;
  regions: string[];
  isActive: boolean;
}

// ==========================================
// STATISTICS & REPORTS
// ==========================================

export interface DashboardStats {
  totalRevenue: number;
  totalOrders: number;
  totalTicketsSold: number;
  totalEvents: number;
  revenueGrowth: number;
  ordersGrowth: number;
}

export interface RevenueByPeriod {
  period: string;
  revenue: number;
  orders: number;
  tickets: number;
}

export interface TopEvent {
  event: Event;
  ticketsSold: number;
  revenue: number;
}

export interface TopOrganizer {
  organizer: Organizer;
  eventsCount: number;
  revenue: number;
  growth: number;
}

// ==========================================
// CHECK-IN TYPES
// ==========================================

export interface CheckInRequest {
  ticketCode: string;
  eventId: string;
  scheduleId?: string;
}

export interface CheckInResponse {
  success: boolean;
  ticket?: Ticket;
  message: string;
  alreadyCheckedIn?: boolean;
}

export interface CheckInStats {
  totalTickets: number;
  checkedIn: number;
  remaining: number;
  checkInRate: number;
}

// ==========================================
// ADMIN TYPES
// ==========================================

export interface AdminStats {
  totalUsers: number;
  totalOrganizers: number;
  totalEvents: number;
  totalRevenue: number;
  pendingEvents: number;
  pendingOrganizers: number;
}

export interface EventApprovalRequest {
  eventId: string;
  action: "approve" | "reject" | "request_changes";
  reason?: string;
}

export interface UserActionRequest {
  userId: string;
  action: "ban" | "unban" | "verify";
  reason?: string;
}

// ==========================================
// COMMON TYPES
// ==========================================

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    currentPage: number;
    totalPages: number;
    totalItems: number;
    itemsPerPage: number;
  };
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, string[]>;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: ApiError;
}

export interface FilterParams {
  page?: number;
  limit?: number;
  search?: string;
  sortBy?: string;
  sortOrder?: "asc" | "desc";
}

export interface EventFilterParams extends FilterParams {
  categoryId?: string;
  city?: string;
  startDate?: string;
  endDate?: string;
  minPrice?: number;
  maxPrice?: number;
  status?: EventStatus;
}

export interface OrderFilterParams extends FilterParams {
  eventId?: string;
  status?: OrderStatus;
  paymentStatus?: PaymentStatus;
  startDate?: string;
  endDate?: string;
}
