# Hunny Bible Tracker Web/API

`apps/web` is the Next.js app that serves the Hunny Bible Tracker public web pages, admin dashboard, and mobile-facing API.

The mobile app must never connect directly to Neon. It talks to this app for published catalog data, auth user sync, reading-progress sync, today's message, and feedback submission.

## Stack

- Next.js 15 App Router
- React 19
- TypeScript
- Neon Postgres via `@neondatabase/serverless`
- Firebase Admin SDK for server-side Firebase ID token verification
- Firebase Web SDK for the browser admin Google login
- Cloudinary for admin-uploaded plan covers and today-message images
- Vercel Analytics on the public layout

## App Structure

```text
apps/web
+-- db
|   +-- schema.sql                 # Full current Neon schema
|   +-- migrations/                # Empty during MVP schema-history reset
+-- docs
|   +-- ADMIN_DASHBOARD.md         # Admin-specific operator notes
+-- src
|   +-- app
|   |   +-- layout.tsx             # Root: <html>, globals.css, metadata
|   |   +-- (public)/              # Route group: public marketing + share pages (URLs unchanged)
|   |   |   +-- layout.tsx         # Site header/footer (not used by /admin)
|   |   |   +-- page.tsx           # /
|   |   |   +-- privacy|terms|support
|   |   |   +-- today-message/[slug]
|   |   +-- admin/                 # Admin dashboard (AdminChrome in admin/layout.tsx)
|   |   +-- api/                   # API route handlers (no shared page layout)
|   +-- components/admin           # Admin dashboard client/server components
|   +-- lib                        # Data access, auth, Cloudinary, validation, sync logic
+-- next.config.mjs                # Monorepo output tracing root
+-- package.json
+-- tsconfig.json
+-- vercel.json
```

Use `src/app/**/page.tsx` for UI routes and `src/app/api/**/route.ts` for API endpoints. Shared behavior belongs in `src/lib`; route handlers should stay thin.

## Key Modules

- `src/lib/db/neon.ts`: creates the Neon SQL client from `DATABASE_URL`.
- `src/lib/auth/verify-firebase-token.ts`: verifies Firebase bearer tokens using service-account env vars or application default credentials.
- `src/lib/auth/auth-user-sync.ts`: upserts Firebase identities into `auth_users`.
- `src/lib/admin/auth.ts`: parses bearer tokens and allows only emails listed in `ADMIN_EMAILS`.
- `src/lib/admin/client.ts`: stores/reads the browser admin ID token for admin fetch calls.
- `src/lib/plans.ts`: plan catalog validation, CRUD, publishing, archiving, public plan reads, and sort parsing.
- `src/lib/today-messages.ts`: today-message validation, CRUD, public lookup, public share lookup, heart/share counters.
- `src/lib/sync/reading-sync.ts`: compact mobile reading backup push/bootstrap persistence.
- `src/lib/feedback.ts`: mobile feedback validation and persistence.
- `src/lib/cloudinary.ts`: signed Cloudinary uploads plus `media_assets` recording.
- `src/lib/bible-books.ts`: canonical Bible book keys and chapter counts used by admin editors.
- `src/lib/plan-taxonomy.ts`: accepted plan type, testament scope, and difficulty values.

## Public Pages

```text
GET /                    # Landing page
GET /privacy
GET /terms
GET /support
GET /today-message/[slug]  # Public share page for a published today message, e.g. /today-message/2026-05-15
```

The root layout lives in `src/app/layout.tsx` (document shell only). Public chrome (header/footer) lives in `src/app/(public)/layout.tsx`; global styles are in `src/app/globals.css`.

## Admin UI

```text
GET /admin/login
GET /admin/plans
GET /admin/plans/new
GET /admin/plans/[id]
GET /admin/today-messages
GET /admin/today-messages/new
GET /admin/today-messages/[id]
```

Admin users sign in with Firebase Google Auth in the browser. Access to admin APIs is allowed only when the Firebase user's email is included in the comma-separated `ADMIN_EMAILS` env var.

`src/components/admin/AdminChrome.tsx` provides the admin shell and keeps the Firebase ID token available to admin client code. `/admin/login` is intentionally rendered outside that shell.

## API Routes

### Health

```text
GET /api/health
```

Returns a lightweight health response.

### Auth/User

All routes below require `Authorization: Bearer <Firebase ID token>`.

```text
POST /api/v1/auth/sync  # Verify token and upsert auth_users
GET  /api/v1/me         # Verify token, upsert auth_users, return basic token identity
```

### Published Plans

```text
GET /api/v1/plans
GET /api/v1/plans/[identifier]
```

Only published, non-archived plans are returned. `identifier` can resolve a public plan by the logic in `getPublishedPlanByIdentifier`.

`GET /api/v1/plans` accepts a `sort` query parsed by `parsePublishedPlanSort` in `src/lib/plans.ts`.

### Reading Sync

Both routes require `Authorization: Bearer <Firebase ID token>`.

```text
GET  /api/v1/sync/bootstrap
POST /api/v1/sync/push
```

`bootstrap` returns the latest compact reading backup payload for the authenticated Firebase user, or `payload: null` when no backup exists.

`push` accepts one compact backup snapshot. The server validates it, computes a stable payload hash, and upserts one `user_reading_backups` row for the authenticated user. See `src/lib/sync/reading-sync.ts` for the exact JSON shape.

### Today Message

