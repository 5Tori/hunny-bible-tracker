# `apps/web/db` — 서버 DB 참고 자료

Supabase(Postgres) 스키마·시드·레거시 마이그레이션 스냅샷입니다. **실제 Supabase 적용**은 `supabase/migrations/` 를 사용하세요.

## 디렉터리

| 경로 | 내용 |
| --- | --- |
| `schema.sql` | 전체 서버 스키마 참고본 (baseline과 동기화 목적) |
| `migrations/` | 레거시 **증분** SQL (baseline 이전 이력 참고용). 현재 스키마는 `supabase/migrations/` |
| `seeds/content_test_seed.sql` | Discover용 **테스트 콘텐츠** (작가·태그·article/video/cartoon·`content_plan_links`) |
| `seeds/plans/` | 플랜 시드 설계 메모 (선택) |

## `migrations/` 파일 요약

| 파일 | 역할 |
| --- | --- |
| `20260517_content_catalog.sql` | `contents`, 태그, 작가, 관련 플랜 링크 등 콘텐츠 카탈로그 |
| `20260517_today_message_share_image.sql` | 오늘의 말씀 share 이미지 컬럼 |
| `20260518_content_author_verified.sql` | 작가 `is_verified` |
| `20260518_content_sections.sql` | 콘텐츠 섹션(슬라이드 등) |
| `20260518_content_type_cartoon.sql` | cartoon 타입 |

이 내용은 `supabase/migrations/20260528000000_baseline.sql` 에 통합되어 있습니다.

## 시드 데이터 (플랜 vs 콘텐츠)

| 종류 | Supabase 마이그레이션 | 비고 |
| --- | --- | --- |
| **읽기 플랜 카탈로그** | `supabase/migrations/2026052811*_seed_plan_*.sql` | 플랜별 1파일, `template_key` 기준 idempotent |
| **Discover 테스트 콘텐츠** | `seeds/content_test_seed.sql` | SQL Editor 또는 별도 마이그레이션으로 실행 |

플랜 시드는 Admin에서 만든 것과 동일한 테이블을 채웁니다: `plan_templates`, `plan_template_sections`, `plan_template_items`, (선택) `plan_tags`.

## 적용 순서 (Supabase)

1. `20260528000000_baseline.sql` (이미 적용됨)
2. `20260528110000_seed_plan_*.sql` — 번호 순서대로
3. (선택) `content_test_seed.sql` — Discover 로컬/스테이징 테스트용

```bash
supabase db push
# 또는 Dashboard → SQL → 파일 붙여넣기
```
