import { useState } from "react";
import { useTranslation } from "react-i18next";
import { motion } from "framer-motion";
import { 
  Search, 
  HelpCircle, 
  Ticket, 
  CreditCard, 
  RefreshCw, 
  Shield, 
  Users, 
  Building2,
  MessageCircle,
  Mail,
  Phone
} from "lucide-react";
import { MainLayout } from "@/components/layout/MainLayout";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { FadeIn, StaggerContainer, StaggerItem } from "@/components/ui/motion-wrapper";
import { Badge } from "@/components/ui/badge";

const faqCategories = [
  {
    id: "general",
    name: "Chung",
    nameEn: "General",
    icon: HelpCircle,
    color: "from-blue-500 to-cyan-500",
  },
  {
    id: "tickets",
    name: "Mua vé",
    nameEn: "Tickets",
    icon: Ticket,
    color: "from-pink-500 to-rose-500",
  },
  {
    id: "payment",
    name: "Thanh toán",
    nameEn: "Payment",
    icon: CreditCard,
    color: "from-green-500 to-emerald-500",
  },
  {
    id: "refund",
    name: "Hoàn tiền",
    nameEn: "Refund",
    icon: RefreshCw,
    color: "from-orange-500 to-amber-500",
  },
  {
    id: "security",
    name: "Bảo mật",
    nameEn: "Security",
    icon: Shield,
    color: "from-purple-500 to-violet-500",
  },
  {
    id: "organizer",
    name: "Ban tổ chức",
    nameEn: "Organizer",
    icon: Building2,
    color: "from-indigo-500 to-blue-500",
  },
];

