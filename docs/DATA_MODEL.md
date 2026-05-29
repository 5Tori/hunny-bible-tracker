# Data Model

This document is the current data-model source of truth for the project.

## Schema Sources

| Layer | Source |
| --- | --- |
| Local mobile database | `apps/mobile/lib/core/database/app_database.dart` |
| Generated Drift code | `apps/mobile/lib/core/database/app_database.g.dart` |
| Server database | `apps/web/db/schema.sql` |

Local Drift schema version is `3`. During active MVP development, stale local data can be cleared by deleting/reinstalling the app or resetting the simulator/emulator build.

During MVP development, the server migration history has been reset. Use `supabase/migrations/20260528000000_baseline.sql` as the source of truth for fresh Supabase setup (`apps/web/db/schema.sql` is a reference mirror).

## Conceptual Model

```text
Plan template
  -> sections
      -> chapter ranges

Content
  -> author
  -> tags
  -> related plan templates
  -> ordered assets/blocks

User reading plan
  -> locally resolved user plan chapters
      -> chapter progress entries
      -> reading activities
      -> completion event
```

The important split:

- Template data defines what a plan is.
- Content data defines what can be consumed or discovered around plans.
- User plan data represents one user's run of that plan.
- `user_plan_chapters` is local derived data used for offline UI, ordering, sections, and progress denominators.
- Later template edits should not rewrite already-started plan runs.
- Remote reading backup should store compact user state, not every derived chapter row.
- Today’s Message is a daily Home slot. It remains separate from the general content catalog for now, with an optional `content_id` reserved for linking to a reusable `contents` row later.

## Local Tables

### `bible_books`

Seeded from `apps/mobile/assets/data/bible_books.en.json`.

| Column | Role |
| --- | --- |
| `book_key` | Stable key used by plans and progress |
| `testament` | `old` or `new` |
| `book_order` | Canonical order |
| `short_name` | UI short label |
| `display_name_en` | English display name |
| `display_name_ko` | Nullable future localization |
| `chapter_count` | Canonical chapter count |

### `bible_chapters`

Seeded from `apps/mobile/assets/data/bible_chapters.json` (1,189 Protestant canon chapters).

| Column | Role |
| --- | --- |
| `book_key` | FK-style key matching `bible_books.book_key` |
| `chapter_number` | 1 … `chapter_count` for that book |
| `verse_count` | Verses in the chapter (KJV structure via generation script) |
| `estimated_reading_seconds` | `verse_count × 7` |
| `estimated_reading_minutes` | `max(1, ceil(seconds / 60))` |

Primary key: `(book_key, chapter_number)`.

Regenerate the JSON after changing `bible_books.en.json`:

```bash
pnpm run bible-chapters:generate
```

