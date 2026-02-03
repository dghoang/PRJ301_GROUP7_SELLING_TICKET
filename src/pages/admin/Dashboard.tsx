import { motion } from "framer-motion";
import {
  Calendar,
  Users,
  DollarSign,
  TrendingUp,
  AlertTriangle,
  CheckCircle,
  Clock,
  ArrowUpRight,
  ArrowDownRight,
} from "lucide-react";
import { AdminLayout } from "@/components/admin";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from "recharts";
import { staggerContainer, staggerItem } from "@/lib/animations";

const revenueData = [
  { name: "T1", value: 450 },
  { name: "T2", value: 520 },
  { name: "T3", value: 680 },
  { name: "T4", value: 890 },
  { name: "T5", value: 720 },
  { name: "T6", value: 950 },
  { name: "T7", value: 1100 },
  { name: "T8", value: 980 },
  { name: "T9", value: 1250 },
  { name: "T10", value: 1400 },
  { name: "T11", value: 1580 },
  { name: "T12", value: 1850 },
];

const categoryData = [
  { name: "Âm nhạc", value: 45, color: "#EC4899" },
  { name: "Workshop", value: 25, color: "#8B5CF6" },
  { name: "Thể thao", value: 15, color: "#06B6D4" },
  { name: "Nghệ thuật", value: 10, color: "#F59E0B" },
  { name: "Khác", value: 5, color: "#6B7280" },
];

const pendingEvents = [
  {
    id: 1,
    name: "Music Festival 2025",
    organizer: "Live Nation VN",
    date: "15/03/2025",
    status: "pending",
  },
  {
    id: 2,
    name: "Tech Conference",
    organizer: "TechVN",
    date: "20/03/2025",
    status: "pending",
  },
  {
    id: 3,
    name: "Art Exhibition",
    organizer: "Gallery X",
    date: "25/03/2025",
    status: "pending",
  },
];

const transition = { duration: 0.4, ease: "easeOut" as const };

