# Data Model

This document is the current data-model source of truth for the project.

## Schema Sources

| Layer | Source |
| --- | --- |
| Local mobile database | `apps/mobile/lib/core/database/app_database.dart` |
| Generated Drift code | `apps/mobile/lib/core/database/app_database.g.dart` |
| Server database | `apps/web/db/schema.sql` |
| Server migrations | `apps/web/db/migrations/` |

Local Drift schema version is `2`. During active MVP development, stale local data can be cleared by deleting/reinstalling the app or resetting the simulator/emulator build.

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
- Later template edits should not rewrite already-started plan runs.

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
- `estimated_minutes`
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
- Published templates are stored in Neon and served through `GET /api/v1/plans`.
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

`apps/web/db/schema.sql` is the server schema source for Neon.

### Identity

```text
auth_users
```

Firebase Auth owns identity. `auth_users.firebase_uid` maps Firebase users to app data rows.

### Plan catalog

```text
plan_templates
plan_template_sections
plan_template_items
plan_tags
plan_template_tags
```

Admin-owned plan content is stored in Neon and published to mobile through `/api/v1/plans`.

### Reading backup/restore

```text
user_reading_plans
user_plan_chapters
chapter_progress_entries
reading_activities
plan_completion_events
sync_states
```

Server sync rows are scoped to `auth_users`. Mobile UUIDs are stored as `client_id` values, allowing the API to acknowledge uploaded rows back to local Drift rows.

### Today’s Message

```text
media_assets
today_messages
```

Important `today_messages` fields:

- `publish_date`
- `language`
- `verse_reference`
- `bible_version`
- `verse_text`
- `message`
- `image_url`
- `image_public_id`
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
- Firebase `uid` is stored locally in `local_users.auth_user_id`.
- Mobile backup/restore maps local UUIDs to server UUIDs through `client_id` / `server_id`.
- Mobile still writes locally first; backup/restore is an authenticated secondary path.
