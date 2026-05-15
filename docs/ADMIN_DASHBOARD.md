# Admin Dashboard

The admin dashboard lives in `apps/web` and supports server-managed content for the mobile app.

## Access

- Admin users are authorized by the `ADMIN_EMAILS` environment variable.
- Admin access is verified by a Firebase ID token sent as a Bearer token.

## Pages

- `/admin/login` — paste a Firebase bearer token from an admin account.
- `/admin/plans` — list all plan templates from Neon.
- `/admin/plans/new` — create a new plan template.
- `/admin/plans/[id]` — edit an existing plan template.
- `/admin/today-messages` — list Today’s Message rows.
- `/admin/today-messages/new` — create a Today’s Message row.
- `/admin/today-messages/[id]` — edit a Today’s Message row.

## Plan Template Features

- Plan title, subtitle, descriptions, taxonomy, tags, and publish state.
- Sections and chapter ranges.
- Browse visibility and featured rank.
- Archive state for hiding templates without deleting them.
- Cloudinary cover image upload via `POST /api/v1/admin/plans/upload`.
- Public read-only plan list via `GET /api/v1/plans`.

## Today’s Message Features

Today’s Message powers the Home card and Read More modal.

Fields:

- `publish_date`
- `language`
- `verse_reference`
- `bible_version`
- `verse_text`
- `message`
- `image_url`
- `hint_title`
- `hint_summary`
- `article_title`
- `article_body`
- `primary_related_plan_template_id`
- `is_published`

Admin routes:

```text
GET    /api/v1/admin/today-messages
POST   /api/v1/admin/today-messages
GET    /api/v1/admin/today-messages/:id
PUT    /api/v1/admin/today-messages/:id
DELETE /api/v1/admin/today-messages/:id
POST   /api/v1/admin/today-messages/upload
```

Public mobile-facing route:

```text
GET /api/v1/today-message?date=YYYY-MM-DD&language=en
```

If `date` is omitted, the route uses today’s server date. It returns the latest published message where `publish_date <= date` for the requested language.

Engagement routes:

```text
POST /api/v1/today-message/:id/heart
POST /api/v1/today-message/:id/share
```

## Cloudinary

Uploads use:

```text
CLOUDINARY_CLOUD_NAME
CLOUDINARY_API_KEY
CLOUDINARY_API_SECRET
```

Current folders:

```text
hunny-bible-tracker/plans
hunny-bible-tracker/today-messages
```

The database stores image URLs and Cloudinary public ids.

## Required Environment Variables

- `DATABASE_URL`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`
- `ADMIN_EMAILS`
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`

## Content Notes

- Plan creation and updates are stored in Neon using `schema.sql`.
- The public `/api/v1/plans` endpoint serves published, browse-visible, non-archived plans.
- `today_messages` has a unique `(publish_date, language)` constraint.
- Only publish verse text that the project is licensed or allowed to display.
- Use `bible_version` instead of appending version text to `verse_text`.
- Related plans should point to published plan templates whenever possible.
