import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { GlassCard } from "@/components/ui/glass-card";
import { cn } from "@/lib/utils";
import { 
  Music, 
  Palette, 
  Trophy, 
  Utensils, 
  GraduationCap, 
  Heart, 
  Briefcase, 
  Sparkles 
} from "lucide-react";

interface CategoryCardProps {
  id: string;
  name: string;
  icon: string;
  count: number;
  color: string;
  className?: string;
}

const iconMap: Record<string, React.ComponentType<{ className?: string }>> = {
  music: Music,
  art: Palette,
  sports: Trophy,
  food: Utensils,
  education: GraduationCap,
  charity: Heart,
  business: Briefcase,
  entertainment: Sparkles,
};

const colorMap: Record<string, string> = {
  pink: "from-pink-400 to-pink-600",
  purple: "from-purple-400 to-purple-600",
  blue: "from-blue-400 to-blue-600",
  green: "from-green-400 to-green-600",
  orange: "from-orange-400 to-orange-600",
  red: "from-red-400 to-red-600",
  yellow: "from-yellow-400 to-yellow-600",
  teal: "from-teal-400 to-teal-600",
};

const CategoryCard = ({
  id,
  name,
  icon,
  count,
  color,
  className,
}: CategoryCardProps) => {
  const { t } = useTranslation();
  const IconComponent = iconMap[icon] || Sparkles;
  const gradientClass = colorMap[color] || "from-primary to-purple-600";

  return (
    <Link to={`/events?category=${id}`}>
      <GlassCard 
        hover 
        className={cn("p-6 text-center group", className)}
      >
        <div 
          className={cn(
            "w-16 h-16 rounded-2xl bg-gradient-to-br flex items-center justify-center mx-auto mb-4 shadow-lg transition-transform duration-300 group-hover:scale-110",
            gradientClass
          )}
        >
          <IconComponent className="w-8 h-8 text-white" />
        </div>
        <h3 className="font-semibold mb-1">{name}</h3>
        <p className="text-sm text-muted-foreground">{count} {t("common.eventsCount")}</p>
      </GlassCard>
    </Link>
  );
};

export { CategoryCard };
