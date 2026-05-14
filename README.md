# Hunny Bible Tracker

Offline-first Bible reading tracker built with Flutter + Drift(SQLite), Firebase Auth, Next.js web/API routes, and Neon Postgres.

## Current scope: v0.1

The initial implementation focuses on the **Read** tab:

- Bottom tabs: Home / Find / Read / List / Settings
- Offline-first local SQLite persistence through Drift
- Built-in Whole Bible plan
- Chapter-level check/uncheck tracker
- 3-column book grid
- 8-column chapter grid
- Book progress and total plan progress
- Last opened book memory
- Streak-ready reading activity log
- Local settings for language/timezone/account
- Firebase Auth account link

The tracker does **not** store full Bible text. It stores book/chapter references and user progress.

## Monorepo layout

```text
apps/
  mobile/   Flutter app
  web/      Next.js web app and API routes for Firebase token verification and future Neon sync

docs/
  FIREBASE_AUTH.md
  PRODUCT_PLAN.md
  SYNC_PLAN.md
```

## Development Setup

### First-time setup

```bash
cd apps/mobile
flutter pub get
dart run build_runner build
```

If native platform folders ever need to be regenerated, run Flutter create carefully and do **not** overwrite existing `lib/`, `assets/`, or `pubspec.yaml` files:

```bash
flutter create --platforms=ios,android --project-name hunny_bible_tracker .
```

### Firebase Define Files

The app initializes Firebase from `--dart-define` values. Do not type them manually every time. Use define files instead.

Create local files from the committed example:

```bash
cd apps/mobile
cp .env.example.json .env.ios.json
cp .env.example.json .env.android.json
```

Fill both files with values from Firebase Console / app settings.

Use different API base URLs per platform:

```json
{
  "HUNNY_API_BASE_URL": "http://127.0.0.1:3000"
}
```

```json
{
  "HUNNY_API_BASE_URL": "http://10.0.2.2:3000"
}
```

The first value is for `.env.ios.json`; the second is for `.env.android.json`. These local files are ignored by git:

```bash
apps/mobile/.env*.json
!apps/mobile/.env.example.json
```

### Optional Web/API Server

The Flutter app can run without the server. If `HUNNY_API_BASE_URL` is set, sign-in will also try to upsert the Firebase user into Neon through API routes in `apps/web`.

Run the web app:

```bash
pnpm web:dev
```

API environment is documented in `docs/FIREBASE_AUTH.md`.

## Run on iOS Simulator

Start a simulator:

```bash
open -a Simulator
```

List devices if needed:

```bash
xcrun simctl list devices available
```

Run on the booted iOS simulator:

```bash
cd apps/mobile
./scripts/run_ios.sh
```

To target a specific simulator:

```bash
./scripts/run_ios.sh -d <DEVICE_ID>
```

iOS native Google Sign-In also requires `apps/mobile/ios/Runner/Info.plist` to match `apps/mobile/ios/Runner/GoogleService-Info.plist`:

- `GIDClientID` = `CLIENT_ID`
- `CFBundleURLTypes` scheme = `REVERSED_CLIENT_ID`

## Run on Android Emulator

Start an Android emulator from Android Studio Device Manager, or list/run devices from the CLI:

```bash
flutter emulators
flutter emulators --launch <EMULATOR_ID>
flutter devices
```

Run on the booted Android emulator:

```bash
cd apps/mobile
./scripts/run_android.sh
```

To target a specific emulator:

```bash
./scripts/run_android.sh -d <DEVICE_ID>
```

Android emulator uses `10.0.2.2` to reach a server running on the host machine. Do not use `127.0.0.1` for the API from Android emulator unless the API is running inside the emulator.

For Google Sign-In on Android, add the debug SHA-1 to Firebase Console:

```bash
cd apps/mobile/android
./gradlew signingReport
```

Then add the `SHA1` under Firebase Console → Project settings → Android app → SHA certificate fingerprints.

If Android build fails with an NDK error like `source.properties` missing, delete the broken local NDK folder and let Android Studio/Gradle reinstall it:

```bash
rm -rf /Users/dongwon/Library/Android/sdk/ndk/28.2.13676358
```

## Hot-reload key commands

| Key | Action |
|-----|--------|
| `r` | Hot reload — applies code changes instantly |
| `R` | Hot restart — full restart with state reset |
| `d` | Detach — stop CLI but keep the app running |
| `q` | Quit — terminate the app |

## API Direction

The server stack is:

```text
Next.js API
Firebase Admin SDK
Neon Postgres
```

The mobile app should never connect to Neon directly. Sync should go through the API layer.
