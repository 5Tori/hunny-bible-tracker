# Database seeds (closed testing)

Manual test SQL — **not** run by `supabase db push`. Apply after migrations.

## What's in the repo

| Resource | Path | Contents |
| --- | --- | --- |
| Baseline schema | `supabase/migrations/20260528000000_baseline.sql` | Full server schema |
| Plan catalog | `supabase/migrations/20260528110000_seed_plan_*.sql` | 8 plans (MVP + Jonah, Zacchaeus, Samuel) |
| Discover content | `supabase/seeds/content_test_seed.sql` | 6 Discover items (video ×2, essay ×2, cartoon ×2); `body` null; sections with `block_type`; plan links |
| Message taxonomy | `supabase/seeds/message_taxonomy_seed.sql` | category/situation/theme/tone tags |
| Message cards (pilot) | `supabase/seeds/message_cards_pilot_seed.sql` | ~10 message cards + plan links |
| Today's Message | `supabase/seeds/today_message_test_seed.sql` | 2 slots (today + yesterday) linked to Message Cards via `content_id` |

## Apply order

```bash
# Project root
supabase db push
```

Plan seeds ship in migrations `20260528110000`–`20260528110007`.  
`estimated_minutes` reconciliation: `20260601120400_reconcile_plan_estimated_minutes.sql` — see [`PLAN_CATALOG.md`](PLAN_CATALOG.md).

Optional content / today's message (local or staging):

```bash
psql "$DATABASE_URL" -f supabase/seeds/message_taxonomy_seed.sql
psql "$DATABASE_URL" -f supabase/seeds/message_cards_pilot_seed.sql
psql "$DATABASE_URL" -f supabase/seeds/content_test_seed.sql
psql "$DATABASE_URL" -f supabase/seeds/today_message_test_seed.sql
```

Apply `message_cards_pilot_seed.sql` **after** `message_taxonomy_seed.sql` and plan catalog migrations.

Run `today_message_test_seed.sql` **after** `20260529120000_simplify_today_messages.sql`.

Today's Message can also be published via **Admin**.

## Production API checks

`HUNNY_API_BASE_URL=https://hunnybibletracker.com`

```bash
curl -s "https://hunnybibletracker.com/api/health"
curl -s "https://hunnybibletracker.com/api/v1/plans?sort=featured" | jq '.plans | length'
curl -s "https://hunnybibletracker.com/api/v1/content?sort=featured&language=en&discoverOnly=1" | jq '.contents | length'
curl -s "https://hunnybibletracker.com/api/v1/today-message?date=$(date +%Y-%m-%d)&language=en" | jq '.message'
```

Closed-test targets: **8 plans**, **≥1 Today's Message** (Message Card link), **6 Discover content items** (no message rows in `content_test_seed.sql`; messages come from `message_cards_pilot_seed.sql`).

**Remote (2026-06-01):** Discover 6 + Message 10 + Today slots linked to `when-your-mind-feels-crowded` (today) and `when-tomorrow-feels-heavy` (yesterday).

Plan catalog details: [`PLAN_CATALOG.md`](PLAN_CATALOG.md)
