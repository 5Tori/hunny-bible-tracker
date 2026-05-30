# Today's Message + Content Redesign Plan

## Goal

**Today's Message** is a lightweight daily Home entry card: image + Scripture verse (required), with optional short hint and optional link to reusable Content. It keeps `publish_date`, `language`, fallback lookup, Home cache, heart/share counters, and local save.

**Content** is the expandable layer for deeper explanation, stories, media, sections, and cartoon slides. It is reusable in Discover, public web pages, and Today's Message.

**Plan** is the reading journey. Users reach plans **through Content** (`content_plan_links`), not through a direct Today's Message → Plan shortcut.

```text
Today's Message = daily entry card (image + verse + optional hint + optional content_id)
Content         = reusable body / media / sections + related plans
Plan            = started from content-related CTA → Read flow
```

Legacy compatibility is **not** a priority. Prefer a clean schema and API over preserving transitional fields.

---

## Updated Product Model

### Stage 1 — Required

Today's Message must have:

- **Image** — `image_url` / `image_public_id` (Home card)
- **Scripture verse** — `verse_reference`, `verse_text` (and optionally `bible_version`)

Minimum viable Home card. Works offline after cache with no linked content.

### Stage 2 — Optional

Today's Message may also have:

- **Hint** — `hint_title`, `hint_summary` (short explanation shown in More / hint area)
- **Linked content** — `content_id` → `contents` (deeper body, media, sections live here)

Long text must **not** live on Today's Message. Content owns body, sections, assets, and video.

### Stage 3 — Optional

If linked content has related plans (`content_plan_links`):

- User can start / subscribe from the **content detail flow**
- Then continue into Read

Plans should **not** be attached directly to Today's Message in the target model.

### Image roles (this phase)

| Field | Role |
| --- | --- |
| `image_url` | Home card / main image |
| `share_image_url` | Mobile sharing / story-style share image (auto-generated today) |

**No dedicated 1200×630 OG image** in this phase. Public web metadata uses `share_image_url` → `image_url` → site default.

---

## Current State

Verified against `supabase/migrations/20260528000000_baseline.sql`, `apps/web/db/schema.sql`, and application code.

### Database schema

#### `today_messages` (actual columns)

| Column | Notes |
| --- | --- |
| `id`, `publish_date`, `language` | Daily slot; `unique (publish_date, language)` |
| `verse_reference`, `bible_version`, `verse_text` | Verse block |
| `message` | Short fallback line; used when `verse_text` absent on mobile |
| `image_url`, `image_public_id` | Home card |
| `share_image_url`, `share_image_public_id` | Stored; regenerated on admin save |
| `hint_title`, `hint_summary` | Short reflection |
| `article_title`, `article_body` | **Legacy lightweight Read More copy — should be removed** |
| `content_id` | Nullable FK → `contents`; **exists but unused in product UX** |
| `primary_related_plan_template_id` | FK → `plan_templates`; **actively used — should be removed** |
| `is_published`, `heart_count`, `share_count` | Publish + engagement |

Indexes exist for publish lookup, engagement, `primary_related_plan_template_id`, and `content_id`.

#### `contents` and related tables

| Table | Role |
| --- | --- |
| `contents` | slug, type (`message`/`video`/`essay`/`cartoon`), title, summary, body, cover, author, verse fields, publish states |
| `content_sections` | Essay sections + inline images |
| `content_assets` | Cartoon panels, gallery, video files |
| `content_tags` / `content_tag_links` | Discover filtering |
| `content_plan_links` | **Target plan relationship** — `relationship_type`, `display_order`, `cta_label` |
| `media_assets` | Cloudinary upload audit (not joined in read paths) |
| `plan_templates` | Catalog with sections/items |

No `contents.share_image_*` columns (not needed this phase).

#### Seeds

- `apps/web/db/seeds/content_test_seed.sql` — Discover content with tags, sections, `content_plan_links`.
- **No** seed links `today_messages.content_id` to content.
- Plan seeds in `supabase/migrations/2026052811000*.sql` + `PLAN_CATALOG.md`.

### API

#### `GET /api/v1/today-message`

- Returns full `today_messages` row.
- Joins plan summary via `primary_related_plan_template_id`: `related_plan_template_key`, `related_plan_title`, `related_plan_chapters`, `related_plan_minutes`.
- Adds computed `share_url` → `/today-message/{publish_date}`.
- **Does not** return `linked_content` summary when `content_id` is set.
- Still exposes `article_title`, `article_body`, `primary_related_plan_template_id`.

