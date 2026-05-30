# Hunny Bible Tracker — Supabase-first Hybrid Refactoring Plan

_Last updated: 2026-05-29_

## 0. Executive Summary

테스트 결과 현재 데이터 통신 속도가 체감상 느리다면, 기존의 **Mobile → Next.js API → Supabase Postgres** 구조를 일부 유지하되, 모바일의 public read 경로는 더 빠르고 단순한 **Supabase RPC/View 직접 조회**로 옮기는 것이 가장 현실적인 리팩토링 방향이다.

최종 추천 구조는 다음과 같다.

```text
Mobile
  -> Drift / SQLite local-first for reading progress
  -> Supabase Auth for identity
  -> Supabase RPC/View for public read content
  -> Supabase Edge Function for sync backup, if proven useful
  -> No direct table access to sensitive/user tables

Web/Admin
  -> Cloudflare Workers + Next.js
  -> Supabase Postgres via Hyperdrive
  -> Cloudinary for admin-managed media
  -> Admin/server-only logic stays here

Public Web
  -> Cloudflare-rendered pages
  -> cacheable content/share/SEO pages
```

핵심 원칙은 다음이다.

```text
읽기 습관 데이터 = local-first
콘텐츠 조회 = Supabase RPC/View direct read 가능
관리자 / 웹 / SEO = Cloudflare 유지
복잡한 서버 작업 = Edge Function 또는 Cloudflare API
```

이 계획은 “API를 완전히 제거”하는 것이 아니라, 각 레이어가 가장 잘하는 일을 맡도록 역할을 재분배하는 리팩토링이다.

---

## 1. Why Refactor

### 현재 문제

현재 구조는 안전하고 관리하기 쉽지만, 모바일에서 서버 콘텐츠를 가져올 때 다음 경로를 거친다.

```text
Flutter Mobile
  -> Next.js API on Cloudflare Workers
  -> Supabase Postgres via Hyperdrive
```

이 구조는 다음 장점이 있다.

- DB 스키마를 모바일에서 숨길 수 있음
- API payload shape를 서버에서 통제 가능
- public / admin / draft / archived 데이터를 분리하기 쉬움
- 웹과 모바일이 같은 API 계약을 공유 가능

하지만 실제 테스트에서 느리다면 다음 병목 가능성이 있다.

- Worker hop 추가
- Worker → Supabase query latency
- payload가 필요 이상으로 큼
- list/detail endpoint 분리가 불충분함
- 앱 시작 또는 Home refresh가 API 응답을 기다림
- public read 데이터에 Cloudflare cache가 충분히 적용되지 않음
- 모바일이 같은 데이터를 반복 fetch함

### 바뀐 제품 구조와의 관계

Hunny는 이제 단순 reading tracker가 아니라 다음 흐름을 가진다.

```text
Today's Message
  -> Content
  -> Related Plan
  -> Read / Track
```

이 구조에서는 `today-message`, `content`, `plan catalog`가 모바일에서 자주 조회되는 public read 데이터가 된다. 이 영역은 사용자 개인 데이터가 아니므로, 적절히 제한된 View/RPC를 통해 Supabase에서 직접 읽는 전략을 검토할 수 있다.

---

## 2. Final Recommendation

### 유지할 것

#### 2.1 Reading progress는 계속 local-first

아래 데이터는 네트워크를 기다리지 않고 로컬에서 즉시 처리한다.

- chapter check / uncheck
- reading activity
- streak
- today read minutes
- reading calendar
- plan completion event
- active/current/archived plan state

권장 경로:

```text
Flutter UI
  -> Drift / SQLite transaction
  -> UI update immediately
  -> optional backup later
```

이유:

- Read flow는 앱 핵심 경험
- 오프라인에서도 동작해야 함
- 체크박스 UX는 즉시 반응해야 함
- 네트워크 기반으로 바꾸면 습관 트래커 경험이 나빠짐

#### 2.2 Web/Admin은 Cloudflare + Next.js 유지

아래 기능은 계속 Cloudflare Workers / Next.js 쪽에 둔다.

- public website
- SEO / share pages
- admin dashboard
- Cloudinary upload
- admin authorization
- sitemap / metadata
- server-rendered content pages
- one-off management API

