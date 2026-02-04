import { Skeleton } from "@/components/ui/skeleton";
import { GlassCard } from "@/components/ui/glass-card";

export const FeaturedEventSkeleton = () => {
  return (
    <GlassCard className="overflow-hidden">
      <div className="grid md:grid-cols-2 gap-0">
        {/* Image */}
        <Skeleton className="aspect-[16/10] md:aspect-auto md:h-full" />
        
        {/* Content */}
        <div className="p-6 md:p-8 space-y-4">
          {/* Badge */}
          <Skeleton className="h-6 w-24 rounded-full" />
          
          {/* Title */}
          <div className="space-y-2">
            <Skeleton className="h-8 w-full" />
            <Skeleton className="h-8 w-2/3" />
          </div>
          
          {/* Description */}
          <div className="space-y-2">
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-3/4" />
          </div>
          
          {/* Meta info */}
          <div className="space-y-3 pt-4">
            <div className="flex items-center gap-2">
              <Skeleton className="h-5 w-5 rounded" />
              <Skeleton className="h-5 w-40" />
            </div>
            <div className="flex items-center gap-2">
              <Skeleton className="h-5 w-5 rounded" />
              <Skeleton className="h-5 w-48" />
            </div>
          </div>
          
          {/* Price and button */}
          <div className="flex items-center justify-between pt-4">
            <div className="space-y-1">
              <Skeleton className="h-4 w-16" />
              <Skeleton className="h-7 w-28" />
            </div>
            <Skeleton className="h-11 w-32 rounded-full" />
          </div>
        </div>
      </div>
    </GlassCard>
  );
};
