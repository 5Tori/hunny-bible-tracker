# Hunny Bible Tracker — Message Card Library Plan

## 1. 핵심 결론

`Today's Message`는 하나의 콘텐츠 타입이라기보다, 많은 `Message Card` 중 하루에 하나를 대표로 보여주는 **daily featured slot**으로 정리한다.

즉, 제품 구조는 아래처럼 잡는다.

```text
Message Card Library
  ├─ Search / Browse / Filter
  ├─ Shareable Message Cards
  ├─ Related Reading Plans
  └─ Daily Featured Slot = Today's Message
```

이렇게 하면 Home의 `Today's Message`는 유지하면서도, 웹과 모바일에서 사람들이 직접 말씀 카드를 찾고, 저장하고, 공유하고, 관련 플랜까지 이어갈 수 있다.

## 2. 제품 방향

### 한 줄 정의

사용자가 자신의 마음 상태와 상황에 맞는 말씀 카드를 빠르게 찾고, 예쁘게 공유하고, 필요하면 관련 성경 읽기 플랜으로 이어가게 하는 기능.

### 이 기능이 해결하는 문제

사용자는 보통 성경 구절을 “성경책 순서”로 찾기보다 아래와 같은 방식으로 찾는다.

- 불안할 때
- 미래가 막막할 때
- 인간관계 때문에 힘들 때
- 용기가 필요할 때
- 감사하고 싶을 때
- 잠들기 전에 평안이 필요할 때
- 누군가에게 위로의 말씀을 보내고 싶을 때

그래서 검색 구조도 “책/장/절” 중심이 아니라 **마음 상태 + 상황 + 신앙 주제** 중심이어야 한다.

### 제품 안에서의 역할

Message Card Library는 Hunny Bible Tracker의 핵심 루프 중 `Discover → Understand → Read → Track → Return`에서 `Discover`, `Understand`, `Return`을 강화한다.

```text
Message Card 발견
  → 내 상황에 맞는 말씀 확인
  → 저장 / 공유
  → 관련 reading plan 시작
  → 다시 앱으로 돌아올 이유 생성
```

## 3. 기능 범위

### MVP에 포함

- 웹에서 Message Card Library 구현
- 검색창
- 감정/상황 기반 필터
- 예쁜 카드 리스트
- 카드 상세 페이지 또는 상세 모달
- 공유용 이미지/카드 레이아웃
- `Today's Message`를 Message Card 중 하나와 연결
- Admin에서 message card 생성/수정/발행
- 관련 plan 연결

### MVP 이후

- 모바일 Discover에 같은 구조 반영
- 저장한 message cards
- 추천 알고리즘
- 인기 공유 카드
- 상황별 컬렉션 페이지
- 카드 디자인 템플릿 여러 개
- 사용자가 직접 카드 스타일 선택 후 공유
- 언어별 message card

### 지금 하지 않을 것

- 소셜 피드
- 댓글/팔로우
- 사용자가 직접 공개 카드 업로드
- 복잡한 추천 알고리즘
- 성경 전문 reader화
- 과한 gamification

## 4. 정보 구조

### 핵심 개념

| 개념 | 설명 |
| --- | --- |
| Message Card | 공유 가능한 말씀 카드 콘텐츠 단위 |
| Category | 가장 큰 분류. 사용자의 마음 상태 또는 필요 중심 |
| Situation | 그 감정/필요가 생긴 구체적 상황 |
| Theme Tag | 신앙적 주제 태그 |
| Tone | 카드의 말투와 목적 |
| Share Intent | 사용자가 이 카드를 누구에게/왜 공유하는지 |
| Today's Message | 날짜별 대표 카드 슬롯 |
| Related Plan | 이 메시지와 연결되는 읽기 플랜 |

### 추천 구조

```text
Primary Category
  → Situation
    → Theme Tags
      → Message Cards
```

예시:

```text
Anxiety & Worry
  → Future uncertainty
    → trust, waiting, peace, prayer
      → “When tomorrow feels heavy”
```

## 5. 카테고리 설계 원칙

카테고리는 너무 세밀하면 관리가 어려워지고, 너무 넓으면 사용자가 원하는 카드를 찾기 어렵다.

