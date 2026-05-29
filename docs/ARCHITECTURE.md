# Architecture

This document is the system map for Hunny Bible Tracker. It should let a new agent find the right files quickly before making changes.

## Runtime Shape

```text
Flutter mobile app
  -> Drift / SQLite local database
  -> Supabase Auth (supabase_flutter)
  -> optional authenticated Next.js API calls

Next.js web/API/admin app
  -> Supabase JWT verification (service role)
  -> Supabase Postgres
  -> Cloudinary image upload for admin-managed media
```

The mobile app is offline-first. SQLite is the first write target for reading plans, chapter progress, reading activities, settings, and local Today’s Message flags. Home and Read should render from local state first. API calls use short timeouts and cached reachability so offline startup does not wait on repeated network failures.

The web/API app serves admin tools, public content APIs, Supabase-authenticated account APIs, reading backup/restore APIs, and shareable Today’s Message pages.

## Applications

| Path | Role |
| --- | --- |
| `apps/mobile` | Flutter iOS/Android app |
| `apps/web` | Next.js web pages, API routes, and admin dashboard |

## Mobile Module Map

| Path | Role |
| --- | --- |
| `lib/main.dart` | App entrypoint |
| `lib/app/app.dart` | Top-level app composition |
| `lib/core/database/app_database.dart` | Drift schema source |
| `lib/core/database/app_database.g.dart` | Generated Drift code |
| `lib/core/auth/` | Supabase Auth config, auth repository, auth DTOs |
| `lib/core/api/` | API config, shared Dio timeout/reachability client, and sync response models |
| `lib/features/root/root_shell.dart` | Bottom tab shell: Home, Discover, Read, Settings |
| `lib/features/content/` | Content API client and shared content DTOs |
| `lib/features/home/` | Home tab, Today’s Message, current progress card |
| `lib/features/find/` | Discover tab backed by the public content API |
| `lib/features/read/` | Read tab, repository, sync payloads, domain models, widgets |
| `lib/features/plans/` | Full-screen Plan Manager / Plan Library |
| `lib/features/settings/` | Account, backup/restore, plan entrypoint, feedback UI |
| `lib/features/list/` | Hidden Saved/List prototype retained for later |
| `assets/data/bible_books.en.json` | Canonical book metadata seed |
| `assets/brand/google_g.svg` | Google sign-in mark used in auth sheet |
| `assets/image/honeycomb.jpg` | Today’s Message offline fallback image |
| `assets/image/logo-and-name.jpg` | Source image for native launch screen assets |
| `assets/icon/app-icon.jpg` | Source image for generated launcher icons |

## Web/API Module Map

| Path | Role |
| --- | --- |
| `apps/web/src/app/(public)/page.tsx` | Public landing page (marketing sections in `components/home/`) |
| `apps/web/src/app/(public)/privacy/page.tsx` | Privacy page |
| `apps/web/src/app/(public)/terms/page.tsx` | Terms page |
| `apps/web/src/app/(public)/support/page.tsx` | Support page |
| `apps/web/src/app/(browse)/today/page.tsx` | Redirect to latest published Today’s Message (`/today-message/YYYY-MM-DD`) |
| `apps/web/src/app/(browse)/today-message/[slug]/page.tsx` | Today’s Message browse page (date or id slug) |
| `apps/web/src/app/(browse)/discover/page.tsx` | Discover content grid (`?type=` filter) |
| `apps/web/src/app/(browse)/content/[slug]/page.tsx` | Single published content item |
| `apps/web/src/app/(browse)/layout.tsx` | Browse shell (shared header, app promo, footer) |
| `apps/web/src/app/admin` | Admin dashboard pages |
| `apps/web/src/components/marketing/ui/` | Marketing layout primitives (container, section, button, prose) |
| `apps/web/src/components/browse/` | Browse UI (`TodayMessageView`, `ContentCard`, `ContentDetail`, filters) |
| `apps/web/src/styles/marketing.css` | Minimal marketing design tokens (`.mkt-*`) |
| `apps/web/src/components/public/SiteShell.tsx` | Public web header/footer and shared chrome |
| `apps/web/postcss.config.mjs` | Tailwind v4 PostCSS setup |
| `apps/web/src/app/api/health/route.ts` | Health check |
| `apps/web/src/app/api/v1/auth/sync/route.ts` | Supabase token verify + profiles upsert |
| `apps/web/src/app/api/v1/me/route.ts` | Supabase token verify + current user response |
| `apps/web/src/app/api/v1/plans` | Published plan catalog APIs |
| `apps/web/src/app/api/v1/content` | Published content catalog APIs |
| `apps/web/src/app/api/v1/admin/content` | Admin content CRUD and content upload APIs |
| `apps/web/src/app/api/v1/sync/push/route.ts` | Authenticated reading backup push |
| `apps/web/src/app/api/v1/sync/bootstrap/route.ts` | Authenticated reading backup restore/bootstrap |
| `apps/web/src/app/api/v1/today-message` | Public Today’s Message API and engagement routes |
| `apps/web/src/app/api/v1/feedback/route.ts` | Mobile Help & feedback submission |
| `apps/web/src/lib/auth/` | Supabase token verification and profile sync |
| `apps/web/src/lib/plans.ts` | Plan template CRUD and public serialization |
| `apps/web/src/lib/content.ts` | General content CRUD, public lookup, authors, tags, assets, related plans |
| `apps/web/src/lib/today-messages.ts` | Today’s Message CRUD, public lookup, engagement counters |
| `apps/web/src/lib/sync/reading-sync.ts` | Reading backup/restore server logic |
| `apps/web/src/lib/feedback.ts` | Feedback validation and insert logic |
| `apps/web/src/lib/db/postgres.ts` | Supabase Postgres SQL client |
| `supabase/migrations/` | Active server DB migration source |
| `apps/web/db/schema.sql` | Reference schema mirror |

