import { OrganizerLayout } from "@/components/organizer";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import {
  TrendingUp,
  Ticket,
  Calendar,
  DollarSign,
  Users,
  Eye,
  Plus,
  ArrowUpRight,
  ArrowDownRight,
} from "lucide-react";
import { Link } from "react-router-dom";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
} from "recharts";

const revenueData = [
  { name: "T1", revenue: 4000000 },
  { name: "T2", revenue: 3000000 },
  { name: "T3", revenue: 5000000 },
  { name: "T4", revenue: 2780000 },
  { name: "T5", revenue: 1890000 },
  { name: "T6", revenue: 2390000 },
  { name: "T7", revenue: 3490000 },
];

const ticketData = [
  { name: "VIP", sold: 120, total: 150 },
  { name: "Premium", sold: 280, total: 300 },
  { name: "Standard", sold: 450, total: 500 },
  { name: "Economy", sold: 180, total: 200 },
];

const recentOrders = [
  { id: "ORD001", customer: "Nguyễn Văn A", event: "Concert ABC", amount: 1500000, status: "completed" },
  { id: "ORD002", customer: "Trần Thị B", event: "Workshop XYZ", amount: 500000, status: "pending" },
  { id: "ORD003", customer: "Lê Văn C", event: "Concert ABC", amount: 2000000, status: "completed" },
  { id: "ORD004", customer: "Phạm Thị D", event: "Festival 2024", amount: 800000, status: "completed" },
];

const upcomingEvents = [
  { id: 1, name: "Concert ABC", date: "15/02/2024", ticketsSold: 850, status: "active" },
  { id: 2, name: "Workshop XYZ", date: "20/02/2024", ticketsSold: 45, status: "active" },
  { id: 3, name: "Festival 2024", date: "01/03/2024", ticketsSold: 0, status: "pending" },
];