그래서 아래 원칙을 사용한다.

1. **카테고리 = 사용자의 큰 마음 상태 또는 필요**
2. **상황 = 그 마음 상태의 구체적 원인**
3. **태그 = 성경적 주제, 키워드, 문맥**
4. **검색어 = 사용자가 자연스럽게 입력하는 문장도 매칭**

예를 들어 “불안”은 카테고리이고, “미래가 불안함”, “관계 때문에 불안함”, “결정을 앞두고 불안함”은 상황이다.

## 6. MVP 카테고리 값

처음에는 8개 카테고리로 시작하는 것을 추천한다. 너무 많은 카테고리보다, 각 카테고리에 좋은 카드가 충분히 있는 것이 더 중요하다.

| Key | 한국어 이름 | 영어 이름 | 설명 |
| --- | --- | --- | --- |
| `anxiety_worry` | 불안과 염려 | Anxiety & Worry | 걱정, 두려움, 미래에 대한 불확실함 |
| `peace_rest` | 평안과 쉼 | Peace & Rest | 마음의 안정, 휴식, 하나님의 평안 |
| `hope_waiting` | 소망과 기다림 | Hope & Waiting | 지연, 기다림, 낙심 중의 소망 |
| `strength_courage` | 힘과 용기 | Strength & Courage | 지침, 두려움, 도전 앞에서의 용기 |
| `wisdom_guidance` | 지혜와 인도 | Wisdom & Guidance | 선택, 결정, 방향성, 분별 |
| `loneliness_belonging` | 외로움과 소속감 | Loneliness & Belonging | 혼자라고 느낄 때, 관계의 단절 |
| `forgiveness_grace` | 용서와 은혜 | Forgiveness & Grace | 죄책감, 회복, 다시 시작 |
| `gratitude_joy` | 감사와 기쁨 | Gratitude & Joy | 감사, 기쁨, 찬양, 일상의 은혜 |

## 7. 확장 카테고리 값

MVP 이후 콘텐츠가 늘어나면 아래 카테고리를 추가한다.

| Key | 한국어 이름 | 영어 이름 | 설명 |
| --- | --- | --- | --- |
| `grief_sorrow` | 슬픔과 상실 | Grief & Sorrow | 이별, 상실, 애통, 깊은 슬픔 |
| `love_relationships` | 사랑과 관계 | Love & Relationships | 가족, 친구, 연인, 공동체 관계 |
| `faith_trust` | 믿음과 신뢰 | Faith & Trust | 하나님을 신뢰하기 어려울 때 |
| `identity_worth` | 정체성과 가치 | Identity & Worth | 비교, 자존감, 내가 누구인지에 대한 질문 |
| `purpose_calling` | 목적과 부르심 | Purpose & Calling | 삶의 방향, 소명, 일의 의미 |
| `repentance_renewal` | 회개와 새로움 | Repentance & Renewal | 돌이킴, 새 출발, 마음의 변화 |
| `temptation_self_control` | 유혹과 절제 | Temptation & Self-Control | 습관, 욕심, 분노, 절제 |
| `protection_fear` | 보호와 두려움 | Protection & Fear | 위험, 불안전함, 하나님의 보호 |

## 8. Situation 값 설계

Situation은 사용자가 “내 이야기 같다”고 느끼게 만드는 핵심이다. 카테고리보다 더 실질적인 탐색 단위다.

### `anxiety_worry`

| Situation Key | 표시 이름 | 검색 문장 예시 |
| --- | --- | --- |
| `future_uncertainty` | 미래가 불안할 때 | “앞으로 어떻게 될지 모르겠어요” |
| `relationships` | 인간관계 때문에 불안할 때 | “사람 때문에 마음이 불편해요” |
| `decision_pressure` | 결정을 앞두고 불안할 때 | “무엇을 선택해야 할지 모르겠어요” |
| `money_work_pressure` | 돈이나 일 때문에 걱정될 때 | “일과 재정이 걱정돼요” |
| `health_fear` | 건강이 걱정될 때 | “몸과 건강 때문에 두려워요” |
| `feeling_behind` | 뒤처진 것 같을 때 | “나만 늦은 것 같아요” |
| `spiritual_doubt` | 믿음이 흔들릴 때 | “하나님이 멀게 느껴져요” |

