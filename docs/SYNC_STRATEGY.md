# Sync Strategy

Remote reading-data sync is planned. The current MVP direction is a narrow
push-only backup first, then restore/bootstrap after the upload path is stable.

The current app is offline-first:

```text
User action
  -> SQLite transaction
  -> UI update
  -> row marked local_only/pending
  -> sync worker / manual Sync now
  -> Next.js API
  -> Neon Postgres
```

## Current Implemented Sync

Only auth identity sync exists today.

```text
Firebase ID token
  -> POST /api/v1/auth/sync
  -> Neon auth_users upsert
```

Reading plans, chapters, progress, activities, settings, and completion events do not sync to the server yet. Server tables for the core reading-data backup path have been added, but API and mobile upload code still need to be implemented.

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
| `pending` | Row changed locally and should be uploaded later |
| `synced` | Reserved for future server acknowledgement |
| `conflict` | Reserved for future conflict handling |

Feature code already sets `pending` for user-driven mutations in key tables.

## Future Sync Triggers

Recommended v1 triggers:

- App start
- Existing Firebase session refresh, throttled by last sync time
- Network reconnect
- Manual Settings -> Sync now
- Debounced after local mutations

## Identity Merge

Before sign-in, local data belongs to one guest `local_users` row.

After sign-in:

```text
Firebase uid
  -> local_users.auth_user_id
  -> future sync owner key
```

Future sync should merge guest local data into the signed-in account rather than discarding local progress.

## Data Categories

### Template data

Plan templates are mostly source/catalog data.

Published plan templates are server-managed in Neon and downloaded through `GET /api/v1/plans`.
Mobile caches them locally in Drift so Browse Plans and user plan creation can work from the local snapshot.

### User plan runs

`user_reading_plans` and `user_plan_chapters` should upload together. A user plan run is a snapshot and should not be silently rewritten by later template edits.

### Chapter progress

`chapter_progress_entries` is mutable current state.

Recommended conflict policy:

```text
unique(local_user_id, user_plan_id, book_key, chapter_number)
latest updated_at / client_revision wins
```

Explicit uncheck is a real mutation and should sync.

### Reading activities

`reading_activities` is append-friendly activity history.

Recommended conflict policy:

```text
unique(local_user_id, user_plan_id, book_key, chapter_number, activity_date, action)
insert-or-ignore / append-only
```

Do not delete completion activity when a user unchecks a chapter.

### Completion events

`plan_completion_events` is one event per finished user plan run.

Recommended conflict policy:

```text
unique(user_plan_id)
insert-once
```

## Future API Surface

Suggested route shape:

| Route | Purpose |
| --- | --- |
| `GET /api/v1/sync/bootstrap` | Download server snapshot after login |
| `POST /api/v1/sync/push` | Upload pending local mutations |
| `POST /api/v1/sync/pull` | Pull changes since cursor |
| `POST /api/v1/sync/resolve` | Optional conflict resolution endpoint |

All routes should verify Firebase bearer tokens server-side.

MVP implementation order:

```text
POST /api/v1/sync/push first
Settings -> Sync now calls push
GET /api/v1/sync/bootstrap for manual restore
POST /api/v1/sync/pull only when incremental restore is needed
```

## Server Schema Work Required

`apps/web/db/schema.sql` now includes reading-data sync tables for:

```text
- user_reading_plans
- user_plan_chapters
- chapter_progress_entries
- reading_activities
- plan_completion_events
- sync_states
```

The server schema is aligned with the current local model in `docs/DATA_MODEL.md` for backup-first sync. It stores mobile client UUIDs as `client_id` values so API routes can acknowledge uploaded rows back to local Drift rows later.

## Implementation Order

1. Implement auth-scoped push endpoint.
2. Add mobile payload builders for pending local rows.
3. Mark acknowledged rows as `synced` with server ids and `last_synced_at`.
4. Add Settings UI for sync status and manual Sync now.
5. Add idempotent activity and completion upserts.
6. Add conflict telemetry before exposing complex resolution UI.
