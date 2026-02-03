import { useState } from "react";
import { useParams, Link } from "react-router-dom";
import { MainLayout } from "@/components/layout";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { 
  Calendar, 
  MapPin, 
  Clock, 
  Users, 
  Share2, 
  Heart, 
  Ticket,
  ChevronRight,
  Lock,
  Building2,
  Info
} from "lucide-react";

// Mock event data
const eventData = {
  id: "1",
  title: "Đêm nhạc Acoustic - Những bản tình ca",
  description: `Đêm nhạc Acoustic là sự kiện âm nhạc trực tiếp quy tụ những nghệ sĩ tài năng nhất Việt Nam. Với không gian ấm cúng và âm thanh chất lượng cao, đây sẽ là trải nghiệm âm nhạc đáng nhớ dành cho bạn.

Chương trình bao gồm:
• Các ca khúc acoustic nổi tiếng
• Giao lưu với nghệ sĩ
• Cocktail welcome drink
• Quà tặng cho 50 khách đầu tiên`,
  image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=1200",
  bannerImage: "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=1920",
  category: "Âm nhạc",
  location: "Nhà hát Thành phố",
  address: "7 Công trường Lam Sơn, Quận 1, TP. Hồ Chí Minh",
  attendees: 1250,
  isPrivate: false,
  organizer: {
    name: "Ticketbox Entertainment",
    logo: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=200",
    description: "Đơn vị tổ chức sự kiện hàng đầu Việt Nam với hơn 10 năm kinh nghiệm.",
  },
  schedules: [
    { id: "s1", date: "15/02/2026", time: "19:00 - 22:00", status: "available" },
    { id: "s2", date: "16/02/2026", time: "19:00 - 22:00", status: "available" },
    { id: "s3", date: "17/02/2026", time: "19:00 - 22:00", status: "soldout" },
  ],
  ticketTypes: [
    { id: "t1", name: "Vé thường", price: 350000, available: 500, description: "Ghế ngồi khu vực B, C" },
    { id: "t2", name: "Vé VIP", price: 750000, available: 100, description: "Ghế ngồi khu vực A, bao gồm đồ uống" },
    { id: "t3", name: "Vé VVIP", price: 1500000, available: 20, description: "Ghế ngồi hàng đầu, giao lưu với nghệ sĩ" },
  ],
};

