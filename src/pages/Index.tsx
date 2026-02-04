import { useTranslation } from "react-i18next";
import { MainLayout } from "@/components/layout";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { EventCard } from "@/components/events/EventCard";
import { CategoryCard } from "@/components/events/CategoryCard";
import { Search, ArrowRight, ChevronRight, Star, TrendingUp } from "lucide-react";
import { Link } from "react-router-dom";

// Mock data
const featuredEvents = [
  {
    id: "1",
    title: "Đêm nhạc Acoustic - Những bản tình ca",
    image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800",
    date: "15/02/2026 - 20:00",
    location: "Nhà hát Thành phố, Quận 1, TP.HCM",
    price: 350000,
    category: "Âm nhạc",
    attendees: 1250,
  },
  {
    id: "2",
    title: "Workshop UI/UX Design cho người mới bắt đầu",
    image: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800",
    date: "20/02/2026 - 09:00",
    location: "Dreamplex, Quận 3, TP.HCM",
    price: 500000,
    category: "Workshop",
    attendees: 320,
  },
  {
    id: "3",
    title: "Lễ hội Ẩm thực Đường phố 2026",
    image: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800",
    date: "25/02/2026 - 16:00",
    location: "Công viên 23/9, Quận 1, TP.HCM",
    price: 0,
    category: "Ẩm thực",
    attendees: 5000,
  },
  {
    id: "4",
    title: "Giải Marathon Thành phố 2026",
    image: "https://images.unsplash.com/photo-1530549387789-4c1017266635?w=800",
    date: "01/03/2026 - 05:00",
    location: "Quận 7, TP.HCM",
    price: 200000,
    category: "Thể thao",
    attendees: 8500,
  },
];

const categories = [
  { id: "music", name: "Âm nhạc", icon: "music", count: 156, color: "pink" },
  { id: "workshop", name: "Workshop", icon: "education", count: 89, color: "purple" },
  { id: "sports", name: "Thể thao", icon: "sports", count: 67, color: "blue" },
  { id: "food", name: "Ẩm thực", icon: "food", count: 45, color: "orange" },
  { id: "art", name: "Nghệ thuật", icon: "art", count: 78, color: "teal" },
  { id: "business", name: "Kinh doanh", icon: "business", count: 34, color: "green" },
  { id: "charity", name: "Từ thiện", icon: "charity", count: 23, color: "red" },
  { id: "entertainment", name: "Giải trí", icon: "entertainment", count: 112, color: "yellow" },
];

const upcomingEvents = [
  {
    id: "5",
    title: "Triển lãm Nghệ thuật Đương đại",
    image: "https://images.unsplash.com/photo-1531058020387-3be344556be6?w=800",
    date: "10/02/2026 - 10:00",
    location: "Bảo tàng Mỹ thuật, Quận 1",
    price: 100000,
    category: "Nghệ thuật",
  },
  {
    id: "6",
    title: "Hội thảo Khởi nghiệp 2026",
    image: "https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800",
    date: "12/02/2026 - 08:30",
    location: "GEM Center, Quận 1",
    price: 1500000,
    category: "Kinh doanh",
  },
  {
    id: "7",
    title: "Live Concert - Indie Night",
    image: "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800",
    date: "18/02/2026 - 19:30",
    location: "Cargo Bar, Quận 4",
    price: 250000,
    category: "Âm nhạc",
  },
  {
    id: "8",
    title: "Yoga ngoài trời - Sunrise Session",
    image: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800",
    date: "22/02/2026 - 06:00",
    location: "Công viên Gia Định",
    price: 0,
    category: "Thể thao",
  },
];

