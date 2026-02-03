// Event hooks
export {
  useEvents,
  useEventDetail,
  useFeaturedEvents,
  useUpcomingEvents,
  useCategories,
  useTicketTypes,
  useCheckEventAccess,
} from "./useEvents";

// Order hooks
export {
  useMyOrders,
  useOrderDetail,
  useMyTickets,
  useCreateOrder,
  useCancelOrder,
  useValidateVoucher,
  useCalculateOrder,
} from "./useOrders";

// Organizer hooks
export {
  useOrganizerDashboard,
  useOrganizerEvents,
  useOrganizerOrders,
  useOrganizerVouchers,
  useOrganizerTeam,
  useCheckIn,
} from "./useOrganizer";

// Re-export existing hooks
export { useIsMobile } from "./use-mobile";
export { useToast } from "./use-toast";
