# Auth & API

Supabase Auth, API routes, env, 배포 체크리스트.

## Architecture

```text
Supabase Auth     → mobile identity (Google, native ID token)
Supabase RPC      → mobile public read-only catalog/content (`HUNNY_REMOTE_READ_MODE=supabase_rpc`)
Next.js API       → JWT verify, heart/share, sync, feedback, admin, API fallback reads
Supabase Admin REST (from Worker) → profiles upsert, reading backup, today-message counters
Supabase Postgres → app data (Hyperdrive for admin/catalog SQL reads)
```

**Hybrid guardrail:** Mobile must not access sensitive user/admin tables directly. Mobile may use approved Supabase RPC for public read-only catalog/content. Reading progress remains local-first. Sync backup stays on Next.js API routes (Worker → Supabase Admin REST, not direct mobile table access).

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
| Production | `https://hunnybibletracker.com` | `https://hunnybibletracker.com/admin/login` |
| Local | `http://127.0.0.1:3000` | `http://127.0.0.1:3000/admin/login`, `http://localhost:3000/admin/login` |
| Mobile (optional) | — | `com.hunnybibletracker.app://login-callback/` (브라우저 OAuth 시; 현재 앱은 native Google ID token) |

**Google Cloud:** Web client → Supabase callback URI · iOS/Android → native sign-in · Web client ID → `GOOGLE_WEB_CLIENT_ID`

## Mobile env

`apps/mobile/.env.ios.json` / `.env.android.json` (gitignored):

```text
SUPABASE_URL, SUPABASE_ANON_KEY
GOOGLE_WEB_CLIENT_ID, GOOGLE_IOS_CLIENT_ID, GOOGLE_ANDROID_CLIENT_ID
HUNNY_API_BASE_URL
HUNNY_REMOTE_READ_MODE   # api | supabase_rpc (default: api)
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
| `POST /api/v1/auth/sync` | Bearer | profiles upsert (Supabase Admin REST) |
| `GET /api/v1/me` | Bearer | Current user |
| `GET /api/v1/plans` · `/plans/[id]` | — | Plan catalog (mobile may use `mobile_plan_*` RPC instead) |
| `GET /api/v1/content` · `/content/[id]` | — | Content catalog (mobile may use `mobile_content_*` RPC instead) |
| `GET /api/v1/today-message` | — | Today's Message lookup (mobile may use `mobile_today_message_latest` RPC instead) |
| `POST .../today-message/[id]/heart\|share` | — | Engagement counters (Supabase Admin REST). Heart는 **한 번만** (로컬 상태); Save는 로컬 토글 |
| `POST /api/v1/feedback` | — | Feedback |
| `POST /api/v1/sync/push` | Bearer | Backup upload (Supabase Admin REST) |
| `GET /api/v1/sync/bootstrap` | Bearer | Backup restore (Supabase Admin REST) |
| `/api/v1/admin/*` | Admin Bearer | CRUD + upload |

Bearer: `Authorization: Bearer <Supabase access token>`

Reachability probe: `GET /api/v1/sync/bootstrap` (401 without token = online). `/api/health`는 DB ping — probe용으로 사용하지 않음. Offline surface는 initial UI를 API에 block하지 않음.

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
