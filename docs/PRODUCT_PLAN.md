# Hunny Bible Tracker — Product Plan v0.1

## Product direction

Hunny Bible Tracker starts as an offline-first Bible chapter tracker. The app is not a Bible text reader in v0.1. It stores references, reading plans, progress, and activity logs.

## Core tabs

- Home
- Find
- Read
- List
- Settings

## v0.1 target

The Read tab is the first production-quality area.

### Included

- Bottom tab shell
- Initial state for all five tabs
- Whole Bible reading plan
- Multiple-plan-ready data model
- Book grid with progress
- Chapter grid with check/uncheck
- Local persistence
- Current plan progress
- Streak-ready reading activity log
- Last opened plan/book memory
- Firebase Auth account link

### Excluded from v0.1

- Remote sync
- Admin dashboard
- Today's message feed
- Curated contents
- Saved list features
- Verse text storage

## Read interaction

- Books are shown in a 3-column grid.
- Selected book opens its chapters.
- Chapters are shown in an 8-column grid.
- Tapping a chapter toggles complete/incomplete.
- Users can read in any order.
- One user can eventually run multiple plans at the same time.

## Streak policy

- A day counts if the user completes at least one chapter.
- The user's timezone is used.
- Offline local device time is the source for v0.1.
- Progress and activity logs are separate.

## Future features

- Optional account for backup
- Automatic + manual sync
- Guided reading pack catalog and section/range plan templates (`docs/PLAN_STRUCTURE_REFACTOR.md`)
- Today's message
- Curated content
- Find by keyword/topic/length
- Saved verse references and verse text
- Notes
