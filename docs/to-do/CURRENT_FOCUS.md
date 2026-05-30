# Current Focus

**지금 무엇을 하는가** — 운영용. 제품 방향은 `docs/PRODUCT_STRATEGY.md`.

## Goal

Post-MVP 방향 정리: **content-led Bible reading + habit tracking**.

## Active Work

1. ~~Android closed-test QA~~ ✓ (2026-05-29)
2. **iOS closed-test QA** + Play/TestFlight 빌드 (`versionCode` bump)
3. Real plan/content seed (Admin 또는 seed SQL)
4. Habit layer 준비 (`bible_chapters`, estimated reading time, daily goal, stats)

## 완료 (재오픈 금지)

- Documentation 정리·한국어화
- Cloudflare Workers + Supabase 아키텍처 문서 정렬
- **Supabase-first hybrid** — mobile RPC read + API write (`HUNNY_REMOTE_READ_MODE=supabase_rpc`)
- **Sync/restore E2E** — Settings SYNC, Supabase Admin REST storage
- **Home engagement** — heart (one-way), save (toggle), share
- **Infra** — Hyperdrive password align, `/api/health` `db: true`, deploy via `pnpm run deploy`

## Implementation sequence

1. ~~Documentation cleanup~~ ✓
2. ~~Closed testing QA (Android)~~ ✓ → iOS + release artifact
3. `bible_chapters` + estimated reading time
4. Daily reading goal
5. Today read minutes
6. Reading stats / streak / calendar
7. Plan Detail
8. Story Card / Content Detail
9. Home featured content
10. Saved (List tab)
11. Push notifications
12. Visual explainers · video/animation

## Not Now

Full Bible reader · social · heavy animation production · auto multi-device merge · conflict UI

## Checklists

- Release: `docs/to-do/MVP_CLOSE_TESTING_TODO.md`
- Roadmap: `docs/PRODUCT_ROADMAP.md`

## Uncommitted code (commit when ready)

모바일 sync/settings/home + web auth/sync/engagement REST 전환 — `git status` 참고.