Source for verse counts: [thiagobodruk/bible](https://github.com/thiagobodruk/bible) `en_kjv.json` (cached under `scripts/data/` on first run; gitignored).

Lookup helpers:

- Mobile: `apps/mobile/lib/core/bible/bible_chapter_metadata.dart`
- Web admin (build-time JSON): `apps/web/src/lib/bible-chapters.ts`

### `local_users`

One local profile row exists before remote sync. Supabase user UUID is stored in `auth_user_id` after sign-in.

| Column | Role |
| --- | --- |
| `id` | Short local device/user id |
| `type` | `guest` or `authenticated` |
| `auth_user_id` | Supabase user UUID, nullable |
| `sync_status`, `server_id`, `last_synced_at`, `client_revision` | Sync metadata |

### `plan_templates`

Catalog/source definition for reading plans.

Important columns:

- `template_key`
- `title`
- `subtitle`
- `description`
- `short_description`
- `cover_image_url`
- `plan_type`
- `testament_scope`
- `difficulty`
- `estimated_minutes` — average estimated reading minutes **per chapter** in the plan; computed automatically from `bible_chapters.json` on admin save (not manually edited)
- `estimated_days`
- `total_chapters`
- `primary_book_key`
- `primary_character`
- `is_builtin`
- `is_published`
- `featured_rank`
- `browse_visible`

Template source:

- Plan templates are created and edited in the web admin dashboard.
- Published templates are stored in Supabase and served through `GET /api/v1/plans`.
- Mobile caches published template rows locally before Catalog / Start Plan flows.

### `plan_template_sections`

Sections inside a template.

Examples:

- `Old Testament`
- `New Testament`
- `Dreams and Betrayal`
- `Joseph in Egypt`

### `plan_template_items`

Chapter ranges inside a section.

Example:

```text
Dreams and Betrayal
  Genesis 37

Joseph in Egypt
  Genesis 39-41
```

This is why the same book can appear in multiple sections with different chapter ranges.

### `plan_tags` and `plan_template_tags`

Reserved for catalog/search metadata.

Potential tag types:

- `person`
- `theme`
- `book`
- `testament`
- `situation`
- `length`
- `genre`

### `user_reading_plans`

A user's run of a template.

Important columns:

| Column | Role |
| --- | --- |
| `local_user_id` | Owner |
| `template_id` | Source template |
| `title` | Snapshot title |
| `status` | `active`, `completion_ready`, `completed`, `archived` |
| `subscribed_at` | Added to user's plan list |
| `started_at` | First completion/start moment |
| `completed_at` | Finish Plan confirmation time |
| `archived_at` | Hidden from Current while preserving progress/history |
| `is_active` | Current selected run flag |
| `last_opened_section_id` | Read tab resume state |
| `last_opened_book_key` | Read tab resume state |
| sync metadata | Backup/restore state |

Current UI interpretation:

- Plans > My Plans > Current: `active` and `completion_ready` where `archived_at is null`
- Plans > My Plans > Completed: completion history from `plan_completion_events`
- Plans > My Plans > Archived: `archived_at is not null`
- Catalog `Continue`: a template has an active/current run
- Catalog `Start Again`: a template has completed history and no current run

Archive is non-destructive. It updates the plan row and keeps `user_plan_chapters`, `chapter_progress_entries`, `reading_activities`, and `plan_completion_events`.

### `user_plan_chapters`

Resolved chapter snapshot for one user plan run.

This table is local derived data. Starting a plan can create hundreds or thousands of rows here so the offline read UI has a stable denominator and ordering. These rows should not be replicated to server backup in the compact backup architecture.

Unique key:

```text
unique(user_plan_id, book_key, chapter_number)
```

Section id is stored on each row so section-based rendering can show the same book in different sections.

### `chapter_progress_entries`

Mutable current state for chapter completion within a plan run.

Unique key:

```text
unique(local_user_id, user_plan_id, book_key, chapter_number)
```

Plan progress is calculated from completed rows divided by `user_plan_chapters`.

### `reading_activities`

Append-friendly activity summary for streak and reading-day calculations.

Unique key:

```text
unique(
  local_user_id,
  user_plan_id,
  book_key,
  chapter_number,
  activity_date,
  action
)
```

This prevents duplicate same-day completion activity when a user checks, unchecks, and rechecks a chapter.

Unchecking updates `chapter_progress_entries`; it does not delete activity history.

### `plan_completion_events`

Completion history, one event per finished user plan run.

Unique key:

```text
unique(user_plan_id)
```

`completion_number` is calculated per local user + template. This supports labels such as `Completed once` and `Completed N times`.

### `app_settings`

Small key/value store for local settings and prompt flags.

Examples:

- `last_active_plan_id`
- `account_mode`
- `initial_backup_prompt_done`
- `last_reading_sync_at`
- `today_message_hearted_<id>`
- `today_message_saved_<id>`

## Server Tables

`supabase/migrations/` is the server schema source for Supabase.

### Identity

```text
auth.users   # Supabase-managed
profiles     # public.profiles, FK to auth.users
```

Supabase Auth owns identity. `profiles.id` maps auth users to app data rows.

### Plan catalog

```text
plan_templates
plan_template_sections
plan_template_items
plan_tags
plan_template_tags
```

Admin-owned plan content is stored in Supabase and published to mobile through `/api/v1/plans`.

### Content catalog

```text
content_authors
contents
content_assets
content_sections
content_tags
content_tag_links
content_plan_links
```

General content is server-managed and currently powers Discover/Find. It is also designed to power future Home featured content, Saved, and content detail screens.

`contents` is the canonical content record. Initial supported `content_type` values are:

- `message`
- `video`
- `essay`
- `cartoon`

Important `contents` fields:

- `slug`
- `content_type`
- `language`
- `title`
- `subtitle`
- `summary`
- `body`
- `cover_image_url`
- `cover_image_public_id`
- `author_id`
- `primary_verse_reference`
- `bible_version`
- `verse_text`
- `duration_seconds`
- `external_url`
- `is_published`
- `is_archived`
- `published_at`
- `featured_rank`
- `browse_visible`
- `metadata`

`content_authors` is intentionally lightweight. It supports one-person publishing today and future multi-author expansion later.

Important `content_authors` fields:

- `slug`
- `display_name`
- `bio`
- `avatar_image_url`
- `avatar_image_public_id`
- `website_url`
- `is_verified`
- `is_active`

`content_assets` stores ordered supporting media for content. Examples:

- video thumbnail
- embedded video URL
- cartoon slide images
- share image

`content_sections` stores ordered essay body sections. Each section has one required text body and one optional image, so essay content can render as repeated image-plus-paragraph blocks.

`content_tags` supports multiple tag categories through the `type` field instead of hard-coding a fixed taxonomy. Early likely categories:

- `topic`
- `situation`
- `person`
- `book`
- `theme`
- `format`
- `length`

`content_plan_links` connects content to one or more plan templates. This allows Home and Discover cards to say “start this related plan” without forcing every content item to own a plan.

Published content is served through:

```text
GET /api/v1/content
GET /api/v1/content/:identifier
```

Today’s Message remains in `today_messages` because its date/language uniqueness, fallback lookup, and engagement behavior are special Home-slot behavior. The schema reserves this optional bridge:

```text
today_messages.content_id -> contents.id
```

When product code starts using that link, Today’s Message can reuse the general content renderer while preserving the daily publishing policy.

### Reading backup/restore

Target compact backup table:

```text
user_reading_backups
```

One row per authenticated user stores the latest compact reading backup snapshot:

| Column | Role |
| --- | --- |
| `auth_user_id` | Unique owner, references `profiles(id)` |
| `backup_version` | Snapshot schema version |
| `payload_jsonb` | Compact JSON backup payload |
| `payload_hash` | Stable hash of canonical payload JSON |
| `created_at`, `updated_at` | Backup lifecycle timestamps |

The payload stores plan lifecycle metadata, completed progress, reading activities, completion events, and backup-relevant settings. It does not store `user_plan_chapters`.

Legacy relational sync tables are removed from the server schema. Relational reading tables remain local Drift tables only.

### Today’s Message

```text
media_assets
today_messages
```

Important `today_messages` fields:

- `content_id`
- `publish_date`
- `language`
- `verse_reference`
- `bible_version`
- `verse_text`
- `message`
- `image_url`
- `image_public_id`
- `share_image_url`
- `share_image_public_id`
- `hint_title`
- `hint_summary`
- `article_title`
- `article_body`
- `primary_related_plan_template_id`
- `is_published`
- `heart_count`
- `share_count`

`unique(publish_date, language)` keeps one canonical message per language per day. Public lookup returns the latest published message where `publish_date <= requested date`.

Only publish verse text that the project is licensed or allowed to display.

### Feedback

```text
feedback_messages
```

Mobile Settings > Help & feedback posts to the server with:

- `category`: `bug`, `idea`, or `other`
- `message`
- optional contact/signed-in email
- source and metadata

## Current Repository Consistency Notes

- Local Drift code uses `user_plan_id` for plan-run scoped rows.
- Local denominator table is `user_plan_chapters`.
- Supabase user UUID is stored locally in `local_users.auth_user_id`.
- Compact backup does not depend on per-row `server_id` values.
- Mobile still writes locally first; backup/restore is an authenticated secondary path.
