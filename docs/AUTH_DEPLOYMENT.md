# Auth Deployment Guide

현재 인증 구조는 **Firebase Auth + Neon DB**다.

- Firebase Auth: Google 로그인, iOS/Android 인증 세션
- Neon Postgres: 앱 데이터 저장
- `apps/web` API routes: Firebase ID token 검증, Neon DB 사용자 upsert, 향후 sync

상세 설정은 `docs/FIREBASE_AUTH.md`를 기준으로 한다. 이전 Neon Auth managed endpoint 기반 Google 로그인은 Flutter native Google `idToken` 흐름에서 세션 생성이 되지 않아 더 이상 기본 경로로 사용하지 않는다.

## 배포 체크리스트

- Firebase Console에서 Google provider를 활성화했다.
- Firebase Android 앱의 package name이 release `applicationId`와 일치한다.
- Firebase iOS 앱의 Bundle ID가 release Bundle ID와 일치한다.
- Android debug/release/Play App Signing SHA-1을 Firebase 또는 Google Cloud OAuth 설정에 등록했다.
- iOS `Info.plist`의 `GIDClientID`와 URL scheme이 Firebase iOS Google client와 일치한다.
- Flutter build에 Firebase `--dart-define` 값을 넘긴다.
- API 배포 환경에 `DATABASE_URL`, `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`를 설정했다.
- Neon DB에 `apps/web/db/schema.sql`의 `auth_users` 테이블을 적용했다.
- 로그인 후 `POST /api/v1/auth/sync` 또는 `GET /api/v1/me`가 성공하는지 확인했다.

## iOS Build Example

```bash
cd apps/mobile

flutter build ipa --release \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=YOUR_PROJECT.firebaseapp.com \
  --dart-define=FIREBASE_IOS_BUNDLE_ID=com.example.hunnyBibleTracker \
  --dart-define=GOOGLE_WEB_CLIENT_ID=... \
  --dart-define=GOOGLE_IOS_CLIENT_ID=... \
  --dart-define=HUNNY_API_BASE_URL=https://YOUR_API_DOMAIN
```

## Android Build Example

```bash
cd apps/mobile

flutter build appbundle --release \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=YOUR_PROJECT.firebaseapp.com \
  --dart-define=GOOGLE_WEB_CLIENT_ID=... \
  --dart-define=GOOGLE_ANDROID_CLIENT_ID=... \
  --dart-define=HUNNY_API_BASE_URL=https://YOUR_API_DOMAIN
```

## Related Docs

- `docs/FIREBASE_AUTH.md`: Firebase Auth + Neon DB 상세 설정
- `docs/SYNC_PLAN.md`: 향후 읽기 데이터 sync 계획
