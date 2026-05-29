# Cloudflare Workers deploy (OpenNext)

`apps/web` deploys to **Cloudflare Workers**. Production URLs:

| URL | Role |
| --- | --- |
| `https://hunnybibletracker.com` | **Canonical** (custom domain; set `NEXT_PUBLIC_SITE_URL` to this) |
| `https://hunny-bible-tracker-web.<subdomain>.workers.dev` | Legacy worker hostname — **301** to the custom domain via middleware |

`www.hunnybibletracker.com` also **301**s to the apex. Preview deploy URLs (`*-hunny-bible-tracker-web...workers.dev`) are not redirected.

## Prerequisites

1. [Cloudflare account](https://dash.cloudflare.com/) + `wrangler login`
2. Supabase project `tbexpdwipdjgcjtlujis` with baseline migration applied
3. **Hyperdrive** (required — Workers cannot open raw TCP to Supabase)

## 1. Create Hyperdrive

Dashboard: **Workers & Pages** → **Hyperdrive** → **Create**

- Origin: Supabase **transaction pooler** connection string (port **6543**, `?pgbouncer=true`)
- Name: e.g. `hunny-bible-tracker-db`

Or CLI (paste your pooler URL):

```bash
cd apps/web
wrangler hyperdrive create hunny-bible-tracker-db \
  --connection-string="postgresql://postgres.tbexpdwipdjgcjtlujis:YOUR_PASSWORD@aws-0-REGION.pooler.supabase.com:6543/postgres?pgbouncer=true"
```

Copy the config **id** into [`apps/web/wrangler.jsonc`](../apps/web/wrangler.jsonc) → replace `REPLACE_HYPERDRIVE_ID`.

Optional local preview: add `localConnectionString` on that binding (same as `DATABASE_URL`) for `pnpm preview`.

## 2. Secrets and vars

```bash
cd apps/web
cp .dev.vars.example .dev.vars
# Fill .dev.vars (and/or use wrangler secret bulk)

wrangler secret put SUPABASE_SERVICE_ROLE_KEY
wrangler secret put DATABASE_URL          # fallback for tooling; runtime uses Hyperdrive
wrangler secret put CLOUDINARY_API_SECRET
# ... ADMIN_EMAILS can be wrangler secret or var
```

For **build-time** public env, set in Cloudflare dashboard → Worker → Settings → Variables:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `NEXT_PUBLIC_SITE_URL` (`https://hunnybibletracker.com` in `wrangler.jsonc`)
- `NEXT_PUBLIC_GTM_ID` (`GTM-TWDZMRJW` — public marketing analytics via GTM)
- `NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION` (optional; see [`GOOGLE_ANALYTICS_AND_SEARCH.md`](GOOGLE_ANALYTICS_AND_SEARCH.md))
- `SUPABASE_URL`
- `ADMIN_EMAILS`

## 3. Supabase redirect URLs

In **Authentication** → **URL configuration**:

1. **Site URL** (default redirect):  
   `https://hunnybibletracker.com`
2. **Redirect URLs** (allow list — add every environment you use):  
   - `https://hunnybibletracker.com/admin/login`  
   - `https://hunny-bible-tracker-web.hunnybibletracker.workers.dev/admin/login` (optional; workers.dev 301s to apex)  
   - `http://127.0.0.1:3000/admin/login` (local `next dev`)  
   - `http://localhost:3000/admin/login` (optional)

If the Workers URL is missing from Redirect URLs, Google sign-in from the live site can still succeed but Supabase will send you to **Site URL** (e.g. `http://localhost:3000/#access_token=...`).

## 4. Deploy

### 로컬에서 배포 (수동)

```bash
cd apps/web
pnpm install
pnpm run deploy
```

`pnpm deploy`는 **동작하지 않습니다** (pnpm 내장 명령). 반드시 `pnpm run deploy`를 사용하세요.

### GitHub Actions 자동 배포 (선택)

`main`에 `apps/web/**`가 push되면 [`.github/workflows/deploy-web-cloudflare.yml`](../.github/workflows/deploy-web-cloudflare.yml)이 실행됩니다.

**GA4 / GTM / Search Console은 GitHub 설정과 무관합니다.** 실패하는 워크플로는 Cloudflare 배포 전용입니다.

#### GitHub에 꼭 넣어야 하는 Secrets (2개)

Repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret 이름 | 값 얻는 방법 |
| --- | --- |
| `CLOUDFLARE_API_TOKEN` | [Cloudflare](https://dash.cloudflare.com/profile/api-tokens) → **Create Token** → **Edit Cloudflare Workers** 템플릿 → Account: 본인 계정 → Zone: All zones (또는 해당 zone) → **Continue to summary** → Create → 토큰 복사 (한 번만 표시) |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare 대시보드 → **Workers & Pages** → 오른쪽 **Account ID** (32자 hex) |

Secrets를 넣기 전에는 워크플로가 **의도적으로 실패**합니다 (빈 토큰으로 Wrangler 배포 방지).

설정 후 **Actions** 탭 → **Deploy web to Cloudflare Workers** → **Run workflow**로 수동 재실행하거나, 아무 커밋을 push해 확인하세요.

#### CI를 쓰지 않을 때

로컬에서만 `pnpm run deploy` 한다면 Actions 실패 알림이 거슬릴 수 있습니다. 그때는 워크플로 파일을 삭제하거나, `on.push`를 제거하고 `workflow_dispatch`만 남겨 두세요.

After adding a custom domain in Cloudflare → **Domains**, set `NEXT_PUBLIC_SITE_URL` to `https://hunnybibletracker.com` and redeploy so metadata, sitemap, and share URLs use the canonical host.

## 5. Local commands

| Command | Purpose |
| --- | --- |
| `pnpm dev` | Next.js dev server (uses `.env.local`) |
| `pnpm preview` | Build + Workers runtime locally (uses `.dev.vars`) |
| `pnpm run deploy` | Build + deploy to Cloudflare |

## Mobile API URL

Production/staging mobile builds:

```json
"HUNNY_API_BASE_URL": "https://hunnybibletracker.com"
```

## Troubleshooting

- **GitHub Actions 빨간 X**: Actions 로그에서 `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID` missing 여부 확인. 토큰 권한에 **Account.Workers Scripts** · **Account.Workers KV** · **User.User Details** Read 포함 권장.
- **DB errors on Workers**: Hyperdrive id missing/wrong in `wrangler.jsonc`, or pooler URL incorrect.
- **Admin OAuth redirect**: Supabase **Site URL** and **Redirect URLs** must include `https://hunnybibletracker.com/admin/login` when using the custom domain.
- **SEO**: `sitemap.xml`, `robots.txt`, OG tags, and JSON-LD use `NEXT_PUBLIC_SITE_URL`. Middleware consolidates `www` and the production workers.dev host onto the apex.
- **Unstyled site**: ensure `public/_headers` is present and OpenNext build completed (`.open-next/`).
