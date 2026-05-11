# Hunny Bible Tracker

Offline-first Bible reading tracker built with Flutter + Drift(SQLite), with a future path for Next.js API + Neon Postgres + Neon Auth backup/sync.

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
- Local settings for language/timezone/account placeholder

The tracker does **not** store full Bible text. It stores book/chapter references and user progress.

## Monorepo layout

```text
apps/
  mobile/   Flutter app
  api/      Next.js API placeholder for future Neon sync

docs/
  PRODUCT_PLAN.md
  SYNC_PLAN.md
```

## Run the Flutter app

### First-time setup

Generate native platform folders (if not already present):

```bash
cd apps/mobile
flutter create --platforms=ios,android,web --project-name hunny_bible_tracker .
flutter pub get
dart run build_runner build
```

If Flutter asks to overwrite files, do **not** overwrite the existing `lib/`, `assets/`, or `pubspec.yaml` files.

### Run on iOS Simulator (recommended)

```bash
open -a Simulator                # launch Simulator app
cd apps/mobile
flutter run                      # auto-detects the booted simulator
```

To target a specific device:

```bash
xcrun simctl list devices available   # list simulators
flutter run -d <DEVICE_ID>            # run on a specific simulator
```

### Run on Chrome (web)

```bash
cd apps/mobile
flutter run -d chrome
```

### Hot-reload key commands (while running)

| Key | Action |
|-----|--------|
| `r` | Hot reload — applies code changes instantly |
| `R` | Hot restart — full restart with state reset |
| `d` | Detach — stop CLI but keep the app running |
| `q` | Quit — terminate the app |

## Future API

The API folder is intentionally light for v0.1. The planned server stack is:

```text
Next.js API
Neon Postgres
Neon Auth
```

The mobile app should never connect to Neon directly. Sync should go through the API layer.
