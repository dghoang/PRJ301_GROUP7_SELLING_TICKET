import { useState } from "react";
import { motion } from "framer-motion";
import {
  Calendar,
  Download,
  TrendingUp,
  TrendingDown,
  DollarSign,
  Ticket,
  Users,
  Building2,
  ArrowUpRight,
  ArrowDownRight,
} from "lucide-react";
import { AdminLayout } from "@/components/admin";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
} from "recharts";
import { staggerContainer, staggerItem } from "@/lib/animations";

const monthlyRevenue = [
  { name: "T1", revenue: 1200, tickets: 4500, events: 45 },
  { name: "T2", revenue: 1450, tickets: 5200, events: 52 },
  { name: "T3", revenue: 1680, tickets: 6100, events: 58 },
  { name: "T4", revenue: 1920, tickets: 7200, events: 64 },
  { name: "T5", revenue: 1750, tickets: 6800, events: 61 },
  { name: "T6", revenue: 2100, tickets: 8500, events: 72 },
  { name: "T7", revenue: 2450, tickets: 9800, events: 85 },
  { name: "T8", revenue: 2200, tickets: 8900, events: 78 },
  { name: "T9", revenue: 2680, tickets: 10500, events: 92 },
  { name: "T10", revenue: 2890, tickets: 11200, events: 98 },
  { name: "T11", revenue: 3150, tickets: 12500, events: 105 },
  { name: "T12", revenue: 3580, tickets: 14200, events: 118 },
];

const topOrganizers = [
  { name: "Live Nation VN", revenue: "2.5 tỷ", events: 25, growth: 18.5 },
  { name: "TechVN Community", revenue: "450 triệu", events: 12, growth: 24.2 },
  { name: "VN Sports Club", revenue: "380 triệu", events: 18, growth: 15.8 },
  { name: "Art Gallery X", revenue: "120 triệu", events: 5, growth: -5.2 },
  { name: "Music Production", revenue: "95 triệu", events: 8, growth: 32.1 },
];

const topEvents = [
  { name: "Vietnam Music Festival", tickets: 15000, revenue: "2.25 tỷ" },
  { name: "Tech Summit 2025", tickets: 5000, revenue: "750 triệu" },
  { name: "Marathon HCM", tickets: 8000, revenue: "400 triệu" },
  { name: "Art Exhibition", tickets: 3000, revenue: "150 triệu" },
  { name: "Comedy Night", tickets: 2000, revenue: "100 triệu" },
];

const categoryDistribution = [
  { name: "Âm nhạc", value: 42, color: "#EC4899" },
  { name: "Thể thao", value: 22, color: "#06B6D4" },
  { name: "Hội thảo", value: 18, color: "#8B5CF6" },
  { name: "Nghệ thuật", value: 12, color: "#F59E0B" },
  { name: "Khác", value: 6, color: "#6B7280" },
];

