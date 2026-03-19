# Endpoint Reference

This file is an inventory of servlet routes collected from `@WebServlet` annotations.

## Public and Shared Web

- `/home`
- `/events`
- `/event/*`, `/event-detail`
- `/categories`, `/about`, `/faq`, `/terms`
- `/login`, `/register`, `/logout`
- `/auth/google`, `/auth/google/callback`
- `/checkout`, `/tickets`, `/order-confirmation`
- `/profile`, `/change-password`, `/my-tickets`, `/resume-payment`
- `/support/*`
- `/media/upload`

## Organizer Web

- `/organizer`, `/organizer/dashboard`
- `/organizer/events`, `/organizer/events/*`, `/organizer/create-event`
- `/organizer/orders`, `/organizer/orders/*`
- `/organizer/statistics`, `/organizer/statistics/*`
- `/organizer/tickets`
- `/organizer/vouchers`, `/organizer/vouchers/*`
- `/organizer/team`
- `/organizer/check-in`
- `/organizer/support/*`
- `/organizer/settings`
- `/organizer/chat`

## Admin Web

- `/admin`, `/admin/dashboard`, `/admin/dashboard/chart-data`
- `/admin/events`, `/admin/events/*`
- `/admin/event-approval`
- `/admin/orders`, `/admin/orders/*`
- `/admin/users`, `/admin/users/*`
- `/admin/categories`, `/admin/categories/*`
- `/admin/reports`, `/admin/reports/*`
- `/admin/settings`
- `/admin/support`, `/admin/support/*`
- `/admin/system-vouchers`, `/admin/system-vouchers/*`
- `/admin/chat-dashboard`

## API Endpoints

### Public / External

- `POST /api/seepay/webhook`

### Authenticated User API

- `GET /api/events`
- `GET /api/my-orders`
- `GET /api/my-tickets`
- `/api/chat/*`
- `/api/payment/status`
- `POST /api/voucher/validate`
- `POST /api/upload`

### Organizer API

- `/api/organizer/events`

### Admin API

- `/api/admin/events`
- `POST /api/admin/events/feature`
- `/api/admin/orders`
- `POST /api/admin/orders/confirm-payment`
- `/api/admin/users`

## Filter Coverage

From `web.xml`:

- `AuthFilter` covers web protected routes and selected `/api/*` prefixes
- `CsrfFilter` covers web form routes plus `/api/*`
- `/api/seepay/webhook` is exempt in filter logic