## Data Flow: Reading Progress

```text
Tap chapter
  -> ReadScreen
  -> ReadRepository.toggleChapter()
  -> Drift transaction
  -> chapter_progress_entries updated
  -> reading_activities insert-or-ignore for completion activity
  -> affected rows marked pending
  -> UI reloads section/book/chapter progress
```

When a plan reaches 100%, `ReadRepository` marks the plan `completion_ready`. The UI asks the user to finish the plan. On confirmation:

```text
finishPlan()
  -> plan_completion_events insert once per user_plan_id
  -> user_reading_plans.status = completed
  -> user_reading_plans.is_active = false
```

Completed plans appear in Plans > My Plans > Completed. Starting again creates a new user plan run.

Current plans can be archived from Plans. Archive preserves progress and activity rows, moves the run out of Current, and allows Restore later.

## Data Flow: Plan Catalog

```text
Admin edits/publishes plan
  -> Supabase plan_templates / sections / items
  -> GET /api/v1/plans
  -> mobile caches template rows in Drift
  -> user starts a plan
  -> user_plan_chapters snapshot is created locally
```

Started plan runs create local derived `user_plan_chapters` rows for offline UI and progress denominators. Compact server backup keeps these rows out of Supabase and regenerates them from plan templates on restore.

## Data Flow: Today’s Message

```text
Admin creates/publishes Today’s Message
  -> today_messages row in Supabase
  -> GET /api/v1/today-message?date=YYYY-MM-DD&language=en
  -> Home card renders image, verse, version, actions, hint, Read More
  -> Read More modal can start/continue related plan
```

The public API returns the latest published message where `publish_date <= date`, so the mobile app can still show a message if today’s date does not have a dedicated row.

On mobile, Home first checks today’s local cache, then the last cached Today’s Message, then a built-in offline fallback using Proverbs 16:24 and `assets/image/honeycomb.jpg`. A remote refresh runs after local UI has rendered.

## Data Flow: General Content / Discover

```text
Admin creates/publishes content
  -> Supabase contents / content_sections / content_assets / content_tags / content_plan_links
  -> GET /api/v1/content?sort=featured&language=en
  -> mobile Discover loads content through ContentApiClient
  -> user searches, filters by type/tag, and opens a content detail sheet
```

Discover is a finder/list surface. It does not write content locally yet. Home featured content and Saved/List are separate follow-up surfaces.

Discover is online-only for now. If the API is not reachable, the mobile tab shows an offline state instead of waiting through long retries.

## Data Flow: Authentication and Backup

```text
Continue with Google
  -> Supabase Auth (Google ID token)
  -> local_users.auth_user_id = Supabase user UUID
  -> POST /api/v1/auth/sync
  -> public.profiles upsert
  -> optional POST /api/v1/sync/push
```

Manual restore:

```text
Settings -> Restore backup
  -> GET /api/v1/sync/bootstrap
  -> compact backup payload returned
  -> Drift restores plan rows
  -> user_plan_chapters regenerated locally from plan templates
  -> progress, activities, completion events, and settings restored
```

Supabase Auth owns identity. Supabase Postgres stores application data; `public.profiles` mirrors auth users for app FKs.

## Current Boundaries

- Mobile reads/writes progress locally first.
- Backup/restore is for account recovery, not live collaborative sync.
- Automatic incremental pull/merge and conflict UI are not implemented.
- Mobile must not connect directly to Supabase Postgres.
- Discover is enabled as a public-content finder/list.
- Saved/List remains hidden for MVP closed testing.

## Related Docs

- `docs/DATA_MODEL.md`
- `docs/AUTH_AND_API.md`
- `docs/SYNC_STRATEGY.md`
- `docs/PRODUCT_ROADMAP.md`
- `docs/ADMIN_DASHBOARD.md`
- `docs/DEVELOPMENT.md`
- `docs/to-do/MVP_CLOSE_TESTING_TODO.md`
