# GA4 · GTM · Google Search Console 설정

프로덕션 도메인: **https://hunnybibletracker.com**

코드는 **공개 마케팅 페이지**(`(public)` 라우트)에만 태그를 넣습니다. `/admin`에는 GA/GTM이 로드되지 않습니다.

---

## 1. GA4 (Google Analytics 4)

### 이미 만든 스트림 (참고)

| 항목 | 값 |
| --- | --- |
| 스트림 URL | `https://hunnybibletracker.com` |
| 측정 ID | `G-8RSLHM5PHV` |
| 스트림 ID | `14966153928` |

### 사이트에 태그 넣기 (완료)

`apps/web`에 측정 ID가 연결되어 있습니다.

- `wrangler.jsonc` → `NEXT_PUBLIC_GA_MEASUREMENT_ID`
- 배포 시 `pnpm run deploy`가 빌드에 동일 ID를 주입

**배포 후 확인**

1. [GA4](https://analytics.google.com/) → **관리** → **데이터 스트림** → `Hunny Bible Tracker`
2. **태그 설정** → **설치 안내** → **실시간** 보고서
3. 시크릿 창에서 https://hunnybibletracker.com 을 연 뒤 실시간에 `1` active user가 보이면 성공 (최대 몇 분 지연 가능)

경고 *「데이터 수집이 활성화되지 않음」* 은 배포 전이거나 48시간 미만일 때 자주 보입니다. 실시간만 먼저 확인하세요.

---

## 2. GTM (Google Tag Manager) — 선택

GTM을 쓰면 **태그를 대시보드에서** 바꿀 수 있습니다. GTM을 켜면 코드의 **직접 GA4(gtag)는 자동으로 끕니다** (이중 집계 방지).

### GTM 컨테이너 만들기

1. [tagmanager.google.com](https://tagmanager.google.com/) → **계정 만들기**
2. 컨테이너 이름: `Hunny Bible Tracker` · 플랫폼: **웹**
3. 컨테이너 ID 복사: `GTM-XXXXXXX`

### GA4 태그를 GTM 안에 연결

1. GTM → **태그** → **새로 만들기**
2. 태그 유형: **Google 애널리틱스: GA4 구성**
3. 측정 ID: `G-8RSLHM5PHV`
4. 트리거: **All Pages** (`Initialization - All Pages` 또는 `Page View - All Pages`)
5. **제출** → **게시**

### 사이트에 GTM ID 넣기

`apps/web/wrangler.jsonc` (또는 Cloudflare Worker 환경 변수):

```jsonc
"NEXT_PUBLIC_GTM_ID": "GTM-XXXXXXX",
"NEXT_PUBLIC_GA_MEASUREMENT_ID": "",
```

`NEXT_PUBLIC_GA_MEASUREMENT_ID`를 비우고 GTM만 켜야 합니다. 그다음:

```bash
cd apps/web && pnpm run deploy
```

---

## 3. Google Search Console

### 속성 추가

1. [Google Search Console](https://search.google.com/search-console)
2. **속성 추가** → **URL 접두어**  
   `https://hunnybibletracker.com`
3. 소유권 확인 방법: **HTML 태그** 권장

### HTML 태그로 확인 (코드 연동)

Search Console이 보여 주는 메타 태그 예:

```html
<meta name="google-site-verification" content="abc123..." />
```

**`content=` 뒤 문자열만** 복사합니다.

`wrangler.jsonc`에 추가:

```jsonc
"NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION": "여기에_content_값",
```

배포 후 **확인** 버튼을 누릅니다.

로컬만 테스트할 때는 `apps/web/.env.local`에 동일 키를 넣고 `pnpm dev`로도 메타 태그가 출력되는지 볼 수 있습니다.

### 사이트맵 제출

소유권 확인 후:

1. Search Console → **Sitemaps**
2. 새 사이트맵 URL: `sitemap.xml`  
   (전체 URL: `https://hunnybibletracker.com/sitemap.xml`)

이미 `apps/web/src/app/sitemap.ts`가 위 URL을 생성합니다.

### URL 검사 (선택)

**URL 검사**에 `https://hunnybibletracker.com/` 입력 → **색인 생성 요청** (신규 도메인은 며칠~몇 주 걸릴 수 있음).

---

## 환경 변수 요약

| 변수 | 예시 | 용도 |
| --- | --- | --- |
| `NEXT_PUBLIC_GA_MEASUREMENT_ID` | `G-8RSLHM5PHV` | 직접 GA4 (GTM 미사용 시) |
| `NEXT_PUBLIC_GTM_ID` | `GTM-XXXXXXX` | GTM 사용 시 (GA4는 GTM 태그로) |
| `NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION` | Search Console `content` 값 | 소유권 확인 메타 태그 |

---

## GitHub Actions 배포

`.github/workflows/deploy-web-cloudflare.yml` 빌드에도 `NEXT_PUBLIC_GA_MEASUREMENT_ID`가 필요합니다 (또는 wrangler `vars`와 동일하게 맞춤).

Search Console verification 토큰은 **비밀이 아니지만** 저장소에 넣기 싫으면 Cloudflare 대시보드 Worker **Variables**에만 넣고 `wrangler.jsonc`에서는 빈 문자열로 둬도 됩니다. **반드시 빌드 시점에** `NEXT_PUBLIC_*`가 보여야 하므로, CI에서는 workflow `env`로 넘기거나 deploy 전 빌드 env를 맞추세요.

---

## 문제 해결

| 증상 | 확인 |
| --- | --- |
| GA4 실시간 0 | 최근 `pnpm run deploy` 했는지, 광고 차단기 꺼졌는지 |
| GA4 이중 집계 | GTM 켠 뒤 `NEXT_PUBLIC_GA_MEASUREMENT_ID` 비웠는지 |
| Search Console 확인 실패 | 배포 후 페이지 소스에 `google-site-verification` 메타 있는지 |
| Admin에 트래픽 섞임 | Admin은 `(public)` 밖 — 정상적으로 제외됨 |
