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
  -> Firebase Auth
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

For normative detail on **LWW vs append-only logs** and idempotent completion keys, see `docs/PROGRESS_AND_ACTIVITY_PLAN.md` §5 and §9.

---

## Local schema: sync-ready metadata (Phase E)

The Flutter app keeps **SQLite as the write path**; the columns below exist so a future outbox / API layer can push and reconcile without another schema bump for the basics.

**Phase F (Firebase Auth):** see `docs/FIREBASE_AUTH.md` for Firebase token verification and linking `local_users.auth_user_id` from the mobile client.

### `sync_status` (text)

| Value | Meaning |
|--------|---------|
| `local_only` | Row has not been marked dirty for upload, or was created locally with defaults. |
| `pending` | Local change that should be included in the next sync batch. |
| `synced` | Reserved: last push was acknowledged (set by sync worker, not by feature code yet). |
| `conflict` | Reserved: server rejected or diverged; needs resolution UI or policy. |

Feature code today sets `pending` on user-driven mutations to plans, chapter progress, and reading activities. New rows may stay `local_only` until first mutation or until a sync layer normalizes.

### Per-row metadata (hot tables)

| Column | Role |
|--------|------|
| `server_id` | Nullable text: stable id from Neon / API after first successful upsert. |
| `last_synced_at` | Nullable: when this row was last acknowledged in sync (client clock). |
| `client_revision` | Monotonic integer bumped on **each local mutation** of that row for LWW and merge hints (with `updated_at`). |

**Tables carrying these fields (schema v3+):** `local_users` (`sync_status` + triplet), `user_reading_plans`, `plan_scope_chapters`, `chapter_progress_entries`, `reading_activities`.

`plan_scope_chapters` also carries `sync_status` so plan scope can be uploaded as a unit with the same outbox semantics as the parent plan.

### Implementation notes

- **Chapter progress:** bump `client_revision` and set `sync_status = pending` on insert/update; never delete `reading_activities` “complete” rows on uncheck (see product plan §5.1).
- **Reading activities:** `INSERT OR IGNORE` for idempotent completes; new rows start at `client_revision = 0` until a sync layer defines finer rules.
- **Server ack:** sync worker should set `server_id`, `last_synced_at`, and optionally `sync_status = synced` without resetting `client_revision` unless the protocol requires it.
