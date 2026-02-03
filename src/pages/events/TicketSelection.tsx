import { useState, useEffect } from "react";
import { useParams, useSearchParams, Link } from "react-router-dom";
import { MainLayout } from "@/components/layout";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { 
  Minus, 
  Plus, 
  Clock, 
  ArrowRight, 
  ArrowLeft,
  Ticket,
  AlertCircle
} from "lucide-react";

// Mock data
const eventData = {
  id: "1",
  title: "Đêm nhạc Acoustic - Những bản tình ca",
  image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800",
  schedules: [
    { id: "s1", date: "15/02/2026", time: "19:00 - 22:00" },
    { id: "s2", date: "16/02/2026", time: "19:00 - 22:00" },
  ],
  ticketTypes: [
    { id: "t1", name: "Vé thường", price: 350000, available: 500, minQty: 1, maxQty: 10, description: "Ghế ngồi khu vực B, C" },
    { id: "t2", name: "Vé VIP", price: 750000, available: 100, minQty: 1, maxQty: 5, description: "Ghế ngồi khu vực A, bao gồm đồ uống" },
    { id: "t3", name: "Vé VVIP", price: 1500000, available: 20, minQty: 1, maxQty: 2, description: "Ghế ngồi hàng đầu, giao lưu với nghệ sĩ" },
  ],
  hasSeatMap: false,
};

const HOLD_TIME = 10 * 60; // 10 minutes in seconds