이유:

- Admin은 service-role 성격의 작업이 섞일 수 있음
- Cloudinary secret은 서버에서만 다뤄야 함
- public web page는 SEO와 metadata가 중요함
- share page는 Cloudflare에서 캐시하기 좋음

### 바꿀 것

#### 2.3 모바일 public read를 Supabase RPC/View로 전환

대상:

- latest Today's Message
- Today's Message list
- Content list
- Content detail
- Plan catalog
- Plan detail, if needed

권장 경로:

```text
Flutter Mobile
  -> supabase_flutter
  -> Supabase RPC or read-only View
  -> mapped DTO
  -> local cache where useful
```

중요:

- 테이블 직접 select를 기본으로 하지 않는다.
- 모바일 전용 RPC/View를 만든다.
- RPC/View는 public/draft/admin 필드를 숨긴다.
- Flutter는 안정적인 contract만 의존한다.

#### 2.4 Sync backup은 Edge Function 후보

읽기 backup/restore는 지금 당장 옮기지 않아도 되지만, 후보로 둔다.

권장 후보:

```text
Flutter
  -> Supabase Edge Function
  -> user_reading_backups
```

단, 현재 compact backup이 충분히 빠르면 굳이 옮기지 않는다.

---

## 3. Target Architecture

## 3.1 Mobile Architecture

```text
Flutter App

Local core:
  Drift / SQLite
    - local_users
    - user_reading_plans
    - user_plan_chapters
    - chapter_progress_entries
    - reading_activities
    - plan_completion_events
    - app_settings

Remote public read:
  Supabase RPC/View
    - mobile_today_message_latest
    - mobile_today_message_list
    - mobile_content_list
    - mobile_content_detail
    - mobile_plan_catalog

Remote auth:
  Supabase Auth

Remote backup:
  Phase 1: existing Next.js API
  Phase 2 candidate: Supabase Edge Function
```

## 3.2 Web/Admin Architecture

```text
Cloudflare Workers + Next.js
  - public web pages
  - admin dashboard
  - share/SEO pages
  - Cloudinary upload
  - admin-only CRUD

Supabase Postgres
  - content data
  - plan catalog
  - today messages
  - compact backup

Hyperdrive
  - Cloudflare -> Supabase DB connection path
```

## 3.3 Data Ownership

| Data | Owner | Access path |
| --- | --- | --- |
| Reading progress | Mobile local DB | Drift first, backup later |
| Plan catalog | Supabase | Mobile RPC/View, Web API/Admin |
| Today's Message | Supabase | Mobile RPC/View, Web pages/API/Admin |
| Content | Supabase | Mobile RPC/View, Web pages/API/Admin |
| Admin media | Cloudinary | Web/Admin only |
| Backup snapshot | Supabase | API or Edge Function |
| Auth identity | Supabase Auth | Mobile + Web/Admin |

---

## 4. What Not To Do

Do not switch everything to direct Supabase table access.

Avoid:

```text
Flutter -> supabase.from('contents').select('*, sections(*), assets(*), tags(*), plans(*)')
```

Reason:

- Flutter becomes tightly coupled to schema
- RLS complexity increases
- hidden/draft/admin fields may leak if policy is wrong
- future schema changes require mobile release coordination

Instead:

```text
Flutter -> rpc('mobile_content_detail', { slug })
```

or:

```text
Flutter -> from('mobile_content_detail_view').select(...)
```

Do not move admin writes to mobile/client-side direct DB access.

Do not move reading progress live sync to Supabase tables yet.

Do not expose `user_reading_plans`, `chapter_progress_entries`, `reading_activities`, or `user_reading_backups` to direct mobile table access in the first phase.

---

## 5. Refactoring Phases

## Phase 0 — Baseline Performance Measurement

**Status: complete** (2026-05-30) — see `docs/to-do/API_PERFORMANCE_BASELINE.md` and commit `2f8119c` instrumentation.

### Goal

Before changing architecture broadly, measure where the app is actually slow.

### Tasks

1. Add lightweight timing logs around current mobile API calls.
2. Add route duration logs to current web API endpoints.
3. Measure payload size for key endpoints.
4. Measure app startup path and whether UI waits on network.
5. Document baseline numbers.

