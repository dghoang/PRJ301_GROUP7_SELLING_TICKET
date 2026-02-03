import { httpClient } from "./http.service";
import { API_ENDPOINTS } from "@/config/api.config";
import type {
  Organizer,
  Event,
  Order,
  Voucher,
  VoucherCreateRequest,
  TeamMember,
  TeamInviteRequest,
  DashboardStats,
  RevenueByPeriod,
  CheckInRequest,
  CheckInResponse,
  CheckInStats,
  BankingInfo,
  OrderFilterParams,
  PaginatedResponse,
  ApiResponse,
} from "@/types";

// ==========================================
// ORGANIZER SERVICE
// ==========================================

class OrganizerService {
  // Get organizer profile
  async getProfile(): Promise<ApiResponse<Organizer>> {
    return httpClient.get<Organizer>(API_ENDPOINTS.ORGANIZER.PROFILE);
  }

  // Update organizer profile
  async updateProfile(data: Partial<Organizer>): Promise<ApiResponse<Organizer>> {
    return httpClient.put<Organizer>(API_ENDPOINTS.ORGANIZER.PROFILE, data);
  }

  // Get dashboard stats
  async getDashboardStats(): Promise<ApiResponse<DashboardStats>> {
    return httpClient.get<DashboardStats>(API_ENDPOINTS.ORGANIZER.DASHBOARD);
  }

  // Get organizer events
  async getEvents(params?: OrderFilterParams): Promise<ApiResponse<PaginatedResponse<Event>>> {
    const queryParams: Record<string, string> = {};
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams[key] = String(value);
        }
      });
    }
    return httpClient.get<PaginatedResponse<Event>>(API_ENDPOINTS.ORGANIZER.EVENTS, queryParams);
  }

  // Get organizer orders
  async getOrders(params?: OrderFilterParams): Promise<ApiResponse<PaginatedResponse<Order>>> {
    const queryParams: Record<string, string> = {};
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams[key] = String(value);
        }
      });
    }
    return httpClient.get<PaginatedResponse<Order>>(API_ENDPOINTS.ORGANIZER.ORDERS, queryParams);
  }

  // Get order detail
  async getOrderById(id: string): Promise<ApiResponse<Order>> {
    return httpClient.get<Order>(API_ENDPOINTS.ORGANIZER.ORDER_BY_ID(id));
  }

  // Export orders to Excel
  async exportOrders(eventId?: string, startDate?: string, endDate?: string): Promise<Blob> {
    const params = new URLSearchParams();
    if (eventId) params.append("eventId", eventId);
    if (startDate) params.append("startDate", startDate);
    if (endDate) params.append("endDate", endDate);
    
    const response = await fetch(
      `${API_ENDPOINTS.ORGANIZER.ORDERS}/export?${params.toString()}`,
      {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("ticketbox_access_token")}`,
        },
      }
    );
    return response.blob();
  }

  // Statistics
  async getStatistics(
    period: "day" | "week" | "month" | "year" = "month",
    eventId?: string
  ): Promise<ApiResponse<RevenueByPeriod[]>> {
    const params: Record<string, string> = { period };
    if (eventId) params.eventId = eventId;
    return httpClient.get<RevenueByPeriod[]>(API_ENDPOINTS.ORGANIZER.STATISTICS, params);
  }

  // ==========================================
  // VOUCHER MANAGEMENT
  // ==========================================

  async getVouchers(): Promise<ApiResponse<Voucher[]>> {
    return httpClient.get<Voucher[]>(API_ENDPOINTS.ORGANIZER.VOUCHERS);
  }

  async createVoucher(data: VoucherCreateRequest): Promise<ApiResponse<Voucher>> {
    return httpClient.post<Voucher>(API_ENDPOINTS.ORGANIZER.VOUCHERS, data);
  }

  async updateVoucher(id: string, data: Partial<VoucherCreateRequest>): Promise<ApiResponse<Voucher>> {
    return httpClient.put<Voucher>(`${API_ENDPOINTS.ORGANIZER.VOUCHERS}/${id}`, data);
  }

  async deleteVoucher(id: string): Promise<ApiResponse<void>> {
    return httpClient.delete(`${API_ENDPOINTS.ORGANIZER.VOUCHERS}/${id}`);
  }

  async toggleVoucherStatus(id: string): Promise<ApiResponse<Voucher>> {
    return httpClient.patch<Voucher>(`${API_ENDPOINTS.ORGANIZER.VOUCHERS}/${id}/toggle`);
  }

  // ==========================================
  // TEAM MANAGEMENT
  // ==========================================

  async getTeamMembers(): Promise<ApiResponse<TeamMember[]>> {
    return httpClient.get<TeamMember[]>(API_ENDPOINTS.ORGANIZER.TEAM);
  }

  async inviteTeamMember(data: TeamInviteRequest): Promise<ApiResponse<TeamMember>> {
    return httpClient.post<TeamMember>(API_ENDPOINTS.ORGANIZER.INVITE_MEMBER, data);
  }

  async updateTeamMember(id: string, data: Partial<TeamMember>): Promise<ApiResponse<TeamMember>> {
    return httpClient.put<TeamMember>(API_ENDPOINTS.ORGANIZER.TEAM_MEMBER(id), data);
  }

  async removeTeamMember(id: string): Promise<ApiResponse<void>> {
    return httpClient.delete(API_ENDPOINTS.ORGANIZER.TEAM_MEMBER(id));
  }

  // ==========================================
  // CHECK-IN
  // ==========================================

  async checkIn(data: CheckInRequest): Promise<ApiResponse<CheckInResponse>> {
    return httpClient.post<CheckInResponse>(API_ENDPOINTS.TICKETS.CHECK_IN, data);
  }

  async getCheckInStats(eventId: string): Promise<ApiResponse<CheckInStats>> {
    return httpClient.get<CheckInStats>(API_ENDPOINTS.ORGANIZER.CHECK_IN_STATS(eventId));
  }

  // ==========================================
  // SETTINGS
  // ==========================================

  async updateBankingInfo(data: BankingInfo): Promise<ApiResponse<BankingInfo>> {
    return httpClient.put<BankingInfo>(API_ENDPOINTS.ORGANIZER.BANKING, data);
  }

  async getBankingInfo(): Promise<ApiResponse<BankingInfo>> {
    return httpClient.get<BankingInfo>(API_ENDPOINTS.ORGANIZER.BANKING);
  }
}

export const organizerService = new OrganizerService();
