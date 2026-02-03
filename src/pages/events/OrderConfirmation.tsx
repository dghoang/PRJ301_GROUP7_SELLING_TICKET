import { Link } from "react-router-dom";
import { MainLayout } from "@/components/layout";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { 
  CheckCircle2, 
  Download, 
  Calendar, 
  Clock, 
  MapPin,
  Mail,
  Ticket,
  ArrowRight,
  Truck
} from "lucide-react";

// Mock order data
const orderData = {
  orderId: "TB2026021501234",
  event: {
    title: "Đêm nhạc Acoustic - Những bản tình ca",
    image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800",
    date: "15/02/2026",
    time: "19:00 - 22:00",
    location: "Nhà hát Thành phố, Quận 1, TP.HCM",
  },
  tickets: [
    { name: "Vé VIP", quantity: 2, price: 750000, seats: ["A5", "A6"] },
    { name: "Vé thường", quantity: 1, price: 350000, seats: ["B12"] },
  ],
  deliveryType: "electronic",
  total: 1850000,
  paymentMethod: "MoMo",
  email: "user@example.com",
  qrCode: "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=TB2026021501234",
};

const OrderConfirmation = () => {
  const formatPrice = (price: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(price);
  };

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8 max-w-3xl">
        {/* Success Header */}
        <div className="text-center mb-8">
          <div className="w-20 h-20 rounded-full bg-green-500/10 flex items-center justify-center mx-auto mb-6">
            <CheckCircle2 className="w-10 h-10 text-green-500" />
          </div>
          <h1 className="text-2xl md:text-3xl font-bold mb-2">Đặt vé thành công!</h1>
          <p className="text-muted-foreground">
            Mã đơn hàng: <span className="font-semibold text-foreground">{orderData.orderId}</span>
          </p>
        </div>

        {/* Email Notification */}
        <GlassCard className="p-4 mb-6 border-2 border-green-500/30 bg-green-500/10">
          <div className="flex items-center gap-3">
            <Mail className="w-5 h-5 text-green-500" />
            <p className="text-sm">
              Chúng tôi đã gửi xác nhận đơn hàng và vé điện tử đến <strong>{orderData.email}</strong>
            </p>
          </div>
        </GlassCard>

        {/* Order Details */}
        <GlassCard variant="strong" className="p-6 mb-6">
          {/* Event Info */}
          <div className="flex gap-4 pb-6 border-b border-border">
            <img
              src={orderData.event.image}
              alt={orderData.event.title}
              className="w-24 h-24 rounded-xl object-cover"
            />
            <div>
              <h2 className="font-semibold text-lg mb-2">{orderData.event.title}</h2>
              <div className="space-y-1 text-sm text-muted-foreground">
                <div className="flex items-center gap-2">
                  <Calendar className="w-4 h-4" />
                  {orderData.event.date}
                </div>
                <div className="flex items-center gap-2">
                  <Clock className="w-4 h-4" />
                  {orderData.event.time}
                </div>
                <div className="flex items-center gap-2">
                  <MapPin className="w-4 h-4" />
                  {orderData.event.location}
                </div>
              </div>
            </div>
          </div>

          {/* Tickets */}
          <div className="py-6 border-b border-border">
            <h3 className="font-semibold mb-4 flex items-center gap-2">
              <Ticket className="w-5 h-5 text-primary" />
              Vé của bạn
            </h3>
            <div className="space-y-3">
              {orderData.tickets.map((ticket, i) => (
                <div key={i} className="flex justify-between items-start glass p-4 rounded-xl">
                  <div>
                    <p className="font-medium">{ticket.name}</p>
                    <p className="text-sm text-muted-foreground">
                      Số lượng: {ticket.quantity} • Ghế: {ticket.seats.join(", ")}
                    </p>
                  </div>
                  <p className="font-semibold">{formatPrice(ticket.price * ticket.quantity)}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Delivery Info */}
          <div className="py-6 border-b border-border">
            <h3 className="font-semibold mb-3 flex items-center gap-2">
              {orderData.deliveryType === "electronic" ? (
                <Mail className="w-5 h-5 text-primary" />
              ) : (
                <Truck className="w-5 h-5 text-primary" />
              )}
              Hình thức nhận vé
            </h3>
            <p className="text-muted-foreground">
              {orderData.deliveryType === "electronic" 
                ? "Vé điện tử - Đã gửi qua email" 
                : "Vé giấy - Đang vận chuyển"
              }
            </p>
          </div>

          {/* QR Code */}
          <div className="py-6 border-b border-border text-center">
            <h3 className="font-semibold mb-4">Mã QR Check-in</h3>
            <img
              src={orderData.qrCode}
              alt="QR Code"
              className="w-48 h-48 mx-auto rounded-xl bg-white p-2"
            />
            <p className="text-sm text-muted-foreground mt-4">
              Xuất trình mã QR này tại cổng check-in
            </p>
          </div>

          {/* Total */}
          <div className="pt-6 flex justify-between items-center">
            <div>
              <p className="text-sm text-muted-foreground">Tổng thanh toán</p>
              <p className="text-sm text-muted-foreground">Thanh toán qua: {orderData.paymentMethod}</p>
            </div>
            <p className="text-2xl font-bold text-primary">{formatPrice(orderData.total)}</p>
          </div>
        </GlassCard>

        {/* Actions */}
        <div className="flex flex-col sm:flex-row gap-4">
          <GradientButton className="flex-1 h-12">
            <Download className="w-5 h-5" />
            Tải vé PDF
          </GradientButton>
          <Link to="/profile/orders" className="flex-1">
            <GradientButton variant="secondary" className="w-full h-12">
              Xem đơn hàng
              <ArrowRight className="w-5 h-5" />
            </GradientButton>
          </Link>
        </div>

        {/* Back to home */}
        <div className="text-center mt-8">
          <Link to="/" className="text-sm text-muted-foreground hover:text-foreground">
            ← Quay về trang chủ
          </Link>
        </div>
      </div>
    </MainLayout>
  );
};

export default OrderConfirmation;
