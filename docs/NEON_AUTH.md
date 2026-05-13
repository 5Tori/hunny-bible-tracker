# Neon Auth (Phase F)

This app talks to **Neon Auth** (Better Auth–compatible HTTP) from Flutter using session cookies (`dio` + `PersistCookieJar`).

## Your project (reference)

- **Neon project name:** `hunny-bible-tracker`
- **Neon project id:** `autumn-moon-32438280`
- **Auth base URL (default in app):**  
  `https://ep-morning-mountain-akevadzl.neonauth.c-3.us-west-2.aws.neon.tech/neondb/auth`
- **JWKS (for future API / JWT verification):**  
  `https://ep-morning-mountain-akevadzl.neonauth.c-3.us-west-2.aws.neon.tech/neondb/auth/.well-known/jwks.json`

## Trusted `Origin` header

Better Auth requires an **`Origin`** header on sign-up / sign-in (and may validate it elsewhere). The Flutter client sends:

- **`NEON_AUTH_ORIGIN`** (dart-define), defaulting to `https://hunny-bible-tracker.local`

You must allow this origin in the **Neon Console → Auth / trusted origins** (exact URL, no trailing slash unless you configure it that way). For production, use a real HTTPS origin you control (e.g. `https://app.example.com`) and pass it at build time.

## Build-time overrides

```bash
flutter run \
  --dart-define=NEON_AUTH_BASE_URL=https://YOUR_HOST/neondb/auth \
  --dart-define=NEON_AUTH_ORIGIN=https://YOUR_TRUSTED_ORIGIN
```

If `NEON_AUTH_BASE_URL` is empty, sign-in is disabled in Settings.

## API JWT (`GET /token`)

Neon Auth exposes a session JWT suitable for **`Authorization: Bearer`** to your backend. After sign-in, the app refreshes it from **`GET {NEON_AUTH_BASE_URL}/token`** (session cookies) and stores it in the device keychain for Hunny API calls.

Configure the API base URL at build time:

```bash
flutter run --dart-define=HUNNY_API_BASE_URL=http://127.0.0.1:3000
```

Android emulator → use `http://10.0.2.2:3000` instead of `127.0.0.1`.

## Local merge (Phase F)

On successful sign-in or sign-up, the app sets `local_users.auth_user_id` to Neon’s `user.id` and `type` to `authenticated` (single on-device row; guest data is **not** duplicated). Sign-out clears cookies and clears `auth_user_id`, returning the profile to `guest`.

## Next (sync)

`docs/SYNC_PLAN.md`: full outbox sync is still future work. For **JWT-backed API calls**, the app stores Neon’s `GET …/token` JWT and can hit Hunny API `GET /api/v1/me` (see `apps/api/.env.example`).
