# Auth and API

This document describes the active authentication and API setup.

## Current Direction

```text
Supabase Auth
  -> mobile identity and Google login

Next.js API routes
  -> verify Supabase access tokens where required
  -> read/write Supabase Postgres app data

Supabase Postgres
  -> app data database (public.profiles + catalog tables)
```

Supabase Auth is the mobile authentication provider. Postgres is used as the application database through API routes, not as a direct mobile database.

## Mobile Supabase Config

The app initializes Supabase from `--dart-define` values, usually provided by `.env.ios.json` and `.env.android.json`.

Required:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

For Google Sign-In (native + `signInWithIdToken`):

```text
GOOGLE_WEB_CLIENT_ID
GOOGLE_IOS_CLIENT_ID
GOOGLE_ANDROID_CLIENT_ID
HUNNY_API_BASE_URL
```

Example file:

```text
apps/mobile/.env.example.json
```

Local private files are ignored:

```text
apps/mobile/.env*.json
!apps/mobile/.env.example.json
```

## Platform Identity Settings

Current development identifiers:

| Platform | Identifier |
| --- | --- |
| Android applicationId | `com.hunnybibletracker.app` |
| iOS Bundle ID | `com.example.hunnyBibleTracker` |

Before release, confirm these are the intended production IDs and that Supabase + Google OAuth clients match them.

### iOS

- `Info.plist` includes Google `GIDClientID` / reversed client URL scheme for native Google Sign-In.
- `Info.plist` includes `com.hunnybibletracker.app` URL scheme for Supabase OAuth redirects.

### Android

Google Cloud OAuth must include the Android app package and SHA fingerprints.

Register:

- Debug SHA-1
- Release SHA-1
- Play App Signing SHA-1, if using Play Store distribution

Get debug signing data:

```bash
cd apps/mobile/android
./gradlew signingReport
```

## API Routes

All current API routes live under `apps/web/src/app/api`.

| Route | Method | Auth | Purpose |
| --- | --- | --- | --- |
| `/api/health` | `GET` | None | Health check |
| `/api/v1/auth/sync` | `POST` | Supabase bearer | Verify token, upsert `profiles`, return user |
| `/api/v1/me` | `GET` | Supabase bearer | Verify token, upsert `profiles`, return current user summary |
| `/api/v1/plans` | `GET` | None | Public published plan catalog |
| `/api/v1/plans/[identifier]` | `GET` | None | Public single published plan by id/key |
| `/api/v1/content` | `GET` | None | Public published content catalog with author, assets, tags, and related plans |
| `/api/v1/content/[identifier]` | `GET` | None | Public single published content item by id/slug |
| `/api/v1/sync/push` | `POST` | Supabase bearer | Upload compact reading backup snapshot |
| `/api/v1/sync/bootstrap` | `GET` | Supabase bearer | Download compact reading backup snapshot |
| `/api/v1/today-message` | `GET` | None | Latest published Today’s Message by date/language |
| `/api/v1/today-message/[id]/heart` | `POST` | None | Increment Today’s Message heart counter |
| `/api/v1/today-message/[id]/share` | `POST` | None | Increment Today’s Message share counter |
| `/api/v1/feedback` | `POST` | None | Insert Help & feedback message |
| `/api/v1/admin/verify` | `GET` | Admin Supabase bearer | Verify admin access |
| `/api/v1/admin/plans` | `GET/POST` | Admin Supabase bearer | Plan template list/create |
| `/api/v1/admin/plans/[id]` | `GET/PUT/DELETE` | Admin Supabase bearer | Plan template read/update/delete |
| `/api/v1/admin/plans/upload` | `POST` | Admin Supabase bearer | Upload plan cover image |
| `/api/v1/admin/content` | `GET/POST` | Admin Supabase bearer | Content list/create |
| `/api/v1/admin/content/[id]` | `GET/PUT/DELETE` | Admin Supabase bearer | Content read/update/delete |
| `/api/v1/admin/content/authors` | `GET` | Admin Supabase bearer | Content author options |
| `/api/v1/admin/content/upload` | `POST` | Admin Supabase bearer | Upload content image |
| `/api/v1/admin/today-messages` | `GET/POST` | Admin Supabase bearer | Today’s Message list/create |
| `/api/v1/admin/today-messages/[id]` | `GET/PUT/DELETE` | Admin Supabase bearer | Today’s Message read/update/delete |
| `/api/v1/admin/today-messages/upload` | `POST` | Admin Supabase bearer | Upload Today’s Message image |