const Index = () => {
  const { t } = useTranslation();

  return (
    <MainLayout headerVariant="transparent">
      {/* Hero Section */}
      <section className="relative min-h-[85vh] flex items-center overflow-hidden">
        {/* Background decoration */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-20 left-10 w-72 h-72 bg-pink-300/30 rounded-full blur-3xl animate-float" />
          <div className="absolute bottom-20 right-10 w-96 h-96 bg-purple-300/30 rounded-full blur-3xl animate-float" style={{ animationDelay: "1s" }} />
          <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-gradient-to-br from-pink-200/20 to-purple-200/20 rounded-full blur-3xl" />
        </div>

        <div className="container mx-auto px-4 relative z-10">
          <div className="max-w-4xl mx-auto text-center">
            {/* Badge */}
            <div className="inline-flex items-center gap-2 glass px-4 py-2 rounded-full mb-8 animate-fade-in">
              <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
              <span className="text-sm font-medium">{t("header.platformBadge")}</span>
            </div>

            {/* Heading */}
            <h1 className="text-4xl md:text-6xl lg:text-7xl font-bold mb-6 animate-fade-in" style={{ animationDelay: "0.1s" }}>
              {t("hero.title")}{" "}
              <span className="text-gradient">{t("hero.titleHighlight")}</span>
              <br />
              {t("hero.titleEnd")}
            </h1>

            {/* Subheading */}
            <p className="text-lg md:text-xl text-muted-foreground mb-10 max-w-2xl mx-auto animate-fade-in" style={{ animationDelay: "0.2s" }}>
              {t("hero.subtitle")}
            </p>

            {/* Search Bar */}
            <div className="animate-fade-in" style={{ animationDelay: "0.3s" }}>
              <GlassCard className="max-w-2xl mx-auto p-2">
                <div className="flex flex-col sm:flex-row gap-2">
                  <div className="flex-1 flex items-center gap-3 px-4 py-3 bg-background/50 rounded-xl">
                    <Search className="w-5 h-5 text-muted-foreground" />
                    <input
                      type="text"
                      placeholder={t("common.searchAdvanced")}
                      className="flex-1 bg-transparent border-none outline-none text-base placeholder:text-muted-foreground"
                    />
                  </div>
                  <GradientButton size="lg" className="px-8">
                    <Search className="w-5 h-5 mr-2" />
                    {t("common.search")}
                  </GradientButton>
                </div>
              </GlassCard>
            </div>

            {/* Stats */}
            <div className="flex flex-wrap justify-center gap-8 mt-12 animate-fade-in" style={{ animationDelay: "0.4s" }}>
              {[
                { value: "10K+", label: t("hero.stats.events") },
                { value: "500K+", label: t("hero.stats.users") },
                { value: "1M+", label: t("hero.stats.ticketsSold") },
              ].map((stat, index) => (
                <div key={index} className="text-center">
                  <div className="text-3xl md:text-4xl font-bold text-gradient">{stat.value}</div>
                  <div className="text-sm text-muted-foreground">{stat.label}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Categories Section */}
      <section className="py-16 md:py-24">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="text-2xl md:text-3xl font-bold mb-2">{t("categories.title")}</h2>
              <p className="text-muted-foreground">{t("categories.subtitle")}</p>
            </div>
            <Link to="/categories">
              <GradientButton variant="ghost">
                {t("common.viewAll")}
                <ChevronRight className="w-4 h-4" />
              </GradientButton>
            </Link>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-8 gap-4">
            {categories.map((category) => (
              <CategoryCard key={category.id} {...category} />
            ))}
          </div>
        </div>
      </section>

      {/* Featured Events */}
      <section className="py-16 md:py-24">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between mb-8">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-pink-500 to-purple-600 flex items-center justify-center">
                <TrendingUp className="w-5 h-5 text-white" />
              </div>
              <div>
                <h2 className="text-2xl md:text-3xl font-bold">{t("events.featured")}</h2>
                <p className="text-muted-foreground">{t("events.featuredSubtitle")}</p>
              </div>
            </div>
            <Link to="/events?sort=popular">
              <GradientButton variant="ghost">
                {t("common.viewAll")}
                <ChevronRight className="w-4 h-4" />
              </GradientButton>
            </Link>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {featuredEvents.map((event) => (
              <EventCard key={event.id} {...event} />
            ))}
          </div>
        </div>
      </section>

      {/* Upcoming Events */}
      <section className="py-16 md:py-24">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="text-2xl md:text-3xl font-bold">{t("events.upcoming")}</h2>
              <p className="text-muted-foreground">{t("events.upcomingSubtitle")}</p>
            </div>
            <Link to="/events?sort=upcoming">
              <GradientButton variant="ghost">
                {t("common.viewAll")}
                <ChevronRight className="w-4 h-4" />
              </GradientButton>
            </Link>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {upcomingEvents.map((event) => (
              <EventCard key={event.id} {...event} />
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 md:py-24">
        <div className="container mx-auto px-4">
          <GlassCard variant="strong" className="p-8 md:p-12 text-center">
            <h2 className="text-2xl md:text-4xl font-bold mb-4">
              {t("cta.organizerTitle")}
            </h2>
            <p className="text-muted-foreground mb-8 max-w-2xl mx-auto">
              {t("cta.organizerSubtitle")}
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link to="/organizer/register">
                <GradientButton size="lg">
                  {t("cta.registerNow")}
                  <ArrowRight className="w-5 h-5" />
                </GradientButton>
              </Link>
              <Link to="/pricing">
                <GradientButton variant="secondary" size="lg">
                  {t("cta.viewPricing")}
                </GradientButton>
              </Link>
            </div>
          </GlassCard>
        </div>
      </section>
    </MainLayout>
  );
};

export default Index;
