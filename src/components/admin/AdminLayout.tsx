import { motion } from "framer-motion";
import { Bell, Search, Moon, Sun } from "lucide-react";
import AdminSidebar from "./AdminSidebar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { useState } from "react";

interface AdminLayoutProps {
  children: React.ReactNode;
  title: string;
  subtitle?: string;
}

const transition = { duration: 0.4, ease: "easeOut" as const };

const AdminLayout = ({ children, title, subtitle }: AdminLayoutProps) => {
  const [isDark, setIsDark] = useState(false);

  const toggleTheme = () => {
    setIsDark(!isDark);
    document.documentElement.classList.toggle("dark");
  };

  return (
    <div className="min-h-screen gradient-bg">
      <AdminSidebar />
      
      {/* Main Content */}
      <div className="ml-64">
        {/* Header */}
        <motion.header
          initial={{ y: -20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={transition}
          className="sticky top-0 z-30 glass-strong border-b border-border/50"
        >
          <div className="flex h-16 items-center justify-between px-6">
            <div>
              <motion.h1
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.1 }}
                className="text-xl font-bold text-foreground"
              >
                {title}
              </motion.h1>
              {subtitle && (
                <motion.p
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.2 }}
                  className="text-sm text-muted-foreground"
                >
                  {subtitle}
                </motion.p>
              )}
            </div>

            <div className="flex items-center gap-4">
              {/* Search */}
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.2 }}
                className="relative hidden md:block"
              >
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Tìm kiếm..."
                  className="w-64 bg-background/50 pl-10"
                />
              </motion.div>

              {/* Theme Toggle */}
              <motion.div
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
              >
                <Button variant="ghost" size="icon" onClick={toggleTheme}>
                  {isDark ? (
                    <Sun className="h-5 w-5" />
                  ) : (
                    <Moon className="h-5 w-5" />
                  )}
                </Button>
              </motion.div>

              {/* Notifications */}
              <motion.div
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                className="relative"
              >
                <Button variant="ghost" size="icon">
                  <Bell className="h-5 w-5" />
                </Button>
                <motion.span
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  className="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-xs text-white"
                >
                  5
                </motion.span>
              </motion.div>

              {/* Profile */}
              <motion.div
                whileHover={{ scale: 1.05 }}
                className="flex items-center gap-3"
              >
                <Avatar className="h-9 w-9 ring-2 ring-red-500/20">
                  <AvatarImage src="/placeholder.svg" />
                  <AvatarFallback className="bg-gradient-to-br from-red-500 to-orange-500 text-white">
                    AD
                  </AvatarFallback>
                </Avatar>
                <div className="hidden md:block">
                  <p className="text-sm font-medium">Super Admin</p>
                  <p className="text-xs text-muted-foreground">admin@ticketbox.vn</p>
                </div>
              </motion.div>
            </div>
          </div>
        </motion.header>

        {/* Page Content */}
        <motion.main
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, ...transition }}
          className="p-6"
        >
          {children}
        </motion.main>
      </div>
    </div>
  );
};

export default AdminLayout;
