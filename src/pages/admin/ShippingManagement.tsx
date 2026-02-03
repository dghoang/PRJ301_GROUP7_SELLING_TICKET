import { useState } from "react";
import { motion } from "framer-motion";
import {
  Plus,
  Search,
  Truck,
  Edit,
  Trash2,
  ToggleLeft,
  ToggleRight,
  MapPin,
  DollarSign,
  Clock,
  Package,
} from "lucide-react";
import { AdminLayout } from "@/components/admin";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { staggerContainer, staggerItem } from "@/lib/animations";

const mockShippingProviders = [
  {
    id: 1,
    name: "Giao Hàng Nhanh",
    code: "GHN",
    logo: "/placeholder.svg",
    baseFee: 25000,
    feePerKm: 2000,
    estimatedDays: "2-3",
    regions: ["Toàn quốc"],
    status: true,
    ordersDelivered: 15840,
  },
  {
    id: 2,
    name: "Giao Hàng Tiết Kiệm",
    code: "GHTK",
    logo: "/placeholder.svg",
    baseFee: 18000,
    feePerKm: 1500,
    estimatedDays: "3-5",
    regions: ["Toàn quốc"],
    status: true,
    ordersDelivered: 12560,
  },
  {
    id: 3,
    name: "VNPost",
    code: "VNPOST",
    logo: "/placeholder.svg",
    baseFee: 15000,
    feePerKm: 1200,
    estimatedDays: "5-7",
    regions: ["Toàn quốc"],
    status: false,
    ordersDelivered: 8420,
  },
  {
    id: 4,
    name: "J&T Express",
    code: "JT",
    logo: "/placeholder.svg",
    baseFee: 22000,
    feePerKm: 1800,
    estimatedDays: "2-4",
    regions: ["HCM", "HN", "ĐN"],
    status: true,
    ordersDelivered: 9650,
  },
  {
    id: 5,
    name: "Ninja Van",
    code: "NINJA",
    logo: "/placeholder.svg",
    baseFee: 28000,
    feePerKm: 2200,
    estimatedDays: "1-2",
    regions: ["HCM", "HN"],
    status: true,
    ordersDelivered: 5230,
  },
];

