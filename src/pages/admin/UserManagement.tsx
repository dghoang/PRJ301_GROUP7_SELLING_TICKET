import { useState } from "react";
import { motion } from "framer-motion";
import {
  Search,
  Filter,
  MoreHorizontal,
  UserCheck,
  UserX,
  Shield,
  Building2,
  Mail,
  Phone,
  Calendar,
  Eye,
  Ban,
  Unlock,
} from "lucide-react";
import { AdminLayout } from "@/components/admin";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { staggerContainer, staggerItem } from "@/lib/animations";

const mockCustomers = [
  {
    id: 1,
    name: "Nguyễn Văn A",
    email: "nguyenvana@email.com",
    phone: "0901234567",
    joinedAt: "15/01/2025",
    ticketsBought: 12,
    totalSpent: "4,500,000",
    status: "active",
    avatar: "/placeholder.svg",
  },
  {
    id: 2,
    name: "Trần Thị B",
    email: "tranthib@email.com",
    phone: "0912345678",
    joinedAt: "20/01/2025",
    ticketsBought: 8,
    totalSpent: "2,800,000",
    status: "active",
    avatar: "/placeholder.svg",
  },
  {
    id: 3,
    name: "Lê Văn C",
    email: "levanc@email.com",
    phone: "0923456789",
    joinedAt: "25/01/2025",
    ticketsBought: 3,
    totalSpent: "950,000",
    status: "banned",
    avatar: "/placeholder.svg",
  },
];

const mockOrganizers = [
  {
    id: 1,
    name: "Live Nation Vietnam",
    email: "contact@livenation.vn",
    phone: "02812345678",
    joinedAt: "01/12/2024",
    eventsCreated: 25,
    totalRevenue: "2,500,000,000",
    status: "verified",
    avatar: "/placeholder.svg",
  },
  {
    id: 2,
    name: "TechVN Community",
    email: "info@techvn.org",
    phone: "02823456789",
    joinedAt: "15/12/2024",
    eventsCreated: 12,
    totalRevenue: "450,000,000",
    status: "active",
    avatar: "/placeholder.svg",
  },
  {
    id: 3,
    name: "Art Gallery X",
    email: "hello@galleryx.vn",
    phone: "02834567890",
    joinedAt: "10/01/2025",
    eventsCreated: 5,
    totalRevenue: "120,000,000",
    status: "pending",
    avatar: "/placeholder.svg",
  },
];