```text
GET  /api/v1/today-message?date=YYYY-MM-DD&language=en
POST /api/v1/today-message/[id]/heart
POST /api/v1/today-message/[id]/share
```

The public lookup returns the latest published message for the requested language on or before the requested date. When `date` is omitted, the server uses today's UTC date. The response includes `share_url`, built from `NEXT_PUBLIC_SITE_URL` when present and otherwise from the request origin, using `/today-message/YYYY-MM-DD`.

Heart/share endpoints increment counters and return the updated counts.

### Feedback

```text
POST /api/v1/feedback
```

Stores a mobile feedback message in `feedback_messages`. Valid categories are `bug`, `idea`, and `other`; message length is constrained by the DB and validation layer.

### Admin APIs

All admin routes require `Authorization: Bearer <Firebase ID token>` and an email in `ADMIN_EMAILS`.

```text
GET    /api/v1/admin/verify

GET    /api/v1/admin/plans
POST   /api/v1/admin/plans
GET    /api/v1/admin/plans/[id]
PUT    /api/v1/admin/plans/[id]
PATCH  /api/v1/admin/plans/[id]      # partial status/archive-style updates
DELETE /api/v1/admin/plans/[id]
POST   /api/v1/admin/plans/upload

GET    /api/v1/admin/today-messages
POST   /api/v1/admin/today-messages
GET    /api/v1/admin/today-messages/[id]
PUT    /api/v1/admin/today-messages/[id]
DELETE /api/v1/admin/today-messages/[id]
POST   /api/v1/admin/today-messages/upload
```

Plan and today-message uploads go to Cloudinary and record metadata in `media_assets`.

## Data Model

The full schema is `db/schema.sql`. Apply it to Neon before running the app against a fresh database.

Important table groups:

```text
auth_users

plan_templates
  -> plan_template_sections
      -> plan_template_items
  -> plan_template_tags
      -> plan_tags

user_reading_plans
user_plan_chapters
chapter_progress_entries
reading_activities
plan_completion_events
sync_states

today_messages
feedback_messages
media_assets
```

Plan catalog notes:

- `plan_templates.template_key` is unique and generated from the title plus a short random suffix on create.
- Archived plans are forced unpublished by normalization.
- Public plan reads should use the exported functions in `src/lib/plans.ts` rather than querying tables directly.

Today-message notes:

- `today_messages` has a unique `(publish_date, language)` slot.
- A message can optionally reference a primary related plan through `primary_related_plan_template_id`.
- `share_image_url` is generated from the uploaded Cloudinary image plus verse text/reference as a 4:5 (1080 x 1350) share card.
- Published public reads should use `src/lib/today-messages.ts`.

Reading-sync notes:

- Firebase Auth owns identity; `auth_users` is the server's local user record.
- Mobile rows are deduped by `(auth_user_id, client_id)`.
- Several tables also enforce natural uniqueness, for example chapter progress by user/plan/book/chapter.

## Environment

Create local env from the example:

```bash
cp apps/web/.env.example apps/web/.env.local
```

Required server env:

```text
DATABASE_URL
FIREBASE_PROJECT_ID
FIREBASE_CLIENT_EMAIL
FIREBASE_PRIVATE_KEY
ADMIN_EMAILS
CLOUDINARY_CLOUD_NAME
CLOUDINARY_API_KEY
CLOUDINARY_API_SECRET
```

Required browser env for `/admin/login`:

```text
NEXT_PUBLIC_FIREBASE_API_KEY
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN
NEXT_PUBLIC_FIREBASE_PROJECT_ID
NEXT_PUBLIC_FIREBASE_APP_ID
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID
```

Optional:

```text
NEXT_PUBLIC_SITE_URL  # canonical origin used for today-message share URLs
```

For `FIREBASE_PRIVATE_KEY`, paste the key with escaped newlines in local and Vercel env vars.

## Commands

From the repo root:

```bash
pnpm install
pnpm web:dev
pnpm web:build
```

From `apps/web`:

```bash
pnpm dev
pnpm typecheck
pnpm build
```

`package.json` also contains `lint`, but this app currently does not include an ESLint config in `apps/web`.

## Development Boundaries

- Keep mobile-facing behavior behind API routes; do not expose Neon credentials or direct DB access to mobile.
- Keep route handlers small. Put validation, SQL, and normalization in `src/lib`.
- Use Firebase bearer tokens for authenticated mobile APIs and admin APIs.
- Use `requireAdminUser` only for admin-only endpoints.
- Use `db/schema.sql` as the source of truth for database setup during MVP development.
- When changing API response shapes, check the mobile client expectations before merging.
- When changing admin forms, update both the API validation in `src/lib/*` and the editor component in `src/components/admin/*`.
- When adding image upload flows, record provider metadata in `media_assets`.

## Manual Smoke Test

1. Fill `apps/web/.env.local`.
2. Apply `apps/web/db/schema.sql` to Neon if the database is new.
3. Run `pnpm web:dev` from the repo root.
4. Open `/admin/login` and sign in with an email in `ADMIN_EMAILS`.
5. Create or edit a plan, add at least one section and chapter range, upload a cover, publish it.
6. Confirm `GET /api/v1/plans` returns the published plan.
7. Create or edit a today message, publish it, and confirm `GET /api/v1/today-message` returns it.
8. Run `pnpm --dir apps/web typecheck` before handing off code changes.
