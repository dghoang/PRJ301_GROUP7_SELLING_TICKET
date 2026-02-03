import { OrganizerLayout } from "@/components/organizer";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  TrendingUp,
  TrendingDown,
  DollarSign,
  Ticket,
  Users,
  Calendar,
  Download,
} from "lucide-react";
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
  PieChart,
  Pie,
  Cell,
  AreaChart,
  Area,
} from "recharts";

const revenueData = [
  { date: "01/01", revenue: 15000000, tickets: 30 },
  { date: "02/01", revenue: 22000000, tickets: 45 },
  { date: "03/01", revenue: 18000000, tickets: 35 },
  { date: "04/01", revenue: 28000000, tickets: 55 },
  { date: "05/01", revenue: 35000000, tickets: 70 },
  { date: "06/01", revenue: 42000000, tickets: 85 },
  { date: "07/01", revenue: 38000000, tickets: 75 },
];

const ticketTypeData = [
  { name: "VIP", value: 120, revenue: 180000000 },
  { name: "Premium", value: 280, revenue: 224000000 },
  { name: "Standard", value: 450, revenue: 225000000 },
  { name: "Economy", value: 180, revenue: 54000000 },
];

const showData = [
  { show: "Suất 1 (19:00)", sold: 320, capacity: 350, revenue: 160000000 },
  { show: "Suất 2 (21:00)", sold: 280, capacity: 350, revenue: 140000000 },
  { show: "Suất 3 (14:00)", sold: 230, capacity: 300, revenue: 115000000 },
];

const eventComparisonData = [
  { name: "Concert ABC", revenue: 125500000, tickets: 850 },
  { name: "Workshop", revenue: 22500000, tickets: 45 },
  { name: "Festival", revenue: 0, tickets: 0 },
];

const COLORS = ["#ec4899", "#a855f7", "#8b5cf6", "#6366f1"];

