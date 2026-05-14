# Auth and API

This document describes the active authentication and API setup.

## Current Direction

```text
Firebase Auth
  -> mobile identity and Google login

Next.js API routes
  -> verify Firebase ID token
  -> upsert Neon auth user

Neon Postgres
  -> app data database
```

Firebase Auth is the mobile authentication provider. Neon is used as the application database through API routes, not as the mobile auth provider.

## Mobile Firebase Config

The app initializes Firebase from `--dart-define` values, usually provided by `.env.ios.json` and `.env.android.json`.

Required:

```text
FIREBASE_API_KEY
FIREBASE_APP_ID
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_PROJECT_ID
```

Recommended/current:

```text
FIREBASE_AUTH_DOMAIN
FIREBASE_STORAGE_BUCKET
FIREBASE_IOS_BUNDLE_ID
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

Before release, confirm these are the intended production IDs and that Firebase apps match them exactly.

### iOS

Native Google Sign-In requires `apps/mobile/ios/Runner/Info.plist` to match `apps/mobile/ios/Runner/GoogleService-Info.plist`:

- `GIDClientID` = iOS `CLIENT_ID`
- `CFBundleURLTypes` scheme = `REVERSED_CLIENT_ID`

Firebase iOS SDK 12.x requires iOS deployment target 15.0+ in this project.

### Android

Firebase Console must include the Android app package and SHA fingerprints.

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

| Route | Method | Purpose |
| --- | --- | --- |
| `/api/health` | `GET` | Health check |
| `/api/v1/auth/sync` | `POST` | Verify Firebase bearer token, upsert `auth_users`, return user |
| `/api/v1/me` | `GET` | Verify Firebase bearer token, upsert `auth_users`, return current user summary |

Auth routes require:

```text
Authorization: Bearer <Firebase ID token>
```

Possible auth errors:

- `missing_bearer`
- `missing_token`
- `invalid_token`
- `sync_failed`

## API Environment

Set in `apps/web/.env.local` or deployment env:

```bash
DATABASE_URL="postgresql://USER:PASSWORD@HOST/dbname?sslmode=require"
FIREBASE_PROJECT_ID="..."
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-...@YOUR_PROJECT.iam.gserviceaccount.com"
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

Firebase Admin can also use application default credentials if service-account env vars are not set and the environment supports ADC.

## Mobile API Behavior

`HUNNY_API_BASE_URL` is optional.

- If unset or empty, the Flutter app can still run locally with Firebase Auth and SQLite.
- If set, sign-in will try to sync the Firebase user to Neon through `apps/web`.

Local API URLs:

| Platform | URL |
| --- | --- |
| iOS simulator | `http://127.0.0.1:3000` |
| Android emulator | `http://10.0.2.2:3000` |

## Deployment Checklist

- Firebase Google provider is enabled.
- Firebase Android package matches release `applicationId`.
- Firebase iOS Bundle ID matches release Bundle ID.
- Android debug/release/Play SHA-1 values are registered.
- iOS `Info.plist` has correct `GIDClientID` and reversed URL scheme.
- Flutter builds include dart-define values.
- API deployment has `DATABASE_URL` and Firebase Admin env vars.
- Neon has `apps/web/db/schema.sql` applied.
- `POST /api/v1/auth/sync` succeeds after mobile login.
- `GET /api/v1/me` succeeds with a Firebase ID token.

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
