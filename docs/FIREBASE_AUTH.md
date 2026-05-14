# Firebase Auth + Neon DB

이 프로젝트는 Firebase Auth를 인증 계층으로 쓰고, Neon Postgres를 앱 데이터베이스로 계속 사용한다.

## 역할 분리

- **Firebase Auth**: Google 로그인, iOS/Android 인증 세션
- **Neon Postgres**: 읽기 계획, 진행률, 활동 기록, 서버 측 사용자 프로필
- **apps/web** API routes: Firebase ID token 검증, Neon DB 사용자 upsert, 향후 sync API

모바일 앱의 로컬 SQLite `local_users.auth_user_id` 컬럼에는 Firebase `uid`를 저장한다. 컬럼명은 기존 Neon Auth 작업의 흔적이지만, 현재 의미는 remote auth user id다.

## Firebase Console 설정

Firebase 프로젝트에서 아래를 설정한다.

- Authentication → Sign-in method → Google
- Android 앱 추가
- iOS 앱 추가

Android package name과 iOS Bundle ID는 앱의 실제 배포 식별자와 일치해야 한다.

현재 개발 기본값:

```text
Android applicationId: com.hunnybibletracker.app
iOS Bundle ID: com.example.hunnyBibleTracker
```

배포 전에는 둘 다 실제 식별자로 바꾸는 것을 권장한다.

## Flutter 빌드 설정

앱은 Firebase 값을 `--dart-define`으로 받는다. Firebase Console 또는 `flutterfire configure` 결과에서 값을 확인한다.

필수:

```bash
--dart-define=FIREBASE_API_KEY=...
--dart-define=FIREBASE_APP_ID=...
--dart-define=FIREBASE_MESSAGING_SENDER_ID=...
--dart-define=FIREBASE_PROJECT_ID=...
```

권장:

```bash
--dart-define=FIREBASE_AUTH_DOMAIN=YOUR_PROJECT.firebaseapp.com
--dart-define=FIREBASE_STORAGE_BUCKET=YOUR_PROJECT.appspot.com
--dart-define=FIREBASE_IOS_BUNDLE_ID=com.example.hunnyBibleTracker
--dart-define=GOOGLE_WEB_CLIENT_ID=...
--dart-define=GOOGLE_IOS_CLIENT_ID=...
--dart-define=GOOGLE_ANDROID_CLIENT_ID=...
--dart-define=HUNNY_API_BASE_URL=http://127.0.0.1:3000
```

iOS simulator에서 API를 로컬로 테스트할 때는 `http://127.0.0.1:3000`을 사용한다. Android emulator에서는 `http://10.0.2.2:3000`을 사용한다.

## iOS native 설정

Google Sign-In을 iOS에서 쓰려면 `ios/Runner/Info.plist`에 Google reversed client ID URL scheme이 필요하다.

Firebase iOS SDK 12.x 기준으로 이 프로젝트의 iOS deployment target은 15.0 이상이다.

Firebase의 `GoogleService-Info.plist`에서 확인할 값:

- `CLIENT_ID`
- `REVERSED_CLIENT_ID`

`GIDClientID`는 iOS client ID, `CFBundleURLSchemes`는 reversed client ID와 일치해야 한다.

## Android native 설정

Firebase Console에서 Android 앱을 추가하고 SHA-1을 등록한다.

필요한 SHA-1:

- debug keystore SHA-1
- release keystore SHA-1
- Play Store 배포 시 Play App Signing SHA-1

`android/app/google-services.json`을 추가하는 방식도 가능하지만, 현재 앱 코드는 Dart `FirebaseOptions`를 `--dart-define`으로 초기화한다. Google Sign-In 자체는 package name과 SHA-1 등록이 맞아야 정상 동작한다.

## API 서버 설정

`apps/web`의 API routes는 Firebase Admin SDK로 모바일 Firebase ID token을 검증한다.

`.env.local` 또는 배포 환경에 설정:

```bash
DATABASE_URL="postgresql://USER:PASSWORD@HOST/dbname?sslmode=require"
FIREBASE_PROJECT_ID="..."
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-...@YOUR_PROJECT.iam.gserviceaccount.com"
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

서버는 아래 endpoint를 제공한다.

- `POST /api/v1/auth/sync`: Firebase token을 검증하고 Neon `auth_users`에 upsert
- `GET /api/v1/me`: Firebase token을 검증하고 현재 사용자 정보를 반환

모바일 앱은 로그인 직후와 앱 시작 시 API가 설정되어 있으면 자동으로 sync를 시도한다.

## Neon DB schema

`apps/web/db/schema.sql`에 `auth_users`가 추가되어 있다.

```sql
create table if not exists auth_users (
  id uuid primary key default gen_random_uuid(),
  firebase_uid text not null unique,
  email text,
  display_name text,
  photo_url text,
  email_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_seen_at timestamptz
);
```

API의 `auth_user_id` 필드는 Firebase `uid`를 저장한다.

## Sync 전략

사용자가 수동으로 계정을 만들거나 동기화 버튼을 누를 필요는 없다. `Continue with Google`을 누르면 Firebase가 새 사용자는 자동 생성하고, 기존 사용자는 같은 흐름으로 로그인한다. 아래 이벤트에 맞춰 서버 사용자 upsert도 자동으로 시도한다.

- Firebase 로그인 직후
- 앱 시작 시 Firebase session이 살아 있을 때
- `/api/v1/me` 같은 인증 API 호출 시

향후 읽기 진행률 sync는 같은 Firebase token을 사용해 서버에서 `uid`를 검증한 뒤, `auth_user_id = firebase_uid` 기준으로 데이터를 저장하면 된다.
