# Content Refactor Memo

**목적:** 리팩토링 방향을 한곳에 모아 두었다가, 나중에 까먹지 않고 같은 원칙으로 적용하기 위한 운영 메모.

**사용법:** 새 기능·마이그레이션·Admin UI 작업 전에 이 문서의 **확정(Confirmed)** 섹션을 먼저 읽는다. 아직 확정되지 않은 항목은 **TBD**에만 적는다.

**관련 문서**

| 문서 | 역할 |
| --- | --- |
| [`message-card-library-plan.md`](./message-card-library-plan.md) | Message Card Library 제품·taxonomy·로드맵 (장기) |
| [`TODAY_MESSAGE_CONTENT_PLAN.md`](./TODAY_MESSAGE_CONTENT_PLAN.md) | 구 Today+Content 리디자인 (일부 superseded — 아래 Confirmed 우선) |
| [`CURRENT_FOCUS.md`](./CURRENT_FOCUS.md) | 지금 하는 일 |
| [`../DATA_MODEL.md`](../DATA_MODEL.md) | 스키마 요약 |

---

## 1. Confirmed — Message Card ↔ Today's Message

### 한 줄 정의

```text
Message Card = 재사용 가능한 말씀 카드 콘텐츠 (contents, content_type = message)
Today's Message = 날짜별 daily featured slot (today_messages) — 하루에 Message Card 하나를 가리킴
```

**Today's Message는 기능의 중심이 아니라, Message Card Library에서 매일 하나를 보여주는 슬롯이다.**

### 관계 diagram

```text
Message Card (contents.content_type = message)
  ├─ verse, image, context, hint  ← 카드에서 작성·소유
  ├─ taxonomy (category, situations, tags)
  ├─ related plans (content_plan_links)
  └─ public: /messages/[slug]

Today's Message slot (today_messages)
  ├─ publish_date + language        ← 스케줄 식별 (unique)
  ├─ content_id → Message Card      ← 필수 (슬롯의 유일한 콘텐츠 연결)
  ├─ is_published                   ← 그날 공개 여부
  └─ heart_count / share_count      ← 슬롯 단위 engagement (유지)

Discover content (video | essay | cartoon)
  └─ Today slot과 별개 — /admin/discover, Discover 탭용
```

### 소유권 규칙 (Single source of truth)

| 데이터 | 작성·수정 위치 | Today slot에서 |
| --- | --- | --- |
| 구절 reference / version / text | Message admin | **편집 금지** — 링크 시 hydrate |
| 카드 이미지 (`cover_image_*`) | Message admin | **편집 금지** — hydrate |
| `context` (짧은 묵상) | Message metadata | **편집 금지** — hydrate |
| `hint` (부드러운 한 줄) | Message metadata | **편집 금지** — hydrate → `hint_summary` |
| `contents.summary` | **사용 안 함 (message)** | Discover(`video`/`essay`/`cartoon`)만 — message는 `metadata.context`만 |
| Category / situations / tags | Message admin + taxonomy | Today와 무관 |
| Related plans | Message admin (`content_plan_links`) | Today에 직접 FK **없음** |
| `publish_date`, `language` | Today admin | **슬롯만** |
| Home 노출 (live) | Message Card `is_published` | Today 슬롯 publish 토글 **없음** — 카드 Published면 live |

**Admin Today editor 입력 필드 (확정):** `content_id`, `publish_date`, `language` 만.

**Admin Message editor:** Published 토글이 Today picker 후보 + slot live 자격을 결정 (`isTodayEligible` **사용 안 함**). verse, image, context, hint, classification, plans, author 등 카드 본문도 Message admin에서 작성.

### 런타임 동작 (확정)

1. **저장 시** — `today-messages.ts` `normalizeInput()`이 `content_id`로 Message Card를 읽고, verse/image/hint 등을 **슬롯 row에 denormalize**해서 저장한다. (`content_type !== 'message'`이면 거부)
2. **공개 API** — `GET /api/v1/today-message`는 슬롯 row + `linked_content`(slug, taxonomy, related plans, `context`)를 반환. Home/Mobile은 카드 필드만으로도 렌더 가능해야 한다.
3. **Live 판단** — Today slot은 linked Message Card가 `is_published`이면 Home에 노출. 별도 Today-eligible 플래그 없음.
4. **언어** — 슬롯 `language`와 카드 `language` 불일치 시 Admin 경고 (차단은 아직 optional).

### 스케줄 UX (확정)

- Admin **`/admin/today-messages`**: 월간 **캘린더 + 리스트**, language 필터, 날짜별 미리 지정.
- 빈 날 → Published Message Card 선택해 슬롯 생성. 기존 슬롯 → 카드 변경.
- 카드가 Draft면 캘린더에 “Draft card”로 표시되고 Home에는 노출되지 않음.
- 에디터 진입: `?publish_date=&language=` 로 날짜·언어 고정, 저장 후 캘린더로 복귀 (`?month=&date=`).

### 하지 않는 것 (확정)

- Today slot에서 verse/image/context/hint **직접 입력 UI** 다시 만들지 않음.
- `today_messages.primary_related_plan_template_id` **복구하지 않음** — plan은 Message Card → `content_plan_links` 경로만.
- Today slot이 essay/video/cartoon에 `content_id` 연결 **하지 않음** (message card only).
- Today slot을 두 번째 CMS(긴 본문, article body)로 쓰지 않음.

