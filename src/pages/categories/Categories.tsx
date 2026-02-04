import { useState } from "react";
import { useTranslation } from "react-i18next";
import { motion, AnimatePresence } from "framer-motion";
import { 
  Music, 
  Palette, 
  Trophy, 
  Briefcase, 
  GraduationCap, 
  Heart,
  Film,
  Utensils,
  ChevronLeft,
  ChevronRight,
  Calendar,
  MapPin,
  Users
} from "lucide-react";
import { MainLayout } from "@/components/layout/MainLayout";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@/components/ui/carousel";
import { FadeIn, StaggerContainer, StaggerItem } from "@/components/ui/motion-wrapper";

const categories = [
  {
    id: "music",
    name: "Âm nhạc",
    nameEn: "Music",
    icon: Music,
    color: "from-pink-500 to-rose-500",
    bgImage: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800",
    description: "Hòa nhạc, live show, festival và các buổi biểu diễn âm nhạc",
    descriptionEn: "Concerts, live shows, festivals and music performances",
    eventCount: 156,
    upcomingEvents: [
      { title: "Rock Festival 2024", date: "15/03/2024", location: "Sân vận động Mỹ Đình" },
      { title: "Jazz Night", date: "20/03/2024", location: "Nhà hát Lớn Hà Nội" },
      { title: "EDM Party", date: "25/03/2024", location: "GEM Center, HCM" },
    ]
  },
  {
    id: "art",
    name: "Nghệ thuật",
    nameEn: "Art & Culture",
    icon: Palette,
    color: "from-purple-500 to-indigo-500",
    bgImage: "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800",
    description: "Triển lãm, gallery, biểu diễn nghệ thuật và văn hóa",
    descriptionEn: "Exhibitions, galleries, art performances and culture",
    eventCount: 89,
    upcomingEvents: [
      { title: "Contemporary Art Show", date: "18/03/2024", location: "Bảo tàng Mỹ thuật" },
      { title: "Photography Exhibition", date: "22/03/2024", location: "The Factory" },
      { title: "Digital Art Festival", date: "28/03/2024", location: "Vincom Center" },
    ]
  },
  {
    id: "sports",
    name: "Thể thao",
    nameEn: "Sports",
    icon: Trophy,
    color: "from-green-500 to-emerald-500",
    bgImage: "https://images.unsplash.com/photo-1461896836934- voices-of-the-people-2?w=800",
    description: "Giải đấu thể thao, marathon, yoga và các hoạt động thể chất",
    descriptionEn: "Sports tournaments, marathons, yoga and physical activities",
    eventCount: 124,
    upcomingEvents: [
      { title: "Marathon Hà Nội 2024", date: "10/04/2024", location: "Hồ Hoàn Kiếm" },
      { title: "Yoga Festival", date: "15/04/2024", location: "Ecopark" },
      { title: "Football Championship", date: "20/04/2024", location: "Sân Thống Nhất" },
    ]
  },
  {
    id: "business",
    name: "Kinh doanh",
    nameEn: "Business",
    icon: Briefcase,
    color: "from-blue-500 to-cyan-500",
    bgImage: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800",
    description: "Hội nghị, hội thảo, networking và sự kiện doanh nghiệp",
    descriptionEn: "Conferences, seminars, networking and corporate events",
    eventCount: 67,
    upcomingEvents: [
      { title: "Tech Summit 2024", date: "12/03/2024", location: "JW Marriott" },
      { title: "Startup Weekend", date: "18/03/2024", location: "Dreamplex" },
      { title: "Marketing Conference", date: "25/03/2024", location: "Gem Center" },
    ]
  },
  {
    id: "education",
    name: "Giáo dục",
    nameEn: "Education",
    icon: GraduationCap,
    color: "from-orange-500 to-amber-500",
    bgImage: "https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800",
    description: "Workshop, khóa học, hội thảo chuyên đề và đào tạo",
    descriptionEn: "Workshops, courses, seminars and training",
    eventCount: 203,
    upcomingEvents: [
      { title: "AI Workshop", date: "14/03/2024", location: "FPT Tower" },
      { title: "Design Thinking", date: "21/03/2024", location: "WeWork" },
      { title: "Language Exchange", date: "27/03/2024", location: "The Coffee House" },
    ]
  },
  {
    id: "charity",
    name: "Từ thiện",
    nameEn: "Charity",
    icon: Heart,
    color: "from-red-500 to-pink-500",
    bgImage: "https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=800",
    description: "Hoạt động thiện nguyện, gây quỹ và cộng đồng",
    descriptionEn: "Volunteer activities, fundraising and community",
    eventCount: 45,
    upcomingEvents: [
      { title: "Charity Run", date: "16/03/2024", location: "Công viên Thống Nhất" },
      { title: "Blood Donation", date: "23/03/2024", location: "Bệnh viện Bạch Mai" },
      { title: "Green Cleanup", date: "30/03/2024", location: "Bãi biển Đà Nẵng" },
    ]
  },
  {
    id: "entertainment",
    name: "Giải trí",
    nameEn: "Entertainment",
    icon: Film,
    color: "from-violet-500 to-purple-500",
    bgImage: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800",
    description: "Phim, kịch, hài, game show và các hoạt động giải trí",
    descriptionEn: "Movies, theater, comedy, game shows and entertainment",
    eventCount: 178,
    upcomingEvents: [
      { title: "Comedy Night", date: "17/03/2024", location: "Nhà hát Tuổi trẻ" },
      { title: "Film Festival", date: "24/03/2024", location: "CGV Vincom" },
      { title: "Game Tournament", date: "31/03/2024", location: "Cyber Game" },
    ]
  },
  {
    id: "food",
    name: "Ẩm thực",
    nameEn: "Food & Drink",
    icon: Utensils,
    color: "from-yellow-500 to-orange-500",
    bgImage: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800",
    description: "Lễ hội ẩm thực, wine tasting, cooking class",
    descriptionEn: "Food festivals, wine tasting, cooking classes",
    eventCount: 92,
    upcomingEvents: [
      { title: "Street Food Festival", date: "19/03/2024", location: "Phố đi bộ Nguyễn Huệ" },
      { title: "Wine Tasting", date: "26/03/2024", location: "InterContinental" },
      { title: "Cooking Masterclass", date: "02/04/2024", location: "Le Cordon Bleu" },
    ]
  },
];

