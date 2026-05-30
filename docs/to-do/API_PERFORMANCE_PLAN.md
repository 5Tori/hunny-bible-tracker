# API Performance Plan (PR A)

Lightweight diagnostics only — **no query or architecture changes** in this PR.

## Goal

Measure where time is spent before optimizing:

- API route wall time
- DB query time (sum + count + slowest query preview)
- JSON payload size
- Mobile client request duration + timeout/reachability settings

## Enable server logs

| Env | Behavior |
| --- | --- |
| `NODE_ENV=development` | **On** by default (`pnpm web:dev`) |
| `API_PERF_LOG=1` | Force on (Workers preview / production smoke) |
| `API_PERF_LOG=0` | Force off |

Add to `apps/web/.env.local`:

```bash
API_PERF_LOG=1
```

## Log format (server)

Each instrumented route emits one JSON line:

```json
{
  "type": "api_perf",
  "route": "GET /api/v1/content",
  "method": "GET",
  "status": 200,
  "total_ms": 842.4,
  "db_ms": 780.2,
  "db_query_count": 12,
  "handler_ms": 62.2,
  "response_bytes": 48321,
  "slowest_db_query_ms": 210.5,
  "slowest_db_query": "select * from contents where ..."
}
```

### How to read fields

| Field | Meaning |
| --- | --- |
| `total_ms` | End-to-end route time (includes auth, JSON serialize, DB) |
| `db_ms` | Sum of measured SQL durations in this request |
| `handler_ms` | `total_ms - db_ms` (auth, CPU, network to Supabase overhead not in a query, JSON work) |
| `db_query_count` | Number of SQL round trips |
| `response_bytes` | UTF-8 JSON body size |
| `slowest_db_query` | Preview of the slowest SQL in this request |

**Note:** If `db_ms` is close to `total_ms` → DB-bound.  
If `handler_ms` is large with low `db_query_count` → auth / external API / serialization.  
If `response_bytes` is very large → payload-bound (mobile parse + transfer).

## Instrumented routes

| Route | File |
| --- | --- |
| `GET /api/health` | `apps/web/src/app/api/health/route.ts` |
| `GET /api/v1/plans` | `apps/web/src/app/api/v1/plans/route.ts` |
| `GET /api/v1/content` | `apps/web/src/app/api/v1/content/route.ts` |
| `GET /api/v1/content/[identifier]` | `apps/web/src/app/api/v1/content/[identifier]/route.ts` |
| `GET /api/v1/today-message` | `apps/web/src/app/api/v1/today-message/route.ts` |
| `POST /api/v1/sync/push` | `apps/web/src/app/api/v1/sync/push/route.ts` |
| `GET /api/v1/sync/bootstrap` | `apps/web/src/app/api/v1/sync/bootstrap/route.ts` |

Implementation:

- `apps/web/src/lib/perf/api-timing.ts` — route wrapper
- `apps/web/src/lib/perf/db-timing.ts` — per-request SQL aggregation
- `apps/web/src/lib/db/postgres.ts` — records each query duration when timing is active

Admin routes are **not** instrumented in PR A (add in PR B if needed).

## Local benchmark script

With `pnpm web:dev` running:

```bash
pnpm --dir apps/web bench:api
# or
HUNNY_API_BASE_URL=https://hunnybibletracker.com pnpm --dir apps/web bench:api
```

Script: `apps/web/scripts/bench-api.mjs` — client-side wall time + response bytes.

Compare script output (`totalMs`) with server `api_perf` logs (`total_ms`, `db_ms`).

## Mobile debug logs

`HunnyApiClient` logs in **debug builds only** (`kDebugMode`):

```text
[HunnyApi] GET /api/v1/plans 200 842ms connect=1200ms receive=2500ms
```

File: `apps/mobile/lib/core/api/hunny_api_client.dart`

Run app from IDE / `flutter run` and watch the console while opening Home, Discover, Plans, Settings sync.

## Current timeout / reachability values

From `apps/mobile/lib/core/api/hunny_api_client.dart`:

| Setting | Value | Used for |
| --- | --- | --- |
| `requestConnectTimeout` | **1200 ms** | Normal API calls |
| `requestReceiveTimeout` | **2500 ms** | Normal API calls (+ sendTimeout) |
| `probeConnectTimeout` | **1500 ms** | `/api/health` reachability probe |
| `probeReceiveTimeout` | **2000 ms** | Reachability probe |

From `HunnyApiReachability`:

| Setting | Value | Behavior |
| --- | --- | --- |
| `_onlineTtl` | **30 s** | Cached “online” — skips probe |
| `_offlineCooldown` | **20 s** | Cached “offline” — skips API attempts |

If server `total_ms` is 800ms but mobile times out, check:

1. Reachability probe added latency before the real request
2. `receiveTimeout` (2500ms) vs large payload on slow network
3. Double fetch (reachability + actual call)

## Measurement checklist

Run each scenario **3 times** (cold + warm):

### Web / server (`pnpm web:dev`)

1. `pnpm --dir apps/web bench:api`
2. Open admin pages and grep dev terminal for `"type":"api_perf"`
3. Note `db_query_count` for `/api/v1/plans` vs `detail=summary`

### Production smoke (optional)

```bash
API_PERF_LOG=1 pnpm --dir apps/web preview
# or temporary wrangler var, then curl endpoints
```

### Mobile (debug)

1. Home load → `[HunnyApi] ... /api/v1/today-message`
2. Discover → `/api/v1/content`
3. Plans tab → `/api/v1/plans`
4. Settings sign-in → `/api/v1/sync/bootstrap`, `/api/v1/sync/push`

Record: client `durationMs`, server `total_ms`, `db_ms`, `response_bytes`.

## Decision matrix (after PR A data)

| Pattern | Likely cause | Next PR |
| --- | --- | --- |
| High `db_ms`, high `db_query_count` | N+1 / heavy joins | PR B — batch queries |
| High `db_ms`, low count | Slow network / pooler / Hyperdrive | Connection tuning, local Supabase for dev |
| High `handler_ms`, low `db_ms` | Auth (sync routes), JSON work | Profile auth path |
| High `response_bytes`, moderate `total_ms` | Large payload | `detail=summary`, field pruning |
| Server fast, mobile slow | Timeout, reachability cache, device network | Adjust timeouts / cache TTL |
| Admin content 12s+, `db_query_count` 15+ | Admin list N+1 (known) | PR B — admin list batch (partially done locally) |

## Out of scope (PR A)

- Query refactors
- Caching layer
- Production permanent verbose logging (`API_PERF_LOG=0` in Workers vars by default)
- Admin API instrumentation

## Related docs

- `docs/DEVELOPMENT.md` — troubleshooting (Hyperdrive, network)
- `docs/to-do/CURRENT_FOCUS.md` — current sprint focus
