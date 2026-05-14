# Today’s Message Manager

This admin module lets an authorized admin schedule a daily verse/message card for the mobile Home tab.

## Admin Routes

```text
/admin/today-messages
/admin/today-messages/new
/admin/today-messages/[id]
```

## API Routes

Admin routes require a Firebase ID token for an email listed in `ADMIN_EMAILS`.

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

## Database

Run `db/schema.sql` in Neon. The manager requires:

```text
today_messages
media_assets
```

`today_messages` has a unique `(publish_date, language)` constraint so each language has one canonical message per day.

## Cloudinary

Uploads use the existing Cloudinary env vars:

```text
CLOUDINARY_CLOUD_NAME
CLOUDINARY_API_KEY
CLOUDINARY_API_SECRET
```

Today message images are stored in:

```text
hunny-bible-tracker/today-messages
```

The database stores only `image_url` and `image_public_id`.

## Content Notes

- `verse_reference` is required.
- `verse_text` is optional so the app can stay reference-only if needed.
- Only publish verse text that the project is licensed or allowed to display.
- The mobile app can later cache the last published message locally for offline display.
