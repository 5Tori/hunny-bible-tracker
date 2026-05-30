# Database seeds (closed testing)

Manual test SQL — **not** run by `supabase db push`. Apply after migrations.

## What's in the repo

| Resource | Path | Contents |
| --- | --- | --- |
| Baseline schema | `supabase/migrations/20260528000000_baseline.sql` | Full server schema |
| Plan catalog | `supabase/migrations/20260528110000_seed_plan_*.sql` | 8 plans (MVP + Jonah, Zacchaeus, Samuel) |
| Discover content | `supabase/seeds/content_test_seed.sql` | 4 test items + `content_plan_links` |
| Today's Message | `supabase/seeds/today_message_test_seed.sql` | Mode A (today) + Mode B (yesterday, linked content) |

## Apply order

```bash
# Project root
supabase db push
```

Plan seeds ship in migrations `20260528110000`–`20260528110007`.  
`estimated_minutes` reconciliation: `20260601120400_reconcile_plan_estimated_minutes.sql` — see [`PLAN_CATALOG.md`](PLAN_CATALOG.md).

Optional content / today's message (local or staging):

```bash
psql "$DATABASE_URL" -f supabase/seeds/content_test_seed.sql
psql "$DATABASE_URL" -f supabase/seeds/today_message_test_seed.sql
```

Run `today_message_test_seed.sql` **after** `20260529120000_simplify_today_messages.sql`.

Today's Message can also be published via **Admin**.

## Production API checks

`HUNNY_API_BASE_URL=https://hunnybibletracker.com`

```bash
curl -s "https://hunnybibletracker.com/api/health"
curl -s "https://hunnybibletracker.com/api/v1/plans?sort=featured" | jq '.plans | length'
curl -s "https://hunnybibletracker.com/api/v1/content?sort=featured&language=en" | jq '.contents | length'
curl -s "https://hunnybibletracker.com/api/v1/today-message?date=$(date +%Y-%m-%d)&language=en" | jq '.message'
```

Closed-test targets: **8 plans**, **≥1 Today's Message**, **≥4 content items** (Discover).

**Remote (2026-05-30):** `content_test_seed.sql` + `today_message_test_seed.sql` applied — 8 plans, 4 contents, 3 content→plan links, 2 today messages (Mode A today, Mode B yesterday).

Plan catalog details: [`PLAN_CATALOG.md`](PLAN_CATALOG.md)
