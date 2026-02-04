import { Skeleton } from "@/components/ui/skeleton";
import { GlassCard } from "@/components/ui/glass-card";

export const EventCardSkeleton = () => {
  return (
    <GlassCard className="overflow-hidden">
      {/* Image skeleton */}
      <Skeleton className="aspect-[16/10] w-full" />
      
      <div className="p-4 space-y-3">
        {/* Category badge */}
        <Skeleton className="h-5 w-20 rounded-full" />
        
        {/* Title */}
        <Skeleton className="h-6 w-full" />
        <Skeleton className="h-6 w-3/4" />
        
        {/* Date and location */}
        <div className="space-y-2 pt-2">
          <div className="flex items-center gap-2">
            <Skeleton className="h-4 w-4 rounded" />
            <Skeleton className="h-4 w-32" />
          </div>
          <div className="flex items-center gap-2">
            <Skeleton className="h-4 w-4 rounded" />
            <Skeleton className="h-4 w-40" />
          </div>
        </div>
        
        {/* Price */}
        <div className="flex items-center justify-between pt-2">
          <Skeleton className="h-5 w-24" />
          <Skeleton className="h-8 w-20 rounded-full" />
        </div>
      </div>
    </GlassCard>
  );
};

export const EventCardSkeletonGrid = ({ count = 6 }: { count?: number }) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {Array.from({ length: count }).map((_, i) => (
        <EventCardSkeleton key={i} />
      ))}
    </div>
  );
};
