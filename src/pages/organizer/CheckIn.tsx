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
import { Badge } from "@/components/ui/badge";
import {
  QrCode,
  Search,
  Camera,
  CheckCircle2,
  XCircle,
  Users,
  Ticket,
  Clock,
  RefreshCw,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useToast } from "@/hooks/use-toast";

const recentCheckins = [
  {
    id: 1,
    ticketCode: "TKT001234",
    customerName: "Nguyễn Văn A",
    ticketType: "VIP",
    checkInTime: "14:30:25",
    status: "success",
  },
  {
    id: 2,
    ticketCode: "TKT001235",
    customerName: "Trần Thị B",
    ticketType: "Premium",
    checkInTime: "14:28:10",
    status: "success",
  },
  {
    id: 3,
    ticketCode: "TKT001236",
    customerName: "Lê Văn C",
    ticketType: "Standard",
    checkInTime: "14:25:45",
    status: "failed",
    reason: "Vé đã được sử dụng",
  },
  {
    id: 4,
    ticketCode: "TKT001237",
    customerName: "Phạm Thị D",
    ticketType: "VIP",
    checkInTime: "14:22:30",
    status: "success",
  },
];

const CheckIn = () => {
  const [selectedEvent, setSelectedEvent] = useState("concert-abc");
  const [searchCode, setSearchCode] = useState("");
  const [isScanning, setIsScanning] = useState(false);
  const { toast } = useToast();

  const stats = {
    total: 1000,
    checkedIn: 456,
    remaining: 544,
  };

  const handleManualCheckIn = () => {
    if (!searchCode) {
      toast({
        title: "Lỗi",
        description: "Vui lòng nhập mã vé",
        variant: "destructive",
      });
      return;
    }

    // Simulate check-in
    toast({
      title: "Check-in thành công!",
      description: `Mã vé ${searchCode} đã được xác nhận`,
    });
    setSearchCode("");
  };

  const toggleScanner = () => {
    setIsScanning(!isScanning);
    if (!isScanning) {
      toast({
        title: "Bật quét QR",
        description: "Đưa mã QR vào khung hình để quét",
      });
    }
  };

  return (
    <OrganizerLayout
      title="Soát vé"
      subtitle="Quét QR hoặc tìm kiếm vé thủ công"
      actions={
        <Select value={selectedEvent} onValueChange={setSelectedEvent}>
          <SelectTrigger className="w-56 glass-input">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="concert-abc">Concert ABC - Suất 19:00</SelectItem>
            <SelectItem value="concert-abc-2">Concert ABC - Suất 21:00</SelectItem>
            <SelectItem value="workshop">Workshop Khởi nghiệp</SelectItem>
          </SelectContent>
        </Select>
      }
    >
      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <GlassCard className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-primary/20 flex items-center justify-center">
              <Ticket className="h-5 w-5 text-primary" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Tổng vé</p>
              <p className="text-xl font-bold">{stats.total.toLocaleString()}</p>
            </div>
          </div>
        </GlassCard>
        <GlassCard className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-green-500/20 flex items-center justify-center">
              <CheckCircle2 className="h-5 w-5 text-green-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Đã check-in</p>
              <p className="text-xl font-bold">
                {stats.checkedIn.toLocaleString()}
                <span className="text-sm font-normal text-muted-foreground ml-1">
                  ({Math.round((stats.checkedIn / stats.total) * 100)}%)
                </span>
              </p>
            </div>
          </div>
        </GlassCard>
        <GlassCard className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center">
              <Users className="h-5 w-5 text-blue-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Còn lại</p>
              <p className="text-xl font-bold">{stats.remaining.toLocaleString()}</p>
            </div>
          </div>
        </GlassCard>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* QR Scanner */}
        <GlassCard className="p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold">Quét mã QR</h3>
            <Button
              variant="outline"
              size="sm"
              className={cn("glass", isScanning && "bg-primary/20")}
              onClick={toggleScanner}
            >
              <Camera className="h-4 w-4 mr-2" />
              {isScanning ? "Dừng quét" : "Bật camera"}
            </Button>
          </div>

          <div
            className={cn(
              "aspect-square max-w-sm mx-auto rounded-2xl border-2 border-dashed flex items-center justify-center transition-all",
              isScanning
                ? "border-primary bg-primary/5"
                : "border-white/20 bg-white/5"
            )}
          >
            {isScanning ? (
              <div className="text-center">
                <div className="relative">
                  <QrCode className="h-24 w-24 text-primary animate-pulse" />
                  <div className="absolute inset-0 border-2 border-primary rounded-lg animate-ping" />
                </div>
                <p className="mt-4 text-sm text-muted-foreground">
                  Đang quét... Đưa mã QR vào khung hình
                </p>
              </div>
            ) : (
              <div className="text-center">
                <QrCode className="h-16 w-16 mx-auto text-muted-foreground mb-3" />
                <p className="text-sm text-muted-foreground">
                  Nhấn "Bật camera" để quét mã QR
                </p>
              </div>
            )}
          </div>

          {/* Manual Search */}
          <div className="mt-6 pt-6 border-t border-white/10">
            <h4 className="font-medium mb-3">Tìm kiếm thủ công</h4>
            <div className="flex gap-2">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Nhập mã vé..."
                  value={searchCode}
                  onChange={(e) => setSearchCode(e.target.value)}
                  className="pl-10 glass-input"
                  onKeyDown={(e) => e.key === "Enter" && handleManualCheckIn()}
                />
              </div>
              <GradientButton onClick={handleManualCheckIn}>
                Check-in
              </GradientButton>
            </div>
          </div>
        </GlassCard>

        {/* Recent Check-ins */}
        <GlassCard className="p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold">Lịch sử check-in</h3>
            <Button variant="ghost" size="sm" className="text-muted-foreground">
              <RefreshCw className="h-4 w-4 mr-1" />
              Làm mới
            </Button>
          </div>

          <div className="space-y-3">
            {recentCheckins.map((checkin) => (
              <div
                key={checkin.id}
                className={cn(
                  "p-3 rounded-xl transition-colors",
                  checkin.status === "success"
                    ? "bg-green-500/10 border border-green-500/20"
                    : "bg-red-500/10 border border-red-500/20"
                )}
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <div
                      className={cn(
                        "w-10 h-10 rounded-full flex items-center justify-center",
                        checkin.status === "success"
                          ? "bg-green-500/20"
                          : "bg-red-500/20"
                      )}
                    >
                      {checkin.status === "success" ? (
                        <CheckCircle2 className="h-5 w-5 text-green-400" />
                      ) : (
                        <XCircle className="h-5 w-5 text-red-400" />
                      )}
                    </div>
                    <div>
                      <p className="font-medium">{checkin.customerName}</p>
                      <p className="text-xs text-muted-foreground font-mono">
                        {checkin.ticketCode}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <Badge
                      variant="secondary"
                      className="bg-white/10 border-0 text-xs"
                    >
                      {checkin.ticketType}
                    </Badge>
                    <div className="flex items-center gap-1 text-xs text-muted-foreground mt-1">
                      <Clock className="h-3 w-3" />
                      {checkin.checkInTime}
                    </div>
                  </div>
                </div>
                {checkin.status === "failed" && checkin.reason && (
                  <p className="text-xs text-red-400 mt-2 pl-13">
                    Lý do: {checkin.reason}
                  </p>
                )}
              </div>
            ))}
          </div>

          {/* Progress Bar */}
          <div className="mt-6 pt-4 border-t border-white/10">
            <div className="flex items-center justify-between text-sm mb-2">
              <span className="text-muted-foreground">Tiến độ check-in</span>
              <span className="font-medium">
                {Math.round((stats.checkedIn / stats.total) * 100)}%
              </span>
            </div>
            <div className="h-3 bg-white/10 rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-primary rounded-full transition-all"
                style={{ width: `${(stats.checkedIn / stats.total) * 100}%` }}
              />
            </div>
          </div>
        </GlassCard>
      </div>
    </OrganizerLayout>
  );
};

export default CheckIn;
