import { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { motion, AnimatePresence } from "framer-motion";
import { 
  Users, 
  Target, 
  Award, 
  Heart,
  Sparkles,
  Globe,
  Shield,
  Zap,
  ChevronLeft,
  ChevronRight,
  Quote,
  Linkedin,
  Twitter,
  Mail
} from "lucide-react";
import { MainLayout } from "@/components/layout/MainLayout";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@/components/ui/carousel";
import { FadeIn, StaggerContainer, StaggerItem, AnimatedCounter } from "@/components/ui/motion-wrapper";

const heroSlides = [
  {
    id: 1,
    title: "Kết nối mọi người qua sự kiện",
    titleEn: "Connecting People Through Events",
    subtitle: "Nền tảng bán vé số 1 Việt Nam",
    subtitleEn: "Vietnam's #1 Ticketing Platform",
    image: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1200",
  },
  {
    id: 2,
    title: "Trải nghiệm không giới hạn",
    titleEn: "Unlimited Experiences",
    subtitle: "Từ âm nhạc đến thể thao, từ nghệ thuật đến giáo dục",
    subtitleEn: "From music to sports, from art to education",
    image: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1200",
  },
  {
    id: 3,
    title: "Công nghệ hiện đại",
    titleEn: "Modern Technology",
    subtitle: "Thanh toán an toàn, vé điện tử tiện lợi",
    subtitleEn: "Secure payment, convenient e-tickets",
    image: "https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=1200",
  },
];

const values = [
  {
    icon: Heart,
    title: "Đam mê",
    titleEn: "Passion",
    description: "Chúng tôi yêu những gì mình làm và luôn nỗ lực mang đến trải nghiệm tốt nhất",
    descriptionEn: "We love what we do and always strive to deliver the best experience",
    color: "from-pink-500 to-rose-500",
  },
  {
    icon: Shield,
    title: "Tin cậy",
    titleEn: "Trust",
    description: "Bảo mật thông tin và giao dịch của khách hàng là ưu tiên hàng đầu",
    descriptionEn: "Customer data and transaction security is our top priority",
    color: "from-blue-500 to-cyan-500",
  },
  {
    icon: Sparkles,
    title: "Sáng tạo",
    titleEn: "Innovation",
    description: "Không ngừng đổi mới để mang đến những tính năng tiên tiến nhất",
    descriptionEn: "Continuously innovating to bring the most advanced features",
    color: "from-purple-500 to-violet-500",
  },
  {
    icon: Globe,
    title: "Kết nối",
    titleEn: "Connection",
    description: "Xây dựng cộng đồng yêu sự kiện và kết nối mọi người",
    descriptionEn: "Building an event-loving community and connecting people",
    color: "from-green-500 to-emerald-500",
  },
];

const team = [
  {
    name: "Nguyễn Văn An",
    role: "CEO & Founder",
    roleEn: "CEO & Founder",
    image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300",
    bio: "10+ năm kinh nghiệm trong ngành công nghệ và sự kiện",
    bioEn: "10+ years of experience in technology and events",
  },
  {
    name: "Trần Thị Bình",
    role: "CTO",
    roleEn: "CTO",
    image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300",
    bio: "Chuyên gia về kiến trúc hệ thống và bảo mật",
    bioEn: "Expert in system architecture and security",
  },
  {
    name: "Lê Hoàng Cường",
    role: "Giám đốc Vận hành",
    roleEn: "COO",
    image: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300",
    bio: "15+ năm kinh nghiệm quản lý vận hành",
    bioEn: "15+ years of operations management experience",
  },
  {
    name: "Phạm Thị Dung",
    role: "Giám đốc Marketing",
    roleEn: "CMO",
    image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300",
    bio: "Chuyên gia về digital marketing và branding",
    bioEn: "Digital marketing and branding expert",
  },
  {
    name: "Hoàng Văn Em",
    role: "Lead Developer",
    roleEn: "Lead Developer",
    image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300",
    bio: "Full-stack developer với đam mê về UX",
    bioEn: "Full-stack developer with passion for UX",
  },
  {
    name: "Ngô Thị Phương",
    role: "Head of Design",
    roleEn: "Head of Design",
    image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300",
    bio: "8+ năm kinh nghiệm thiết kế UI/UX",
    bioEn: "8+ years of UI/UX design experience",
  },
];

const testimonials = [
  {
    name: "Minh Tuấn",
    role: "Event Organizer",
    image: "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200",
    content: "Ticketbox đã giúp chúng tôi bán hơn 10,000 vé trong 2 giờ. Hệ thống ổn định và hỗ trợ rất chuyên nghiệp!",
    contentEn: "Ticketbox helped us sell over 10,000 tickets in 2 hours. Stable system and very professional support!",
  },
  {
    name: "Thu Hà",
    role: "Khách hàng",
    image: "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=200",
    content: "Mua vé rất dễ dàng, vé điện tử tiện lợi. Đã dùng Ticketbox cho mọi sự kiện!",
    contentEn: "Buying tickets is very easy, e-tickets are convenient. Have been using Ticketbox for all events!",
  },
  {
    name: "Đức Long",
    role: "Festival Manager",
    image: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200",
    content: "Tính năng check-in bằng QR code giúp tiết kiệm rất nhiều thời gian. Recommend cho tất cả các ban tổ chức!",
    contentEn: "QR code check-in feature saves a lot of time. Recommend for all organizers!",
  },
];

const milestones = [
  { year: "2019", event: "Thành lập Ticketbox", eventEn: "Ticketbox Founded" },
  { year: "2020", event: "Đạt 100,000 người dùng", eventEn: "Reached 100,000 users" },
  { year: "2021", event: "Ra mắt ứng dụng mobile", eventEn: "Launched mobile app" },
  { year: "2022", event: "Mở rộng ra 63 tỉnh thành", eventEn: "Expanded to 63 provinces" },
  { year: "2023", event: "1 triệu vé được bán", eventEn: "1 million tickets sold" },
  { year: "2024", event: "Hợp tác quốc tế", eventEn: "International partnerships" },
];

const AboutUs = () => {
  const { t, i18n } = useTranslation();
  const [currentSlide, setCurrentSlide] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % heroSlides.length);
    }, 5000);
    return () => clearInterval(timer);
  }, []);

  return (
    <MainLayout>
      <div className="min-h-screen">
        {/* Hero Slideshow */}
        <section className="relative h-[80vh] overflow-hidden">
          <AnimatePresence mode="wait">
            <motion.div
              key={currentSlide}
              initial={{ opacity: 0, scale: 1.1 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.7 }}
              className="absolute inset-0"
            >
              <div 
                className="absolute inset-0 bg-cover bg-center"
                style={{ backgroundImage: `url(${heroSlides[currentSlide].image})` }}
              />
              <div className="absolute inset-0 bg-gradient-to-b from-black/70 via-black/50 to-background" />
            </motion.div>
          </AnimatePresence>

          <div className="relative z-10 container mx-auto px-4 h-full flex flex-col justify-center items-center text-center">
            <AnimatePresence mode="wait">
              <motion.div
                key={currentSlide}
                initial={{ opacity: 0, y: 40 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -40 }}
                transition={{ duration: 0.5 }}
              >
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: "spring" }}
                  className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/20 backdrop-blur-sm text-primary mb-6"
                >
                  <Sparkles className="h-5 w-5" />
                  <span className="font-medium">
                    {i18n.language === 'vi' ? heroSlides[currentSlide].subtitle : heroSlides[currentSlide].subtitleEn}
                  </span>
                </motion.div>

                <h1 className="text-4xl md:text-6xl lg:text-7xl font-bold text-white mb-6 max-w-4xl">
                  {i18n.language === 'vi' ? heroSlides[currentSlide].title : heroSlides[currentSlide].titleEn}
                </h1>
              </motion.div>
            </AnimatePresence>

            {/* Slide Navigation */}
            <div className="absolute bottom-12 left-1/2 -translate-x-1/2 flex gap-3">
              {heroSlides.map((_, index) => (
                <button
                  key={index}
                  onClick={() => setCurrentSlide(index)}
                  className={`h-2 rounded-full transition-all duration-300 ${
                    index === currentSlide 
                      ? 'w-12 bg-primary' 
                      : 'w-2 bg-white/40 hover:bg-white/60'
                  }`}
                />
              ))}
            </div>

            {/* Navigation Arrows */}
            <div className="absolute bottom-12 right-8 flex gap-3">
              <Button
                variant="outline"
                size="icon"
                className="rounded-full bg-white/10 backdrop-blur-md border-white/20 text-white hover:bg-white/20"
                onClick={() => setCurrentSlide((prev) => (prev === 0 ? heroSlides.length - 1 : prev - 1))}
              >
                <ChevronLeft className="h-5 w-5" />
              </Button>
              <Button
                variant="outline"
                size="icon"
                className="rounded-full bg-white/10 backdrop-blur-md border-white/20 text-white hover:bg-white/20"
                onClick={() => setCurrentSlide((prev) => (prev + 1) % heroSlides.length)}
              >
                <ChevronRight className="h-5 w-5" />
              </Button>
            </div>
          </div>
        </section>

        {/* Mission & Vision */}
        <section className="py-20 container mx-auto px-4">
          <div className="grid md:grid-cols-2 gap-12">
            <FadeIn direction="left">
              <GlassCard className="p-8 h-full">
                <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-gradient-to-r from-pink-500 to-rose-500 text-white mb-6">
                  <Target className="h-5 w-5" />
                  <span className="font-semibold">{i18n.language === 'vi' ? 'Sứ mệnh' : 'Mission'}</span>
                </div>
                <h2 className="text-3xl font-bold mb-4">
                  {i18n.language === 'vi' 
                    ? 'Mang sự kiện đến gần hơn với mọi người' 
                    : 'Bringing events closer to everyone'}
                </h2>
                <p className="text-muted-foreground text-lg leading-relaxed">
                  {i18n.language === 'vi'
                    ? 'Chúng tôi tin rằng mỗi sự kiện là một cơ hội để kết nối, học hỏi và tạo ra những kỷ niệm đáng nhớ. Ticketbox cam kết xây dựng nền tảng công nghệ tiên tiến, giúp người tổ chức dễ dàng quản lý sự kiện và khách hàng có trải nghiệm mua vé thuận tiện nhất.'
                    : 'We believe every event is an opportunity to connect, learn, and create memorable moments. Ticketbox is committed to building an advanced technology platform that helps organizers easily manage events and customers have the most convenient ticket purchasing experience.'}
                </p>
              </GlassCard>
            </FadeIn>

            <FadeIn direction="right">
              <GlassCard className="p-8 h-full">
                <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-gradient-to-r from-purple-500 to-indigo-500 text-white mb-6">
                  <Sparkles className="h-5 w-5" />
                  <span className="font-semibold">{i18n.language === 'vi' ? 'Tầm nhìn' : 'Vision'}</span>
                </div>
                <h2 className="text-3xl font-bold mb-4">
                  {i18n.language === 'vi' 
                    ? 'Trở thành nền tảng sự kiện hàng đầu Đông Nam Á' 
                    : 'Become the leading event platform in Southeast Asia'}
                </h2>
                <p className="text-muted-foreground text-lg leading-relaxed">
                  {i18n.language === 'vi'
                    ? 'Đến năm 2030, Ticketbox đặt mục tiêu phục vụ hàng triệu người dùng, hỗ trợ hàng ngàn ban tổ chức và góp phần phát triển ngành công nghiệp sự kiện tại Việt Nam và khu vực Đông Nam Á.'
                    : 'By 2030, Ticketbox aims to serve millions of users, support thousands of organizers, and contribute to the development of the event industry in Vietnam and Southeast Asia.'}
                </p>
              </GlassCard>
            </FadeIn>
          </div>
        </section>

        {/* Core Values */}
        <section className="py-20 bg-muted/30">
          <div className="container mx-auto px-4">
            <FadeIn>
              <div className="text-center mb-12">
                <h2 className="text-3xl md:text-4xl font-bold mb-4">
                  {i18n.language === 'vi' ? 'Giá trị cốt lõi' : 'Core Values'}
                </h2>
                <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
                  {i18n.language === 'vi' 
                    ? 'Những giá trị định hướng mọi hoạt động của chúng tôi'
                    : 'Values that guide all our activities'}
                </p>
              </div>
            </FadeIn>

            <StaggerContainer className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
              {values.map((value, index) => (
                <StaggerItem key={index}>
                  <GlassCard className="p-6 text-center h-full hover:scale-105 transition-transform">
                    <div className={`inline-flex p-4 rounded-2xl bg-gradient-to-r ${value.color} text-white mb-4`}>
                      <value.icon className="h-8 w-8" />
                    </div>
                    <h3 className="text-xl font-bold mb-2">
                      {i18n.language === 'vi' ? value.title : value.titleEn}
                    </h3>
                    <p className="text-muted-foreground">
                      {i18n.language === 'vi' ? value.description : value.descriptionEn}
                    </p>
                  </GlassCard>
                </StaggerItem>
              ))}
            </StaggerContainer>
          </div>
        </section>

        {/* Stats */}
        <section className="py-20 container mx-auto px-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {[
              { value: 1000000, suffix: "+", label: i18n.language === 'vi' ? "Vé đã bán" : "Tickets Sold" },
              { value: 500000, suffix: "+", label: i18n.language === 'vi' ? "Người dùng" : "Users" },
              { value: 5000, suffix: "+", label: i18n.language === 'vi' ? "Sự kiện" : "Events" },
              { value: 200, suffix: "+", label: i18n.language === 'vi' ? "Đối tác" : "Partners" },
            ].map((stat, index) => (
              <FadeIn key={index} delay={index * 0.1}>
                <GlassCard className="p-8 text-center">
                  <div className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-primary to-purple-500 bg-clip-text text-transparent mb-2">
                    <AnimatedCounter value={stat.value} suffix={stat.suffix} />
                  </div>
                  <div className="text-muted-foreground">{stat.label}</div>
                </GlassCard>
              </FadeIn>
            ))}
          </div>
        </section>

        {/* Timeline */}
        <section className="py-20 bg-muted/30">
          <div className="container mx-auto px-4">
            <FadeIn>
              <h2 className="text-3xl md:text-4xl font-bold text-center mb-12">
                {i18n.language === 'vi' ? 'Hành trình phát triển' : 'Our Journey'}
              </h2>
            </FadeIn>

            <div className="relative">
              <div className="absolute left-1/2 top-0 bottom-0 w-0.5 bg-gradient-to-b from-primary via-purple-500 to-pink-500 hidden md:block" />
              
              <div className="space-y-8">
                {milestones.map((milestone, index) => (
                  <FadeIn key={index} direction={index % 2 === 0 ? "left" : "right"} delay={index * 0.1}>
                    <div className={`flex items-center gap-8 ${index % 2 === 0 ? 'md:flex-row' : 'md:flex-row-reverse'}`}>
                      <div className={`flex-1 ${index % 2 === 0 ? 'md:text-right' : 'md:text-left'}`}>
                        <GlassCard className="p-6 inline-block">
                          <div className="text-2xl font-bold text-primary mb-1">{milestone.year}</div>
                          <div className="text-lg">
                            {i18n.language === 'vi' ? milestone.event : milestone.eventEn}
                          </div>
                        </GlassCard>
                      </div>
                      <div className="hidden md:flex w-4 h-4 rounded-full bg-primary ring-4 ring-primary/20" />
                      <div className="flex-1" />
                    </div>
                  </FadeIn>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* Team Carousel */}
        <section className="py-20 container mx-auto px-4">
          <FadeIn>
            <div className="text-center mb-12">
              <h2 className="text-3xl md:text-4xl font-bold mb-4">
                {i18n.language === 'vi' ? 'Đội ngũ của chúng tôi' : 'Our Team'}
              </h2>
              <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
                {i18n.language === 'vi' 
                  ? 'Những con người tài năng và đam mê đứng sau Ticketbox'
                  : 'The talented and passionate people behind Ticketbox'}
              </p>
            </div>
          </FadeIn>

          <Carousel
            opts={{
              align: "start",
              loop: true,
            }}
            className="w-full"
          >
            <CarouselContent className="-ml-4">
              {team.map((member, index) => (
                <CarouselItem key={index} className="pl-4 md:basis-1/2 lg:basis-1/3">
                  <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.1 }}
                  >
                    <GlassCard className="p-6 text-center">
                      <Avatar className="w-24 h-24 mx-auto mb-4 ring-4 ring-primary/20">
                        <AvatarImage src={member.image} alt={member.name} />
                        <AvatarFallback>{member.name.charAt(0)}</AvatarFallback>
                      </Avatar>
                      <h3 className="text-xl font-bold mb-1">{member.name}</h3>
                      <p className="text-primary font-medium mb-2">
                        {i18n.language === 'vi' ? member.role : member.roleEn}
                      </p>
                      <p className="text-muted-foreground text-sm mb-4">
                        {i18n.language === 'vi' ? member.bio : member.bioEn}
                      </p>
                      <div className="flex justify-center gap-3">
                        <Button variant="ghost" size="icon" className="rounded-full">
                          <Linkedin className="h-4 w-4" />
                        </Button>
                        <Button variant="ghost" size="icon" className="rounded-full">
                          <Twitter className="h-4 w-4" />
                        </Button>
                        <Button variant="ghost" size="icon" className="rounded-full">
                          <Mail className="h-4 w-4" />
                        </Button>
                      </div>
                    </GlassCard>
                  </motion.div>
                </CarouselItem>
              ))}
            </CarouselContent>
            <CarouselPrevious className="hidden md:flex -left-4" />
            <CarouselNext className="hidden md:flex -right-4" />
          </Carousel>
        </section>

        {/* Testimonials */}
        <section className="py-20 bg-muted/30">
          <div className="container mx-auto px-4">
            <FadeIn>
              <div className="text-center mb-12">
                <h2 className="text-3xl md:text-4xl font-bold mb-4">
                  {i18n.language === 'vi' ? 'Khách hàng nói gì về chúng tôi' : 'What Our Customers Say'}
                </h2>
              </div>
            </FadeIn>

            <Carousel
              opts={{
                align: "center",
                loop: true,
              }}
              className="w-full max-w-4xl mx-auto"
            >
              <CarouselContent>
                {testimonials.map((testimonial, index) => (
                  <CarouselItem key={index}>
                    <GlassCard className="p-8 md:p-12 text-center">
                      <Quote className="h-12 w-12 text-primary/30 mx-auto mb-6" />
                      <p className="text-xl md:text-2xl mb-8 leading-relaxed">
                        "{i18n.language === 'vi' ? testimonial.content : testimonial.contentEn}"
                      </p>
                      <Avatar className="w-16 h-16 mx-auto mb-4">
                        <AvatarImage src={testimonial.image} alt={testimonial.name} />
                        <AvatarFallback>{testimonial.name.charAt(0)}</AvatarFallback>
                      </Avatar>
                      <div className="font-bold text-lg">{testimonial.name}</div>
                      <div className="text-muted-foreground">{testimonial.role}</div>
                    </GlassCard>
                  </CarouselItem>
                ))}
              </CarouselContent>
              <CarouselPrevious className="hidden md:flex" />
              <CarouselNext className="hidden md:flex" />
            </Carousel>
          </div>
        </section>

        {/* CTA */}
        <section className="py-20 container mx-auto px-4">
          <FadeIn>
            <GlassCard className="p-12 text-center bg-gradient-to-r from-primary/10 to-purple-500/10">
              <h2 className="text-3xl md:text-4xl font-bold mb-4">
                {i18n.language === 'vi' ? 'Sẵn sàng tạo sự kiện?' : 'Ready to Create an Event?'}
              </h2>
              <p className="text-muted-foreground text-lg mb-8 max-w-2xl mx-auto">
                {i18n.language === 'vi'
                  ? 'Tham gia cùng hàng ngàn ban tổ chức đang sử dụng Ticketbox để tạo nên những sự kiện thành công'
                  : 'Join thousands of organizers using Ticketbox to create successful events'}
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Button size="lg" className="bg-gradient-to-r from-primary to-purple-500 hover:opacity-90">
                  {i18n.language === 'vi' ? 'Bắt đầu miễn phí' : 'Start for Free'}
                </Button>
                <Button size="lg" variant="outline">
                  {i18n.language === 'vi' ? 'Liên hệ tư vấn' : 'Contact Sales'}
                </Button>
              </div>
            </GlassCard>
          </FadeIn>
        </section>
      </div>
    </MainLayout>
  );
};

export default AboutUs;
