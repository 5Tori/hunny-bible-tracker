# Product Roadmap

This document explains what the product is today and what should be built next.

## Product Direction

Hunny Bible Tracker is becoming a guided Bible reading pack app, not just a chapter checklist.

```text
Browse Plans
  -> add/start a reading journey
  -> read section/book/chapter progress
  -> finish a plan
  -> keep completed history
  -> start again when desired
```

The app is not a Bible text reader in v0.1. It tracks references and progress.

## Current Tabs

| Tab | Current state |
| --- | --- |
| Home | Greeting, verse mock, current plan progress, featured content mock |
| Discover/Find | Mock content catalog with search/filter UI |
| Read | Main production-quality area |
| List | Placeholder |
| Settings | Account, preferences, help/feedback |

## Read Tab Current UX

Current implemented flow:

- Top plan title opens My Plans sheet.
- My Plans has `Current` and `Completed` tabs.
- `Current` shows active/current plan runs.
- `Completed` shows finished run history.
- `Browse Plans` opens catalog.
- Catalog cards show type, title, short description, chapter count, estimated time.
- A plan already being read shows `In Progress`.
- A plan with completed history shows `Completed once` or `Completed N times`.
- A completed template can be started again with `Start Again`.
- Chapter grids can be read in any order.
- Plan completion requires confirmation.

## Current Built-In Plans

### Bible in a Year

Sections:

- Old Testament
- New Testament

### Samuel Story

Sections:

- Before Samuel
- Young Samuel
- Samuel and Saul

This proves the section/range model supports non-canonical story plans and repeated books across different sections.

## Completion Policy

When all chapters in a plan run are complete:

1. Mark plan `completion_ready`.
2. Show completion dialog.
3. If confirmed, create one `plan_completion_events` row.
4. Mark plan `completed`.
5. Remove it from current plan list.
6. Keep it visible in `Completed`.

Completed plans are read-only for now. To read again, start a new run from Browse Plans.

## Settings Current UX

- Guest state shows local device id and short sign-in prompt.
- Signed-in state shows account email.
- Google-only sign-in flow through Firebase Auth.
- Timezone is automatically detected.
- Language opens a bottom sheet with English only.
- Notifications are Off and reserved for future development.
- Help & feedback bottom sheet includes FAQ and feedback form.
- Signed-in feedback uses account email internally; guest users can enter email.

## Discover Current UX

The Discover/Find tab is local mock data today.

Current behavior:

- Search filters by title, reference, and tags.
- Keyword filters are AND.
- Topic filters are AND.
- Length filters are OR inside the length dimension.
- Results must pass all active filter dimensions.

Future server content should preserve these semantics or document any change.

## Near-Term Priorities

### 1. Plan Catalog Detail

Add detail view for a plan before starting:

- Cover image
- Description
- Sections preview
- Estimated time/days
- Tags
- Optional intro/prologue

### 2. More Built-In Plans

Add a few real guided packs:

- Life of Joseph
- Life of David
- Psalms for Anxiety
- Gospel of Mark

Each should be seeded through the same template/section/item model.

### 3. Completed Plan Polish

Improve completed history:

- Completed date
- Run number
- Total chapters
- Optional completion message
- Future reward/badge placeholder

### 4. Remote Sync Foundation

Implement server schema and API for local model sync. See `docs/SYNC_STRATEGY.md`.

### 5. List Tab

Decide first useful scope:

- Saved references
- Saved content items
- Reading notes

Do not introduce full Bible text storage unless product scope changes.

### 6. Discover Content API

Replace mock catalog with server-provided content when content strategy is ready.

Potential content types:

- Devotional
- Article
- Video
- Plan prologue
- Section intro
- Completion message

## Later Ideas

- Plan tags and filtering in Browse Plans
- Plan media table for cover/detail/prologue/completion assets
- Reward templates and reward grants
- Reflection prompts
- Admin dashboard for plan/content authoring
- Push notifications
- Account statistics and lifetime unique chapters read

## Product Guardrails

- Keep the first screen useful, not a marketing page.
- Keep Read workflows fast and ergonomic.
- Do not make users distinguish sign-up vs sign-in for Google Auth.
- Keep plan definitions separate from user progress.
- Keep reading activity separate from current progress state.
- Keep Neon behind API routes; mobile should not connect to Neon directly.
