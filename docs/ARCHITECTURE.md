# Architecture

This document is the system map for Hunny Bible Tracker. It should let a new agent find the right files quickly before making changes.

## Runtime Shape

```text
Flutter mobile app
  -> Drift / SQLite local database
  -> Firebase Auth SDK
  -> optional Next.js API calls

Next.js web/API app
  -> Firebase Admin SDK token verification
  -> Neon Postgres
```

The mobile app is usable offline. SQLite is the first write target for reading plans, chapter progress, reading activities, and settings.

The web/API app currently handles authentication support only. Reading progress sync is planned but not implemented.

## Applications

| Path | Role |
| --- | --- |
| `apps/mobile` | Flutter iOS/Android app |
| `apps/web` | Next.js web pages and API routes |

## Mobile Module Map

| Path | Role |
| --- | --- |
| `lib/main.dart` | App entrypoint |
| `lib/app/app.dart` | Top-level app composition |
| `lib/core/database/app_database.dart` | Drift schema source |
| `lib/core/database/app_database.g.dart` | Generated Drift code |
| `lib/core/database/connection/` | Native/web database connection adapters |
| `lib/core/auth/` | Firebase Auth config, auth repository, auth DTOs |
| `lib/core/api/` | Optional API client config/models |
| `lib/features/root/root_shell.dart` | Bottom tab shell |
| `lib/features/home/` | Home tab |
| `lib/features/find/` | Discover/Find tab mock catalog and filters |
| `lib/features/read/` | Reading plan UI, repository, domain models, widgets |
| `lib/features/list/` | Placeholder List tab |
| `lib/features/settings/` | Account/settings/help feedback UI |
| `assets/data/bible_books.en.json` | Canonical book metadata seed |
| `assets/brand/google_g.svg` | Google sign-in mark used in auth sheet |

## Web/API Module Map

| Path | Role |
| --- | --- |
| `apps/web/src/app/page.tsx` | Basic web landing page |
| `apps/web/src/app/privacy/page.tsx` | Privacy page |
| `apps/web/src/app/terms/page.tsx` | Terms page |
| `apps/web/src/app/support/page.tsx` | Support page |
| `apps/web/src/app/api/health/route.ts` | Health check |
| `apps/web/src/app/api/v1/auth/sync/route.ts` | Firebase token verify + Neon auth user upsert |
| `apps/web/src/app/api/v1/me/route.ts` | Firebase token verify + current user response |
| `apps/web/src/lib/auth/verify-firebase-token.ts` | Firebase Admin token verification |
| `apps/web/src/lib/auth/auth-user-sync.ts` | Neon `auth_users` upsert |
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
  -> UI reloads section/book/chapter progress
```

When a plan reaches 100%, `ReadRepository` marks the plan `completion_ready`. The UI asks the user to finish the plan. On confirmation:

```text
finishPlan()
  -> plan_completion_events insert once per user_plan_id
  -> user_reading_plans.status = completed
  -> user_reading_plans.is_active = false
```

Completed plans appear in the My Plans `Completed` tab. Browse Plans can start the same template again, creating a new user plan run.

## Data Flow: Authentication

```text
Continue with Google
  -> Firebase Auth native sign-in
  -> local_users.auth_user_id = Firebase uid
  -> optional POST /api/v1/auth/sync
  -> Neon auth_users upsert
```

Firebase Auth owns identity. Neon stores application data and server-side user profile rows.

## Current Boundaries

- Mobile reads/writes progress locally.
- API routes do not yet sync reading plans, chapters, progress, activities, or completion events.
- `apps/web/db/schema.sql` is active only for auth support today.
- Any future sync work must go through API routes, not direct mobile-to-Neon access.

## Related Docs

- `docs/DATA_MODEL.md`
- `docs/AUTH_AND_API.md`
- `docs/SYNC_STRATEGY.md`
- `docs/PRODUCT_ROADMAP.md`
- `docs/DEVELOPMENT.md`
