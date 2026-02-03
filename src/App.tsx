import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";

// Pages
import Index from "./pages/Index";
import NotFound from "./pages/NotFound";
import Login from "./pages/auth/Login";
import Register from "./pages/auth/Register";
import Events from "./pages/events/Events";
import EventDetail from "./pages/events/EventDetail";
import TicketSelection from "./pages/events/TicketSelection";
import Checkout from "./pages/events/Checkout";
import OrderConfirmation from "./pages/events/OrderConfirmation";
import Profile from "./pages/profile/Profile";

// Organizer Pages
import {
  OrganizerDashboard,
  CreateEvent,
  ManageEvents,
  ManageTickets,
  Vouchers,
  Orders,
  Statistics,
  Team,
  CheckIn,
  OrganizerSettings,
} from "./pages/organizer";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <Routes>
          {/* Public Pages */}
          <Route path="/" element={<Index />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          
          {/* Events */}
          <Route path="/events" element={<Events />} />
          <Route path="/events/:id" element={<EventDetail />} />
          <Route path="/events/:id/tickets" element={<TicketSelection />} />
          <Route path="/events/:id/checkout" element={<Checkout />} />
          <Route path="/events/:id/confirmation" element={<OrderConfirmation />} />
          
          {/* User Profile */}
          <Route path="/profile" element={<Profile />} />
          <Route path="/profile/:tab" element={<Profile />} />
          
          {/* Organizer */}
          <Route path="/organizer" element={<OrganizerDashboard />} />
          <Route path="/organizer/create-event" element={<CreateEvent />} />
          <Route path="/organizer/events" element={<ManageEvents />} />
          <Route path="/organizer/tickets" element={<ManageTickets />} />
          <Route path="/organizer/vouchers" element={<Vouchers />} />
          <Route path="/organizer/orders" element={<Orders />} />
          <Route path="/organizer/statistics" element={<Statistics />} />
          <Route path="/organizer/team" element={<Team />} />
          <Route path="/organizer/check-in" element={<CheckIn />} />
          <Route path="/organizer/settings" element={<OrganizerSettings />} />
          
          {/* Catch-all */}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