### `peace_rest`

| Situation Key | 표시 이름 | 검색 문장 예시 |
| --- | --- | --- |
| `overwhelmed` | 마음이 너무 복잡할 때 | “머리가 너무 복잡해요” |
| `before_sleep` | 잠들기 전 평안이 필요할 때 | “자기 전에 마음을 가라앉히고 싶어요” |
| `busy_life` | 바쁜 하루 중 쉼이 필요할 때 | “쉴 틈이 없어요” |
| `inner_noise` | 마음의 소음이 클 때 | “생각이 멈추지 않아요” |
| `need_stillness` | 조용히 하나님 앞에 있고 싶을 때 | “잠시 멈추고 싶어요” |

### `hope_waiting`

| Situation Key | 표시 이름 | 검색 문장 예시 |
| --- | --- | --- |
| `waiting_season` | 기다림의 시간을 지날 때 | “언제 끝날지 모르겠어요” |
| `discouraged` | 낙심될 때 | “힘을 내기가 어려워요” |
| `unanswered_prayer` | 기도가 응답되지 않는 것 같을 때 | “기도해도 달라지는 게 없는 것 같아요” |
| `new_beginning` | 새 시작이 필요할 때 | “다시 시작하고 싶어요” |
| `long_process` | 과정이 길게 느껴질 때 | “너무 오래 걸리는 것 같아요” |

### `strength_courage`

| Situation Key | 표시 이름 | 검색 문장 예시 |
| --- | --- | --- |
| `tired` | 지치고 힘이 없을 때 | “오늘 너무 지쳤어요” |
| `afraid_to_start` | 시작이 두려울 때 | “시작하기가 무서워요” |
| `facing_challenge` | 어려운 일을 앞두고 있을 때 | “큰 일을 앞두고 있어요” |
| `need_endurance` | 끝까지 버틸 힘이 필요할 때 | “포기하고 싶어요” |
| `standing_firm` | 흔들리지 않고 서고 싶을 때 | “마음을 굳게 하고 싶어요” |

### `wisdom_guidance`

| Situation Key | 표시 이름 | 검색 문장 예시 |
| --- | --- | --- |
| `big_decision` | 큰 결정을 앞두고 있을 때 | “중요한 선택을 해야 해요” |
| `confused_direction` | 방향을 모르겠을 때 | “어디로 가야 할지 모르겠어요” |
| `need_discernment` | 분별이 필요할 때 | “무엇이 옳은지 알고 싶어요” |
| `work_school_choice` | 일이나 공부의 길을 고민할 때 | “커리어/학교 선택이 고민돼요” |
| `relationship_decision` | 관계 안에서 지혜가 필요할 때 | “이 관계를 어떻게 해야 할지 모르겠어요” |

### `loneliness_belonging`

| Situation Key | 표시 이름 | 검색 문장 예시 |
| --- | --- | --- |
| `feeling_alone` | 혼자인 것 같을 때 | “아무도 내 마음을 모르는 것 같아요” |
| `left_out` | 소외감을 느낄 때 | “나만 빠진 것 같아요” |
| `far_from_god` | 하나님이 멀게 느껴질 때 | “하나님이 가까이 계신지 모르겠어요” |
| `need_comfort` | 조용한 위로가 필요할 때 | “그냥 위로받고 싶어요” |
| `missing_home` | 집이나 공동체가 그리울 때 | “어딘가에 속하고 싶어요” |

### `forgiveness_grace`

| Situation Key | 표시 이름 | 검색 문장 예시 |
| --- | --- | --- |
| `guilt` | 죄책감이 들 때 | “내가 너무 부족한 것 같아요” |
| `shame` | 부끄러움이 마음을 누를 때 | “다시 하나님께 가기 어려워요” |
| `need_mercy` | 긍휼이 필요할 때 | “용서받고 싶어요” |
| `starting_over` | 다시 시작하고 싶을 때 | “새롭게 시작하고 싶어요” |
| `forgiving_others` | 누군가를 용서하기 어려울 때 | “용서가 잘 안 돼요” |

