# Plan Structure Refactor

## Goal

Hunny Bible Tracker should support many plan shapes with one model:

```text
Plan Catalog
  -> Plan template
  -> Sections
      -> Chapter ranges
          -> Resolved user plan chapters
              -> User progress
```

The key split is:

- **Plan definition**: what structure and chapter ranges a plan contains.
- **User progress**: how far a specific user has progressed in one started plan.

This lets the app represent `whole_bible`, `samuel_story`, `life_of_david`,
`psalms_for_anxiety`, and future curated plans without special-case code.

The product direction is closer to reading journey packs than a simple
checklist. Users discover a plan pack, add it to their own list, progress
through a personal run, then keep a completed history.

```text
Plan Catalog
  = plans the user can add

My Plans
  = plans the user has added

Active Plan Run
  = a specific in-progress user instance

Archived / Completed Plans
  = completed or retired plan history

Plan Metadata
  = topic, person, Bible range, difficulty, time estimate, tags
```

## Core Principle

Templates are source definitions for future starts. User plans are snapshots.

When a user starts a plan, the app resolves template ranges into individual
chapters and stores that snapshot under the user plan. Later edits to a template
must not unexpectedly change a plan a user already started.

```text
plan_templates
  -> plan_template_sections
      -> plan_template_items
          -> chapter ranges

user_reading_plans
  -> user_plan_chapters
      -> resolved individual chapters
          -> chapter_progress_entries
```

Reading activity remains separate and append-only.

## UX Model

Primary user flow:

```text
Read tab
  -> view My Plans
  -> Add Plan
  -> browse Plan Catalog
  -> inspect image, description, total chapters, estimated time
  -> Add to My Plans
  -> read the plan
  -> complete
  -> archive / completion history
```

### My Plans Switcher

The plan switcher is for switching, not discovery. Keep it compact.

```text
My Plans

Whole Bible
42% complete

Samuel Story
8 / 31 chapters

Life of Joseph
Not started

[Add New Plan]
```

Initial implementation can show only titles. Add progress summaries once the
new `user_plan_chapters` source is stable.

### Add Plan Catalog

The catalog is where a plan should feel desirable to start.

Plan card v1:

```text
[Cover Image]

Samuel Story
From Samuel's birth to Israel's first king.

31 chapters - About 2 hours - Story Plan

[Add to My Plans]
```

Recommended card fields:

- Cover image
- Title
- Short description
- Total chapters
- Estimated reading time
- Plan type
- Primary tags
- Add button

Plan detail can come later when prologue, video, section previews, or richer
content is available. Early catalog cards can add directly to My Plans.

## Phase 1 - Template Structure Refactor

First stabilize the data model. UI can continue looking mostly the same.

### Objectives

- Represent Whole Bible with sections.
- Represent story/topic plans such as Samuel Story.
- Allow different chapter ranges from the same book in different sections.
- Keep the current Read UI working while changing its data source.

### Tables

#### `plan_templates`

Plan source definitions.

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `template_key` | Stable key, unique |
| `title` | User-facing title |
| `subtitle` | Optional supporting line |
| `description` | Plan summary |
| `short_description` | Catalog card summary |
| `cover_image_url` | Optional catalog image |
| `plan_type` | Example: `canonical`, `story`, `topic` |
| `testament_scope` | Example: `old_testament`, `new_testament`, `whole_bible`, `mixed` |
| `difficulty` | Optional level for catalog filtering |
| `estimated_minutes` | Optional total estimate |
| `estimated_days` | Optional suggested duration |
| `total_chapters` | Denormalized catalog count |
| `primary_book_key` | Nullable primary book |
| `primary_character` | Nullable primary person |
| `is_builtin` | Built-in seed plan flag |
| `is_published` | Catalog visibility |
| `created_at` | Timestamp |
| `updated_at` | Timestamp |

Example keys:

- `whole_bible`
- `samuel_story`
- `life_of_david`
- `psalms_for_anxiety`

#### `plan_template_sections`

Sections inside a plan.

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `plan_template_id` | References `plan_templates.id` |
| `section_key` | Stable key within a template |
| `title` | Example: `Old Testament`, `Young Samuel` |
| `description` | Optional section intro |
| `order_index` | Display/resolve order |
| `estimated_minutes` | Optional section estimate |
| `created_at` | Timestamp |
| `updated_at` | Timestamp |

