import { useState } from "react";
import { MainLayout } from "@/components/layout";
import { EventCard } from "@/components/events/EventCard";
import { GlassCard } from "@/components/ui/glass-card";
import { GradientButton } from "@/components/ui/gradient-button";
import { Input } from "@/components/ui/input";
import { 
  Search, 
  Filter, 
  Grid3X3, 
  List, 
  ChevronDown,
  Calendar,
  MapPin,
  Tag
} from "lucide-react";

// Mock data
const allEvents = [
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

const categories = ["Tất cả", "Âm nhạc", "Workshop", "Thể thao", "Ẩm thực", "Nghệ thuật", "Kinh doanh"];
const sortOptions = [
  { value: "newest", label: "Mới nhất" },
  { value: "popular", label: "Phổ biến nhất" },
  { value: "price-low", label: "Giá thấp → cao" },
  { value: "price-high", label: "Giá cao → thấp" },
  { value: "upcoming", label: "Sắp diễn ra" },
];

const Events = () => {
  const [viewMode, setViewMode] = useState<"grid" | "list">("grid");
  const [selectedCategory, setSelectedCategory] = useState("Tất cả");
  const [sortBy, setSortBy] = useState("newest");
  const [searchQuery, setSearchQuery] = useState("");
  const [showFilters, setShowFilters] = useState(false);

  const filteredEvents = allEvents.filter((event) => {
    const matchesCategory = selectedCategory === "Tất cả" || event.category === selectedCategory;
    const matchesSearch = event.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          event.location.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl md:text-4xl font-bold mb-2">Khám phá sự kiện</h1>
          <p className="text-muted-foreground">
            Tìm và đặt vé cho {allEvents.length}+ sự kiện đang diễn ra
          </p>
        </div>

        {/* Search & Filters */}
        <GlassCard variant="strong" className="p-4 md:p-6 mb-8">
          {/* Search Bar */}
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="flex-1 relative">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
              <Input
                type="text"
                placeholder="Tìm kiếm sự kiện, địa điểm..."
                className="pl-12 h-12 rounded-xl"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>
            <div className="flex gap-2">
              <GradientButton
                variant="glass"
                className="h-12"
                onClick={() => setShowFilters(!showFilters)}
              >
                <Filter className="w-5 h-5" />
                Bộ lọc
                <ChevronDown className={`w-4 h-4 transition-transform ${showFilters ? 'rotate-180' : ''}`} />
              </GradientButton>
              <GradientButton className="h-12 px-6">
                <Search className="w-5 h-5" />
                Tìm kiếm
              </GradientButton>
            </div>
          </div>

          {/* Category Pills */}
          <div className="flex flex-wrap gap-2 mb-4">
            {categories.map((category) => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${
                  selectedCategory === category
                    ? "bg-primary text-primary-foreground"
                    : "glass hover:bg-accent/50"
                }`}
              >
                {category}
              </button>
            ))}
          </div>

          {/* Advanced Filters */}
          {showFilters && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-4 border-t border-border mt-4">
              <div>
                <label className="text-sm font-medium mb-2 flex items-center gap-2">
                  <Calendar className="w-4 h-4" />
                  Ngày diễn ra
                </label>
                <Input type="date" className="h-10 rounded-xl" />
              </div>
              <div>
                <label className="text-sm font-medium mb-2 flex items-center gap-2">
                  <MapPin className="w-4 h-4" />
                  Địa điểm
                </label>
                <select className="w-full h-10 rounded-xl border border-input bg-background px-3 text-sm">
                  <option value="">Tất cả địa điểm</option>
                  <option value="hcm">TP. Hồ Chí Minh</option>
                  <option value="hanoi">Hà Nội</option>
                  <option value="danang">Đà Nẵng</option>
                </select>
              </div>
              <div>
                <label className="text-sm font-medium mb-2 flex items-center gap-2">
                  <Tag className="w-4 h-4" />
                  Mức giá
                </label>
                <select className="w-full h-10 rounded-xl border border-input bg-background px-3 text-sm">
                  <option value="">Tất cả mức giá</option>
                  <option value="free">Miễn phí</option>
                  <option value="under500">Dưới 500.000đ</option>
                  <option value="500-1000">500.000đ - 1.000.000đ</option>
                  <option value="above1000">Trên 1.000.000đ</option>
                </select>
              </div>
            </div>
          )}
        </GlassCard>

        {/* Results Header */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
          <p className="text-muted-foreground">
            Tìm thấy <span className="font-semibold text-foreground">{filteredEvents.length}</span> sự kiện
          </p>
          <div className="flex items-center gap-4">
            {/* Sort */}
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              className="h-10 rounded-xl border border-input bg-background px-3 text-sm"
            >
              {sortOptions.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>

            {/* View Toggle */}
            <div className="flex glass rounded-xl p-1">
              <button
                onClick={() => setViewMode("grid")}
                className={`p-2 rounded-lg transition-colors ${
                  viewMode === "grid" ? "bg-primary text-primary-foreground" : "text-muted-foreground"
                }`}
              >
                <Grid3X3 className="w-5 h-5" />
              </button>
              <button
                onClick={() => setViewMode("list")}
                className={`p-2 rounded-lg transition-colors ${
                  viewMode === "list" ? "bg-primary text-primary-foreground" : "text-muted-foreground"
                }`}
              >
                <List className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>

        {/* Events Grid */}
        <div className={
          viewMode === "grid"
            ? "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
            : "space-y-4"
        }>
          {filteredEvents.map((event) => (
            <EventCard key={event.id} {...event} />
          ))}
        </div>

        {/* Empty State */}
        {filteredEvents.length === 0 && (
          <GlassCard className="p-12 text-center">
            <div className="text-6xl mb-4">🔍</div>
            <h3 className="text-xl font-semibold mb-2">Không tìm thấy sự kiện</h3>
            <p className="text-muted-foreground mb-4">
              Thử thay đổi bộ lọc hoặc tìm kiếm với từ khóa khác
            </p>
            <GradientButton onClick={() => {
              setSelectedCategory("Tất cả");
              setSearchQuery("");
            }}>
              Xóa bộ lọc
            </GradientButton>
          </GlassCard>
        )}

        {/* Pagination */}
        {filteredEvents.length > 0 && (
          <div className="flex justify-center gap-2 mt-12">
            <GradientButton variant="glass" size="sm">Trước</GradientButton>
            {[1, 2, 3, 4, 5].map((page) => (
              <GradientButton
                key={page}
                variant={page === 1 ? "default" : "glass"}
                size="sm"
                className="w-10"
              >
                {page}
              </GradientButton>
            ))}
            <GradientButton variant="glass" size="sm">Sau</GradientButton>
          </div>
        )}
      </div>
    </MainLayout>
  );
};

export default Events;