### `gratitude_joy`

| Situation Key | 표시 이름 | 검색 문장 예시 |
| --- | --- | --- |
| `morning_gratitude` | 아침에 감사로 시작하고 싶을 때 | “오늘을 감사로 시작하고 싶어요” |
| `small_blessings` | 작은 은혜를 기억하고 싶을 때 | “작은 것에 감사하고 싶어요” |
| `celebration` | 기쁜 일을 나누고 싶을 때 | “좋은 일이 있었어요” |
| `contentment` | 만족하는 마음이 필요할 때 | “충분함을 느끼고 싶어요” |
| `praise` | 하나님을 찬양하고 싶을 때 | “찬양하는 마음을 갖고 싶어요” |

## 9. Theme Tag 값

Theme Tag는 여러 카테고리를 가로질러 붙을 수 있다. 예를 들어 `trust`는 불안, 기다림, 믿음 카테고리 모두에 붙을 수 있다.

### MVP Theme Tags

| Key | 표시 이름 | 설명 |
| --- | --- | --- |
| `trust` | 신뢰 | 하나님을 의지함 |
| `peace` | 평안 | 마음의 안정과 쉼 |
| `hope` | 소망 | 미래에 대한 기대와 믿음 |
| `prayer` | 기도 | 하나님께 마음을 드림 |
| `waiting` | 기다림 | 지연과 인내의 시간 |
| `courage` | 용기 | 두려움 앞에서 나아감 |
| `wisdom` | 지혜 | 선택과 분별 |
| `guidance` | 인도하심 | 방향과 길 |
| `grace` | 은혜 | 값없이 주어지는 사랑 |
| `forgiveness` | 용서 | 하나님과 사람 사이의 회복 |
| `comfort` | 위로 | 아픔 중에 받는 돌봄 |
| `strength` | 힘 | 지친 마음을 붙듦 |
| `joy` | 기쁨 | 하나님 안의 기쁨 |
| `gratitude` | 감사 | 받은 은혜를 기억함 |
| `identity` | 정체성 | 하나님 안에서의 나 |
| `purpose` | 목적 | 삶의 방향과 부르심 |
| `faith` | 믿음 | 보이지 않는 것을 신뢰함 |
| `rest` | 쉼 | 멈춤과 회복 |

### 성경 문맥 태그

| Key | 표시 이름 |
| --- | --- |
| `psalms` | Psalms |
| `proverbs` | Proverbs |
| `gospels` | Gospels |
| `paul_letters` | Paul’s Letters |
| `prophets` | Prophets |
| `old_testament_story` | Old Testament Story |
| `jesus_words` | Words of Jesus |

## 10. Tone 값

Tone은 같은 구절이라도 카드가 어떤 느낌으로 전달되는지를 정한다.

| Key | 표시 이름 | 사용 상황 |
| --- | --- | --- |
| `comfort` | 위로 | 슬픔, 외로움, 불안 |
| `encouragement` | 격려 | 용기, 시작, 도전 |
| `reflection` | 묵상 | 조용히 생각하게 하는 카드 |
| `prayerful` | 기도 | 기도문처럼 읽을 수 있는 카드 |
| `gratitude` | 감사 | 감사와 찬양 |
| `challenge` | 도전 | 회개, 순종, 결단 |
| `assurance` | 확신 | 하나님의 약속을 붙드는 카드 |

## 11. Share Intent 값

공유 목적을 별도 태그로 두면 “내가 볼 카드”와 “누군가에게 보낼 카드”를 다르게 추천할 수 있다.

| Key | 표시 이름 | 설명 |
| --- | --- | --- |
| `for_self` | 나를 위해 | 개인 묵상용 |
| `send_comfort` | 위로를 보내기 | 힘든 사람에게 보내기 좋음 |
| `send_encouragement` | 격려를 보내기 | 도전 앞에 있는 사람에게 좋음 |
| `morning_share` | 아침 인사 | 하루 시작용 |
| `night_share` | 밤 묵상 | 잠들기 전 공유용 |
| `thank_you` | 감사 전하기 | 고마운 사람에게 보내기 좋음 |
| `celebration` | 기쁨 나누기 | 좋은 일을 함께 기뻐할 때 |

