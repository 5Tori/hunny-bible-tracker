# Architecture

시스템 맵. 코드 변경 전 **어느 파일을 볼지** 빠르게 찾기 위한 문서.

## Runtime

```text
Flutter mobile
  → Drift / SQLite (local-first)
  → Supabase Auth
  → Supabase RPC (approved public read-only catalog/content)
  → Next.js API (fallback, heart/share, sync, admin)

Next.js web/API/admin
  → Supabase JWT verify
  → Supabase Admin REST (profiles, backup, today-message counters)
  → Supabase Postgres via Hyperdrive (admin CRUD, catalog SQL reads)
  → Cloudinary (admin media)
```

모바일은 **offline-first**. Home·Read는 local state 먼저 렌더. Public read는 Supabase RPC(기본 closed test) 또는 API fallback. Sync/heart/share는 API + short timeout + reachability cache.

**Guardrail:** Mobile must not access sensitive user/admin tables directly. Mobile may use approved Supabase RPC for public read-only catalog/content. Reading progress remains local-first.

## Apps

| Path | Role |
| --- | --- |
| `apps/mobile` | Flutter iOS/Android |
| `apps/web` | Next.js public · API · Admin |

## Mobile — 주요 경로

| Path | Role |
| --- | --- |
| `lib/core/database/app_database.dart` | Drift schema |
| `lib/core/auth/` | Supabase Auth |
| `lib/core/supabase/` | RPC read layer, `HUNNY_REMOTE_READ_MODE` |
| `lib/core/api/` | API client, timeout, reachability (heart/share, sync fallback) |
| `lib/features/root/root_shell.dart` | Tab shell: Home, Discover, Read, Settings |
| `lib/features/home/` | Today's Message, progress |
| `lib/features/find/` | Discover |
| `lib/features/read/` | Read, `ReadRepository`, sync payload |
| `lib/features/plans/` | Plan Manager |
| `lib/features/settings/` | Account, backup, feedback |
| `assets/data/bible_books.en.json` · `bible_chapters.json` | Book/chapter metadata |

## Web — 주요 경로

| Path | Role |
| --- | --- |
| `src/app/(public)/` | Landing, privacy, terms, support |
| `src/app/(browse)/` | Today message, Discover, content pages |
| `src/app/admin/` | Admin dashboard |
| `src/app/api/` | Public + admin API routes |
| `src/lib/auth/auth-user-sync.ts` | Profile upsert (Supabase Admin REST) |
| `src/lib/sync/reading-sync.ts` | Compact backup (Supabase Admin REST) |
| `src/lib/today-messages.ts` | Catalog CRUD + engagement increment (REST for heart/share) |
| `src/lib/db/postgres.ts` | Postgres client (Hyperdrive; admin/catalog reads) |
| `supabase/migrations/` | Server schema source |

## Data flow 요약

**Reading progress:** tap chapter → Drift transaction → `chapter_progress_entries` + `reading_activities` → UI refresh. 100% → `completion_ready` → confirm → `plan_completion_events`.

**Today's Message:** Admin publish → Supabase RPC or `GET /api/v1/today-message` → Home (cache → fallback). Lookup: latest where `publish_date <= date`. **Slot links one Message Card (`content_type = message`) via `content_id`; verse/image/context/hint are owned by the card and hydrated onto the slot.** Refactor memo: `docs/to-do/CONTENT_REFACTOR_MEMO.md`.

**Discover:** Admin content → Supabase RPC or `GET /api/v1/content` → online-only list/detail sheet.

**Plan catalog:** Admin publish → Supabase RPC or `GET /api/v1/plans` → mobile cache → Start Plan → local `user_plan_chapters` snapshot.

**Auth & backup:** Google → Supabase Auth → `POST /api/v1/auth/sync` → optional `sync/push` · restore via `sync/bootstrap` → `user_plan_chapters` local regenerate. Settings 탭 **SYNC** 섹션에서 Sync now / Restore.

**Today's Message engagement:** Heart (one-way, local + server increment) · Save (local toggle) · Share (native sheet + server increment).

## Boundaries

- Backup/restore = account recovery, not live sync
- `user_plan_chapters` = local derived, backup 미포함
- Discover enabled · Saved/List hidden (MVP)
- Auto merge / conflict UI 미구현

## 관련 문서

`docs/DATA_MODEL.md` · `docs/AUTH_AND_API.md` · `docs/SYNC_STRATEGY.md` · `docs/DEVELOPMENT.md`
