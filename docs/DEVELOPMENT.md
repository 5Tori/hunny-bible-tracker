# Development

This document contains local setup, run commands, build commands, and common troubleshooting.

## Prerequisites

- Flutter SDK
- Xcode and iOS simulator for iOS development
- Android Studio and Android SDK for Android development
- pnpm for the web/API app
- Firebase project with Android and iOS apps

## First-Time Mobile Setup

```bash
cd apps/mobile
flutter pub get
flutter pub run build_runner build
```

Use `flutter pub run build_runner build` for Drift generation. If generated files conflict, clean up intentionally; do not hand-edit `app_database.g.dart`.

## Define Files

The Flutter app uses `--dart-define-from-file`.

Create local files:

```bash
cd apps/mobile
cp .env.example.json .env.ios.json
cp .env.example.json .env.android.json
```

Fill both files with Firebase values.

Use platform-specific API base URLs:

```json
{
  "HUNNY_API_BASE_URL": "http://127.0.0.1:3000"
}
```

for iOS simulator, and:

```json
{
  "HUNNY_API_BASE_URL": "http://10.0.2.2:3000"
}
```

for Android emulator.

These files are ignored by git:

```text
apps/mobile/.env*.json
!apps/mobile/.env.example.json
```

## Run iOS

Start a simulator:

```bash
open -a Simulator
```

Run:

```bash
cd apps/mobile
./scripts/run_ios.sh
```

Target a specific simulator:

```bash
./scripts/run_ios.sh -d <DEVICE_ID>
```

## Run Android

Start an emulator from Android Studio Device Manager, or use:

```bash
flutter emulators
flutter emulators --launch <EMULATOR_ID>
flutter devices
```

Run:

```bash
cd apps/mobile
./scripts/run_android.sh
```

Target a specific emulator:

```bash
./scripts/run_android.sh -d <DEVICE_ID>
```

## Run Web/API

Install dependencies from repo root if needed:

```bash
pnpm install
```

Create env file:

```bash
cp apps/web/.env.example apps/web/.env.local
```

Fill:

```text
DATABASE_URL
FIREBASE_PROJECT_ID
FIREBASE_CLIENT_EMAIL
FIREBASE_PRIVATE_KEY
```

Run:

```bash
pnpm web:dev
```

## Checks

Mobile:

```bash
cd apps/mobile
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

Web:

```bash
pnpm web:build
pnpm --dir apps/web typecheck
```

Run `flutter analyze` and `pnpm --dir apps/web typecheck` after focused mobile/web implementation work. Run the broader test/build set before release candidates.

## Native Platform Notes

If native platform folders ever need to be regenerated, run Flutter create carefully and do not overwrite existing `lib/`, `assets/`, or `pubspec.yaml` files:

```bash
cd apps/mobile
flutter create --platforms=ios,android --project-name hunny_bible_tracker .
```

## Firebase Native Checks

iOS:

- `apps/mobile/ios/Runner/GoogleService-Info.plist` exists.
- `Info.plist` has matching `GIDClientID`.
- URL scheme matches Firebase `REVERSED_CLIENT_ID`.

Android:

- `applicationId` is `com.hunnybibletracker.app`.
- Firebase Android app uses the same package name.
- Debug SHA-1 is registered.

Get SHA-1:

```bash
cd apps/mobile/android
./gradlew signingReport
```

## Hot Reload Keys

| Key | Action |
| --- | --- |
| `r` | Hot reload |
| `R` | Hot restart |
| `d` | Detach and keep app running |
| `q` | Quit app |

## Troubleshooting

### Android NDK folder is broken

If Android build fails with an NDK error such as `source.properties` missing, delete the broken local NDK folder and let Android Studio/Gradle reinstall it:

```bash
rm -rf /Users/dongwon/Library/Android/sdk/ndk/28.2.13676358
```

### Android emulator cannot reach local API

Use:

```text
http://10.0.2.2:3000
```

Do not use `127.0.0.1` from Android emulator unless the API server runs inside the emulator.

### iOS simulator cannot return from Google Sign-In

Check:

- `GoogleService-Info.plist`
- `Info.plist` `GIDClientID`
- `CFBundleURLTypes`
- Bundle ID in Firebase Console

### Drift generated code is stale

Run:

```bash
cd apps/mobile
flutter pub run build_runner build
```

Then run:

```bash
flutter analyze
flutter test
```

### Mobile data looks stale during MVP development

The app is still in active schema/content development. If plan or Today’s Message behavior looks stale during manual testing, uninstall the app or reset the simulator/emulator app data, then run again with the current API base URL.