## 12. Message Card 데이터 모델 제안

기존 구조에서는 `contents.content_type = message`를 사용한다. `today_messages`는 날짜별 슬롯으로 유지하되, 가능한 한 `content_id`를 통해 Message Card와 연결한다.

### 추천 필드

```ts
interface MessageCardContent {
  id: string;
  contentType: "message";
  status: "draft" | "published" | "archived";
  language: "en" | "ko" | "ja" | "zh";

  title: string;
  subtitle?: string;
  slug: string;

  verseReference: string;
  verseText?: string;
  translation?: string;

  shortReflection?: string;
  prayerText?: string;

  primaryCategory: string;
  situations: string[];
  themeTags: string[];
  bibleContextTags: string[];
  tone: string;
  shareIntents: string[];

  cardTemplateKey: string;
  shareImageAssetId?: string;

  relatedPlanIds: string[];

  isTodayEligible: boolean;
  isFeatured: boolean;
  sortWeight: number;

  publishedAt?: string;
  createdAt: string;
  updatedAt: string;
}
```

### DB 구현 방향

가장 안전한 순서는 아래와 같다.

#### Phase 1 — 기존 테이블 최대 활용

- `contents.content_type = 'message'` 사용
- `content_tags`에 category/situation/theme/tone/share_intent를 모두 tag로 저장
- `content_tag_links`로 연결
- `contents.metadata` 또는 유사 JSON 필드가 있다면 message-specific 값을 임시 저장
- `today_messages.content_id`로 message card 연결

#### Phase 2 — 태그 그룹 명확화

`content_tags`에 아래 필드를 추가하는 것을 검토한다.

```sql
ALTER TABLE content_tags
ADD COLUMN tag_type text;
```

추천 `tag_type` 값:

```text
category
situation
theme
bible_context
tone
share_intent
```

#### Phase 3 — Message 전용 메타데이터 정규화

Message Card가 제품 핵심이 되고 카드 수가 많아지면 아래처럼 별도 테이블을 검토한다.

```sql
CREATE TABLE message_card_metadata (
  content_id uuid PRIMARY KEY REFERENCES contents(id) ON DELETE CASCADE,
  verse_reference text NOT NULL,
  verse_text text,
  translation text,
  primary_category text NOT NULL,
  tone text,
  card_template_key text,
  is_today_eligible boolean DEFAULT true,
  is_featured boolean DEFAULT false,
  sort_weight int DEFAULT 0
);
```

MVP에서는 Phase 1 또는 Phase 2까지만 추천한다. 너무 빨리 전용 테이블을 늘리면 Admin CRUD가 복잡해진다.

## 13. API 설계

### Public API

```text
GET /api/v1/messages
GET /api/v1/messages/:slug
GET /api/v1/message-taxonomy
GET /api/v1/today-message
```

### 검색 API 예시

```text
GET /api/v1/messages?category=anxiety_worry
GET /api/v1/messages?category=anxiety_worry&situation=future_uncertainty
GET /api/v1/messages?q=I feel anxious about the future
GET /api/v1/messages?tag=trust&tone=comfort
```

### 응답 예시

```json
{
  "items": [
    {
      "id": "msg_001",
      "slug": "when-tomorrow-feels-heavy",
      "title": "When tomorrow feels heavy",
      "verseReference": "Matthew 6:34",
      "primaryCategory": "anxiety_worry",
      "situations": ["future_uncertainty"],
      "themeTags": ["trust", "peace", "prayer"],
      "tone": "comfort",
      "shareImageUrl": "https://...",
      "relatedPlans": [
        {
          "id": "plan_001",
          "title": "Start with Jesus"
        }
      ]
    }
  ]
}
```

## 14. 웹 UX 방향

웹에서 먼저 구현하는 이유는 다음과 같다.

