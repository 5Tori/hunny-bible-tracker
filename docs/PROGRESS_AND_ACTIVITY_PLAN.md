# Progress vs account activity — architecture plan

This document turns the agreed product principles into a **concrete plan for Hunny Bible Tracker**: what to compute per plan, what to compute per account (or future user), and how our existing SQLite / Drift tables evolve. It incorporates **review feedback** (local identity early, idempotent activities, clearer averages, plan-completion UX, sync conflict rules, phased delivery).

## Guiding principle

**Plan progress is plan-scoped. Habits (streak, reading days, aggregate activity) are account-scoped. Lifetime Bible coverage is a future, cross-plan metric.**

That separation keeps multi-plan behaviour intuitive and avoids double-counting streaks when the user reads in two plans on the same day.

### Why not merge progress and activity

| Store | Question it answers |
|-------|---------------------|
| `chapter_progress_entries` | *In this plan, is this chapter checked right now?* (mutable **current state** per `plan_id` + chapter.) |
| `reading_activities` | *When did this person perform a read-related action?* (immutable **event log** for history, streak, reading-day derivation.) |

Mixing the two into one model makes streak logic, uncheck, multi-plan, and sync **almost guaranteed to tangle**. Keep them separate in schema, queries, and product copy.

---

## 1. Three conceptual layers

### 1.1 Plan progress (per `user_reading_plans.id`)

**Question answered:** “How far am I in *this* plan?”

- Numerator: chapters marked complete **in that plan** (`chapter_progress_entries` where `plan_id` matches and `is_completed` is true).
- Denominator: chapters in scope (`plan_scope_chapters` for that `plan_id`).
- Book-level progress: same rows, grouped by `book_key`.

**Rule:** Completing Genesis 1 in Plan A only moves Plan A’s bar. Plan B is unchanged until the user completes a chapter in Plan B.

**Current codebase:** `ReadRepository.getBooksWithProgress`, `getChaptersForBook`, `getOverviewStats` (partially plan-scoped today).

---

### 1.2 Account activity (per **local user**, then Neon user after auth)

**Question answered:** “Did I show up to read today, across any plan?”

Used for:

- **Reading day:** ≥1 qualifying completion in a calendar day (user’s timezone).
- **Streak:** consecutive reading days — **at most one increment per calendar day**, regardless of how many plans were read.
- Later: totals, longest streak, first/last read date.

**Rule (v1):** Any day with **≥1** chapter completed in **any** plan → that calendar day counts **once** for streak / reading day.

**Identity:** Introduce **`local_users`** and `local_user_id` **before** remote auth (see §3). Until auth, the app creates **one guest** row at first launch; all plans and rows point at it. Login later **merges** device data to `auth_user_id` with a controlled migration instead of inventing identity at sync time.

---

### 1.3 Lifetime Bible coverage (future)

**Question answered:** “Across my whole life in the app, how much of the Bible have I touched at least once?”

- **Total completion events:** count of “complete” events over time (can exceed 1189).
- **Unique chapters read:** distinct `(book_key, chapter_number)` ever completed (policy tied to §5 idempotent activity — each *first* completion per day/chapter still one semantic “touch” for many metrics).

**MVP:** No dedicated UI. Keep logs **append-friendly / non-destructive** so lifetime metrics can be derived later.

---

## 2. Cross-plan scenarios (policy)

### 2.1 Same calendar day, two plans

| Layer | Outcome |
|--------|---------|
| Plan A progress | Genesis 1 complete for A |
| Plan B progress | Matthew 1 complete for B |
| Account reading day | That calendar day counts **once** |
| Account streak | **+1** day in streak logic, not +2 |

### 2.2 Plan A finished, then Plan B starts

| Entity | Outcome |
|--------|---------|
| Plan A | `status = completed`, `completed_at` set; progress remains 100% |
| Plan B | New plan instance; progress from 0% within B’s scope |
| Account | Streak and reading-day aggregates **continue** |

---

## 3. Local user identity (recommended **now**, not at auth time)

**Review:** Add `local_user_id` at the local DB stage so remote auth migration is safer.

### 3.1 Table: `local_users` (new)

| Column | Notes |
|--------|--------|
| `id` | PK (uuid) |
| `type` | `guest` \| `authenticated` (or enum text) |
| `auth_user_id` | nullable; set when linked to Neon |
| `created_at`, `updated_at` | |

