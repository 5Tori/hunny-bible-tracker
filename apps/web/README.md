# Hunny Bible Tracker Web

Next.js web app and API routes for Firebase-authenticated Neon backup/sync.

The mobile app is local-first. When `HUNNY_API_BASE_URL` is set, it sends
Firebase ID tokens to the API routes so the server can upsert the user in Neon.

Planned endpoints:

```text
GET  /api/health
POST /api/v1/auth/sync
GET  /api/v1/me
POST /api/sync/push
GET  /api/sync/pull
GET  /api/sync/status
POST /api/backup/export
POST /api/backup/restore
```