const AdminDashboard = () => {
  const stats = [
    {
      title: "Tổng doanh thu",
      value: "12.5 tỷ",
      change: "+18.2%",
      trend: "up",
      icon: DollarSign,
      gradient: "from-emerald-500 to-teal-500",
    },
    {
      title: "Sự kiện hoạt động",
      value: "248",
      change: "+12",
      trend: "up",
      icon: Calendar,
      gradient: "from-blue-500 to-cyan-500",
    },
    {
      title: "Người dùng",
      value: "125.8k",
      change: "+2.4k",
      trend: "up",
      icon: Users,
      gradient: "from-violet-500 to-purple-500",
    },
    {
      title: "Tăng trưởng",
      value: "32%",
      change: "+5.2%",
      trend: "up",
      icon: TrendingUp,
      gradient: "from-pink-500 to-rose-500",
    },
  ];

  return (
    <AdminLayout title="Dashboard" subtitle="Tổng quan hệ thống">
      <motion.div
        variants={staggerContainer}
        initial="initial"
        animate="animate"
        className="space-y-6"
      >
        {/* Stats Grid */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {stats.map((stat, index) => (
            <motion.div
              key={stat.title}
              variants={staggerItem}
              transition={{ ...transition, delay: index * 0.1 }}
              whileHover={{ y: -4, scale: 1.02 }}
            >
              <GlassCard className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-muted-foreground">{stat.title}</p>
                    <motion.p
                      initial={{ opacity: 0, scale: 0.5 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: 0.3 + index * 0.1 }}
                      className="mt-1 text-3xl font-bold"
                    >
                      {stat.value}
                    </motion.p>
                    <div className="mt-2 flex items-center gap-1">
                      {stat.trend === "up" ? (
                        <ArrowUpRight className="h-4 w-4 text-emerald-500" />
                      ) : (
                        <ArrowDownRight className="h-4 w-4 text-red-500" />
                      )}
                      <span
                        className={
                          stat.trend === "up" ? "text-emerald-500" : "text-red-500"
                        }
                      >
                        {stat.change}
                      </span>
                    </div>
                  </div>
                  <motion.div
                    whileHover={{ rotate: 10, scale: 1.1 }}
                    className={`rounded-2xl bg-gradient-to-br ${stat.gradient} p-3`}
                  >
                    <stat.icon className="h-6 w-6 text-white" />
                  </motion.div>
                </div>
              </GlassCard>
            </motion.div>
          ))}
        </div>

        {/* Charts Row */}
        <div className="grid gap-6 lg:grid-cols-3">
          {/* Revenue Chart */}
          <motion.div
            variants={staggerItem}
            className="lg:col-span-2"
          >
            <GlassCard className="p-6">
              <h3 className="mb-4 text-lg font-semibold">Doanh thu theo tháng</h3>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={revenueData}>
                    <defs>
                      <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#EC4899" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="#EC4899" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                    <XAxis dataKey="name" stroke="#9CA3AF" />
                    <YAxis stroke="#9CA3AF" />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: "rgba(255, 255, 255, 0.9)",
                        borderRadius: "12px",
                        border: "none",
                        boxShadow: "0 10px 40px -10px rgba(0,0,0,0.1)",
                      }}
                    />
                    <Area
                      type="monotone"
                      dataKey="value"
                      stroke="#EC4899"
                      strokeWidth={3}
                      fill="url(#colorRevenue)"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </GlassCard>
          </motion.div>

          {/* Category Distribution */}
          <motion.div variants={staggerItem}>
            <GlassCard className="p-6">
              <h3 className="mb-4 text-lg font-semibold">Phân bố thể loại</h3>
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={categoryData}
                      cx="50%"
                      cy="50%"
                      innerRadius={60}
                      outerRadius={80}
                      paddingAngle={5}
                      dataKey="value"
                    >
                      {categoryData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="mt-4 space-y-2">
                {categoryData.map((item) => (
                  <div key={item.name} className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div
                        className="h-3 w-3 rounded-full"
                        style={{ backgroundColor: item.color }}
                      />
                      <span className="text-sm">{item.name}</span>
                    </div>
                    <span className="text-sm font-medium">{item.value}%</span>
                  </div>
                ))}
              </div>
            </GlassCard>
          </motion.div>
        </div>

        {/* Bottom Section */}
        <div className="grid gap-6 lg:grid-cols-2">
          {/* Pending Events */}
          <motion.div variants={staggerItem}>
            <GlassCard className="p-6">
              <div className="mb-4 flex items-center justify-between">
                <h3 className="text-lg font-semibold">Sự kiện chờ duyệt</h3>
                <Badge variant="secondary" className="bg-amber-100 text-amber-700">
                  <Clock className="mr-1 h-3 w-3" />
                  {pendingEvents.length} chờ xử lý
                </Badge>
              </div>
              <div className="space-y-4">
                {pendingEvents.map((event, index) => (
                  <motion.div
                    key={event.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.5 + index * 0.1 }}
                    className="flex items-center justify-between rounded-xl bg-background/50 p-4"
                  >
                    <div>
                      <p className="font-medium">{event.name}</p>
                      <p className="text-sm text-muted-foreground">
                        {event.organizer} • {event.date}
                      </p>
                    </div>
                    <div className="flex gap-2">
                      <Button size="sm" variant="outline" className="text-red-500">
                        Từ chối
                      </Button>
                      <Button size="sm" className="bg-emerald-500 hover:bg-emerald-600">
                        Duyệt
                      </Button>
                    </div>
                  </motion.div>
                ))}
              </div>
              <Button variant="ghost" className="mt-4 w-full">
                Xem tất cả
              </Button>
            </GlassCard>
          </motion.div>

          {/* System Status */}
          <motion.div variants={staggerItem}>
            <GlassCard className="p-6">
              <h3 className="mb-4 text-lg font-semibold">Trạng thái hệ thống</h3>
              <div className="space-y-6">
                <div>
                  <div className="mb-2 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <CheckCircle className="h-4 w-4 text-emerald-500" />
                      <span className="text-sm">Server chính</span>
                    </div>
                    <span className="text-sm text-emerald-500">Hoạt động</span>
                  </div>
                  <Progress value={85} className="h-2" />
                  <p className="mt-1 text-xs text-muted-foreground">CPU: 85%</p>
                </div>

                <div>
                  <div className="mb-2 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <CheckCircle className="h-4 w-4 text-emerald-500" />
                      <span className="text-sm">Database</span>
                    </div>
                    <span className="text-sm text-emerald-500">Hoạt động</span>
                  </div>
                  <Progress value={62} className="h-2" />
                  <p className="mt-1 text-xs text-muted-foreground">Bộ nhớ: 62%</p>
                </div>

                <div>
                  <div className="mb-2 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <AlertTriangle className="h-4 w-4 text-amber-500" />
                      <span className="text-sm">Payment Gateway</span>
                    </div>
                    <span className="text-sm text-amber-500">Cảnh báo</span>
                  </div>
                  <Progress value={92} className="h-2" />
                  <p className="mt-1 text-xs text-muted-foreground">Độ trễ: 245ms</p>
                </div>

                <div>
                  <div className="mb-2 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <CheckCircle className="h-4 w-4 text-emerald-500" />
                      <span className="text-sm">CDN & Storage</span>
                    </div>
                    <span className="text-sm text-emerald-500">Hoạt động</span>
                  </div>
                  <Progress value={45} className="h-2" />
                  <p className="mt-1 text-xs text-muted-foreground">Sử dụng: 45%</p>
                </div>
              </div>
            </GlassCard>
          </motion.div>
        </div>
      </motion.div>
    </AdminLayout>
  );
};

export default AdminDashboard;