### DB 현실 (아직 denormalize 유지)

`today_messages` 테이블에는 여전히 `verse_*`, `image_*`, `hint_*` 컬럼이 있다. **의도:** mobile RPC / 캐시 / 기존 read path 호환.  
**원칙:** Admin·제품 UX 기준으로는 Message Card가 source of truth; 슬롯 컬럼은 **파생 캐시**로 취급.

향후 (TBD): 슬롯 row를 `content_id` + schedule + counters만 남기고 read path에서 join/hydrate만 하는 스키마 슬림화 검토.

---

## 2. Confirmed — Discover content 분리

Message Card와 Discover용 long-form/media 콘텐츠는 **Admin·라우트·타입**을 분리한다.

| | Message Card | Discover content |
| --- | --- | --- |
| `content_type` | `message` | `video`, `essay`, `cartoon` |
| Admin | `/admin/messages` | `/admin/discover` |
| Public | `/messages` | `/content/[slug]`, Discover |
| Today slot | **연결 대상** | **연결 안 함** |

레거시 `/admin/content` → discover로 redirect.

---

## 3. Implemented (web, offline-first 기준)

아래는 **로컬 mock + Admin UI** 기준으로 이미 맞춰 둔 것. live DB 재연결 시 같은 규칙이 적용되는지 smoke 필요.

| 영역 | 상태 | 핵심 파일 |
| --- | --- | --- |
| Message public UI | ✓ | `components/messages/*`, `/messages` |
| Message admin editor | ✓ | `MessageCardEditor.tsx`, verse picker |
| Today = picker only | ✓ | `TodayMessageEditor.tsx`, `normalizeInput()` |
| Today schedule calendar | ✓ | `TodayScheduleCalendar.tsx`, `TodayScheduleList.tsx` |
| Discover admin 분리 | ✓ | `DiscoverContentEditor.tsx`, `/admin/discover` |
| Metadata `context` / `hint` | ✓ | `message-metadata.ts` |
| Message `summary` deprecated | ✓ | save → `null`; display → `metadata.context` only |
| Mock message seeds | ✓ | `MessageCardSeed` in `fixtures/contents.ts` |
| Mock offline CRUD | ✓ | `lib/mock/store.ts`, `HUNNY_OFFLINE_MODE=1` |

---

## 4. TBD — 다음에 정리·적용할 방향

아직 **확정 메모에 올리지 않은** 항목. 결정되면 위 Confirmed 섹션으로 승격.

### 4.1 Live DB / mobile 재정렬

- [ ] Hyperdrive/Supabase reconnect 후 Admin save + public API smoke
- [ ] Mobile Home DTO가 `context`/`hint` + message-card-only Today 모델과 일치하는지 점검
- [ ] `TODAY_MESSAGE_CONTENT_PLAN.md`의 “Today → generic content” 서술과 충돌하는 mobile/web 잔여 코드 정리

### 4.2 스키마·API 슬림화

- [ ] `today_messages` denormalized 컬럼 제거 여부 (join-only read)
- [ ] `hint_title` on slot vs `hint` on card — slot 쪽 deprecated 정리
- [ ] Public API `linked_content` shape: message card 전용 필드만 vs legacy generic content 필드

### 4.3 제품·운영

- [ ] Mobile Discover에 Message Card Library 섹션 (`message-card-library-plan.md` Phase 5)
- [ ] Seed/카탈로그 운영 (`PLAN_CATALOG.md`, message cards bulk seed)
- [ ] Analytics 이벤트 (`message_card_open`, `today_message_share`, …)

---

## 5. 적용 체크리스트 (PR 전)

새 코드·마이그레이션이 아래를 어기면 리팩토링 방향과 어긋난다.

- [ ] Today admin에 verse/image/body 입력 필드를 추가하지 않았는가?
- [ ] Today slot `content_id`가 `content_type = message`만 가리키는가?
- [ ] Plan 연결을 `today_messages` FK가 아닌 Message Card `content_plan_links`로 했는가?
- [ ] Discover 타입을 Message admin과 섞지 않았는가?
- [ ] 공개 Today UI가 linked Message Card 없이도 verse+image로 동작하는가?

---

## 6. Key file map

| 역할 | Path |
| --- | --- |
| Today slot lib + hydrate | `apps/web/src/lib/today-messages.ts` |
| Message card lib | `apps/web/src/lib/messages.ts` |
| Message metadata | `apps/web/src/lib/message-metadata.ts` |
| Discover types | `apps/web/src/lib/discover-content.ts` |
| Today schedule UI helpers | `apps/web/src/lib/today-schedule-ui.ts` |
| Today admin calendar | `apps/web/src/components/admin/today-messages/*` |
| Today admin editor | `apps/web/src/components/admin/editors/today-message/TodayMessageEditor.tsx` |
| Message admin editor | `apps/web/src/components/admin/editors/message/MessageCardEditor.tsx` |
| Discover admin editor | `apps/web/src/components/admin/editors/discover/DiscoverContentEditor.tsx` |
| Mock store (offline) | `apps/web/src/lib/mock/store.ts` |

---

## 7. Changelog (memo)

| Date | Note |
| --- | --- |
| 2026-05-29 | Today-eligible 제거 — Published message card = Today picker + slot live 기준 |
