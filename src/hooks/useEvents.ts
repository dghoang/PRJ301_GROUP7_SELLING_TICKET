import { useState, useCallback } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { eventService } from "@/services/event.service";
import type { Event, EventFilterParams, PaginatedResponse } from "@/types";

// ==========================================
// USE EVENTS HOOK
// ==========================================

export function useEvents(initialFilters?: EventFilterParams) {
  const [filters, setFilters] = useState<EventFilterParams>(initialFilters || {});

  const query = useQuery({
    queryKey: ["events", filters],
    queryFn: async () => {
      const response = await eventService.getEvents(filters);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch events");
      }
      return response.data as PaginatedResponse<Event>;
    },
  });

  const updateFilters = useCallback((newFilters: Partial<EventFilterParams>) => {
    setFilters((prev) => ({ ...prev, ...newFilters }));
  }, []);

  const resetFilters = useCallback(() => {
    setFilters(initialFilters || {});
  }, [initialFilters]);

  return {
    events: query.data?.data || [],
    pagination: query.data?.meta,
    isLoading: query.isLoading,
    isError: query.isError,
    error: query.error,
    filters,
    updateFilters,
    resetFilters,
    refetch: query.refetch,
  };
}

// ==========================================
// USE EVENT DETAIL HOOK
// ==========================================

export function useEventDetail(id: string) {
  return useQuery({
    queryKey: ["event", id],
    queryFn: async () => {
      const response = await eventService.getEventById(id);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch event");
      }
      return response.data as Event;
    },
    enabled: !!id,
  });
}

// ==========================================
// USE FEATURED EVENTS HOOK
// ==========================================

export function useFeaturedEvents() {
  return useQuery({
    queryKey: ["events", "featured"],
    queryFn: async () => {
      const response = await eventService.getFeaturedEvents();
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch featured events");
      }
      return response.data as Event[];
    },
  });
}

// ==========================================
// USE UPCOMING EVENTS HOOK
// ==========================================

export function useUpcomingEvents(limit: number = 10) {
  return useQuery({
    queryKey: ["events", "upcoming", limit],
    queryFn: async () => {
      const response = await eventService.getUpcomingEvents(limit);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch upcoming events");
      }
      return response.data as Event[];
    },
  });
}

// ==========================================
// USE CATEGORIES HOOK
// ==========================================

export function useCategories() {
  return useQuery({
    queryKey: ["categories"],
    queryFn: async () => {
      const response = await eventService.getCategories();
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch categories");
      }
      return response.data;
    },
    staleTime: 1000 * 60 * 60, // 1 hour
  });
}

// ==========================================
// USE TICKET TYPES HOOK
// ==========================================

export function useTicketTypes(eventId: string) {
  return useQuery({
    queryKey: ["ticketTypes", eventId],
    queryFn: async () => {
      const response = await eventService.getTicketTypes(eventId);
      if (!response.success) {
        throw new Error(response.error?.message || "Failed to fetch ticket types");
      }
      return response.data;
    },
    enabled: !!eventId,
  });
}

// ==========================================
// USE CHECK EVENT ACCESS HOOK
// ==========================================

export function useCheckEventAccess() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ eventId, accessCode }: { eventId: string; accessCode: string }) => {
      const response = await eventService.checkEventAccess(eventId, accessCode);
      if (!response.success) {
        throw new Error(response.error?.message || "Invalid access code");
      }
      return response.data;
    },
    onSuccess: (_, variables) => {
      // Invalidate event query to refresh with access
      queryClient.invalidateQueries({ queryKey: ["event", variables.eventId] });
    },
  });
}