### Endpoints to measure

| Endpoint | Reason |
| --- | --- |
| `/api/health` | reachability baseline |
| `/api/v1/today-message` | Home critical path |
| `/api/v1/content` | Discover list |
| `/api/v1/content/[identifier]` | content detail |
| `/api/v1/plans` | plan catalog |
| `/api/v1/sync/push` | backup |
| `/api/v1/sync/bootstrap` | restore |

### Deliverable

Create or update:

```text
docs/to-do/API_PERFORMANCE_BASELINE.md
```

Include:

- endpoint
- average response time
- slowest response time
- payload size
- mobile screen affected
- current cache behavior

### Acceptance Criteria

- Baseline data exists.
- Slow endpoints are identified.
- We know whether the problem is network hop, DB query, payload size, or mobile blocking.

---

## Phase 1 — Architecture Decision Update

### Goal

Update project docs so the new direction is explicit.

Current docs say mobile should not access Supabase Postgres directly. That should be refined, not simply deleted.

### New guardrail wording

Use this direction:

```text
Mobile must not access sensitive user/admin tables directly.
Mobile may use approved Supabase RPC/View endpoints for public read-only catalog/content data.
Reading progress remains local-first and syncs through controlled backup endpoints.
```

### Docs to update

- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/AUTH_AND_API.md`
- `docs/DATA_MODEL.md`
- `docs/SYNC_STRATEGY.md`
- `docs/PRODUCT_ROADMAP.md`
- `docs/to-do/CURRENT_FOCUS.md`

### Acceptance Criteria

- Docs no longer imply all mobile remote reads must go through Next.js API.
- Docs still prohibit sensitive direct table access.
- The hybrid model is clear.

---

## Phase 2 — Create Mobile Read Contracts in Supabase

### Goal

Add stable RPC/View contracts for mobile public read data.

### Preferred contract style

Use SQL functions returning JSONB or stable rows.

Recommended functions:

```sql
mobile_today_message_latest(p_language text, p_date date)
mobile_today_message_list(p_language text, p_limit int, p_offset int)
mobile_content_list(p_language text, p_type text, p_search text, p_limit int, p_offset int)
mobile_content_detail(p_identifier text, p_language text)
mobile_plan_catalog(p_language text)
mobile_plan_detail(p_identifier text)
```

Alternative:

- `mobile_*` read-only views for simple list queries
- RPC for nested/detail payloads

### Security principles

- Only published data.
- Exclude archived data.
- Exclude admin-only fields.
- Exclude draft/unpublished content.
- Use stable JSON shape.
- Grant execute/select only to `anon` or `authenticated` as appropriate.
- Do not expose base tables more than necessary.

### Suggested RPC output shapes

#### `mobile_today_message_latest`

```json
{
  "id": "uuid",
  "publish_date": "2026-05-29",
  "language": "en",
  "verse_reference": "John 3:16",
  "bible_version": "NIV",
  "verse_text": "...",
  "image_url": "...",
  "share_image_url": "...",
  "hint_title": "...",
  "hint_summary": "...",
  "content_id": "uuid",
  "linked_content": {
    "id": "uuid",
    "slug": "why-did-jonah-run-away",
    "content_type": "essay",
    "title": "Why did Jonah run away?",
    "summary": "...",
    "cover_image_url": "...",
    "related_plans": []
  },
  "heart_count": 0,
  "share_count": 0
}
```

#### `mobile_content_detail`

```json
{
  "id": "uuid",
  "slug": "why-did-jonah-run-away",
  "content_type": "essay",
  "language": "en",
  "title": "Why did Jonah run away?",
  "subtitle": "...",
  "summary": "...",
  "body": "...",
  "cover_image_url": "...",
  "author": {},
  "sections": [],
  "assets": [],
  "tags": [],
  "related_plans": [],
  "linked_today_messages": []
}
```

### Files / areas

- `supabase/migrations/`
- `apps/web/db/schema.sql` mirror
- optional `docs/DATA_MODEL.md`

### Acceptance Criteria

- RPC/View contracts exist.
- They return only published/browse-safe data.
- They are callable with anon/authenticated client as intended.
- They do not expose user reading data.

---

## Phase 3 — Mobile Supabase Read Client

### Goal

Add a new mobile data access layer for Supabase public read RPCs.

### New files suggested

```text
apps/mobile/lib/core/supabase/hunny_supabase_client.dart
apps/mobile/lib/core/supabase/supabase_read_exception.dart
apps/mobile/lib/features/home/data/today_message_supabase_client.dart
apps/mobile/lib/features/content/data/content_supabase_client.dart
apps/mobile/lib/features/plans/data/plan_catalog_supabase_client.dart
```

### Rules

- Keep existing API clients temporarily.
- Add feature flag or config switch.
- Allow fallback to existing Next.js API while testing.
- Do not change reading progress writes.
- Do not direct-query sensitive tables.

### Feature flag examples

```text
HUNNY_REMOTE_READ_MODE=api
HUNNY_REMOTE_READ_MODE=supabase_rpc
```

or compile-time dart define:

```json
{
  "HUNNY_REMOTE_READ_MODE": "supabase_rpc"
}
```

### Fetch fallback strategy

```text
1. Try Supabase RPC
2. If fails and API fallback enabled, call existing Next.js API
3. If both fail, render cached local data / offline state
```

### Acceptance Criteria

- Mobile can fetch Today's Message through Supabase RPC.
- Existing API path can still be used during testing.
- Failure does not block Home/Read startup.
- No reading progress code is migrated.

---

## Phase 4 — Switch Today's Message First

### Why first

Today's Message is Home-facing, high-value, and relatively contained.

### Tasks

1. Build `TodayMessageSupabaseClient`.
2. Map RPC JSON to existing or updated Today’s Message model.
3. Preserve local cache behavior.
4. Preserve offline fallback.
5. Measure API mode vs RPC mode.
6. Keep `share_image_url` behavior unchanged.

### Success Metrics

- Home loads faster or no slower.
- RPC response is stable.
- Offline fallback still works.
- Linked content summary can be displayed later.

### Acceptance Criteria

- Today’s Message can load via Supabase RPC.
- Existing API mode can still be enabled if needed.
- No crash when RPC returns no row.
- No mobile direct base table query is used.

---

## Phase 5 — Switch Content List / Detail

### Goal

Improve Discover/content loading speed.

### Tasks

1. Add `ContentSupabaseClient`.
2. Fetch content list via `mobile_content_list`.
3. Fetch content detail via `mobile_content_detail`.
4. Keep Discover online-only behavior.
5. Reuse related plan DTO mapping.
6. Compare latency with Next.js API.

### Watch outs

- Content detail payload can become large.
- Sections/assets/tags should be carefully shaped.
- Avoid over-fetching in list endpoint.
- List endpoint should not include full body.

### Acceptance Criteria

- Discover list loads via RPC.
- Content detail loads via RPC.
- Related plans still display.
- Payload size is reasonable.

---

## Phase 6 — Switch Plan Catalog

### Goal

Move plan catalog public read to Supabase RPC/View.

### Tasks

1. Add `PlanCatalogSupabaseClient`.
2. Fetch published/browse-visible plans.
3. Fetch detail only when needed.
4. Preserve local cache into Drift if the app currently caches catalog locally.
5. Keep user plan runs local-first.

### Important

Do not let mobile write to `plan_templates`.
Do not write user reading plan progress directly to Supabase tables.

### Acceptance Criteria

- Plan catalog reads via Supabase RPC/View.
- Start Plan still creates local user plan run.
- Offline behavior remains as good or better.

---

## Phase 7 — Evaluate Sync Backup Edge Function

### Goal

Decide whether backup/restore should move from Next.js API to Supabase Edge Functions.

### Current behavior

```text
Mobile -> Next.js API -> user_reading_backups
```

Candidate:

```text
Mobile -> Supabase Edge Function -> user_reading_backups
```

### When to move

Move only if:

- current sync API is measurably slow
- Worker/Hyperdrive path is the bottleneck
- Edge Function reduces latency or simplifies auth
- payload validation can be maintained cleanly

### Edge Function candidates

- `sync-reading-backup-push`
- `sync-reading-backup-bootstrap`

### Non-candidates for now

- chapter check/uncheck live writes
- real-time collaborative sync
- direct per-row reading progress sync

### Acceptance Criteria

- Decision documented with measured data.
- If implemented, old API path remains available during rollout.
- Backup payload validation stays strict.

---

## Phase 8 — Retire or Shrink Mobile API Routes

### Goal

Once mobile RPC paths are stable, reduce reliance on mobile-facing Next.js API endpoints.

### Candidates to keep for web/admin

- `/api/v1/admin/*`
- public web rendering helpers
- upload endpoints
- feedback endpoint, if still useful
- share/engagement endpoints, if not moved

### Candidates to retire for mobile only

- `/api/v1/today-message`
- `/api/v1/content`
- `/api/v1/plans`

Do not delete routes until:

- mobile release using RPC is stable
- public web does not depend on the route
- monitoring shows no active usage

### Acceptance Criteria

- API deprecation plan exists.
- Web/Admin remain functional.
- Mobile no longer depends on deprecated endpoints.

---

## 6. Security Plan

## 6.1 RLS / Grant Principles

If mobile uses Supabase direct read, security must be handled at DB contract level.

### Required

- RLS enabled on exposed tables.
- Prefer exposing `mobile_*` views/RPC over raw tables.
- Grant only necessary `select` / `execute` permissions.
- Do not expose draft/admin/private fields.
- Do not expose service role keys to mobile.
- Test anon and authenticated roles separately.

### Suggested policies

For public content base tables, either:

1. Keep base tables protected and expose only RPCs.
2. Or allow select only where `is_published = true` and `is_archived = false`.

Preferred:

```text
RPC/View first, raw table direct access avoided.
```

## 6.2 User Data

Do not expose direct table access for:

- `user_reading_backups`
- `profiles` beyond current user summary
- future user settings tables
- future subscription/account data
- admin tables

---

## 7. Cost / Resource Considerations

## 7.1 Cloudflare usage after refactor

Cloudflare usage should decrease for mobile public read endpoints if mobile moves to Supabase RPC.

Still used for:

- public website
- admin
- SEO/share pages
- Cloudinary uploads
- server-rendered pages

Expected effect:

- fewer mobile API requests to Workers
- lower Worker request/CPU/Hyperdrive query usage for mobile traffic
- Cloudflare remains necessary for web/admin

## 7.2 Supabase usage after refactor

Supabase usage will increase because mobile public reads go directly to Supabase.

Expected increase:

- PostgREST/RPC requests
- DB query load
- bandwidth for JSON payloads
- possibly auth/session usage

Mitigation:

- list/detail payload split
- only published fields
- pagination
- caching in Flutter
- RPC functions optimized with indexes
- avoid repeated fetches

## 7.3 Edge Function cost

Do not move everything to Edge Functions.

Use Edge Functions only for:

- sync backup if measured benefit exists
- future push notifications
- future scheduled jobs
- webhook-like work

If too many Edge Functions are created, we simply recreate an API layer inside Supabase and increase operational complexity.

---

## 8. Risk Analysis

| Risk | Why it matters | Mitigation |
| --- | --- | --- |
| DB schema coupling | Mobile could depend directly on schema details | Use RPC/View contracts |
| RLS mistake | Could expose draft/admin data | Keep raw tables protected; test anon/auth roles |
| Payload bloat | Direct RPC can still be slow if JSON is huge | Split list/detail; minimize fields |
| Dual data access paths | API + RPC can diverge | Feature flag during rollout; retire old path later |
| More Supabase load | Worker load decreases but DB/API load increases | Measure and optimize SQL/functions |
| Sync complexity | Edge migration could break backup/restore | Keep sync API until Edge is proven |
| Offline regressions | Content direct fetch could block UI | Keep Home/Read local-first and cached |
| Admin complexity | Admin should not move client-side | Keep Admin on Cloudflare server/API |

---

## 9. Implementation PR Sequence

## PR 1 — docs: adopt Supabase-first mobile read architecture

Scope:

- Update architecture docs.
- Replace strict “mobile never reads from Supabase” with nuanced rule.
- Document allowed RPC/View public read path.
- Keep sensitive/user tables API/Edge-controlled.

Files:

- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/AUTH_AND_API.md`
- `docs/DATA_MODEL.md`
- `docs/SYNC_STRATEGY.md`
- `docs/PRODUCT_ROADMAP.md`
- `docs/to-do/CURRENT_FOCUS.md`

## PR 2 — db: add mobile public read RPC contracts

Scope:

- Add SQL migration with `mobile_*` RPCs/views.
- Add grants.
- Update schema mirror.
- Add simple SQL smoke checks if project has pattern.

Functions:

- `mobile_today_message_latest`
- `mobile_today_message_list`
- `mobile_content_list`
- `mobile_content_detail`
- `mobile_plan_catalog`

## PR 3 — mobile: add Supabase read client with feature flag

Scope:

- Add `HUNNY_REMOTE_READ_MODE`.
- Add Supabase RPC client wrappers.
- Do not switch screens by default unless configured.
- Add latency debug logs.

## PR 4 — mobile: switch Today’s Message to Supabase RPC

Scope:

- Home Today's Message fetch uses RPC when flag enabled.
- Preserve cache/fallback.
- Compare timing with existing API.

## PR 5 — mobile: switch Discover content to Supabase RPC

Scope:

- Content list/detail use RPC.
- Keep online-only state.
- Preserve related plan behavior.

## PR 6 — mobile: switch plan catalog to Supabase RPC

Scope:

- Plan catalog reads use RPC/View.
- Plan start remains local.

## PR 7 — sync: evaluate Edge Function backup

Scope:

- Only after measurement.
- Implement Edge candidate if beneficial.
- Keep old API fallback temporarily.

## PR 8 — cleanup: retire unused mobile API paths

Scope:

- Remove or deprecate mobile use of old API endpoints.
- Keep web/admin routes as needed.
- Update docs.

---

## 10. Testing Strategy

## 10.1 SQL / Supabase

Test:

- anon can call public RPCs.
- authenticated can call public RPCs.
- unpublished content does not appear.
- archived content does not appear.
- draft Today’s Message does not appear.
- linked content summary only returns published content.
- related plans only include published/browse-visible plans.

## 10.2 Mobile

Test with `HUNNY_REMOTE_READ_MODE=api` and `supabase_rpc`.

Cases:

- fresh install
- Home online
- Home offline
- cached Today’s Message
- no Today’s Message row
- Discover online
- Discover offline
- Content detail with related plan
- Plan catalog
- Start Plan still local
- Restore/sync unaffected

## 10.3 Web/Admin

Test:

- admin still creates content
- admin still creates Today’s Message
- public today page works
- public content page works
- SEO/share pages unaffected

## 10.4 Performance

Measure before/after:

| Flow | Before | After | Target |
| --- | --- | --- | --- |
| Home Today's Message fetch | TBD | TBD | clearly faster or more reliable |
| Discover list fetch | TBD | TBD | faster / smaller payload |
| Content detail fetch | TBD | TBD | stable and not oversized |
| Plan catalog fetch | TBD | TBD | stable |

---

## 11. Acceptance Criteria for the Whole Refactor

The refactor is successful when:

- Reading progress remains local-first.
- Mobile public reads can use Supabase RPC/View.
- No sensitive/user tables are accessed directly from mobile.
- Home/Read offline behavior does not regress.
- Today’s Message loads faster or at least avoids current bottleneck.
- Discover/content loading improves or becomes more predictable.
- Web/Admin remains on Cloudflare and works as before.
- Backup/restore still works.
- Docs clearly explain the new hybrid architecture.
- Old API paths are either retained intentionally or deprecated safely.

---

## 12. Recommended Immediate Next Step

Do **not** start with full migration.

Start with:

```text
PR 1: docs: adopt Supabase-first mobile read architecture
PR 2: db: add mobile_today_message_latest RPC
PR 3: mobile: test Today’s Message RPC behind feature flag
```

This gives the fastest feedback with the lowest risk.

If Today’s Message improves clearly, continue with Content and Plan catalog.

If it does not improve, keep API-first and optimize caching/payload instead.
