# Hunny Bible Tracker — MVP Progress & Next Steps

> Recommended repo path: `docs/MVP_PROGRESS_AND_NEXT_STEPS.md`

## 1. Current MVP Status

Hunny Bible Tracker is now beyond the idea/prototype stage. The project has a solid offline-first foundation and a stabilized Read flow.

Estimated progress:

```text
Offline-first Read MVP: 85–90%
Public-launch MVP: 55–65%
Cloud backup/sync MVP: 35–45%
```

The most mature areas are:

```text
- Read tab
- Plan template / section / range structure
- User plan runs
- Chapter-level progress
- Plan completion flow
- Completed plan history
- Start Again / new run flow
- Firebase Google Sign-In
- Basic Settings account UX
- Read Flow QA & Stabilization completed
```

The main unfinished areas are:

```text
- Remote reading-data sync
- Apply/deploy server schema for reading data
- Plan detail screen
- More published plans
- Home / Discover / List production scope
- Release readiness
```

---

## 2. Current Product Shape

The app is moving toward a **guided Bible reading pack app**, not just a simple chapter checklist.

Core product loop:

```text
Browse Plans
  -> add/start a reading journey
  -> read section/book/chapter progress
  -> finish a plan
  -> keep completed history
  -> start again when desired
```

The app does not store full Bible text in v0.1. It stores:

```text
- Bible book/chapter references
- Plan templates
- Plan sections
- Chapter ranges
- User plan runs
- Resolved user plan chapters
- Chapter progress
- Reading activities
- Completion events
- Local settings
- Account-link metadata
```

---

## 3. Current Architecture Summary

Runtime shape:

```text
Flutter mobile app
  -> Drift / SQLite local database
  -> Firebase Auth SDK
  -> optional Next.js API calls

Next.js web/API app
  -> Firebase Admin SDK token verification
  -> Neon Postgres
```

Important boundaries:

```text
- Mobile writes reading data locally first.
- Mobile should not connect directly to Neon.
- Firebase Auth owns identity.
- Neon stores app data behind API routes.
- Current server sync only supports auth user upsert.
- Reading progress sync is not implemented yet.
```

---

## 4. Current Data Model Summary

Current conceptual model:

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

Important principles:

```text
Template data defines what a plan is.
User plan data snapshots one user's run of that plan.
Later template edits should not rewrite already-started user plan runs.
```

Key local tables:

```text
bible_books
local_users
plan_templates
plan_template_sections
plan_template_items
plan_tags
plan_template_tags
user_reading_plans
user_plan_chapters
chapter_progress_entries
reading_activities
plan_completion_events
app_settings
```

Core split:

```text
Plan progress = user_plan_id scoped
Streak / reading days = local_user_id scoped
Completion history = one event per finished user plan run
```

---

## 5. What Is Already Working Well

### 5.1 Read Tab Foundation

The Read tab is the strongest part of the app.

Current implemented expectations:

```text
- Top plan title opens My Plans sheet
- My Plans has Current and Completed tabs
- Current shows active/current plan runs
- Completed shows finished plan run history
- Browse Plans opens catalog
- Catalog cards show plan type, title, description, chapter count, estimated time
- In-progress plans are labelled
- Completed templates show Completed once / Completed N times
- Completed templates can be started again
- Chapter grids can be read in any order
- Plan completion requires confirmation
```

### 5.2 Section/Range Plan Model

The current model supports both canonical and story-based plans.

Examples:

```text
Bible in a Year
  -> Old Testament
  -> New Testament

Samuel Story
  -> Before Samuel
  -> Young Samuel
  -> Samuel and Saul
```

This proves the structure can support plans like:

```text
- Life of Joseph
- Life of David
- Psalms for Anxiety
- Gospel of Mark
- Parables of Jesus
- Women of the Bible
```

### 5.3 Completion / Start Again Policy

Current completion flow is directionally correct:

```text
1. User completes all chapters in a plan run.
2. Plan becomes completion_ready.
3. Completion dialog appears.
4. User confirms finish.
5. One plan_completion_events row is created.
6. Plan status becomes completed.
7. Plan is removed from Current.
8. Plan remains visible in Completed.
9. User can Start Again from Browse Plans.
10. Start Again creates a new user plan run.
```