#### `GET /api/v1/content` / `[identifier]`

- Full `ContentWithRelations`: author, assets, sections, tags, **related_plans** (published plans only).
- Works end-to-end for Discover and public content pages.

#### Admin today-messages / content / plans

- Today Message CRUD reads/writes all legacy fields including `article_*`, `primary_related_plan_template_id`, `content_id`.
- `share_image_url` auto-built in `today-messages.ts` via `buildTodayMessageShareImageUrl()` (1080×1350 Cloudinary transform from home image + verse).
- Content CRUD supports related plans via `related_plan_ids` / `related_plans`.

### Admin UI

#### Today Message editor (`TodayMessageEditor.tsx`)

Current sections:

- Publish date, language, verse fields, short `message`
- Hint title/summary
- **Article title/body** (should be removed)
- **Related plan dropdown** (should be removed)
- Home image upload + computed share preview
- `content_id` in form state but **no linked-content picker UI**
- Publish toggle

#### Content editor (`ContentEditor.tsx`)

Current sections (aligned with target):

- Type, slug, title/subtitle/summary/body
- Cover upload, author, verse, duration, external URL
- Essay sections, assets, tags
- Related plan checkboxes
- Publish / archive / browse_visible / featured_rank

### Public web

#### `/today-message/[slug]`

- Metadata title/description fall back to **`article_title` / `article_body`** (legacy).
- OG image: `share_image_url || image_url` (no separate OG field — acceptable for this phase).
- Page renders verse, message, hint, **article body**, **direct related plan block**.
- No linked content CTA.

#### `/content/[slug]`

- Full content renderer with sections, assets, video, related plans list (informational only on web).

#### Sitemap

- Static routes only; no today-message or content slug URLs.

### Mobile Home

- **Home card**: image + `verse_text` (fallback `message` → `verse_reference`); hint snippet + "Read more" below actions.
- **More sheet** (`_TodayMessageArticleSheet`): **`articleHeading` / `articleText`** (article or hint fallback); **direct plan CTA** from `primary_related_plan_template_id`.
- **`content_id` parsed but never used** in UI.
- **Share**: server `share_image_url` download → local 1080×1350 canvas fallback.
- **Cache**: full JSON in `app_settings`; offline fallback hard-coded Proverbs message (includes legacy `article_*` placeholders).

### Mobile Content / Discover

- Discover fetches content list + detail sheet with **related plan Start buttons** (works).
- No navigation from Home Today's Message into content detail.
- Content remains online-only.

### Plan linking (current)

| Path | Status |
| --- | --- |
| `today_messages.primary_related_plan_template_id` | Active in API, admin, mobile More sheet, public TM page |
| `content_plan_links` | Active in content API, Discover, content admin |
| `today_messages.content_id` → content plans | **Not wired** |

### Share image behavior (current)

- **Generation**: on admin save, `share_image_url` = Cloudinary transform of `image_public_id` + verse text/reference (4:5, 1080×1350). Stored in DB.
- **Mobile share**: downloads `share_image_url` or draws matching canvas locally.
- **Web metadata**: uses same `share_image_url` for Open Graph (no separate OG asset).
- **No manual share upload** — derived only (acceptable for target).

---

## Target Data Model

### `today_messages` (clean target)

| Field | Keep? | Role |
| --- | --- | --- |
| `id` | Yes | PK |
| `publish_date`, `language` | Yes | Daily slot identity |
| `verse_reference`, `bible_version`, `verse_text` | Yes | **Stage 1 required** (enforce `verse_text` in admin) |
| `message` | **Deprecate → remove** | Redundant with `verse_text`; only used as fallback today |
| `image_url`, `image_public_id` | Yes | **Stage 1 required** |
| `share_image_url`, `share_image_public_id` | Yes | Mobile / web share preview (auto-generated) |
| `hint_title`, `hint_summary` | Yes | **Stage 2 optional** |
| `content_id` | Yes | **Stage 2 optional** FK → `contents` |
| `is_published`, `heart_count`, `share_count` | Yes | Publish + engagement |
| `created_at`, `updated_at` | Yes | Audit |
| `article_title`, `article_body` | **Remove** | Duplicates Content; violates lightweight TM principle |
| `primary_related_plan_template_id` | **Remove** | Plans belong on Content via `content_plan_links` |