**MVP behaviour:** On first launch, insert **one** guest `local_users` row. All app data references `local_user_id =` that id. No multi-profile UI required.

### 3.2 Add `local_user_id` to owning tables

| Table | Purpose |
|-------|---------|
| `user_reading_plans` | Which user owns this plan instance |
| `chapter_progress_entries` | Scoped reads / sync |
| `reading_activities` | Account-level streak queries filter by this |

Existing rows need a one-time migration: set `local_user_id` to the default guest id.

---

## 4. Data model mapping (this repo + planned columns)

Drift definitions live in `apps/mobile/lib/core/database/app_database.dart`.

| Table | Role |
|-------|------|
| `local_users` | **New.** Canonical “who on this device” before cloud id. |
| `user_reading_plans` | Plan instance. **Add:** `local_user_id`, `status` (`active` \| `paused` \| `completed` \| `archived`), `started_at`, `completed_at` (nullable). **Recommendation:** add lifecycle columns **early**; UI can ignore them until “complete plan” ships. `is_active` can coexist with `status` during transition; long-term prefer `status` as source of truth. |
| `plan_scope_chapters` | Denominator for plan %. |
| `chapter_progress_entries` | **Plan progress source of truth** per `(plan_id, book_key, chapter_number)`. **Add:** `local_user_id`. |
| `reading_activities` | **Account-activity log** for streak / reading-day / history. **Add:** `local_user_id`. Keep `plan_id` for forensics. |

Naming in code: `ChapterProgressEntries`, `ReadingActivities`.

---

## 5. Uncheck policy + activity idempotency

### 5.1 Uncheck does not erase history used for streak

Toggling **off** updates `chapter_progress_entries` (plan %) but **does not delete** existing `reading_activities` rows that recorded a **complete** for streak / reading-day purposes.

Rationale: uncheck corrects **plan bookkeeping**; the user still *acted* that day. Streak should not disappear due to a mistaken tap.

### 5.2 Prevent duplicate “complete” rows (same day, same chapter)

**Problem:** check → uncheck → check again on the same day inserts multiple `complete` rows and can inflate “activity” counts.

**Recommendation (MVP):** Do **not** insert a second `complete` activity for the same logical event key:

**Unique constraint (SQLite):**

```text
UNIQUE (
  local_user_id,
  plan_id,
  book_key,
  chapter_number,
  activity_date,
  action
)
```

Where `activity_date` is the calendar bucket string (e.g. `yyyy-MM-dd`) already used today. `action = 'complete'`.

Effects:

- First check that day → insert row.
- Uncheck → update **progress** only; activity row **remains** (§5.1).
- Re-check same day → **no new** activity row (idempotent); streak / reading day unchanged (still counted that day once).

**Future:** If product needs a **full forensic timeline** (every toggle), add a separate `reading_activity_events` table or stream; keep `reading_activities` (or the unique key above) as the **streak-safe summary** layer. Out of MVP scope unless required.

---

## 6. Reading day computation: Option A (MVP) vs Option B (future)

| Option | Mechanism | Pros / cons |
|--------|-----------|----------------|
| **A — MVP** | Derive reading days from `reading_activities` (distinct `activity_date` where `action = complete`, scoped by `local_user_id`). | Simple, no extra table. Streak = function of distinct dates. |
| **B — Future** | Add `reading_day_entries` (`local_user_id`, `activity_date`, `timezone`, `first_activity_at`, `chapter_count`, …). | Simpler streak math, easier multi-device merge (“one row per user per day”). |

**Plan:** Ship **A** first. Document **B** as an explicit future optimization when sync load or query cost justifies it.

---

## 7. Averages and Home copy (must be unambiguous)

“Averages” differ by **scope** and **denominator**:

| Metric | Meaning |
|--------|--------|
| A — Avg in **current plan** | Chapters completed in plan P ÷ reading days that included any activity in P (or plan-scoped definition — pick one and document in code). |
| B — Account avg | All plans, same user, over account reading days. |
| C — Per reading-day vs calendar-day | Denominator is “days with ≥1 read” vs “all calendar days”. |

**MVP Home recommendation:**

- Show **current plan** progress (chapters / in-scope %).
- Show **account** streak.
- If showing an average: **“Avg in this plan”** (or equivalent explicit label) so it cannot be read as lifetime or account-global unless we intend that.

