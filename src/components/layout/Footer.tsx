import { Link } from "react-router-dom";
import { Ticket, Facebook, Instagram, Youtube, Mail, Phone, MapPin } from "lucide-react";

const Footer = () => {
  const currentYear = new Date().getFullYear();

  const footerLinks = {
    company: [
      { label: "Về chúng tôi", href: "/about" },
      { label: "Liên hệ", href: "/contact" },
      { label: "Tuyển dụng", href: "/careers" },
      { label: "Blog", href: "/blog" },
    ],
    support: [
      { label: "Hướng dẫn mua vé", href: "/guide" },
      { label: "Câu hỏi thường gặp", href: "/faq" },
      { label: "Chính sách hoàn vé", href: "/refund-policy" },
      { label: "Điều khoản sử dụng", href: "/terms" },
    ],
    organizer: [
      { label: "Đăng ký BTC", href: "/organizer/register" },
      { label: "Tạo sự kiện", href: "/organizer/create-event" },
      { label: "Bảng giá dịch vụ", href: "/pricing" },
      { label: "Hỗ trợ BTC", href: "/organizer/support" },
    ],
  };

  const socialLinks = [
    { icon: Facebook, href: "#", label: "Facebook" },
    { icon: Instagram, href: "#", label: "Instagram" },
    { icon: Youtube, href: "#", label: "Youtube" },
  ];

  return (
    <footer className="glass-strong border-t border-border/50 mt-auto">
      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8">
          {/* Brand */}
          <div className="lg:col-span-2">
            <Link to="/" className="flex items-center gap-2 mb-4">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-pink-500 to-purple-600 flex items-center justify-center shadow-lg">
                <Ticket className="w-6 h-6 text-white" />
              </div>
              <span className="text-xl font-bold text-gradient">Ticketbox</span>
            </Link>
            <p className="text-sm text-muted-foreground mb-6 max-w-sm">
              Nền tảng bán vé sự kiện hàng đầu Việt Nam. Khám phá và đặt vé cho các sự kiện âm nhạc, workshop, thể thao và nhiều hơn nữa.
            </p>
            
            {/* Contact Info */}
            <div className="space-y-2 text-sm text-muted-foreground">
              <div className="flex items-center gap-2">
                <Mail className="w-4 h-4" />
                <span>support@ticketbox.vn</span>
              </div>
              <div className="flex items-center gap-2">
                <Phone className="w-4 h-4" />
                <span>1900 1234</span>
              </div>
              <div className="flex items-center gap-2">
                <MapPin className="w-4 h-4" />
                <span>Quận 1, TP. Hồ Chí Minh</span>
              </div>
            </div>

            {/* Social Links */}
            <div className="flex gap-3 mt-6">
              {socialLinks.map((social) => (
                <a
                  key={social.label}
                  href={social.href}
                  className="w-10 h-10 rounded-xl glass flex items-center justify-center hover:bg-primary/10 hover:text-primary transition-all"
                  aria-label={social.label}
                >
                  <social.icon className="w-5 h-5" />
                </a>
              ))}
            </div>
          </div>

          {/* Links */}
          <div>
            <h4 className="font-semibold mb-4">Công ty</h4>
            <ul className="space-y-2">
              {footerLinks.company.map((link) => (
                <li key={link.href}>
                  <Link
                    to={link.href}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="font-semibold mb-4">Hỗ trợ</h4>
            <ul className="space-y-2">
              {footerLinks.support.map((link) => (
                <li key={link.href}>
                  <Link
                    to={link.href}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="font-semibold mb-4">Ban tổ chức</h4>
            <ul className="space-y-2">
              {footerLinks.organizer.map((link) => (
                <li key={link.href}>
                  <Link
                    to={link.href}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom */}
        <div className="border-t border-border/50 mt-10 pt-6 flex flex-col sm:flex-row justify-between items-center gap-4">
          <p className="text-sm text-muted-foreground">
            © {currentYear} Ticketbox. Tất cả quyền được bảo lưu.
          </p>
          <div className="flex gap-4 text-sm text-muted-foreground">
            <Link to="/privacy" className="hover:text-foreground transition-colors">
              Chính sách bảo mật
            </Link>
            <Link to="/terms" className="hover:text-foreground transition-colors">
              Điều khoản
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
};

export { Footer };
