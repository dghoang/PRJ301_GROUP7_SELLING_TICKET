import { useState } from "react";
import { OrganizerLayout } from "@/components/organizer";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
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
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Plus,
  Search,
  MoreVertical,
  Edit,
  Copy,
  Pause,
  Trash2,
  Eye,
  Calendar,
  Ticket,
  Users,
} from "lucide-react";
import { Link } from "react-router-dom";
import { cn } from "@/lib/utils";

const events = [
  {
    id: 1,
    name: "Concert ABC - Đêm nhạc trẻ",
    image: "https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=300",
    date: "15/02/2024",
    status: "active",
    ticketsSold: 850,
    totalTickets: 1000,
    revenue: 125500000,
    views: 12500,
  },
  {
    id: 2,
    name: "Workshop Khởi nghiệp 2024",
    image: "https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=300",
    date: "20/02/2024",
    status: "active",
    ticketsSold: 45,
    totalTickets: 100,
    revenue: 22500000,
    views: 3200,
  },
  {
    id: 3,
    name: "Festival Mùa Xuân",
    image: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=300",
    date: "01/03/2024",
    status: "pending",
    ticketsSold: 0,
    totalTickets: 500,
    revenue: 0,
    views: 0,
  },
  {
    id: 4,
    name: "Hội thảo AI & Future",
    image: "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=300",
    date: "10/03/2024",
    status: "draft",
    ticketsSold: 0,
    totalTickets: 200,
    revenue: 0,
    views: 0,
  },
  {
    id: 5,
    name: "Đêm nhạc acoustic",
    image: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=300",
    date: "05/01/2024",
    status: "ended",
    ticketsSold: 200,
    totalTickets: 200,
    revenue: 40000000,
    views: 8900,
  },
];

const statusConfig = {
  draft: { label: "Nháp", color: "bg-gray-500/20 text-gray-400" },
  pending: { label: "Chờ duyệt", color: "bg-yellow-500/20 text-yellow-400" },
  active: { label: "Đang bán", color: "bg-green-500/20 text-green-400" },
  paused: { label: "Tạm dừng", color: "bg-orange-500/20 text-orange-400" },
  ended: { label: "Đã kết thúc", color: "bg-blue-500/20 text-blue-400" },
};

const ManageEvents = () => {
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");

  const filteredEvents = events.filter((event) => {
    const matchesSearch = event.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === "all" || event.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  return (
    <OrganizerLayout
      title="Quản lý sự kiện"
      subtitle="Xem và quản lý tất cả sự kiện của bạn"
      actions={
        <Link to="/organizer/create-event">
          <GradientButton>
            <Plus className="h-4 w-4 mr-2" />
            Tạo sự kiện mới
          </GradientButton>
        </Link>
      }
    >
      {/* Filters */}
      <GlassCard className="p-4 mb-6">
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Tìm kiếm sự kiện..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 glass-input"
            />
          </div>
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="w-full sm:w-48 glass-input">
              <SelectValue placeholder="Trạng thái" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Tất cả trạng thái</SelectItem>
              <SelectItem value="draft">Nháp</SelectItem>
              <SelectItem value="pending">Chờ duyệt</SelectItem>
              <SelectItem value="active">Đang bán</SelectItem>
              <SelectItem value="paused">Tạm dừng</SelectItem>
              <SelectItem value="ended">Đã kết thúc</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </GlassCard>

      {/* Events List */}
      <div className="space-y-4">
        {filteredEvents.map((event) => (
          <GlassCard key={event.id} className="p-4 hover:bg-white/10 transition-colors">
            <div className="flex flex-col lg:flex-row gap-4">
              {/* Image */}
              <div className="w-full lg:w-48 h-32 rounded-xl overflow-hidden flex-shrink-0">
                <img
                  src={event.image}
                  alt={event.name}
                  className="w-full h-full object-cover"
                />
              </div>

              {/* Info */}
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <h3 className="font-semibold text-lg truncate">{event.name}</h3>
                    <div className="flex items-center gap-2 mt-1">
                      <Calendar className="h-4 w-4 text-muted-foreground" />
                      <span className="text-sm text-muted-foreground">{event.date}</span>
                      <span
                        className={cn(
                          "text-xs px-2 py-0.5 rounded-full",
                          statusConfig[event.status as keyof typeof statusConfig].color
                        )}
                      >
                        {statusConfig[event.status as keyof typeof statusConfig].label}
                      </span>
                    </div>
                  </div>

                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon" className="flex-shrink-0">
                        <MoreVertical className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem>
                        <Eye className="h-4 w-4 mr-2" />
                        Xem chi tiết
                      </DropdownMenuItem>
                      <DropdownMenuItem>
                        <Edit className="h-4 w-4 mr-2" />
                        Chỉnh sửa
                      </DropdownMenuItem>
                      <DropdownMenuItem>
                        <Copy className="h-4 w-4 mr-2" />
                        Sao chép
                      </DropdownMenuItem>
                      <DropdownMenuItem>
                        <Pause className="h-4 w-4 mr-2" />
                        Tạm dừng
                      </DropdownMenuItem>
                      <DropdownMenuItem className="text-red-400">
                        <Trash2 className="h-4 w-4 mr-2" />
                        Xóa
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>

                {/* Stats */}
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-4">
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-lg bg-primary/20 flex items-center justify-center">
                      <Ticket className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Đã bán</p>
                      <p className="font-medium">
                        {event.ticketsSold}/{event.totalTickets}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-lg bg-green-500/20 flex items-center justify-center">
                      <span className="text-sm font-bold text-green-400">₫</span>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Doanh thu</p>
                      <p className="font-medium">
                        {(event.revenue / 1000000).toFixed(1)}M
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-lg bg-blue-500/20 flex items-center justify-center">
                      <Eye className="h-4 w-4 text-blue-400" />
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Lượt xem</p>
                      <p className="font-medium">{event.views.toLocaleString()}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-lg bg-purple-500/20 flex items-center justify-center">
                      <Users className="h-4 w-4 text-purple-400" />
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Tỉ lệ bán</p>
                      <p className="font-medium">
                        {Math.round((event.ticketsSold / event.totalTickets) * 100)}%
                      </p>
                    </div>
                  </div>
                </div>

                {/* Progress Bar */}
                <div className="mt-4">
                  <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-gradient-primary rounded-full transition-all"
                      style={{
                        width: `${(event.ticketsSold / event.totalTickets) * 100}%`,
                      }}
                    />
                  </div>
                </div>
              </div>
            </div>
          </GlassCard>
        ))}
      </div>

      {filteredEvents.length === 0 && (
        <GlassCard className="p-12 text-center">
          <Calendar className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
          <h3 className="font-semibold text-lg mb-2">Không tìm thấy sự kiện</h3>
          <p className="text-muted-foreground mb-4">
            Thử thay đổi bộ lọc hoặc tạo sự kiện mới
          </p>
          <Link to="/organizer/create-event">
            <GradientButton>
              <Plus className="h-4 w-4 mr-2" />
              Tạo sự kiện mới
            </GradientButton>
          </Link>
        </GlassCard>
      )}
    </OrganizerLayout>
  );
};

export default ManageEvents;