const faqData = [
  // General
  {
    category: "general",
    question: "Ticketbox là gì?",
    questionEn: "What is Ticketbox?",
    answer: "Ticketbox là nền tảng bán vé sự kiện trực tuyến hàng đầu Việt Nam, giúp bạn dễ dàng tìm kiếm, mua vé và tham gia các sự kiện như hòa nhạc, workshop, thể thao, triển lãm và nhiều hơn nữa.",
    answerEn: "Ticketbox is Vietnam's leading online event ticketing platform, helping you easily find, purchase tickets, and attend events such as concerts, workshops, sports, exhibitions, and more.",
  },
  {
    category: "general",
    question: "Làm thế nào để tạo tài khoản?",
    questionEn: "How do I create an account?",
    answer: "Bạn có thể tạo tài khoản bằng cách nhấn vào nút 'Đăng ký' ở góc phải trên cùng, sau đó điền thông tin cá nhân như email, số điện thoại và mật khẩu. Bạn cũng có thể đăng ký nhanh qua Google hoặc Facebook.",
    answerEn: "You can create an account by clicking the 'Register' button in the top right corner, then fill in your personal information such as email, phone number, and password. You can also quickly register via Google or Facebook.",
  },
  {
    category: "general",
    question: "Ticketbox có ứng dụng di động không?",
    questionEn: "Does Ticketbox have a mobile app?",
    answer: "Có, Ticketbox có ứng dụng di động cho cả iOS và Android. Bạn có thể tải ứng dụng từ App Store hoặc Google Play để mua vé và quản lý vé của mình một cách tiện lợi.",
    answerEn: "Yes, Ticketbox has a mobile app for both iOS and Android. You can download the app from the App Store or Google Play to purchase and manage your tickets conveniently.",
  },
  {
    category: "general",
    question: "Tôi có thể liên hệ hỗ trợ bằng cách nào?",
    questionEn: "How can I contact support?",
    answer: "Bạn có thể liên hệ với đội ngũ hỗ trợ của chúng tôi qua email support@ticketbox.vn, hotline 1900-xxxx (8:00 - 22:00), hoặc chat trực tiếp trên website/ứng dụng.",
    answerEn: "You can contact our support team via email support@ticketbox.vn, hotline 1900-xxxx (8:00 AM - 10:00 PM), or live chat on our website/app.",
  },
  // Tickets
  {
    category: "tickets",
    question: "Làm thế nào để mua vé?",
    questionEn: "How do I buy tickets?",
    answer: "Để mua vé, bạn chọn sự kiện muốn tham gia, chọn loại vé và số lượng, sau đó tiến hành thanh toán. Sau khi thanh toán thành công, vé sẽ được gửi đến email của bạn và hiển thị trong mục 'Vé của tôi'.",
    answerEn: "To buy tickets, select the event you want to attend, choose the ticket type and quantity, then proceed to payment. After successful payment, tickets will be sent to your email and displayed in 'My Tickets' section.",
  },
  {
    category: "tickets",
    question: "Tôi có thể mua bao nhiêu vé cho một sự kiện?",
    questionEn: "How many tickets can I buy for an event?",
    answer: "Số lượng vé tối đa phụ thuộc vào quy định của ban tổ chức sự kiện. Thông thường, mỗi tài khoản có thể mua từ 4-10 vé cho mỗi sự kiện. Giới hạn cụ thể sẽ được hiển thị trên trang mua vé.",
    answerEn: "The maximum number of tickets depends on the event organizer's regulations. Typically, each account can purchase 4-10 tickets per event. The specific limit will be displayed on the ticket purchase page.",
  },
  {
    category: "tickets",
    question: "Vé điện tử và vé giấy khác nhau như thế nào?",
    questionEn: "What's the difference between e-tickets and paper tickets?",
    answer: "Vé điện tử (e-ticket) được gửi qua email với mã QR để quét khi vào cửa, không cần in ra. Vé giấy sẽ được giao đến địa chỉ của bạn với phí ship bổ sung. Cả hai loại vé đều có giá trị như nhau.",
    answerEn: "E-tickets are sent via email with a QR code to scan at entry, no printing required. Paper tickets will be delivered to your address with additional shipping fees. Both types of tickets have the same value.",
  },
  {
    category: "tickets",
    question: "Tôi có thể chuyển nhượng vé cho người khác không?",
    questionEn: "Can I transfer tickets to someone else?",
    answer: "Có, bạn có thể chuyển nhượng vé điện tử cho người khác thông qua tính năng 'Chuyển vé' trong mục 'Vé của tôi'. Người nhận sẽ cần có tài khoản Ticketbox để nhận vé.",
    answerEn: "Yes, you can transfer e-tickets to others through the 'Transfer Ticket' feature in 'My Tickets' section. The recipient will need a Ticketbox account to receive the ticket.",
  },
  // Payment
  {
    category: "payment",
    question: "Ticketbox hỗ trợ những phương thức thanh toán nào?",
    questionEn: "What payment methods does Ticketbox support?",
    answer: "Chúng tôi hỗ trợ nhiều phương thức thanh toán bao gồm: Thẻ tín dụng/ghi nợ (Visa, Mastercard, JCB), Ví điện tử (MoMo, ZaloPay, VNPay), Chuyển khoản ngân hàng, và thanh toán tại cửa hàng tiện lợi.",
    answerEn: "We support multiple payment methods including: Credit/debit cards (Visa, Mastercard, JCB), E-wallets (MoMo, ZaloPay, VNPay), Bank transfer, and payment at convenience stores.",
  },
  {
    category: "payment",
    question: "Thanh toán có an toàn không?",
    questionEn: "Is payment secure?",
    answer: "Hoàn toàn an toàn. Ticketbox sử dụng công nghệ mã hóa SSL 256-bit và tuân thủ tiêu chuẩn PCI-DSS để bảo vệ thông tin thanh toán của bạn. Chúng tôi không lưu trữ thông tin thẻ của bạn.",
    answerEn: "Absolutely secure. Ticketbox uses 256-bit SSL encryption technology and complies with PCI-DSS standards to protect your payment information. We do not store your card information.",
  },
  {
    category: "payment",
    question: "Tôi có thể sử dụng mã giảm giá không?",
    questionEn: "Can I use discount codes?",
    answer: "Có, bạn có thể nhập mã giảm giá tại bước thanh toán. Mã giảm giá có thể là phần trăm hoặc số tiền cố định, và có thể có điều kiện áp dụng như số tiền tối thiểu hoặc loại vé cụ thể.",
    answerEn: "Yes, you can enter discount codes at the checkout step. Discount codes can be percentage or fixed amount, and may have conditions such as minimum amount or specific ticket types.",
  },
  // Refund
  {
    category: "refund",
    question: "Chính sách hoàn tiền như thế nào?",
    questionEn: "What is the refund policy?",
    answer: "Chính sách hoàn tiền phụ thuộc vào quy định của ban tổ chức sự kiện. Thông thường: Hoàn 100% nếu hủy trước 7 ngày, 50% nếu hủy trước 3 ngày, và không hoàn tiền trong 3 ngày trước sự kiện. Chi tiết được ghi rõ trên trang sự kiện.",
    answerEn: "Refund policy depends on the event organizer's regulations. Typically: 100% refund if cancelled 7 days before, 50% if cancelled 3 days before, and no refund within 3 days before the event. Details are specified on the event page.",
  },
  {
    category: "refund",
    question: "Làm thế nào để yêu cầu hoàn tiền?",
    questionEn: "How do I request a refund?",
    answer: "Để yêu cầu hoàn tiền, vào 'Vé của tôi', chọn đơn hàng cần hoàn, nhấn 'Yêu cầu hoàn tiền' và điền lý do. Yêu cầu sẽ được xử lý trong 3-5 ngày làm việc và tiền sẽ được hoàn về phương thức thanh toán ban đầu.",
    answerEn: "To request a refund, go to 'My Tickets', select the order to refund, click 'Request Refund' and fill in the reason. The request will be processed within 3-5 business days and money will be refunded to the original payment method.",
  },
  {
    category: "refund",
    question: "Sự kiện bị hủy thì sao?",
    questionEn: "What if the event is cancelled?",
    answer: "Nếu sự kiện bị hủy bởi ban tổ chức, bạn sẽ được hoàn 100% giá vé về phương thức thanh toán ban đầu trong vòng 7-14 ngày làm việc. Chúng tôi sẽ gửi email thông báo và hướng dẫn chi tiết.",
    answerEn: "If the event is cancelled by the organizer, you will receive a 100% refund to the original payment method within 7-14 business days. We will send an email notification with detailed instructions.",
  },
  // Security
  {
    category: "security",
    question: "Làm thế nào để bảo vệ tài khoản?",
    questionEn: "How do I protect my account?",
    answer: "Để bảo vệ tài khoản, hãy sử dụng mật khẩu mạnh (ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt), bật xác thực 2 bước, không chia sẻ thông tin đăng nhập và đăng xuất khi sử dụng thiết bị công cộng.",
    answerEn: "To protect your account, use a strong password (at least 8 characters, including uppercase, lowercase, numbers, and special characters), enable 2-factor authentication, don't share login information, and log out when using public devices.",
  },
  {
    category: "security",
    question: "Ticketbox có lưu thông tin thẻ của tôi không?",
    questionEn: "Does Ticketbox store my card information?",
    answer: "Không, Ticketbox không lưu trữ thông tin thẻ tín dụng/ghi nợ của bạn. Tất cả giao dịch được xử lý thông qua các cổng thanh toán an toàn và được mã hóa theo tiêu chuẩn quốc tế.",
    answerEn: "No, Ticketbox does not store your credit/debit card information. All transactions are processed through secure payment gateways and encrypted according to international standards.",
  },
  // Organizer
  {
    category: "organizer",
    question: "Làm thế nào để trở thành ban tổ chức?",
    questionEn: "How do I become an organizer?",
    answer: "Để trở thành ban tổ chức, đăng ký tài khoản và chọn 'Đăng ký BTC', điền thông tin doanh nghiệp/cá nhân, xác minh danh tính và chờ duyệt (1-3 ngày làm việc). Sau khi được duyệt, bạn có thể bắt đầu tạo sự kiện.",
    answerEn: "To become an organizer, register an account and select 'Register as Organizer', fill in business/personal information, verify identity, and wait for approval (1-3 business days). Once approved, you can start creating events.",
  },
  {
    category: "organizer",
    question: "Phí dịch vụ cho ban tổ chức là bao nhiêu?",
    questionEn: "What are the service fees for organizers?",
    answer: "Ticketbox thu phí dịch vụ từ 3-8% tùy thuộc vào gói dịch vụ bạn chọn. Phí này đã bao gồm: hệ thống bán vé, thanh toán, báo cáo, marketing cơ bản và hỗ trợ khách hàng 24/7.",
    answerEn: "Ticketbox charges a service fee of 3-8% depending on the service package you choose. This fee includes: ticketing system, payment processing, reports, basic marketing, and 24/7 customer support.",
  },
  {
    category: "organizer",
    question: "Khi nào tôi nhận được tiền từ việc bán vé?",
    questionEn: "When do I receive money from ticket sales?",
    answer: "Tiền bán vé sẽ được chuyển vào tài khoản ngân hàng của bạn trong vòng 3-7 ngày làm việc sau khi sự kiện kết thúc, sau khi trừ phí dịch vụ và các khoản hoàn tiền (nếu có).",
    answerEn: "Ticket sales proceeds will be transferred to your bank account within 3-7 business days after the event ends, after deducting service fees and refunds (if any).",
  },
];

