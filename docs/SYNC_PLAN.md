# Backup and Sync Plan

## Principle

The local SQLite database is the first write target. The server is backup/sync infrastructure, not the primary runtime dependency.

```text
User action
  -> SQLite transaction
  -> UI update
  -> mark row pending for future sync
  -> optional background/foreground sync later
```

## Future stack

```text
Flutter App
  -> Next.js API
  -> Neon Postgres
  -> Neon Auth
```

The Flutter app should not connect directly to Neon.

## Future sync triggers

- App start
- App returns to foreground
- Network reconnect
- Manual Settings > Sync now
- Debounced after local changes

## Conflict policy v1

- Most recent `updated_at` wins for chapter progress.
- Explicit uncheck is considered a real update.
- Reading activity logs are append-only.
- Guest local data should be merged into the account on first login.
