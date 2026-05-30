# Supabase database

Single source of truth for Postgres schema, migrations, and manual test seeds.

## Layout

| Path | Purpose |
| --- | --- |
| `migrations/` | Applied via `supabase db push` — baseline, plan catalog seeds, RPCs, reconciliations |
| `seeds/` | Optional manual SQL for local/staging (content, today's message) — not auto-run by CLI |
| `schema.sql` | Full schema **reference mirror** — browse/diff only; do not apply instead of migrations |
| `config.toml` | Supabase CLI project config |

## Apply schema (all environments)

```bash
supabase db push
```

Fresh project: migrations run in timestamp order starting with `20260528000000_baseline.sql`.

## Optional test data

After migrations:

```bash
psql "$DATABASE_URL" -f supabase/seeds/content_test_seed.sql
psql "$DATABASE_URL" -f supabase/seeds/today_message_test_seed.sql
```

See [`seeds/README.md`](seeds/README.md) and [`seeds/PLAN_CATALOG.md`](seeds/PLAN_CATALOG.md).

## Keep `schema.sql` in sync

When adding a migration that changes tables, update `schema.sql` to match (or regenerate from `supabase db dump --schema-only`).
