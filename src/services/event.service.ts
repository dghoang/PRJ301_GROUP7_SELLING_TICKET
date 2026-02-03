import { httpClient } from "./http.service";
import { API_ENDPOINTS } from "@/config/api.config";
import type {
  Event,
  EventCategory,
  EventCreateRequest,
  EventFilterParams,
  PaginatedResponse,
  ApiResponse,
  TicketType,
  EventSchedule,
} from "@/types";

// ==========================================
// EVENT SERVICE
// ==========================================

class EventService {
  // Get all events with filters
  async getEvents(params?: EventFilterParams): Promise<ApiResponse<PaginatedResponse<Event>>> {
    const queryParams: Record<string, string> = {};
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams[key] = String(value);
        }
      });
    }
    return httpClient.get<PaginatedResponse<Event>>(API_ENDPOINTS.EVENTS.BASE, queryParams);
  }

  // Get single event by ID
  async getEventById(id: string): Promise<ApiResponse<Event>> {
    return httpClient.get<Event>(API_ENDPOINTS.EVENTS.BY_ID(id));
  }

  // Get event by slug
  async getEventBySlug(slug: string): Promise<ApiResponse<Event>> {
    return httpClient.get<Event>(API_ENDPOINTS.EVENTS.BY_SLUG(slug));
  }

  // Get featured events
  async getFeaturedEvents(): Promise<ApiResponse<Event[]>> {
    return httpClient.get<Event[]>(API_ENDPOINTS.EVENTS.FEATURED);
  }

  // Get upcoming events
  async getUpcomingEvents(limit: number = 10): Promise<ApiResponse<Event[]>> {
    return httpClient.get<Event[]>(API_ENDPOINTS.EVENTS.UPCOMING, { limit: String(limit) });
  }

  // Get events by category
  async getEventsByCategory(
    categoryId: string,
    params?: EventFilterParams
  ): Promise<ApiResponse<PaginatedResponse<Event>>> {
    const queryParams: Record<string, string> = {};
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams[key] = String(value);
        }
      });
    }
    return httpClient.get<PaginatedResponse<Event>>(
      API_ENDPOINTS.EVENTS.BY_CATEGORY(categoryId),
      queryParams
    );
  }

  // Get event schedules
  async getEventSchedules(eventId: string): Promise<ApiResponse<EventSchedule[]>> {
    return httpClient.get<EventSchedule[]>(API_ENDPOINTS.EVENTS.SCHEDULES(eventId));
  }

  // Get ticket types for an event
  async getTicketTypes(eventId: string): Promise<ApiResponse<TicketType[]>> {
    return httpClient.get<TicketType[]>(API_ENDPOINTS.EVENTS.TICKET_TYPES(eventId));
  }

  // Check access for private event
  async checkEventAccess(eventId: string, accessCode: string): Promise<ApiResponse<{ hasAccess: boolean }>> {
    return httpClient.post<{ hasAccess: boolean }>(
      API_ENDPOINTS.EVENTS.CHECK_ACCESS(eventId),
      { accessCode }
    );
  }

  // Get all categories
  async getCategories(): Promise<ApiResponse<EventCategory[]>> {
    return httpClient.get<EventCategory[]>(API_ENDPOINTS.CATEGORIES.BASE);
  }

  // Create new event (Organizer)
  async createEvent(data: EventCreateRequest): Promise<ApiResponse<Event>> {
    return httpClient.post<Event>(API_ENDPOINTS.ORGANIZER.EVENTS, data);
  }

  // Update event (Organizer)
  async updateEvent(id: string, data: Partial<EventCreateRequest>): Promise<ApiResponse<Event>> {
    return httpClient.put<Event>(API_ENDPOINTS.ORGANIZER.EVENT_BY_ID(id), data);
  }

  // Delete event (Organizer)
  async deleteEvent(id: string): Promise<ApiResponse<void>> {
    return httpClient.delete(API_ENDPOINTS.ORGANIZER.EVENT_BY_ID(id));
  }

  // Submit event for approval (Organizer)
  async submitForApproval(id: string): Promise<ApiResponse<Event>> {
    return httpClient.post<Event>(`${API_ENDPOINTS.ORGANIZER.EVENT_BY_ID(id)}/submit`);
  }

  // Duplicate event (Organizer)
  async duplicateEvent(id: string): Promise<ApiResponse<Event>> {
    return httpClient.post<Event>(`${API_ENDPOINTS.ORGANIZER.EVENT_BY_ID(id)}/duplicate`);
  }

  // Cancel event (Organizer)
  async cancelEvent(id: string, reason: string): Promise<ApiResponse<Event>> {
    return httpClient.post<Event>(`${API_ENDPOINTS.ORGANIZER.EVENT_BY_ID(id)}/cancel`, { reason });
  }
}

export const eventService = new EventService();
