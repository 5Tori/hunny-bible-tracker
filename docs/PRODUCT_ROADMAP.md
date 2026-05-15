# Product Roadmap

This document explains what the product is today and what should be built next.

## Product Direction

Hunny Bible Tracker is becoming a guided Bible reading pack app, not just a chapter checklist.

```text
Home prompt / Plan Catalog
  -> start a reading journey
  -> read section/book/chapter progress
  -> finish a plan
  -> keep completed history
  -> archive/restore or start again when desired
```

The app is not a full Bible text reader in v0.1. It tracks references, progress, plans, and short admin-managed message content.

## MVP Tabs

| Tab | Current state |
| --- | --- |
| Home | Greeting, Today’s Message, Read More modal, related plan CTA, current reading progress |
| Read | Main reading surface and quick plan switcher |
| Settings | Account, backup/restore, Manage reading plans, Help & feedback |

Hidden for MVP:

- Discover/Find prototype
- Saved/List prototype

## Home Current UX

Today’s Message is a small content unit:

- Image
- Verse text
- Verse reference + Bible version
- Heart, Save, Share actions
- Quick reflection title/summary
- Read More article modal
- Related plan CTA in the article modal

Public lookup returns the latest published message on or before the requested date. This prevents a blank Home card when today’s content has not been published yet.

Heart/share counts are server counters. Save is local for now.

## Read Current UX

Implemented flow:

- Top plan title opens a lightweight My Plans sheet.
- The sheet is quick switching only.
- Sheet rows show Current Plans and progress.
- Sheet buttons open full Plans screen:
  - `Browse Plans` -> Plans Catalog
  - `Manage Plans` -> Plans My Plans
- Chapter grids can be read in any order.
- Plan completion requires confirmation.

## Plans Current UX

Plans is a full-screen Plan Manager / Plan Library, not a bottom tab.

### My Plans

Sections:

- `Current`: active and completion-ready runs
- `Completed`: finished run history
- `Archived`: archived runs with preserved progress

Current plan cards show:

- title
- completed / total chapters
- percent
- Continue
- Archive

Archived plan cards show:

- preserved progress
- Restore

### Catalog

Catalog shows published plan templates from Neon, cached locally on mobile.

CTA policy:

- Never started -> `Start Plan`
- Active/current run exists -> `Continue`
- Completed before and no active run -> `Start Again`

`Plan Detail` is intentionally not implemented yet.

## Settings Current UX

- Guest state shows local account state and sign-in prompt.
- Signed-in state shows account email.
- Google-only sign-in flow through Firebase Auth.
- Timezone is automatically detected.
- Language opens a bottom sheet with English only.
- Notifications are Off and reserved for future development.
- Backup section supports Sync now and Restore backup for signed-in users.
- Account section links to Manage reading plans.
- Help & feedback bottom sheet includes FAQ and feedback form.
- Signed-in feedback uses account email internally; guest users can enter email.

## Admin Current UX

The web admin dashboard supports:

- Plan template create/edit/publish/archive
- Plan sections and chapter ranges
- Cloudinary cover image upload
- Today’s Message create/edit/publish/delete
- Today’s Message image upload
- Today’s Message article fields and related plan selection

## Completion Policy

When all chapters in a plan run are complete:

1. Mark plan `completion_ready`.
2. Show completion dialog.
3. If confirmed, create one `plan_completion_events` row.
4. Mark plan `completed`.
5. Remove it from Current.
6. Keep it visible in Completed history.

Completed plans are read-only for now. To read again, start a new run from Catalog or Completed `Start Again`.

Archive policy:

- Archive hides an active/current run without deleting progress or reading history.
- Restore moves the archived run back to Current and makes it active.

## Current Launch Definition

Closed-test MVP should include:

- Home Today’s Message working with published server content.
- Read flow stable for at least one active plan.
- Plans screen can start, continue, archive, restore, and start again.
- Settings sign-in, Sync now, Restore backup, and Help & feedback work.
- Discover/Saved remain hidden.
- Privacy, Terms, and Support pages exist.
- Android closed testing build passes basic manual QA.

## Near-Term Priorities

### 1. Closed Testing Cleanup

Use `docs/to-do/MVP_CLOSE_TESTING_TODO.md` as the active checklist.

Focus:

- Release configuration
- Seed/publish real content
- Manual QA
- Store copy / release notes
- Backup/restore sanity checks

### 2. Plan Detail Screen

Add detail view for a plan before starting:

- Cover image
- Description
- Sections preview
- Estimated time/days
- Tags
- Optional intro/prologue

### 3. More Published Plans

Minimum useful launch set:

- Bible in a Year
- The Story of Joseph
- Gospel of Mark
- Psalms for Anxiety
- Life of David

Each should be created through the same template/section/item model and published in admin.

### 4. Today’s Message Content Pipeline

Prepare a small calendar of real messages:

- Verse reference
- Bible version
- Licensed/allowed verse text or reference-only fallback
- Image
- Quick reflection
- Article body
- Related plan

### 5. Sync Polish

The backup/restore foundation exists. Next work should improve:

- User-facing error states
- App-start sync timing
- Conflict telemetry
- Incremental pull only if bootstrap becomes too heavy

### 6. Saved / Discover Scope

Do not re-enable Discover/Saved until there is a real content source or a very small committed scope.

Possible first Saved scope:

- saved Today’s Messages
- saved plans

Avoid full Bible text storage unless product scope changes.

## Later Ideas

- Plan detail media
- Plan tags and filtering in Catalog
- Reflection prompts
- Section intro content
- Completion messages
- Rewards/badges
- Push notifications
- Account statistics and lifetime unique chapters read

## Product Guardrails

- Keep the first screen useful, not a marketing page.
- Keep Read workflows fast and ergonomic.
- Do not make users distinguish sign-up vs sign-in for Google Auth.
- Keep plan definitions separate from user progress.
- Keep reading activity separate from current progress state.
- Archive should preserve progress and statistics.
- Keep Neon behind API routes; mobile should not connect to Neon directly.
