# Current Focus

**지금 무엇을 하는가** — 운영용. 제품 방향은 `docs/PRODUCT_STRATEGY.md`.

## Goal

Post-MVP 방향 정리: **content-led Bible reading + habit tracking**.

## Active Work

1. ~~Android closed-test QA~~ ✓ (2026-05-29)
2. ~~iOS closed-test QA~~ ✓
3. **v0.5.0+11** Play/TestFlight upload (`app-release.aab` / `.ipa`)
4. ~~Real plan/content seed~~ ✓
5. ~~Habit layer — Settings activity grid~~ ✓
6. ~~Message Card Library (web Phase 0–4)~~ ✓
7. Plan Detail

## 완료 (재오픈 금지)

- Documentation 정리·한국어화
- Cloudflare Workers + Supabase 아키텍처 문서 정렬
- **Supabase-first hybrid** — mobile RPC read + API write (`HUNNY_REMOTE_READ_MODE=supabase_rpc`)
- **Sync/restore E2E** — Settings SYNC, Supabase Admin REST storage
- **Home engagement** — heart (one-way), save (toggle), share
- **Home plan hero (v0.5.0+11)** — Current plan · progress ring · chapters read · tap → Read + last-read scroll · weekly/last-read footer
- **ReadingStatsRepository** — progress vs activity stats split; Settings summary + activity grid
- **Settings tab UX** — background refresh (no Sign out flicker) · pull-to-refresh for stats
- **Web admin** — plan list/detail via Supabase Admin REST; Hyperdrive per-query client (admin 500 fix)
- **Infra** — Hyperdrive password align, `/api/health` `db: true`, deploy via `pnpm run deploy`

## Implementation sequence

1. ~~Documentation cleanup~~ ✓
2. ~~Closed testing QA (Android + iOS)~~ ✓ → release artifact
3. ~~`bible_chapters` + estimated reading time (mobile UI)~~ ✓
4. ~~Admin/seed `estimated_minutes` reconcile~~ ✓
5. ~~Daily reading goal + today read minutes~~ ✓
6. ~~Reading stats / streak / calendar~~ ✓ (Settings bottom panel + `ReadingStatsRepository`)
7. ~~Message Card Library (web)~~ ✓ — `/messages`, Admin, API, Today link — **관계 정리:** `docs/to-do/CONTENT_REFACTOR_MEMO.md`
8. ~~Home plan hero + weekly footer (mobile)~~ ✓ (v0.5.0+11)
9. Plan Detail
10. Story Card / Content Detail
11. Home featured content
12. Saved (List tab)
13. Push notifications
14. Visual explainers · video/animation

## Not Now

Full Bible reader · social · heavy animation production · auto multi-device merge · conflict UI · sync Edge Function migration · retire mobile read API routes (keep RPC + API fallback until stable)

## Checklists

- **Content refactor direction:** `docs/to-do/CONTENT_REFACTOR_MEMO.md` — Message Card ↔ Today's Message (confirmed)
- Release: `docs/to-do/MVP_CLOSE_TESTING_TODO.md`
- Roadmap: `docs/PRODUCT_ROADMAP.md`