#### `plan_template_items`

Chapter ranges inside a section.

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `section_id` | References `plan_template_sections.id` |
| `order_index` | Order inside the section |
| `book_key` | Matches `bible_books.book_key` |
| `start_chapter` | Inclusive |
| `end_chapter` | Inclusive |

This table makes section-specific ranges possible:

```text
Young Samuel
  1_samuel 3-7

Samuel and Saul
  1_samuel 8-15
```

#### `plan_tags`

Catalog/search tags.

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `key` | Stable unique key |
| `name` | Display name |
| `type` | Example: `person`, `theme`, `book`, `testament`, `situation`, `length`, `genre` |

#### `plan_template_tags`

Many-to-many join between plan templates and tags.

| Column | Notes |
| --- | --- |
| `plan_template_id` | References `plan_templates.id` |
| `tag_id` | References `plan_tags.id` |

Example metadata for Joseph Story:

```text
person:
  Joseph

book:
  Genesis

theme:
  forgiveness
  waiting
  restoration

testament:
  old_testament

genre:
  narrative
```

Tags should be added after the base catalog and subscription flow works. They
are important for Find/Discover, but not required to make v1 plans usable.

### Media Strategy

Start simple:

```text
plan_templates.cover_image_url
```

This is enough for the first catalog cards.

If plans later need multiple images, intro videos, completion images, or
carousel content, add:

#### `plan_media`

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `plan_template_id` | References `plan_templates.id` |
| `media_type` | `image`, `video`, `youtube`, `carousel_image` |
| `url` | Media URL |
| `thumbnail_url` | Optional thumbnail |
| `order_index` | Display order |
| `placement` | `cover`, `detail_header`, `prologue`, `completion` |

Recommendation: keep only `cover_image_url` now, then introduce `plan_media`
when richer plan detail pages require it.

### Seed Examples

Whole Bible:

```text
Whole Bible
  Old Testament
    Genesis 1-50
    Exodus 1-40
    ...
  New Testament
    Matthew 1-28
    Mark 1-16
    ...
```

Samuel Story:

```text
Samuel Story
  Before Samuel
    Ruth 1-4
    1 Samuel 1-2
  Young Samuel
    1 Samuel 3-7
  Samuel and Saul
    1 Samuel 8-15
```

## Phase 2 - User Plan Instances

Separate plan templates from user plan runs.

```text
Plan Template: Whole Bible
User Plan Run #1: completed
User Plan Run #2: active
```

### `user_reading_plans`

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `local_user_id` | References local user |
| `template_id` | References `plan_templates.id` |
| `title` | Snapshot title for the run |
| `status` | Lifecycle state |
| `subscribed_at` | Added to My Plans |
| `started_at` | First chapter checked or explicit Start |
| `completed_at` | Nullable |
| `archived_at` | Nullable |
| `last_opened_section_id` | Nullable, references user plan section/snapshot context |
| `last_opened_book_key` | Nullable |
| `created_at` | Timestamp |
| `updated_at` | Timestamp |

Recommended status values:

- `active`
- `completion_ready`
- `completed`
- `archived`
- `paused`

MVP can start with:

- `active`
- `completed`
- `archived`

`Add to My Plans` creates a `user_reading_plans` row. In this product context,
"subscribed" means added to the user's list. It does not imply paid
subscription.

Recommended date semantics:

- `subscribed_at`: when the user added the plan.
- `started_at`: when the user first started reading.
- `completed_at`: when Finish Plan is confirmed.
- `archived_at`: when the plan moves out of active reading.

These dates enable future stats:

- Days from subscribe to start.
- Days from start to completion.
- Reading days required to complete.

## Phase 3 - Resolved Chapters

Templates define ranges, but progress is stored per chapter.

Example:

```text
1 Samuel 3-7
```

resolves to:

```text
1 Samuel 3
1 Samuel 4
1 Samuel 5
1 Samuel 6
1 Samuel 7
```

### `user_plan_chapters`

Snapshot of individual chapters generated when a user starts a plan.

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `user_plan_id` | References `user_reading_plans.id` |
| `section_id` | Template section id or future snapshot section id |
| `book_key` | Matches `bible_books.book_key` |
| `chapter_number` | Individual chapter |
| `order_index` | Total plan order |

