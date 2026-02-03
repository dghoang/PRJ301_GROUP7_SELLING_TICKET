import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { orderService, voucherService } from "@/services/order.service";
import type { Order, OrderCreateRequest, OrderFilterParams, PaginatedResponse } from "@/types";

// ==========================================
// USE MY ORDERS HOOK
// ==========================================

export function useMyOrders(filters?: OrderFilterParams) {
  return useQuery({
    queryKey: ["myOrders", filters],
    queryFn: async () => {
      const response = await orderService.getMyOrders(filters);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch orders");
      }
      return response.data as PaginatedResponse<Order>;
    },
  });
}

// ==========================================
// USE ORDER DETAIL HOOK
// ==========================================

export function useOrderDetail(id: string) {
  return useQuery({
    queryKey: ["order", id],
    queryFn: async () => {
      const response = await orderService.getOrderById(id);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch order");
      }
      return response.data as Order;
    },
    enabled: !!id,
  });
}

// ==========================================
// USE MY TICKETS HOOK
// ==========================================

export function useMyTickets() {
  return useQuery({
    queryKey: ["myTickets"],
    queryFn: async () => {
      const response = await orderService.getMyTickets();
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch tickets");
      }
      return response.data;
    },
  });
}

// ==========================================
// USE CREATE ORDER HOOK
// ==========================================

export function useCreateOrder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: OrderCreateRequest) => {
      const response = await orderService.createOrder(data);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to create order");
      }
      return response.data as Order;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["myOrders"] });
      queryClient.invalidateQueries({ queryKey: ["myTickets"] });
    },
  });
}

// ==========================================
// USE CANCEL ORDER HOOK
// ==========================================

export function useCancelOrder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, reason }: { id: string; reason?: string }) => {
      const response = await orderService.cancelOrder(id, reason);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to cancel order");
      }
      return response.data as Order;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ["order", variables.id] });
      queryClient.invalidateQueries({ queryKey: ["myOrders"] });
    },
  });
}

// ==========================================
// USE VALIDATE VOUCHER HOOK
// ==========================================

export function useValidateVoucher() {
  return useMutation({
    mutationFn: async ({
      code,
      eventId,
      orderAmount,
    }: {
      code: string;
      eventId: string;
      orderAmount: number;
    }) => {
      const response = await voucherService.validateVoucher(code, eventId, orderAmount);
      if (!response.success) {
        throw new Error(response.error?.message || "Invalid voucher code");
      }
      return response.data;
    },
  });
}

// ==========================================
// USE CALCULATE ORDER HOOK
// ==========================================

export function useCalculateOrder() {
  return useMutation({
    mutationFn: async ({
      eventId,
      items,
      voucherCode,
      shippingProviderId,
    }: {
      eventId: string;
      items: { ticketTypeId: string; quantity: number }[];
      voucherCode?: string;
      shippingProviderId?: string;
    }) => {
      const response = await orderService.calculateOrder(
        eventId,
        items,
        voucherCode,
        shippingProviderId
      );
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to calculate order");
      }
      return response.data;
    },
  });
}
