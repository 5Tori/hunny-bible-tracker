# Hunny Bible Tracker

Offline-first Bible reading tracker built with Flutter, Drift/SQLite, Firebase Auth, Next.js API routes, and Neon Postgres.

The app does not store Bible text in v0.1. It stores book/chapter references, reading plans, chapter progress, activity logs, local settings, and account-link metadata.

## Current Status

The current product focus is the Read and Settings flow.

- Flutter mobile app for iOS and Android.
- Offline-first local database through Drift/SQLite.
- Firebase Auth for Google sign-in.
- Neon Postgres is kept for server-side app data.
- `apps/web` provides API routes for Firebase token verification, Neon `auth_users` upsert, and an admin dashboard for plan template management.
- Read tab supports plan templates, section-based plans, current/completed plan lists, catalog browsing, plan completion, and starting a completed plan again.
- Settings supports account sign-in/out, automatic timezone display, language placeholder, notifications placeholder, and Help & feedback UI.

Remote progress sync is not implemented yet. The local schema is sync-ready, but server sync tables/API routes still need to be designed and built.

## Monorepo Layout

```text
apps/
  mobile/   Flutter app
  web/      Next.js web/API app

docs/
  ARCHITECTURE.md     Runtime structure and module map
  DATA_MODEL.md       Local Drift schema, server schema status, plan lifecycle
  AUTH_AND_API.md     Firebase Auth, Google Sign-In, API routes, deployment checklist
  SYNC_STRATEGY.md    Future backup/sync design and conflict policy
  PRODUCT_ROADMAP.md  Product state, UX model, and next implementation priorities
  DEVELOPMENT.md      Local setup, run commands, builds, troubleshooting
```

## Start Here

For a new agent or developer:

1. Read this README.
2. Read `docs/ARCHITECTURE.md` for the system map.
3. Read `docs/DATA_MODEL.md` before changing Read, plan, progress, or sync logic.
4. Read `docs/AUTH_AND_API.md` before changing Firebase Auth, Google sign-in, or API routes.
5. Use `docs/DEVELOPMENT.md` for local run/build commands.

## Quick Setup

```bash
cd apps/mobile
flutter pub get
flutter pub run build_runner build
```

Create local dart-define files:

```bash
cd apps/mobile
cp .env.example.json .env.ios.json
cp .env.example.json .env.android.json
```

Fill both files with Firebase values. Use:

- iOS simulator API URL: `http://127.0.0.1:3000`
- Android emulator API URL: `http://10.0.2.2:3000`

Run mobile:

```bash
cd apps/mobile
./scripts/run_ios.sh
./scripts/run_android.sh
```

Run web/API:

```bash
pnpm web:dev
```

## Common Checks

```bash
cd apps/mobile
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

```bash
pnpm web:build
```

## Current Data Boundary

The mobile app writes locally first. It may call the API after Firebase login to upsert the server-side auth user, but chapter progress and reading activities are not synced remotely yet.

```text
User action
  -> Flutter UI
  -> Drift/SQLite transaction
  -> sync_status pending/local_only
  -> future sync worker/API
```

The mobile app must not connect directly to Neon. Server access should go through `apps/web` API routes.

## Important Implementation Notes

- Local DB schema source: `apps/mobile/lib/core/database/app_database.dart`
- Generated Drift file: `apps/mobile/lib/core/database/app_database.g.dart`
- Read repository: `apps/mobile/lib/features/read/data/read_repository.dart`
- Server schema file: `apps/web/db/schema.sql`
- API routes: `apps/web/src/app/api`
- Firebase define example: `apps/mobile/.env.example.json`

`apps/web/db/schema.sql` currently has only the active auth schema as the reliable server schema. Full remote sync tables are intentionally deferred until sync implementation.
