# Product Roadmap

전략적 우선순위 요약. 제품 정체성은 `docs/PRODUCT_STRATEGY.md`, 실행은 `docs/to-do/CURRENT_FOCUS.md` 참고.

## 방향

**Content-led Bible reading habit app** — Discover/Understand → Read → Track → Return.

Full Bible text reader가 아님. book/chapter reference, plan, progress, reading activity, admin-managed content만 다룸.

## 현재 제품 상태

| Tab | 상태 |
| --- | --- |
| Home | Today's Message, reflection, Read More, related plan CTA, progress, local save, heart/share |
| Discover | content finder/list — search, type/tag filter, detail sheet (online-only) |
| Read | section plan, chapter progress, quick plan switcher, completion flow |
| Settings | Supabase Auth, backup/restore, Manage plans, Help & feedback |

**Deferred:** Saved/List · **미구현:** Plan Detail

### Plans

전체 화면 Plan Manager. My Plans(Current / Completed / Archived), Catalog(Supabase template → local cache).

Catalog CTA: never started → Start Plan · active run → Continue · completed & no active → Start Again.

### Completion policy

모든 chapter 완료 → `completion_ready` → 사용자 확인 → `plan_completion_events` 1건 → Completed. Archive는 progress 보존.

## Launch definition (closed testing)

- Home Today's Message + stable Read + Plans(start/continue/archive/restore)
- Discover + offline-safe Home/Read startup
- Settings sign-in, backup/restore, feedback
- Saved/List hidden · Privacy/Terms/Support pages
- 체크리스트: `docs/to-do/MVP_CLOSE_TESTING_TODO.md`

## Now

Closed testing stability · content/plan seed · QA

## Next

`bible_chapters` UI · daily reading goal · today read minutes · reading stats · streak/calendar · Plan Detail

## Later

Home featured content · Story Card / Content Detail · Saved · push · visual explainers · video/animation

## Not Now

Full Bible reader · social · BibleProject-scale production · gamified levels · auto multi-device sync · conflict UI

## Guardrails

첫 화면은 useful해야 함(marketing page 아님) · Read flow 빠르게 · Google Auth sign-up/sign-in 구분 없음 · template ≠ user progress · reading activity ≠ current progress state · mobile → API only · compact backup에 `user_plan_chapters` 미포함
