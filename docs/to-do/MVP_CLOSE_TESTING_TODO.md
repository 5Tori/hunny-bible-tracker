# MVP Close Testing Todo

다음 closed-test build 전 **릴리스 체크리스트**. 로드맵이 아님.

## Done / Do Not Re-open

Read flow QA · Discover enabled · Saved/List hidden · Home Today's Message · content admin/API · Plans(full-screen, archive/restore) · feedback API · **sync push/bootstrap (Android + iOS E2E)** · offline Home/Read · Discover offline message · launch/icon assets · **Supabase RPC read layer** · **heart/share/save UX** · **Discover plan CTA (Continue + Read navigation)** · Documentation 정리 · **Web catalog RPC perf (Step 4)** · **Mobile Discover detail + Today DTO (Step 5)**

### Android manual QA (2026-05-29) ✓

- Home Today's Message · heart (one-way) · save toggle · share · More → linked content
- Discover online/offline · Plans start/read · Settings sign-in · **Sync now · Restore**
- `HUNNY_REMOTE_READ_MODE=supabase_rpc` + `HUNNY_API_BASE_URL=https://hunnybibletracker.com`
- Production `/api/health` → `db: true`

### iOS manual QA (2026-05-30) ✓

- Onboarding plan load (`supabase_rpc`) · Home/Discover/Read/Settings parity with Android
- Discover content detail: subscribed plan shows **Continue** → Read tab
- Sync/restore · Drift schema v4 migration on fresh install

### Step 6 manual QA (2026-06-01 — in progress)

- [ ] **v0.5.0+10** cold/warm E2E (`docs/MOBILE_TESTING.md` Step 6)
- [ ] Discover 6건 · detail lazy load · message card More CTA
- [ ] Play / TestFlight upload after simulator pass

## Before Build

**Infrastructure**

- [x] Cloudflare Hyperdrive + secrets (`SUPABASE_SERVICE_ROLE_KEY`, Cloudinary)
- [x] Hyperdrive origin password ↔ Supabase DB password aligned
- [x] `ADMIN_EMAILS` · Google OAuth · release `HUNNY_API_BASE_URL=https://hunnybibletracker.com`
- [x] `supabase/migrations/` through `20260601120600` applied on production
- [x] Discover content: seed 6건 (video/essay/cartoon)
- [x] Today's Message: seed + Message Card link model

**Automated**

- [x] `pnpm mobile:smoke-prod` (API + Supabase RPC prod gate)
- [x] `pnpm --dir apps/web bench:api` on production (<800ms summary routes)
- [ ] `flutter analyze` · `flutter test` (full suite — widget test slow; Today DTO tests pass)
- [x] `pubspec.yaml` `version` / `+versionCode` bump (current: **`0.5.0+10`**)

**Production API / RPC**

- [x] `GET /api/health` 200 (`db: true`)
- [x] Mobile closed test: `HUNNY_REMOTE_READ_MODE=supabase_rpc` on iOS + Android
- [x] `GET /api/v1/plans?detail=summary` — published plans
- [x] `GET /api/v1/content?discoverOnly=1` — 6 discover items
- [x] Supabase RPC smoke: `mobile_today_message_latest`, `mobile_plan_catalog`, `mobile_content_list`, `mobile_content_detail`

## Content Required

- [x] Today's Message 1건+ · fallback(이전 publish_date) 동작
- [x] `verse_text` / `bible_version` 분리
- [x] Discover content 6건 (seed)
- [x] MVP plans: **8** published plans
- [x] Start Plan → valid `user_plan_chapters` · plan CTA via linked content

## Known Deferred

Plan Detail · Saved/List tab · Home featured · content deep link · habit layer · push · auto merge · conflict UI · automated test coverage · retire mobile read API routes · sync Edge Function migration

## Release Notes

`docs/ref/HUNNY_RELEASE_LOG.md`에 build number, track, package ID, testing focus 기록
