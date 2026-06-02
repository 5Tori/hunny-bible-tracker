# Local web dev — mock vs live database

`pnpm web:dev` uses **live Supabase/Postgres** when `apps/web/.env.local` has `DATABASE_URL` + Supabase keys. Use **`pnpm web:dev:offline`** for mock fixtures only.

## Offline mock

```bash
cp apps/web/.env.offline.example apps/web/.env.local
pnpm web:dev:offline
# → http://127.0.0.1:3000
```

## Live database (admin + real catalog)

```bash
cp apps/web/.env.example apps/web/.env.local   # fill credentials
pnpm web:dev
```

Sync fixture message cards to Postgres:

```bash
pnpm sync:message-cards          # dry-run
pnpm sync:message-cards:write    # upsert from src/lib/mock/fixtures/
```

## Smoke URLs

| Page | URL |
|------|-----|
| Messages list | http://127.0.0.1:3000/messages |
| Message detail (John) | http://127.0.0.1:3000/messages/john-1-1-3 |
| Admin messages | http://127.0.0.1:3000/admin/messages |
| Health (live DB) | http://127.0.0.1:3000/api/health?db=1 |

## Mock dataset (offline only)

Fixtures in `src/lib/mock/fixtures/` — 100 message cards, 8 plans, discover seeds. Push to DB with `pnpm sync:message-cards:write`.

See `docs/DEVELOPMENT.md` for env vars and Hyperdrive setup.
