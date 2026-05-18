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
- `/admin/content` — list reusable content for Home featured content and Discover.
- `/admin/content/new` — create a reusable content item.
- `/admin/content/[id]` — edit an existing reusable content item.
- Future: `/admin/content/authors` — manage lightweight author profiles outside the content editor.
- Future: `/admin/content/tags` — manage content tag categories and labels outside the content editor.

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

Today’s Message remains a dedicated daily slot. The schema reserves `today_messages.content_id` for a later link to a general content record, but Today’s Message should keep its date/language uniqueness and fallback lookup behavior.

## General Content Features

General content is the source for Discover/Find today and the future source for Home featured content, Saved, and content detail pages.
Discover/Find is currently backed by the public content API. Home featured content and Saved/List are follow-up surfaces.

Planned content types:

- `message`
- `video`
- `essay`
- `webtoon`

Admin scope:

- Content create/edit/publish/archive
- Ordered content assets for media, inline images, and webtoon slides
- Category-based content tags
- Many-to-many related plan selection
- Lightweight author creation/reuse from the content editor

Future admin scope:

- Dedicated author create/edit/archive screens
- Dedicated tag category management screens

Core author fields:

- `slug`
- `display_name`
- `bio`
- `avatar_image_url`
- `avatar_image_public_id`
- `website_url`
- `is_verified`
- `is_active`

Core content fields:

- `slug`
- `content_type`
- `language`
- `title`
- `subtitle`
- `summary`
- `body`
- `cover_image_url`
- `cover_image_public_id`
- `author_id`
- `primary_verse_reference`
- `bible_version`
- `verse_text`
- `duration_seconds`
- `external_url`
- `is_published`
- `is_archived`
- `published_at`
- `featured_rank`
- `browse_visible`
- `metadata`

Content tags use a category field, so the taxonomy can grow without schema changes. Expected early categories:

- `topic`
- `situation`
- `person`
- `book`
- `theme`
- `format`
- `length`

Content can relate to multiple plans through `content_plan_links`. A plan can also be related to multiple content items.

Public mobile-facing routes:

```text
GET /api/v1/content?sort=featured&language=en&type=video&tag=peace&limit=20
GET /api/v1/content/:identifier?language=en
```

The list route returns published, browse-visible, non-archived content with author, assets, tags, and related plans. `identifier` can be either `contents.id` or `contents.slug`.

Admin routes:

```text
GET    /api/v1/admin/content
POST   /api/v1/admin/content
GET    /api/v1/admin/content/:id
PUT    /api/v1/admin/content/:id
DELETE /api/v1/admin/content/:id
GET    /api/v1/admin/content/authors
POST   /api/v1/admin/content/upload
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
hunny-bible-tracker/content
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
- General content uses `content_type`, category-based tags, and many-to-many related plan links.
- Only publish verse text that the project is licensed or allowed to display.
- Use `bible_version` instead of appending version text to `verse_text`.
- Related plans should point to published plan templates whenever possible.
