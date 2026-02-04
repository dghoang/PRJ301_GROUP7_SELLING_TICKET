import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { GlassCard } from "@/components/ui/glass-card";
import { Calendar, MapPin, Users } from "lucide-react";
import { cn } from "@/lib/utils";

interface EventCardProps {
  id: string;
  title: string;
  image: string;
  date: string;
  location: string;
  price: number;
  category: string;
  attendees?: number;
  isPrivate?: boolean;
  className?: string;
}

const EventCard = ({
  id,
  title,
  image,
  date,
  location,
  price,
  category,
  attendees,
  isPrivate = false,
  className,
}: EventCardProps) => {
  const { t } = useTranslation();
  
  const formatPrice = (price: number) => {
    if (price === 0) return t("common.free");
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(price);
  };

  return (
    <Link to={isPrivate ? `/events/private/${id}` : `/events/${id}`}>
      <GlassCard hover className={cn("overflow-hidden group", className)}>
        {/* Image */}
        <div className="relative aspect-[16/10] overflow-hidden">
          <img
            src={image}
            alt={title}
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
          />
          
          {/* Category Badge */}
          <div className="absolute top-3 left-3">
            <span className="px-3 py-1 rounded-full text-xs font-medium bg-white/90 dark:bg-black/70 text-foreground backdrop-blur-sm">
              {category}
            </span>
          </div>

          {/* Private Badge */}
          {isPrivate && (
            <div className="absolute top-3 right-3">
              <span className="px-3 py-1 rounded-full text-xs font-medium bg-primary text-primary-foreground">
                🔒 {t("common.private")}
              </span>
            </div>
          )}

          {/* Price Badge */}
          <div className="absolute bottom-3 right-3">
            <span className={cn(
              "px-3 py-1.5 rounded-xl text-sm font-bold backdrop-blur-sm",
              price === 0 
                ? "bg-green-500/90 text-white" 
                : "bg-white/90 dark:bg-black/70 text-foreground"
            )}>
              {formatPrice(price)}
            </span>
          </div>
        </div>

        {/* Content */}
        <div className="p-4">
          <h3 className="font-semibold text-lg line-clamp-2 mb-3 group-hover:text-primary transition-colors">
            {title}
          </h3>

          <div className="space-y-2 text-sm text-muted-foreground">
            <div className="flex items-center gap-2">
              <Calendar className="w-4 h-4 text-primary" />
              <span>{date}</span>
            </div>
            <div className="flex items-center gap-2">
              <MapPin className="w-4 h-4 text-primary" />
              <span className="truncate">{location}</span>
            </div>
            {attendees && (
              <div className="flex items-center gap-2">
                <Users className="w-4 h-4 text-primary" />
                <span>{attendees.toLocaleString("vi-VN")} {t("common.peopleInterested")}</span>
              </div>
            )}
          </div>
        </div>
      </GlassCard>
    </Link>
  );
};

export { EventCard };
