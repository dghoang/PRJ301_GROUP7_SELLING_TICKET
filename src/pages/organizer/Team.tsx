import { useState } from "react";
import { OrganizerLayout } from "@/components/organizer";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
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
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Badge } from "@/components/ui/badge";
import {
  Plus,
  MoreVertical,
  Mail,
  Shield,
  Eye,
  QrCode,
  Edit,
  Trash2,
  UserPlus,
} from "lucide-react";
import { cn } from "@/lib/utils";

const teamMembers = [
  {
    id: 1,
    name: "Nguyễn Văn A",
    email: "nguyenvana@email.com",
    role: "admin",
    avatar: null,
    addedDate: "01/01/2024",
    lastActive: "Hôm nay",
  },
  {
    id: 2,
    name: "Trần Thị B",
    email: "tranthib@email.com",
    role: "manager",
    avatar: null,
    addedDate: "05/01/2024",
    lastActive: "Hôm qua",
  },
  {
    id: 3,
    name: "Lê Văn C",
    email: "levanc@email.com",
    role: "checkin",
    avatar: null,
    addedDate: "10/01/2024",
    lastActive: "3 ngày trước",
  },
  {
    id: 4,
    name: "Phạm Thị D",
    email: "phamthid@email.com",
    role: "viewer",
    avatar: null,
    addedDate: "12/01/2024",
    lastActive: "1 tuần trước",
  },
];

const roleConfig = {
  admin: {
    label: "Quản trị viên",
    color: "bg-red-500/20 text-red-400",
    icon: Shield,
    description: "Toàn quyền quản lý",
  },
  manager: {
    label: "Quản lý",
    color: "bg-purple-500/20 text-purple-400",
    icon: Edit,
    description: "Chỉnh sửa sự kiện, vé, voucher",
  },
  checkin: {
    label: "Check-in",
    color: "bg-blue-500/20 text-blue-400",
    icon: QrCode,
    description: "Chỉ soát vé tại sự kiện",
  },
  viewer: {
    label: "Xem báo cáo",
    color: "bg-green-500/20 text-green-400",
    icon: Eye,
    description: "Chỉ xem thống kê, báo cáo",
  },
};

const Team = () => {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [newMemberEmail, setNewMemberEmail] = useState("");
  const [newMemberRole, setNewMemberRole] = useState("");

  return (
    <OrganizerLayout
      title="Điều hành viên"
      subtitle="Quản lý thành viên trong ban tổ chức"
      actions={
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger asChild>
            <GradientButton>
              <UserPlus className="h-4 w-4 mr-2" />
              Thêm thành viên
            </GradientButton>
          </DialogTrigger>
          <DialogContent className="glass-strong border-white/20 max-w-md">
            <DialogHeader>
              <DialogTitle>Thêm điều hành viên</DialogTitle>
            </DialogHeader>
            <div className="space-y-4 mt-4">
              <div>
                <Label>Email *</Label>
                <Input
                  type="email"
                  value={newMemberEmail}
                  onChange={(e) => setNewMemberEmail(e.target.value)}
                  placeholder="email@example.com"
                  className="mt-1 glass-input"
                />
              </div>
              <div>
                <Label>Vai trò *</Label>
                <Select value={newMemberRole} onValueChange={setNewMemberRole}>
                  <SelectTrigger className="mt-1 glass-input">
                    <SelectValue placeholder="Chọn vai trò" />
                  </SelectTrigger>
                  <SelectContent>
                    {Object.entries(roleConfig).map(([key, config]) => (
                      <SelectItem key={key} value={key}>
                        <div className="flex items-center gap-2">
                          <config.icon className="h-4 w-4" />
                          <span>{config.label}</span>
                        </div>
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {newMemberRole && (
                  <p className="text-xs text-muted-foreground mt-2">
                    {roleConfig[newMemberRole as keyof typeof roleConfig].description}
                  </p>
                )}
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
                  Gửi lời mời
                </GradientButton>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      }
    >
      {/* Role Legend */}
      <GlassCard className="p-4 mb-6">
        <h3 className="font-medium mb-3">Phân quyền vai trò</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {Object.entries(roleConfig).map(([key, config]) => (
            <div
              key={key}
              className="flex items-start gap-3 p-3 rounded-xl bg-white/5"
            >
              <div className={cn("p-2 rounded-lg", config.color)}>
                <config.icon className="h-4 w-4" />
              </div>
              <div>
                <p className="font-medium text-sm">{config.label}</p>
                <p className="text-xs text-muted-foreground">{config.description}</p>
              </div>
            </div>
          ))}
        </div>
      </GlassCard>

      {/* Team Members */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {teamMembers.map((member) => {
          const role = roleConfig[member.role as keyof typeof roleConfig];
          return (
            <GlassCard key={member.id} className="p-4">
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-full bg-gradient-primary flex items-center justify-center text-white font-bold">
                    {member.name
                      .split(" ")
                      .map((n) => n[0])
                      .join("")
                      .slice(0, 2)}
                  </div>
                  <div>
                    <p className="font-semibold">{member.name}</p>
                    <div className="flex items-center gap-1 text-sm text-muted-foreground">
                      <Mail className="h-3 w-3" />
                      {member.email}
                    </div>
                  </div>
                </div>
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="ghost" size="icon" className="h-8 w-8">
                      <MoreVertical className="h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem>
                      <Edit className="h-4 w-4 mr-2" />
                      Đổi vai trò
                    </DropdownMenuItem>
                    <DropdownMenuItem className="text-red-400">
                      <Trash2 className="h-4 w-4 mr-2" />
                      Xóa khỏi nhóm
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>

              <div className="flex items-center justify-between mt-4 pt-4 border-t border-white/10">
                <Badge variant="secondary" className={cn("border-0", role.color)}>
                  <role.icon className="h-3 w-3 mr-1" />
                  {role.label}
                </Badge>
                <div className="text-xs text-muted-foreground">
                  <span>Hoạt động: {member.lastActive}</span>
                </div>
              </div>
            </GlassCard>
          );
        })}
      </div>
    </OrganizerLayout>
  );
};

export default Team;
