# API Performance Baseline

Captured before Supabase-first mobile read refactor (2026-05-30).

Environment: local `pnpm web:dev` → Supabase pooler (us-east-2), client bench via `pnpm --dir apps/web bench:api`.

## Public API (instrumented routes)

| Endpoint | Screen | Client avg (ms) | Server total_ms | db_ms | db_query_count | response_bytes | Cache / notes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| `GET /api/health` | reachability probe | 1400–1770 | 1156–1438 | ~1155–1436 | 1 | 57 | Cold pooler connect dominates |
| `GET /api/v1/today-message?language=en` | Home | 300–1800 | 284–1465 | ~283–1464 | 1–2 | 716 | Drift cache after first fetch; linked_content adds 2nd query |
| `GET /api/v1/content?sort=featured` | Discover | 2000–3500 | 2018–3276 | ~2047–3273 | 6 | 2296 | N+1 per content item |
| `GET /api/v1/plans?sort=featured` | Plans / onboarding | 8300–8500 | 8281–8295 | high (25 queries) | 25 | 35470 | **Primary bottleneck** — full sections/items/tags per plan |
| `GET /api/v1/plans?detail=summary` | Plans list (light) | 130–225 | 130–225 | ~129–224 | 1 | 6519 | Same catalog without relations |

## Admin API (not instrumented in PR A)

| Endpoint | Screen | Observed (ms) | Notes |
| --- | --- | ---: | --- |
| `GET /api/v1/admin/today-messages` | Admin TM list | 400–700 | Single query |
| `GET /api/v1/admin/content` | Admin content list | 12000–72000 | Was N+1 (20+ queries); batch fix in parallel track |
| `GET /api/v1/admin/plans` | Admin plans list | 500–850 | Single query |

## Mobile client settings (baseline)

| Setting | Value | File |
| --- | --- | --- |
| `requestConnectTimeout` | 8000ms | `hunny_api_client.dart` |
| `requestReceiveTimeout` | 20000ms | `hunny_api_client.dart` |
| Plan catalog timeouts | 8000ms / 20000ms | `plan_catalog_api_client.dart` (aligned with default) |
| Reachability online TTL | 30s | `HunnyApiReachability` |
| Reachability offline cooldown | 20s | `HunnyApiReachability` |

## Production smoke (2026-05-30)

Production was intermittently unhealthy (Hyperdrive/DB). Do not use as steady-state baseline until `/api/health` returns `db: true`.

## Diagnosis summary

1. **Plans full relations** — DB-bound, 25 queries, 35KB payload; mobile default 2.5s timeout insufficient.
2. **Content list** — 6 queries, ~2s; moderate N+1.
3. **Today’s Message** — 1–2 queries, ~300ms warm; acceptable but adds Worker hop vs direct RPC candidate.
4. **Admin content list** — worst admin path; optimize independently of mobile RPC.

## Post-refactor targets (PR 4 gate)

| Flow | Baseline | Target |
| --- | --- | --- |
| Home Today’s Message | ~300ms warm (API) | RPC p95 < 1s or 30%+ faster |
| Discover list | ~2s / 2.3KB | RPC p95 < 2s, payload < 10KB |
| Plan catalog | ~8s full / ~150ms summary | RPC summary-only p95 < 1s |

Update this file after PR 4 with RPC vs API comparison rows.

## PR 4 decision gate (2026-05-30)

| Decision | Result |
| --- | --- |
| Proceed with PR 2b/5/6 (content + plan RPC) | **Go** |
| Rationale | TM RPC is a single DB round-trip (no Worker hop); list/detail RPCs follow same pattern. API N+1 batch fixes land in parallel for fallback path. |
| Default mobile mode | `HUNNY_REMOTE_READ_MODE=api` (no regression); opt in with `supabase_rpc` after `supabase db push` |
| Next measurement | Compare `[HunnySupabase] rpc mobile_today_message_latest` vs `[HunnyApi] GET /api/v1/today-message` on device after migration deploy |
