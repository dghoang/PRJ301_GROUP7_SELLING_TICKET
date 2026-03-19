# Security Implementation

## Request Protection Stack

1. SecurityHeadersFilter
2. CsrfFilter
3. AuthFilter

Filter mappings are defined in `SellingTicketJava/src/webapp/WEB-INF/web.xml`.

## Authentication

### Web frontend

- Primary auth: HTTP session (`user` / `account` attributes)
- JWT cookie path is used for session restoration when needed

### API clients

- `/api/*` supports `Authorization: Bearer <access-token>`
- Valid bearer token authenticates request directly
- Invalid bearer token falls back to session/cookie path in compatibility mode
- If no auth source succeeds, API returns 401 JSON

## Authorization

- `admin`: full admin and admin APIs
- `support_agent`: restricted to support/chat admin routes
- `organizer`: organizer routes + organizer APIs
- `customer`: customer routes and limited organizer onboarding routes

## CSRF Policy

CsrfFilter currently protects:

- `/login`, `/register`, `/checkout`, `/profile`, `/change-password`
- `/support/*`, `/media/upload`
- `/organizer/*`, `/admin/*`
- `/api/*`

POST decision rules:

1. `/api/seepay/webhook` is exempt (validated by API key)
2. API POST with valid bearer token: CSRF skipped
3. API POST without valid bearer token: must provide `X-CSRF-Token` (or fallback `csrf_token`)
4. Non-API web forms: must provide `csrf_token`

## Payment/Webhook Security

SePay webhook (`/api/seepay/webhook`) protections:

- Authorization header validation against configured SePay API key
- Request body size cap
- JSON shape validation
- Order code extraction and amount match verification
- Atomic order confirmation
- Replay protection via persistent dedup table `SeepayWebhookDedup`

## Data Consistency Hardening

- Canonical organizer team roles: `manager`, `staff`, `scanner`
- Legacy role values are normalized in backend for compatibility
- Migration: `SellingTicketJava/database/migrations/migration_event_staff_role_canonical.sql`

## Key Source Files

- `SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java`
- `SellingTicketJava/src/java/com/sellingticket/filter/CsrfFilter.java`
- `SellingTicketJava/src/java/com/sellingticket/controller/api/SeepayWebhookServlet.java`
- `SellingTicketJava/src/java/com/sellingticket/dao/SeepayWebhookDedupDAO.java`
- `SellingTicketJava/src/java/com/sellingticket/service/AuthTokenService.java`
- `SellingTicketJava/src/webapp/WEB-INF/web.xml`