- SEO 페이지로 확장 가능
- 공유 링크가 자연스럽게 웹으로 열림
- 카드 디자인과 필터 UX를 빠르게 테스트 가능
- 모바일보다 레이아웃 실험이 쉬움
- 반응 좋은 카테고리를 보고 모바일에 반영 가능

### 추천 라우트

```text
/messages
/messages/[slug]
/messages/categories/[category]
/messages/situations/[situation]
/today
```

### `/messages` 화면 구조

```text
Hero
  - Find a message for today.
  - Search input

Feeling chips
  - Anxious
  - Tired
  - Waiting
  - Need wisdom
  - Grateful

Situation chips
  - The future
  - A relationship
  - A decision
  - Work or money
  - Feeling alone

Featured collections
  - For anxious thoughts
  - Before sleep
  - When you need courage
  - For someone who needs comfort

Message card grid
  - Card image/preview
  - Title
  - Verse reference
  - Category + situation
  - Save / Share / Read more
```

### 카드 상세 구조

```text
Message Card Visual
Verse Reference
Short Reflection
Tiny Prayer
Tags
Related Reading Plan CTA
Share Button
More like this
```

### 애니메이션 방향

과하지 않고 “차분하고 부드러운” 느낌으로 간다.

- 필터 칩 선택 시 카드 grid가 부드럽게 fade/slide
- 카드 hover 시 살짝 lift
- 상세 모달은 아래에서 천천히 올라오는 sheet 느낌
- 검색 결과 변경 시 skeleton 또는 subtle fade
- 카드 공유 버튼은 작고 명확하게

웹에서는 `Framer Motion`을 선택적으로 사용할 수 있다. 단, 첫 구현에서는 CSS transition만으로도 충분하다.

## 15. 모바일 UX 반영 방향

웹에서 검증한 뒤 모바일에 가져온다.

### 모바일 Discover 탭

기존 Discover를 완전히 바꾸기보다, 상단에 Message Card 중심 진입점을 추가한다.

```text
Discover
  ├─ Search
  ├─ Message Cards
  │   ├─ How are you feeling?
  │   ├─ Situation chips
  │   └─ Card list
  ├─ Stories / Essays / Videos
  └─ Related Plans
```

### Home

Home의 Today’s Message는 계속 유지한다.

추가할 수 있는 CTA:

```text
Not what you need today?
Find another message
```

또는

```text
Browse more messages like this
```

### 모바일 애니메이션

Flutter에서는 아래 방향을 추천한다.

- `AnimatedSwitcher`: 필터 변경 시 카드 리스트 전환
- `AnimatedSize`: situation chips 확장/축소
- `Hero`: 카드 → 상세 화면 전환
- `DraggableScrollableSheet`: 카드 상세 시트
- `SliverAppBar`: 검색/카테고리 상단 고정

## 16. Admin UX 방향

Admin에서 Message Card를 쉽게 만들 수 있어야 콘텐츠가 쌓인다.

### Message Editor 필드

```text
Basic
  - Title
  - Slug
  - Language
  - Status

Scripture
  - Verse reference
  - Verse text
  - Translation

Card Content
  - Short reflection
  - Prayer text
  - Card template
  - Share image

Classification
  - Primary category
  - Situations
  - Theme tags
  - Bible context tags
  - Tone
  - Share intent

Connections
  - Related plans
  - Eligible for Today's Message
  - Featured
```

### Admin에서 중요한 UX

- Category 선택 후 situation 후보를 자동으로 좁혀주기
- 태그는 multi-select
- 카드 미리보기 실시간 제공
- 공유 이미지 preview 제공
- “Today’s Message로 예약” 버튼 제공
- 같은 verseReference 중복 경고

## 17. 콘텐츠 제작 가이드

### 좋은 Message Card의 조건

- 제목은 사용자의 상황과 바로 연결되어야 한다.
- 구절은 너무 길지 않아야 한다.
- 묵상은 설교처럼 길지 않고, 짧고 부드러워야 한다.
- 공유했을 때 부담스럽지 않아야 한다.
- 관련 plan CTA가 자연스러워야 한다.

### 제목 패턴

```text
When tomorrow feels heavy
For the moment you feel alone
When you need courage to begin
A quiet reminder before sleep
When waiting feels too long
When your heart needs peace
```

