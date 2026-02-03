import { useState, useEffect, useCallback } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { organizerService } from "@/services/organizer.service";
import type {
  Event,
  Order,
  Voucher,
  VoucherCreateRequest,
  TeamMember,
  TeamInviteRequest,
  DashboardStats,
  CheckInRequest,
  CheckInResponse,
  CheckInStats,
  OrderFilterParams,
  PaginatedResponse,
} from "@/types";

// ==========================================
// USE ORGANIZER DASHBOARD HOOK
// ==========================================

export function useOrganizerDashboard() {
  return useQuery({
    queryKey: ["organizer", "dashboard"],
    queryFn: async () => {
      const response = await organizerService.getDashboardStats();
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch dashboard");
      }
      return response.data as DashboardStats;
    },
  });
}

// ==========================================
// USE ORGANIZER EVENTS HOOK
// ==========================================

export function useOrganizerEvents(filters?: OrderFilterParams) {
  return useQuery({
    queryKey: ["organizer", "events", filters],
    queryFn: async () => {
      const response = await organizerService.getEvents(filters);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch events");
      }
      return response.data as PaginatedResponse<Event>;
    },
  });
}

// ==========================================
// USE ORGANIZER ORDERS HOOK
// ==========================================

export function useOrganizerOrders(filters?: OrderFilterParams) {
  return useQuery({
    queryKey: ["organizer", "orders", filters],
    queryFn: async () => {
      const response = await organizerService.getOrders(filters);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch orders");
      }
      return response.data as PaginatedResponse<Order>;
    },
  });
}

// ==========================================
// USE ORGANIZER VOUCHERS HOOK
// ==========================================

export function useOrganizerVouchers() {
  const queryClient = useQueryClient();

  const query = useQuery({
    queryKey: ["organizer", "vouchers"],
    queryFn: async () => {
      const response = await organizerService.getVouchers();
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch vouchers");
      }
      return response.data as Voucher[];
    },
  });

  const createMutation = useMutation({
    mutationFn: async (data: VoucherCreateRequest) => {
      const response = await organizerService.createVoucher(data);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to create voucher");
      }
      return response.data as Voucher;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["organizer", "vouchers"] });
    },
  });

  const toggleMutation = useMutation({
    mutationFn: async (id: string) => {
      const response = await organizerService.toggleVoucherStatus(id);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to toggle voucher");
      }
      return response.data as Voucher;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["organizer", "vouchers"] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const response = await organizerService.deleteVoucher(id);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to delete voucher");
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["organizer", "vouchers"] });
    },
  });

  return {
    vouchers: query.data || [],
    isLoading: query.isLoading,
    createVoucher: createMutation.mutateAsync,
    toggleVoucher: toggleMutation.mutateAsync,
    deleteVoucher: deleteMutation.mutateAsync,
    isCreating: createMutation.isPending,
  };
}

// ==========================================
// USE ORGANIZER TEAM HOOK
// ==========================================

export function useOrganizerTeam() {
  const queryClient = useQueryClient();

  const query = useQuery({
    queryKey: ["organizer", "team"],
    queryFn: async () => {
      const response = await organizerService.getTeamMembers();
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch team");
      }
      return response.data as TeamMember[];
    },
  });

  const inviteMutation = useMutation({
    mutationFn: async (data: TeamInviteRequest) => {
      const response = await organizerService.inviteTeamMember(data);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to invite member");
      }
      return response.data as TeamMember;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["organizer", "team"] });
    },
  });

  const removeMutation = useMutation({
    mutationFn: async (id: string) => {
      const response = await organizerService.removeTeamMember(id);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to remove member");
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["organizer", "team"] });
    },
  });

  return {
    members: query.data || [],
    isLoading: query.isLoading,
    inviteMember: inviteMutation.mutateAsync,
    removeMember: removeMutation.mutateAsync,
    isInviting: inviteMutation.isPending,
  };
}

// ==========================================
// USE CHECK-IN HOOK
// ==========================================

export function useCheckIn(eventId: string) {
  const [stats, setStats] = useState<CheckInStats | null>(null);

  // Fetch initial stats
  useEffect(() => {
    const fetchStats = async () => {
      const response = await organizerService.getCheckInStats(eventId);
      if (response.success && response.data) {
        setStats(response.data);
      }
    };
    fetchStats();
  }, [eventId]);

  const checkInMutation = useMutation({
    mutationFn: async (data: CheckInRequest) => {
      const response = await organizerService.checkIn(data);
      if (!response.success) {
        throw new Error(response.error?.message || "Check-in failed");
      }
      return response.data as CheckInResponse;
    },
    onSuccess: (data) => {
      if (data.success && stats) {
        setStats({
          ...stats,
          checkedIn: stats.checkedIn + 1,
          remaining: stats.remaining - 1,
          checkInRate: ((stats.checkedIn + 1) / stats.totalTickets) * 100,
        });
      }
    },
  });

  const refreshStats = useCallback(async () => {
    const response = await organizerService.getCheckInStats(eventId);
    if (response.success && response.data) {
      setStats(response.data);
    }
  }, [eventId]);

  return {
    stats,
    checkIn: checkInMutation.mutateAsync,
    isCheckingIn: checkInMutation.isPending,
    lastCheckIn: checkInMutation.data,
    refreshStats,
  };
}
