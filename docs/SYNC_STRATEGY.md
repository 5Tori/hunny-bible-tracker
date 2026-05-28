# Sync Strategy

The app is offline-first. Reading data is written locally first, then optionally backed up to Supabase for signed-in users.

```text
User action
  -> SQLite transaction
  -> UI update
  -> row marked local_only/pending
  -> authenticated sync push
  -> Next.js API
  -> Supabase Postgres
```

## Current Implemented Sync

### Auth identity

```text
Supabase access token
  -> POST /api/v1/auth/sync
  -> profiles upsert
```

### Reading backup push

```text
Settings -> Sync now
  -> ReadRepository.exportReadingBackupSnapshot()
  -> POST /api/v1/sync/push
  -> server validates snapshot
  -> server upserts one user_reading_backups row for the auth user
  -> app_settings.last_reading_sync_at updated
```

Push scope:

- plan lifecycle metadata
- completed progress tuples
- reading activity tuples
- completion events
- backup-relevant settings

The push payload does not include `user_plan_chapters`, sync metadata, or per-row server ids.

### Reading backup restore/bootstrap

```text
Settings -> Restore backup
  -> GET /api/v1/sync/bootstrap
  -> server returns compact snapshot
  -> mobile restores user_reading_plans
  -> mobile regenerates user_plan_chapters from plan templates
  -> mobile restores progress, activities, completion events, and settings
```

Core invariant:

```text
user_plan_chapters is local derived data only.
```

Server backup is for backup/restore, not live collaborative sync. Backup size should scale with actual user state, not with the total chapter count of started plans.

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

## Server Backup Table

`apps/web/db/schema.sql` includes:

- `user_reading_backups`

The server stores one compact backup row per `auth_user_id`. Legacy relational reading sync tables are no longer part of the server schema.

## Identity Merge

Before sign-in, local data belongs to one guest `local_users` row.

After sign-in:

```text
Supabase user UUID
  -> local_users.auth_user_id
  -> POST /api/v1/auth/sync
  -> profiles.id
```

Current behavior preserves local data and pushes it after sign-in. Restore/bootstrap replaces local reading state from the compact account backup.

## Data Categories

### Template data

Plan templates are source/catalog data.

Published plan templates are server-managed in Supabase and downloaded through `GET /api/v1/plans`. Mobile caches them locally in Drift so Catalog and user plan creation can work from the local snapshot.

### User plan runs

Compact backup uploads only plan lifecycle metadata and uses `templateKey` to regenerate local derived chapters on restore.

Archived plans remain syncable. Archive is a status/state update, not a destructive delete.

### Chapter progress

`chapter_progress_entries` is mutable current state.

Explicit uncheck is a real mutation and should sync.

### Reading activities

`reading_activities` is append-friendly activity history.

Do not delete completion activity when a user unchecks a chapter.

### Completion events

`plan_completion_events` is one event per finished user plan run.

## Current API Surface

| Route | Purpose |
| --- | --- |
| `POST /api/v1/sync/push` | Upload current local reading snapshot for signed-in user |
| `GET /api/v1/sync/bootstrap` | Download server snapshot for signed-in user |

All routes verify Supabase bearer tokens server-side.

## Remaining Sync Work

Do not treat the current sync as full multi-device collaboration. It is a practical backup/restore foundation.

Remaining work:

- Apply `supabase/migrations/20260528000000_baseline.sql` to the fresh Supabase database.
- Run push/restore E2E smoke tests.
- Throttled app-start sync UX and telemetry polish.
- Network reconnect trigger.
- More explicit sync error state in Settings.
- Conflict telemetry before exposing conflict resolution UI.
- Clear policy for cross-device edits to the same chapter before automatic merge is advertised.