const Reports = () => {
  const [dateRange, setDateRange] = useState("year");

  const stats = [
    {
      title: "Tổng doanh thu",
      value: "27.05 tỷ",
      change: "+24.5%",
      trend: "up",
      icon: DollarSign,
      gradient: "from-emerald-500 to-teal-500",
    },
    {
      title: "Vé đã bán",
      value: "105,400",
      change: "+18.2%",
      trend: "up",
      icon: Ticket,
      gradient: "from-blue-500 to-cyan-500",
    },
    {
      title: "Người dùng mới",
      value: "28,540",
      change: "+32.1%",
      trend: "up",
      icon: Users,
      gradient: "from-violet-500 to-purple-500",
    },
    {
      title: "Ban tổ chức",
      value: "1,284",
      change: "+12.8%",
      trend: "up",
      icon: Building2,
      gradient: "from-pink-500 to-rose-500",
    },
  ];

  return (
    <AdminLayout title="Báo cáo tổng hợp" subtitle="Phân tích dữ liệu hệ thống">
      <motion.div
        variants={staggerContainer}
        initial="initial"
        animate="animate"
        className="space-y-6"
      >
        {/* Header Actions */}
        <motion.div variants={staggerItem}>
          <GlassCard className="p-4">
            <div className="flex flex-wrap items-center justify-between gap-4">
              <div className="flex items-center gap-4">
                <Select value={dateRange} onValueChange={setDateRange}>
                  <SelectTrigger className="w-40">
                    <Calendar className="mr-2 h-4 w-4" />
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="week">Tuần này</SelectItem>
                    <SelectItem value="month">Tháng này</SelectItem>
                    <SelectItem value="quarter">Quý này</SelectItem>
                    <SelectItem value="year">Năm nay</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <Button className="btn-gradient text-white">
                <Download className="mr-2 h-4 w-4" />
                Xuất báo cáo
              </Button>
            </div>
          </GlassCard>
        </motion.div>

        {/* Stats Grid */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {stats.map((stat, index) => (
            <motion.div
              key={stat.title}
              variants={staggerItem}
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
                      <span className="text-xs text-muted-foreground">vs năm trước</span>
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

        {/* Charts */}
        <motion.div variants={staggerItem}>
          <Tabs defaultValue="revenue" className="w-full">
            <TabsList className="glass mb-4">
              <TabsTrigger value="revenue">Doanh thu</TabsTrigger>
              <TabsTrigger value="tickets">Vé bán ra</TabsTrigger>
              <TabsTrigger value="events">Sự kiện</TabsTrigger>
            </TabsList>

            <TabsContent value="revenue">
              <GlassCard className="p-6">
                <h3 className="mb-4 text-lg font-semibold">Doanh thu theo tháng (triệu VNĐ)</h3>
                <div className="h-80">
                  <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={monthlyRevenue}>
                      <defs>
                        <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
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
                        formatter={(value: number) => [`${value} triệu`, "Doanh thu"]}
                      />
                      <Area
                        type="monotone"
                        dataKey="revenue"
                        stroke="#EC4899"
                        strokeWidth={3}
                        fill="url(#colorRev)"
                      />
                    </AreaChart>
                  </ResponsiveContainer>
                </div>
              </GlassCard>
            </TabsContent>

            <TabsContent value="tickets">
              <GlassCard className="p-6">
                <h3 className="mb-4 text-lg font-semibold">Số lượng vé bán ra</h3>
                <div className="h-80">
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={monthlyRevenue}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                      <XAxis dataKey="name" stroke="#9CA3AF" />
                      <YAxis stroke="#9CA3AF" />
                      <Tooltip
                        contentStyle={{
                          backgroundColor: "rgba(255, 255, 255, 0.9)",
                          borderRadius: "12px",
                          border: "none",
                        }}
                      />
                      <Bar dataKey="tickets" fill="#8B5CF6" radius={[8, 8, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </GlassCard>
            </TabsContent>

            <TabsContent value="events">
              <GlassCard className="p-6">
                <h3 className="mb-4 text-lg font-semibold">Số sự kiện theo tháng</h3>
                <div className="h-80">
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={monthlyRevenue}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                      <XAxis dataKey="name" stroke="#9CA3AF" />
                      <YAxis stroke="#9CA3AF" />
                      <Tooltip
                        contentStyle={{
                          backgroundColor: "rgba(255, 255, 255, 0.9)",
                          borderRadius: "12px",
                          border: "none",
                        }}
                      />
                      <Line
                        type="monotone"
                        dataKey="events"
                        stroke="#06B6D4"
                        strokeWidth={3}
                        dot={{ fill: "#06B6D4", strokeWidth: 2 }}
                      />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              </GlassCard>
            </TabsContent>
          </Tabs>
        </motion.div>

        {/* Bottom Grid */}
        <div className="grid gap-6 lg:grid-cols-3">
          {/* Category Distribution */}
          <motion.div variants={staggerItem}>
            <GlassCard className="p-6">
              <h3 className="mb-4 text-lg font-semibold">Phân bố thể loại</h3>
              <div className="h-48">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={categoryDistribution}
                      cx="50%"
                      cy="50%"
                      innerRadius={50}
                      outerRadius={70}
                      paddingAngle={5}
                      dataKey="value"
                    >
                      {categoryDistribution.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="mt-4 space-y-2">
                {categoryDistribution.map((item) => (
                  <div key={item.name} className="flex items-center justify-between text-sm">
                    <div className="flex items-center gap-2">
                      <div
                        className="h-3 w-3 rounded-full"
                        style={{ backgroundColor: item.color }}
                      />
                      <span>{item.name}</span>
                    </div>
                    <span className="font-medium">{item.value}%</span>
                  </div>
                ))}
              </div>
            </GlassCard>
          </motion.div>

          {/* Top Organizers */}
          <motion.div variants={staggerItem}>
            <GlassCard className="p-6">
              <h3 className="mb-4 text-lg font-semibold">Top BTC</h3>
              <div className="space-y-4">
                {topOrganizers.map((org, index) => (
                  <motion.div
                    key={org.name}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.5 + index * 0.1 }}
                    className="flex items-center justify-between"
                  >
                    <div className="flex items-center gap-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-primary to-accent text-sm font-bold text-white">
                        {index + 1}
                      </div>
                      <div>
                        <p className="text-sm font-medium">{org.name}</p>
                        <p className="text-xs text-muted-foreground">
                          {org.events} sự kiện
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-semibold">{org.revenue}</p>
                      <div className="flex items-center justify-end gap-1">
                        {org.growth >= 0 ? (
                          <TrendingUp className="h-3 w-3 text-emerald-500" />
                        ) : (
                          <TrendingDown className="h-3 w-3 text-red-500" />
                        )}
                        <span
                          className={`text-xs ${
                            org.growth >= 0 ? "text-emerald-500" : "text-red-500"
                          }`}
                        >
                          {org.growth >= 0 ? "+" : ""}
                          {org.growth}%
                        </span>
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>
            </GlassCard>
          </motion.div>

          {/* Top Events */}
          <motion.div variants={staggerItem}>
            <GlassCard className="p-6">
              <h3 className="mb-4 text-lg font-semibold">Top sự kiện</h3>
              <div className="space-y-4">
                {topEvents.map((event, index) => (
                  <motion.div
                    key={event.name}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.5 + index * 0.1 }}
                    className="flex items-center justify-between"
                  >
                    <div className="flex items-center gap-3">
                      <Badge
                        variant="outline"
                        className={
                          index === 0
                            ? "border-yellow-500 bg-yellow-50 text-yellow-600"
                            : index === 1
                            ? "border-gray-400 bg-gray-50 text-gray-600"
                            : index === 2
                            ? "border-orange-500 bg-orange-50 text-orange-600"
                            : ""
                        }
                      >
                        #{index + 1}
                      </Badge>
                      <div>
                        <p className="text-sm font-medium">{event.name}</p>
                        <p className="text-xs text-muted-foreground">
                          {event.tickets.toLocaleString()} vé
                        </p>
                      </div>
                    </div>
                    <p className="text-sm font-semibold">{event.revenue}</p>
                  </motion.div>
                ))}
              </div>
            </GlassCard>
          </motion.div>
        </div>
      </motion.div>
    </AdminLayout>
  );
};

export default Reports;
