# Supabase setup

Hunny uses **Supabase Auth** for identity and **Supabase Postgres** for server data behind `apps/web` API routes. The mobile app never connects to the database directly.

## 1. Create a Supabase project

1. Create a project at [supabase.com](https://supabase.com).
2. Note **Project URL**, **anon key**, and **service role key** (Settings → API).
3. Note the **database connection strings** (Settings → Database):
   - **Transaction pooler** (port 6543) → use as `DATABASE_URL` locally and as Hyperdrive origin on Cloudflare (`?pgbouncer=true`)
   - **Direct** (port 5432) → use for `supabase db push` / migrations only

## 2. Link CLI (optional, for local dev)

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

Or apply [`supabase/migrations/`](../supabase/migrations/) from the SQL editor in the dashboard.

## 3. Google OAuth

### Supabase dashboard

Authentication → Providers → Google: enable and add OAuth client ID/secret from Google Cloud Console.

Authentication → URL configuration:

| Environment | Site URL | Redirect URLs (add **all** that you use) |
| --- | --- | --- |
| Local web admin | `http://127.0.0.1:3000` | `http://127.0.0.1:3000/admin/login` |
| Local (alternate) | — | `http://localhost:3000/admin/login` |
| Production (custom domain) | `https://hunnybibletracker.com` | `https://hunnybibletracker.com/admin/login` |
| Cloudflare workers.dev (legacy) | — | `https://hunny-bible-tracker-web.hunnybibletracker.workers.dev/admin/login` (optional) |
| Mobile (deep link) | — | `com.hunnybibletracker.app://login-callback/` |

**Important:** Supabase allows one **Site URL** (default redirect). If production `redirectTo` is missing from **Redirect URLs**, OAuth completes but sends the browser to **Site URL** instead — often `http://localhost:3000` with `#access_token=...` in the hash. Fix by adding the Workers URL to Redirect URLs and setting Site URL to production (keep local URLs in the redirect list for `next dev`).

### Google Cloud Console

Create OAuth clients for:

- **Web** — authorized redirect URI: `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`
- **iOS / Android** — used by native Google Sign-In + `signInWithIdToken` on mobile

Add the Web client ID to Supabase Google provider settings. Use the same Web client ID as `GOOGLE_WEB_CLIENT_ID` in mobile env for `serverClientId`.

## 4. Environment variables

### Web (`apps/web/.env.local`)

```env
# Transaction pooler (port 6543) — use on Cloudflare Workers / serverless.
DATABASE_URL="postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres?pgbouncer=true"

# If local `next dev` hits CONNECT_TIMEOUT on port 6543 (firewall/VPN), use **Direct**
# from Dashboard → Database → Connection string → Direct (port 5432, host db.[ref].supabase.co):
# DATABASE_URL="postgresql://postgres.[ref]:[password]@db.[ref].supabase.co:5432/postgres"
SUPABASE_URL="https://YOUR_PROJECT_REF.supabase.co"
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
NEXT_PUBLIC_SUPABASE_URL="https://YOUR_PROJECT_REF.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="your-anon-key"
ADMIN_EMAILS="you@example.com"
CLOUDINARY_CLOUD_NAME="..."
CLOUDINARY_API_KEY="..."
CLOUDINARY_API_SECRET="..."
```

### Mobile (`apps/mobile/.env.ios.json` / `.env.android.json`)

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_REF.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key",
  "GOOGLE_WEB_CLIENT_ID": "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com",
  "GOOGLE_IOS_CLIENT_ID": "YOUR_IOS_CLIENT_ID.apps.googleusercontent.com",
  "GOOGLE_ANDROID_CLIENT_ID": "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com",
  "HUNNY_API_BASE_URL": "http://127.0.0.1:3000"
}
```

## 5. Seeds (optional)

After migrations, run [`apps/web/db/seeds/content_test_seed.sql`](../apps/web/db/seeds/content_test_seed.sql) in the SQL editor for local Discover/content testing.

## 6. Decommissioning Neon / Firebase

After E2E verification on staging:

1. Point Cloudflare Worker secrets/vars and Supabase env vars to the new project only (see `docs/CLOUDFLARE_DEPLOY.md`).
2. Ship a mobile build with Supabase dart-defines.
3. Disable or delete the old Neon database and Firebase project when no longer needed.
