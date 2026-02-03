import { httpClient } from "./http.service";
import { API_ENDPOINTS } from "@/config/api.config";
import type {
  Order,
  OrderCreateRequest,
  OrderFilterParams,
  PaginatedResponse,
  ApiResponse,
  Ticket,
  Voucher,
} from "@/types";

// ==========================================
// ORDER SERVICE
// ==========================================

class OrderService {
  // Create new order
  async createOrder(data: OrderCreateRequest): Promise<ApiResponse<Order>> {
    return httpClient.post<Order>(API_ENDPOINTS.ORDERS.BASE, data);
  }

  // Get order by ID
  async getOrderById(id: string): Promise<ApiResponse<Order>> {
    return httpClient.get<Order>(API_ENDPOINTS.ORDERS.BY_ID(id));
  }

  // Get order by order number
  async getOrderByNumber(orderNumber: string): Promise<ApiResponse<Order>> {
    return httpClient.get<Order>(API_ENDPOINTS.ORDERS.BY_ORDER_NUMBER(orderNumber));
  }

  // Get my orders (customer)
  async getMyOrders(params?: OrderFilterParams): Promise<ApiResponse<PaginatedResponse<Order>>> {
    const queryParams: Record<string, string> = {};
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams[key] = String(value);
        }
      });
    }
    return httpClient.get<PaginatedResponse<Order>>(API_ENDPOINTS.ORDERS.MY_ORDERS, queryParams);
  }

  // Cancel order
  async cancelOrder(id: string, reason?: string): Promise<ApiResponse<Order>> {
    return httpClient.post<Order>(API_ENDPOINTS.ORDERS.CANCEL(id), { reason });
  }

  // Apply voucher to order calculation
  async applyVoucher(
    eventId: string,
    items: { ticketTypeId: string; quantity: number }[],
    voucherCode: string
  ): Promise<ApiResponse<{
    subtotal: number;
    discount: number;
    total: number;
    voucher: Voucher;
  }>> {
    return httpClient.post(API_ENDPOINTS.ORDERS.APPLY_VOUCHER, {
      eventId,
      items,
      voucherCode,
    });
  }

  // Calculate order total
  async calculateOrder(
    eventId: string,
    items: { ticketTypeId: string; quantity: number }[],
    voucherCode?: string,
    shippingProviderId?: string
  ): Promise<ApiResponse<{
    subtotal: number;
    discount: number;
    shippingFee: number;
    total: number;
  }>> {
    return httpClient.post(API_ENDPOINTS.ORDERS.CALCULATE, {
      eventId,
      items,
      voucherCode,
      shippingProviderId,
    });
  }

  // Get my tickets
  async getMyTickets(): Promise<ApiResponse<Ticket[]>> {
    return httpClient.get<Ticket[]>(API_ENDPOINTS.TICKETS.MY_TICKETS);
  }

  // Get ticket by code
  async getTicketByCode(code: string): Promise<ApiResponse<Ticket>> {
    return httpClient.get<Ticket>(API_ENDPOINTS.TICKETS.BY_CODE(code));
  }
}

// ==========================================
// VOUCHER SERVICE
// ==========================================

class VoucherService {
  // Validate voucher
  async validateVoucher(
    code: string,
    eventId: string,
    orderAmount: number
  ): Promise<ApiResponse<{
    valid: boolean;
    voucher?: Voucher;
    discountAmount?: number;
    message?: string;
  }>> {
    return httpClient.post(API_ENDPOINTS.VOUCHERS.VALIDATE, {
      code,
      eventId,
      orderAmount,
    });
  }

  // Get voucher by code
  async getVoucherByCode(code: string): Promise<ApiResponse<Voucher>> {
    return httpClient.get<Voucher>(API_ENDPOINTS.VOUCHERS.BY_CODE(code));
  }
}

export const orderService = new OrderService();
export const voucherService = new VoucherService();
