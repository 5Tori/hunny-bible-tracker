# Mobile Testing

Android/iOS 스모크 테스트·릴리스 빌드.

Production API: `https://hunnybibletracker.com`  
Production read mode (closed test): `HUNNY_REMOTE_READ_MODE=supabase_rpc`

## Setup

```bash
cd apps/mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
cp .env.example.json .env.android.json .env.ios.json
```

필수 keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_*_CLIENT_ID`, `HUNNY_API_BASE_URL`, `HUNNY_REMOTE_READ_MODE`

`.env.android.json` production 예:

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
| Home | Today's Message, progress, **heart (one-way)**, **save toggle**, share, More |
| Home offline | cache or Proverbs fallback |
| Discover | list, search, filters, detail sheet |
| Discover offline | offline message |
| Read / Plans | start plan, chapter persist, completion |
| Settings | sign-in, **Sync now**, **Restore**, feedback |

API sanity:

```bash
curl -s https://hunnybibletracker.com/api/health
curl -s -o /dev/null -w "%{http_code}\n" https://hunnybibletracker.com/api/v1/sync/bootstrap
```

전체 QA: `docs/to-do/MVP_CLOSE_TESTING_TODO.md`

## Android QA log (2026-05-29)

- Sync/restore E2E OK · heart/save/share OK · Supabase RPC read logs 정상
- Hyperdrive password reset + production `db: true` 확인

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
| Home/Discover empty | Admin publish · Supabase RPC migration applied |
| Sync server offline | reachability uses `/api/v1/sync/bootstrap`; retry after network settles |
| Google sign-in fail | env client IDs · Android SHA-1 · iOS bundle ID |
| iOS signing | Xcode → Runner → Team |

## 관련 문서

`docs/AUTH_AND_API.md` · `docs/DEVELOPMENT.md` · `docs/SYNC_STRATEGY.md`
