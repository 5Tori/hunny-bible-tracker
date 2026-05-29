# Mobile testing guide (Android & iOS)

Production API base URL:

`https://hunnybibletracker.com`

(Trailing slashes are stripped in the app — `...workers.dev/` is fine.)

## 1. One-time setup

```bash
cd apps/mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Create env files (gitignored):

```bash
cp .env.example.json .env.android.json
cp .env.example.json .env.ios.json
```

Fill in both files:

| Key | Where to get it |
| --- | --- |
| `SUPABASE_URL` | Supabase → Project Settings → API |
| `SUPABASE_ANON_KEY` | Same (anon / public key) |
| `GOOGLE_WEB_CLIENT_ID` | Google Cloud → OAuth Web client |
| `GOOGLE_IOS_CLIENT_ID` | Google Cloud → OAuth iOS client |
| `GOOGLE_ANDROID_CLIENT_ID` | Google Cloud → OAuth Android client |
| `HUNNY_API_BASE_URL` | `https://hunnybibletracker.com` |

Supabase **Authentication → URL configuration** must include:

- `com.hunnybibletracker.app://login-callback/`

See `docs/SUPABASE_SETUP.md` for Google OAuth SHA-1 (Android) and bundle ID (iOS).

## 2. Run on device / simulator (debug)

### Android

1. Start an emulator (Device Manager) or connect a USB device with USB debugging.
2. `flutter devices` — note the device id.
3. Run:

```bash
cd apps/mobile
./scripts/run_android.sh
# or
./scripts/run_android.sh -d <DEVICE_ID>
```

Emulator and physical device both use the **Workers HTTPS URL** (no `10.0.2.2` needed unless you point at local `next dev`).

### iOS

1. Open Simulator: `open -a Simulator`
2. Run:

```bash
cd apps/mobile
./scripts/run_ios.sh
# or
./scripts/run_ios.sh -d <DEVICE_ID>
```

First iOS run may require opening `ios/Runner.xcworkspace` in Xcode once to set your **Team** for signing.

## 3. Smoke test checklist (production API)

Do these against the deployed API after Admin has published content.

| Area | What to verify |
| --- | --- |
| Home | Today’s Message loads (image, verse, actions) |
| Home offline | Airplane mode → cached message or Proverbs fallback; Read progress still visible |
| Discover | Published content list; search/filters; detail sheet |
| Discover offline | Offline message when API unreachable |
| Plans | Browse / start plan; chapter check persists after restart |
| Today’s Message | Heart / share counters update |
| Settings → Feedback | Submit succeeds |
| Sign-in (optional) | Google sign-in → backup/restore or sync (needs valid Google client IDs in env) |

Quick API sanity (optional, terminal):

```bash
curl -s "https://hunny-bible-tracker-web.hunnybibletracker.workers.dev/api/v1/plans?sort=featured" | head -c 200
curl -s "https://hunny-bible-tracker-web.hunnybibletracker.workers.dev/api/v1/today-message?language=en" | head -c 200
```

## 4. Build commands

### Checks (before release)

```bash
cd apps/mobile
flutter analyze
flutter test
```

### Android — debug APK (quick install)

```bash
cd apps/mobile
flutter build apk --debug --dart-define-from-file=.env.android.json
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

Install on connected device:

```bash
flutter install --debug --dart-define-from-file=.env.android.json
```

### Android — release App Bundle (Play Console)

Bump `version` in `pubspec.yaml` (`0.3.0+7` → increase the number after `+` for each Play upload).

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter build appbundle --release --dart-define-from-file=.env.android.json
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS — Simulator debug

```bash
cd apps/mobile
flutter build ios --simulator --debug --dart-define-from-file=.env.ios.json
```

### iOS — release IPA (TestFlight / device)

Requires Apple Developer signing configured in Xcode.

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter build ipa --release --dart-define-from-file=.env.ios.json
```

Output: `build/ios/ipa/*.ipa`

Or archive from Xcode: open `ios/Runner.xcworkspace` → Product → Archive.

## 5. Local API only (optional)

If you run `pnpm web:dev` on the host machine:

| Platform | `HUNNY_API_BASE_URL` |
| --- | --- |
| iOS Simulator | `http://127.0.0.1:3000` |
| Android emulator | `http://10.0.2.2:3000` |

Use these in `.env.ios.json` / `.env.android.json` instead of the Workers URL, then rebuild/run.

## 6. Troubleshooting

| Symptom | Likely fix |
| --- | --- |
| `HUNNY_API_BASE_URL is not set` | Run via `./scripts/run_*.sh` or pass `--dart-define-from-file=...` on every `flutter run` / `build` |
| Home / Discover empty | Publish content in Admin; confirm API URLs above return JSON |
| Google sign-in fails | Fill `GOOGLE_*_CLIENT_ID` in env; Android SHA-1 in Google Cloud; iOS bundle ID matches OAuth client |
| SSL / network errors on emulator | Confirm device has internet; Workers URL is `https://` |
| iOS build signing error | Xcode → Runner → Signing & Capabilities → select Team |

## Related docs

- `docs/SUPABASE_SETUP.md` — Auth and OAuth
- `docs/CLOUDFLARE_DEPLOY.md` — Web/API deploy
- `docs/to-do/MVP_CLOSE_TESTING_TODO.md` — Full closed-test checklist
