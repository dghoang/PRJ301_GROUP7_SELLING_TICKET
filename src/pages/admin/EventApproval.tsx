import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Search,
  Filter,
  Eye,
  CheckCircle,
  XCircle,
  Clock,
  Calendar,
  MapPin,
  Users,
  MessageSquare,
} from "lucide-react";
import { AdminLayout } from "@/components/admin";
import { GlassCard } from "@/components/ui/glass-card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Textarea } from "@/components/ui/textarea";
import { staggerContainer, staggerItem } from "@/lib/animations";

const mockEvents = [
  {
    id: 1,
    name: "Vietnam Music Festival 2025",
    organizer: "Live Nation VN",
    category: "Âm nhạc",
    date: "15/03/2025",
    location: "Hồ Chí Minh",
    ticketTypes: 5,
    expectedAttendees: 10000,
    status: "pending",
    submittedAt: "2 giờ trước",
    image: "/placeholder.svg",
  },
  {
    id: 2,
    name: "Tech Summit Vietnam",
    organizer: "TechVN Community",
    category: "Hội thảo",
    date: "20/03/2025",
    location: "Hà Nội",
    ticketTypes: 3,
    expectedAttendees: 500,
    status: "pending",
    submittedAt: "5 giờ trước",
    image: "/placeholder.svg",
  },
  {
    id: 3,
    name: "Art & Design Exhibition",
    organizer: "Gallery X",
    category: "Nghệ thuật",
    date: "25/03/2025",
    location: "Đà Nẵng",
    ticketTypes: 2,
    expectedAttendees: 300,
    status: "pending",
    submittedAt: "1 ngày trước",
    image: "/placeholder.svg",
  },
  {
    id: 4,
    name: "Marathon Hồ Chí Minh",
    organizer: "VN Running Club",
    category: "Thể thao",
    date: "10/04/2025",
    location: "Hồ Chí Minh",
    ticketTypes: 4,
    expectedAttendees: 5000,
    status: "approved",
    submittedAt: "3 ngày trước",
    image: "/placeholder.svg",
  },
  {
    id: 5,
    name: "Food Festival 2025",
    organizer: "VietFood",
    category: "Ẩm thực",
    date: "01/05/2025",
    location: "Hà Nội",
    ticketTypes: 2,
    expectedAttendees: 2000,
    status: "rejected",
    rejectionReason: "Thiếu giấy phép an toàn thực phẩm",
    submittedAt: "5 ngày trước",
    image: "/placeholder.svg",
  },
];

const transition = { duration: 0.4, ease: "easeOut" as const };

