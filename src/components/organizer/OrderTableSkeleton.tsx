import { Skeleton } from "@/components/ui/skeleton";
import { GlassCard } from "@/components/ui/glass-card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export const OrderTableRowSkeleton = () => {
  return (
    <TableRow className="border-white/10">
      <TableCell>
        <Skeleton className="h-4 w-24" />
      </TableCell>
      <TableCell>
        <div className="flex items-center gap-3">
          <Skeleton className="w-8 h-8 rounded-full" />
          <div className="space-y-1">
            <Skeleton className="h-4 w-28" />
            <Skeleton className="h-3 w-36" />
          </div>
        </div>
      </TableCell>
      <TableCell>
        <Skeleton className="h-4 w-32" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-4 w-20" />
      </TableCell>
      <TableCell className="text-right">
        <Skeleton className="h-4 w-24 ml-auto" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-6 w-24 rounded-full" />
      </TableCell>
      <TableCell className="text-right">
        <Skeleton className="h-8 w-8 rounded ml-auto" />
      </TableCell>
    </TableRow>
  );
};

export const OrderTableSkeleton = ({ rows = 5 }: { rows?: number }) => {
  return (
    <GlassCard className="overflow-hidden">
      <Table>
        <TableHeader>
          <TableRow className="border-white/10 hover:bg-transparent">
            <TableHead>Mã đơn</TableHead>
            <TableHead>Khách hàng</TableHead>
            <TableHead>Sự kiện</TableHead>
            <TableHead>Số lượng</TableHead>
            <TableHead className="text-right">Tổng tiền</TableHead>
            <TableHead>Trạng thái</TableHead>
            <TableHead className="text-right">Chi tiết</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {Array.from({ length: rows }).map((_, i) => (
            <OrderTableRowSkeleton key={i} />
          ))}
        </TableBody>
      </Table>
    </GlassCard>
  );
};