### 짧은 묵상 패턴

```text
God does not ask you to carry tomorrow before it arrives. Take the next small step with Him today.
```

### Prayer 패턴

```text
Lord, help me trust You with what I cannot control today. Give me peace for the next step. Amen.
```

### 주의할 점

- 죄책감을 자극하는 문구를 피한다.
- “믿음이 있으면 불안하지 않다” 같은 단정적 표현을 피한다.
- 힘든 상황을 너무 쉽게 해결되는 것처럼 말하지 않는다.
- 현대 영어 성경 본문을 사용할 경우 저작권/라이선스를 먼저 확인한다.
- 라이선스가 불확실하면 verse text는 짧게 쓰거나 reference 중심으로 처리한다.

## 18. 초기 Seed 콘텐츠 계획

처음부터 모든 카테고리를 채우기보다, MVP 8개 카테고리에 각각 6개씩 넣어 총 48개 카드로 시작하는 것을 추천한다.

| Category | 초기 카드 수 | 우선 상황 |
| --- | ---: | --- |
| Anxiety & Worry | 8 | future, relationships, decisions, feeling behind |
| Peace & Rest | 6 | sleep, overwhelmed, busy life |
| Hope & Waiting | 6 | waiting, unanswered prayer, new beginning |
| Strength & Courage | 6 | tired, challenge, endurance |
| Wisdom & Guidance | 6 | decision, direction, discernment |
| Loneliness & Belonging | 6 | alone, left out, far from God |
| Forgiveness & Grace | 5 | guilt, shame, starting over |
| Gratitude & Joy | 5 | morning, small blessings, praise |

### 초기 카드 예시

| Title | Category | Situation | Tags | Tone |
| --- | --- | --- | --- | --- |
| When tomorrow feels heavy | Anxiety & Worry | Future uncertainty | trust, peace, prayer | comfort |
| When you feel behind | Anxiety & Worry | Feeling behind | identity, trust, hope | assurance |
| Before you fall asleep | Peace & Rest | Before sleep | peace, rest, prayer | prayerful |
| When waiting feels long | Hope & Waiting | Waiting season | waiting, hope, faith | encouragement |
| Courage for the next step | Strength & Courage | Facing challenge | courage, strength, guidance | encouragement |
| When you need wisdom | Wisdom & Guidance | Big decision | wisdom, guidance, prayer | reflection |
| For the moment you feel alone | Loneliness & Belonging | Feeling alone | comfort, presence, faith | comfort |
| When you need to start again | Forgiveness & Grace | Starting over | grace, forgiveness, renewal | assurance |
| A quiet morning gratitude | Gratitude & Joy | Morning gratitude | gratitude, joy, praise | gratitude |

## 19. 검색 설계

검색은 단순 keyword search로 시작하되, 아래 필드를 모두 대상으로 삼는다.

```text
title
subtitle
verse_reference
short_reflection
primary_category label
situation labels
theme tag labels
search aliases
```

### Search Alias가 중요함

사용자는 같은 의미를 여러 방식으로 입력한다.

예:

```json
{
  "future_uncertainty": [
    "future",
    "tomorrow",
    "uncertain",
    "what if",
    "앞날",
    "미래",
    "막막",
    "걱정"
  ]
}
```

처음에는 DB 검색 + alias 매칭으로 충분하다. 추후 카드가 많아지면 full-text search 또는 semantic search를 검토한다.

## 20. 구현 순서

### Phase 0 — 기획 확정

- Message Card와 Today's Message 개념 분리 확정
- MVP category/situation/tag 값 확정
- Admin에서 어떤 필드를 입력할지 확정
- 웹 라우트 확정

### Phase 1 — 데이터 모델 정리

- `content_type = message` 기준 확정
- tag_type 또는 metadata 방식 결정
- `today_messages.content_id` 연결을 실제 운영 기준으로 사용
- seed taxonomy 파일 추가

추천 파일:

```text
apps/web/src/lib/message-taxonomy.ts
apps/web/src/lib/messages.ts
apps/web/db/seeds/message_cards_seed.sql
```

### Phase 2 — Admin 확장

