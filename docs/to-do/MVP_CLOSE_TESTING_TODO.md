# MVP Close Testing Todo

다음 closed-test build 전 **릴리스 체크리스트**. 로드맵이 아님.

## Done / Do Not Re-open

Read flow QA 완료 · Discover enabled · Saved/List hidden · Home Today's Message · content admin/API · Plans(full-screen, archive/restore) · feedback API · sync push/bootstrap · offline Home/Read · Discover offline message · launch/icon assets · **Documentation 정리·한국어화 (Cloudflare + Supabase 기준)**

## Before Build

**Infrastructure**

- [ ] `supabase/migrations/` ~ plan seeds `20260528110007` 적용
- [ ] Discover content: `apps/web/db/seeds/content_test_seed.sql` 또는 Admin publish
- [ ] Today's Message ≥1건 Admin publish
- [ ] Cloudflare Hyperdrive + secrets (`SUPABASE_SERVICE_ROLE_KEY`, Cloudinary)
- [ ] `ADMIN_EMAILS` · Google OAuth SHA-1 · release `HUNNY_API_BASE_URL=https://hunnybibletracker.com`

**Automated**

- [ ] `flutter analyze` · `flutter test` · `pnpm --dir apps/web typecheck`
- [ ] Android smoke test · `pubspec.yaml` `0.3.0+7` 확인

**Production API**

- [ ] `GET /api/health` 200
- [ ] `GET /api/v1/plans?sort=featured` (target: 8 plans)
- [ ] `GET /api/v1/content?sort=featured&language=en`
- [ ] `GET /api/v1/today-message?date=YYYY-MM-DD&language=en` — includes `linked_content` when `content_id` set

## Content Required

- Today's Message 1건+ · fallback(이전 publish_date) 동작
- `verse_text` / `bible_version` 분리
- Discover content (seed 또는 Admin publish)
- MVP plans: target **≥5** published plans (Joseph, Mark, Psalms for Anxiety, Life of David 등)
- Start Plan → valid `user_plan_chapters` · plan CTA via linked content (`content_plan_links`) when Today’s Message has `content_id`

## Manual QA

Fresh install Home · airplane mode Home/Read · Today's Message cache/fallback · Discover online/offline · search/filter/detail sheet · heart/share/save · Read More + plan CTA · Plans browse/manage · archive/restore · chapter persist · completion event · Start Again · Settings sign-in/sync/restore/feedback · launch screen

## Known Deferred

Plan Detail · Saved/List · Home featured · content deep link · habit layer · push · auto merge · conflict UI · automated test coverage

## Release Notes

`docs/ref/HUNNY_RELEASE_LOG.md`에 build number, track, package ID, testing focus 기록