const UserManagement = () => {
  const [searchTerm, setSearchTerm] = useState("");

  const getStatusBadge = (status: string, type: "customer" | "organizer") => {
    if (type === "customer") {
      switch (status) {
        case "active":
          return (
            <Badge className="bg-emerald-100 text-emerald-700">
              <UserCheck className="mr-1 h-3 w-3" />
              Hoạt động
            </Badge>
          );
        case "banned":
          return (
            <Badge className="bg-red-100 text-red-700">
              <UserX className="mr-1 h-3 w-3" />
              Đã khóa
            </Badge>
          );
        default:
          return null;
      }
    } else {
      switch (status) {
        case "verified":
          return (
            <Badge className="bg-blue-100 text-blue-700">
              <Shield className="mr-1 h-3 w-3" />
              Đã xác thực
            </Badge>
          );
        case "active":
          return (
            <Badge className="bg-emerald-100 text-emerald-700">
              <UserCheck className="mr-1 h-3 w-3" />
              Hoạt động
            </Badge>
          );
        case "pending":
          return (
            <Badge className="bg-amber-100 text-amber-700">
              <Building2 className="mr-1 h-3 w-3" />
              Chờ xác thực
            </Badge>
          );
        default:
          return null;
      }
    }
  };

  return (
    <AdminLayout title="Quản lý người dùng" subtitle="Quản lý khách hàng và ban tổ chức">
      <motion.div
        variants={staggerContainer}
        initial="initial"
        animate="animate"
        className="space-y-6"
      >
        {/* Stats */}
        <motion.div variants={staggerItem} className="grid gap-4 md:grid-cols-4">
          {[
            { label: "Tổng khách hàng", value: "125,842", icon: UserCheck, gradient: "from-blue-500 to-cyan-500" },
            { label: "Ban tổ chức", value: "1,284", icon: Building2, gradient: "from-violet-500 to-purple-500" },
            { label: "Đang hoạt động", value: "124,558", icon: UserCheck, gradient: "from-emerald-500 to-teal-500" },
            { label: "Đã khóa", value: "156", icon: UserX, gradient: "from-red-500 to-rose-500" },
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

        {/* Search */}
        <motion.div variants={staggerItem}>
          <GlassCard className="p-4">
            <div className="flex flex-wrap gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Tìm theo tên, email, số điện thoại..."
                  className="pl-10"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              <Button variant="outline">
                <Filter className="mr-2 h-4 w-4" />
                Bộ lọc
              </Button>
            </div>
          </GlassCard>
        </motion.div>

        {/* Tabs */}
        <motion.div variants={staggerItem}>
          <Tabs defaultValue="customers" className="w-full">
            <TabsList className="glass mb-4">
              <TabsTrigger value="customers" className="gap-2">
                <UserCheck className="h-4 w-4" />
                Khách hàng
              </TabsTrigger>
              <TabsTrigger value="organizers" className="gap-2">
                <Building2 className="h-4 w-4" />
                Ban tổ chức
              </TabsTrigger>
            </TabsList>

            <TabsContent value="customers">
              <GlassCard className="overflow-hidden">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Người dùng</TableHead>
                      <TableHead>Liên hệ</TableHead>
                      <TableHead>Ngày tham gia</TableHead>
                      <TableHead>Vé đã mua</TableHead>
                      <TableHead>Tổng chi tiêu</TableHead>
                      <TableHead>Trạng thái</TableHead>
                      <TableHead className="w-12"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {mockCustomers.map((customer, index) => (
                      <motion.tr
                        key={customer.id}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.05 }}
                        className="group"
                      >
                        <TableCell>
                          <div className="flex items-center gap-3">
                            <Avatar className="h-10 w-10">
                              <AvatarImage src={customer.avatar} />
                              <AvatarFallback>{customer.name[0]}</AvatarFallback>
                            </Avatar>
                            <span className="font-medium">{customer.name}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="space-y-1 text-sm">
                            <div className="flex items-center gap-1 text-muted-foreground">
                              <Mail className="h-3 w-3" />
                              {customer.email}
                            </div>
                            <div className="flex items-center gap-1 text-muted-foreground">
                              <Phone className="h-3 w-3" />
                              {customer.phone}
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-1 text-sm text-muted-foreground">
                            <Calendar className="h-3 w-3" />
                            {customer.joinedAt}
                          </div>
                        </TableCell>
                        <TableCell className="font-medium">{customer.ticketsBought}</TableCell>
                        <TableCell className="font-medium">{customer.totalSpent}đ</TableCell>
                        <TableCell>{getStatusBadge(customer.status, "customer")}</TableCell>
                        <TableCell>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem>
                                <Eye className="mr-2 h-4 w-4" />
                                Xem chi tiết
                              </DropdownMenuItem>
                              <DropdownMenuSeparator />
                              {customer.status === "active" ? (
                                <DropdownMenuItem className="text-red-500">
                                  <Ban className="mr-2 h-4 w-4" />
                                  Khóa tài khoản
                                </DropdownMenuItem>
                              ) : (
                                <DropdownMenuItem className="text-emerald-500">
                                  <Unlock className="mr-2 h-4 w-4" />
                                  Mở khóa
                                </DropdownMenuItem>
                              )}
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      </motion.tr>
                    ))}
                  </TableBody>
                </Table>
              </GlassCard>
            </TabsContent>

            <TabsContent value="organizers">
              <GlassCard className="overflow-hidden">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Tổ chức</TableHead>
                      <TableHead>Liên hệ</TableHead>
                      <TableHead>Ngày tham gia</TableHead>
                      <TableHead>Sự kiện</TableHead>
                      <TableHead>Doanh thu</TableHead>
                      <TableHead>Trạng thái</TableHead>
                      <TableHead className="w-12"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {mockOrganizers.map((org, index) => (
                      <motion.tr
                        key={org.id}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.05 }}
                        className="group"
                      >
                        <TableCell>
                          <div className="flex items-center gap-3">
                            <Avatar className="h-10 w-10">
                              <AvatarImage src={org.avatar} />
                              <AvatarFallback>{org.name[0]}</AvatarFallback>
                            </Avatar>
                            <span className="font-medium">{org.name}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="space-y-1 text-sm">
                            <div className="flex items-center gap-1 text-muted-foreground">
                              <Mail className="h-3 w-3" />
                              {org.email}
                            </div>
                            <div className="flex items-center gap-1 text-muted-foreground">
                              <Phone className="h-3 w-3" />
                              {org.phone}
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-1 text-sm text-muted-foreground">
                            <Calendar className="h-3 w-3" />
                            {org.joinedAt}
                          </div>
                        </TableCell>
                        <TableCell className="font-medium">{org.eventsCreated}</TableCell>
                        <TableCell className="font-medium">{org.totalRevenue}đ</TableCell>
                        <TableCell>{getStatusBadge(org.status, "organizer")}</TableCell>
                        <TableCell>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem>
                                <Eye className="mr-2 h-4 w-4" />
                                Xem chi tiết
                              </DropdownMenuItem>
                              {org.status === "pending" && (
                                <DropdownMenuItem className="text-blue-500">
                                  <Shield className="mr-2 h-4 w-4" />
                                  Xác thực
                                </DropdownMenuItem>
                              )}
                              <DropdownMenuSeparator />
                              <DropdownMenuItem className="text-red-500">
                                <Ban className="mr-2 h-4 w-4" />
                                Khóa tài khoản
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      </motion.tr>
                    ))}
                  </TableBody>
                </Table>
              </GlassCard>
            </TabsContent>
          </Tabs>
        </motion.div>
      </motion.div>
    </AdminLayout>
  );
};

export default UserManagement;
