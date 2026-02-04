import { Skeleton } from "@/components/ui/skeleton";
import { GlassCard } from "@/components/ui/glass-card";

export const CategoryCardSkeleton = () => {
  return (
    <GlassCard className="p-6 text-center">
      {/* Icon */}
      <Skeleton className="w-16 h-16 rounded-2xl mx-auto mb-4" />
      
      {/* Name */}
      <Skeleton className="h-5 w-24 mx-auto mb-2" />
      
      {/* Event count */}
      <Skeleton className="h-4 w-16 mx-auto" />
    </GlassCard>
  );
};

export const CategoryCardSkeletonGrid = ({ count = 6 }: { count?: number }) => {
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
      {Array.from({ length: count }).map((_, i) => (
        <CategoryCardSkeleton key={i} />
      ))}
    </div>
  );
};
