# Mobile Testing

Android/iOS 스모크 테스트·릴리스 빌드.

Production API: `https://hunnybibletracker.com`  
Production read mode (closed test): `HUNNY_REMOTE_READ_MODE=supabase_rpc`  
**Current build:** `0.5.0+11` (`apps/mobile/pubspec.yaml`)

## Setup

```bash
cd apps/mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
cp .env.example.json .env.android.json .env.ios.json
```

필수 keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_*_CLIENT_ID`, `HUNNY_API_BASE_URL`, `HUNNY_REMOTE_READ_MODE`

`.env.android.json` / `.env.ios.json` production 예 (둘 다 동일 패턴):

```json
{
  "HUNNY_API_BASE_URL": "https://hunnybibletracker.com",
  "HUNNY_REMOTE_READ_MODE": "supabase_rpc"
}
```

OAuth · Supabase redirect: `docs/AUTH_AND_API.md`

## Run (debug)

```bash
./scripts/run_android.sh [-d DEVICE_ID]
./scripts/run_ios.sh [-d DEVICE_ID]
```

Production API 테스트 시 emulator/device 모두 HTTPS Workers URL 사용. Local `next dev`만 쓸 때는 `10.0.2.2` / `127.0.0.1`.

Hot restart: `R` (env·native 변경 후)

## Smoke checklist

| Area | Verify |
| --- | --- |
| Home | Today's Message, **Current plan** (ring, chapters read, Continue reading), **Last 7 days / Last read** footer, **heart (one-way)**, **save toggle**, share, More |
| Home plan tap | Whole plan block → Read tab · **last-read chapter centered** on screen |
| Home More | `context` reflection copy · message card → **Open message card** (web) · discover → detail sheet |
| Home offline | cache or Proverbs fallback |
| Discover | **6 items** (video/essay/cartoon only), search, filters, **tap → full detail** (body/sections/slides) |
| Discover offline | offline message |
| Read / Plans | start plan, chapter persist, completion |
| Settings | sign-in, **Sign out stable on tab revisit**, **Sync now**, **Restore**, feedback, **pull-to-refresh** on reading stats |

### Step 6 E2E (cold / warm)

**Cold start** (앱 kill 후 재실행):

1. Home — Today's Message loads (`supabase_rpc` log)
2. Discover tab — 6 cards, no message type filter chip
3. Tap essay → loading → detail with body/sections
4. Tap cartoon → slides render
5. Home More → linked message card opens web `/messages/...`

**Warm** (탭 재방문):

- Discover list 재진입 — acceptable repeat RPC (session OK)
- Detail tap — `mobile_content_detail` 1회

**Automated prod gate** (업로드 전):

```bash
pnpm mobile:smoke-prod
# optional: SUPABASE_ANON_KEY=... HUNNY_API_BASE_URL=https://hunnybibletracker.com
```

API sanity:

```bash
curl -s https://hunnybibletracker.com/api/health
curl -s -o /dev/null -w "%{http_code}\n" https://hunnybibletracker.com/api/v1/sync/bootstrap
```

전체 QA: `docs/to-do/MVP_CLOSE_TESTING_TODO.md`

## Android QA log (2026-05-29)

- Sync/restore E2E OK · heart/save/share OK · Supabase RPC read logs 정상
- Hyperdrive password reset + production `db: true` 확인

## iOS QA log (2026-05-30)

- `supabase_rpc` onboarding/catalog · sync/restore · Discover Continue → Read tab
- `./scripts/run_ios.sh` targets iOS simulator (not macOS)
- Guest reachability: `GET /api/v1/sync/bootstrap` **401 = online** (not an error)

## Build commands

```bash
flutter analyze && flutter test
flutter build apk --debug --dart-define-from-file=.env.android.json
flutter build appbundle --release --dart-define-from-file=.env.android.json   # Play
flutter build ipa --release --dart-define-from-file=.env.ios.json             # iOS
```

Play upload마다 `pubspec.yaml` `version`의 `+versionCode` 증가.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `HUNNY_API_BASE_URL is not set` | `--dart-define-from-file` 또는 `./scripts/run_*.sh` |
| `./scripts/run_ios.sh` opens **macOS** app | Script now defaults to `-d ios`; or pass `-d <simulator id>` |
| `no such table: plan_templates` on launch | Stale local DB — delete app/reinstall, or pull latest migration fix and hot restart (`R`) |
| Long **sqlite3** / `MIN` macro warnings in Xcode build | Harmless pod noise (Drift/sqlite3); ignore if build succeeds |
| Home/Discover empty | Admin publish · Supabase RPC migration applied |
| Sync server offline | reachability uses `/api/v1/sync/bootstrap`; retry after network settles |
| `GET /api/v1/sync/bootstrap` 401 in debug log | Expected when logged out — reachability probe treats 401 as online |
| Google sign-in fail | env client IDs · Android SHA-1 · iOS bundle ID |
| iOS signing | Xcode → Runner → Team |

## 관련 문서

`docs/AUTH_AND_API.md` · `docs/DEVELOPMENT.md` · `docs/SYNC_STRATEGY.md`
