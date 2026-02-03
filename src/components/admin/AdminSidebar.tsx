import { NavLink, useLocation } from "react-router-dom";
import { motion } from "framer-motion";
import {
  LayoutDashboard,
  CalendarCheck,
  Users,
  Truck,
  BarChart3,
  Shield,
  Settings,
  LogOut,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { staggerContainer, staggerItem } from "@/lib/animations";

const menuItems = [
  { icon: LayoutDashboard, label: "Dashboard", path: "/admin" },
  { icon: CalendarCheck, label: "Duyệt sự kiện", path: "/admin/events" },
  { icon: Users, label: "Người dùng", path: "/admin/users" },
  { icon: Truck, label: "Vận chuyển", path: "/admin/shipping" },
  { icon: BarChart3, label: "Báo cáo", path: "/admin/reports" },
];

const transition = { duration: 0.4, ease: "easeOut" as const };

const AdminSidebar = () => {
  const location = useLocation();

  return (
    <motion.aside
      initial={{ x: -100, opacity: 0 }}
      animate={{ x: 0, opacity: 1 }}
      transition={transition}
      className="fixed left-0 top-0 z-40 h-screen w-64 glass-strong border-r border-border/50"
    >
      <div className="flex h-full flex-col">
        {/* Logo */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="flex items-center gap-3 border-b border-border/50 px-6 py-5"
        >
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-red-500 to-orange-500">
            <Shield className="h-6 w-6 text-white" />
          </div>
          <div>
            <h1 className="text-lg font-bold text-foreground">Admin</h1>
            <p className="text-xs text-muted-foreground">Quản trị hệ thống</p>
          </div>
        </motion.div>

        {/* Navigation */}
        <motion.nav
          variants={staggerContainer}
          initial="initial"
          animate="animate"
          className="flex-1 space-y-1 px-3 py-4"
        >
          {menuItems.map((item, index) => {
            const isActive = location.pathname === item.path;
            return (
              <motion.div
                key={item.path}
                variants={staggerItem}
                transition={{ ...transition, delay: index * 0.05 }}
              >
                <NavLink
                  to={item.path}
                  className={cn(
                    "group flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-medium transition-all duration-300",
                    isActive
                      ? "bg-gradient-to-r from-red-500/20 to-orange-500/20 text-red-600 dark:text-red-400"
                      : "text-muted-foreground hover:bg-accent hover:text-foreground"
                  )}
                >
                  <motion.div
                    whileHover={{ scale: 1.1, rotate: 5 }}
                    whileTap={{ scale: 0.95 }}
                  >
                    <item.icon
                      className={cn(
                        "h-5 w-5 transition-colors",
                        isActive ? "text-red-500" : "group-hover:text-primary"
                      )}
                    />
                  </motion.div>
                  <span>{item.label}</span>
                  {isActive && (
                    <motion.div
                      layoutId="admin-active-indicator"
                      className="ml-auto h-2 w-2 rounded-full bg-red-500"
                      transition={{ type: "spring", stiffness: 300, damping: 30 }}
                    />
                  )}
                </NavLink>
              </motion.div>
            );
          })}
        </motion.nav>

        {/* Bottom Section */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="border-t border-border/50 p-3"
        >
          <NavLink
            to="/admin/settings"
            className="flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-medium text-muted-foreground transition-all hover:bg-accent hover:text-foreground"
          >
            <Settings className="h-5 w-5" />
            <span>Cài đặt</span>
          </NavLink>
          <button className="flex w-full items-center gap-3 rounded-xl px-4 py-3 text-sm font-medium text-destructive transition-all hover:bg-destructive/10">
            <LogOut className="h-5 w-5" />
            <span>Đăng xuất</span>
          </button>
        </motion.div>
      </div>
    </motion.aside>
  );
};

export default AdminSidebar;
