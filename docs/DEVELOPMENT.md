# Development

로컬 실행, 배포, 트러블슈팅.

## Prerequisites

Flutter · Xcode(iOS) · Android Studio · pnpm · Supabase + Google OAuth (`docs/AUTH_AND_API.md`)

## Mobile — 최초 설정

```bash
cd apps/mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
cp .env.example.json .env.ios.json .env.android.json  # 각각 복사 후 값 입력
# closed test: HUNNY_REMOTE_READ_MODE=supabase_rpc (see .env.example.json)
```

| Platform | Local `HUNNY_API_BASE_URL` |
| --- | --- |
| iOS Simulator | `http://127.0.0.1:3000` |
| Android Emulator | `http://10.0.2.2:3000` |
| Production test | `https://hunnybibletracker.com` |

실행: `./scripts/run_ios.sh` · `./scripts/run_android.sh`

릴리스/스모크: `docs/MOBILE_TESTING.md`

## Web/API — 로컬

```bash
pnpm install
cp apps/web/.env.example apps/web/.env.local   # 값 입력
pnpm web:dev
```

Admin: http://127.0.0.1:3000/admin/login

Workers preview: `cd apps/web && cp .dev.vars.example .dev.vars && pnpm preview`

## Production deploy (Cloudflare Workers)

**설정 완료.** Canonical: https://hunnybibletracker.com

| 방법 | 용도 |
| --- | --- |
| `main` push | Cloudflare Workers Builds (기본) |
| `cd apps/web && pnpm run deploy` | 긴급 로컬 deploy |

Build: `pnpm install --frozen-lockfile && pnpm --filter @hunny-bible-tracker/web run cf:build`  
Deploy: `cd apps/web && pnpm run deploy` (루트: `pnpm web:deploy`)

> **주의:** pnpm 10+에서 `pnpm deploy`는 package.json 스크립트가 아니라 pnpm 내장 명령입니다. 반드시 `pnpm run deploy`를 사용하세요.

Runtime secrets: `SUPABASE_SERVICE_ROLE_KEY`, `CLOUDINARY_*` · Hyperdrive → `wrangler.jsonc`

**쓰기 경로 (2026-05):** 모바일 sync/auth/heart/share는 Worker에서 **Supabase Admin REST**로 저장합니다. Admin CRUD·일부 catalog SQL read는 Hyperdrive를 계속 사용합니다.

검증:

```bash
curl -s https://hunnybibletracker.com/api/health          # db: true
curl -s -o /dev/null -w "%{http_code}\n" https://hunnybibletracker.com/api/v1/sync/bootstrap  # 401 = route alive
```

## Analytics & SEO (설정 완료)

Public `(public)` routes only — `/admin` 제외.

| Item | Value |
| --- | --- |
| GTM | `GTM-TWDZMRJW` |
| GA4 | `G-8RSLHM5PHV` (GTM 태그) |
| Search Console | `NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION` |
| Sitemap | `/sitemap.xml` |

변경 시 `wrangler.jsonc` 또는 Cloudflare build variables → redeploy.

## Checks

```bash
cd apps/mobile && flutter analyze && flutter test
pnpm --dir apps/web typecheck
pnpm web:build
```

## Offline startup (mobile)

Home·Read는 local first. Discover는 online-only + offline message. Airplane mode smoke:

```text
Home 빠르게 → progress/fallback · Read chapter toggle · Discover offline message
```

## Admin Dashboard

운영 UI: https://hunnybibletracker.com/admin/login

- `ADMIN_EMAILS` + Google (Supabase Auth)
- Sidebar: Plans · Content · Today's messages
- Minimal B/W UI — `apps/web/src/styles/admin*.css` (public site와 분리)
- Routes: `/admin/plans`, `/admin/content`, `/admin/today-messages` (+ editors)
- API: `/api/v1/admin/*` — 상세는 `docs/AUTH_AND_API.md`

## Troubleshooting

