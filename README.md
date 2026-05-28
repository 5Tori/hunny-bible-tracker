# Hunny Bible Tracker

Offline-first Bible reading tracker built with Flutter, Drift/SQLite, Supabase Auth, Next.js API routes, and Supabase Postgres.

The app does not store full Bible text. It stores book/chapter references, reading plans, chapter progress, reading activities, local settings, Today’s Message content metadata, Discover content metadata, and account-link metadata.

## Current Status

The current MVP focus is closed-test readiness for Home, Discover, Read, Plans, Settings, and the public web/API surface.

- Flutter mobile app for iOS and Android.
- Bottom tabs for `Home`, `Discover`, `Read`, and `Settings`; unfinished Saved/List surfaces are hidden for MVP.
- Offline-first local database through Drift/SQLite. Home and Read must load quickly offline; Discover is online-only and shows an offline state when the API is unreachable.
- Supabase Auth for Google sign-in.
- Supabase Postgres is the server-side app database behind `apps/web` API routes.
- Read supports section-based plan runs, chapter progress, completion, completed history, Start Again, and plan archive/restore.
- Plans is a full-screen Plan Manager / Plan Library with `My Plans`, `Catalog`, `Archived`, and catalog CTA states.
- Home supports Today’s Message cards, quick reflection, Read More article modal, related plan CTA, local save, heart/share counters, current reading progress, cached messages, and an offline fallback message.
- Discover supports published content search, type filters, tag filters, media/detail sheets, YouTube video/Shorts playback, and related plan cards.
- Settings supports account sign-in/out, manual backup, restore/bootstrap, sync status, Manage reading plans, and Help & feedback submission.
- Admin dashboard supports plan templates, Today’s Message management, and general content CRUD.
- `apps/web` serves the public website, support/legal pages, mobile API routes, and admin dashboard. The public website uses Tailwind v4 in the Next.js app.

Remote reading-data backup and restore are implemented through `POST /api/v1/sync/push` and `GET /api/v1/sync/bootstrap`. Full automatic multi-device incremental merge is still deferred.

## Monorepo Layout

```text
apps/
  mobile/   Flutter app
  web/      Next.js web/API/admin app

docs/
  PROJECT_CONTEXT.md       이 프로젝트에 대한 전체 컨텍스트
  ARCHITECTURE.md          Runtime structure and module map
  DATA_MODEL.md            Local/server schema, plan lifecycle, content tables
  AUTH_AND_API.md          Supabase Auth, API routes, deployment checklist
  SUPABASE_SETUP.md        Supabase project, migrations, OAuth redirects
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
4. Read `docs/AUTH_AND_API.md` and `docs/SUPABASE_SETUP.md` before changing Supabase Auth, Google sign-in, or API routes.
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

Fill both files with Supabase values. Use:

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

## Release Builds

The app version comes from the root mobile app file:

```text
apps/mobile/pubspec.yaml
```

Use `version: <versionName>+<versionCode>`:

```yaml
version: 0.3.0+7
```

For Google Play, every upload must increase the number after `+` (`versionCode`). If Play Console says the version already exists, confirm you edited `apps/mobile/pubspec.yaml`, not a plugin/example `pubspec.yaml` under `ios/.symlinks` or another generated folder.

Android release app bundle:

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter build appbundle --release --dart-define-from-file=.env.android.json
```

Output:

```text
apps/mobile/build/app/outputs/bundle/release/app-release.aab
```

iOS release archive:

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter build ipa --release --dart-define-from-file=.env.ios.json
```

Output:

```text
apps/mobile/build/ios/ipa/*.ipa
```

Before release builds, make sure `.env.android.json` and `.env.ios.json` point `HUNNY_API_BASE_URL` to the deployed API, not a local emulator URL.

## Current Data Boundary

The mobile app writes reading data locally first. Signed-in users can push a backup to Supabase and restore/bootstrap it later through authenticated API routes.

```text
User action
  -> Flutter UI
  -> Drift/SQLite transaction
  -> sync_status pending/local_only
  -> optional authenticated sync push
  -> Next.js API
  -> Supabase Postgres
```

The mobile app must not connect directly to Supabase Postgres. Server access goes through `apps/web` API routes.

## Important Implementation Notes

- Local DB schema source: `apps/mobile/lib/core/database/app_database.dart`
- Generated Drift file: `apps/mobile/lib/core/database/app_database.g.dart`
- Read repository and sync payload logic: `apps/mobile/lib/features/read/data/read_repository.dart`
- Shared mobile API timeout/reachability client: `apps/mobile/lib/core/api/hunny_api_client.dart`
- Plan Manager screen: `apps/mobile/lib/features/plans/plans_screen.dart`
- Today’s Message client/UI: `apps/mobile/lib/features/home/`
- Discover content finder UI: `apps/mobile/lib/features/find/discover_screen.dart`
- Mobile splash and fallback imagery: `apps/mobile/assets/image/`
- Server schema file: `apps/web/db/schema.sql`
- API routes: `apps/web/src/app/api`
- Admin pages: `apps/web/src/app/admin`
- Supabase define example: `apps/mobile/.env.example.json`
