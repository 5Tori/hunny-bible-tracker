# Sync Strategy

**Offline-first** 읽기 데이터 설계. Live collaborative sync가 아닌 **compact backup/restore**.

## Flow

```text
User action → SQLite transaction → UI update
  → (signed-in) POST /api/v1/sync/push → user_reading_backups
```

## Push scope (포함)

Plan lifecycle metadata · completed progress · reading activities · completion events · backup-relevant settings

## Push scope (미포함)

`user_plan_chapters` · sync metadata · per-row `server_id`

## Restore

`GET /api/v1/sync/bootstrap` → restore plans/progress/activities/events/settings → **`user_plan_chapters`를 plan template에서 local regenerate**

## Core invariant

```text
user_plan_chapters = local derived data only
```

Backup size는 started plan의 total chapter 수에 비례하지 **않음** (compact snapshot).

## Local sync metadata

`sync_status`: `local_only` · `pending` · `synced` · `conflict`(reserved)

## Identity merge

Sign-in: Supabase UUID → `local_users.auth_user_id` → `POST /api/v1/auth/sync` → `profiles`. Local data preserve 후 push. Restore는 account backup으로 **replace**.

## Data rules

| Data | Rule |
| --- | --- |
| Plan templates | Server catalog → `GET /api/v1/plans` → local cache |
| User plan runs | Backup에 lifecycle + `templateKey` only |
| `chapter_progress_entries` | Mutable; uncheck도 sync 대상 |
| `reading_activities` | Append-friendly; uncheck 시 삭제 금지 |
| `plan_completion_events` | 1 per finished run |
| Archive | Destructive delete 아님 |

## Remaining work

Push/restore E2E · app-start sync UX · explicit error states · conflict policy before auto merge

## 관련 문서

`docs/DATA_MODEL.md` · `docs/AUTH_AND_API.md` · `docs/ARCHITECTURE.md`
