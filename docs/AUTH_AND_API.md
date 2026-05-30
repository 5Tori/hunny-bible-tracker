# Auth & API

Supabase Auth, API routes, env, 배포 체크리스트.

## Architecture

```text
Supabase Auth     → mobile identity (Google)
Next.js API       → JWT verify, Postgres read/write
Supabase Postgres → app data (profiles, catalog, backup)
```

Mobile은 Postgres **직접 접근 불가**. API routes only.

## Supabase project

Ref: `tbexpdwipdjgcjtlujis`

```bash
supabase login && supabase link --project-ref tbexpdwipdjgcjtlujis && supabase db push
```

| Connection | Port | Use |
| --- | --- | --- |
| Transaction pooler | 6543 | `DATABASE_URL`, Hyperdrive (`?pgbouncer=true`) |
| Direct | 5432 | migrations only |

Content seed (optional): `apps/web/db/seeds/content_test_seed.sql`

## Google OAuth

**Supabase → Authentication → URL configuration**

| Env | Site URL | Redirect URLs |
| --- | --- | --- |
| Production | `https://hunnybibletracker.com` | `.../admin/login` |
| Local | `http://127.0.0.1:3000` | `127.0.0.1` / `localhost` admin login |
| Mobile | — | `com.hunnybibletracker.app://login-callback/` |

**Google Cloud:** Web client → Supabase callback URI · iOS/Android → native sign-in · Web client ID → `GOOGLE_WEB_CLIENT_ID`

## Mobile env

`apps/mobile/.env.ios.json` / `.env.android.json` (gitignored):

```text
SUPABASE_URL, SUPABASE_ANON_KEY
GOOGLE_WEB_CLIENT_ID, GOOGLE_IOS_CLIENT_ID, GOOGLE_ANDROID_CLIENT_ID
HUNNY_API_BASE_URL
```

| Platform | ID |
| --- | --- |
| Android | `com.hunnybibletracker.app` |
| iOS | `com.example.hunnyBibleTracker` (release 전 확인) |

Local API: iOS `http://127.0.0.1:3000` · Android emulator `http://10.0.2.2:3000` · Production `https://hunnybibletracker.com`

## Web env

`apps/web/.env.local` — see `.env.example`:

`DATABASE_URL`, `SUPABASE_*`, `ADMIN_EMAILS`, `CLOUDINARY_*`, `NEXT_PUBLIC_*`

## API routes

| Route | Auth | Purpose |
| --- | --- | --- |
| `GET /api/health` | — | Health |
| `POST /api/v1/auth/sync` | Bearer | profiles upsert |
| `GET /api/v1/me` | Bearer | Current user |
| `GET /api/v1/plans` · `/plans/[id]` | — | Plan catalog |
| `GET /api/v1/content` · `/content/[id]` | — | Content catalog |
| `GET /api/v1/today-message` | — | Today's Message lookup |
| `POST .../today-message/[id]/heart\|share` | — | Counters |
| `POST /api/v1/feedback` | — | Feedback |
| `POST /api/v1/sync/push` | Bearer | Backup upload |
| `GET /api/v1/sync/bootstrap` | Bearer | Backup restore |
| `/api/v1/admin/*` | Admin Bearer | CRUD + upload |

Bearer: `Authorization: Bearer <Supabase access token>`

Reachability probe: `/api/health`. Offline surface는 initial UI를 API에 block하지 않음.

## Backup/restore

Signed-in: Sync now → `sync/push` · Restore → `sync/bootstrap` (local state replace). Auto multi-device merge / conflict UI **미구현**.

## Deployment checklist

- Supabase Google + redirect URLs · Android SHA-1 · iOS URL schemes
- Cloudflare secrets + Hyperdrive · migrations applied
- `GET /api/health` · auth/sync · sync push/bootstrap · today-message · content · feedback

Release builds:

```bash
cd apps/mobile
flutter build appbundle --release --dart-define-from-file=.env.android.json
flutter build ipa --release --dart-define-from-file=.env.ios.json
```

## 관련 문서

`docs/SYNC_STRATEGY.md` · `docs/DEVELOPMENT.md` · `docs/MOBILE_TESTING.md`
