# Admin Dashboard

The admin dashboard lives in `apps/web` and supports plan template management for the mobile app.

## Access

- Admin users are authorized by the `ADMIN_EMAILS` environment variable.
- Admin access is verified by a Firebase ID token sent as a Bearer token.

## Pages

- `/admin/login` — paste a Firebase bearer token from an admin account.
- `/admin/plans` — list all plan templates from Neon.
- `/admin/plans/new` — create a new plan template.
- `/admin/plans/[id]` — edit an existing plan template.

## Features

- Plan title, subtitle, description, tags, and publish state.
- Sections and chapter ranges.
- Cloudinary cover image upload via `POST /api/v1/admin/plans/upload`.
- Public read-only plan list via `GET /api/v1/plans`.

## Required environment variables

- `DATABASE_URL`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`
- `ADMIN_EMAILS`
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`

## Notes

- Admin UI data is protected server-side by `ADMIN_EMAILS`.
- The public endpoint `/api/v1/plans` serves published plans only.
- Plan creation and updates are stored in Neon using `schema.sql`.