Recommended policy to keep:

```text
Completed plans are read-only.
To read again, create a new run.
Completion event should occur once per user_plan_id.
```

### 5.4 Firebase Auth Direction

The move to Firebase Auth is a good fit for native iOS/Android Google Sign-In.

Recommended identity model:

```text
Guest-first usage
Continue with Google
Firebase uid stored in local_users.auth_user_id
Optional API call upserts auth user into Neon
No separate Sign up / Sign in distinction for Google Auth
```

---

## 6. Main Gaps Before MVP

### 6.1 Remote Progress Sync

Current sync status:

```text
Implemented:
- Firebase login
- Firebase token verification
- Neon auth_users upsert

Not implemented:
- user_reading_plans sync
- user_plan_chapters sync
- chapter_progress_entries sync
- reading_activities sync
- plan_completion_events sync
- app_settings sync
```

This means:

```text
The user can sign in, but reading progress is still local-only.
```

This is acceptable for an offline-first internal MVP, but not ideal for public launch unless the product clearly communicates that progress is currently device-local.

### 6.2 Server Schema

Current server schema is reliable only for auth support.

Before remote sync, server schema should be expanded to align with the current local model:

```text
plan_templates
plan_template_sections
plan_template_items
user_reading_plans
user_plan_chapters
chapter_progress_entries
reading_activities
plan_completion_events
sync cursors / metadata
```

### 6.3 Home / Discover / List Scope

Current tab maturity:

```text
Home: useful but partly mock-driven
Discover/Find: local mock catalog and filters
Read: production-quality area
List: placeholder
Settings: good MVP foundation
```

Before public MVP, decide whether Home/Discover/List are:

```text
A. Real MVP features
B. Coming Soon placeholders
C. Reduced/hidden until ready
```

Recommended:

```text
Home: keep useful, Read-focused
Discover: keep as lightweight local mock or hide server promises
List: Coming Soon or very small first scope
```

### 6.4 Server-Managed Plan Content

The mobile app no longer seeds built-in plan templates. Plan content should be created in the web admin dashboard, published to Neon, and downloaded by mobile through `/api/v1/plans`.

Minimum recommended launch set:

```text
- Bible in a Year
- Samuel Story
- Life of Joseph
- Life of David
- Gospel of Mark
- Psalms for Anxiety
```

These should all use the same template/section/item model.

### 6.5 Plan Detail Screen

Browse Plans currently has catalog cards. The next UX step is a proper plan detail screen.

Recommended fields:

```text
- Cover image
- Title
- Subtitle
- Short description
- Full description
- Plan type
- Total chapters
- Estimated minutes
- Estimated days
- Sections preview
- Tags
- Start / Continue / Start Again CTA
```

This is important because the product direction is closer to “reading packs” than a plain checklist.

---

## 7. Recommended Next Work Order

### Priority 1 — Read Flow QA & Stabilization

Status: completed.

Note: Manual QA/stabilization for the Read flow has already been completed and should not be treated as the next open MVP task. Automated coverage can be added later, but current MVP development is prioritizing fast delivery and deploy readiness.

Goal: make the current Read experience reliable.

Test cases:

```text
Fresh install
  -> default user created
  -> default plan created
  -> Bible in a Year opens correctly

Browse Plans
  -> Samuel Story appears
  -> Add/Start works
  -> user_plan_chapters snapshot is created

Read
  -> section selector works
  -> book grid works
  -> chapter grid works
  -> chapter check/uncheck persists
  -> book/section/plan progress updates correctly

Completion
  -> last chapter triggers completion_ready
  -> dialog appears
  -> Finish creates one completion event
  -> completed plan disappears from Current
  -> completed plan appears in Completed

Start Again
  -> completed template shows Start Again
  -> new user_plan_id is created
  -> old completion history remains
  -> new run starts at 0%
```

Implementation notes:

```text
- Verify all progress queries use user_plan_id, not legacy plan_id.
- Verify denominator is user_plan_chapters, not old plan_scope_chapters.
- Verify reading_activities are insert-or-ignore for same-day duplicate completion.
- Verify uncheck does not delete reading activity history.
```

### Priority 2 — Completed Plan Polish

Goal: make completed history feel intentional and rewarding.

Completed card should show:

```text
- Plan title
- Completed date
- Run number or completion count
- Total chapters
- Optional estimated reading time
- Start Again CTA
```

Example:

```text
Samuel Story
Completed 2 times
Last completed May 14, 2026
31 chapters

[Start Again]
```

Recommended behavior:

```text
My Plans > Current:
- active
- completion_ready
- not-started but subscribed/current runs

My Plans > Completed:
- completed runs only

Browse Plans:
- In Progress if active run exists
- Completed once / Completed N times if completion history exists
- Start Again if no active run exists and completed history exists
```

### Priority 3 — Plan Detail Screen

Goal: make Browse Plans feel like a real plan catalog.

Flow:

```text
Browse Plans
  -> tap plan card
  -> Plan Detail
  -> Add to My Plans / Continue / Start Again
```

Plan Detail v1:

```text
Cover image
Title
Subtitle
Description
Total chapters
Estimated time
Estimated days
Sections preview
Tags
CTA
```

Sections preview example:

```text
Samuel Story

Before Samuel
- Ruth 1–4
- 1 Samuel 1–2

Young Samuel
- 1 Samuel 3–7

Samuel and Saul
- 1 Samuel 8–15
```

Keep the first version simple. Prologue video/images can come later.

### Priority 4 — Add More Built-in Plans

Goal: make the app feel useful beyond a demo.

Recommended initial pack list:

#### 4.1 Life of Joseph

Possible range:

```text
Genesis 37
Genesis 39–50
```

Potential sections:

```text
Dreams and Betrayal
Joseph in Egypt
Famine and Forgiveness
```

Metadata:

```text
testament_scope: old
plan_type: story
primary_book_key: genesis
primary_character: Joseph
tags: Joseph, forgiveness, waiting, family, restoration
```

#### 4.2 Life of David

Possible ranges:

```text
1 Samuel 16–31
2 Samuel 1–24
selected Psalms later if desired
```

Potential sections:

```text
Anointed and Hidden
David and Saul
David as King
```

#### 4.3 Psalms for Anxiety

Possible structure:

```text
Psalm 23
Psalm 27
Psalm 34
Psalm 42
Psalm 46
Psalm 91
Psalm 121
Psalm 139
```

Potential sections:

```text
Peace
Fear
Trust
Rest
```

#### 4.4 Gospel of Mark

Range:

```text
Mark 1–16
```

Potential sections:

```text
Beginning of the Good News
Jesus' Authority
The Way to the Cross
Resurrection
```

### Priority 5 — Home MVP Cleanup

Goal: make Home useful without pretending unfinished systems are live.

Recommended Home MVP:

```text
- Greeting
- Current plan progress
- Continue Reading CTA
- Current streak / reading days
- Featured plan or simple static message
```

Avoid overcommitting to server-driven content until Discover/Today’s Message backend exists.

Recommended copy:

```text
Continue your reading journey
Pick up where you left off.
```

### Priority 6 — List Tab Scope Decision

Option A: keep as Coming Soon.

```text
Saved items are coming soon.
Soon you’ll be able to save verses, notes, and content here.
```

Option B: implement very small first scope.

```text
Saved references
Simple notes
Saved plans
```

Recommended for speed:

```text
For MVP, keep List as Coming Soon unless there is enough time to implement saved references cleanly.
```

Do not introduce full Bible text storage unless the product scope changes.

### Priority 7 — Remote Sync v1

Status: ready to start now for MVP as a narrow backup-first scope.

Goal: back up the user’s reading data safely.

Recommended minimum sync scope:

```text
- user_reading_plans
- user_plan_chapters
- chapter_progress_entries
- reading_activities
- plan_completion_events
```

Recommended triggers:

```text
- App start
- Existing Firebase session refresh, throttled by last sync time
- Network reconnect
- Manual Settings -> Sync now
- Debounced after local mutations
```

Recommended v1 API:

```text
POST /api/v1/sync/push       first
GET  /api/v1/sync/bootstrap  manual restore
POST /api/v1/sync/pull       later if needed
```

Recommended MVP cut:

```text
Start with push-only backup for signed-in users.
Do not block launch on full multi-device merge UI.
Use manual restore/bootstrap before adding automatic merge.
```

Conflict policy:

