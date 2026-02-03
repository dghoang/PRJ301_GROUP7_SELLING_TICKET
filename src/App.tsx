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
          
          {/* Catch-all */}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