const FAQ = () => {
  const { i18n } = useTranslation();
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  const filteredFAQs = faqData.filter((faq) => {
    const matchesSearch = searchQuery === "" || 
      (i18n.language === 'vi' 
        ? faq.question.toLowerCase().includes(searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().includes(searchQuery.toLowerCase())
        : faq.questionEn.toLowerCase().includes(searchQuery.toLowerCase()) ||
          faq.answerEn.toLowerCase().includes(searchQuery.toLowerCase())
      );
    
    const matchesCategory = selectedCategory === null || faq.category === selectedCategory;
    
    return matchesSearch && matchesCategory;
  });

  const groupedFAQs = selectedCategory 
    ? { [selectedCategory]: filteredFAQs }
    : filteredFAQs.reduce((acc, faq) => {
        if (!acc[faq.category]) acc[faq.category] = [];
        acc[faq.category].push(faq);
        return acc;
      }, {} as Record<string, typeof faqData>);

  return (
    <MainLayout>
      <div className="min-h-screen">
        {/* Hero Section */}
        <section className="relative py-20 overflow-hidden">
          <div className="absolute inset-0 bg-gradient-to-br from-primary/20 via-purple-500/10 to-pink-500/20" />
          <div className="absolute inset-0">
            <div className="absolute top-20 left-10 w-72 h-72 bg-primary/30 rounded-full blur-3xl" />
            <div className="absolute bottom-10 right-10 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl" />
          </div>

          <div className="relative z-10 container mx-auto px-4 text-center">
            <FadeIn>
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", delay: 0.2 }}
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/20 backdrop-blur-sm text-primary mb-6"
              >
                <HelpCircle className="h-5 w-5" />
                <span className="font-medium">
                  {i18n.language === 'vi' ? 'Trung tâm hỗ trợ' : 'Help Center'}
                </span>
              </motion.div>

              <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6">
                {i18n.language === 'vi' ? 'Câu hỏi thường gặp' : 'Frequently Asked Questions'}
              </h1>
              
              <p className="text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto mb-10">
                {i18n.language === 'vi' 
                  ? 'Tìm câu trả lời cho các thắc mắc phổ biến về Ticketbox'
                  : 'Find answers to common questions about Ticketbox'}
              </p>

              {/* Search Bar */}
              <div className="max-w-xl mx-auto relative">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                <Input
                  type="text"
                  placeholder={i18n.language === 'vi' ? 'Tìm kiếm câu hỏi...' : 'Search questions...'}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-12 py-6 text-lg bg-background/80 backdrop-blur-md border-primary/20 focus:border-primary"
                />
              </div>
            </FadeIn>
          </div>
        </section>

        {/* Category Filter */}
        <section className="py-8 container mx-auto px-4">
          <FadeIn>
            <div className="flex flex-wrap justify-center gap-3">
              <Button
                variant={selectedCategory === null ? "default" : "outline"}
                onClick={() => setSelectedCategory(null)}
                className="rounded-full"
              >
                {i18n.language === 'vi' ? 'Tất cả' : 'All'}
              </Button>
              {faqCategories.map((category) => (
                <Button
                  key={category.id}
                  variant={selectedCategory === category.id ? "default" : "outline"}
                  onClick={() => setSelectedCategory(category.id)}
                  className={`rounded-full gap-2 ${
                    selectedCategory === category.id 
                      ? `bg-gradient-to-r ${category.color} border-0` 
                      : ''
                  }`}
                >
                  <category.icon className="h-4 w-4" />
                  {i18n.language === 'vi' ? category.name : category.nameEn}
                </Button>
              ))}
            </div>
          </FadeIn>
        </section>

        {/* FAQ Accordions */}
        <section className="py-12 container mx-auto px-4">
          {Object.keys(groupedFAQs).length === 0 ? (
            <FadeIn>
              <GlassCard className="p-12 text-center">
                <HelpCircle className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
                <h3 className="text-xl font-semibold mb-2">
                  {i18n.language === 'vi' ? 'Không tìm thấy kết quả' : 'No results found'}
                </h3>
                <p className="text-muted-foreground">
                  {i18n.language === 'vi' 
                    ? 'Thử tìm kiếm với từ khóa khác hoặc liên hệ hỗ trợ'
                    : 'Try searching with different keywords or contact support'}
                </p>
              </GlassCard>
            </FadeIn>
          ) : (
            <StaggerContainer className="space-y-8">
              {Object.entries(groupedFAQs).map(([categoryId, faqs]) => {
                const category = faqCategories.find((c) => c.id === categoryId);
                if (!category || faqs.length === 0) return null;

                return (
                  <StaggerItem key={categoryId}>
                    <GlassCard className="p-6 md:p-8">
                      <div className="flex items-center gap-3 mb-6">
                        <div className={`p-3 rounded-xl bg-gradient-to-r ${category.color} text-white`}>
                          <category.icon className="h-6 w-6" />
                        </div>
                        <div>
                          <h2 className="text-2xl font-bold">
                            {i18n.language === 'vi' ? category.name : category.nameEn}
                          </h2>
                          <p className="text-muted-foreground text-sm">
                            {faqs.length} {i18n.language === 'vi' ? 'câu hỏi' : 'questions'}
                          </p>
                        </div>
                      </div>

                      <Accordion type="single" collapsible className="space-y-3">
                        {faqs.map((faq, index) => (
                          <AccordionItem 
                            key={index} 
                            value={`${categoryId}-${index}`}
                            className="border rounded-xl px-4 bg-background/50 hover:bg-background/80 transition-colors"
                          >
                            <AccordionTrigger className="text-left hover:no-underline py-4">
                              <span className="font-medium pr-4">
                                {i18n.language === 'vi' ? faq.question : faq.questionEn}
                              </span>
                            </AccordionTrigger>
                            <AccordionContent className="text-muted-foreground pb-4 leading-relaxed">
                              {i18n.language === 'vi' ? faq.answer : faq.answerEn}
                            </AccordionContent>
                          </AccordionItem>
                        ))}
                      </Accordion>
                    </GlassCard>
                  </StaggerItem>
                );
              })}
            </StaggerContainer>
          )}
        </section>

        {/* Still need help section */}
        <section className="py-20 container mx-auto px-4">
          <FadeIn>
            <GlassCard className="p-8 md:p-12 bg-gradient-to-r from-primary/10 to-purple-500/10">
              <div className="text-center mb-10">
                <h2 className="text-3xl md:text-4xl font-bold mb-4">
                  {i18n.language === 'vi' ? 'Vẫn cần hỗ trợ?' : 'Still need help?'}
                </h2>
                <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
                  {i18n.language === 'vi'
                    ? 'Đội ngũ hỗ trợ của chúng tôi luôn sẵn sàng giúp đỡ bạn'
                    : 'Our support team is always ready to help you'}
                </p>
              </div>

              <div className="grid md:grid-cols-3 gap-6">
                {[
                  {
                    icon: MessageCircle,
                    title: i18n.language === 'vi' ? 'Chat trực tiếp' : 'Live Chat',
                    description: i18n.language === 'vi' ? 'Phản hồi trong vài phút' : 'Response in minutes',
                    action: i18n.language === 'vi' ? 'Bắt đầu chat' : 'Start Chat',
                    color: 'from-blue-500 to-cyan-500',
                  },
                  {
                    icon: Mail,
                    title: 'Email',
                    description: 'support@ticketbox.vn',
                    action: i18n.language === 'vi' ? 'Gửi email' : 'Send Email',
                    color: 'from-pink-500 to-rose-500',
                  },
                  {
                    icon: Phone,
                    title: 'Hotline',
                    description: '1900-xxxx (8:00 - 22:00)',
                    action: i18n.language === 'vi' ? 'Gọi ngay' : 'Call Now',
                    color: 'from-green-500 to-emerald-500',
                  },
                ].map((contact, index) => (
                  <motion.div
                    key={index}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.1 }}
                  >
                    <GlassCard className="p-6 text-center h-full hover:scale-105 transition-transform cursor-pointer">
                      <div className={`inline-flex p-4 rounded-2xl bg-gradient-to-r ${contact.color} text-white mb-4`}>
                        <contact.icon className="h-8 w-8" />
                      </div>
                      <h3 className="text-xl font-bold mb-2">{contact.title}</h3>
                      <p className="text-muted-foreground mb-4">{contact.description}</p>
                      <Button className={`w-full bg-gradient-to-r ${contact.color} border-0 hover:opacity-90`}>
                        {contact.action}
                      </Button>
                    </GlassCard>
                  </motion.div>
                ))}
              </div>
            </GlassCard>
          </FadeIn>
        </section>

        {/* Quick Stats */}
        <section className="py-12 container mx-auto px-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {[
              { value: "24/7", label: i18n.language === 'vi' ? "Hỗ trợ" : "Support" },
              { value: "< 5 phút", label: i18n.language === 'vi' ? "Thời gian phản hồi" : "Response Time" },
              { value: "98%", label: i18n.language === 'vi' ? "Hài lòng" : "Satisfaction" },
              { value: "50K+", label: i18n.language === 'vi' ? "Câu hỏi đã giải đáp" : "Questions Answered" },
            ].map((stat, index) => (
              <FadeIn key={index} delay={index * 0.1}>
                <GlassCard className="p-6 text-center">
                  <div className="text-2xl md:text-3xl font-bold bg-gradient-to-r from-primary to-purple-500 bg-clip-text text-transparent mb-1">
                    {stat.value}
                  </div>
                  <div className="text-sm text-muted-foreground">{stat.label}</div>
                </GlassCard>
              </FadeIn>
            ))}
          </div>
        </section>
      </div>
    </MainLayout>
  );
};

export default FAQ;
