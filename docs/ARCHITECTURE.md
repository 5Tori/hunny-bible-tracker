# Architecture

This document is the system map for Hunny Bible Tracker. It should let a new agent find the right files quickly before making changes.

## Runtime Shape

```text
Flutter mobile app
  -> Drift / SQLite local database
  -> Firebase Auth SDK
  -> optional authenticated Next.js API calls

Next.js web/API/admin app
  -> Firebase Admin SDK token verification
  -> Neon Postgres
  -> Cloudinary image upload for admin-managed media
```

The mobile app is offline-first. SQLite is the first write target for reading plans, chapter progress, reading activities, settings, and local Today’s Message flags.

The web/API app serves admin tools, public content APIs, Firebase-authenticated account APIs, reading backup/restore APIs, and shareable Today’s Message pages.

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
| `lib/core/auth/` | Firebase Auth config, auth repository, auth DTOs |
| `lib/core/api/` | API config and sync response models |
| `lib/features/root/root_shell.dart` | MVP bottom tab shell: Home, Read, Settings |
| `lib/features/home/` | Home tab, Today’s Message, current progress card |
| `lib/features/read/` | Read tab, repository, sync payloads, domain models, widgets |
| `lib/features/plans/` | Full-screen Plan Manager / Plan Library |
| `lib/features/settings/` | Account, backup/restore, plan entrypoint, feedback UI |
| `lib/features/find/` | Hidden Discover prototype retained for later |
| `lib/features/list/` | Hidden Saved/List prototype retained for later |
| `assets/data/bible_books.en.json` | Canonical book metadata seed |
| `assets/brand/google_g.svg` | Google sign-in mark used in auth sheet |

## Web/API Module Map

| Path | Role |
| --- | --- |
| `apps/web/src/app/page.tsx` | Basic web landing page |
| `apps/web/src/app/privacy/page.tsx` | Privacy page |
| `apps/web/src/app/terms/page.tsx` | Terms page |
| `apps/web/src/app/support/page.tsx` | Support page |
| `apps/web/src/app/admin` | Admin dashboard pages |
| `apps/web/src/app/today-message/[id]/page.tsx` | Public share page for Today’s Message |
| `apps/web/src/app/api/health/route.ts` | Health check |
| `apps/web/src/app/api/v1/auth/sync/route.ts` | Firebase token verify + Neon auth user upsert |
| `apps/web/src/app/api/v1/me/route.ts` | Firebase token verify + current user response |
| `apps/web/src/app/api/v1/plans` | Published plan catalog APIs |
| `apps/web/src/app/api/v1/sync/push/route.ts` | Authenticated reading-data backup |
| `apps/web/src/app/api/v1/sync/bootstrap/route.ts` | Authenticated reading-data restore/bootstrap |
| `apps/web/src/app/api/v1/today-message` | Public Today’s Message API and engagement routes |
| `apps/web/src/app/api/v1/feedback/route.ts` | Mobile Help & feedback submission |
| `apps/web/src/lib/auth/` | Firebase Admin token verification and auth user sync |
| `apps/web/src/lib/plans.ts` | Plan template CRUD and public serialization |
| `apps/web/src/lib/today-messages.ts` | Today’s Message CRUD, public lookup, engagement counters |
| `apps/web/src/lib/sync/reading-sync.ts` | Reading backup/restore server logic |
| `apps/web/src/lib/feedback.ts` | Feedback validation and insert logic |
| `apps/web/src/lib/db/neon.ts` | Neon serverless SQL client |
| `apps/web/db/schema.sql` | Active server DB schema source |

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
  -> Neon plan_templates / sections / items
  -> GET /api/v1/plans
  -> mobile caches template rows in Drift
  -> user starts a plan
  -> user_plan_chapters snapshot is created locally
```

Started plan runs are snapshots. Later template edits should not rewrite existing `user_plan_chapters`.

## Data Flow: Today’s Message

```text
Admin creates/publishes Today’s Message
  -> today_messages row in Neon
  -> GET /api/v1/today-message?date=YYYY-MM-DD&language=en
  -> Home card renders image, verse, version, actions, hint, Read More
  -> Read More modal can start/continue related plan
```

The public API returns the latest published message where `publish_date <= date`, so the mobile app can still show a message if today’s date does not have a dedicated row.

## Data Flow: Authentication and Backup

```text
Continue with Google
  -> Firebase Auth native sign-in
  -> local_users.auth_user_id = Firebase uid
  -> POST /api/v1/auth/sync
  -> Neon auth_users upsert
  -> optional POST /api/v1/sync/push
```

Manual restore:

```text
Settings -> Restore backup
  -> GET /api/v1/sync/bootstrap
  -> Drift insertOnConflictUpdate for backed-up reading rows
```

Firebase Auth owns identity. Neon stores application data and server-side user profile rows.

## Current Boundaries

- Mobile reads/writes progress locally first.
- Backup/restore exists, but automatic incremental pull/merge and conflict UI are not implemented.
- Mobile must not connect directly to Neon.
- Discover and Saved/List surfaces are hidden for MVP closed testing.

## Related Docs

- `docs/DATA_MODEL.md`
- `docs/AUTH_AND_API.md`
- `docs/SYNC_STRATEGY.md`
- `docs/PRODUCT_ROADMAP.md`
- `docs/ADMIN_DASHBOARD.md`
- `docs/DEVELOPMENT.md`
- `docs/to-do/MVP_CLOSE_TESTING_TODO.md`