**Recommendation:** Drop `article_title`, `article_body`, `primary_related_plan_template_id`, and `message` in one cleanup migration. Project is pre-release; migrate any existing admin copy into linked Content or `hint_summary` manually before drop.

### `contents` (unchanged target)

Owns: slug, type, language, title, subtitle, summary, body, cover, author, verse metadata, duration, external URL, sections, assets, tags, publish/browse state, and **related plans** through `content_plan_links`.

No new columns required this phase.

### Relationships (target)

```text
today_messages.content_id ──optional──> contents.id
contents ──content_plan_links──> plan_templates (0..N)
plan_templates ──start──> user_reading_plans (mobile local)
```

**Do not use:**

```text
today_messages.primary_related_plan_template_id  (remove)
today_messages.article_title / article_body      (remove)
```

---

## Gap Analysis

| Area | Current | Target | Gap | Recommended change | Priority |
| --- | --- | --- | --- | --- | --- |
| `article_title` / `article_body` | DB, API, admin, mobile More, public web | Removed; body in Content | Second content system on TM | Drop columns; remove from lib/API/admin/mobile/web | P0 |
| `primary_related_plan_template_id` | DB, API join, admin select, mobile/web plan CTA | Removed; plans via Content only | Direct TM→Plan bypasses Content | Drop column + index; remove join from queries | P0 |
| `message` field | DB, API, card fallback | Prefer `verse_text` only | Extra field | Drop after requiring `verse_text` in admin | P1 |
| `content_id` | DB + API CRUD + mobile DTO | Optional Stage 2 link | No admin picker; no API `linked_content`; mobile unused | Add picker + embed summary in public API | P0 |
| Today Message admin editor | Article + direct plan + no content picker | Verse, image, hint, linked content, previews | Wrong ownership of long copy and plans | Redesign editor sections | P0 |
| Linked content selector | Missing | Required for Mode B | Cannot author Mode B | Searchable content select in admin | P0 |
| `share_image_url` | Auto 4:5 from home image | Same role; no OG split | Aligned with target | Keep; document as share-only | — |
| Public today-message API | Full row + direct plan join | Core fields + `linked_content` (+ optional plan summary from content) | Wrong payload shape | Remove legacy fields; add linked summary | P0 |
| Public TM page | Article body + direct plan | Image + verse + hint + content CTA | Wrong page structure | Redesign `TodayMessageView` | P1 |
| Public content page | Full renderer; weak plan CTA | Full content + plan CTA | Plan list text-only | Polish plan blocks (optional) | P2 |
| Mobile Home DTO | Article + direct plan fields | Verse + hint + `linkedContent` | Wrong model | Slim DTO; drop article/plan fields | P0 |
| Mobile More / Read More | Article sheet + direct Start Plan | Hint + content preview/CTA | Wrong flow | Rename to "More"; open content detail; plans from content | P0 |
| Mobile content opening | None from Home | Discover-style detail sheet | Missing | Reuse `_ContentDetailSheet` from Discover | P0 |
| Content related plan CTA | Works in Discover | Same path from Home-linked content | Already built; not reachable from Home | Wire Home → content detail | P0 |
| Offline / cache | TM-only cache works | TM must not depend on content | OK for card; linked content online-only | Cache `linked_content` summary in API JSON; full fetch on tap | P1 |
| Seed data | Content + plans; no TM link | Mode A + Mode B examples | QA gap | Seed TM with/without `content_id` | P2 |

---

## Recommended Product Behavior

### Mode A — Simple Today's Message

- Image + verse (required)
- Optional hint
- No `content_id`
- No plan CTA on Today's Message or More sheet
- Fully offline-capable after cache

### Mode B — Today's Message linked to Content

- Image + verse + optional hint
- `content_id` set
- More sheet: hint + linked content preview/CTA ("Read full story")
- User opens content detail (online)
- Plan CTA appears **only if** linked content has `content_plan_links`
- Home card unchanged (still image + verse + hint snippet)

### Mode C — Content only

- Published in Discover / public web
- May have related plans
- Not referenced by any `today_messages` row

---

## Admin UX Plan

### Today's Message editor (target)

