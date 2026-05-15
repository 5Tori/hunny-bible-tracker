# Sync Strategy

The app is offline-first. Reading data is written locally first, then optionally backed up to Neon for signed-in users.

```text
User action
  -> SQLite transaction
  -> UI update
  -> row marked local_only/pending
  -> authenticated sync push
  -> Next.js API
  -> Neon Postgres
```

## Current Implemented Sync

### Auth identity

```text
Firebase ID token
  -> POST /api/v1/auth/sync
  -> Neon auth_users upsert
```

### Reading-data push backup

```text
Settings -> Sync now
  -> ReadRepository.buildReadingSyncPushPayload()
  -> POST /api/v1/sync/push
  -> server upserts rows by auth user + client id
  -> mobile marks acknowledged rows synced
  -> app_settings.last_reading_sync_at updated
```

Push scope:

- `user_reading_plans`
- `user_plan_chapters`
- `chapter_progress_entries`
- `reading_activities`
- `plan_completion_events`

### Reading-data restore/bootstrap

```text
Settings -> Restore backup
  -> GET /api/v1/sync/bootstrap
  -> server returns account snapshot
  -> mobile insertOnConflictUpdate into Drift
  -> local-only starter plans may be archived when server data exists
```

Restore scope matches push scope.

## Local Sync Metadata

Hot local tables include sync-ready fields:

- `sync_status`
- `server_id`
- `last_synced_at`
- `client_revision`

Current values:

| Value | Meaning |
| --- | --- |
| `local_only` | Row exists locally and has not been uploaded |
| `pending` | Row changed locally and should be uploaded |
| `synced` | Server acknowledged the row |
| `conflict` | Reserved for future conflict handling |

Feature code sets `pending` for user-driven mutations in key tables.

## Server Sync Tables

`apps/web/db/schema.sql` includes:

- `user_reading_plans`
- `user_plan_chapters`
- `chapter_progress_entries`
- `reading_activities`
- `plan_completion_events`
- `sync_states`

Server rows are scoped by `auth_user_id`. Mobile local UUIDs are stored as `client_id` values and returned in acknowledgements.

## Identity Merge

Before sign-in, local data belongs to one guest `local_users` row.

After sign-in:

```text
Firebase uid
  -> local_users.auth_user_id
  -> POST /api/v1/auth/sync
  -> auth_users.id
```

Current behavior preserves local data and pushes it after sign-in. Restore/bootstrap can pull server data into the current local user.

## Data Categories

### Template data

Plan templates are source/catalog data.

Published plan templates are server-managed in Neon and downloaded through `GET /api/v1/plans`. Mobile caches them locally in Drift so Catalog and user plan creation can work from the local snapshot.

### User plan runs

`user_reading_plans` and `user_plan_chapters` should upload together. A user plan run is a snapshot and should not be silently rewritten by later template edits.

Archived plans remain syncable. Archive is a status/state update, not a destructive delete.

### Chapter progress

`chapter_progress_entries` is mutable current state.

Current backup policy:

```text
unique(auth_user_id, client_id)
unique(auth_user_id, user_reading_plan_id, book_key, chapter_number)
```

Future conflict policy:

```text
latest updated_at / client_revision wins
```

Explicit uncheck is a real mutation and should sync.

### Reading activities

`reading_activities` is append-friendly activity history.

Current backup policy:

```text
unique(auth_user_id, client_id)
unique(auth_user_id, user_reading_plan_id, book_key, chapter_number, activity_date, action)
```

Do not delete completion activity when a user unchecks a chapter.

### Completion events

`plan_completion_events` is one event per finished user plan run.

Current backup policy:

```text
unique(auth_user_id, client_id)
unique(user_reading_plan_id)
```

## Current API Surface

| Route | Purpose |
| --- | --- |
| `POST /api/v1/sync/push` | Upload current local reading snapshot for signed-in user |
| `GET /api/v1/sync/bootstrap` | Download server snapshot for signed-in user |

All routes verify Firebase bearer tokens server-side.

## Remaining Sync Work

Do not treat the current sync as full multi-device collaboration. It is a practical backup/restore foundation.

Remaining work:

- Throttled app-start sync UX and telemetry polish.
- Network reconnect trigger.
- More explicit sync error state in Settings.
- Incremental pull cursor if full bootstrap becomes too heavy.
- Conflict telemetry before exposing conflict resolution UI.
- Clear policy for cross-device edits to the same chapter before automatic merge is advertised.
