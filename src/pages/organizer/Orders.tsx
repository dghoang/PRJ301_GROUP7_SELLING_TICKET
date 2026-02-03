import { useState } from "react";
import { OrganizerLayout } from "@/components/organizer";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import {
  Search,
  Download,
  Eye,
  Mail,
  Phone,
  Calendar,
  Ticket,
  User,
} from "lucide-react";
import { cn } from "@/lib/utils";

const orders = [
  {
    id: "ORD001",
    customerName: "Nguyễn Văn A",
    email: "nguyenvana@email.com",
    phone: "0912345678",
    event: "Concert ABC - Đêm nhạc trẻ",
    ticketType: "VIP",
    quantity: 2,
    total: 3000000,
    orderDate: "10/01/2024 14:30",
    paymentMethod: "Momo",
    status: "completed",
  },
  {
    id: "ORD002",
    customerName: "Trần Thị B",
    email: "tranthib@email.com",
    phone: "0987654321",
    event: "Concert ABC - Đêm nhạc trẻ",
    ticketType: "Premium",
    quantity: 4,
    total: 3200000,
    orderDate: "11/01/2024 09:15",
    paymentMethod: "VNPay",
    status: "completed",
  },
  {
    id: "ORD003",
    customerName: "Lê Văn C",
    email: "levanc@email.com",
    phone: "0909090909",
    event: "Workshop Khởi nghiệp 2024",
    ticketType: "Regular",
    quantity: 1,
    total: 500000,
    orderDate: "12/01/2024 16:45",
    paymentMethod: "Chuyển khoản",
    status: "pending",
  },
  {
    id: "ORD004",
    customerName: "Phạm Thị D",
    email: "phamthid@email.com",
    phone: "0933333333",
    event: "Concert ABC - Đêm nhạc trẻ",
    ticketType: "Standard",
    quantity: 3,
    total: 1500000,
    orderDate: "13/01/2024 11:20",
    paymentMethod: "ZaloPay",
    status: "completed",
  },
  {
    id: "ORD005",
    customerName: "Hoàng Văn E",
    email: "hoangvane@email.com",
    phone: "0944444444",
    event: "Workshop Khởi nghiệp 2024",
    ticketType: "Early Bird",
    quantity: 2,
    total: 600000,
    orderDate: "05/01/2024 08:00",
    paymentMethod: "Momo",
    status: "cancelled",
  },
];

const statusConfig = {
  pending: { label: "Chờ thanh toán", color: "bg-yellow-500/20 text-yellow-400" },
  completed: { label: "Hoàn thành", color: "bg-green-500/20 text-green-400" },
  cancelled: { label: "Đã hủy", color: "bg-red-500/20 text-red-400" },
};

const Orders = () => {
  const [searchQuery, setSearchQuery] = useState("");
  const [eventFilter, setEventFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");

  const uniqueEvents = [...new Set(orders.map((o) => o.event))];

  const filteredOrders = orders.filter((order) => {
    const matchesSearch =
      order.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      order.customerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      order.email.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesEvent = eventFilter === "all" || order.event === eventFilter;
    const matchesStatus = statusFilter === "all" || order.status === statusFilter;
    return matchesSearch && matchesEvent && matchesStatus;
  });

  const totalRevenue = filteredOrders
    .filter((o) => o.status === "completed")
    .reduce((sum, o) => sum + o.total, 0);
  const totalOrders = filteredOrders.length;
  const totalTickets = filteredOrders.reduce((sum, o) => sum + o.quantity, 0);

  return (
    <OrganizerLayout
      title="Quản lý đơn hàng"
      subtitle="Xem danh sách khách hàng đã mua vé (RSVP)"
      actions={
        <Button variant="outline" className="glass">
          <Download className="h-4 w-4 mr-2" />
          Xuất Excel
        </Button>
      }
    >
      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <GlassCard className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-primary/20 flex items-center justify-center">
              <User className="h-5 w-5 text-primary" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Tổng đơn hàng</p>
              <p className="text-xl font-bold">{totalOrders}</p>
            </div>
          </div>
        </GlassCard>
        <GlassCard className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center">
              <Ticket className="h-5 w-5 text-blue-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Tổng vé</p>
              <p className="text-xl font-bold">{totalTickets}</p>
            </div>
          </div>
        </GlassCard>
        <GlassCard className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-green-500/20 flex items-center justify-center">
              <span className="text-lg font-bold text-green-400">₫</span>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Doanh thu</p>
              <p className="text-xl font-bold">
                {(totalRevenue / 1000000).toFixed(1)}M
              </p>
            </div>
          </div>
        </GlassCard>
      </div>

      {/* Filters */}
      <GlassCard className="p-4 mb-6">
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Tìm theo mã đơn, tên, email..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 glass-input"
            />
          </div>
          <Select value={eventFilter} onValueChange={setEventFilter}>
            <SelectTrigger className="w-full sm:w-56 glass-input">
              <SelectValue placeholder="Sự kiện" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Tất cả sự kiện</SelectItem>
              {uniqueEvents.map((event) => (
                <SelectItem key={event} value={event}>
                  {event}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="w-full sm:w-40 glass-input">
              <SelectValue placeholder="Trạng thái" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Tất cả</SelectItem>
              <SelectItem value="completed">Hoàn thành</SelectItem>
              <SelectItem value="pending">Chờ thanh toán</SelectItem>
              <SelectItem value="cancelled">Đã hủy</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </GlassCard>

      {/* Table */}
      <GlassCard className="overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="border-white/10 hover:bg-transparent">
              <TableHead>Mã đơn</TableHead>
              <TableHead>Khách hàng</TableHead>
              <TableHead>Sự kiện / Vé</TableHead>
              <TableHead className="text-right">Tổng tiền</TableHead>
              <TableHead>Thời gian</TableHead>
              <TableHead>Trạng thái</TableHead>
              <TableHead className="text-right">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredOrders.map((order) => (
              <TableRow key={order.id} className="border-white/10">
                <TableCell className="font-mono font-bold">{order.id}</TableCell>
                <TableCell>
                  <div>
                    <p className="font-medium">{order.customerName}</p>
                    <div className="flex items-center gap-3 text-xs text-muted-foreground mt-1">
                      <span className="flex items-center gap-1">
                        <Mail className="h-3 w-3" />
                        {order.email}
                      </span>
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <div>
                    <p className="text-sm">{order.event}</p>
                    <p className="text-xs text-muted-foreground">
                      {order.ticketType} x {order.quantity}
                    </p>
                  </div>
                </TableCell>
                <TableCell className="text-right font-medium">
                  {order.total.toLocaleString()}đ
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-1 text-sm text-muted-foreground">
                    <Calendar className="h-3 w-3" />
                    {order.orderDate}
                  </div>
                </TableCell>
                <TableCell>
                  <Badge
                    variant="secondary"
                    className={cn(
                      "border-0",
                      statusConfig[order.status as keyof typeof statusConfig].color
                    )}
                  >
                    {statusConfig[order.status as keyof typeof statusConfig].label}
                  </Badge>
                </TableCell>
                <TableCell className="text-right">
                  <Button variant="ghost" size="icon" className="h-8 w-8">
                    <Eye className="h-4 w-4" />
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </GlassCard>
    </OrganizerLayout>
  );
};

export default Orders;