1. **Publishing** — publish date, language, published toggle
2. **Verse** — reference, Bible version, verse text (required)
3. **Images** — main image upload; share card preview (auto-generated, read-only)
4. **Hint** — hint title, hint summary (optional Stage 2)
5. **Linked Content** — searchable select of published contents (id, title, slug, type, language); clear; warn on language mismatch
6. **Preview** — mobile card mock (~0.86 aspect); share card preview
7. **Publish controls** — save, delete

**Remove / de-emphasize:**

- Article title/body fields
- Direct related plan selector
- Long-form textarea beyond hint summary

### Content editor (target)

Keep current structure; it already owns the right responsibilities:

1. Basic content (type, slug, title, subtitle, summary)
2. Body / sections (essay)
3. Media / assets / video URL
4. Tags
5. Related plans (primary plan authoring path)
6. Publishing (publish, archive, browse_visible, featured)

---

## API Plan

### `GET /api/v1/today-message` (target payload)

Return enough for Home card + More sheet **without requiring a second fetch for CTA labels**:

```json
{
  "message": {
    "id": "...",
    "publish_date": "2026-05-29",
    "language": "en",
    "verse_reference": "John 3:16",
    "bible_version": "NIV",
    "verse_text": "...",
    "image_url": "...",
    "share_image_url": "...",
    "share_url": "https://.../today-message/2026-05-29",
    "hint_title": "...",
    "hint_summary": "...",
    "content_id": "...",
    "linked_content": {
      "id": "...",
      "slug": "...",
      "content_type": "essay",
      "title": "...",
      "summary": "...",
      "cover_image_url": "...",
      "related_plans": [
        {
          "id": "...",
          "template_key": "...",
          "title": "...",
          "total_chapters": 12,
          "estimated_minutes": 8,
          "cta_label": null
        }
      ]
    },
    "heart_count": 0,
    "share_count": 0
  }
}
```

**Remove from public response:**

- `article_title`, `article_body`
- `primary_related_plan_template_id`
- `related_plan_*` join fields from today's message
- `message` (optional — remove after migration)

`linked_content` is `null` when no link, unpublished target, or archived target. Main card fields must always be present without `linked_content`.

### `GET /api/v1/content` / `[identifier]`

No structural change. Continues to return full detail + `related_plans` for content detail and Discover.

### Admin APIs

- Stop accepting / returning dropped columns after migration.
- Optional: `GET /api/v1/admin/content?fields=minimal` for picker performance (later).

---

## Mobile Plan

### DTO updates

- **Remove:** `articleTitle`, `articleBody`, `primaryRelatedPlanTemplateId`, `relatedPlanTemplateKey`, `relatedPlanTitle`, `relatedPlanChapters`, `relatedPlanMinutes`, `hasRelatedPlan`, `planTemplateIdentifier`, etc.
- **Add:** `LinkedContentSummary` (id, slug, contentType, title, summary, coverImageUrl, relatedPlans[])
- **Keep:** verse, image, share fields, hint, heart/share counts, `contentId`

### Home card

- Image + verse text + reference (Stage 1)
- Heart / save / share actions
- Hint snippet + "More" (not "Read more" if no long article)

### More sheet (replaces Read More article modal)

- Hint title / summary when present
- Linked content preview card + CTA when `linked_content` present (online)
- **No** local article body
- **No** direct plan CTA on this sheet

### Linked content flow

- Tap CTA → open existing Discover `_ContentDetailSheet` (or extract shared widget)
- Fetch full content via `ContentApiClient.fetchContentByIdentifier(slug)` if not already loaded
- Plan start/subscribe from content's `relatedPlans` (reuse Discover `_startRelatedPlan`)

### Offline behavior

- Home card renders from cache without linked content fetch
- More sheet shows hint only when offline; hide or disable content CTA
- Update offline fallback message: remove `article_*`; keep verse + hint only

### Local save

- Unchanged — local flag on Today's Message id

---

## Web Plan

### Today's Message public page

- Hero: image + verse
- Hint section when present
- Linked content card linking to `/content/{slug}` when `content_id` resolved
- Related plan block **only inside linked content section** (or defer to content page)
- Metadata: title from verse reference or hint; description from hint or verse; image fallback: `share_image_url` → `image_url` → site default

### Content public page

- Unchanged full renderer
- Related plans section with clearer CTA copy (optional polish)

### Share image fallback (this phase)

1. `share_image_url`
2. `image_url` (Today) / `cover_image_url` (Content)
3. Site default

No dedicated OG image work.

---

## Database / Migration Plan