const EventApproval = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedEvent, setSelectedEvent] = useState<typeof mockEvents[0] | null>(null);
  const [showRejectDialog, setShowRejectDialog] = useState(false);
  const [rejectReason, setRejectReason] = useState("");

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "pending":
        return (
          <Badge className="bg-amber-100 text-amber-700">
            <Clock className="mr-1 h-3 w-3" />
            Chờ duyệt
          </Badge>
        );
      case "approved":
        return (
          <Badge className="bg-emerald-100 text-emerald-700">
            <CheckCircle className="mr-1 h-3 w-3" />
            Đã duyệt
          </Badge>
        );
      case "rejected":
        return (
          <Badge className="bg-red-100 text-red-700">
            <XCircle className="mr-1 h-3 w-3" />
            Từ chối
          </Badge>
        );
      default:
        return null;
    }
  };

  const filteredEvents = mockEvents.filter(
    (event) =>
      event.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      event.organizer.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const pendingEvents = filteredEvents.filter((e) => e.status === "pending");
  const approvedEvents = filteredEvents.filter((e) => e.status === "approved");
  const rejectedEvents = filteredEvents.filter((e) => e.status === "rejected");

  const handleApprove = (event: typeof mockEvents[0]) => {
    // In real app, call API
    console.log("Approved:", event.id);
  };

  const handleReject = () => {
    if (selectedEvent && rejectReason) {
      // In real app, call API
      console.log("Rejected:", selectedEvent.id, rejectReason);
      setShowRejectDialog(false);
      setRejectReason("");
      setSelectedEvent(null);
    }
  };

  const EventCard = ({ event }: { event: typeof mockEvents[0] }) => (
    <motion.div
      layout
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      whileHover={{ y: -4 }}
      transition={transition}
    >
      <GlassCard className="overflow-hidden">
        <div className="flex gap-4 p-4">
          <img
            src={event.image}
            alt={event.name}
            className="h-32 w-32 rounded-xl object-cover"
          />
          <div className="flex-1">
            <div className="flex items-start justify-between">
              <div>
                <h3 className="font-semibold">{event.name}</h3>
                <p className="text-sm text-muted-foreground">{event.organizer}</p>
              </div>
              {getStatusBadge(event.status)}
            </div>

            <div className="mt-3 flex flex-wrap gap-4 text-sm text-muted-foreground">
              <div className="flex items-center gap-1">
                <Calendar className="h-4 w-4" />
                {event.date}
              </div>
              <div className="flex items-center gap-1">
                <MapPin className="h-4 w-4" />
                {event.location}
              </div>
              <div className="flex items-center gap-1">
                <Users className="h-4 w-4" />
                {event.expectedAttendees.toLocaleString()} người
              </div>
            </div>

            <div className="mt-3 flex items-center gap-2">
              <Badge variant="outline">{event.category}</Badge>
              <Badge variant="outline">{event.ticketTypes} loại vé</Badge>
              <span className="ml-auto text-xs text-muted-foreground">
                Gửi {event.submittedAt}
              </span>
            </div>
          </div>
        </div>

        {event.status === "pending" && (
          <div className="flex gap-2 border-t border-border/50 bg-muted/30 p-3">
            <Button size="sm" variant="outline" className="flex-1">
              <Eye className="mr-2 h-4 w-4" />
              Xem chi tiết
            </Button>
            <Button
              size="sm"
              variant="outline"
              className="text-red-500 hover:bg-red-50"
              onClick={() => {
                setSelectedEvent(event);
                setShowRejectDialog(true);
              }}
            >
              <XCircle className="mr-2 h-4 w-4" />
              Từ chối
            </Button>
            <Button
              size="sm"
              className="bg-emerald-500 hover:bg-emerald-600"
              onClick={() => handleApprove(event)}
            >
              <CheckCircle className="mr-2 h-4 w-4" />
              Duyệt
            </Button>
          </div>
        )}

        {event.status === "rejected" && event.rejectionReason && (
          <div className="border-t border-border/50 bg-red-50 p-3">
            <div className="flex items-start gap-2 text-sm text-red-700">
              <MessageSquare className="mt-0.5 h-4 w-4" />
              <div>
                <p className="font-medium">Lý do từ chối:</p>
                <p>{event.rejectionReason}</p>
              </div>
            </div>
          </div>
        )}
      </GlassCard>
    </motion.div>
  );

  return (
    <AdminLayout title="Duyệt sự kiện" subtitle="Xem xét và phê duyệt sự kiện mới">
      <motion.div
        variants={staggerContainer}
        initial="initial"
        animate="animate"
        className="space-y-6"
      >
        {/* Search and Filters */}
        <motion.div variants={staggerItem}>
          <GlassCard className="p-4">
            <div className="flex flex-wrap gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Tìm kiếm sự kiện, ban tổ chức..."
                  className="pl-10"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              <Button variant="outline">
                <Filter className="mr-2 h-4 w-4" />
                Bộ lọc
              </Button>
            </div>
          </GlassCard>
        </motion.div>

        {/* Tabs */}
        <motion.div variants={staggerItem}>
          <Tabs defaultValue="pending" className="w-full">
            <TabsList className="glass mb-4 w-full justify-start">
              <TabsTrigger value="pending" className="gap-2">
                <Clock className="h-4 w-4" />
                Chờ duyệt
                <Badge className="ml-1 bg-amber-500">{pendingEvents.length}</Badge>
              </TabsTrigger>
              <TabsTrigger value="approved" className="gap-2">
                <CheckCircle className="h-4 w-4" />
                Đã duyệt
                <Badge className="ml-1 bg-emerald-500">{approvedEvents.length}</Badge>
              </TabsTrigger>
              <TabsTrigger value="rejected" className="gap-2">
                <XCircle className="h-4 w-4" />
                Từ chối
                <Badge className="ml-1 bg-red-500">{rejectedEvents.length}</Badge>
              </TabsTrigger>
            </TabsList>

            <TabsContent value="pending" className="space-y-4">
              <AnimatePresence mode="popLayout">
                {pendingEvents.map((event) => (
                  <EventCard key={event.id} event={event} />
                ))}
              </AnimatePresence>
              {pendingEvents.length === 0 && (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="py-12 text-center text-muted-foreground"
                >
                  <CheckCircle className="mx-auto h-12 w-12 text-emerald-500" />
                  <p className="mt-4">Không có sự kiện nào chờ duyệt!</p>
                </motion.div>
              )}
            </TabsContent>

            <TabsContent value="approved" className="space-y-4">
              <AnimatePresence mode="popLayout">
                {approvedEvents.map((event) => (
                  <EventCard key={event.id} event={event} />
                ))}
              </AnimatePresence>
            </TabsContent>

            <TabsContent value="rejected" className="space-y-4">
              <AnimatePresence mode="popLayout">
                {rejectedEvents.map((event) => (
                  <EventCard key={event.id} event={event} />
                ))}
              </AnimatePresence>
            </TabsContent>
          </Tabs>
        </motion.div>
      </motion.div>

      {/* Reject Dialog */}
      <Dialog open={showRejectDialog} onOpenChange={setShowRejectDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Từ chối sự kiện</DialogTitle>
          </DialogHeader>
          <div className="py-4">
            <p className="mb-4 text-sm text-muted-foreground">
              Sự kiện: <strong>{selectedEvent?.name}</strong>
            </p>
            <Textarea
              placeholder="Nhập lý do từ chối..."
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              rows={4}
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowRejectDialog(false)}>
              Hủy
            </Button>
            <Button
              className="bg-red-500 hover:bg-red-600"
              onClick={handleReject}
              disabled={!rejectReason}
            >
              Xác nhận từ chối
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </AdminLayout>
  );
};

export default EventApproval;
