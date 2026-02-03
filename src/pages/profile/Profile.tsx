import { useState } from "react";
import { MainLayout } from "@/components/layout";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { 
  User, 
  Ticket, 
  ShoppingBag, 
  Settings, 
  Lock, 
  Mail,
  Phone,
  Calendar,
  Edit2,
  Save,
  ChevronRight,
  QrCode,
  Clock,
  MapPin
} from "lucide-react";
import { Link } from "react-router-dom";

// Mock user data
const userData = {
  id: "u1",
  fullName: "Nguyễn Văn A",
  email: "nguyenvana@email.com",
  phone: "0901234567",
  birthDate: "1995-05-15",
  gender: "male",
  avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200",
};

// Mock orders
const orders = [
  {
    id: "TB2026021501234",
    event: "Đêm nhạc Acoustic - Những bản tình ca",
    date: "15/02/2026",
    tickets: 3,
    total: 1850000,
    status: "confirmed",
  },
  {
    id: "TB2026011587654",
    event: "Workshop UI/UX Design",
    date: "20/01/2026",
    tickets: 1,
    total: 500000,
    status: "completed",
  },
];

// Mock tickets
const myTickets = [
  {
    id: "t1",
    event: "Đêm nhạc Acoustic - Những bản tình ca",
    image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400",
    date: "15/02/2026",
    time: "19:00",
    location: "Nhà hát Thành phố",
    ticketType: "Vé VIP",
    seat: "A5",
    status: "upcoming",
  },
  {
    id: "t2",
    event: "Workshop UI/UX Design",
    image: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400",
    date: "20/01/2026",
    time: "09:00",
    location: "Dreamplex, Quận 3",
    ticketType: "Vé thường",
    seat: "C12",
    status: "used",
  },
];

type TabType = "profile" | "orders" | "tickets" | "security";

