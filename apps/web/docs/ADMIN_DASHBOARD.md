# Admin Dashboard

The Admin dashboard lives in `apps/web` and manages server-side plan catalog data.

## Routes

```text
/admin/login
/admin/plans
/admin/plans/new
/admin/plans/[id]
```

## Auth

Admin users sign in with Firebase Google Auth in the browser. Access is allowed only when the Firebase user email is included in `ADMIN_EMAILS`.

For local debugging, `/admin/login` also includes a Firebase ID token fallback.

## Required environment variables

See `apps/web/.env.example`.

Important groups:

```text
DATABASE_URL
FIREBASE_PROJECT_ID
FIREBASE_CLIENT_EMAIL
FIREBASE_PRIVATE_KEY
ADMIN_EMAILS
NEXT_PUBLIC_FIREBASE_*
CLOUDINARY_*
```

## Data model

Admin-created plans are stored in Neon:

```text
plan_templates
  -> plan_template_sections
      -> plan_template_items
  -> plan_template_tags
      -> plan_tags
```

Images are uploaded to Cloudinary. Neon stores only image metadata:

```text
cover_image_url
cover_image_public_id
media_assets
```

## Public plan API

```text
GET /api/v1/plans
GET /api/v1/plans/[identifier]
```

These routes return published plans for future mobile download/cache.

## Manual test checklist

1. Run `pnpm install`.
2. Fill `apps/web/.env.local` from `.env.example`.
3. Apply `db/schema.sql` to Neon.
4. Run `pnpm dev`.
5. Open `/admin/login`.
6. Sign in with an email in `ADMIN_EMAILS`.
7. Create a plan with at least one section and one chapter range.
8. Upload a cover image.
9. Publish the plan.
10. Confirm it appears on `/admin/plans`.
11. Confirm `GET /api/v1/plans` returns the published plan.
