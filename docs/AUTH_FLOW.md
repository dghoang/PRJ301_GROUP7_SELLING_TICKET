# Auth Flow (Current)

## Authentication Sources

1. Session user (primary for JSP/web pages)
2. Compact refresh cookie `st_refresh` for web session restoration
3. Bearer token for `/api/*` (preferred for external API clients)
4. Legacy `st_access` JWT cookie is still read for compatibility and deleted when encountered

## Runtime Order

- AuthFilter checks session first.
- For `/api/*` requests with `Authorization: Bearer <token>`:
  - valid token: request is authenticated from bearer token
  - invalid token: fallback to session/cookie flow in compatibility mode
- For web requests without session:
  - legacy `st_access` is accepted temporarily if still present
  - otherwise `st_refresh` is resolved against `UserSessions` and the session is rebuilt
- During successful auth/session restore, legacy access-cookie copies are deleted to keep request headers small.
- If no auth source succeeds:
  - `/api/*` returns 401 JSON
  - web routes redirect to `/login` with `returnUrl`

## Login And Restore Model

- Login and Google OAuth create a normal servlet session immediately.
- The backend also stores one opaque refresh token ID in `UserSessions` and sends only `st_refresh` as the persistent auth cookie for web flows.
- When Tomcat session state expires, `st_refresh` is used to restore the session without re-login.
- The server still understands old JWT refresh cookies during migration, then continues with the compact token model.

## Why The Cookie Model Changed

- Older web flows could send `JSESSIONID` + `st_access` + `st_refresh` on every request.
- The new flow keeps only `JSESSIONID` and one short `st_refresh` cookie for normal web traffic.
- This reduces request-header size and avoids local Tomcat 400 errors caused by large cookie headers.

## Authorization Rules

- admin: full /admin/* and protected APIs
- support_agent: limited admin support/chat routes
- organizer: organizer area and organizer APIs
- customer: customer routes, plus allowed organizer onboarding routes

## CSRF Rules

CsrfFilter applies to:
- login/register/checkout/profile/change-password
- support/*, media/upload
- organizer/*, admin/*
- api/*

Policy for POST:
- /api/seepay/webhook: exempt (API key protected)
- API request with valid Bearer token: CSRF skipped
- API request without valid Bearer: must provide X-CSRF-Token (or csrf_token fallback)
- Web form POST: must provide csrf_token

## Important Transition Note

Current deployment mode is hybrid:
- Web frontend: session + CSRF remains supported
- Web session restore: compact refresh cookie backed by DB
- External API clients: Bearer token supported

This avoids breaking existing JSP flows while enabling token-based API access.

## Dev Tomcat Note

- For local Tomcat environments that still need a larger request-header budget, see `SellingTicketJava/conf/tomcat-connector.dev-example.xml`.

## Related Files

- SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java
- SellingTicketJava/src/java/com/sellingticket/filter/CsrfFilter.java
- SellingTicketJava/src/java/com/sellingticket/service/AuthTokenService.java
- SellingTicketJava/src/java/com/sellingticket/dao/RefreshTokenDAO.java
- SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java
- SellingTicketJava/src/java/com/sellingticket/util/ServletUtil.java
- SellingTicketJava/src/webapp/WEB-INF/web.xml
