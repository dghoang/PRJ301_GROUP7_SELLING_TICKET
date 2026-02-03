import { useState } from "react";
import { OrganizerLayout } from "@/components/organizer";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
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
import { Plus, Tag, Search, Edit, Trash2, Copy } from "lucide-react";
import { cn } from "@/lib/utils";
import { useToast } from "@/hooks/use-toast";

const vouchers = [
  {
    id: 1,
    code: "SUMMER2024",
    name: "Khuyến mãi mùa hè",
    type: "percent",
    value: 20,
    used: 45,
    limit: 100,
    minTickets: 2,
    maxTickets: 10,
    startDate: "01/01/2024",
    endDate: "28/02/2024",
    status: true,
    event: "Concert ABC",
  },
  {
    id: 2,
    code: "EARLYBIRD",
    name: "Early Bird Discount",
    type: "fixed",
    value: 100000,
    used: 30,
    limit: 30,
    minTickets: 1,
    maxTickets: 5,
    startDate: "01/01/2024",
    endDate: "15/01/2024",
    status: false,
    event: "Workshop Khởi nghiệp",
  },
  {
    id: 3,
    code: "VIP50K",
    name: "Giảm giá VIP",
    type: "fixed",
    value: 50000,
    used: 0,
    limit: null,
    minTickets: 1,
    maxTickets: null,
    startDate: "15/02/2024",
    endDate: "01/03/2024",
    status: true,
    event: "Festival Mùa Xuân",
  },
];

const Vouchers = () => {
  const [searchQuery, setSearchQuery] = useState("");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const { toast } = useToast();

  const filteredVouchers = vouchers.filter(
    (v) =>
      v.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
      v.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const copyCode = (code: string) => {
    navigator.clipboard.writeText(code);
    toast({
      title: "Đã sao chép!",
      description: `Mã ${code} đã được sao chép vào clipboard`,
    });
  };

  return (
    <OrganizerLayout
      title="Mã giảm giá"
      subtitle="Tạo và quản lý voucher khuyến mãi"
      actions={
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger asChild>
            <GradientButton>
              <Plus className="h-4 w-4 mr-2" />
              Tạo mã mới
            </GradientButton>
          </DialogTrigger>
          <DialogContent className="glass-strong border-white/20 max-w-lg">
            <DialogHeader>
              <DialogTitle>Tạo mã giảm giá mới</DialogTitle>
            </DialogHeader>
            <div className="space-y-4 mt-4">
              <div>
                <Label>Mã voucher *</Label>
                <Input placeholder="VD: SUMMER2024" className="mt-1 glass-input" />
              </div>
              <div>
                <Label>Tên chương trình *</Label>
                <Input placeholder="VD: Khuyến mãi mùa hè" className="mt-1 glass-input" />
              </div>
              <div>
                <Label>Áp dụng cho sự kiện *</Label>
                <Select>
                  <SelectTrigger className="mt-1 glass-input">
                    <SelectValue placeholder="Chọn sự kiện" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Tất cả sự kiện</SelectItem>
                    <SelectItem value="concert">Concert ABC</SelectItem>
                    <SelectItem value="workshop">Workshop Khởi nghiệp</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label>Loại giảm giá *</Label>
                  <Select>
                    <SelectTrigger className="mt-1 glass-input">
                      <SelectValue placeholder="Chọn loại" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="percent">Phần trăm (%)</SelectItem>
                      <SelectItem value="fixed">Số tiền (VNĐ)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label>Mức giảm *</Label>
                  <Input type="number" placeholder="20" className="mt-1 glass-input" />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label>Ngày bắt đầu *</Label>
                  <Input type="date" className="mt-1 glass-input" />
                </div>
                <div>
                  <Label>Ngày kết thúc *</Label>
                  <Input type="date" className="mt-1 glass-input" />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label>Tổng lượt sử dụng</Label>
                  <Input
                    type="number"
                    placeholder="Không giới hạn"
                    className="mt-1 glass-input"
                  />
                </div>
                <div>
                  <Label>Max đơn/người</Label>
                  <Input
                    type="number"
                    placeholder="Không giới hạn"
                    className="mt-1 glass-input"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label>Min vé/đơn</Label>
                  <Input type="number" defaultValue={1} className="mt-1 glass-input" />
                </div>
                <div>
                  <Label>Max vé/đơn</Label>
                  <Input
                    type="number"
                    placeholder="Không giới hạn"
                    className="mt-1 glass-input"
                  />
                </div>
              </div>
              <div className="flex justify-end gap-3 pt-4">
                <Button
                  variant="outline"
                  onClick={() => setIsDialogOpen(false)}
                  className="glass"
                >
                  Hủy
                </Button>
                <GradientButton onClick={() => setIsDialogOpen(false)}>
                  Tạo mã
                </GradientButton>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      }
    >
      {/* Search */}
      <GlassCard className="p-4 mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Tìm kiếm mã giảm giá..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10 glass-input"
          />
        </div>
      </GlassCard>

      {/* Table */}
      <GlassCard className="overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="border-white/10 hover:bg-transparent">
              <TableHead>Mã / Tên</TableHead>
              <TableHead>Sự kiện</TableHead>
              <TableHead className="text-right">Giảm giá</TableHead>
              <TableHead className="text-right">Đã dùng</TableHead>
              <TableHead>Thời gian</TableHead>
              <TableHead>Trạng thái</TableHead>
              <TableHead className="text-right">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredVouchers.map((voucher) => (
              <TableRow key={voucher.id} className="border-white/10">
                <TableCell>
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-gradient-primary/20 flex items-center justify-center">
                      <Tag className="h-5 w-5 text-primary" />
                    </div>
                    <div>
                      <p className="font-mono font-bold">{voucher.code}</p>
                      <p className="text-sm text-muted-foreground">{voucher.name}</p>
                    </div>
                  </div>
                </TableCell>
                <TableCell className="text-sm">{voucher.event}</TableCell>
                <TableCell className="text-right font-medium">
                  {voucher.type === "percent"
                    ? `${voucher.value}%`
                    : `${voucher.value.toLocaleString()}đ`}
                </TableCell>
                <TableCell className="text-right">
                  <span className="font-medium">{voucher.used}</span>
                  <span className="text-muted-foreground">
                    /{voucher.limit || "∞"}
                  </span>
                </TableCell>
                <TableCell className="text-sm text-muted-foreground">
                  {voucher.startDate} - {voucher.endDate}
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Switch checked={voucher.status} />
                    <Badge
                      variant="secondary"
                      className={cn(
                        "border-0",
                        voucher.status
                          ? "bg-green-500/20 text-green-400"
                          : "bg-gray-500/20 text-gray-400"
                      )}
                    >
                      {voucher.status ? "Đang bật" : "Đã tắt"}
                    </Badge>
                  </div>
                </TableCell>
                <TableCell className="text-right">
                  <div className="flex items-center justify-end gap-1">
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8"
                      onClick={() => copyCode(voucher.code)}
                    >
                      <Copy className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="icon" className="h-8 w-8">
                      <Edit className="h-4 w-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8 text-red-400 hover:text-red-500"
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </GlassCard>
    </OrganizerLayout>
  );
};

export default Vouchers;