| Issue | Fix |
| --- | --- |
| Android NDK broken | broken NDK folder 삭제 후 Gradle reinstall |
| Emulator → local API | `10.0.2.2:3000` (not `127.0.0.1`) |
| Google Sign-In iOS | `Info.plist` GIDClientID, URL schemes, Supabase redirect |
| Drift stale | `flutter pub run build_runner build` |
| Stale mobile data | 앱 삭제/reinstall |
| API 500 / 10–30s timeout | `curl https://hunnybibletracker.com/api/health` — `db: false`면 Hyperdrive origin 비밀번호·Supabase Network restrictions 확인 |
| Sync/heart timeout but RPC OK | sync·heart·share·profiles upsert는 Supabase Admin REST 경로 — `SUPABASE_SERVICE_ROLE_KEY` Worker secret 확인 |
| `pnpm deploy` → Nothing to deploy | `pnpm run deploy` 또는 `pnpm web:deploy` 사용 (pnpm 10 내장 명령과 충돌) |
| Mobile “Sync server offline” | reachability probe는 `GET /api/v1/sync/bootstrap` (401=online). `/api/health`는 DB ping이라 느릴 수 있음 |
| `env.IMAGES binding is not defined` | `next.config.mjs` `images.unoptimized: true` (Cloudinary 직접 사용). 또는 wrangler에 `images.binding: IMAGES` 추가 |
| `waitUntil() tasks did not complete` | Worker background task timeout — DB 연결 hang·이미지 최적화 실패 시 발생. health·Hyperdrive 먼저 확인 |

현재 release target: `v0.4.0+8` — `docs/ref/HUNNY_RELEASE_LOG.md`

Hot reload: `r` / `R` / `q`

## API performance diagnostics

리팩터링 전 API 경로는 Worker hop + N+1로 느렸고(특히 `GET /api/v1/plans` full relations ~8s), 모바일 closed test는 **`HUNNY_REMOTE_READ_MODE=supabase_rpc`** 로 public read를 Supabase RPC에 둡니다. API read 라우트는 web/fallback용으로 유지합니다.

### Server timing logs

| Env | Behavior |
| --- | --- |
| `NODE_ENV=development` | On by default (`pnpm web:dev`) |
| `API_PERF_LOG=1` | Force on (Workers preview / production smoke) |
| `API_PERF_LOG=0` | Force off |

`apps/web/.env.local` 예: `API_PERF_LOG=1`

Instrumented routes emit JSON lines (`type: api_perf`) with `total_ms`, `db_ms`, `db_query_count`, `response_bytes`. Implementation: `src/lib/perf/api-timing.ts`, `src/lib/perf/db-timing.ts`.

| Route | Typical bottleneck (API mode) |
| --- | --- |
| `GET /api/v1/plans` (full) | ~25 SQL queries, ~35KB — avoid on mobile; use RPC or `?detail=summary` |
| `GET /api/v1/content` | ~6 queries list N+1 |
| `GET /api/v1/today-message` | 1–2 queries; acceptable but adds Worker hop vs RPC |
| `GET /api/health` | DB ping — **not** mobile reachability probe |

### Local benchmark

```bash
pnpm web:dev   # separate terminal
pnpm --dir apps/web bench:api
HUNNY_API_BASE_URL=https://hunnybibletracker.com pnpm --dir apps/web bench:api
```

Script: `apps/web/scripts/bench-api.mjs` — client wall time + response bytes. Compare with server `api_perf` logs.

### Mobile client (debug builds)

`HunnyApiClient` logs `[HunnyApi] METHOD path STATUS durationMs ...` in `kDebugMode` only.

| Setting | Value | Used for |
| --- | --- | --- |
| `requestConnectTimeout` | 8000 ms | Normal API calls (sync, heart, share) |
| `requestReceiveTimeout` | 20000 ms | Normal API calls |
| `probeConnectTimeout` | 4000 ms | Reachability probe |
| `probeReceiveTimeout` | 6000 ms | Reachability probe |
| Reachability probe | `GET /api/v1/sync/bootstrap` | **401 without token = online** |
| `_onlineTtl` / `_offlineCooldown` | 30 s / 20 s | Cached reachability |

Public catalog reads in RPC mode use `[HunnySupabase]` logs, not `[HunnyApi] GET /api/v1/plans`.

## 관련 문서

`docs/AUTH_AND_API.md` · `docs/MOBILE_TESTING.md` · `docs/ARCHITECTURE.md`