const Profile = () => {
  const [activeTab, setActiveTab] = useState<TabType>("profile");
  const [isEditing, setIsEditing] = useState(false);
  const [profileData, setProfileData] = useState(userData);

  const tabs = [
    { id: "profile" as TabType, label: "Thông tin cá nhân", icon: User },
    { id: "orders" as TabType, label: "Lịch sử đơn hàng", icon: ShoppingBag },
    { id: "tickets" as TabType, label: "Vé của tôi", icon: Ticket },
    { id: "security" as TabType, label: "Bảo mật", icon: Lock },
  ];

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(price);
  };

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Sidebar */}
          <div className="lg:col-span-1">
            <GlassCard variant="strong" className="p-6">
              {/* User Info */}
              <div className="text-center mb-6 pb-6 border-b border-border">
                <img
                  src={profileData.avatar}
                  alt={profileData.fullName}
                  className="w-20 h-20 rounded-full mx-auto mb-4 object-cover"
                />
                <h2 className="font-semibold text-lg">{profileData.fullName}</h2>
                <p className="text-sm text-muted-foreground">{profileData.email}</p>
              </div>

              {/* Navigation */}
              <nav className="space-y-1">
                {tabs.map((tab) => (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-all ${
                      activeTab === tab.id
                        ? "bg-primary text-primary-foreground"
                        : "hover:bg-muted/50 text-muted-foreground"
                    }`}
                  >
                    <tab.icon className="w-5 h-5" />
                    <span className="font-medium">{tab.label}</span>
                  </button>
                ))}
              </nav>
            </GlassCard>
          </div>

          {/* Main Content */}
          <div className="lg:col-span-3">
            {/* Profile Tab */}
            {activeTab === "profile" && (
              <GlassCard variant="strong" className="p-6">
                <div className="flex items-center justify-between mb-6">
                  <h2 className="text-xl font-semibold">Thông tin cá nhân</h2>
                  <GradientButton
                    variant={isEditing ? "default" : "secondary"}
                    size="sm"
                    onClick={() => setIsEditing(!isEditing)}
                  >
                    {isEditing ? (
                      <>
                        <Save className="w-4 h-4" />
                        Lưu
                      </>
                    ) : (
                      <>
                        <Edit2 className="w-4 h-4" />
                        Chỉnh sửa
                      </>
                    )}
                  </GradientButton>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <Label>Họ và tên</Label>
                    <div className="relative">
                      <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                      <Input
                        className="pl-10 h-11 rounded-xl"
                        value={profileData.fullName}
                        onChange={(e) => setProfileData({ ...profileData, fullName: e.target.value })}
                        disabled={!isEditing}
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label>Email</Label>
                    <div className="relative">
                      <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                      <Input
                        className="pl-10 h-11 rounded-xl"
                        value={profileData.email}
                        disabled
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label>Số điện thoại</Label>
                    <div className="relative">
                      <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                      <Input
                        className="pl-10 h-11 rounded-xl"
                        value={profileData.phone}
                        onChange={(e) => setProfileData({ ...profileData, phone: e.target.value })}
                        disabled={!isEditing}
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label>Ngày sinh</Label>
                    <div className="relative">
                      <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                      <Input
                        type="date"
                        className="pl-10 h-11 rounded-xl"
                        value={profileData.birthDate}
                        onChange={(e) => setProfileData({ ...profileData, birthDate: e.target.value })}
                        disabled={!isEditing}
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label>Giới tính</Label>
                    <select
                      className="w-full h-11 rounded-xl border border-input bg-background px-3"
                      value={profileData.gender}
                      onChange={(e) => setProfileData({ ...profileData, gender: e.target.value })}
                      disabled={!isEditing}
                    >
                      <option value="male">Nam</option>
                      <option value="female">Nữ</option>
                      <option value="other">Khác</option>
                    </select>
                  </div>
                </div>
              </GlassCard>
            )}

            {/* Orders Tab */}
            {activeTab === "orders" && (
              <GlassCard variant="strong" className="p-6">
                <h2 className="text-xl font-semibold mb-6">Lịch sử đơn hàng</h2>
                <div className="space-y-4">
                  {orders.map((order) => (
                    <div key={order.id} className="glass p-4 rounded-xl">
                      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                        <div>
                          <p className="font-semibold">{order.event}</p>
                          <p className="text-sm text-muted-foreground">
                            Mã đơn: {order.id} • {order.date}
                          </p>
                          <p className="text-sm text-muted-foreground">
                            {order.tickets} vé • {formatPrice(order.total)}
                          </p>
                        </div>
                        <div className="flex items-center gap-3">
                          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                            order.status === "confirmed" 
                              ? "bg-green-500/20 text-green-500" 
                              : "bg-muted text-muted-foreground"
                          }`}>
                            {order.status === "confirmed" ? "Đã xác nhận" : "Đã hoàn thành"}
                          </span>
                          <GradientButton variant="ghost" size="sm">
                            Chi tiết
                            <ChevronRight className="w-4 h-4" />
                          </GradientButton>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </GlassCard>
            )}

            {/* Tickets Tab */}
            {activeTab === "tickets" && (
              <div className="space-y-6">
                <h2 className="text-xl font-semibold">Vé của tôi</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {myTickets.map((ticket) => (
                    <GlassCard key={ticket.id} variant="strong" className="overflow-hidden">
                      <img
                        src={ticket.image}
                        alt={ticket.event}
                        className="w-full h-32 object-cover"
                      />
                      <div className="p-4">
                        <div className="flex items-start justify-between mb-3">
                          <h3 className="font-semibold line-clamp-2">{ticket.event}</h3>
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                            ticket.status === "upcoming" 
                              ? "bg-primary/20 text-primary" 
                              : "bg-muted text-muted-foreground"
                          }`}>
                            {ticket.status === "upcoming" ? "Sắp diễn ra" : "Đã sử dụng"}
                          </span>
                        </div>
                        <div className="space-y-1 text-sm text-muted-foreground mb-4">
                          <div className="flex items-center gap-2">
                            <Calendar className="w-4 h-4" />
                            {ticket.date}
                          </div>
                          <div className="flex items-center gap-2">
                            <Clock className="w-4 h-4" />
                            {ticket.time}
                          </div>
                          <div className="flex items-center gap-2">
                            <MapPin className="w-4 h-4" />
                            {ticket.location}
                          </div>
                        </div>
                        <div className="flex items-center justify-between pt-3 border-t border-border">
                          <div>
                            <p className="text-xs text-muted-foreground">{ticket.ticketType}</p>
                            <p className="font-semibold">Ghế {ticket.seat}</p>
                          </div>
                          <GradientButton size="sm">
                            <QrCode className="w-4 h-4" />
                            Xem QR
                          </GradientButton>
                        </div>
                      </div>
                    </GlassCard>
                  ))}
                </div>
              </div>
            )}

            {/* Security Tab */}
            {activeTab === "security" && (
              <GlassCard variant="strong" className="p-6">
                <h2 className="text-xl font-semibold mb-6">Bảo mật</h2>
                
                <div className="space-y-6">
                  {/* Change Password */}
                  <div className="glass p-6 rounded-xl">
                    <h3 className="font-semibold mb-4 flex items-center gap-2">
                      <Lock className="w-5 h-5 text-primary" />
                      Đổi mật khẩu
                    </h3>
                    <div className="space-y-4">
                      <div className="space-y-2">
                        <Label>Mật khẩu hiện tại</Label>
                        <Input type="password" className="h-11 rounded-xl" />
                      </div>
                      <div className="space-y-2">
                        <Label>Mật khẩu mới</Label>
                        <Input type="password" className="h-11 rounded-xl" />
                      </div>
                      <div className="space-y-2">
                        <Label>Xác nhận mật khẩu mới</Label>
                        <Input type="password" className="h-11 rounded-xl" />
                      </div>
                      <GradientButton>Cập nhật mật khẩu</GradientButton>
                    </div>
                  </div>

                  {/* Two Factor */}
                  <div className="glass p-6 rounded-xl">
                    <div className="flex items-center justify-between">
                      <div>
                        <h3 className="font-semibold flex items-center gap-2">
                          <Settings className="w-5 h-5 text-primary" />
                          Xác thực hai yếu tố
                        </h3>
                        <p className="text-sm text-muted-foreground mt-1">
                          Tăng cường bảo mật cho tài khoản của bạn
                        </p>
                      </div>
                      <GradientButton variant="secondary">Kích hoạt</GradientButton>
                    </div>
                  </div>
                </div>
              </GlassCard>
            )}
          </div>
        </div>
      </div>
    </MainLayout>
  );
};

export default Profile;
