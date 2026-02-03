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
import { Search, Edit, Ticket, TrendingUp } from "lucide-react";
import { cn } from "@/lib/utils";

const ticketTypes = [
  {
    id: 1,
    eventName: "Concert ABC - Đêm nhạc trẻ",
    ticketName: "VIP",
    price: 1500000,
    sold: 120,
    total: 150,
    startSale: "01/01/2024",
    endSale: "14/02/2024",
    status: "selling",
  },
  {
    id: 2,
    eventName: "Concert ABC - Đêm nhạc trẻ",
    ticketName: "Premium",
    price: 800000,
    sold: 280,
    total: 300,
    startSale: "01/01/2024",
    endSale: "14/02/2024",
    status: "selling",
  },
  {
    id: 3,
    eventName: "Concert ABC - Đêm nhạc trẻ",
    ticketName: "Standard",
    price: 500000,
    sold: 450,
    total: 500,
    startSale: "01/01/2024",
    endSale: "14/02/2024",
    status: "selling",
  },
  {
    id: 4,
    eventName: "Workshop Khởi nghiệp 2024",
    ticketName: "Early Bird",
    price: 300000,
    sold: 30,
    total: 30,
    startSale: "01/01/2024",
    endSale: "31/01/2024",
    status: "soldout",
  },
  {
    id: 5,
    eventName: "Workshop Khởi nghiệp 2024",
    ticketName: "Regular",
    price: 500000,
    sold: 15,
    total: 70,
    startSale: "01/02/2024",
    endSale: "19/02/2024",
    status: "selling",
  },
  {
    id: 6,
    eventName: "Festival Mùa Xuân",
    ticketName: "General Admission",
    price: 200000,
    sold: 0,
    total: 500,
    startSale: "15/02/2024",
    endSale: "28/02/2024",
    status: "upcoming",
  },
];

const statusConfig = {
  upcoming: { label: "Sắp mở bán", color: "bg-blue-500/20 text-blue-400" },
  selling: { label: "Đang bán", color: "bg-green-500/20 text-green-400" },
  soldout: { label: "Hết vé", color: "bg-red-500/20 text-red-400" },
  ended: { label: "Ngừng bán", color: "bg-gray-500/20 text-gray-400" },
};

const ManageTickets = () => {
  const [searchQuery, setSearchQuery] = useState("");
  const [eventFilter, setEventFilter] = useState("all");

  const uniqueEvents = [...new Set(ticketTypes.map((t) => t.eventName))];

  const filteredTickets = ticketTypes.filter((ticket) => {
    const matchesSearch =
      ticket.ticketName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      ticket.eventName.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesEvent = eventFilter === "all" || ticket.eventName === eventFilter;
    return matchesSearch && matchesEvent;
  });

  const totalRevenue = filteredTickets.reduce(
    (sum, t) => sum + t.price * t.sold,
    0
  );
  const totalSold = filteredTickets.reduce((sum, t) => sum + t.sold, 0);
  const totalTickets = filteredTickets.reduce((sum, t) => sum + t.total, 0);

  return (
    <OrganizerLayout
      title="Quản lý vé"
      subtitle="Theo dõi và quản lý các loại vé của sự kiện"
    >
      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <GlassCard className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-primary/20 flex items-center justify-center">
              <Ticket className="h-5 w-5 text-primary" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Tổng vé đã bán</p>
              <p className="text-xl font-bold">
                {totalSold.toLocaleString()} / {totalTickets.toLocaleString()}
              </p>
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
                {(totalRevenue / 1000000).toFixed(1)}M VNĐ
              </p>
            </div>
          </div>
        </GlassCard>
        <GlassCard className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center">
              <TrendingUp className="h-5 w-5 text-blue-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Tỉ lệ bán</p>
              <p className="text-xl font-bold">
                {totalTickets > 0
                  ? Math.round((totalSold / totalTickets) * 100)
                  : 0}
                %
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
              placeholder="Tìm kiếm loại vé..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 glass-input"
            />
          </div>
          <Select value={eventFilter} onValueChange={setEventFilter}>
            <SelectTrigger className="w-full sm:w-64 glass-input">
              <SelectValue placeholder="Chọn sự kiện" />
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
        </div>
      </GlassCard>

      {/* Table */}
      <GlassCard className="overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="border-white/10 hover:bg-transparent">
              <TableHead>Sự kiện</TableHead>
              <TableHead>Loại vé</TableHead>
              <TableHead className="text-right">Giá</TableHead>
              <TableHead className="text-right">Đã bán</TableHead>
              <TableHead>Thời gian bán</TableHead>
              <TableHead>Trạng thái</TableHead>
              <TableHead className="text-right">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredTickets.map((ticket) => (
              <TableRow key={ticket.id} className="border-white/10">
                <TableCell className="font-medium max-w-[200px] truncate">
                  {ticket.eventName}
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-lg bg-gradient-primary/20 flex items-center justify-center">
                      <Ticket className="h-4 w-4 text-primary" />
                    </div>
                    {ticket.ticketName}
                  </div>
                </TableCell>
                <TableCell className="text-right font-medium">
                  {ticket.price.toLocaleString()}đ
                </TableCell>
                <TableCell className="text-right">
                  <div>
                    <span className="font-medium">{ticket.sold}</span>
                    <span className="text-muted-foreground">/{ticket.total}</span>
                  </div>
                  <div className="w-16 h-1.5 bg-white/10 rounded-full mt-1 ml-auto">
                    <div
                      className="h-full bg-gradient-primary rounded-full"
                      style={{ width: `${(ticket.sold / ticket.total) * 100}%` }}
                    />
                  </div>
                </TableCell>
                <TableCell className="text-sm text-muted-foreground">
                  {ticket.startSale} - {ticket.endSale}
                </TableCell>
                <TableCell>
                  <Badge
                    variant="secondary"
                    className={cn(
                      "border-0",
                      statusConfig[ticket.status as keyof typeof statusConfig].color
                    )}
                  >
                    {statusConfig[ticket.status as keyof typeof statusConfig].label}
                  </Badge>
                </TableCell>
                <TableCell className="text-right">
                  <Button variant="ghost" size="icon" className="h-8 w-8">
                    <Edit className="h-4 w-4" />
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

export default ManageTickets;
