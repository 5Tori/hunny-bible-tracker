# Reading stats / streak / activity grid

**Habit layer #6** in `CURRENT_FOCUS.md`. Daily reading goal + today minutes shipped in `4a070fd`.

## Decisions (locked)

| Topic | Choice |
| --- | --- |
| **Placement** | Settings screen bottom only — no dedicated screen |
| **Streak** | Strict: no reading today → streak `0` (existing logic) |
| **Grid** | Rolling ~12 months, GitHub / habit-tracker style — **horizontal scroll**, weeks as columns, Sun–Sat rows |
| **Language** | English UI |

## Shipped building blocks

| Piece | Location |
| --- | --- |
| Activity log | `reading_activities` (Drift) |
| Current streak | `_calculateCurrentStreak` → Home/Read chip + Settings panel |
| Longest streak | `_calculateLongestStreak` |
| Rolling year grid | `getAccountReadingStats()` → `ReadingActivityYear` |
| Settings UI | `ReadingActivityPanel` at bottom of Settings |

## Data API

```dart
Future<AccountReadingStats> getAccountReadingStats({DateTime? anchorDate});
```

Returns streak totals, range counts, and `activityYear.weekColumns` (oldest → newest; scroll starts at latest week).

Cell states: no reading · read · goal met (when daily goal > 0).

## Out of scope

- Dedicated stats screen / streak chip navigation
- Monthly pager
- Push notifications · server RPC · per-plan filter

## Tests

`apps/mobile/test/reading_activity_stats_test.dart`

## Manual QA

1. Mark a chapter today → Settings shows streak ≥ 1 and today cell filled.
2. No reading today → streak `0`; past days still visible in grid.
3. Set daily goal; read enough minutes → darker “Goal met” cell.
4. Horizontal scroll lands on the most recent weeks.
5. Backup restore → grid matches restored activities.