const Categories = () => {
  const { t, i18n } = useTranslation();
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);
  const [activeIndex, setActiveIndex] = useState(0);

  const handleCategoryChange = (index: number) => {
    setActiveIndex(index);
    setSelectedCategory(categories[index]);
  };

  return (
    <MainLayout>
      <div className="min-h-screen">
        {/* Hero Section with Main Carousel */}
        <section className="relative h-[70vh] overflow-hidden">
          <AnimatePresence mode="wait">
            <motion.div
              key={selectedCategory.id}
              initial={{ opacity: 0, scale: 1.1 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              transition={{ duration: 0.5 }}
              className="absolute inset-0"
            >
              <div 
                className="absolute inset-0 bg-cover bg-center"
                style={{ backgroundImage: `url(${selectedCategory.bgImage})` }}
              />
              <div className="absolute inset-0 bg-gradient-to-b from-black/60 via-black/40 to-background" />
            </motion.div>
          </AnimatePresence>

          <div className="relative z-10 container mx-auto px-4 h-full flex flex-col justify-center">
            <AnimatePresence mode="wait">
              <motion.div
                key={selectedCategory.id}
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -30 }}
                transition={{ duration: 0.4 }}
                className="max-w-2xl"
              >
                <div className={`inline-flex items-center gap-3 px-4 py-2 rounded-full bg-gradient-to-r ${selectedCategory.color} text-white mb-6`}>
                  <selectedCategory.icon className="h-5 w-5" />
                  <span className="font-semibold">
                    {i18n.language === 'vi' ? selectedCategory.name : selectedCategory.nameEn}
                  </span>
                </div>

                <h1 className="text-4xl md:text-6xl font-bold text-white mb-4">
                  {i18n.language === 'vi' ? selectedCategory.name : selectedCategory.nameEn}
                </h1>
                
                <p className="text-lg md:text-xl text-white/80 mb-6">
                  {i18n.language === 'vi' ? selectedCategory.description : selectedCategory.descriptionEn}
                </p>

                <div className="flex items-center gap-6 text-white/90">
                  <div className="flex items-center gap-2">
                    <Calendar className="h-5 w-5" />
                    <span>{selectedCategory.eventCount} {t('events.title')}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Users className="h-5 w-5" />
                    <span>{Math.floor(selectedCategory.eventCount * 150)}+ {i18n.language === 'vi' ? 'người tham gia' : 'attendees'}</span>
                  </div>
                </div>

                <Button 
                  size="lg" 
                  className={`mt-8 bg-gradient-to-r ${selectedCategory.color} hover:opacity-90 text-white border-0`}
                >
                  {t('events.exploreEvents')}
                </Button>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Navigation Arrows */}
          <div className="absolute bottom-8 right-8 flex gap-3 z-20">
            <Button
              variant="outline"
              size="icon"
              className="rounded-full bg-white/10 backdrop-blur-md border-white/20 text-white hover:bg-white/20"
              onClick={() => handleCategoryChange(activeIndex === 0 ? categories.length - 1 : activeIndex - 1)}
            >
              <ChevronLeft className="h-5 w-5" />
            </Button>
            <Button
              variant="outline"
              size="icon"
              className="rounded-full bg-white/10 backdrop-blur-md border-white/20 text-white hover:bg-white/20"
              onClick={() => handleCategoryChange(activeIndex === categories.length - 1 ? 0 : activeIndex + 1)}
            >
              <ChevronRight className="h-5 w-5" />
            </Button>
          </div>

          {/* Dots Indicator */}
          <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex gap-2 z-20">
            {categories.map((_, index) => (
              <button
                key={index}
                onClick={() => handleCategoryChange(index)}
                className={`w-2 h-2 rounded-full transition-all ${
                  index === activeIndex 
                    ? 'w-8 bg-white' 
                    : 'bg-white/40 hover:bg-white/60'
                }`}
              />
            ))}
          </div>
        </section>

        {/* Category Cards Carousel */}
        <section className="py-16 container mx-auto px-4">
          <FadeIn>
            <h2 className="text-3xl font-bold text-center mb-12">
              {i18n.language === 'vi' ? 'Khám phá danh mục' : 'Explore Categories'}
            </h2>
          </FadeIn>

          <Carousel
            opts={{
              align: "start",
              loop: true,
            }}
            className="w-full"
          >
            <CarouselContent className="-ml-4">
              {categories.map((category, index) => (
                <CarouselItem key={category.id} className="pl-4 md:basis-1/2 lg:basis-1/3 xl:basis-1/4">
                  <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.1 }}
                  >
                    <GlassCard 
                      className={`p-0 overflow-hidden cursor-pointer transition-all duration-300 hover:scale-105 ${
                        activeIndex === index ? 'ring-2 ring-primary' : ''
                      }`}
                      onClick={() => handleCategoryChange(index)}
                    >
                      <div className="relative h-48">
                        <img 
                          src={category.bgImage} 
                          alt={category.name}
                          className="w-full h-full object-cover"
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />
                        <div className="absolute bottom-4 left-4 right-4">
                          <div className={`inline-flex items-center gap-2 px-3 py-1 rounded-full bg-gradient-to-r ${category.color} text-white text-sm mb-2`}>
                            <category.icon className="h-4 w-4" />
                            <span>{i18n.language === 'vi' ? category.name : category.nameEn}</span>
                          </div>
                          <p className="text-white/80 text-sm">
                            {category.eventCount} {t('events.title')}
                          </p>
                        </div>
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

        {/* Upcoming Events in Selected Category */}
        <section className="py-16 bg-muted/30">
          <div className="container mx-auto px-4">
            <FadeIn>
              <div className="flex items-center justify-between mb-8">
                <h2 className="text-2xl font-bold">
                  {i18n.language === 'vi' ? 'Sự kiện sắp diễn ra' : 'Upcoming Events'} - {i18n.language === 'vi' ? selectedCategory.name : selectedCategory.nameEn}
                </h2>
                <Button variant="outline">
                  {t('common.viewAll')}
                </Button>
              </div>
            </FadeIn>

            <StaggerContainer className="grid md:grid-cols-3 gap-6">
              <AnimatePresence mode="wait">
                {selectedCategory.upcomingEvents.map((event, index) => (
                  <StaggerItem key={`${selectedCategory.id}-${index}`}>
                    <motion.div
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -20 }}
                      transition={{ delay: index * 0.1 }}
                    >
                      <GlassCard className="p-6 hover:scale-105 transition-transform cursor-pointer">
                        <Badge className={`bg-gradient-to-r ${selectedCategory.color} text-white border-0 mb-4`}>
                          {i18n.language === 'vi' ? selectedCategory.name : selectedCategory.nameEn}
                        </Badge>
                        <h3 className="text-xl font-semibold mb-3">{event.title}</h3>
                        <div className="space-y-2 text-muted-foreground">
                          <div className="flex items-center gap-2">
                            <Calendar className="h-4 w-4" />
                            <span>{event.date}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <MapPin className="h-4 w-4" />
                            <span>{event.location}</span>
                          </div>
                        </div>
                      </GlassCard>
                    </motion.div>
                  </StaggerItem>
                ))}
              </AnimatePresence>
            </StaggerContainer>
          </div>
        </section>

        {/* Stats Section */}
        <section className="py-20 container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            {[
              { value: "1,000+", label: i18n.language === 'vi' ? "Sự kiện" : "Events" },
              { value: "500K+", label: i18n.language === 'vi' ? "Người tham gia" : "Attendees" },
              { value: "200+", label: i18n.language === 'vi' ? "Ban tổ chức" : "Organizers" },
              { value: "8", label: i18n.language === 'vi' ? "Danh mục" : "Categories" },
            ].map((stat, index) => (
              <FadeIn key={index} delay={index * 0.1}>
                <GlassCard className="p-8 text-center">
                  <div className="text-4xl font-bold bg-gradient-to-r from-primary to-purple-500 bg-clip-text text-transparent mb-2">
                    {stat.value}
                  </div>
                  <div className="text-muted-foreground">{stat.label}</div>
                </GlassCard>
              </FadeIn>
            ))}
          </div>
        </section>
      </div>
    </MainLayout>
  );
};

export default Categories;
