import { useState } from "react";
import { OrganizerLayout } from "@/components/organizer";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { cn } from "@/lib/utils";
import {
  FileText,
  Image,
  MapPin,
  Building2,
  CalendarDays,
  Ticket,
  Settings,
  CreditCard,
  Check,
  ChevronLeft,
  ChevronRight,
  Upload,
  Plus,
  Trash2,
  Globe,
  Lock,
} from "lucide-react";

const steps = [
  { id: 1, title: "Thông tin cơ bản", icon: FileText },
  { id: 2, title: "Hình ảnh", icon: Image },
  { id: 3, title: "Địa điểm", icon: MapPin },
  { id: 4, title: "Ban tổ chức", icon: Building2 },
  { id: 5, title: "Lịch diễn", icon: CalendarDays },
  { id: 6, title: "Cấu hình vé", icon: Ticket },
  { id: 7, title: "Tùy chỉnh", icon: Settings },
  { id: 8, title: "Thanh toán", icon: CreditCard },
];

const categories = [
  "Âm nhạc",
  "Workshop",
  "Thể thao",
  "Nghệ thuật",
  "Công nghệ",
  "Kinh doanh",
  "Giáo dục",
  "Khác",
];

const CreateEvent = () => {
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState({
    // Step 1: Basic Info
    name: "",
    category: "",
    description: "",
    // Step 2: Images
    logo: null as File | null,
    banner: null as File | null,
    // Step 3: Location
    locationType: "offline",
    venueName: "",
    province: "",
    district: "",
    ward: "",
    address: "",
    onlineUrl: "",
    // Step 4: Organizer
    organizerName: "",
    organizerLogo: null as File | null,
    organizerDescription: "",
    // Step 5: Schedule
    shows: [{ id: 1, startDate: "", startTime: "", endDate: "", endTime: "" }],
    // Step 6: Tickets
    ticketTypes: [
      { id: 1, name: "", price: "", minQty: 1, maxQty: 10, quantity: "", description: "", startSale: "", endSale: "" },
    ],
    // Step 7: Settings
    customUrl: "",
    privacy: "public",
    accessCode: "",
    // Step 8: Payment
    accountName: "",
    accountNumber: "",
    bankName: "",
    bankBranch: "",
    needInvoice: false,
    businessType: "",
    companyName: "",
    companyAddress: "",
    taxCode: "",
  });

  const updateFormData = (field: string, value: any) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const addShow = () => {
    const newId = formData.shows.length + 1;
    setFormData((prev) => ({
      ...prev,
      shows: [...prev.shows, { id: newId, startDate: "", startTime: "", endDate: "", endTime: "" }],
    }));
  };

  const removeShow = (id: number) => {
    setFormData((prev) => ({
      ...prev,
      shows: prev.shows.filter((s) => s.id !== id),
    }));
  };

  const addTicketType = () => {
    const newId = formData.ticketTypes.length + 1;
    setFormData((prev) => ({
      ...prev,
      ticketTypes: [
        ...prev.ticketTypes,
        { id: newId, name: "", price: "", minQty: 1, maxQty: 10, quantity: "", description: "", startSale: "", endSale: "" },
      ],
    }));
  };

  const removeTicketType = (id: number) => {
    setFormData((prev) => ({
      ...prev,
      ticketTypes: prev.ticketTypes.filter((t) => t.id !== id),
    }));
  };

  const nextStep = () => {
    if (currentStep < steps.length) {
      setCurrentStep(currentStep + 1);
    }
  };

  const prevStep = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
    }
  };

  const renderStepContent = () => {
    switch (currentStep) {
      case 1:
        return (
          <div className="space-y-6">
            <div>
              <Label htmlFor="name">Tên sự kiện *</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => updateFormData("name", e.target.value)}
                placeholder="Nhập tên sự kiện"
                className="mt-2 glass-input"
              />
            </div>
            <div>
              <Label htmlFor="category">Thể loại *</Label>
              <Select value={formData.category} onValueChange={(v) => updateFormData("category", v)}>
                <SelectTrigger className="mt-2 glass-input">
                  <SelectValue placeholder="Chọn thể loại" />
                </SelectTrigger>
                <SelectContent>
                  {categories.map((cat) => (
                    <SelectItem key={cat} value={cat}>
                      {cat}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="description">Mô tả sự kiện *</Label>
              <Textarea
                id="description"
                value={formData.description}
                onChange={(e) => updateFormData("description", e.target.value)}
                placeholder="Mô tả chi tiết về sự kiện của bạn..."
                rows={6}
                className="mt-2 glass-input"
              />
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-6">
            <div>
              <Label>Logo sự kiện (720x958) *</Label>
              <div className="mt-2 border-2 border-dashed border-white/20 rounded-xl p-8 text-center hover:border-primary/50 transition-colors cursor-pointer">
                <Upload className="h-10 w-10 mx-auto text-muted-foreground mb-3" />
                <p className="text-sm text-muted-foreground">
                  Kéo thả hoặc click để upload
                </p>
                <p className="text-xs text-muted-foreground mt-1">
                  PNG, JPG (720x958px)
                </p>
              </div>
            </div>
            <div>
              <Label>Banner sự kiện (1280x720) *</Label>
              <div className="mt-2 border-2 border-dashed border-white/20 rounded-xl p-8 text-center hover:border-primary/50 transition-colors cursor-pointer">
                <Upload className="h-10 w-10 mx-auto text-muted-foreground mb-3" />
                <p className="text-sm text-muted-foreground">
                  Kéo thả hoặc click để upload
                </p>
                <p className="text-xs text-muted-foreground mt-1">
                  PNG, JPG (1280x720px)
                </p>
              </div>
            </div>
          </div>
        );

      case 3:
        return (
          <div className="space-y-6">
            <div>
              <Label>Hình thức tổ chức *</Label>
              <div className="grid grid-cols-2 gap-4 mt-2">
                <button
                  onClick={() => updateFormData("locationType", "offline")}
                  className={cn(
                    "p-4 rounded-xl border-2 transition-all text-left",
                    formData.locationType === "offline"
                      ? "border-primary bg-primary/10"
                      : "border-white/20 hover:border-white/40"
                  )}
                >
                  <MapPin className="h-6 w-6 mb-2" />
                  <p className="font-medium">Offline</p>
                  <p className="text-sm text-muted-foreground">Tổ chức tại địa điểm</p>
                </button>
                <button
                  onClick={() => updateFormData("locationType", "online")}
                  className={cn(
                    "p-4 rounded-xl border-2 transition-all text-left",
                    formData.locationType === "online"
                      ? "border-primary bg-primary/10"
                      : "border-white/20 hover:border-white/40"
                  )}
                >
                  <Globe className="h-6 w-6 mb-2" />
                  <p className="font-medium">Online</p>
                  <p className="text-sm text-muted-foreground">Tổ chức trực tuyến</p>
                </button>
              </div>
            </div>

            {formData.locationType === "offline" ? (
              <>
                <div>
                  <Label htmlFor="venueName">Tên địa điểm *</Label>
                  <Input
                    id="venueName"
                    value={formData.venueName}
                    onChange={(e) => updateFormData("venueName", e.target.value)}
                    placeholder="VD: Nhà hát lớn Hà Nội"
                    className="mt-2 glass-input"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="province">Tỉnh/Thành phố *</Label>
                    <Select value={formData.province} onValueChange={(v) => updateFormData("province", v)}>
                      <SelectTrigger className="mt-2 glass-input">
                        <SelectValue placeholder="Chọn tỉnh/thành" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="hanoi">Hà Nội</SelectItem>
                        <SelectItem value="hcm">TP. Hồ Chí Minh</SelectItem>
                        <SelectItem value="danang">Đà Nẵng</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label htmlFor="district">Quận/Huyện *</Label>
                    <Select value={formData.district} onValueChange={(v) => updateFormData("district", v)}>
                      <SelectTrigger className="mt-2 glass-input">
                        <SelectValue placeholder="Chọn quận/huyện" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="hoankiem">Hoàn Kiếm</SelectItem>
                        <SelectItem value="badinh">Ba Đình</SelectItem>
                        <SelectItem value="caugiay">Cầu Giấy</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
                <div>
                  <Label htmlFor="address">Địa chỉ chi tiết *</Label>
                  <Input
                    id="address"
                    value={formData.address}
                    onChange={(e) => updateFormData("address", e.target.value)}
                    placeholder="Số nhà, đường..."
                    className="mt-2 glass-input"
                  />
                </div>
              </>
            ) : (
              <div>
                <Label htmlFor="onlineUrl">Link tham gia *</Label>
                <Input
                  id="onlineUrl"
                  value={formData.onlineUrl}
                  onChange={(e) => updateFormData("onlineUrl", e.target.value)}
                  placeholder="https://zoom.us/..."
                  className="mt-2 glass-input"
                />
              </div>
            )}
          </div>
        );

      case 4:
        return (
          <div className="space-y-6">
            <div>
              <Label htmlFor="organizerName">Tên ban tổ chức *</Label>
              <Input
                id="organizerName"
                value={formData.organizerName}
                onChange={(e) => updateFormData("organizerName", e.target.value)}
                placeholder="VD: Công ty ABC Entertainment"
                className="mt-2 glass-input"
              />
            </div>
            <div>
              <Label>Logo ban tổ chức (275x275)</Label>
              <div className="mt-2 border-2 border-dashed border-white/20 rounded-xl p-6 text-center hover:border-primary/50 transition-colors cursor-pointer">
                <Upload className="h-8 w-8 mx-auto text-muted-foreground mb-2" />
                <p className="text-sm text-muted-foreground">Upload logo</p>
              </div>
            </div>
            <div>
              <Label htmlFor="organizerDescription">Mô tả về ban tổ chức</Label>
              <Textarea
                id="organizerDescription"
                value={formData.organizerDescription}
                onChange={(e) => updateFormData("organizerDescription", e.target.value)}
                placeholder="Giới thiệu về ban tổ chức..."
                rows={4}
                className="mt-2 glass-input"
              />
            </div>
          </div>
        );

      case 5:
        return (
          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="font-medium">Lịch diễn</h3>
                <p className="text-sm text-muted-foreground">
                  Thêm các suất diễn cho sự kiện
                </p>
              </div>
              <Button variant="outline" size="sm" onClick={addShow} className="glass">
                <Plus className="h-4 w-4 mr-1" />
                Thêm suất
              </Button>
            </div>

            {formData.shows.map((show, index) => (
              <GlassCard key={show.id} className="p-4">
                <div className="flex items-center justify-between mb-4">
                  <h4 className="font-medium">Suất {index + 1}</h4>
                  {formData.shows.length > 1 && (
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8 text-red-400 hover:text-red-500"
                      onClick={() => removeShow(show.id)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Ngày bắt đầu</Label>
                    <Input type="date" className="mt-1 glass-input" />
                  </div>
                  <div>
                    <Label>Giờ bắt đầu</Label>
                    <Input type="time" className="mt-1 glass-input" />
                  </div>
                  <div>
                    <Label>Ngày kết thúc</Label>
                    <Input type="date" className="mt-1 glass-input" />
                  </div>
                  <div>
                    <Label>Giờ kết thúc</Label>
                    <Input type="time" className="mt-1 glass-input" />
                  </div>
                </div>
              </GlassCard>
            ))}
          </div>
        );

      case 6:
        return (
          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="font-medium">Loại vé</h3>
                <p className="text-sm text-muted-foreground">
                  Cấu hình các loại vé và giá
                </p>
              </div>
              <Button variant="outline" size="sm" onClick={addTicketType} className="glass">
                <Plus className="h-4 w-4 mr-1" />
                Thêm loại vé
              </Button>
            </div>

            {formData.ticketTypes.map((ticket, index) => (
              <GlassCard key={ticket.id} className="p-4">
                <div className="flex items-center justify-between mb-4">
                  <h4 className="font-medium">Loại vé {index + 1}</h4>
                  {formData.ticketTypes.length > 1 && (
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8 text-red-400 hover:text-red-500"
                      onClick={() => removeTicketType(ticket.id)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="col-span-2">
                    <Label>Tên loại vé *</Label>
                    <Input placeholder="VD: VIP, Standard..." className="mt-1 glass-input" />
                  </div>
                  <div>
                    <Label>Giá vé (VNĐ) *</Label>
                    <Input type="number" placeholder="500000" className="mt-1 glass-input" />
                  </div>
                  <div>
                    <Label>Số lượng *</Label>
                    <Input type="number" placeholder="100" className="mt-1 glass-input" />
                  </div>
                  <div>
                    <Label>Min mua/đơn</Label>
                    <Input type="number" defaultValue={1} className="mt-1 glass-input" />
                  </div>
                  <div>
                    <Label>Max mua/đơn</Label>
                    <Input type="number" defaultValue={10} className="mt-1 glass-input" />
                  </div>
                  <div>
                    <Label>Thời gian mở bán</Label>
                    <Input type="datetime-local" className="mt-1 glass-input" />
                  </div>
                  <div>
                    <Label>Thời gian ngừng bán</Label>
                    <Input type="datetime-local" className="mt-1 glass-input" />
                  </div>
                  <div className="col-span-2">
                    <Label>Mô tả loại vé</Label>
                    <Textarea placeholder="Quyền lợi của vé..." rows={2} className="mt-1 glass-input" />
                  </div>
                </div>
              </GlassCard>
            ))}
          </div>
        );

      case 7:
        return (
          <div className="space-y-6">
            <div>
              <Label htmlFor="customUrl">Đường dẫn tùy chỉnh</Label>
              <div className="flex items-center mt-2">
                <span className="px-3 py-2 bg-white/10 rounded-l-xl border border-r-0 border-white/20 text-sm text-muted-foreground">
                  ticketbox.vn/
                </span>
                <Input
                  id="customUrl"
                  value={formData.customUrl}
                  onChange={(e) => updateFormData("customUrl", e.target.value)}
                  placeholder="ten-su-kien"
                  className="rounded-l-none glass-input"
                />
              </div>
            </div>

            <div>
              <Label>Quyền riêng tư *</Label>
              <div className="grid grid-cols-2 gap-4 mt-2">
                <button
                  onClick={() => updateFormData("privacy", "public")}
                  className={cn(
                    "p-4 rounded-xl border-2 transition-all text-left",
                    formData.privacy === "public"
                      ? "border-primary bg-primary/10"
                      : "border-white/20 hover:border-white/40"
                  )}
                >
                  <Globe className="h-6 w-6 mb-2" />
                  <p className="font-medium">Công khai</p>
                  <p className="text-sm text-muted-foreground">Mọi người có thể thấy</p>
                </button>
                <button
                  onClick={() => updateFormData("privacy", "private")}
                  className={cn(
                    "p-4 rounded-xl border-2 transition-all text-left",
                    formData.privacy === "private"
                      ? "border-primary bg-primary/10"
                      : "border-white/20 hover:border-white/40"
                  )}
                >
                  <Lock className="h-6 w-6 mb-2" />
                  <p className="font-medium">Riêng tư</p>
                  <p className="text-sm text-muted-foreground">Cần mã để truy cập</p>
                </button>
              </div>
            </div>

            {formData.privacy === "private" && (
              <div>
                <Label htmlFor="accessCode">Mã truy cập *</Label>
                <Input
                  id="accessCode"
                  value={formData.accessCode}
                  onChange={(e) => updateFormData("accessCode", e.target.value)}
                  placeholder="Nhập mã bí mật"
                  className="mt-2 glass-input"
                />
                <p className="text-xs text-muted-foreground mt-1">
                  Người dùng cần nhập mã này để xem sự kiện
                </p>
              </div>
            )}
          </div>
        );

      case 8:
        return (
          <div className="space-y-6">
            <GlassCard className="p-4">
              <h3 className="font-medium mb-4">Thông tin tài khoản nhận tiền</h3>
              <div className="grid grid-cols-2 gap-4">
                <div className="col-span-2">
                  <Label>Tên chủ tài khoản *</Label>
                  <Input
                    value={formData.accountName}
                    onChange={(e) => updateFormData("accountName", e.target.value)}
                    placeholder="NGUYEN VAN A"
                    className="mt-1 glass-input"
                  />
                </div>
                <div>
                  <Label>Số tài khoản *</Label>
                  <Input
                    value={formData.accountNumber}
                    onChange={(e) => updateFormData("accountNumber", e.target.value)}
                    placeholder="0123456789"
                    className="mt-1 glass-input"
                  />
                </div>
                <div>
                  <Label>Ngân hàng *</Label>
                  <Select value={formData.bankName} onValueChange={(v) => updateFormData("bankName", v)}>
                    <SelectTrigger className="mt-1 glass-input">
                      <SelectValue placeholder="Chọn ngân hàng" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="vcb">Vietcombank</SelectItem>
                      <SelectItem value="tcb">Techcombank</SelectItem>
                      <SelectItem value="mb">MB Bank</SelectItem>
                      <SelectItem value="acb">ACB</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="col-span-2">
                  <Label>Chi nhánh</Label>
                  <Input
                    value={formData.bankBranch}
                    onChange={(e) => updateFormData("bankBranch", e.target.value)}
                    placeholder="Chi nhánh Hà Nội"
                    className="mt-1 glass-input"
                  />
                </div>
              </div>
            </GlassCard>

            <GlassCard className="p-4">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h3 className="font-medium">Xuất hóa đơn đỏ</h3>
                  <p className="text-sm text-muted-foreground">
                    Bật nếu bạn cần xuất hóa đơn VAT
                  </p>
                </div>
                <Switch
                  checked={formData.needInvoice}
                  onCheckedChange={(checked) => updateFormData("needInvoice", checked)}
                />
              </div>

              {formData.needInvoice && (
                <div className="grid grid-cols-2 gap-4 pt-4 border-t border-white/10">
                  <div>
                    <Label>Loại hình kinh doanh *</Label>
                    <Select
                      value={formData.businessType}
                      onValueChange={(v) => updateFormData("businessType", v)}
                    >
                      <SelectTrigger className="mt-1 glass-input">
                        <SelectValue placeholder="Chọn loại hình" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="company">Công ty</SelectItem>
                        <SelectItem value="individual">Cá nhân</SelectItem>
                        <SelectItem value="household">Hộ kinh doanh</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label>Mã số thuế *</Label>
                    <Input
                      value={formData.taxCode}
                      onChange={(e) => updateFormData("taxCode", e.target.value)}
                      placeholder="0123456789"
                      className="mt-1 glass-input"
                    />
                  </div>
                  <div className="col-span-2">
                    <Label>Tên công ty/cá nhân *</Label>
                    <Input
                      value={formData.companyName}
                      onChange={(e) => updateFormData("companyName", e.target.value)}
                      placeholder="Công ty TNHH ABC"
                      className="mt-1 glass-input"
                    />
                  </div>
                  <div className="col-span-2">
                    <Label>Địa chỉ *</Label>
                    <Input
                      value={formData.companyAddress}
                      onChange={(e) => updateFormData("companyAddress", e.target.value)}
                      placeholder="Địa chỉ xuất hóa đơn"
                      className="mt-1 glass-input"
                    />
                  </div>
                </div>
              )}
            </GlassCard>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <OrganizerLayout title="Tạo sự kiện mới" subtitle="Điền thông tin để tạo sự kiện của bạn">
      <div className="max-w-4xl mx-auto">
        {/* Steps Progress */}
        <div className="mb-8 overflow-x-auto">
          <div className="flex items-center min-w-max">
            {steps.map((step, index) => (
              <div key={step.id} className="flex items-center">
                <button
                  onClick={() => setCurrentStep(step.id)}
                  className={cn(
                    "flex items-center gap-2 px-4 py-2 rounded-xl transition-all",
                    currentStep === step.id
                      ? "bg-gradient-primary text-white"
                      : currentStep > step.id
                      ? "bg-green-500/20 text-green-400"
                      : "bg-white/10 text-muted-foreground"
                  )}
                >
                  {currentStep > step.id ? (
                    <Check className="h-4 w-4" />
                  ) : (
                    <step.icon className="h-4 w-4" />
                  )}
                  <span className="text-sm font-medium hidden sm:inline">{step.title}</span>
                </button>
                {index < steps.length - 1 && (
                  <div
                    className={cn(
                      "w-8 h-0.5 mx-1",
                      currentStep > step.id ? "bg-green-500" : "bg-white/20"
                    )}
                  />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Step Content */}
        <GlassCard className="p-6 mb-6">
          <div className="flex items-center gap-3 mb-6">
            {(() => {
              const StepIcon = steps[currentStep - 1].icon;
              return <StepIcon className="h-6 w-6 text-primary" />;
            })()}
            <div>
              <h2 className="text-xl font-semibold">{steps[currentStep - 1].title}</h2>
              <p className="text-sm text-muted-foreground">
                Bước {currentStep} / {steps.length}
              </p>
            </div>
          </div>

          {renderStepContent()}
        </GlassCard>

        {/* Navigation Buttons */}
        <div className="flex items-center justify-between">
          <Button
            variant="outline"
            onClick={prevStep}
            disabled={currentStep === 1}
            className="glass"
          >
            <ChevronLeft className="h-4 w-4 mr-1" />
            Quay lại
          </Button>

          <div className="flex gap-3">
            <Button variant="outline" className="glass">
              Lưu nháp
            </Button>
            {currentStep === steps.length ? (
              <GradientButton>
                <Check className="h-4 w-4 mr-1" />
                Gửi duyệt
              </GradientButton>
            ) : (
              <GradientButton onClick={nextStep}>
                Tiếp theo
                <ChevronRight className="h-4 w-4 ml-1" />
              </GradientButton>
            )}
          </div>
        </div>
      </div>
    </OrganizerLayout>
  );
};

export default CreateEvent;