const ShippingManagement = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [providers, setProviders] = useState(mockShippingProviders);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [editingProvider, setEditingProvider] = useState<typeof mockShippingProviders[0] | null>(null);

  const toggleStatus = (id: number) => {
    setProviders(
      providers.map((p) => (p.id === id ? { ...p, status: !p.status } : p))
    );
  };

  const filteredProviders = providers.filter((p) =>
    p.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <AdminLayout title="Quản lý vận chuyển" subtitle="Cấu hình đơn vị giao vé">
      <motion.div
        variants={staggerContainer}
        initial="initial"
        animate="animate"
        className="space-y-6"
      >
        {/* Stats */}
        <motion.div variants={staggerItem} className="grid gap-4 md:grid-cols-4">
          {[
            { label: "Đơn vị vận chuyển", value: providers.length, icon: Truck, gradient: "from-blue-500 to-cyan-500" },
            { label: "Đang hoạt động", value: providers.filter((p) => p.status).length, icon: ToggleRight, gradient: "from-emerald-500 to-teal-500" },
            { label: "Tổng đơn giao", value: "51,700+", icon: Package, gradient: "from-violet-500 to-purple-500" },
            { label: "Phí trung bình", value: "21,600đ", icon: DollarSign, gradient: "from-pink-500 to-rose-500" },
          ].map((stat, index) => (
            <motion.div
              key={stat.label}
              whileHover={{ y: -4, scale: 1.02 }}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 }}
            >
              <GlassCard className="p-4">
                <div className="flex items-center gap-4">
                  <div className={`rounded-xl bg-gradient-to-br ${stat.gradient} p-3`}>
                    <stat.icon className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold">{stat.value}</p>
                    <p className="text-sm text-muted-foreground">{stat.label}</p>
                  </div>
                </div>
              </GlassCard>
            </motion.div>
          ))}
        </motion.div>

        {/* Search and Add */}
        <motion.div variants={staggerItem}>
          <GlassCard className="p-4">
            <div className="flex flex-wrap gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Tìm đơn vị vận chuyển..."
                  className="pl-10"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              <Button
                className="btn-gradient text-white"
                onClick={() => setShowAddDialog(true)}
              >
                <Plus className="mr-2 h-4 w-4" />
                Thêm đơn vị
              </Button>
            </div>
          </GlassCard>
        </motion.div>

        {/* Provider Grid */}
        <motion.div
          variants={staggerItem}
          className="grid gap-4 md:grid-cols-2 lg:grid-cols-3"
        >
          {filteredProviders.map((provider, index) => (
            <motion.div
              key={provider.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 }}
              whileHover={{ y: -4 }}
            >
              <GlassCard className="p-6">
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 text-lg font-bold text-white">
                      {provider.code}
                    </div>
                    <div>
                      <h3 className="font-semibold">{provider.name}</h3>
                      <Badge variant="outline" className="mt-1">
                        {provider.code}
                      </Badge>
                    </div>
                  </div>
                  <Switch
                    checked={provider.status}
                    onCheckedChange={() => toggleStatus(provider.id)}
                  />
                </div>

                <div className="mt-4 space-y-3">
                  <div className="flex items-center justify-between text-sm">
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <DollarSign className="h-4 w-4" />
                      Phí cơ bản
                    </div>
                    <span className="font-medium">
                      {provider.baseFee.toLocaleString()}đ
                    </span>
                  </div>

                  <div className="flex items-center justify-between text-sm">
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <MapPin className="h-4 w-4" />
                      Phí/km
                    </div>
                    <span className="font-medium">
                      {provider.feePerKm.toLocaleString()}đ
                    </span>
                  </div>

                  <div className="flex items-center justify-between text-sm">
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Clock className="h-4 w-4" />
                      Thời gian giao
                    </div>
                    <span className="font-medium">{provider.estimatedDays} ngày</span>
                  </div>

                  <div className="flex items-center justify-between text-sm">
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Package className="h-4 w-4" />
                      Đã giao
                    </div>
                    <span className="font-medium">
                      {provider.ordersDelivered.toLocaleString()} đơn
                    </span>
                  </div>
                </div>

                <div className="mt-4 flex flex-wrap gap-1">
                  {provider.regions.map((region) => (
                    <Badge key={region} variant="secondary" className="text-xs">
                      {region}
                    </Badge>
                  ))}
                </div>

                <div className="mt-4 flex gap-2 border-t border-border/50 pt-4">
                  <Button
                    variant="outline"
                    size="sm"
                    className="flex-1"
                    onClick={() => setEditingProvider(provider)}
                  >
                    <Edit className="mr-2 h-4 w-4" />
                    Sửa
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    className="text-red-500 hover:bg-red-50"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </GlassCard>
            </motion.div>
          ))}
        </motion.div>
      </motion.div>

      {/* Add/Edit Dialog */}
      <Dialog
        open={showAddDialog || !!editingProvider}
        onOpenChange={(open) => {
          if (!open) {
            setShowAddDialog(false);
            setEditingProvider(null);
          }
        }}
      >
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>
              {editingProvider ? "Chỉnh sửa đơn vị" : "Thêm đơn vị vận chuyển"}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>Tên đơn vị</Label>
              <Input
                placeholder="VD: Giao Hàng Nhanh"
                defaultValue={editingProvider?.name}
              />
            </div>
            <div className="space-y-2">
              <Label>Mã đơn vị</Label>
              <Input placeholder="VD: GHN" defaultValue={editingProvider?.code} />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Phí cơ bản (VNĐ)</Label>
                <Input
                  type="number"
                  placeholder="25000"
                  defaultValue={editingProvider?.baseFee}
                />
              </div>
              <div className="space-y-2">
                <Label>Phí/km (VNĐ)</Label>
                <Input
                  type="number"
                  placeholder="2000"
                  defaultValue={editingProvider?.feePerKm}
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Thời gian giao dự kiến</Label>
              <Select defaultValue={editingProvider?.estimatedDays || "2-3"}>
                <SelectTrigger>
                  <SelectValue placeholder="Chọn thời gian" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="1-2">1-2 ngày</SelectItem>
                  <SelectItem value="2-3">2-3 ngày</SelectItem>
                  <SelectItem value="3-5">3-5 ngày</SelectItem>
                  <SelectItem value="5-7">5-7 ngày</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setShowAddDialog(false);
                setEditingProvider(null);
              }}
            >
              Hủy
            </Button>
            <Button className="btn-gradient text-white">
              {editingProvider ? "Cập nhật" : "Thêm đơn vị"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </AdminLayout>
  );
};

export default ShippingManagement;
