# Hunny Bible Tracker

오프라인 우선, **콘텐츠 중심 성경 읽기 습관 앱**입니다. 접근하기 쉬운 성경 이야기와 짧은 가이드 콘텐츠로 시작해, 관련 읽기 플랜을 한 장씩 진행하며 꾸준한 읽기 습관을 만듭니다.

Flutter + Drift/SQLite(로컬), Supabase Auth, Next.js API/Admin, Supabase Postgres(서버), Cloudinary(관리자 미디어)로 구성됩니다.

앱은 성경 **전문**을 저장하지 않습니다. 책/장 참조, 플랜, 진행, 읽기 활동, 설정, 오늘의 말씀·Discover 콘텐츠 메타데이터를 다룹니다. 모바일은 **로컬에 먼저** 쓰고, Supabase Postgres는 **API 경유**로만 접근합니다. 로그인 사용자는 백업/복원을 사용할 수 있으며, 기기 간 **자동 병합**은 보류입니다.

## 현재 상태

**콘텐츠 중심 성경 읽기 습관 앱** — Discover에서 이야기·콘텐츠를 찾고, 관련 플랜을 읽으며, 진행과 습관을 추적합니다.

클로즈드 테스트를 위해 **Home, Discover, Read, Plans, Settings**와 **공개 웹/API**를 마무리하는 단계입니다.