Start flow:

```text
User starts Samuel Story
  -> read template sections/items
  -> expand ranges into individual chapters
  -> insert user_plan_chapters snapshot
  -> show user plan in Read tab
```

This protects active and completed user runs from future template edits.

## Phase 4 - Progress Connection

Progress stays chapter-based.

### `chapter_progress_entries`

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `local_user_id` | References local user |
| `user_plan_id` | References `user_reading_plans.id` |
| `book_key` | Matches `user_plan_chapters.book_key` |
| `chapter_number` | Matches `user_plan_chapters.chapter_number` |
| `is_completed` | Boolean |
| `completed_at` | Nullable |
| `updated_at` | Timestamp |
| `sync_status` | Sync state |

Recommended unique constraint:

```sql
unique(local_user_id, user_plan_id, book_key, chapter_number)
```

Progress calculations:

- **Plan progress**: completed progress entries / total `user_plan_chapters`.
- **Section progress**: completed entries in the section / section chapters.
- **Book progress**: completed entries grouped by `book_key` / book chapters in this plan.

Important distinction:

- Progress is scoped by `user_plan_id`.
- Streak is scoped by `local_user_id`.

### `reading_activities`

Reading activity remains a separate log.

| Column | Notes |
| --- | --- |
| `local_user_id` | User |
| `user_plan_id` | Plan run |
| `book_key` | Book |
| `chapter_number` | Chapter |
| `activity_date` | Local calendar date |
| `timezone` | Device timezone |
| `happened_at` | Timestamp |

## Development Priority

Immediate priority:

```text
1. Make plan_templates catalog-friendly.
2. Apply section/range structure.
3. Add subscribed_at and Add to My Plans semantics.
4. Create user_plan_chapters snapshots when a plan is added.
5. Build Plan Switcher + Add Plan catalog.
```

### 1. Catalog-Friendly Template Metadata

First extend `plan_templates` so a plan can appear in a catalog.

Tasks:

1. Add/confirm `plan_templates`.
2. Add catalog fields: `subtitle`, `short_description`, `cover_image_url`.
3. Add classification fields: `plan_type`, `testament_scope`, `difficulty`.
4. Add estimates: `estimated_minutes`, `estimated_days`, `total_chapters`.
5. Add visibility fields: `is_builtin`, `is_published`.

At this stage, UI can still show only the current Whole Bible plan. The purpose
is to make templates ready for catalog cards.

### 2. Section / Range Structure

Complete the plan definition model.

Tasks:

1. Add `plan_template_sections`.
2. Add `plan_template_items`.
3. Convert existing Whole Bible seed into section-based template data.
4. Seed Whole Bible with `Old Testament` and `New Testament`.
5. Prepare at least one story-plan fixture, such as Samuel Story, even if it is hidden from UI.

At this stage, the existing UI can stay visually unchanged.

### 3. Subscribe / Add to My Plans

Add the "plan pack" ownership layer.

When the user taps `Add to My Plans`:

```text
plan_template
  -> create user_reading_plan
  -> set subscribed_at
  -> resolve ranges
  -> create user_plan_chapters snapshot
```

Tasks:

1. Add `subscribed_at` to `user_reading_plans`.
2. Add `user_plan_chapters`.
3. Implement the template-to-snapshot resolver.
4. Ensure already-started user plans are insulated from template edits.

This is the point where "catalog plan" and "my plan" become separate concepts.

### 4. Make Read Use the New Source

Current UI can continue looking like:

```text
Old Testament
Gen / Exod / Lev
Chapter grid
```

Internally, it should read:

```text
user_reading_plan
  -> user_plan_chapters
  -> group by testament/book
  -> display book grid
```

The goal is to change the data source without forcing a visible redesign.

### 5. Plan Switcher

Improve Read tab plan switching before building the full catalog.

```text
My Plans

Whole Bible
42% complete

Samuel Story
8 / 31 chapters

[Add New Plan]
```

Tasks:

1. Show subscribed plans.
2. Let the user switch the active plan.
3. Include `Add New Plan` entry.
4. Show progress summaries when available.

### 6. Plan Catalog UI

