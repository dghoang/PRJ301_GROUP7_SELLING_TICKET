import { Link, useLocation } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { cn } from "@/lib/utils";
import { GradientButton } from "@/components/ui/gradient-button";
import { LanguageSwitcher } from "@/components/ui/language-switcher";
import { 
  Search, 
  Menu, 
  X, 
  Ticket, 
  Moon,
  Sun
} from "lucide-react";
import { useState, useEffect } from "react";

interface HeaderProps {
  variant?: "default" | "transparent";
}

const Header = ({ variant = "default" }: HeaderProps) => {
  const { t } = useTranslation();
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const [isDark, setIsDark] = useState(false);
  const location = useLocation();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  useEffect(() => {
    const isDarkMode = document.documentElement.classList.contains("dark");
    setIsDark(isDarkMode);
  }, []);

  const toggleDarkMode = () => {
    document.documentElement.classList.toggle("dark");
    setIsDark(!isDark);
  };

  const navLinks = [
    { href: "/", label: t("common.home") },
    { href: "/events", label: t("common.events") },
    { href: "/categories", label: t("common.categories") },
    { href: "/about", label: t("common.about") },
    { href: "/faq", label: "FAQ" },
  ];

  const isActive = (path: string) => location.pathname === path;

  return (
    <header
      className={cn(
        "fixed top-0 left-0 right-0 z-50 transition-all duration-300",
        isScrolled || variant === "default"
          ? "glass-strong shadow-glass py-3"
          : "bg-transparent py-4"
      )}
    >
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-pink-500 to-purple-600 flex items-center justify-center shadow-lg">
              <Ticket className="w-6 h-6 text-white" />
            </div>
            <span className="text-xl font-bold text-gradient hidden sm:block">
              Ticketbox
            </span>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden lg:flex items-center gap-1">
            {navLinks.map((link) => (
              <Link
                key={link.href}
                to={link.href}
                className={cn(
                  "px-4 py-2 rounded-xl text-sm font-medium transition-all duration-200",
                  isActive(link.href)
                    ? "bg-primary/10 text-primary"
                    : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
                )}
              >
                {link.label}
              </Link>
            ))}
          </nav>

          {/* Search & Actions */}
          <div className="flex items-center gap-3">
            {/* Search Bar - Desktop */}
            <div className="hidden md:flex items-center gap-2 glass rounded-xl px-4 py-2">
              <Search className="w-4 h-4 text-muted-foreground" />
              <input
                type="text"
                placeholder={t("common.searchPlaceholder")}
                className="bg-transparent border-none outline-none text-sm w-40 lg:w-52 placeholder:text-muted-foreground"
              />
            </div>

            {/* Language Switcher */}
            <LanguageSwitcher />

            {/* Dark Mode Toggle */}
            <button
              onClick={toggleDarkMode}
              className="p-2 rounded-xl glass hover:bg-accent/50 transition-colors"
            >
              {isDark ? (
                <Sun className="w-5 h-5 text-yellow-500" />
              ) : (
                <Moon className="w-5 h-5 text-muted-foreground" />
              )}
            </button>

            {/* Auth Buttons */}
            <div className="hidden sm:flex items-center gap-2">
              <Link to="/login">
                <GradientButton variant="ghost" size="sm">
                  {t("common.login")}
                </GradientButton>
              </Link>
              <Link to="/register">
                <GradientButton size="sm">{t("common.register")}</GradientButton>
              </Link>
            </div>

            {/* Mobile Menu Button */}
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="lg:hidden p-2 rounded-xl glass"
            >
              {isMenuOpen ? (
                <X className="w-5 h-5" />
              ) : (
                <Menu className="w-5 h-5" />
              )}
            </button>
          </div>
        </div>

        {/* Mobile Menu */}
        {isMenuOpen && (
          <div className="lg:hidden mt-4 glass-strong rounded-2xl p-4 animate-fade-in">
            {/* Mobile Search */}
            <div className="flex items-center gap-2 glass rounded-xl px-4 py-3 mb-4">
              <Search className="w-4 h-4 text-muted-foreground" />
              <input
                type="text"
                placeholder={t("common.searchPlaceholder")}
                className="bg-transparent border-none outline-none text-sm flex-1 placeholder:text-muted-foreground"
              />
            </div>

            {/* Mobile Nav Links */}
            <nav className="space-y-1 mb-4">
              {navLinks.map((link) => (
                <Link
                  key={link.href}
                  to={link.href}
                  onClick={() => setIsMenuOpen(false)}
                  className={cn(
                    "flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all",
                    isActive(link.href)
                      ? "bg-primary/10 text-primary"
                      : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
                  )}
                >
                  {link.label}
                </Link>
              ))}
            </nav>

            {/* Mobile Auth Buttons */}
            <div className="flex gap-2">
              <Link to="/login" className="flex-1">
                <GradientButton variant="secondary" className="w-full">
                  {t("common.login")}
                </GradientButton>
              </Link>
              <Link to="/register" className="flex-1">
                <GradientButton className="w-full">{t("common.register")}</GradientButton>
              </Link>
            </div>
          </div>
        )}
      </div>
    </header>
  );
};

export { Header };