- **모바일**: Flutter iOS / Android
- **탭**: `Home`, `Discover`, `Read`, `Settings` (MVP에서 Saved/List는 비표시)
- **오프라인**: Drift/SQLite. Home·Read는 오프라인에서도 빠르게 표시. Discover는 온라인 전용이며 API 불가 시 오프라인 안내
- **인증**: Supabase Auth + Google 로그인
- **서버 DB**: Supabase Postgres (`apps/web` API 경유)
- **배포**: 웹/API/Admin은 **Cloudflare Workers** (OpenNext). DB 연결은 **Hyperdrive**
- **Read**: 섹션 기반 플랜, 장 진행, 완료·히스토리, 다시 시작, 아카이브/복원
- **Plans**: 전체 화면 플랜 관리·카탈로그 (`내 플랜`, `카탈로그`, `보관함` 등)
- **Home**: 오늘의 말씀, 반성, Read More, 관련 플랜 CTA, 저장(로컬), 하트/공유, 진행률, 캐시·오프라인 폴백
- **Discover**: 콘텐츠 검색, 타입/태그 필터, 상세 시트, YouTube, 관련 플랜
- **Settings**: 로그인/로그아웃, 수동 백업·복원, 동기화 상태, 플랜 관리, 문의·피드백
- **Admin**: 플랜, 오늘의 말씀, 일반 콘텐츠 CRUD (미니멀 대시보드 UI)
- **공개 웹**: [랜딩·지원·약관](https://hunnybibletracker.com/) (Tailwind v4)

원격 읽기 데이터 백업/복원은 `POST /api/v1/sync/push`, `GET /api/v1/sync/bootstrap`로 구현되어 있습니다. 기기 간 **자동 증분 병합**은 아직 보류입니다.

## 프로덕션 URL

| 용도 | URL |
| --- | --- |
| 공개 웹·API | https://hunnybibletracker.com |
| Admin | https://hunnybibletracker.com/admin/login |
| API 헬스 | `.../api/health` |

모바일 `HUNNY_API_BASE_URL`도 위 API 호스트(끝 `/` 유무 무관)를 사용합니다.

## 모노레포 구조

```text
apps/
  mobile/   Flutter 앱
  web/      Next.js (공개 페이지 · API · Admin)

docs/
  PRODUCT_STRATEGY.md      제품 정체성·핵심 루프 (소스 오브 트루스)
  ARCHITECTURE.md          런타임 구조·모듈 맵
  DATA_MODEL.md            로컬/서버 스키마, 플랜·콘텐츠
  AUTH_AND_API.md          Supabase Auth, OAuth, API, env
  SYNC_STRATEGY.md         backup/restore 설계
  PRODUCT_ROADMAP.md       제품 방향·우선순위
  MOBILE_TESTING.md        모바일 테스트·빌드
  DEVELOPMENT.md           로컬 실행·배포·트러블슈팅 (+ Admin CRUD: Plans · Content · Today's Message)
  ref/HUNNY_RELEASE_LOG.md 릴리스·Play Console 기록
  to-do/                   CURRENT_FOCUS · MVP 체크리스트
```

## 처음 읽을 문서

새로 합류한 개발자·에이전트용 순서:

1. 이 README
2. `docs/PRODUCT_STRATEGY.md` — 제품 정체성·핵심 루프
3. `docs/ARCHITECTURE.md` — 시스템 맵
4. `docs/DATA_MODEL.md` — Read·Plans·콘텐츠·동기화 변경 전
5. `docs/AUTH_AND_API.md` — Auth·API 변경 전
6. `docs/SYNC_STRATEGY.md` — 백업/복원 변경 전
7. `docs/PRODUCT_ROADMAP.md` — 제품 우선순위
8. `docs/to-do/CURRENT_FOCUS.md` — 지금 하는 일
9. `docs/to-do/MVP_CLOSE_TESTING_TODO.md` — 클로즈드 테스트 체크리스트

배포·로컬 실행: `docs/DEVELOPMENT.md`, `docs/AUTH_AND_API.md`, `docs/MOBILE_TESTING.md`

## 빠른 시작

### 모바일

```bash
cd apps/mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

환경 파일 생성 (gitignore):

```bash
cd apps/mobile
cp .env.example.json .env.ios.json
cp .env.example.json .env.android.json
```

두 파일에 Supabase·Google OAuth 값을 채웁니다. **프로덕션 API** 예시:

```json
"HUNNY_API_BASE_URL": "https://hunnybibletracker.com"
```

로컬 `next dev`만 쓸 때:

| 플랫폼 | `HUNNY_API_BASE_URL` |
| --- | --- |
| iOS 시뮬레이터 | `http://127.0.0.1:3000` |
| Android 에뮬레이터 | `http://10.0.2.2:3000` |

실행:

```bash
cd apps/mobile
./scripts/run_ios.sh
./scripts/run_android.sh
```

자세한 스모크 테스트·릴리스 빌드: **`docs/MOBILE_TESTING.md`**

### 웹 / API / Admin (로컬)

```bash
pnpm install
cp apps/web/.env.example apps/web/.env.local
# .env.local에 DATABASE_URL, Supabase, Cloudinary 등 입력 (apps/web/.env.example, docs/AUTH_AND_API.md)
pnpm web:dev
```

로컬 Admin: http://127.0.0.1:3000/admin/login

Workers 런타임 미리보기:

```bash
cd apps/web
cp .dev.vars.example .dev.vars   # 값 채우기
pnpm preview
```

프로덕션 배포:

```bash
cd apps/web
pnpm run deploy
```

상세: **`docs/DEVELOPMENT.md`** (로컬·Cloudflare Workers 배포)

## 자주 쓰는 검증 명령

**모바일**

```bash
cd apps/mobile
flutter analyze
flutter test
flutter build apk --debug --dart-define-from-file=.env.android.json
flutter build ios --simulator --debug --dart-define-from-file=.env.ios.json
```

**웹**

```bash
pnpm web:build
pnpm --dir apps/web typecheck
```

## 릴리스 빌드

버전은 `apps/mobile/pubspec.yaml`의 `version: <이름>+<코드>` 입니다.

```yaml
version: 0.3.0+7
```

Google Play 업로드마다 `+` 뒤 **versionCode**를 반드시 올립니다. `ios/.symlinks` 등 다른 `pubspec.yaml`이 아닌 **루트 mobile `pubspec.yaml`**을 수정했는지 확인하세요.

**Android (App Bundle)**

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter build appbundle --release --dart-define-from-file=.env.android.json
```

산출물: `apps/mobile/build/app/outputs/bundle/release/app-release.aab`

**iOS (IPA)**

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter build ipa --release --dart-define-from-file=.env.ios.json
```

산출물: `apps/mobile/build/ios/ipa/*.ipa`

릴리스 전 `.env.android.json` / `.env.ios.json`의 `HUNNY_API_BASE_URL`이 **배포된 Workers URL**인지 확인하세요.

## 데이터 흐름

모바일은 읽기 데이터를 **로컬에 먼저** 씁니다. 로그인 사용자는 인증 API로 백업·복원할 수 있습니다.

```text
사용자 동작
  → Flutter UI
  → Drift/SQLite 트랜잭션
  → sync_status (pending / local_only)
  → (선택) 인증된 sync push
  → Next.js API (Cloudflare Workers)
  → Supabase Postgres (Hyperdrive)
```

모바일은 **Supabase Postgres에 직접 연결하지 않습니다.** 서버 접근은 `apps/web` API만 사용합니다.

## 주요 구현 위치

| 영역 | 경로 |
| --- | --- |
| 로컬 DB 스키마 | `apps/mobile/lib/core/database/app_database.dart` |
| Drift 생성 파일 | `apps/mobile/lib/core/database/app_database.g.dart` |
| 읽기·동기화 페이로드 | `apps/mobile/lib/features/read/data/read_repository.dart` |
| API 클라이언트(타임아웃) | `apps/mobile/lib/core/api/hunny_api_client.dart` |
| 플랜 화면 | `apps/mobile/lib/features/plans/plans_screen.dart` |
| Home·오늘의 말씀 | `apps/mobile/lib/features/home/` |
| Discover | `apps/mobile/lib/features/find/discover_screen.dart` |
| 모바일 env 예시 | `apps/mobile/.env.example.json` |
| 서버 스키마 참고 | `apps/web/db/schema.sql` |
| Supabase 마이그레이션 | `supabase/migrations/` |
| API 라우트 | `apps/web/src/app/api` |
| Admin | `apps/web/src/app/admin` |
| Workers 설정 | `apps/web/wrangler.jsonc` |
| Postgres 클라이언트 | `apps/web/src/lib/db/postgres.ts` |

## 연락처

- 이메일: hunnybibletracker@gmail.com
- 지원 페이지: https://hunnybibletracker.com/support
