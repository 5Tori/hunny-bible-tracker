# Hunny Bible Tracker Mobile

Flutter iOS/Android app for the offline-first Bible reading tracker.

Home and Read are expected to work from local Drift data when offline. Discover is online-only for MVP and should show an offline message quickly when the web API is unreachable.

Use the root README and docs as the source of truth:

- `../../README.md`
- `../../docs/ARCHITECTURE.md`
- `../../docs/DATA_MODEL.md`
- `../../docs/AUTH_AND_API.md`
- `../../docs/DEVELOPMENT.md`

## Common Commands

```bash
flutter pub get
flutter pub run build_runner build
./scripts/run_ios.sh
./scripts/run_android.sh
flutter analyze
flutter test
```

## Current Assets

```text
assets/icon/app-icon.jpg          # launcher icon source
assets/image/logo-and-name.jpg    # native launch/splash source art
assets/image/honeycomb.jpg        # Today’s Message offline fallback image
```

The local database schema source is:

```text
lib/core/database/app_database.dart
```

Generated Drift code is:

```text
lib/core/database/app_database.g.dart
```