**Applied:** `supabase/migrations/20260529120000_simplify_today_messages.sql`

| # | Table | Change | Status |
| --- | --- | --- | --- |
| M1 | `today_messages` | Drop `article_title`, `article_body` | Done |
| M2 | `today_messages` | Drop `primary_related_plan_template_id` + index | Done |
| M3 | `today_messages` | Drop `message` | Done |
| M4 | `today_messages` | Keep `content_id`, `share_image_*`, `hint_*` | Unchanged |
| M5 | `contents` | No column changes | N/A |
| M6 | Data | Seed Mode A/B today messages | Done (`today_message_test_seed.sql`) |

`apps/web/db/schema.sql` mirror and `docs/DATA_MODEL.md` updated in the same PR.

**Target fields on `today_messages`:**

- `image_url`, `image_public_id`
- `share_image_url`, `share_image_public_id` (auto-generated share card)
- `content_id` (nullable)
- `hint_title`, `hint_summary`
- `verse_reference`, `bible_version`, `verse_text`

---

## Rollout Plan

1. ~~**Planning doc update only**~~ ✓
2. ~~**Schema cleanup migration**~~ ✓ (`20260529120000_simplify_today_messages.sql`)
3. ~~**API payload cleanup** — `linked_content` embed~~ ✓
4. ~~**Admin Today Message editor redesign**~~ ✓
5. ~~**Public web Today Message redesign** (minimal)~~ ✓
6. ~~**Mobile DTO + Home More flow**~~ ✓
7. ~~**Content detail / related plan CTA polish**~~ ✓
8. ~~**Seed data update**~~ ✓
9. **QA / closed testing smoke**

---

## Risks / Decisions Needed

| Question | Options | Planning recommendation |
| --- | --- | --- |
| Keep `message` separate from `hint_summary`? | Drop `message` vs keep as card fallback | **Drop `message`**; require `verse_text` in admin |
| Linked content opens how on mobile? | Bottom sheet vs full screen vs route | **Reuse Discover bottom sheet** (fastest, consistent) |
| Content plan CTA: first plan or all? | Single primary vs list | **Show all related plans** (matches Discover today) |
| `share_image_url` manual override later? | Auto-only vs upload override | **Auto-only this phase**; revisit only if QA fails |
| Cache linked content locally later? | Online-only vs embed summary in TM cache | **Embed summary in today-message API + cache JSON**; full body fetch on tap |
| Transitional direct plan on TM during rollout? | Keep FK temporarily vs hard cut | **Hard cut** — project still in development |
| Web plan CTA on TM page | Show on TM vs only on content page | **Only via linked content block / link to content page** |

---

## Non-goals

- Full Bible text reader
- Saved/List
- Push notifications
- Habit layer
- Video production pipeline
- **Dedicated OG image system (1200×630)**
- Automatic multi-device sync
- Social features beyond share sheet + public pages
- Today's Message as a second content CMS (no article body on TM)

---

## Acceptance Criteria

- [x] Schema cleanup migration applied
- [x] Public API returns `linked_content` when applicable
- [x] Admin editor: no article body or direct plan selector; linked content picker added
- [x] Public web page compatible with new payload
- [x] Mobile DTO + Home More flow
- [x] Seed data Mode A/B
- [x] Public content page related plan CTA (app download)

---

## Appendix: Key file map

| Area | Path |
| --- | --- |
| Server schema | `supabase/migrations/20260528000000_baseline.sql`, `apps/web/db/schema.sql` |
| Today Message lib | `apps/web/src/lib/today-messages.ts` |
| Content lib | `apps/web/src/lib/content.ts` |
| Share URL helper | `apps/web/src/lib/cloudinary-share-url.ts` |
| Public TM API | `apps/web/src/app/api/v1/today-message/route.ts` |
| Admin TM editor | `apps/web/src/components/admin/editors/today-message/TodayMessageEditor.tsx` |
| Public TM page | `apps/web/src/app/(browse)/today-message/[slug]/page.tsx`, `TodayMessageView.tsx` |
| Mobile Home | `apps/mobile/lib/features/home/home_screen.dart` |
| Mobile TM client | `apps/mobile/lib/features/home/data/today_message_api_client.dart` |
| Mobile Discover / content | `apps/mobile/lib/features/find/discover_screen.dart`, `content_api_client.dart` |
| Content seed | `apps/web/db/seeds/content_test_seed.sql` |
