# Hunny Bible Tracker Mobile

Flutter app for the offline-first tracker MVP.

## Setup

```bash
flutter create --platforms=ios,android --project-name hunny_bible_tracker .
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Important generated file

Drift generates this file:

```text
lib/core/database/app_database.g.dart
```

It is intentionally not included in this zip. Generate it with build_runner.

## Main implemented flow

1. App starts in guest/offline mode.
2. Local Bible metadata is seeded from `assets/data/bible_books.en.json`.
3. A built-in Whole Bible plan is created.
4. The Read tab shows books in a 3-column grid.
5. Selecting a book opens chapters in an 8-column grid.
6. Tapping a chapter toggles completion.
7. Progress and reading activity are stored locally in SQLite.