- Content editor에 Message 전용 필드 추가
- Category / Situation / Tag multi-select 추가
- Related plans 연결 UI 추가
- Today eligible / Featured 설정 추가
- 카드 preview 추가

### Phase 3 — Public Web 구현

- `/messages` 리스트 페이지
- `/messages/[slug]` 상세 페이지
- category/situation 필터
- 검색
- 카드 grid
- 공유 버튼
- 관련 plan CTA

### Phase 4 — Today’s Message 연결

- Admin에서 특정 message card를 today slot으로 예약
- Home API는 기존 `/api/v1/today-message` 유지
- 응답에 message card metadata 포함
- today card에서 `/messages/[slug]`로 이동 가능하게 처리

### Phase 5 — Mobile 반영

- Discover 상단에 Message Cards 섹션 추가
- category/situation chips 추가
- message card detail sheet 추가
- Home Today’s Message에서 “more like this” CTA 추가
- 공유 이미지/링크 처리

### Phase 6 — 측정과 개선

측정 이벤트:

```text
message_search
message_category_select
message_situation_select
message_card_open
message_card_share
message_related_plan_click
today_message_open
today_message_share
```

보고 싶은 지표:

- 어떤 category가 가장 많이 선택되는가
- 어떤 situation에서 공유가 많이 일어나는가
- 어떤 카드가 related plan 시작으로 이어지는가
- 검색어 중 결과가 없는 표현은 무엇인가

## 21. 우선순위 추천

가장 먼저 해야 할 일은 “카드가 많아졌을 때도 운영 가능한 분류 체계”를 잡는 것이다.

추천 순서:

1. 이 문서 기준으로 taxonomy 확정
2. `message-taxonomy.ts` 만들기
3. Admin에서 category/situation/tag 입력 가능하게 만들기
4. 웹 `/messages` 페이지 만들기
5. 카드 48개 seed 작성
6. Today’s Message를 message card와 연결
7. 모바일 Discover에 반영

## 22. 코드 에이전트용 구현 프롬프트

```text
We are evolving Hunny Bible Tracker's Today's Message into a Message Card Library.

Current product direction:
- Hunny Bible Tracker is a content-led Bible reading habit app.
- The app is not a full Bible reader.
- Existing server content model includes contents, content_tags, content_tag_links, content_plan_links, and today_messages.
- contents.content_type already supports "message".
- today_messages should be treated as a daily featured slot that can point to a message card through content_id.

Goal:
Build the foundation for a Message Card Library on the web first, then prepare it for mobile Discover.

Implementation direction:
1. Add a central message taxonomy file with categories, situations, theme tags, bible context tags, tones, and share intents.
2. Extend message content handling so content_type="message" can include message-specific metadata such as verseReference, primaryCategory, situations, tone, shareIntents, cardTemplateKey, and related plans.
3. Build public web pages:
   - /messages
   - /messages/[slug]
   - optional category/situation routes
4. Add search and filters by category, situation, tag, and q.
5. Keep the UI minimal, calm, spacious, white background, charcoal text, soft gray surfaces, small warm yellow accent.
6. Add related reading plan CTA from message detail.
7. Keep Today's Message API compatible, but include linked message card metadata when content_id exists.

Do not build social features, comments, user-generated public cards, or a full Bible text reader.
```

## 23. 최종 추천

이 기능은 단순한 부가 기능이 아니라 Hunny Bible Tracker의 “콘텐츠 중심 진입점”을 훨씬 강하게 만드는 방향이다.

특히 웹에서 먼저 구현하면 SEO, 공유, 디자인 테스트, 콘텐츠 운영 검증을 동시에 할 수 있다. 이후 모바일에는 검증된 카테고리와 카드 UX만 가져가면 된다.

가장 중요한 제품 판단은 이것이다.

```text
Today's Message는 기능의 중심이 아니라, Message Card Library에서 매일 하나를 보여주는 슬롯이다.
```

따라서 앞으로의 구조는 아래처럼 가져가는 것이 좋다.

```text
Message Card Library first.
Today's Message as a featured daily card.
Related Plans as the next step.
Mobile Discover as the long-term home.
```
