# Data Model

데이터 모델 **소스 오브 트루스**. 스키마 변경 전 참고.

## Schema sources

| Layer | Source |
| --- | --- |
| Mobile (Drift v3) | `apps/mobile/lib/core/database/app_database.dart` |
| Server | `supabase/migrations/` (baseline: `20260528000000_baseline.sql`) |
| Reference mirror | `apps/web/db/schema.sql` |

MVP 중 stale local data → 앱 삭제/reinstall 또는 simulator reset.

## 개념 분리

```text
plan_templates (+ sections, items)     ← catalog (server)
contents (+ author, tags, assets)      ← Discover content (server)
user_reading_plans                     ← user's plan run (local)
  → user_plan_chapters                 ← local derived (offline UI, denominator)
  → chapter_progress_entries           ← mutable progress
  → reading_activities                 ← streak / reading-day (append-friendly)
  → plan_completion_events             ← 1 per finished run
```

- Template edit는 **이미 시작한 run**을 rewrite하지 않음
- Compact backup은 derived chapter row를 **저장하지 않음**
- Today's Message는 daily Home slot (`today_messages`). optional `content_id` → `contents`; hint + verse only on TM. Plans via `content_plan_links`, not direct TM FK.

## Local tables (mobile)

| Table | Role |
| --- | --- |
| `bible_books` | Book metadata (`bible_books.en.json`) |
| `bible_chapters` | 1,189 chapters — `verse_count`, `estimated_reading_seconds` (= ×7), `estimated_reading_minutes` |
| `local_users` | Guest/authenticated, `auth_user_id` after sign-in |
| `plan_templates` * | Cached from server catalog |
| `user_reading_plans` | Plan run — `active` / `completion_ready` / `completed` / archived |
| `user_plan_chapters` | **Local derived only** — ordering, sections, progress denominator |
| `chapter_progress_entries` | Current check state per chapter |
| `reading_activities` | Activity history (uncheck해도 activity 삭제 안 함) |
| `plan_completion_events` | Completion history (`unique(user_plan_id)`) |
| `app_settings` | Key/value flags (sync time, today message heart/save, etc.) |

\* template sections/items도 local cache

`bible_chapters.json` 재생성: `pnpm run bible-chapters:generate`

## Server tables (Supabase)

| Group | Tables |
| --- | --- |
| Identity | `auth.users`, `profiles` |
| Plan catalog | `plan_templates`, `plan_template_sections`, `plan_template_items`, `plan_tags`, `plan_template_tags` |
| Content catalog | `content_authors`, `contents`, `content_assets`, `content_sections`, `content_tags`, `content_tag_links`, `content_plan_links` |
| Today's Message | `today_messages`, `media_assets` — `unique(publish_date, language)`. Fields: verse, image, share image, hint, optional `content_id`. No `article_*`, no direct plan FK. |
| Backup | `user_reading_backups` — 1 compact JSON row per user |
| Feedback | `feedback_messages` |

**`contents.content_type`:** `message`, `video`, `essay`, `cartoon`

**Public reads:** `GET /api/v1/plans`, `/content`, `/today-message` — Web + mobile API fallback

**Mobile Supabase RPC (anon/authenticated execute):**

| Function | Returns | Notes |
| --- | --- | --- |
| `mobile_today_message_latest(p_language, p_date?)` | TM JSON (matches API `message`) | published only; includes `linked_content` |
| `mobile_content_list(...)` | content array | no `body`/assets/sections in list payload |
| `mobile_content_detail(p_identifier, p_language?)` | content object | full nested detail |
| `mobile_plan_catalog(p_sort?)` | plan array | summary-only (`plan_templates` rows) |
| `mobile_plan_detail(p_identifier)` | plan object | sections/items/tags nested |

RPC output shapes mirror existing mobile DTOs / API JSON. Base tables are not granted to anon.

## Plans UI mapping

| UI | Local condition |
| --- | --- |
| My Plans → Current | `active` / `completion_ready`, not archived |
| Completed | `plan_completion_events` |
| Archived | `archived_at` set — progress preserved |
| Catalog Continue | template에 active run 존재 |
| Catalog Start Again | completed history, no current run |

## Consistency notes

- Mobile writes local first; backup is secondary authenticated path via Next.js API
- `reading_activities` → streak / reading calendar (habit layer)
- Mobile public catalog/content may use Supabase RPC; sensitive tables stay API-only

## 관련 문서

`docs/SYNC_STRATEGY.md` · `docs/ARCHITECTURE.md` · `apps/web/db/seeds/PLAN_CATALOG.md`
