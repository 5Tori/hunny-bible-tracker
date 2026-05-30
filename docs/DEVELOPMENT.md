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
Deploy: `pnpm --filter @hunny-bible-tracker/web run cf:deploy`

Runtime secrets: `SUPABASE_SERVICE_ROLE_KEY`, `CLOUDINARY_*` · Hyperdrive → `wrangler.jsonc`

검증: `curl https://hunnybibletracker.com/api/health`

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
| API 500 / 10–30s timeout | `curl https://hunnybibletracker.com/api/health` — `db: false`면 Hyperdrive·Supabase pooler 확인 (Dashboard → Hyperdrive origin URL·비밀번호, Network restrictions) |
| `env.IMAGES binding is not defined` | `next.config.mjs` `images.unoptimized: true` (Cloudinary 직접 사용). 또는 wrangler에 `images.binding: IMAGES` 추가 |
| `waitUntil() tasks did not complete` | Worker background task timeout — DB 연결 hang·이미지 최적화 실패 시 발생. health·Hyperdrive 먼저 확인 |

현재 release target: `v0.3.0+7` — `docs/ref/HUNNY_RELEASE_LOG.md`

Hot reload: `r` / `R` / `q`

## 관련 문서

`docs/AUTH_AND_API.md` · `docs/MOBILE_TESTING.md` · `docs/ARCHITECTURE.md`