Supabase-protected routes require:

```text
Authorization: Bearer <Supabase access token>
```

Mobile clients use `/api/health` as a fast reachability probe before optional public/API sync work. Offline-sensitive surfaces should avoid blocking initial UI on authenticated sync, plan catalog refresh, Today’s Message refresh, or Discover content fetches.

Common auth errors:

- `missing_bearer`
- `missing_token`
- `invalid_token`
- `auth_user_sync_failed`

## API Environment

Set in `apps/web/.env.local` or deployment env:

```bash
DATABASE_URL="postgresql://postgres.[ref]:[password]@...pooler.supabase.com:6543/postgres?pgbouncer=true"
SUPABASE_URL="https://YOUR_PROJECT_REF.supabase.co"
SUPABASE_SERVICE_ROLE_KEY="..."
NEXT_PUBLIC_SUPABASE_URL="https://YOUR_PROJECT_REF.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="..."
ADMIN_EMAILS="admin@example.com"
CLOUDINARY_CLOUD_NAME="..."
CLOUDINARY_API_KEY="..."
CLOUDINARY_API_SECRET="..."
```

See [`docs/SUPABASE_SETUP.md`](SUPABASE_SETUP.md) for pooler URLs and OAuth redirect configuration.

## Mobile API Behavior

`HUNNY_API_BASE_URL` is optional.

- If unset or empty, the Flutter app can still run locally with Supabase Auth and SQLite.
- If set, sign-in syncs the Supabase user to `profiles` and reading backup/restore can call `apps/web`.

Local API URLs:

| Platform | URL |
| --- | --- |
| iOS simulator | `http://127.0.0.1:3000` |
| Android emulator | `http://10.0.2.2:3000` |

## Reading Backup/Restore

Signed-in users can:

- Push backup through `POST /api/v1/sync/push`
- Restore/bootstrap through `GET /api/v1/sync/bootstrap`

Current limitations:

- No automatic multi-device incremental pull loop yet.
- No end-user conflict resolution UI yet.
- Restore replaces local reading state with the latest compact backup payload.

## Deployment Checklist

- Supabase Google provider is enabled with correct redirect URLs.
- Google OAuth Android package matches release `applicationId`.
- Android debug/release/Play SHA-1 values are registered in Google Cloud.
- iOS `Info.plist` has Google and `com.hunnybibletracker.app` URL schemes.
- Flutter builds include Supabase + Google dart-define values.
- API deployment has `DATABASE_URL`, Supabase env vars, `ADMIN_EMAILS`, and Cloudinary env vars.
- Supabase has `supabase/migrations/20260528000000_baseline.sql` applied (`supabase db push`).
- `GET /api/health` returns quickly from the deployed API.
- `POST /api/v1/auth/sync` succeeds after mobile login.
- `POST /api/v1/sync/push` succeeds for a signed-in account.
- `GET /api/v1/sync/bootstrap` succeeds for a signed-in account.
- `GET /api/v1/today-message?date=YYYY-MM-DD&language=en` returns published content when available.
- `GET /api/v1/content?sort=featured&language=en` returns published content when available.
- `POST /api/v1/feedback` accepts valid mobile feedback.

## Release Build Examples

iOS:

```bash
cd apps/mobile
flutter build ipa --release --dart-define-from-file=.env.ios.json
```

Android:

```bash
cd apps/mobile
flutter build appbundle --release --dart-define-from-file=.env.android.json
```

Make sure local `.env.*.json` files contain production-safe values before release builds.
