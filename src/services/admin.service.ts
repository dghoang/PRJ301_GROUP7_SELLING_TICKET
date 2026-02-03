import { httpClient } from "./http.service";
import { API_ENDPOINTS } from "@/config/api.config";
import type {
  User,
  Event,
  Organizer,
  ShippingProvider,
  AdminStats,
  EventApprovalRequest,
  UserActionRequest,
  RevenueByPeriod,
  TopEvent,
  TopOrganizer,
  PaginatedResponse,
  FilterParams,
  ApiResponse,
} from "@/types";

// ==========================================
// ADMIN SERVICE
// ==========================================

class AdminService {
  // Dashboard
  async getDashboardStats(): Promise<ApiResponse<AdminStats>> {
    return httpClient.get<AdminStats>(API_ENDPOINTS.ADMIN.DASHBOARD);
  }

  // ==========================================
  // EVENT MANAGEMENT
  // ==========================================

  async getEvents(params?: FilterParams & { status?: string }): Promise<ApiResponse<PaginatedResponse<Event>>> {
    const queryParams: Record<string, string> = {};
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams[key] = String(value);
        }
      });
    }
    return httpClient.get<PaginatedResponse<Event>>(API_ENDPOINTS.ADMIN.EVENTS, queryParams);
  }

  async approveEvent(id: string, data?: Partial<EventApprovalRequest>): Promise<ApiResponse<Event>> {
    return httpClient.post<Event>(API_ENDPOINTS.ADMIN.EVENT_APPROVE(id), data);
  }

  async rejectEvent(id: string, reason: string): Promise<ApiResponse<Event>> {
    return httpClient.post<Event>(API_ENDPOINTS.ADMIN.EVENT_REJECT(id), { reason });
  }

  // ==========================================
  // USER MANAGEMENT
  // ==========================================

  async getUsers(params?: FilterParams & { role?: string }): Promise<ApiResponse<PaginatedResponse<User>>> {
    const queryParams: Record<string, string> = {};
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams[key] = String(value);
        }
      });
    }
    return httpClient.get<PaginatedResponse<User>>(API_ENDPOINTS.ADMIN.USERS, queryParams);
  }

  async getUserById(id: string): Promise<ApiResponse<User>> {
    return httpClient.get<User>(API_ENDPOINTS.ADMIN.USER_BY_ID(id));
  }

  async banUser(id: string, reason: string): Promise<ApiResponse<User>> {
    return httpClient.post<User>(API_ENDPOINTS.ADMIN.USER_BAN(id), { reason });
  }

  async unbanUser(id: string): Promise<ApiResponse<User>> {
    return httpClient.post<User>(API_ENDPOINTS.ADMIN.USER_UNBAN(id));
  }

  // ==========================================
  // ORGANIZER MANAGEMENT
  // ==========================================

  async getOrganizers(params?: FilterParams): Promise<ApiResponse<PaginatedResponse<Organizer>>> {
    const queryParams: Record<string, string> = {};
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams[key] = String(value);
        }
      });
    }
    return httpClient.get<PaginatedResponse<Organizer>>(API_ENDPOINTS.ADMIN.ORGANIZERS, queryParams);
  }

  async verifyOrganizer(id: string): Promise<ApiResponse<Organizer>> {
    return httpClient.post<Organizer>(API_ENDPOINTS.ADMIN.ORGANIZER_VERIFY(id));
  }

  // ==========================================
  // SHIPPING PROVIDER MANAGEMENT
  // ==========================================

  async getShippingProviders(): Promise<ApiResponse<ShippingProvider[]>> {
    return httpClient.get<ShippingProvider[]>(API_ENDPOINTS.ADMIN.SHIPPING_PROVIDERS);
  }

  async createShippingProvider(data: Omit<ShippingProvider, "id">): Promise<ApiResponse<ShippingProvider>> {
    return httpClient.post<ShippingProvider>(API_ENDPOINTS.ADMIN.SHIPPING_PROVIDERS, data);
  }

  async updateShippingProvider(
    id: string,
    data: Partial<ShippingProvider>
  ): Promise<ApiResponse<ShippingProvider>> {
    return httpClient.put<ShippingProvider>(API_ENDPOINTS.ADMIN.SHIPPING_PROVIDER_BY_ID(id), data);
  }

  async deleteShippingProvider(id: string): Promise<ApiResponse<void>> {
    return httpClient.delete(API_ENDPOINTS.ADMIN.SHIPPING_PROVIDER_BY_ID(id));
  }

  async toggleShippingProviderStatus(id: string): Promise<ApiResponse<ShippingProvider>> {
    return httpClient.patch<ShippingProvider>(`${API_ENDPOINTS.ADMIN.SHIPPING_PROVIDER_BY_ID(id)}/toggle`);
  }

  // ==========================================
  // REPORTS
  // ==========================================

  async getRevenueReport(
    startDate: string,
    endDate: string,
    groupBy: "day" | "week" | "month" = "month"
  ): Promise<ApiResponse<RevenueByPeriod[]>> {
    return httpClient.get<RevenueByPeriod[]>(API_ENDPOINTS.ADMIN.REPORTS_REVENUE, {
      startDate,
      endDate,
      groupBy,
    });
  }

  async getTopEvents(limit: number = 10): Promise<ApiResponse<TopEvent[]>> {
    return httpClient.get<TopEvent[]>(`${API_ENDPOINTS.ADMIN.REPORTS_EVENTS}/top`, {
      limit: String(limit),
    });
  }

  async getTopOrganizers(limit: number = 10): Promise<ApiResponse<TopOrganizer[]>> {
    return httpClient.get<TopOrganizer[]>(`${API_ENDPOINTS.ADMIN.REPORTS}/top-organizers`, {
      limit: String(limit),
    });
  }

  async getUserGrowthReport(
    startDate: string,
    endDate: string
  ): Promise<ApiResponse<{ period: string; newUsers: number; totalUsers: number }[]>> {
    return httpClient.get(API_ENDPOINTS.ADMIN.REPORTS_USERS, {
      startDate,
      endDate,
    });
  }

  async exportReport(
    type: "revenue" | "events" | "users",
    startDate: string,
    endDate: string
  ): Promise<Blob> {
    const response = await fetch(
      `${API_ENDPOINTS.ADMIN.REPORTS}/${type}/export?startDate=${startDate}&endDate=${endDate}`,
      {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("ticketbox_access_token")}`,
        },
      }
    );
    return response.blob();
  }
}

export const adminService = new AdminService();