**Later Stats screen:** split labels explicitly, e.g. “Account avg chapters / reading day”, “Current plan avg …”, “Lifetime total completions”, “Unique chapters read”.

---

## 8. Plan completion UX (when progress hits 100%)

When all in-scope chapters are complete:

- **Do not** silently flip `status` to `completed` without user confirmation (mis-taps happen).
- **Do** detect `progress == 100%` while `status` is still `active`.
- **UI:** e.g. “You’ve checked every chapter in this plan. Mark it complete?” + primary **Complete plan** CTA.
- **On confirm:** `status = completed`, `completed_at = now()` (and optionally deactivate in favour of next plan per product rules).

Preserves completed plan history for Stats and for “Plan B started after Plan A” narratives (§2.2).

---

## 9. Sync-ready fields and conflict rules (forward-looking)

When Neon / multi-device sync lands, expect:

| Concern | Suggested fields (conceptual) | Notes |
|---------|------------------------------|--------|
| Outbox / merge | `sync_status`, nullable `server_id`, `last_synced_at`, `client_revision` (or version) | Many already partially exist as `sync_status` — extend consistently. |
| Tombstones | `deleted_at` where soft-delete applies | Already on some tables. |

**Conflict policy (normative):**

| Data type | Rule |
|-----------|------|
| **`chapter_progress_entries`** (current state) | **Latest write wins** per `(plan_id, book_key, chapter_number)` using `updated_at` / revision (LWW). Two devices: one checked, one unchecked → one resolved state. |
| **`reading_activities`** (log) | **Append / merge; do not delete** competing device events for audit. Streak and reading-day use **idempotent** keys (§5.2) or derived `reading_day_entries` (§6B) so duplicates do not double-count. |

Document this in `docs/SYNC_PLAN.md` when implementation starts; keep this file as the **product + local schema** source of truth.

---

## 10. v1 policy checklist (north star)

1. Plan % and chapter counts are **always per `plan_id`** (via `chapter_progress_entries`).
2. Streak and reading days are **per `local_user_id`** (then Neon user), **not** per plan.
3. ≥1 chapter completed in **any** plan on a calendar day → that day counts **once** for streak / reading day.
4. Multiple plans same day → **one** streak day.
5. New plan after completing another → **no** account streak reset.
6. **Never** merge progress and activity semantics in one table.
7. **Uncheck** updates progress only; **do not** delete streak-relevant `complete` activity; **no duplicate** complete per §5.2 unique key.
8. Home labels distinguish **plan** vs **account** metrics (§7).
9. MVP: minimal Stats; lifetime metrics later (§1.3).

---

## 11. Implementation phases (review order)

| Phase | Work |
|-------|------|
| **A — Split stats queries** | Separate `getPlanProgressStats(planId)` vs `getAccountActivityStats(localUserId)` (or equivalent); Home/Read use correct scope; labels in UI match §7. |
| **B — Local user** | Add `local_users`, `local_user_id` on `user_reading_plans`, `chapter_progress_entries`, `reading_activities`; migration + default guest bootstrap. |
| **C — Uncheck + idempotency** | Enforce §5.1–5.2: no duplicate `complete` per unique key; streak reads from activity (or distinct dates), not from re-check churn. |
| **D — Plan lifecycle columns** | Add `status`, `started_at`, `completed_at` to `user_reading_plans`; default `active` / `started_at = created_at` for existing rows. |
| **E — Sync-ready metadata** | Align `sync_status`, server ids, revisions across hot tables per `SYNC_PLAN.md`. |
| **F — Auth / sync** | Link `local_users.auth_user_id`, merge device, server reconciliation. |
| **G — Lifetime stats** | Unique chapters, total completions, aggregates — optional `reading_day_entries` (§6B). |

---

## 12. Related docs

- `docs/PRODUCT_PLAN.md` — v0.1 scope and tabs.
- `docs/SYNC_PLAN.md` — extend with §9 conflict rules when implementing sync.
- `docs/DISCOVER.md` — unrelated; listed for index only.

---

## 13. One-line summary

**Progress answers “this plan”; streak and reading days answer “this person” — backed by separate tables, a stable local user id, idempotent completion logs, and explicit UI labels.**
