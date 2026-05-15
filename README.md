# Hunny Bible Tracker

Offline-first Bible reading tracker built with Flutter, Drift/SQLite, Firebase Auth, Next.js API routes, and Neon Postgres.

The app does not store full Bible text in v0.1. It stores book/chapter references, reading plans, chapter progress, reading activities, local settings, Today’s Message content metadata, and account-link metadata.

## Current Status

The current MVP focus is closed-test readiness for Home, Read, Plans, and Settings.

- Flutter mobile app for iOS and Android.
- Bottom tabs for `Home`, `Read`, and `Settings`; unfinished Discover/Saved surfaces are hidden for MVP.
- Offline-first local database through Drift/SQLite.
- Firebase Auth for Google sign-in.
- Neon Postgres is the server-side app database behind `apps/web` API routes.
- Read supports section-based plan runs, chapter progress, completion, completed history, Start Again, and plan archive/restore.
- Plans is a full-screen Plan Manager / Plan Library with `My Plans`, `Catalog`, `Archived`, and catalog CTA states.
- Home supports Today’s Message cards, quick reflection, Read More article modal, related plan CTA, local save, heart/share counters, and current reading progress.
- Settings supports account sign-in/out, manual backup, restore/bootstrap, sync status, Manage reading plans, and Help & feedback submission.
- Admin dashboard supports plan templates and Today’s Message management.

Remote reading-data backup and restore are implemented through `POST /api/v1/sync/push` and `GET /api/v1/sync/bootstrap`. Full automatic multi-device incremental merge is still deferred.

## Monorepo Layout

```text
apps/
  mobile/   Flutter app
  web/      Next.js web/API/admin app

docs/
  ARCHITECTURE.md          Runtime structure and module map
  DATA_MODEL.md            Local/server schema, plan lifecycle, content tables
  AUTH_AND_API.md          Firebase Auth, API routes, deployment checklist
  SYNC_STRATEGY.md         Backup/restore design and remaining sync work
  PRODUCT_ROADMAP.md       Current UX model and next implementation priorities
  ADMIN_DASHBOARD.md       Admin routes and content-management notes
  DEVELOPMENT.md           Local setup, run commands, builds, troubleshooting
  ref/HUNNY_RELEASE_LOG.md Release records and Play Console notes
  to-do/                   Active cleanup and post-MVP task lists
```

## Start Here

For a new agent or developer:

1. Read this README.
2. Read `docs/ARCHITECTURE.md` for the system map.
3. Read `docs/DATA_MODEL.md` before changing Read, Plans, Today’s Message, feedback, or sync logic.
4. Read `docs/AUTH_AND_API.md` before changing Firebase Auth, Google sign-in, or API routes.
5. Read `docs/SYNC_STRATEGY.md` before changing backup/restore behavior.
6. Use `docs/DEVELOPMENT.md` for local run/build commands.
7. Use `docs/to-do/MVP_CLOSE_TESTING_TODO.md` for current cleanup priorities.

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

Run web/API/admin:

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
pnpm --dir apps/web typecheck
```

## Current Data Boundary

The mobile app writes reading data locally first. Signed-in users can push a backup to Neon and restore/bootstrap it later through authenticated API routes.

```text
User action
  -> Flutter UI
  -> Drift/SQLite transaction
  -> sync_status pending/local_only
  -> optional authenticated sync push
  -> Next.js API
  -> Neon Postgres
```

The mobile app must not connect directly to Neon. Server access goes through `apps/web` API routes.

## Important Implementation Notes

- Local DB schema source: `apps/mobile/lib/core/database/app_database.dart`
- Generated Drift file: `apps/mobile/lib/core/database/app_database.g.dart`
- Read repository and sync payload logic: `apps/mobile/lib/features/read/data/read_repository.dart`
- Plan Manager screen: `apps/mobile/lib/features/plans/plans_screen.dart`
- Today’s Message client/UI: `apps/mobile/lib/features/home/`
- Server schema file: `apps/web/db/schema.sql`
- API routes: `apps/web/src/app/api`
- Admin pages: `apps/web/src/app/admin`
- Firebase define example: `apps/mobile/.env.example.json`
