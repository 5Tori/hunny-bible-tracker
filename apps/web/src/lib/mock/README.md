# Local offline web testing

`pnpm web:dev` runs with **`HUNNY_OFFLINE_MODE=1` by default** — no Postgres, Hyperdrive, or Supabase required for public catalog pages.

## Start

```bash
pnpm web:dev
# → http://127.0.0.1:3000
```

Optional env file (same behavior):

```bash
cp apps/web/.env.offline.example apps/web/.env.local
```

## Smoke URLs

| Page | URL |
|------|-----|
| Messages list | http://127.0.0.1:3000/messages |
| Message detail (John) | http://127.0.0.1:3000/messages/john-1-1-3 |
| Message detail (Psalm) | http://127.0.0.1:3000/messages/psalm-19-9-10 |
| Today | http://127.0.0.1:3000/today |
| Admin messages | http://127.0.0.1:3000/admin/messages |
| Health (mock DB) | http://127.0.0.1:3000/api/health?db=1 |

## Mock dataset

Curated offline fixtures (edit `src/lib/mock/fixtures/`):

- **8 plans** (catalog only)
- **2 message cards** — John 1:1-3, Psalm 19:9-10 (NIV)
- **1 today slot** — linked to John 1:1-3

Discover content is empty in offline mode until you add seeds.

## Reconnect to live Supabase (step 3 later)

```bash
pnpm web:dev:online
```

See `docs/DEVELOPMENT.md` for env vars and Hyperdrive setup.
