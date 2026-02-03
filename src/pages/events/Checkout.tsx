import { useState } from "react";
import { useParams, Link } from "react-router-dom";
import { MainLayout } from "@/components/layout";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { 
  ArrowLeft,
  ArrowRight,
  CreditCard,
  Wallet,
  Building2,
  Tag,
  Check,
  Ticket,
  Truck,
  Mail
} from "lucide-react";

// Mock data
const orderData = {
  event: {
    id: "1",
    title: "Đêm nhạc Acoustic - Những bản tình ca",
    image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800",
    date: "15/02/2026",
    time: "19:00 - 22:00",
    location: "Nhà hát Thành phố, Quận 1, TP.HCM",
  },
  tickets: [
    { name: "Vé VIP", quantity: 2, price: 750000 },
    { name: "Vé thường", quantity: 1, price: 350000 },
  ],
};

const paymentMethods = [
  { id: "momo", name: "Ví MoMo", icon: Wallet, color: "bg-pink-500" },
  { id: "vnpay", name: "VNPay", icon: CreditCard, color: "bg-blue-500" },
  { id: "zalopay", name: "ZaloPay", icon: Wallet, color: "bg-blue-600" },
  { id: "bank", name: "Chuyển khoản", icon: Building2, color: "bg-green-500" },
  { id: "visa", name: "Visa/Mastercard", icon: CreditCard, color: "bg-purple-500" },
];

const deliveryOptions = [
  { id: "electronic", name: "Vé điện tử (E-ticket)", description: "Nhận vé qua email ngay sau thanh toán", price: 0 },
  { id: "physical", name: "Vé giấy", description: "Giao tận nơi trong 3-5 ngày làm việc", price: 30000 },
];

