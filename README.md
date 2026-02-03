# 🎫 Ticketbox - Nền tảng bán vé sự kiện

## 📦 Cấu trúc thư mục

```
src/
├── components/           # React Components
│   ├── admin/           # Admin layout & sidebar
│   ├── events/          # Event cards, category cards
│   ├── layout/          # Header, Footer, MainLayout
│   ├── organizer/       # Organizer layout & sidebar
│   └── ui/              # Shadcn UI components
│
├── config/              # Cấu hình ứng dụng
│   ├── api.config.ts    # API endpoints & config
│   └── constants.ts     # Constants, enums, routes
│
├── contexts/            # React Context providers
│   ├── AuthContext.tsx  # Xác thực người dùng
│   ├── CartContext.tsx  # Giỏ hàng/vé
│   └── ThemeContext.tsx # Dark/Light mode
│
├── hooks/               # Custom React Hooks
│   ├── useEvents.ts     # Hooks cho events
│   ├── useOrders.ts     # Hooks cho orders
│   └── useOrganizer.ts  # Hooks cho BTC
│
├── lib/                 # Utilities
│   ├── animations.ts    # Framer Motion variants
│   ├── helpers.ts       # Helper functions
│   └── utils.ts         # Tailwind utils
│
├── pages/               # Trang (23 trang)
│   ├── admin/           # 5 trang Admin
│   ├── auth/            # Login, Register
│   ├── events/          # Event listing, detail, checkout
│   ├── organizer/       # 10 trang BTC
│   └── profile/         # Tài khoản cá nhân
│
├── schemas/             # Zod validation schemas
│   └── index.ts         # All form validations
│
├── services/            # API Services (cho Java backend)
│   ├── http.service.ts  # HTTP client với auth
│   ├── auth.service.ts  # Authentication APIs
│   ├── event.service.ts # Event APIs
│   ├── order.service.ts # Order APIs
│   ├── organizer.service.ts  # Organizer APIs
│   ├── admin.service.ts      # Admin APIs
│   └── common.service.ts     # Shipping, Upload, Payment
│
└── types/               # TypeScript types
    └── index.ts         # All type definitions
```

## 🔌 Tích hợp với Java Backend

### 1. Cấu hình API

Chỉnh sửa file `src/config/api.config.ts`:

```typescript
// Thay đổi URL này thành URL của Java backend
export const API_BASE_URL = "http://localhost:8080/api";
```

Hoặc sử dụng biến môi trường:
```env
VITE_API_BASE_URL=http://localhost:8080/api
```

### 2. API Endpoints

Tất cả endpoints được định nghĩa trong `src/config/api.config.ts`:

```typescript
// Auth
POST /api/v1/auth/login
POST /api/v1/auth/register
POST /api/v1/auth/logout
POST /api/v1/auth/refresh

// Events
GET  /api/v1/events
GET  /api/v1/events/:id
GET  /api/v1/events/featured
GET  /api/v1/categories

// Orders
POST /api/v1/orders
GET  /api/v1/orders/:id
GET  /api/v1/orders/my-orders

// Organizer
GET  /api/v1/organizer/dashboard
GET  /api/v1/organizer/events
POST /api/v1/organizer/events
...

// Admin
GET  /api/v1/admin/dashboard
POST /api/v1/admin/events/:id/approve
POST /api/v1/admin/events/:id/reject
...
```

### 3. Response Format

Backend cần trả về response theo format:

```typescript
// Success
{
  "success": true,
  "data": { ... }
}

// Error
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email không hợp lệ",
    "details": {
      "email": ["Email is invalid"]
    }
  }
}

// Paginated
{
  "success": true,
  "data": [...],
  "meta": {
    "currentPage": 1,
    "totalPages": 10,
    "totalItems": 100,
    "itemsPerPage": 10
  }
}
```

### 4. Authentication

- Sử dụng JWT Bearer token
- Access token lưu trong localStorage với key `ticketbox_access_token`
- Refresh token với key `ticketbox_refresh_token`
- HTTP client tự động gửi token trong header Authorization

## 🎨 Design System

- **Colors**: Gradient hồng pastel → tím lavender
- **Glass morphism**: iOS 26 style với backdrop blur
- **Animations**: Framer Motion
- **Font**: Inter / Plus Jakarta Sans

## 📱 Các trang đã hoàn thành

### Người mua (8 trang)
1. ✅ Trang chủ (`/`)
2. ✅ Đăng nhập (`/login`)
3. ✅ Đăng ký (`/register`)
4. ✅ Danh sách sự kiện (`/events`)
5. ✅ Chi tiết sự kiện (`/events/:id`)
6. ✅ Chọn vé (`/events/:id/tickets`)
7. ✅ Thanh toán (`/events/:id/checkout`)
8. ✅ Xác nhận đơn hàng (`/events/:id/confirmation`)
9. ✅ Tài khoản (`/profile`)

### Ban tổ chức (10 trang)
1. ✅ Dashboard (`/organizer`)
2. ✅ Tạo sự kiện (`/organizer/create-event`)
3. ✅ Quản lý sự kiện (`/organizer/events`)
4. ✅ Quản lý vé (`/organizer/tickets`)
5. ✅ Mã giảm giá (`/organizer/vouchers`)
6. ✅ Đơn hàng (`/organizer/orders`)
7. ✅ Thống kê (`/organizer/statistics`)
8. ✅ Điều hành viên (`/organizer/team`)
9. ✅ Soát vé (`/organizer/check-in`)
10. ✅ Cài đặt (`/organizer/settings`)

### Quản trị viên (5 trang)
1. ✅ Dashboard (`/admin`)
2. ✅ Duyệt sự kiện (`/admin/events`)
3. ✅ Quản lý người dùng (`/admin/users`)
4. ✅ Vận chuyển (`/admin/shipping`)
5. ✅ Báo cáo (`/admin/reports`)

## 🚀 Chạy dự án

```bash
# Install dependencies
npm install

# Development
npm run dev

# Build
npm run build
```

## 📋 Checklist tích hợp Java

- [ ] Cấu hình `VITE_API_BASE_URL` trong `.env`
- [ ] Implement các endpoints trong `api.config.ts`
- [ ] Trả về đúng format response
- [ ] Cấu hình CORS cho frontend domain
- [ ] Implement JWT authentication
- [ ] Implement file upload endpoint
- [ ] Implement payment callback

## 🛠 Technologies

- **Frontend**: React 18, TypeScript, Vite
- **Styling**: Tailwind CSS, Shadcn UI
- **Animation**: Framer Motion
- **State**: React Query, Context API
- **Form**: React Hook Form, Zod validation
- **Charts**: Recharts
