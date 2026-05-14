# Data Model

This document is the current data-model source of truth for the project.

## Current Schema Sources

| Layer | Source |
| --- | --- |
| Local mobile database | `apps/mobile/lib/core/database/app_database.dart` |
| Generated Drift code | `apps/mobile/lib/core/database/app_database.g.dart` |
| Server database | `apps/web/db/schema.sql` |

Local Drift schema version is `1`. During active development, this schema is treated as the clean baseline. If schema behavior looks stale during manual testing, delete the app and reinstall.

## Conceptual Model

```text
Plan template
  -> sections
      -> chapter ranges

User reading plan
  -> resolved user plan chapters
      -> chapter progress entries
      -> reading activities
      -> completion event
```

The important split:

- Template data defines what a plan is.
- User plan data snapshots one user's run of that plan.

When a user starts a plan, template ranges are resolved into individual `user_plan_chapters`. Later template edits should not rewrite already-started plan runs.

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

### `local_users`

One local profile row exists before remote sync. Firebase UID is stored in `auth_user_id` after sign-in.

| Column | Role |
| --- | --- |
| `id` | Short local device/user id |
| `type` | `guest` or `authenticated` |
| `auth_user_id` | Firebase `uid`, nullable |
| `sync_status`, `server_id`, `last_synced_at`, `client_revision` | Future sync metadata |

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
- `estimated_minutes`
- `estimated_days`
- `total_chapters`
- `primary_book_key`
- `primary_character`
- `is_builtin`
- `is_published`

Template source:

- Plan templates are created and edited in the web admin dashboard.
- Published templates are stored in Neon and served through `GET /api/v1/plans`.
- Mobile caches the published template rows locally before Browse Plans / Add Plan flows.

### `plan_template_sections`

Sections inside a template.

Examples:

- `Old Testament`
- `New Testament`
- `Before Samuel`
- `Young Samuel`
- `Samuel and Saul`

### `plan_template_items`

Chapter ranges inside a section.

Example:

```text
Young Samuel
  1_samuel 3-7

Samuel and Saul
  1_samuel 8-15
```

This is why the same book can appear in multiple sections with different chapter ranges.

### `plan_tags` and `plan_template_tags`

Reserved for catalog/search metadata. These tables exist locally but are not heavily used yet.

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
| `status` | `active`, `completion_ready`, `completed`; future: `paused`, `archived` |
| `subscribed_at` | Added to user's plan list |
| `started_at` | First completion/start moment |
| `completed_at` | Finish Plan confirmation time |
| `archived_at` | Reserved for future explicit archive |
| `is_active` | Current selected run flag |
| `last_opened_section_id` | Read tab resume state |
| `last_opened_book_key` | Read tab resume state |
| sync metadata | Future sync |

Current UI interpretation:

- My Plans `Current`: `active` and `completion_ready`
- My Plans `Completed`: `completed`
- Browse Plans `In Progress`: a template has an active/current run
- Browse Plans `Start Again`: a template has completed history and no current run

### `user_plan_chapters`

Resolved chapter snapshot for one user plan run.

Unique key:

```text
unique(user_plan_id, book_key, chapter_number)
```

Note: section id is stored on each row so section-based rendering can show the same book in different sections.

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

`completion_number` is calculated per local user + template. This supports Browse Plans labels such as `Completed once` and future rewards.

### `app_settings`

Small key/value store for local settings and prompt flags.

Examples:

- `last_active_plan_id`
- `account_mode`
- `initial_backup_prompt_done`

## Server Schema Status

The active server schema in `apps/web/db/schema.sql` currently supports auth user upsert:

```sql
auth_users (
  id uuid primary key,
  firebase_uid text unique,
  email text,
  display_name text,
  photo_url text,
  email_verified boolean,
  created_at timestamptz,
  updated_at timestamptz,
  last_seen_at timestamptz
)
```

Remote sync tables for plan templates, user plans, progress, activities, and completion events are not implemented yet.

When sync work starts, the server schema should be aligned with the current local model:

- `plan_templates`
- `plan_template_sections`
- `plan_template_items`
- `user_reading_plans`
- `user_plan_chapters`
- `chapter_progress_entries`
- `reading_activities`
- `plan_completion_events`

## Current Repository Consistency Notes

- Local Drift code uses `user_plan_id` for plan-run scoped rows.
- Local denominator table is `user_plan_chapters`.
- Firebase `uid` is stored locally in `local_users.auth_user_id`.
- The mobile app currently syncs only auth user identity to the server.