const Checkout = () => {
  const { id } = useParams();
  const [paymentMethod, setPaymentMethod] = useState("");
  const [deliveryOption, setDeliveryOption] = useState("electronic");
  const [promoCode, setPromoCode] = useState("");
  const [promoApplied, setPromoApplied] = useState(false);
  const [shippingInfo, setShippingInfo] = useState({
    fullName: "",
    phone: "",
    address: "",
    city: "",
    district: "",
    ward: "",
  });

  const subtotal = orderData.tickets.reduce((sum, t) => sum + t.price * t.quantity, 0);
  const deliveryFee = deliveryOption === "physical" ? 30000 : 0;
  const discount = promoApplied ? 100000 : 0;
  const total = subtotal + deliveryFee - discount;

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(price);
  };

  const applyPromoCode = () => {
    if (promoCode.toUpperCase() === "GIAM100K") {
      setPromoApplied(true);
    }
  };

  const handleSubmit = () => {
    console.log("Checkout:", { paymentMethod, deliveryOption, shippingInfo });
    window.location.href = `/events/${id}/confirmation`;
  };

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8 max-w-5xl">
        {/* Header */}
        <div className="mb-8">
          <Link 
            to={`/events/${id}/tickets`}
            className="inline-flex items-center gap-2 text-muted-foreground hover:text-foreground mb-4"
          >
            <ArrowLeft className="w-4 h-4" />
            Quay lại chọn vé
          </Link>
          <h1 className="text-2xl md:text-3xl font-bold mb-2">Thanh toán</h1>
          <p className="text-muted-foreground">Hoàn tất đơn hàng của bạn</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Delivery Options */}
            <GlassCard variant="strong" className="p-6">
              <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
                <Ticket className="w-5 h-5 text-primary" />
                Hình thức nhận vé
              </h2>
              <div className="space-y-3">
                {deliveryOptions.map((option) => (
                  <button
                    key={option.id}
                    onClick={() => setDeliveryOption(option.id)}
                    className={`w-full p-4 rounded-xl text-left transition-all ${
                      deliveryOption === option.id
                        ? "border-2 border-primary bg-primary/5"
                        : "glass border-2 border-transparent hover:bg-accent/50"
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                          deliveryOption === option.id ? "border-primary bg-primary" : "border-muted-foreground"
                        }`}>
                          {deliveryOption === option.id && <Check className="w-3 h-3 text-white" />}
                        </div>
                        <div>
                          <p className="font-medium">{option.name}</p>
                          <p className="text-sm text-muted-foreground">{option.description}</p>
                        </div>
                      </div>
                      <span className="font-medium">
                        {option.price === 0 ? "Miễn phí" : formatPrice(option.price)}
                      </span>
                    </div>
                  </button>
                ))}
              </div>
            </GlassCard>

            {/* Shipping Address (for physical tickets) */}
            {deliveryOption === "physical" && (
              <GlassCard variant="strong" className="p-6">
                <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
                  <Truck className="w-5 h-5 text-primary" />
                  Địa chỉ giao hàng
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Họ và tên</Label>
                    <Input
                      placeholder="Nguyễn Văn A"
                      className="h-11 rounded-xl"
                      value={shippingInfo.fullName}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, fullName: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Số điện thoại</Label>
                    <Input
                      placeholder="0901234567"
                      className="h-11 rounded-xl"
                      value={shippingInfo.phone}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, phone: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Tỉnh/Thành phố</Label>
                    <select 
                      className="w-full h-11 rounded-xl border border-input bg-background px-3"
                      value={shippingInfo.city}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, city: e.target.value })}
                    >
                      <option value="">Chọn tỉnh/thành</option>
                      <option value="hcm">TP. Hồ Chí Minh</option>
                      <option value="hanoi">Hà Nội</option>
                      <option value="danang">Đà Nẵng</option>
                    </select>
                  </div>
                  <div className="space-y-2">
                    <Label>Quận/Huyện</Label>
                    <select 
                      className="w-full h-11 rounded-xl border border-input bg-background px-3"
                      value={shippingInfo.district}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, district: e.target.value })}
                    >
                      <option value="">Chọn quận/huyện</option>
                      <option value="q1">Quận 1</option>
                      <option value="q3">Quận 3</option>
                      <option value="q7">Quận 7</option>
                    </select>
                  </div>
                  <div className="md:col-span-2 space-y-2">
                    <Label>Địa chỉ cụ thể</Label>
                    <Input
                      placeholder="Số nhà, tên đường..."
                      className="h-11 rounded-xl"
                      value={shippingInfo.address}
                      onChange={(e) => setShippingInfo({ ...shippingInfo, address: e.target.value })}
                    />
                  </div>
                </div>
              </GlassCard>
            )}

            {/* Payment Methods */}
            <GlassCard variant="strong" className="p-6">
              <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
                <CreditCard className="w-5 h-5 text-primary" />
                Phương thức thanh toán
              </h2>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                {paymentMethods.map((method) => (
                  <button
                    key={method.id}
                    onClick={() => setPaymentMethod(method.id)}
                    className={`p-4 rounded-xl text-center transition-all ${
                      paymentMethod === method.id
                        ? "border-2 border-primary bg-primary/5"
                        : "glass border-2 border-transparent hover:bg-accent/50"
                    }`}
                  >
                    <div className={`w-12 h-12 rounded-xl ${method.color} flex items-center justify-center mx-auto mb-2`}>
                      <method.icon className="w-6 h-6 text-white" />
                    </div>
                    <p className="text-sm font-medium">{method.name}</p>
                  </button>
                ))}
              </div>
            </GlassCard>

            {/* Promo Code */}
            <GlassCard variant="strong" className="p-6">
              <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
                <Tag className="w-5 h-5 text-primary" />
                Mã giảm giá
              </h2>
              <div className="flex gap-3">
                <Input
                  placeholder="Nhập mã giảm giá"
                  className="h-11 rounded-xl flex-1"
                  value={promoCode}
                  onChange={(e) => setPromoCode(e.target.value)}
                  disabled={promoApplied}
                />
                <GradientButton
                  onClick={applyPromoCode}
                  variant={promoApplied ? "secondary" : "default"}
                  className="h-11"
                  disabled={promoApplied || !promoCode}
                >
                  {promoApplied ? (
                    <>
                      <Check className="w-4 h-4" />
                      Đã áp dụng
                    </>
                  ) : (
                    "Áp dụng"
                  )}
                </GradientButton>
              </div>
              {promoApplied && (
                <p className="text-sm text-green-500 mt-2">
                  🎉 Giảm {formatPrice(discount)} cho đơn hàng này
                </p>
              )}
            </GlassCard>
          </div>

          {/* Order Summary - Sticky */}
          <div className="lg:col-span-1">
            <div className="sticky top-24">
              <GlassCard variant="strong" className="p-6">
                <h3 className="font-semibold mb-4">Đơn hàng của bạn</h3>

                {/* Event Info */}
                <div className="flex gap-3 mb-4 pb-4 border-b border-border">
                  <img
                    src={orderData.event.image}
                    alt={orderData.event.title}
                    className="w-16 h-16 rounded-xl object-cover"
                  />
                  <div className="flex-1">
                    <p className="font-medium text-sm line-clamp-2">{orderData.event.title}</p>
                    <p className="text-xs text-muted-foreground mt-1">{orderData.event.date}</p>
                  </div>
                </div>

                {/* Tickets */}
                <div className="space-y-2 mb-4 pb-4 border-b border-border">
                  {orderData.tickets.map((ticket, i) => (
                    <div key={i} className="flex justify-between text-sm">
                      <span>{ticket.name} x {ticket.quantity}</span>
                      <span>{formatPrice(ticket.price * ticket.quantity)}</span>
                    </div>
                  ))}
                </div>

                {/* Pricing */}
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Tạm tính</span>
                    <span>{formatPrice(subtotal)}</span>
                  </div>
                  {deliveryFee > 0 && (
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Phí giao hàng</span>
                      <span>{formatPrice(deliveryFee)}</span>
                    </div>
                  )}
                  {promoApplied && (
                    <div className="flex justify-between text-green-500">
                      <span>Giảm giá</span>
                      <span>-{formatPrice(discount)}</span>
                    </div>
                  )}
                </div>

                {/* Total */}
                <div className="flex justify-between items-center py-4 border-t border-border mt-4">
                  <span className="font-medium">Tổng cộng</span>
                  <span className="text-2xl font-bold text-primary">{formatPrice(total)}</span>
                </div>

                {/* Email Notice */}
                <div className="flex items-start gap-2 p-3 rounded-xl bg-muted/50 mb-4">
                  <Mail className="w-5 h-5 text-muted-foreground mt-0.5" />
                  <p className="text-xs text-muted-foreground">
                    Vé sẽ được gửi đến email đăng ký của bạn sau khi thanh toán thành công
                  </p>
                </div>

                {/* Pay Button */}
                <GradientButton
                  onClick={handleSubmit}
                  className="w-full h-12"
                  disabled={!paymentMethod}
                >
                  Thanh toán {formatPrice(total)}
                  <ArrowRight className="w-5 h-5" />
                </GradientButton>
              </GlassCard>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
};

export default Checkout;
