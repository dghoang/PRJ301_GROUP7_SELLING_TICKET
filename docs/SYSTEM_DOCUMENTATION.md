# System Documentation (Current Snapshot)

## High-Level Architecture

- Java Servlet + JSP monolith on Tomcat 10
- Layered structure: Controller -> Service -> DAO -> SQL Server
- Static/media upload handled with Cloudinary integration

## Security Architecture

- AuthFilter for authentication + route authorization
- CsrfFilter for POST protection on web and API routes
- Hybrid auth mode for APIs:
  - Bearer token accepted on /api/*
  - Session/cookie remains supported for existing JSP frontend
- Seepay webhook protected by API key and dedicated exemption path

## Core Domains

- Events and ticketing
- Order/payment lifecycle
- Organizer operations (events, tickets, team, statistics)
- Admin operations (moderation, user/order/report management)
- Support and chat

## Recent Hardening Updates (March 2026)

1. Organizer stats correctness
- Fixed ticket distribution and event stats joins to match current schema
- Fixed organizer order status counting to canonical lowercase statuses

2. Team role canonicalization
- Canonical roles: manager/staff/scanner
- Legacy role values editor/checkin/viewer normalized in backend
- Added migration for role backfill + constraint update

3. API auth/CSRF transition
- Bearer token support for API calls
- Invalid bearer token now falls back to session path (compatibility)
- API POST now enforces CSRF unless a valid bearer token is provided

4. Webhook idempotency
- Added persistent dedup store SeepayWebhookDedup
- Removed fragile clear-all behavior from in-memory dedup strategy

5. Concurrency safety
- ChatApiServlet moved away from mutable SimpleDateFormat to thread-safe formatter

## Database Additions

- SeepayWebhookDedup table + index
- EventStaff role constraints updated to manager/staff/scanner

## Canonical References

- API reference: API_REFERENCE.md
- Endpoint inventory: ENDPOINT_REFERENCE.md
- Auth details: AUTH_FLOW.md
- Security implementation: SECURITY_IMPLEMENTATION.md
- Payment details: PAYMENT_FLOW.md
