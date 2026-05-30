# MVP Close Testing Todo

다음 closed-test build 전 **릴리스 체크리스트**. 로드맵이 아님.

## Done / Do Not Re-open

Read flow QA · Discover enabled · Saved/List hidden · Home Today's Message · content admin/API · Plans(full-screen, archive/restore) · feedback API · **sync push/bootstrap (Android + iOS E2E)** · offline Home/Read · Discover offline message · launch/icon assets · **Supabase RPC read layer** · **heart/share/save UX** · **Discover plan CTA (Continue + Read navigation)** · Documentation 정리

### Android manual QA (2026-05-29) ✓

- Home Today's Message · heart (one-way) · save toggle · share · More → linked content
- Discover online/offline · Plans start/read · Settings sign-in · **Sync now · Restore**
- `HUNNY_REMOTE_READ_MODE=supabase_rpc` + `HUNNY_API_BASE_URL=https://hunnybibletracker.com`
- Production `/api/health` → `db: true`

### iOS manual QA (2026-05-30) ✓

- Onboarding plan load (`supabase_rpc`) · Home/Discover/Read/Settings parity with Android
- Discover content detail: subscribed plan shows **Continue** → Read tab
- Sync/restore · Drift schema v4 migration on fresh install

## Before Build

**Infrastructure**

- [x] Cloudflare Hyperdrive + secrets (`SUPABASE_SERVICE_ROLE_KEY`, Cloudinary)
- [x] Hyperdrive origin password ↔ Supabase DB password aligned
- [x] `ADMIN_EMAILS` · Google OAuth · release `HUNNY_API_BASE_URL=https://hunnybibletracker.com`
- [ ] `supabase/migrations/` through `20260601120300` applied on production
- [ ] Discover content: seed 또는 Admin publish
- [ ] Today's Message: seed 또는 Admin publish

**Automated**

- [ ] `flutter analyze` · `flutter test` · `pnpm --dir apps/web typecheck`
- [x] `pubspec.yaml` `version` / `+versionCode` bump for next upload (current: `0.5.0+9`)

**Production API / RPC**

- [x] `GET /api/health` 200 (`db: true`)
- [x] Mobile closed test: `HUNNY_REMOTE_READ_MODE=supabase_rpc` on iOS + Android
- [ ] `GET /api/v1/plans?sort=featured` (API fallback smoke; target: published plans)
- [ ] `GET /api/v1/content?sort=featured&language=en` (web/API fallback)
- [ ] Supabase RPC smoke: `mobile_today_message_latest`, `mobile_plan_catalog`

## Content Required

- Today's Message 1건+ · fallback(이전 publish_date) 동작
- `verse_text` / `bible_version` 분리
- Discover content (seed 또는 Admin publish)
- MVP plans: target **≥5** published plans
- Start Plan → valid `user_plan_chapters` · plan CTA via linked content

## Known Deferred

Plan Detail · Saved/List tab · Home featured · content deep link · habit layer · push · auto merge · conflict UI · automated test coverage · retire mobile read API routes · sync Edge Function migration

## Release Notes

`docs/ref/HUNNY_RELEASE_LOG.md`에 build number, track, package ID, testing focus 기록
