import { useTranslation } from "react-i18next";
import { motion } from "framer-motion";
import { MainLayout } from "@/components/layout";
import { GlassCard } from "@/components/ui/glass-card";
import { StaggerContainer, FadeIn } from "@/components/ui/motion-wrapper";
import { Shield, Eye, Database, Lock, UserCheck, Bell, Globe, Trash2 } from "lucide-react";

const PrivacyPolicy = () => {
  const { t, i18n } = useTranslation();
  const isVi = i18n.language === "vi";

  const sections = isVi ? [
    {
      icon: Eye,
      title: "1. Thông tin chúng tôi thu thập",
      content: [
        "**Thông tin cá nhân:** Họ tên, email, số điện thoại, địa chỉ khi bạn đăng ký tài khoản hoặc mua vé.",
        "**Thông tin thanh toán:** Thông tin giao dịch, phương thức thanh toán (không bao gồm số thẻ đầy đủ).",
        "**Thông tin kỹ thuật:** Địa chỉ IP, loại trình duyệt, thiết bị, thời gian truy cập và các trang bạn xem.",
        "**Thông tin từ bên thứ ba:** Dữ liệu từ các nền tảng mạng xã hội nếu bạn đăng nhập qua đó."
      ]
    },
    {
      icon: Database,
      title: "2. Cách chúng tôi sử dụng thông tin",
      content: [
        "Xử lý đơn hàng và gửi vé điện tử đến bạn.",
        "Cung cấp hỗ trợ khách hàng và phản hồi các yêu cầu của bạn.",
        "Gửi thông báo về sự kiện, khuyến mãi và cập nhật quan trọng (nếu bạn đồng ý).",
        "Phân tích và cải thiện dịch vụ, trải nghiệm người dùng.",
        "Phát hiện và ngăn chặn gian lận, bảo vệ an ninh hệ thống."
      ]
    },
    {
      icon: Lock,
      title: "3. Bảo mật thông tin",
      content: [
        "Chúng tôi sử dụng mã hóa SSL/TLS để bảo vệ dữ liệu trong quá trình truyền tải.",
        "Thông tin thanh toán được xử lý qua các cổng thanh toán đạt chuẩn PCI-DSS.",
        "Dữ liệu được lưu trữ trên máy chủ bảo mật với kiểm soát truy cập nghiêm ngặt.",
        "Nhân viên chỉ được truy cập thông tin cần thiết cho công việc và đã ký cam kết bảo mật."
      ]
    },
    {
      icon: UserCheck,
      title: "4. Chia sẻ thông tin",
      content: [
        "**Ban tổ chức sự kiện:** Thông tin cần thiết để phục vụ việc check-in và quản lý sự kiện.",
        "**Đối tác thanh toán:** Thông tin giao dịch để xử lý thanh toán.",
        "**Nhà cung cấp dịch vụ:** Các bên hỗ trợ vận hành như email, phân tích, lưu trữ đám mây.",
        "**Cơ quan pháp luật:** Khi có yêu cầu hợp pháp hoặc để bảo vệ quyền lợi của chúng tôi."
      ]
    },
    {
      icon: Bell,
      title: "5. Cookie và công nghệ theo dõi",
      content: [
        "Chúng tôi sử dụng cookie để cải thiện trải nghiệm duyệt web và ghi nhớ tùy chọn của bạn.",
        "Cookie phân tích giúp chúng tôi hiểu cách người dùng tương tác với website.",
        "Bạn có thể quản lý hoặc tắt cookie trong cài đặt trình duyệt của mình.",
        "Một số tính năng có thể không hoạt động đầy đủ nếu cookie bị tắt."
      ]
    },
    {
      icon: Globe,
      title: "6. Quyền của bạn",
      content: [
        "**Quyền truy cập:** Yêu cầu bản sao thông tin cá nhân chúng tôi lưu trữ về bạn.",
        "**Quyền chỉnh sửa:** Cập nhật hoặc sửa đổi thông tin không chính xác.",
        "**Quyền xóa:** Yêu cầu xóa thông tin cá nhân của bạn trong một số trường hợp.",
        "**Quyền phản đối:** Từ chối nhận thông tin tiếp thị bất kỳ lúc nào."
      ]
    },
    {
      icon: Trash2,
      title: "7. Lưu trữ và xóa dữ liệu",
      content: [
        "Thông tin tài khoản được lưu trữ trong suốt thời gian bạn sử dụng dịch vụ.",
        "Dữ liệu giao dịch được lưu trữ theo quy định pháp luật về kế toán và thuế.",
        "Sau khi xóa tài khoản, dữ liệu sẽ được xóa hoặc ẩn danh trong vòng 30 ngày.",
        "Một số thông tin có thể được giữ lại theo yêu cầu pháp lý."
      ]
    }
  ] : [
    {
      icon: Eye,
      title: "1. Information We Collect",
      content: [
        "**Personal Information:** Name, email, phone number, address when you register or purchase tickets.",
        "**Payment Information:** Transaction details, payment methods (excluding full card numbers).",
        "**Technical Information:** IP address, browser type, device, access time, and pages viewed.",
        "**Third-party Information:** Data from social media platforms if you log in through them."
      ]
    },
    {
      icon: Database,
      title: "2. How We Use Information",
      content: [
        "Process orders and send e-tickets to you.",
        "Provide customer support and respond to your requests.",
        "Send notifications about events, promotions, and important updates (if you consent).",
        "Analyze and improve services and user experience.",
        "Detect and prevent fraud, protect system security."
      ]
    },
    {
      icon: Lock,
      title: "3. Information Security",
      content: [
        "We use SSL/TLS encryption to protect data during transmission.",
        "Payment information is processed through PCI-DSS compliant payment gateways.",
        "Data is stored on secure servers with strict access controls.",
        "Employees only access information necessary for their work and have signed confidentiality agreements."
      ]
    },
    {
      icon: UserCheck,
      title: "4. Information Sharing",
      content: [
        "**Event Organizers:** Necessary information for check-in and event management.",
        "**Payment Partners:** Transaction information for payment processing.",
        "**Service Providers:** Parties supporting operations such as email, analytics, cloud storage.",
        "**Legal Authorities:** When legally required or to protect our rights."
      ]
    },
    {
      icon: Bell,
      title: "5. Cookies and Tracking Technologies",
      content: [
        "We use cookies to improve browsing experience and remember your preferences.",
        "Analytics cookies help us understand how users interact with the website.",
        "You can manage or disable cookies in your browser settings.",
        "Some features may not work fully if cookies are disabled."
      ]
    },
    {
      icon: Globe,
      title: "6. Your Rights",
      content: [
        "**Right to Access:** Request a copy of personal information we store about you.",
        "**Right to Rectification:** Update or correct inaccurate information.",
        "**Right to Erasure:** Request deletion of your personal information in certain cases.",
        "**Right to Object:** Opt out of marketing communications at any time."
      ]
    },
    {
      icon: Trash2,
      title: "7. Data Retention and Deletion",
      content: [
        "Account information is stored throughout your use of the service.",
        "Transaction data is retained according to accounting and tax regulations.",
        "After account deletion, data will be deleted or anonymized within 30 days.",
        "Some information may be retained as required by law."
      ]
    }
  ];

  return (
    <MainLayout>
      <div className="min-h-screen pt-24 pb-16">
        {/* Hero Section */}
        <section className="relative py-16 overflow-hidden">
          <div className="absolute inset-0 bg-gradient-to-br from-primary/5 via-transparent to-secondary/5" />
          <div className="container mx-auto px-4 relative">
            <StaggerContainer className="text-center max-w-3xl mx-auto">
              <FadeIn>
                <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass mb-6">
                  <Shield className="w-4 h-4 text-primary" />
                  <span className="text-sm font-medium">
                    {isVi ? "Bảo mật" : "Privacy"}
                  </span>
                </div>
              </FadeIn>
              <FadeIn>
                <h1 className="text-4xl md:text-5xl font-bold mb-4">
                  {isVi ? "Chính sách " : "Privacy "}
                  <span className="text-gradient">{isVi ? "Bảo mật" : "Policy"}</span>
                </h1>
              </FadeIn>
              <FadeIn>
                <p className="text-lg text-muted-foreground">
                  {isVi
                    ? "Ticketbox cam kết bảo vệ quyền riêng tư và thông tin cá nhân của bạn. Chính sách này giải thích cách chúng tôi thu thập, sử dụng và bảo vệ dữ liệu của bạn."
                    : "Ticketbox is committed to protecting your privacy and personal information. This policy explains how we collect, use, and protect your data."}
                </p>
              </FadeIn>
              <FadeIn>
                <p className="text-sm text-muted-foreground mt-4">
                  {isVi ? "Cập nhật lần cuối: 01/02/2026" : "Last updated: February 1, 2026"}
                </p>
              </FadeIn>
            </StaggerContainer>
          </div>
        </section>

        {/* Content Sections */}
        <section className="py-8">
          <div className="container mx-auto px-4 max-w-4xl">
            <StaggerContainer className="space-y-6">
              {sections.map((section, index) => (
                <FadeIn key={index}>
                  <GlassCard className="p-6 md:p-8">
                    <div className="flex items-start gap-4">
                      <div className="p-3 rounded-xl bg-primary/10 shrink-0">
                        <section.icon className="w-6 h-6 text-primary" />
                      </div>
                      <div className="flex-1">
                        <h2 className="text-xl font-semibold mb-4">{section.title}</h2>
                        <div className="space-y-3">
                          {section.content.map((paragraph, pIndex) => (
                            <p 
                              key={pIndex} 
                              className="text-muted-foreground leading-relaxed"
                              dangerouslySetInnerHTML={{
                                __html: paragraph.replace(
                                  /\*\*(.*?)\*\*/g,
                                  '<strong class="text-foreground">$1</strong>'
                                )
                              }}
                            />
                          ))}
                        </div>
                      </div>
                    </div>
                  </GlassCard>
                </FadeIn>
              ))}
            </StaggerContainer>
          </div>
        </section>

        {/* Contact Section */}
        <section className="py-12">
          <div className="container mx-auto px-4 max-w-4xl">
            <GlassCard className="p-8 text-center">
              <h3 className="text-xl font-semibold mb-4">
                {isVi ? "Liên hệ về quyền riêng tư" : "Privacy Contact"}
              </h3>
              <p className="text-muted-foreground mb-6">
                {isVi
                  ? "Nếu bạn có bất kỳ câu hỏi hoặc yêu cầu nào liên quan đến quyền riêng tư và bảo mật dữ liệu, vui lòng liên hệ:"
                  : "If you have any questions or requests regarding privacy and data protection, please contact:"}
              </p>
              <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                <a
                  href="mailto:privacy@ticketbox.vn"
                  className="inline-flex items-center gap-2 text-primary hover:underline"
                >
                  privacy@ticketbox.vn
                </a>
                <span className="hidden sm:block text-muted-foreground">|</span>
                <span className="text-muted-foreground">
                  {isVi ? "Hotline: 1900 1234" : "Hotline: 1900 1234"}
                </span>
              </div>
            </GlassCard>
          </div>
        </section>
      </div>
    </MainLayout>
  );
};

export { PrivacyPolicy };
