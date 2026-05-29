# 플랜 카탈로그 시드 (설계 요약)

Supabase 시드 SQL: `supabase/migrations/20260528110000_seed_plan_*.sql`

## MVP + 마케팅 플랜 (8개)

| 순서 | `template_key` | 제목 | 장 수 | 섹션 구조 |
| --- | --- | --- | ---: | --- |
| 1 | `bible_in_a_year` | Bible in a Year | 1189 | OT 39권 + NT 27권 (권당 1 item) |
| 2 | `the_story_of_joseph` | The Story of Joseph | 14 | Genesis 37–50 (1 item) |
| 3 | `gospel_of_mark` | Gospel of Mark | 16 | Mark 1–8, 9–16 |
| 4 | `psalms_for_anxiety` | Psalms for Anxiety | 12 | 위로 6편 + 압박 6편 (개별 장) |
| 5 | `life_of_david` | Life of David | 17 | 1–2 Samuel 하이라이트 6구간 |
| 6 | `jonah` | The Story of Jonah | 4 | Jonah 1–4 (`content_test_seed` 링크용 key) |
| 7 | `the_story_of_zacchaeus` | The Story of Zacchaeus | 1 | Luke 19 |
| 8 | `samuels_early_life` | Samuel's Childhood | 3 | 1 Samuel 1–3 |

`featured_rank` 낮을수록 카탈로그 상단 (요셉·이야기형 플랜 우선, `bible_in_a_year`는 20).

## `apps/web/db`에 있던 다른 데이터

| 파일 | 내용 |
| --- | --- |
| `seeds/content_test_seed.sql` | Discover 테스트 콘텐츠 3건 + `content_plan_links` → `gospel_of_mark`, `psalms_for_anxiety`, `jonah` |
| `migrations/*.sql` | 스키마 증분 이력 (baseline에 통합됨) |

Admin에서 수동으로 만든 플랜(예: `the_story_of_jonah`)은 `template_key`가 다를 수 있습니다. 시드 실행 시 동일 key는 **삭제 후 재삽입**됩니다.

## `estimated_minutes` 재산출

Seed SQL의 `estimated_minutes`는 `bible_chapters.json`과 플랜 items 기준 평균(장당 분)입니다. items 변경 후:

```bash
pnpm run plan-estimates:update   # dry-run
pnpm run plan-estimates:write    # 8개 seed SQL in-place 갱신
```

## 적용 후 확인

```bash
curl -s "https://hunny-bible-tracker-web.hunnybibletracker.workers.dev/api/v1/plans?sort=featured" | jq '.plans | length'
```

모바일: 앱 재시작 또는 플랜 카탈로그 새로고침 후 Catalog에 8개 노출.
