# Architecture

시스템 맵. 코드 변경 전 **어느 파일을 볼지** 빠르게 찾기 위한 문서.

## Runtime

```text
Flutter mobile
  → Drift / SQLite (local-first)
  → Supabase Auth
  → Next.js API (optional, authenticated)

Next.js web/API/admin
  → Supabase JWT verify
  → Supabase Postgres (Hyperdrive on Cloudflare)
  → Cloudinary (admin media)
```

모바일은 **offline-first**. Home·Read는 local state 먼저 렌더. API는 short timeout + reachability cache. **Mobile은 Postgres에 직접 연결하지 않음.**

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
| `lib/core/api/` | API client, timeout, reachability |
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
| `src/lib/plans.ts` · `content.ts` · `today-messages.ts` | Catalog CRUD |
| `src/lib/sync/reading-sync.ts` | Compact backup |
| `src/lib/db/postgres.ts` | Postgres client |
| `supabase/migrations/` | Server schema source |

## Data flow 요약

**Reading progress:** tap chapter → Drift transaction → `chapter_progress_entries` + `reading_activities` → UI refresh. 100% → `completion_ready` → confirm → `plan_completion_events`.

**Plan catalog:** Admin publish → Supabase → `GET /api/v1/plans` → mobile cache → Start Plan → local `user_plan_chapters` snapshot.

**Today's Message:** Admin publish → `GET /api/v1/today-message` → Home (cache → fallback). Lookup: latest where `publish_date <= date`.

**Discover:** Admin content → `GET /api/v1/content` → online-only list/detail sheet.

**Auth & backup:** Google → Supabase Auth → `POST /api/v1/auth/sync` → optional `sync/push` · restore via `sync/bootstrap` → `user_plan_chapters` local regenerate.

## Boundaries

- Backup/restore = account recovery, not live sync
- `user_plan_chapters` = local derived, backup 미포함
- Discover enabled · Saved/List hidden (MVP)
- Auto merge / conflict UI 미구현

## 관련 문서

`docs/DATA_MODEL.md` · `docs/AUTH_AND_API.md` · `docs/SYNC_STRATEGY.md` · `docs/DEVELOPMENT.md`
