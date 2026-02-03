import { useState } from "react";
import { OrganizerLayout } from "@/components/organizer";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Building2,
  CreditCard,
  FileText,
  Bell,
  Upload,
  Save,
} from "lucide-react";
import { useToast } from "@/hooks/use-toast";

const Settings = () => {
  const { toast } = useToast();
  const [settings, setSettings] = useState({
    // Organization
    orgName: "Công ty ABC Entertainment",
    orgDescription: "Chuyên tổ chức các sự kiện âm nhạc và giải trí hàng đầu Việt Nam",
    orgEmail: "contact@abc-ent.com",
    orgPhone: "1900 1234",
    orgWebsite: "https://abc-ent.com",
    // Bank
    accountName: "CONG TY TNHH ABC ENTERTAINMENT",
    accountNumber: "0123456789",
    bankName: "vcb",
    bankBranch: "Chi nhánh Hà Nội",
    // Invoice
    needInvoice: true,
    businessType: "company",
    companyName: "CÔNG TY TNHH ABC ENTERTAINMENT",
    companyAddress: "123 Đường ABC, Quận 1, TP.HCM",
    taxCode: "0123456789",
    // Notifications
    emailNotifications: true,
    smsNotifications: false,
    orderNotifications: true,
    reportNotifications: true,
  });

  const updateSettings = (field: string, value: any) => {
    setSettings((prev) => ({ ...prev, [field]: value }));
  };

  const handleSave = () => {
    toast({
      title: "Đã lưu!",
      description: "Cài đặt đã được cập nhật thành công",
    });
  };

  return (
    <OrganizerLayout
      title="Cài đặt"
      subtitle="Quản lý thông tin tổ chức và cấu hình"
    >
      <Tabs defaultValue="organization" className="space-y-6">
        <TabsList className="glass p-1">
          <TabsTrigger value="organization" className="gap-2">
            <Building2 className="h-4 w-4" />
            Tổ chức
          </TabsTrigger>
          <TabsTrigger value="bank" className="gap-2">
            <CreditCard className="h-4 w-4" />
            Ngân hàng
          </TabsTrigger>
          <TabsTrigger value="invoice" className="gap-2">
            <FileText className="h-4 w-4" />
            Hóa đơn
          </TabsTrigger>
          <TabsTrigger value="notifications" className="gap-2">
            <Bell className="h-4 w-4" />
            Thông báo
          </TabsTrigger>
        </TabsList>

        {/* Organization Tab */}
        <TabsContent value="organization">
          <GlassCard className="p-6">
            <h3 className="font-semibold mb-6">Thông tin ban tổ chức</h3>
            <div className="space-y-6">
              <div className="flex flex-col sm:flex-row gap-6">
                <div className="flex-shrink-0">
                  <Label>Logo tổ chức</Label>
                  <div className="mt-2 w-32 h-32 rounded-2xl border-2 border-dashed border-white/20 flex items-center justify-center hover:border-primary/50 transition-colors cursor-pointer">
                    <div className="text-center">
                      <Upload className="h-8 w-8 mx-auto text-muted-foreground mb-1" />
                      <span className="text-xs text-muted-foreground">Upload</span>
                    </div>
                  </div>
                </div>
                <div className="flex-1 space-y-4">
                  <div>
                    <Label>Tên tổ chức *</Label>
                    <Input
                      value={settings.orgName}
                      onChange={(e) => updateSettings("orgName", e.target.value)}
                      className="mt-1 glass-input"
                    />
                  </div>
                  <div>
                    <Label>Mô tả</Label>
                    <Textarea
                      value={settings.orgDescription}
                      onChange={(e) =>
                        updateSettings("orgDescription", e.target.value)
                      }
                      rows={3}
                      className="mt-1 glass-input"
                    />
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <Label>Email liên hệ</Label>
                  <Input
                    type="email"
                    value={settings.orgEmail}
                    onChange={(e) => updateSettings("orgEmail", e.target.value)}
                    className="mt-1 glass-input"
                  />
                </div>
                <div>
                  <Label>Số điện thoại</Label>
                  <Input
                    value={settings.orgPhone}
                    onChange={(e) => updateSettings("orgPhone", e.target.value)}
                    className="mt-1 glass-input"
                  />
                </div>
                <div className="sm:col-span-2">
                  <Label>Website</Label>
                  <Input
                    type="url"
                    value={settings.orgWebsite}
                    onChange={(e) => updateSettings("orgWebsite", e.target.value)}
                    className="mt-1 glass-input"
                  />
                </div>
              </div>
            </div>
          </GlassCard>
        </TabsContent>

        {/* Bank Tab */}
        <TabsContent value="bank">
          <GlassCard className="p-6">
            <h3 className="font-semibold mb-6">Tài khoản ngân hàng</h3>
            <p className="text-sm text-muted-foreground mb-6">
              Thông tin tài khoản để nhận thanh toán từ việc bán vé
            </p>
            <div className="space-y-4">
              <div>
                <Label>Tên chủ tài khoản *</Label>
                <Input
                  value={settings.accountName}
                  onChange={(e) => updateSettings("accountName", e.target.value)}
                  placeholder="NGUYEN VAN A"
                  className="mt-1 glass-input"
                />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <Label>Số tài khoản *</Label>
                  <Input
                    value={settings.accountNumber}
                    onChange={(e) => updateSettings("accountNumber", e.target.value)}
                    className="mt-1 glass-input"
                  />
                </div>
                <div>
                  <Label>Ngân hàng *</Label>
                  <Select
                    value={settings.bankName}
                    onValueChange={(v) => updateSettings("bankName", v)}
                  >
                    <SelectTrigger className="mt-1 glass-input">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="vcb">Vietcombank</SelectItem>
                      <SelectItem value="tcb">Techcombank</SelectItem>
                      <SelectItem value="mb">MB Bank</SelectItem>
                      <SelectItem value="acb">ACB</SelectItem>
                      <SelectItem value="bidv">BIDV</SelectItem>
                      <SelectItem value="vtb">VietinBank</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div>
                <Label>Chi nhánh</Label>
                <Input
                  value={settings.bankBranch}
                  onChange={(e) => updateSettings("bankBranch", e.target.value)}
                  className="mt-1 glass-input"
                />
              </div>
            </div>
          </GlassCard>
        </TabsContent>

        {/* Invoice Tab */}
        <TabsContent value="invoice">
          <GlassCard className="p-6">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h3 className="font-semibold">Xuất hóa đơn đỏ</h3>
                <p className="text-sm text-muted-foreground">
                  Thông tin để xuất hóa đơn VAT
                </p>
              </div>
              <Switch
                checked={settings.needInvoice}
                onCheckedChange={(checked) => updateSettings("needInvoice", checked)}
              />
            </div>

            {settings.needInvoice && (
              <div className="space-y-4 pt-4 border-t border-white/10">
                <div>
                  <Label>Loại hình kinh doanh *</Label>
                  <Select
                    value={settings.businessType}
                    onValueChange={(v) => updateSettings("businessType", v)}
                  >
                    <SelectTrigger className="mt-1 glass-input">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="company">Công ty</SelectItem>
                      <SelectItem value="individual">Cá nhân</SelectItem>
                      <SelectItem value="household">Hộ kinh doanh</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label>Tên công ty/cá nhân *</Label>
                  <Input
                    value={settings.companyName}
                    onChange={(e) => updateSettings("companyName", e.target.value)}
                    className="mt-1 glass-input"
                  />
                </div>
                <div>
                  <Label>Địa chỉ *</Label>
                  <Input
                    value={settings.companyAddress}
                    onChange={(e) => updateSettings("companyAddress", e.target.value)}
                    className="mt-1 glass-input"
                  />
                </div>
                <div>
                  <Label>Mã số thuế *</Label>
                  <Input
                    value={settings.taxCode}
                    onChange={(e) => updateSettings("taxCode", e.target.value)}
                    className="mt-1 glass-input"
                  />
                </div>
              </div>
            )}
          </GlassCard>
        </TabsContent>

        {/* Notifications Tab */}
        <TabsContent value="notifications">
          <GlassCard className="p-6">
            <h3 className="font-semibold mb-6">Cài đặt thông báo</h3>
            <div className="space-y-6">
              <div className="flex items-center justify-between p-4 rounded-xl bg-white/5">
                <div>
                  <p className="font-medium">Thông báo qua Email</p>
                  <p className="text-sm text-muted-foreground">
                    Nhận email khi có đơn hàng mới hoặc cập nhật
                  </p>
                </div>
                <Switch
                  checked={settings.emailNotifications}
                  onCheckedChange={(checked) =>
                    updateSettings("emailNotifications", checked)
                  }
                />
              </div>

              <div className="flex items-center justify-between p-4 rounded-xl bg-white/5">
                <div>
                  <p className="font-medium">Thông báo qua SMS</p>
                  <p className="text-sm text-muted-foreground">
                    Nhận tin nhắn khi có đơn hàng quan trọng
                  </p>
                </div>
                <Switch
                  checked={settings.smsNotifications}
                  onCheckedChange={(checked) =>
                    updateSettings("smsNotifications", checked)
                  }
                />
              </div>

              <div className="flex items-center justify-between p-4 rounded-xl bg-white/5">
                <div>
                  <p className="font-medium">Thông báo đơn hàng</p>
                  <p className="text-sm text-muted-foreground">
                    Nhận thông báo mỗi khi có đơn hàng mới
                  </p>
                </div>
                <Switch
                  checked={settings.orderNotifications}
                  onCheckedChange={(checked) =>
                    updateSettings("orderNotifications", checked)
                  }
                />
              </div>

              <div className="flex items-center justify-between p-4 rounded-xl bg-white/5">
                <div>
                  <p className="font-medium">Báo cáo hàng ngày</p>
                  <p className="text-sm text-muted-foreground">
                    Nhận email tổng kết doanh số mỗi ngày
                  </p>
                </div>
                <Switch
                  checked={settings.reportNotifications}
                  onCheckedChange={(checked) =>
                    updateSettings("reportNotifications", checked)
                  }
                />
              </div>
            </div>
          </GlassCard>
        </TabsContent>

        {/* Save Button */}
        <div className="flex justify-end">
          <GradientButton onClick={handleSave}>
            <Save className="h-4 w-4 mr-2" />
            Lưu thay đổi
          </GradientButton>
        </div>
      </Tabs>
    </OrganizerLayout>
  );
};

export default Settings;
