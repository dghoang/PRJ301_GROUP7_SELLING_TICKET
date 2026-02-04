import { useTranslation } from "react-i18next";
import { motion } from "framer-motion";
import { MainLayout } from "@/components/layout";
import { GlassCard } from "@/components/ui/glass-card";
import { StaggerContainer, FadeIn } from "@/components/ui/motion-wrapper";
import { FileText, Shield, Users, AlertTriangle, Scale, Clock } from "lucide-react";

const TermsOfService = () => {
  const { t, i18n } = useTranslation();
  const isVi = i18n.language === "vi";

  const sections = isVi ? [
    {
      icon: FileText,
      title: "1. Điều khoản chung",
      content: [
        "Chào mừng bạn đến với Ticketbox. Bằng việc truy cập và sử dụng dịch vụ của chúng tôi, bạn đồng ý tuân thủ và chịu ràng buộc bởi các điều khoản và điều kiện sau đây.",
        "Ticketbox có quyền thay đổi, chỉnh sửa, thêm hoặc xóa bất kỳ phần nào của các Điều khoản này vào bất kỳ lúc nào. Việc bạn tiếp tục sử dụng dịch vụ sau khi có thay đổi đồng nghĩa với việc bạn chấp nhận các thay đổi đó.",
        "Nếu bạn không đồng ý với bất kỳ điều khoản nào, vui lòng không sử dụng dịch vụ của chúng tôi."
      ]
    },
    {
      icon: Users,
      title: "2. Tài khoản người dùng",
      content: [
        "Để sử dụng một số tính năng của Ticketbox, bạn cần đăng ký tài khoản. Bạn cam kết cung cấp thông tin chính xác, đầy đủ và cập nhật.",
        "Bạn chịu trách nhiệm bảo mật thông tin đăng nhập của mình và tất cả các hoạt động diễn ra dưới tài khoản của bạn.",
        "Ticketbox có quyền đình chỉ hoặc chấm dứt tài khoản của bạn nếu phát hiện vi phạm điều khoản sử dụng hoặc hành vi gian lận."
      ]
    },
    {
      icon: Shield,
      title: "3. Mua vé và thanh toán",
      content: [
        "Tất cả các giao dịch mua vé qua Ticketbox đều tuân theo chính sách giá và phí dịch vụ được công bố tại thời điểm mua.",
        "Vé đã mua không được hoàn trả trừ khi sự kiện bị hủy hoặc hoãn bởi ban tổ chức, hoặc theo chính sách hoàn vé cụ thể của từng sự kiện.",
        "Ticketbox sử dụng các cổng thanh toán uy tín và bảo mật để xử lý giao dịch. Chúng tôi không lưu trữ thông tin thẻ tín dụng của bạn."
      ]
    },
    {
      icon: AlertTriangle,
      title: "4. Quy định sử dụng",
      content: [
        "Bạn không được sử dụng dịch vụ cho mục đích bất hợp pháp hoặc vi phạm quyền của người khác.",
        "Nghiêm cấm việc đầu cơ vé, bán lại vé với giá cao hơn giá gốc mà không có sự cho phép của ban tổ chức.",
        "Không được sử dụng bot, script hoặc các công cụ tự động để mua vé hoặc truy cập dịch vụ."
      ]
    },
    {
      icon: Scale,
      title: "5. Giới hạn trách nhiệm",
      content: [
        "Ticketbox là nền tảng kết nối giữa người tổ chức sự kiện và người tham dự. Chúng tôi không chịu trách nhiệm về nội dung, chất lượng hoặc an toàn của các sự kiện.",
        "Ticketbox không chịu trách nhiệm cho bất kỳ thiệt hại trực tiếp, gián tiếp, ngẫu nhiên hoặc hệ quả nào phát sinh từ việc sử dụng dịch vụ.",
        "Trong mọi trường hợp, trách nhiệm của Ticketbox không vượt quá số tiền bạn đã thanh toán cho vé."
      ]
    },
    {
      icon: Clock,
      title: "6. Điều khoản khác",
      content: [
        "Các Điều khoản này được điều chỉnh bởi pháp luật Việt Nam. Mọi tranh chấp sẽ được giải quyết tại tòa án có thẩm quyền tại Việt Nam.",
        "Nếu bất kỳ điều khoản nào bị coi là không hợp lệ, các điều khoản còn lại vẫn có hiệu lực đầy đủ.",
        "Điều khoản này có hiệu lực kể từ ngày bạn bắt đầu sử dụng dịch vụ Ticketbox."
      ]
    }
  ] : [
    {
      icon: FileText,
      title: "1. General Terms",
      content: [
        "Welcome to Ticketbox. By accessing and using our services, you agree to comply with and be bound by the following terms and conditions.",
        "Ticketbox reserves the right to change, modify, add, or remove any part of these Terms at any time. Your continued use of the service after changes constitutes acceptance of those changes.",
        "If you do not agree with any terms, please do not use our services."
      ]
    },
    {
      icon: Users,
      title: "2. User Accounts",
      content: [
        "To use certain features of Ticketbox, you need to register an account. You agree to provide accurate, complete, and up-to-date information.",
        "You are responsible for maintaining the security of your login credentials and all activities that occur under your account.",
        "Ticketbox reserves the right to suspend or terminate your account if violations of terms of use or fraudulent behavior are detected."
      ]
    },
    {
      icon: Shield,
      title: "3. Ticket Purchases and Payments",
      content: [
        "All ticket purchases through Ticketbox are subject to the pricing and service fee policies published at the time of purchase.",
        "Tickets purchased are non-refundable unless the event is canceled or postponed by the organizer, or according to the specific refund policy of each event.",
        "Ticketbox uses reputable and secure payment gateways to process transactions. We do not store your credit card information."
      ]
    },
    {
      icon: AlertTriangle,
      title: "4. Usage Rules",
      content: [
        "You may not use the service for illegal purposes or in violation of others' rights.",
        "Ticket scalping, reselling tickets at prices higher than the original price without permission from the organizer, is strictly prohibited.",
        "Using bots, scripts, or automated tools to purchase tickets or access the service is not allowed."
      ]
    },
    {
      icon: Scale,
      title: "5. Limitation of Liability",
      content: [
        "Ticketbox is a platform connecting event organizers and attendees. We are not responsible for the content, quality, or safety of events.",
        "Ticketbox is not liable for any direct, indirect, incidental, or consequential damages arising from the use of the service.",
        "In all cases, Ticketbox's liability does not exceed the amount you paid for tickets."
      ]
    },
    {
      icon: Clock,
      title: "6. Other Terms",
      content: [
        "These Terms are governed by the laws of Vietnam. Any disputes will be resolved at competent courts in Vietnam.",
        "If any provision is deemed invalid, the remaining provisions remain in full force and effect.",
        "These Terms are effective from the date you begin using Ticketbox services."
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
                  <FileText className="w-4 h-4 text-primary" />
                  <span className="text-sm font-medium">
                    {isVi ? "Pháp lý" : "Legal"}
                  </span>
                </div>
              </FadeIn>
              <FadeIn>
                <h1 className="text-4xl md:text-5xl font-bold mb-4">
                  {isVi ? "Điều khoản " : "Terms of "}
                  <span className="text-gradient">{isVi ? "Sử dụng" : "Service"}</span>
                </h1>
              </FadeIn>
              <FadeIn>
                <p className="text-lg text-muted-foreground">
                  {isVi
                    ? "Vui lòng đọc kỹ các điều khoản và điều kiện sau trước khi sử dụng dịch vụ Ticketbox."
                    : "Please read the following terms and conditions carefully before using Ticketbox services."}
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
                            <p key={pIndex} className="text-muted-foreground leading-relaxed">
                              {paragraph}
                            </p>
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
                {isVi ? "Có câu hỏi về điều khoản?" : "Questions about our terms?"}
              </h3>
              <p className="text-muted-foreground mb-6">
                {isVi
                  ? "Nếu bạn có bất kỳ thắc mắc nào về các điều khoản sử dụng, vui lòng liên hệ với chúng tôi."
                  : "If you have any questions about the terms of service, please contact us."}
              </p>
              <a
                href="mailto:legal@ticketbox.vn"
                className="inline-flex items-center gap-2 text-primary hover:underline"
              >
                legal@ticketbox.vn
              </a>
            </GlassCard>
          </div>
        </section>
      </div>
    </MainLayout>
  );
};

export { TermsOfService };
