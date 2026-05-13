# Discover tab — UI, data model, and filter rules

This document describes the **Discover** screen (`apps/mobile/lib/features/find/`) so backend and future API work can align with the same structure.

## File map

| File | Role |
|------|------|
| `discover_screen.dart` | `DiscoverScreen` — layout, local filter state, list rendering |
| `discover_models.dart` | `DiscoverLength`, `DiscoverContentItem` — domain types |
| `discover_mock.dart` | `discoverCatalog`, keyword/topic option lists, count helpers |

Replace `discover_mock.dart` with an API repository when online content exists; keep `DiscoverContentItem` (or evolve it) as the DTO shape.

## Screen sections (top → bottom)

1. **Title + subtitle** — “Discover” / “Browse by what you need today.”
2. **Search** — free text; filters the catalog (see rules below).
3. **Active filter chips** — shown only when something is active (search non-empty and/or any keyword, topic, or length). Each chip is removable (tap chip). **Clear all** resets search + all sets.
4. **BY KEYWORD** — wrap of toggles; multi-select `Set<String>`.
5. **BY SITUATION / TOPIC** — vertical rows; multi-select `Set<String>`. Count badge = number of catalog items whose `topicTags` contains that topic.
6. **BY LENGTH** — three cards (`Quick` / `Medium` / `Deep dive`); multi-select `Set<DiscoverLength>`. Count badge = items with that `length` enum.
7. **RESULTS (N)** — only when at least one filter is active (including search). `N` = number of items passing **all** filter dimensions. Empty state copy if `N == 0`.
8. **ALL CONTENT** — full `discoverCatalog` in fixed order; always visible below. Used for browsing when the user scrolls past filters (matches design mock).

## Data model: `DiscoverContentItem`

| Field | Type | Meaning |
|-------|------|---------|
| `id` | `String` | Stable id for list keys / API |
| `title` | `String` | Card title (e.g. devotional title) |
| `reference` | `String` | Scripture or source line (e.g. `Psalm 46:10`) |
| `durationMinutes` | `int` | Length in minutes (drives pill + length bucket) |
| `keywordTags` | `Set<String>` | Subset of BY KEYWORD labels attached to this item |
| `topicTags` | `Set<String>` | Subset of BY SITUATION / TOPIC labels |
| `length` | `DiscoverLength` | `quick` / `medium` / `deep` — must stay consistent with `durationMinutes` |
| `highlightTag` | `String` | Tag to show with accent in **ALL CONTENT** when no filters are active (design: one highlighted tag per card) |

**Length buckets (authoring rule, must match UI copy):**

- `quick`: duration &lt; 5 minutes  
- `medium`: 5 ≤ duration &lt; 15 minutes  
- `deep`: duration ≥ 15 minutes  

## Filter semantics (implementation reference)

Let **active** mean: trimmed search is non-empty **or** `_keywords` non-empty **or** `_topics` non-empty **or** `_lengths` non-empty.

### Search text

If non-empty after trim, item matches only if **any** of:

- `title` contains query (case-insensitive), or  
- `reference` contains query, or  
- any tag in `allTags` contains query (substring, case-insensitive).

### Keywords (AND)

If `_keywords` is non-empty, item matches only if **every** selected keyword is in `item.keywordTags`.

### Topics (AND)

If `_topics` is non-empty, item matches only if **every** selected topic is in `item.topicTags`.

### Length (OR within dimension)

If `_lengths` is non-empty, item matches if `item.length` is **in** `_lengths` (selecting both Quick and Medium shows items that are either quick or medium).

### Combined

Item is in **RESULTS** iff it passes search (if any) **and** keywords **and** topics **and** length (if any length filters).

## Tag chips on result cards

- If a tag is in the active keyword or topic selection → **accent** (yellow fill + ink border).  
- If there are **no** active filters → accent the tag equal to `item.highlightTag` only.  
- Otherwise → neutral chip (white fill, border).

## API migration notes

- Return the same logical fields as `DiscoverContentItem`; map server `tags` into `keywordTags` vs `topicTags` with a known taxonomy, or return them split.  
- Counts for topic rows and length cards can be computed server-side or from a cached facet response.  
- **Active chips** should mirror server-side filter params when syncing URL or deep links (e.g. `?kw=Faith&topic=Anxiety`).

## Related UI

Bottom tab label is **Discover** (`root_shell.dart`). Navigation styling is independent of this module.