```text
chapter_progress_entries:
  latest updated_at / client_revision wins

reading_activities:
  insert-or-ignore / append-friendly

plan_completion_events:
  unique(user_plan_id), insert-once

user_plan_chapters:
  upload together with user_reading_plans as immutable-ish snapshot
```

Settings UI:

```text
Sync status
Last synced at
Sync now
Backup explanation
```

Recommended copy:

```text
Your progress is saved on this device.
Sign in and sync to back it up.
```

### Priority 8 — Release Readiness

Before TestFlight / Play internal testing:

```text
- Confirm production app name
- Confirm Android applicationId
- Confirm iOS Bundle ID
- Register Firebase release SHA-1 and Play App Signing SHA-1
- Confirm Firebase iOS Bundle ID
- Confirm privacy page
- Confirm terms page
- Confirm support page
- Run flutter analyze
- Run flutter test
- Run flutter build apk --debug
- Run flutter build ios --simulator --debug
- Create release build scripts
```

Important current note:

```text
iOS Bundle ID is currently documented as com.example.hunnyBibleTracker.
Before release, replace this with the intended production Bundle ID.
```

---

## 8. Recommended MVP Definition

### 8.1 Offline MVP

This can be considered complete when:

```text
- User can open the app without account
- User can browse plans
- User can add/start a plan
- User can switch active plans
- User can read any section/book/chapter in any order
- Progress persists after app restart
- Plan can be completed
- Completed history is visible
- User can start the same template again
- Basic Home points back to Read
- Settings account UI works
```

### 8.2 Public MVP

This can be considered ready when Offline MVP is complete plus:

```text
- Plan Detail screen exists
- At least 5–6 published plans exist
- Completed history looks polished
- Home is useful and not misleading
- List/Discover unfinished areas are clearly scoped
- Firebase release configuration is correct
- Privacy/Terms/Support pages exist
- Basic QA passes on iOS and Android
```

### 8.3 Backup MVP

This can be considered ready when Public MVP is complete plus:

```text
- User can sign in
- User can Sync now
- Progress uploads to server
- Progress can be restored after reinstall
- Completion history restores correctly
- Last synced at is shown
- Sync errors are understandable
```

---

## 9. Suggested Work Breakdown for Agents

### Agent Task 1 — Read Flow QA

```text
Audit and test the current Read flow.

Focus:
- user_plan_id usage
- section/range rendering
- user_plan_chapters as denominator
- check/uncheck persistence
- completion_ready transition
- finishPlan idempotency
- Start Again new-run behavior

Deliver:
- bug list
- fixes
- short test checklist
```

### Agent Task 2 — Completed Plan Polish

```text
Improve Completed Plans UI.

Requirements:
- show completed date
- show run number or completion count
- show total chapters
- show Start Again CTA
- keep completed plans read-only
- ensure My Plans Current only shows active/current runs
```

### Agent Task 3 — Plan Detail Screen

```text
Build Plan Detail screen from Browse Plans.

Requirements:
- cover image
- title/subtitle/description
- total chapters
- estimated time/days
- sections preview
- tags if available
- CTA state: Add / Continue / Start Again
```

### Agent Task 4 — Admin Plan Content

```text
Create and publish plan templates in the admin dashboard using the current section/range model.

Plans:
- Life of Joseph
- Life of David
- Psalms for Anxiety
- Gospel of Mark

Deliver:
- seed data
- metadata
- sections/items
- manual QA that each creates valid user_plan_chapters
```

### Agent Task 5 — Remote Sync Design

```text
Design and implement sync v1.

Start with:
- server schema aligned to current local model
- auth-scoped push endpoint
- idempotent upserts for activities/completions
- bootstrap/pull endpoint
- Settings Sync now UI

Do not connect mobile directly to Neon.
```

---

## 10. Final Recommendation

The next best sequence is:

```text
1. Remote Sync v1 push-only backup
2. Settings Sync now / last synced / restore UX
3. Plan Detail screen
4. Add more published plans
5. Home MVP cleanup
6. List tab scope decision
7. Incremental pull/merge sync
8. Release readiness
```

Do not start with complex rewards, admin dashboard, or server-driven content yet.

The Read flow foundation is complete enough for fast MVP development. The best next move is to add a narrow, reliable backup path for signed-in users without taking on full sync complexity all at once.