const Dashboard = () => {
  const stats = [
    {
      label: "Tổng doanh thu",
      value: "125.5M",
      unit: "VNĐ",
      change: "+12.5%",
      positive: true,
      icon: DollarSign,
    },
    {
      label: "Vé đã bán",
      value: "1,234",
      unit: "vé",
      change: "+8.2%",
      positive: true,
      icon: Ticket,
    },
    {
      label: "Sự kiện đang diễn",
      value: "5",
      unit: "sự kiện",
      change: "+2",
      positive: true,
      icon: Calendar,
    },
    {
      label: "Lượt xem",
      value: "45.2K",
      unit: "lượt",
      change: "-3.1%",
      positive: false,
      icon: Eye,
    },
  ];

  return (
    <OrganizerLayout
      title="Dashboard"
      subtitle="Tổng quan hoạt động của bạn"
      actions={
        <Link to="/organizer/create-event">
          <GradientButton>
            <Plus className="h-4 w-4 mr-2" />
            Tạo sự kiện mới
          </GradientButton>
        </Link>
      }
    >
      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {stats.map((stat, index) => (
          <GlassCard key={index} className="p-5">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-sm text-muted-foreground">{stat.label}</p>
                <div className="flex items-baseline gap-1 mt-1">
                  <span className="text-2xl font-bold">{stat.value}</span>
                  <span className="text-sm text-muted-foreground">{stat.unit}</span>
                </div>
              </div>
              <div className="w-10 h-10 rounded-xl bg-gradient-primary/20 flex items-center justify-center">
                <stat.icon className="h-5 w-5 text-primary" />
              </div>
            </div>
            <div className="flex items-center gap-1 mt-3">
              {stat.positive ? (
                <ArrowUpRight className="h-4 w-4 text-green-500" />
              ) : (
                <ArrowDownRight className="h-4 w-4 text-red-500" />
              )}
              <span
                className={`text-sm font-medium ${
                  stat.positive ? "text-green-500" : "text-red-500"
                }`}
              >
                {stat.change}
              </span>
              <span className="text-xs text-muted-foreground">so với tuần trước</span>
            </div>
          </GlassCard>
        ))}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        {/* Revenue Chart */}
        <GlassCard className="p-5">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-semibold">Doanh thu theo tuần</h3>
              <p className="text-sm text-muted-foreground">7 ngày gần nhất</p>
            </div>
            <TrendingUp className="h-5 w-5 text-primary" />
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={revenueData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" />
                <XAxis dataKey="name" stroke="rgba(255,255,255,0.5)" />
                <YAxis stroke="rgba(255,255,255,0.5)" tickFormatter={(value) => `${value / 1000000}M`} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "rgba(255,255,255,0.1)",
                    backdropFilter: "blur(10px)",
                    border: "1px solid rgba(255,255,255,0.2)",
                    borderRadius: "12px",
                  }}
                  formatter={(value: number) => [`${value.toLocaleString()} VNĐ`, "Doanh thu"]}
                />
                <Line
                  type="monotone"
                  dataKey="revenue"
                  stroke="url(#gradient)"
                  strokeWidth={3}
                  dot={{ fill: "#ec4899", strokeWidth: 2 }}
                />
                <defs>
                  <linearGradient id="gradient" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor="#ec4899" />
                    <stop offset="100%" stopColor="#a855f7" />
                  </linearGradient>
                </defs>
              </LineChart>
            </ResponsiveContainer>
          </div>
        </GlassCard>

        {/* Ticket Sales Chart */}
        <GlassCard className="p-5">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-semibold">Vé đã bán theo loại</h3>
              <p className="text-sm text-muted-foreground">Tổng hợp tất cả sự kiện</p>
            </div>
            <Ticket className="h-5 w-5 text-primary" />
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={ticketData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" />
                <XAxis dataKey="name" stroke="rgba(255,255,255,0.5)" />
                <YAxis stroke="rgba(255,255,255,0.5)" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "rgba(255,255,255,0.1)",
                    backdropFilter: "blur(10px)",
                    border: "1px solid rgba(255,255,255,0.2)",
                    borderRadius: "12px",
                  }}
                />
                <Bar dataKey="sold" fill="url(#barGradient)" radius={[8, 8, 0, 0]} />
                <Bar dataKey="total" fill="rgba(255,255,255,0.2)" radius={[8, 8, 0, 0]} />
                <defs>
                  <linearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#ec4899" />
                    <stop offset="100%" stopColor="#a855f7" />
                  </linearGradient>
                </defs>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </GlassCard>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Orders */}
        <GlassCard className="p-5">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold">Đơn hàng gần đây</h3>
            <Link to="/organizer/orders" className="text-sm text-primary hover:underline">
              Xem tất cả
            </Link>
          </div>
          <div className="space-y-3">
            {recentOrders.map((order) => (
              <div
                key={order.id}
                className="flex items-center justify-between p-3 rounded-xl bg-white/5 hover:bg-white/10 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-primary/20 flex items-center justify-center">
                    <Users className="h-5 w-5 text-primary" />
                  </div>
                  <div>
                    <p className="font-medium">{order.customer}</p>
                    <p className="text-xs text-muted-foreground">{order.event}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="font-medium">{order.amount.toLocaleString()} đ</p>
                  <span
                    className={`text-xs px-2 py-0.5 rounded-full ${
                      order.status === "completed"
                        ? "bg-green-500/20 text-green-400"
                        : "bg-yellow-500/20 text-yellow-400"
                    }`}
                  >
                    {order.status === "completed" ? "Hoàn thành" : "Đang xử lý"}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </GlassCard>

        {/* Upcoming Events */}
        <GlassCard className="p-5">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold">Sự kiện sắp tới</h3>
            <Link to="/organizer/events" className="text-sm text-primary hover:underline">
              Xem tất cả
            </Link>
          </div>
          <div className="space-y-3">
            {upcomingEvents.map((event) => (
              <div
                key={event.id}
                className="flex items-center justify-between p-3 rounded-xl bg-white/5 hover:bg-white/10 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-gradient-primary/20 flex items-center justify-center">
                    <Calendar className="h-5 w-5 text-primary" />
                  </div>
                  <div>
                    <p className="font-medium">{event.name}</p>
                    <p className="text-xs text-muted-foreground">{event.date}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="font-medium">{event.ticketsSold} vé đã bán</p>
                  <span
                    className={`text-xs px-2 py-0.5 rounded-full ${
                      event.status === "active"
                        ? "bg-green-500/20 text-green-400"
                        : "bg-yellow-500/20 text-yellow-400"
                    }`}
                  >
                    {event.status === "active" ? "Đang bán" : "Chờ duyệt"}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </GlassCard>
      </div>
    </OrganizerLayout>
  );
};

export default Dashboard;
