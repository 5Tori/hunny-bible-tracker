# Hunny Bible Tracker Mobile

Flutter iOS/Android app for the offline-first Bible reading tracker.

**Current release:** `0.5.0+11` — see `docs/ref/HUNNY_RELEASE_LOG.md`

Home and Read are expected to work from local Drift data when offline. Discover is online-only for MVP and should show an offline message quickly when the web API is unreachable.

Use the root README and docs as the source of truth:

- `../../README.md`
- `../../docs/ARCHITECTURE.md`
- `../../docs/DATA_MODEL.md`
- `../../docs/AUTH_AND_API.md`
- `../../docs/DEVELOPMENT.md`

## Feature areas (mobile)

| Area | Notes |
| --- | --- |
| Home | Today's Message · **Current plan** hero (ring, chapters read) · weekly + last-read footer · tap plan → Read + scroll to last-read chapter |
| Read | Chapter grid · plan progress · last-opened section |
| Settings | Account · sync/restore · preferences · **reading stats** (summary + activity grid; pull-to-refresh) |
| Stats | `ReadingStatsRepository` — habit/activity stats from `reading_activities` (separate from plan progress in `ReadRepository`) |

## Common Commands

```bash
flutter pub get
flutter pub run build_runner build
./scripts/run_ios.sh
./scripts/run_android.sh
flutter analyze
flutter test --exclude-tags slow
```

Full-app widget test (may hang in CI; run manually):

```bash
flutter test test/widget_test.dart
```

Release build:

```bash
flutter build appbundle --release --dart-define-from-file=.env.android.json
flutter build ipa --release --dart-define-from-file=.env.ios.json
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