const EventDetail = () => {
  const { id } = useParams();
  const [selectedSchedule, setSelectedSchedule] = useState(eventData.schedules[0]);
  const [showPrivateDialog, setShowPrivateDialog] = useState(false);
  const [accessCode, setAccessCode] = useState("");
  const [isLiked, setIsLiked] = useState(false);

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(price);
  };

  const handleBuyTicket = () => {
    if (eventData.isPrivate) {
      setShowPrivateDialog(true);
    } else {
      // Navigate to ticket selection
      window.location.href = `/events/${id}/tickets?schedule=${selectedSchedule.id}`;
    }
  };

  const handleAccessCodeSubmit = () => {
    // Validate access code
    if (accessCode === "TEST123") {
      setShowPrivateDialog(false);
      window.location.href = `/events/${id}/tickets?schedule=${selectedSchedule.id}`;
    }
  };

  return (
    <MainLayout>
      {/* Banner */}
      <div className="relative h-[50vh] md:h-[60vh] -mt-20">
        <img
          src={eventData.bannerImage}
          alt={eventData.title}
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-background via-background/50 to-transparent" />
      </div>

      <div className="container mx-auto px-4 -mt-32 relative z-10 pb-20">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Event Info Card */}
            <GlassCard variant="strong" className="p-6 md:p-8">
              {/* Category & Actions */}
              <div className="flex items-center justify-between mb-4">
                <span className="px-4 py-1.5 rounded-full text-sm font-medium bg-primary/10 text-primary">
                  {eventData.category}
                </span>
                <div className="flex items-center gap-2">
                  <button 
                    onClick={() => setIsLiked(!isLiked)}
                    className={`p-2 rounded-xl glass ${isLiked ? 'text-red-500' : 'text-muted-foreground'}`}
                  >
                    <Heart className={`w-5 h-5 ${isLiked ? 'fill-current' : ''}`} />
                  </button>
                  <button className="p-2 rounded-xl glass text-muted-foreground">
                    <Share2 className="w-5 h-5" />
                  </button>
                </div>
              </div>

              {/* Title */}
              <h1 className="text-2xl md:text-4xl font-bold mb-6">
                {eventData.title}
              </h1>

              {/* Quick Info */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-8">
                <div className="flex items-center gap-3 text-muted-foreground">
                  <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                    <MapPin className="w-5 h-5 text-primary" />
                  </div>
                  <div>
                    <p className="font-medium text-foreground">{eventData.location}</p>
                    <p className="text-sm">{eventData.address}</p>
                  </div>
                </div>
                <div className="flex items-center gap-3 text-muted-foreground">
                  <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                    <Users className="w-5 h-5 text-primary" />
                  </div>
                  <div>
                    <p className="font-medium text-foreground">{eventData.attendees.toLocaleString()}</p>
                    <p className="text-sm">người quan tâm</p>
                  </div>
                </div>
              </div>

              {/* Description */}
              <div className="prose prose-sm max-w-none">
                <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                  <Info className="w-5 h-5 text-primary" />
                  Giới thiệu sự kiện
                </h3>
                <div className="text-muted-foreground whitespace-pre-line">
                  {eventData.description}
                </div>
              </div>
            </GlassCard>

            {/* Organizer */}
            <GlassCard variant="strong" className="p-6">
              <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
                <Building2 className="w-5 h-5 text-primary" />
                Ban tổ chức
              </h3>
              <div className="flex items-start gap-4">
                <img
                  src={eventData.organizer.logo}
                  alt={eventData.organizer.name}
                  className="w-16 h-16 rounded-xl object-cover"
                />
                <div>
                  <h4 className="font-semibold">{eventData.organizer.name}</h4>
                  <p className="text-sm text-muted-foreground mt-1">
                    {eventData.organizer.description}
                  </p>
                </div>
              </div>
            </GlassCard>

            {/* Ticket Types */}
            <GlassCard variant="strong" className="p-6">
              <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
                <Ticket className="w-5 h-5 text-primary" />
                Loại vé
              </h3>
              <div className="space-y-3">
                {eventData.ticketTypes.map((ticket) => (
                  <div
                    key={ticket.id}
                    className="flex items-center justify-between p-4 rounded-xl glass"
                  >
                    <div>
                      <h4 className="font-semibold">{ticket.name}</h4>
                      <p className="text-sm text-muted-foreground">{ticket.description}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-bold text-lg text-primary">
                        {formatPrice(ticket.price)}
                      </p>
                      <p className="text-sm text-muted-foreground">
                        Còn {ticket.available} vé
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </GlassCard>
          </div>

          {/* Sidebar - Sticky */}
          <div className="lg:col-span-1">
            <div className="sticky top-24">
              <GlassCard variant="strong" className="p-6">
                {/* Schedule Selection */}
                <h3 className="font-semibold mb-4 flex items-center gap-2">
                  <Calendar className="w-5 h-5 text-primary" />
                  Chọn lịch diễn
                </h3>
                <div className="space-y-2 mb-6">
                  {eventData.schedules.map((schedule) => (
                    <button
                      key={schedule.id}
                      onClick={() => schedule.status !== "soldout" && setSelectedSchedule(schedule)}
                      disabled={schedule.status === "soldout"}
                      className={`w-full p-4 rounded-xl text-left transition-all ${
                        selectedSchedule.id === schedule.id
                          ? "bg-primary text-primary-foreground"
                          : schedule.status === "soldout"
                          ? "bg-muted text-muted-foreground cursor-not-allowed opacity-50"
                          : "glass hover:bg-accent/50"
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <Calendar className="w-5 h-5" />
                          <span className="font-medium">{schedule.date}</span>
                        </div>
                        {schedule.status === "soldout" && (
                          <span className="text-xs px-2 py-1 rounded-full bg-destructive/20 text-destructive">
                            Hết vé
                          </span>
                        )}
                      </div>
                      <div className="flex items-center gap-2 mt-1 ml-8 text-sm opacity-80">
                        <Clock className="w-4 h-4" />
                        {schedule.time}
                      </div>
                    </button>
                  ))}
                </div>

                {/* Price Range */}
                <div className="flex items-center justify-between py-4 border-y border-border">
                  <span className="text-muted-foreground">Giá từ</span>
                  <span className="text-2xl font-bold text-primary">
                    {formatPrice(Math.min(...eventData.ticketTypes.map((t) => t.price)))}
                  </span>
                </div>

                {/* Buy Button */}
                <GradientButton
                  onClick={handleBuyTicket}
                  className="w-full h-14 text-lg mt-6"
                  disabled={selectedSchedule.status === "soldout"}
                >
                  {eventData.isPrivate && <Lock className="w-5 h-5" />}
                  Mua vé ngay
                  <ChevronRight className="w-5 h-5" />
                </GradientButton>

                {eventData.isPrivate && (
                  <p className="text-sm text-muted-foreground text-center mt-3">
                    🔒 Sự kiện này yêu cầu mã truy cập
                  </p>
                )}
              </GlassCard>
            </div>
          </div>
        </div>
      </div>

      {/* Private Event Access Dialog */}
      <Dialog open={showPrivateDialog} onOpenChange={setShowPrivateDialog}>
        <DialogContent className="glass-strong">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Lock className="w-5 h-5 text-primary" />
              Nhập mã truy cập
            </DialogTitle>
            <DialogDescription>
              Đây là sự kiện riêng tư. Vui lòng nhập mã truy cập để tiếp tục mua vé.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 mt-4">
            <Input
              type="text"
              placeholder="Nhập mã truy cập"
              value={accessCode}
              onChange={(e) => setAccessCode(e.target.value)}
              className="h-12 rounded-xl text-center text-lg tracking-widest"
            />
            <GradientButton
              onClick={handleAccessCodeSubmit}
              className="w-full h-12"
            >
              Xác nhận
            </GradientButton>
          </div>
        </DialogContent>
      </Dialog>
    </MainLayout>
  );
};

export default EventDetail;