const TicketSelection = () => {
  const { id } = useParams();
  const [searchParams] = useSearchParams();
  const scheduleId = searchParams.get("schedule") || "s1";
  
  const [quantities, setQuantities] = useState<Record<string, number>>({});
  const [timeLeft, setTimeLeft] = useState(HOLD_TIME);

  const selectedSchedule = eventData.schedules.find(s => s.id === scheduleId) || eventData.schedules[0];

  // Countdown timer
  useEffect(() => {
    if (Object.values(quantities).some(q => q > 0)) {
      const timer = setInterval(() => {
        setTimeLeft(prev => {
          if (prev <= 1) {
            clearInterval(timer);
            // Reset quantities when time expires
            setQuantities({});
            return HOLD_TIME;
          }
          return prev - 1;
        });
      }, 1000);
      return () => clearInterval(timer);
    }
  }, [quantities]);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(price);
  };

  const updateQuantity = (ticketId: string, delta: number) => {
    const ticket = eventData.ticketTypes.find(t => t.id === ticketId);
    if (!ticket) return;

    setQuantities(prev => {
      const current = prev[ticketId] || 0;
      const newQty = Math.max(0, Math.min(ticket.maxQty, current + delta));
      return { ...prev, [ticketId]: newQty };
    });
  };

  const totalAmount = eventData.ticketTypes.reduce((sum, ticket) => {
    return sum + (quantities[ticket.id] || 0) * ticket.price;
  }, 0);

  const totalTickets = Object.values(quantities).reduce((sum, qty) => sum + qty, 0);

  const hasSelection = totalTickets > 0;

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8 max-w-5xl">
        {/* Header */}
        <div className="mb-8">
          <Link 
            to={`/events/${id}`}
            className="inline-flex items-center gap-2 text-muted-foreground hover:text-foreground mb-4"
          >
            <ArrowLeft className="w-4 h-4" />
            Quay lại chi tiết sự kiện
          </Link>
          <h1 className="text-2xl md:text-3xl font-bold mb-2">Chọn vé</h1>
          <p className="text-muted-foreground">{eventData.title}</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Ticket Selection */}
          <div className="lg:col-span-2 space-y-4">
            {/* Schedule Info */}
            <GlassCard variant="strong" className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                    <Clock className="w-6 h-6 text-primary" />
                  </div>
                  <div>
                    <p className="font-semibold">{selectedSchedule.date}</p>
                    <p className="text-sm text-muted-foreground">{selectedSchedule.time}</p>
                  </div>
                </div>
              </div>
            </GlassCard>

            {/* Ticket Types */}
            <GlassCard variant="strong" className="p-6">
              <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
                <Ticket className="w-5 h-5 text-primary" />
                Chọn loại vé
              </h2>

              <div className="space-y-4">
                {eventData.ticketTypes.map((ticket) => (
                  <div
                    key={ticket.id}
                    className={`p-4 rounded-xl border-2 transition-all ${
                      (quantities[ticket.id] || 0) > 0
                        ? "border-primary bg-primary/5"
                        : "border-transparent glass"
                    }`}
                  >
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className="font-semibold">{ticket.name}</h3>
                          {ticket.available < 50 && (
                            <span className="text-xs px-2 py-0.5 rounded-full bg-warning/20 text-warning">
                              Còn ít
                            </span>
                          )}
                        </div>
                        <p className="text-sm text-muted-foreground mb-2">{ticket.description}</p>
                        <p className="text-lg font-bold text-primary">{formatPrice(ticket.price)}</p>
                        <p className="text-xs text-muted-foreground">
                          Còn {ticket.available} vé • Tối đa {ticket.maxQty} vé/đơn
                        </p>
                      </div>

                      {/* Quantity Selector */}
                      <div className="flex items-center gap-3">
                        <button
                          onClick={() => updateQuantity(ticket.id, -1)}
                          disabled={(quantities[ticket.id] || 0) === 0}
                          className="w-10 h-10 rounded-xl glass flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed hover:bg-accent/50 transition-colors"
                        >
                          <Minus className="w-5 h-5" />
                        </button>
                        <span className="w-12 text-center font-semibold text-lg">
                          {quantities[ticket.id] || 0}
                        </span>
                        <button
                          onClick={() => updateQuantity(ticket.id, 1)}
                          disabled={(quantities[ticket.id] || 0) >= ticket.maxQty}
                          className="w-10 h-10 rounded-xl glass flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed hover:bg-accent/50 transition-colors"
                        >
                          <Plus className="w-5 h-5" />
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </GlassCard>

            {/* Seat Map (if applicable) */}
            {eventData.hasSeatMap && (
              <GlassCard variant="strong" className="p-6">
                <h2 className="text-lg font-semibold mb-4">Sơ đồ chỗ ngồi</h2>
                <div className="aspect-video bg-muted/50 rounded-xl flex items-center justify-center">
                  <p className="text-muted-foreground">Sơ đồ chỗ ngồi sẽ hiển thị ở đây</p>
                </div>
              </GlassCard>
            )}
          </div>

          {/* Order Summary - Sticky */}
          <div className="lg:col-span-1">
            <div className="sticky top-24 space-y-4">
              {/* Countdown Timer */}
              {hasSelection && (
                <GlassCard className="p-4 border-2 border-warning/50 bg-warning/10">
                  <div className="flex items-center gap-3">
                    <AlertCircle className="w-5 h-5 text-warning" />
                    <div>
                      <p className="text-sm font-medium">Thời gian giữ vé</p>
                      <p className="text-2xl font-bold text-warning">{formatTime(timeLeft)}</p>
                    </div>
                  </div>
                </GlassCard>
              )}

              {/* Order Summary */}
              <GlassCard variant="strong" className="p-6">
                <h3 className="font-semibold mb-4">Đơn hàng của bạn</h3>

                {/* Event Thumbnail */}
                <div className="flex gap-3 mb-4 pb-4 border-b border-border">
                  <img
                    src={eventData.image}
                    alt={eventData.title}
                    className="w-16 h-16 rounded-xl object-cover"
                  />
                  <div className="flex-1">
                    <p className="font-medium text-sm line-clamp-2">{eventData.title}</p>
                    <p className="text-xs text-muted-foreground mt-1">{selectedSchedule.date}</p>
                  </div>
                </div>

                {/* Selected Tickets */}
                {hasSelection ? (
                  <div className="space-y-3 mb-4">
                    {eventData.ticketTypes.map((ticket) => {
                      const qty = quantities[ticket.id] || 0;
                      if (qty === 0) return null;
                      return (
                        <div key={ticket.id} className="flex justify-between text-sm">
                          <span>
                            {ticket.name} x {qty}
                          </span>
                          <span className="font-medium">{formatPrice(ticket.price * qty)}</span>
                        </div>
                      );
                    })}
                  </div>
                ) : (
                  <div className="py-8 text-center text-muted-foreground">
                    <Ticket className="w-12 h-12 mx-auto mb-2 opacity-30" />
                    <p className="text-sm">Chưa chọn vé nào</p>
                  </div>
                )}

                {/* Total */}
                {hasSelection && (
                  <div className="flex justify-between items-center py-4 border-t border-border">
                    <span className="font-medium">Tổng cộng</span>
                    <span className="text-2xl font-bold text-primary">{formatPrice(totalAmount)}</span>
                  </div>
                )}

                {/* Continue Button */}
                <Link to={hasSelection ? `/events/${id}/checkout` : "#"}>
                  <GradientButton
                    className="w-full h-12 mt-4"
                    disabled={!hasSelection}
                  >
                    Tiếp tục
                    <ArrowRight className="w-5 h-5" />
                  </GradientButton>
                </Link>
              </GlassCard>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
};

export default TicketSelection;
