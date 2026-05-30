# Database seeds (closed testing)

시드 적용 및 API 검증 가이드. **문서 전용** — 실제 SQL 마이그레이션은 별도 PR에서 추가 예정.

## 현재 저장소에 있는 시드

| 리소스 | 경로 | 내용 |
| --- | --- | --- |
| Baseline schema | `supabase/migrations/20260528000000_baseline.sql` | 전체 서버 스키마 |
| Plan catalog | `supabase/migrations/20260528110000_seed_plan_*.sql` | 8개 플랜 (MVP 5 + Jonah, Zacchaeus, Samuel) |
| Discover content (로컬 SQL) | `apps/web/db/seeds/content_test_seed.sql` | 4건 테스트 콘텐츠, plan 링크 포함 |
| Today's Message (로컬 SQL) | `apps/web/db/seeds/today_message_test_seed.sql` | Mode A(오늘) + Mode B(어제, linked content) |

## 적용 순서 (Supabase)

```bash
# 프로젝트 루트에서
supabase db push
```

Plan 시드는 `20260528110000`–`20260528110007` 마이그레이션에 포함됩니다.  
`estimated_minutes` 정합성: `20260601120400_reconcile_plan_estimated_minutes.sql` — [`PLAN_CATALOG.md`](PLAN_CATALOG.md) 참고.

Content 시드는 **아직 Supabase 마이그레이션 없음**. 로컬/스테이징 DB에 수동 적용:

```bash
psql "$DATABASE_URL" -f apps/web/db/seeds/content_test_seed.sql
psql "$DATABASE_URL" -f apps/web/db/seeds/today_message_test_seed.sql
```

`today_message_test_seed.sql`은 `20260529120000_simplify_today_messages.sql` 적용 **후** 실행하세요.

Today's Message는 **Admin** publish 또는 위 시드 SQL로 추가할 수 있습니다.

## 프로덕션 API 검증

`HUNNY_API_BASE_URL=https://hunnybibletracker.com`

```bash
curl -s "https://hunnybibletracker.com/api/health"
curl -s "https://hunnybibletracker.com/api/v1/plans?sort=featured" | jq '.plans | length'
curl -s "https://hunnybibletracker.com/api/v1/content?sort=featured&language=en" | jq '.contents | length'
curl -s "https://hunnybibletracker.com/api/v1/today-message?date=$(date +%Y-%m-%d)&language=en" | jq '.message'
```

클로즈드 테스트 목표: **8 plans**, **≥1 Today’s Message**, **≥4 content items** (Discover).

플랜 카탈로그 상세: [`PLAN_CATALOG.md`](PLAN_CATALOG.md)
