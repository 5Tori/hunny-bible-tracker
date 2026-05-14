# Hunny Bible Tracker Web/API

Next.js web/API app for Hunny Bible Tracker.

Current scope:

- Public landing/privacy/terms/support pages
- Firebase Admin token verification
- Neon `auth_users` upsert
- Admin plan catalog dashboard
- Cloudinary plan cover upload
- Published plan API for future mobile download/cache

## Routes

```text
GET  /api/health
POST /api/v1/auth/sync
GET  /api/v1/me
GET  /api/v1/plans
GET  /api/v1/plans/:identifier
GET  /api/v1/admin/verify
GET  /api/v1/admin/plans
POST /api/v1/admin/plans
GET  /api/v1/admin/plans/:id
PUT  /api/v1/admin/plans/:id
POST /api/v1/admin/plans/upload
```

Admin UI:

```text
/admin/login
/admin/plans
/admin/plans/new
/admin/plans/[id]
```

## Setup

```bash
cp .env.example .env.local
```

Fill:

```text
DATABASE_URL
FIREBASE_PROJECT_ID
FIREBASE_CLIENT_EMAIL
FIREBASE_PRIVATE_KEY
ADMIN_EMAILS
CLOUDINARY_CLOUD_NAME
CLOUDINARY_API_KEY
CLOUDINARY_API_SECRET
```

Apply `db/schema.sql` to Neon before using `/admin/plans`.

## Admin login

The current MVP admin login accepts a Firebase ID token for a Google account listed in `ADMIN_EMAILS`.

This keeps the dependency surface small for now. A production-ready browser Google Sign-In flow can be added later with the Firebase Web SDK.

## Commands

```bash
npm install
npm run dev
npm run typecheck
npm run build
```

## Important boundary

Mobile must not connect directly to Neon. Mobile uses `GET /api/v1/plans` to download the published plan catalog through this app.

Reading progress sync is still not implemented in this web/API app.
