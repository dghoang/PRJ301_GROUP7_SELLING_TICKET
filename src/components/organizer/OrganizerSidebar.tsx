import { Link, useLocation } from "react-router-dom";
import {
  LayoutDashboard,
  CalendarPlus,
  Calendar,
  Ticket,
  Tag,
  ClipboardList,
  BarChart3,
  Users,
  QrCode,
  Settings,
  ChevronLeft,
  Menu,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useState } from "react";
import { Button } from "@/components/ui/button";

const menuItems = [
  { icon: LayoutDashboard, label: "Dashboard", path: "/organizer" },
  { icon: CalendarPlus, label: "Tạo sự kiện", path: "/organizer/create-event" },
  { icon: Calendar, label: "Quản lý sự kiện", path: "/organizer/events" },
  { icon: Ticket, label: "Quản lý vé", path: "/organizer/tickets" },
  { icon: Tag, label: "Mã giảm giá", path: "/organizer/vouchers" },
  { icon: ClipboardList, label: "Đơn hàng (RSVP)", path: "/organizer/orders" },
  { icon: BarChart3, label: "Thống kê", path: "/organizer/statistics" },
  { icon: Users, label: "Điều hành viên", path: "/organizer/team" },
  { icon: QrCode, label: "Soát vé", path: "/organizer/check-in" },
  { icon: Settings, label: "Cài đặt", path: "/organizer/settings" },
];

const OrganizerSidebar = () => {
  const location = useLocation();
  const [collapsed, setCollapsed] = useState(false);

  return (
    <>
      {/* Mobile Toggle */}
      <Button
        variant="ghost"
        size="icon"
        className="fixed top-4 left-4 z-50 lg:hidden glass"
        onClick={() => setCollapsed(!collapsed)}
      >
        <Menu className="h-5 w-5" />
      </Button>

      {/* Sidebar */}
      <aside
        className={cn(
          "fixed left-0 top-0 h-full glass-strong border-r border-white/20 transition-all duration-300 z-40",
          collapsed ? "w-20" : "w-64",
          "hidden lg:block"
        )}
      >
        {/* Logo */}
        <div className="p-6 border-b border-white/10">
          <Link to="/organizer" className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-primary flex items-center justify-center">
              <Ticket className="h-5 w-5 text-white" />
            </div>
            {!collapsed && (
              <span className="font-bold text-lg gradient-text">Ticketbox</span>
            )}
          </Link>
        </div>

        {/* Collapse Button */}
        <Button
          variant="ghost"
          size="icon"
          className="absolute -right-3 top-20 w-6 h-6 rounded-full glass border border-white/20 hidden lg:flex"
          onClick={() => setCollapsed(!collapsed)}
        >
          <ChevronLeft
            className={cn(
              "h-3 w-3 transition-transform",
              collapsed && "rotate-180"
            )}
          />
        </Button>

        {/* Navigation */}
        <nav className="p-4 space-y-2">
          {menuItems.map((item) => {
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                className={cn(
                  "flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200",
                  isActive
                    ? "bg-gradient-primary text-white shadow-lg"
                    : "hover:bg-white/10 text-foreground/70 hover:text-foreground"
                )}
              >
                <item.icon className="h-5 w-5 flex-shrink-0" />
                {!collapsed && <span className="font-medium">{item.label}</span>}
              </Link>
            );
          })}
        </nav>

        {/* User Info */}
        {!collapsed && (
          <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-white/10">
            <div className="flex items-center gap-3 p-3 rounded-xl bg-white/5">
              <div className="w-10 h-10 rounded-full bg-gradient-primary flex items-center justify-center text-white font-bold">
                BTC
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-medium truncate">Công ty ABC</p>
                <p className="text-xs text-muted-foreground truncate">
                  Nhà tổ chức
                </p>
              </div>
            </div>
          </div>
        )}
      </aside>

      {/* Mobile Overlay */}
      {collapsed && (
        <div
          className="fixed inset-0 bg-black/50 z-30 lg:hidden"
          onClick={() => setCollapsed(false)}
        />
      )}

      {/* Mobile Sidebar */}
      <aside
        className={cn(
          "fixed left-0 top-0 h-full w-64 glass-strong border-r border-white/20 transition-transform duration-300 z-40 lg:hidden",
          collapsed ? "translate-x-0" : "-translate-x-full"
        )}
      >
        <div className="p-6 border-b border-white/10">
          <Link to="/organizer" className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-primary flex items-center justify-center">
              <Ticket className="h-5 w-5 text-white" />
            </div>
            <span className="font-bold text-lg gradient-text">Ticketbox</span>
          </Link>
        </div>

        <nav className="p-4 space-y-2">
          {menuItems.map((item) => {
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                onClick={() => setCollapsed(false)}
                className={cn(
                  "flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200",
                  isActive
                    ? "bg-gradient-primary text-white shadow-lg"
                    : "hover:bg-white/10 text-foreground/70 hover:text-foreground"
                )}
              >
                <item.icon className="h-5 w-5 flex-shrink-0" />
                <span className="font-medium">{item.label}</span>
              </Link>
            );
          })}
        </nav>
      </aside>
    </>
  );
};

export { OrganizerSidebar };
