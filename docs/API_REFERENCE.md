# API Reference (Current Implementation)

Base URL: http://localhost:8080/{contextPath}

## Public Web Endpoints

- GET /home
- GET /events
- GET /event/*, /event-detail
- GET /categories, /about, /faq, /terms
- GET/POST /login
- GET/POST /register
- GET /logout
- GET /auth/google, /auth/google/callback

## Customer Web Endpoints (requires login)

- GET/POST /checkout
- GET /tickets
- GET /order-confirmation
- GET /my-tickets
- GET/POST /profile
- GET/POST /change-password
- GET /resume-payment
- /support/*

## Organizer Web Endpoints

- /organizer, /organizer/dashboard
- /organizer/events, /organizer/events/*, /organizer/create-event
- /organizer/orders, /organizer/orders/*
- /organizer/statistics, /organizer/statistics/*
- /organizer/tickets
- /organizer/vouchers, /organizer/vouchers/*
- /organizer/team
- /organizer/check-in
- /organizer/support/*
- /organizer/settings
- /organizer/chat

## Admin Web Endpoints

- /admin, /admin/dashboard, /admin/dashboard/chart-data
- /admin/events, /admin/events/*
- /admin/event-approval
- /admin/orders, /admin/orders/*
- /admin/users, /admin/users/*
- /admin/categories, /admin/categories/*
- /admin/reports, /admin/reports/*
- /admin/settings
- /admin/support, /admin/support/*
- /admin/system-vouchers, /admin/system-vouchers/*
- /admin/chat-dashboard

## JSON API Endpoints

### Public / External

- POST /api/seepay/webhook

### Authenticated API

- GET /api/events
- GET /api/my-orders
- GET /api/my-tickets
- /api/chat/*
- /api/payment/status
- POST /api/voucher/validate
- POST /api/upload

### Organizer API

- /api/organizer/events

### Admin API

- /api/admin/events
- POST /api/admin/events/feature
- /api/admin/orders
- POST /api/admin/orders/confirm-payment
- /api/admin/users

## Notes

- Team roles are canonicalized to manager/staff/scanner.
- Legacy role values editor/checkin/viewer are still normalized in backend for compatibility.
- Payment flow is SeePay-first (QR + webhook), with non-SeePay methods handled as immediate paid in current implementation.

## Related Docs

- AUTH_FLOW.md
- PAYMENT_FLOW.md
- SECURITY_IMPLEMENTATION.md
- ENDPOINT_REFERENCE.md
