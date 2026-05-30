# Product Strategy

제품 정체성의 **소스 오브 트루스**. 제품·UX·우선순위 결정 시 이 문서를 기준으로 합니다.

## 한 줄 정의

**Hunny Bible Tracker는 content-led Bible reading habit app**입니다. 접근하기 쉬운 Bible story와 짧은 guided content로 시작해, 관련 reading plan을 **한 chapter씩** 진행하며 꾸준한 읽기 습관을 만듭니다.

> Hunny Bible Tracker helps people discover approachable Bible stories, understand Scripture through short guided content, and build a steady Bible reading habit one chapter at a time.

## 타겟 사용자

**Primary:** Bible 읽기를 시작하고 싶지만 어디서부터 할지 모르는 사람, 교회는 다니지만 reading habit이 없는 사람, Scripture가 부담스러운 사람, 오랜만에 다시 시작하는 사람.

**Secondary:** story-led plan과 simple progress tracking을 원하는 regular reader.

Power user용 full Bible text reader는 목표가 아닙니다.

## 핵심 루프

```text
Discover → Understand → Read → Track → Return
```

1. **Discover** — story, message, essay, video, cartoon 등 콘텐츠 발견
2. **Understand** — 읽기 전 짧은 context·background·visual support
3. **Read** — related plan 시작, chapter checkoff
4. **Track** — progress, estimated reading time, streak, reading activity, completed plans
5. **Return** — Today's Message, Discover, current plan progress, habit stats

## 앱이 하는 일 / 하지 않는 일

| 하는 일 | 하지 않는 일 |
| --- | --- |
| content-led reading habit app | full Bible text reader |
| story-led plan tracker | devotional-only (progress 없음) |
| short content → plan 연결 | social network |
| offline-first + optional backup/restore | live multi-device sync (아직) |
| gentle companion 톤 | heavy gamification / badge system |

**현재 surface:** Home, Discover, Read, Plans(전체 화면), Settings. Saved/List는 deferred.

## Product pillars

- **Approachable entry** — 짧은 story·guided content로 진입 장벽 낮춤
- **Guided understanding** — 읽기 전 context
- **Simple reading flow** — section-based plan, chapter checkoff
- **Visible habit growth** — progress, streak, today minutes (habit layer 예정)
- **Calm return paths** — Today's Message, Discover, plan progress

## 우선순위 원칙

1. Closed testing stability
2. Real content/plan seed → meaningful QA
3. Habit layer는 core Read flow 안정 후
4. Content surface 우선, social은 Not Now
5. Mobile local-first — server는 catalog + backup
6. One chapter at a time

구현 순서: `docs/to-do/CURRENT_FOCUS.md` · 로드맵: `docs/PRODUCT_ROADMAP.md`

## Tone & brand

**gentle guide + calm companion + minimal tracker**

- Warm, calm, inviting — guilt-driven copy 금지
- 핵심 문구: *Start with a story.* · *One chapter at a time.* · *Pick up where you left off.*
- Faith: Scripture 중심, sermon tone보다 approachable rhythm

### 마케팅 카피 참고 (영문)

| 용도 | 문구 |
| --- | --- |
| Hero headline | Bible reading, without the overwhelm. |
| Supporting | Start with short, approachable Bible stories, track your progress, and build a reading habit at your own pace. |
| App Store short | Start with short Bible stories, track progress, and build a reading habit. |

## Guardrails (변하지 않음)

- Mobile은 Supabase Postgres에 **직접 연결하지 않음** (API routes only)
- `user_plan_chapters`는 local derived data
- Backup/restore = account recovery, live collaborative sync 아님
- Full Bible text storage, complex social, automatic multi-device merge — scope 변경 전까지 Not Now

## 관련 문서

- `docs/PRODUCT_ROADMAP.md` — 현재 상태·Now/Next/Later
- `docs/to-do/CURRENT_FOCUS.md` — 지금 하는 일
- `docs/ARCHITECTURE.md` — 기술 맵