const Statistics = () => {
  const stats = [
    {
      label: "Tổng doanh thu",
      value: "148M",
      unit: "VNĐ",
      change: "+23.5%",
      positive: true,
      icon: DollarSign,
    },
    {
      label: "Vé đã bán",
      value: "1,030",
      unit: "vé",
      change: "+18.2%",
      positive: true,
      icon: Ticket,
    },
    {
      label: "Khách hàng",
      value: "892",
      unit: "người",
      change: "+15.4%",
      positive: true,
      icon: Users,
    },
    {
      label: "Sự kiện",
      value: "5",
      unit: "sự kiện",
      change: "+2",
      positive: true,
      icon: Calendar,
    },
  ];

  return (
    <OrganizerLayout
      title="Thống kê doanh số"
      subtitle="Phân tích chi tiết doanh thu và vé bán"
      actions={
        <div className="flex items-center gap-3">
          <Select defaultValue="week">
            <SelectTrigger className="w-40 glass-input">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="today">Hôm nay</SelectItem>
              <SelectItem value="week">7 ngày qua</SelectItem>
              <SelectItem value="month">30 ngày qua</SelectItem>
              <SelectItem value="year">Năm nay</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="outline" className="glass">
            <Download className="h-4 w-4 mr-2" />
            Xuất báo cáo
          </Button>
        </div>
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
                <TrendingUp className="h-4 w-4 text-green-500" />
              ) : (
                <TrendingDown className="h-4 w-4 text-red-500" />
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

      {/* Charts Row 1 */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        {/* Revenue Over Time */}
        <GlassCard className="p-5 lg:col-span-2">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-semibold">Doanh thu theo thời gian</h3>
              <p className="text-sm text-muted-foreground">
                Tổng hợp doanh thu 7 ngày qua
              </p>
            </div>
          </div>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={revenueData}>
                <defs>
                  <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#ec4899" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#ec4899" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" />
                <XAxis dataKey="date" stroke="rgba(255,255,255,0.5)" />
                <YAxis
                  stroke="rgba(255,255,255,0.5)"
                  tickFormatter={(value) => `${value / 1000000}M`}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "rgba(255,255,255,0.1)",
                    backdropFilter: "blur(10px)",
                    border: "1px solid rgba(255,255,255,0.2)",
                    borderRadius: "12px",
                  }}
                  formatter={(value: number) => [
                    `${value.toLocaleString()} VNĐ`,
                    "Doanh thu",
                  ]}
                />
                <Area
                  type="monotone"
                  dataKey="revenue"
                  stroke="#ec4899"
                  strokeWidth={2}
                  fillOpacity={1}
                  fill="url(#colorRevenue)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </GlassCard>

        {/* Ticket Types Pie Chart */}
        <GlassCard className="p-5">
          <div className="mb-4">
            <h3 className="font-semibold">Phân bổ loại vé</h3>
            <p className="text-sm text-muted-foreground">Theo số lượng bán</p>
          </div>
          <div className="h-56">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={ticketTypeData}
                  cx="50%"
                  cy="50%"
                  innerRadius={50}
                  outerRadius={80}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {ticketTypeData.map((entry, index) => (
                    <Cell
                      key={`cell-${index}`}
                      fill={COLORS[index % COLORS.length]}
                    />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    backgroundColor: "rgba(255,255,255,0.1)",
                    backdropFilter: "blur(10px)",
                    border: "1px solid rgba(255,255,255,0.2)",
                    borderRadius: "12px",
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="space-y-2 mt-4">
            {ticketTypeData.map((item, index) => (
              <div key={item.name} className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: COLORS[index] }}
                  />
                  <span className="text-sm">{item.name}</span>
                </div>
                <span className="text-sm font-medium">{item.value} vé</span>
              </div>
            ))}
          </div>
        </GlassCard>
      </div>

      {/* Charts Row 2 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Show Comparison */}
        <GlassCard className="p-5">
          <div className="mb-4">
            <h3 className="font-semibold">Thống kê theo suất diễn</h3>
            <p className="text-sm text-muted-foreground">Concert ABC</p>
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={showData} layout="vertical">
                <CartesianGrid
                  strokeDasharray="3 3"
                  stroke="rgba(255,255,255,0.1)"
                />
                <XAxis type="number" stroke="rgba(255,255,255,0.5)" />
                <YAxis
                  type="category"
                  dataKey="show"
                  stroke="rgba(255,255,255,0.5)"
                  width={100}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "rgba(255,255,255,0.1)",
                    backdropFilter: "blur(10px)",
                    border: "1px solid rgba(255,255,255,0.2)",
                    borderRadius: "12px",
                  }}
                />
                <Bar dataKey="sold" fill="url(#barGradient)" radius={[0, 8, 8, 0]} />
                <defs>
                  <linearGradient id="barGradient2" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor="#ec4899" />
                    <stop offset="100%" stopColor="#a855f7" />
                  </linearGradient>
                </defs>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </GlassCard>

        {/* Event Comparison */}
        <GlassCard className="p-5">
          <div className="mb-4">
            <h3 className="font-semibold">So sánh các sự kiện</h3>
            <p className="text-sm text-muted-foreground">Doanh thu và vé bán</p>
          </div>
          <div className="space-y-4">
            {eventComparisonData.map((event, index) => (
              <div key={event.name} className="p-4 rounded-xl bg-white/5">
                <div className="flex items-center justify-between mb-2">
                  <span className="font-medium">{event.name}</span>
                  <span className="text-sm text-muted-foreground">
                    {event.tickets} vé
                  </span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-muted-foreground">Doanh thu</span>
                  <span className="font-medium">
                    {(event.revenue / 1000000).toFixed(1)}M VNĐ
                  </span>
                </div>
                <div className="mt-2 h-2 bg-white/10 rounded-full overflow-hidden">
                  <div
                    className="h-full rounded-full"
                    style={{
                      width: `${
                        (event.revenue /
                          Math.max(...eventComparisonData.map((e) => e.revenue))) *
                          100 || 0
                      }%`,
                      background: COLORS[index],
                    }}
                  />
                </div>
              </div>
            ))}
          </div>
        </GlassCard>
      </div>
    </OrganizerLayout>
  );
};

export default Statistics;