Build the first Add Plan experience.

Card v1:

```text
cover image
title
short description
total chapters
estimated time
plan type
Add button
```

Plan Detail is optional at this stage. It is acceptable for a card to add
directly to My Plans.

### 7. Section UI

After the source is stable, expose sections.

Suggested Read structure:

```text
Read
  - Plan selector
  - Section selector
  - Book grid
  - Chapter grid
```

Whole Bible:

```text
Old Testament / New Testament
```

Samuel Story:

```text
Before Samuel
Young Samuel
Samuel and Saul
```

Example UI:

```text
Samuel Story

[Before Samuel] 80%
[Young Samuel] 20%
[Samuel and Saul] 0%

Selected: Young Samuel
1 Samuel
[3] [4] [5] [6] [7]
```

### 8. Metadata Tags

Add tags after the base catalog is functional.

Tasks:

1. Add `plan_tags`.
2. Add `plan_template_tags`.
3. Seed tags for initial story/topic plans.
4. Keep UI usage minimal until Find/Discover needs the data.

This supports future queries:

```text
Find plans about forgiveness
Find Old Testament story plans
Find short plans
Find plans about David/Joseph/Samuel
```

### 9. Plan Detail / Prologue

Add a detail page when catalog cards become too small for the content.

Detail v1:

```text
cover image
title
description
total chapters
estimated time
sections preview
tags
Add to My Plans
```

Later additions:

- Prologue
- Intro video
- Related articles
- Section intros
- Completion message

Keep `cover_image_url` until richer media requires `plan_media`.

### 10. Completion and Archive

Completion condition:

```text
all user_plan_chapters have completed progress entries
```

Flow:

```text
Last chapter checked
  -> detect 100%
  -> show completion popup
  -> Finish Plan
  -> create plan_completion_event
  -> user_reading_plans.status = completed
  -> set completed_at / archived_at
```

Policy:

- Completed plans are read-only.
- Reading again creates a new `user_reading_plan`.
- A completion event is created once per `user_plan_id`.

#### `plan_completion_events`

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `local_user_id` | User |
| `user_plan_id` | Completed run, unique |
| `template_id` | Source template |
| `completion_number` | Count for this user/template |
| `completed_at` | Timestamp |
| `created_at` | Timestamp |

### 11. Re-reading

`Read again` starts a new run from the same template.

```text
Whole Bible Run #1 completed
Whole Bible Run #2 active
```

Completion count:

```text
completion_number = previous completions for this template + 1
```

### 12. Rewards

Add rewards only after completion lifecycle is stable.

#### `reward_templates`

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `plan_template_id` | Nullable or plan-specific |
| `trigger_completion_number` | Example: first completion |
| `title` | Reward title |
| `description` | Reward description |
| `image_url` | Optional image |

#### `reward_grants`

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `local_user_id` | User |
| `user_plan_id` | Completed run |
| `reward_template_id` | Reward |
| `granted_at` | Timestamp |

MVP reward:

- First completion badge.

### 13. Related Content Expansion

Later, connect plans to Discover/Admin content.

Content types:

- Plan prologue
- Section intro
- Completion message
- Related YouTube
- Related blog
- Reflection prompt

#### `content_items`

| Column | Notes |
| --- | --- |
| `id` | Primary key |
| `type` | Content type |
| `title` | Title |
| `body` | Text body |
| `url` | Optional external URL |
| `thumbnail_url` | Optional image |
| `language` | Locale |

#### `plan_related_contents`

| Column | Notes |
| --- | --- |
| `plan_template_id` | Template |
| `section_id` | Nullable |
| `content_id` | Content item |
| `placement` | Placement enum |
| `order_index` | Display order |

Placement examples:

- `plan_prologue`
- `section_intro`
- `completion`
- `recommended`

Future UX:

```text
Samuel Story
  - Watch intro
  - Read background
  - Start plan
```

## Implementation Notes

- Add migration in small steps and keep existing local data upgradeable.
- Seed Whole Bible as the first section-based template.
- Prefer snapshot tables for user-started plans to protect in-progress runs.
- Keep progress and activity separate.
- Keep sync metadata on user-owned rows so future server sync can upload user plan runs and progress.
- Avoid coupling streak logic to plan completion. Streak should remain user/day based.
