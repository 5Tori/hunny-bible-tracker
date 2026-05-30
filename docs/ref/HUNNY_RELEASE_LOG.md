# Release Log

Hunny Bible Tracker release history and Play Console notes.

Use this file to keep lightweight release records for internal testing, closed testing, and production releases.

Current active checklist before the next closed-test artifact:

```text
docs/to-do/MVP_CLOSE_TESTING_TODO.md
```

---

## Release Entry Template

이 템플릿은 내부 기록용 본문은 한국어로 작성하고, `Play Console Release Notes` 블록만 영어로 작성한다.
클로즈 테스트 단계에서는 자세한 기능명을 모두 적기보다 테스터가 이해할 수 있는 넓은 표현으로 짧게 정리한다.

### vX.Y.Z+BUILD — TRACK

- **Date:** YYYY-MM-DD
- **Platform:** Android / iOS / Both
- **Track:** Internal testing / Closed testing / Production
- **Release name:** `vX.Y.Z+BUILD - TRACK`
- **Build artifact:** `app-release.aab` / `.apk` / `.ipa`
- **Package / Bundle ID:** `com.hunnybibletracker.app`

#### Summary

이번 릴리즈에 포함된 주요 변경을 1-2문장으로 요약한다.

#### Included

- 주요 변경 1
- 주요 변경 2
- 주요 변경 3

#### Notes

- 알려진 이슈 또는 릴리즈 메모
- 테스트 중점
- 스토어 리뷰 참고 사항

#### Play Console Release Notes

```text
Short English release notes for Google Play.
```

---

## Dev QA — Android emulator (2026-05-29)

릴리스 아티팩트 전 **개발 QA 완료** 기록 (Play upload 아님).

- **Platform:** Android emulator · production API + `supabase_rpc`
- **Verified:** Sync now / Restore · heart (one-way) · save toggle · share · Discover/Plans/Read · sign-in
- **Infra:** Hyperdrive password reset · `/api/health` `db: true` · web deploy `pnpm run deploy`
- **Code (uncommitted at note time):** mobile sync/settings/home · web Supabase Admin REST for sync/engagement

**Next:** iOS QA · `versionCode` bump · `app-release.aab` upload

---

## v0.3.0+7 — Android Closed Testing

- **Date:** 2026-05-18
- **Platform:** Android
- **Track:** Closed testing
- **Release name:** `v0.3.0+7 - Android closed testing`
- **Build artifact:** `app-release.aab`
- **Package ID:** `com.hunnybibletracker.app`

#### Summary

세 번째 Android 클로즈 테스트용 릴리즈. 공개 웹사이트 정리, 오프라인 실행 흐름 개선, 앱 시작 화면과 기본 에셋을 배포 전 상태에 맞춰 다듬은 빌드다.

#### Included

- 오프라인 앱 시작과 Home/Read 로딩 흐름 개선
- Discover 오프라인 안내 상태 추가
- Today’s Message 오프라인 폴백과 캐시 동작 개선
- Google Play 다운로드 링크와 공개 웹사이트 CTA 정리
- 앱 아이콘과 시작 화면 이미지 업데이트
- 공개 웹사이트 리팩토링과 Tailwind v4 기반 정리

#### Notes

- Google Play 클로즈 테스트용 빌드다.
- 테스트 중점은 오프라인 실행, Home progress, Read 탭, Discover 온라인/오프라인 상태, Today’s Message 폴백, 앱 시작 화면이다.
- Android 네이티브 리소스는 로컬 생성 파일이 포함될 수 있으므로 빌드 전 실제 스플래시/아이콘 결과를 확인한다.

#### Play Console Release Notes

```text
Closed testing update for Hunny Bible Tracker.

Includes offline startup improvements, Home and Read reliability updates, Discover offline messaging, refreshed app launch visuals, and public website updates.
```

---

## v0.2.0+6 — Android Closed Testing

- **Date:** 2026-05-18
- **Platform:** Android
- **Track:** Closed testing
- **Release name:** `v0.2.0+6 - Android closed testing`
- **Build artifact:** `app-release.aab`
- **Package ID:** `com.hunnybibletracker.app`

#### Summary

두 번째 Android 클로즈 테스트용 릴리즈. 홈, 플랜, 읽기 흐름, Discover 콘텐츠 경험을 전반적으로 다듬은 빌드다.

#### Included

- 홈 Today’s Message 경험 개선
- 플랜 관리와 읽기 흐름 안정화
- Discover 콘텐츠 목록과 상세 보기 추가
- 메시지, 영상, 글, 웹툰형 콘텐츠 구조 준비
- YouTube 영상과 Shorts 임베드 재생 지원
- 콘텐츠 author 표시와 verified 뱃지 기반 추가
- 백업/복원, 피드백, 설정 관련 사용성 개선

#### Notes

- Google Play 클로즈 테스트용 빌드다.
- 실제 운영 콘텐츠는 계속 보강 중이므로 테스트 데이터나 임시 콘텐츠가 포함될 수 있다.
- 테스트 중점은 앱 실행, 홈 콘텐츠, Discover 콘텐츠 상세, 영상 재생, 플랜 시작/진행/복원 흐름이다.

#### Play Console Release Notes

```text
Closed testing update for Hunny Bible Tracker.

Includes improvements to Home, reading plans, Discover content, content detail views, video playback, backup and restore, and general app stability.
```

---

## v0.1.0+5 — Android Closed Testing

- **Date:** 2026-05-14
- **Platform:** Android
- **Track:** Closed testing
- **Release name:** `v0.1.0+5 - Android closed testing`
- **Build artifact:** `app-release.aab`
- **Package ID:** `com.hunnybibletracker.app`

#### Summary

Initial Android closed testing release for Hunny Bible Tracker.

#### Included

- Offline-first Bible reading progress tracking
- Built-in Bible in a Year reading plan
- Chapter-level check and uncheck tracking
- Book-level and total plan progress
- Reading activity history
- Basic local settings
- App store review support pages: Privacy, Support, and Terms

#### Notes

- This release is intended for Google Play closed testing.
- Testers should verify app launch, reading progress tracking, chapter check/uncheck behavior, local persistence, and settings links.
- Google Sign-In and sync-related behavior should be tested if enabled in this build.
- This entry predates the latest Home Today’s Message, Plans Manager, feedback, and backup/restore updates. Create a new entry for the next closed-test build rather than editing this historical record.

#### Play Console Release Notes

```text
Initial closed testing release of Hunny Bible Tracker.

Includes offline-first Bible reading progress tracking, reading plans, chapter checklists, progress views, and reading activity history.
```

---

## Play Console Quick Copy

### Release name

```text
v0.3.0+7 - Android closed testing
```

### Release notes

```text
Closed testing update for Hunny Bible Tracker.

Includes offline startup improvements, Home and Read reliability updates, Discover offline messaging, refreshed app launch visuals, and public website updates.
```
