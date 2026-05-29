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

## 4. Deploy (로컬 — 공식 경로)

Vercel 시절의 Git 연동 배포는 쓰지 않습니다. **Cloudflare Workers**는 로컬에서 Wrangler로 올립니다.

```bash
cd apps/web
pnpm install   # 처음 한 번, 루트에서 해도 됨
pnpm exec wrangler login   # 최초 1회
pnpm run deploy
```

`pnpm deploy`는 **동작하지 않습니다** (pnpm 내장 명령). 반드시 **`pnpm run deploy`** 를 사용하세요.

스크립트가 빌드 시 `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_GTM_ID` 등을 주입하고, `wrangler.jsonc`의 `vars`·`secrets`와 함께 Worker에 배포합니다.

**GitHub Actions 워크플로는 사용하지 않습니다** (push마다 Secrets 없이 실패하던 중복 경로). GA4/GTM/Search Console도 GitHub 설정과 무관합니다.

### 나중에 push 시 자동 배포를 원할 때 (선택)

1. `.github/workflows/`에 Wrangler deploy 워크플로 추가  
2. GitHub **Secrets**: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`  
3. 또는 Cloudflare 대시보드 **Workers & Pages** → 프로젝트 → **Settings** → **Builds** 에서 GitHub 직접 연결 (Wrangler/OpenNext 빌드 명령을 맞출 것)

개인 프로젝트에서 로컬 배포만 해도 충분하면 위 CI는 생략해도 됩니다.

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

- **DB errors on Workers**: Hyperdrive id missing/wrong in `wrangler.jsonc`, or pooler URL incorrect.
- **Admin OAuth redirect**: Supabase **Site URL** and **Redirect URLs** must include `https://hunnybibletracker.com/admin/login` when using the custom domain.
- **SEO**: `sitemap.xml`, `robots.txt`, OG tags, and JSON-LD use `NEXT_PUBLIC_SITE_URL`. Middleware consolidates `www` and the production workers.dev host onto the apex.
- **Unstyled site**: ensure `public/_headers` is present and OpenNext build completed (`.open-next/`).
