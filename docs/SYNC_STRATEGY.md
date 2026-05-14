# Sync Strategy

Remote reading-data sync is planned but not implemented.

The current app is offline-first:

```text
User action
  -> SQLite transaction
  -> UI update
  -> row marked local_only/pending
  -> future sync worker
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

Reading plans, chapters, progress, activities, settings, and completion events do not sync to the server yet.

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
- App returns to foreground
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

Initial sync can treat built-in templates as app-bundled seed data. Server-managed catalog work can come later.

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

## Server Schema Work Required

`apps/web/db/schema.sql` currently supports `auth_users`. It should be expanded before implementing reading-data sync.

The server schema should align with the current local model in `docs/DATA_MODEL.md`.

## Implementation Order

1. Define server schema for current local model.
2. Add server ids/cursors/outbox query helpers.
3. Implement auth-scoped push endpoint.
4. Implement idempotent activity and completion upserts.
5. Add pull/bootstrap endpoint.
6. Add Settings UI for sync status and manual Sync now.
7. Add conflict telemetry before exposing complex resolution UI.
