# Cloudflare 대시보드 Git 연동 (Workers Builds)

`hunny-bible-tracker-web` Worker에 GitHub 저장소 `5Tori/hunny-bible-tracker`를 연결해 **push → 자동 빌드·배포**하는 설정입니다.

로컬 `pnpm run deploy`와 **같은 OpenNext + Wrangler** 경로를 씁니다.

---

## 1. 사전 확인

| 항목 | 값 |
| --- | --- |
| Cloudflare Worker 이름 | `hunny-bible-tracker-web` (`apps/web/wrangler.jsonc`의 `name`과 **동일**해야 함) |
| GitHub 저장소 | `5Tori/hunny-bible-tracker` |
| 프로덕션 브랜치 | `main` |
| 커스텀 도메인 | `hunnybibletracker.com` (이미 연결됨) |

Worker 이름이 다르면 빌드가 `The name in your Wrangler configuration file must match` 로 실패합니다.

---

## 2. GitHub 연결

1. [Cloudflare 대시보드](https://dash.cloudflare.com/) → **Workers & Pages**
2. **`hunny-bible-tracker-web`** 선택 (새로 만들지 말고 **기존 Worker**)
3. **Settings** → **Builds** → **Connect to GitHub**
4. GitHub 앱 설치·권한: `5Tori/hunny-bible-tracker` 저장소 접근 허용
5. 저장소·브랜치 `main` 선택

---

## 3. Build 설정 (복사해서 붙여넣기)

**Settings → Builds → Build configuration**

| 필드 | 값 |
| --- | --- |
| **Root directory** | *(비움 — 저장소 루트)* `pnpm-lock.yaml`이 루트에 있어야 합니다 |
| **Build command** | `pnpm install --frozen-lockfile && pnpm --filter @hunny-bible-tracker/web run cf:build` |
| **Deploy command** | `pnpm --filter @hunny-bible-tracker/web run cf:deploy` |
| **Production branch** | `main` |

### Build watch paths (선택, 권장)

`apps/web`만 바뀔 때만 빌드하려면 **Build watch paths**에 추가:

```
apps/web/**
pnpm-lock.yaml
package.json
pnpm-workspace.yaml
```

---

## 4. Build variables (빌드 시 — `NEXT_PUBLIC_*` 박히는 값)

**Settings → Builds → Build variables and secrets** → **Add variable**

| Variable name | Value |
| --- | --- |
| `NEXT_PUBLIC_SITE_URL` | `https://hunnybibletracker.com` |
| `NEXT_PUBLIC_GTM_ID` | `GTM-TWDZMRJW` |

`cf:build` / `deploy` 스크립트가 이 값을 읽어 OG·sitemap·GTM 스니펫을 빌드에 넣습니다.

---

## 5. Variables & Secrets (런타임 — Worker 실행 시)

**Settings → Variables and Secrets** (Builds가 아님)

`wrangler.jsonc`의 `vars`에 있는 공개 값은 이미 들어가 있을 수 있습니다. **비밀**은 대시보드에 반드시 등록하세요 (Git에 넣지 않음).

| 이름 | 타입 | 비고 |
| --- | --- | --- |
| `SUPABASE_SERVICE_ROLE_KEY` | Secret | Supabase → Settings → API |
| `CLOUDINARY_API_SECRET` | Secret | Cloudinary 대시보드 |
| `CLOUDINARY_API_KEY` | Secret | (API에서 키 쓰는 경우) |
| `DATABASE_URL` | Secret | 선택 — Hyperdrive가 DB 연결 담당 |

로컬에서 `wrangler secret put`으로 넣었어도, **Git 배포 환경에는 대시보드 Secret이 따로 필요**할 수 있습니다. 배포 후 Admin·API가 500이면 여기를 먼저 확인하세요.

`NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION` (Search Console)을 쓰면 **Variables**에 추가 후 한 번 재배포합니다.

---

## 6. Non-production 브랜치 (선택)

PR/다른 브랜치용 **Non-production branch deploy command**:

```bash
pnpm --filter @hunny-bible-tracker/web exec wrangler versions upload
```

프리뷰 URL은 Workers 버전 URL로 확인합니다.

---

## 7. 첫 배포 확인

1. **Builds** 탭에서 최신 빌드 로그 열기  
2. 성공 시 **Deployments**에서 새 버전 확인  
3. https://hunnybibletracker.com/api/health  
4. 홈 페이지 소스에 `GTM-TWDZMRJW` 또는 `googletagmanager.com/gtm.js` 포함 여부

실패 시 흔한 원인:

| 로그 | 조치 |
| --- | --- |
| Worker name mismatch | 대시보드 Worker 이름 = `hunny-bible-tracker-web` |
| `pnpm install` 실패 | Root directory가 비어 있는지 확인 |
| OpenNext / Next 빌드 실패 | Build variables에 `NEXT_PUBLIC_*` 있는지 확인 |
| Deploy 후 API 500 | Variables & Secrets에 Supabase/Cloudinary secret |

---

## 8. 로컬 배포와 병행

| 방법 | 언제 |
| --- | --- |
| **Git push** | 일상 배포 (연동 후) |
| `cd apps/web && pnpm run deploy` | 긴급 수정·Secrets 테스트 |

둘 다 같은 Worker에 올라갑니다.

---

## 9. Vercel / GitHub Actions

- **Vercel**: 저장소 연결 해제 권장 (중복 배포·실패 알림 방지)
- **GitHub Actions**: 제거됨 — Cloudflare Builds만 사용

---

## 스크립트 참고 (`apps/web/package.json`)

| 스크립트 | 용도 |
| --- | --- |
| `cf:build` | `opennextjs-cloudflare build` (Cloudflare Build command) |
| `cf:deploy` | `opennextjs-cloudflare deploy` (Cloudflare Deploy command) |
| `deploy` | 로컬: build + deploy (env는 셸에서 `NEXT_PUBLIC_*` export 또는 `.env.local`) |

로컬에서 Git과 동일한 public env로 배포:

```bash
cd apps/web
export NEXT_PUBLIC_SITE_URL=https://hunnybibletracker.com
export NEXT_PUBLIC_GTM_ID=GTM-TWDZMRJW
pnpm run deploy
```
