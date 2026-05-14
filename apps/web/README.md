# Hunny Bible Tracker Web/API

Next.js web app and API routes for Firebase-authenticated Neon user records.

Use the root README and docs as the source of truth:

- `../../README.md`
- `../../docs/ARCHITECTURE.md`
- `../../docs/AUTH_AND_API.md`
- `../../docs/SYNC_STRATEGY.md`
- `../../docs/DEVELOPMENT.md`

## Current API Routes

```text
GET  /api/health
POST /api/v1/auth/sync
GET  /api/v1/me
```

Reading progress sync routes are not implemented yet.

## Common Commands

```bash
pnpm web:dev
pnpm web:build
```

Server schema source:

```text
db/schema.sql
```
