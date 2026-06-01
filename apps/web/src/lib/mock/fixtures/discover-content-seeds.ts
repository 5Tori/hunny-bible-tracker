import type {
  ContentAsset,
  ContentRelatedPlan,
  ContentSection,
  ContentTag,
  ContentWithRelations,
} from '@/lib/content';
import type { DiscoverBlockType } from '@/lib/discover-blocks';
import { DISCOVER_GALLERY_ASSET_ROLE } from '@/lib/discover-content';
import { mockAuthor } from '@/lib/mock/fixtures/author';
import { MOCK_IDS, MOCK_TS } from '@/lib/mock/fixtures/ids';
import { getMockPlanByIdentifier } from '@/lib/mock/fixtures/plans';

type DiscoverContentType = 'video' | 'essay' | 'cartoon';

type DiscoverSectionSeed = {
  block_type: DiscoverBlockType;
  title?: string;
  body?: string;
  image_url?: string;
  image_alt_text?: string;
  image_caption?: string;
};

type DiscoverSlideSeed = {
  url: string;
  caption?: string;
  alt_text?: string;
};

export type DiscoverContentSeed = {
  slug: keyof typeof MOCK_IDS.discover;
  content_type: DiscoverContentType;
  title: string;
  subtitle?: string;
  summary: string;
  cover_image_url: string;
  external_url?: string;
  duration_seconds?: number;
  featured_rank: number;
  sections?: DiscoverSectionSeed[];
  slides?: DiscoverSlideSeed[];
  planLinks?: Array<{ templateKey: keyof typeof MOCK_IDS.plans; ctaLabel?: string }>;
  is_published?: boolean;
  is_archived?: boolean;
};

function relatedPlan(
  templateKey: keyof typeof MOCK_IDS.plans,
  ctaLabel: string | null = null,
): ContentRelatedPlan {
  const plan = getMockPlanByIdentifier(templateKey)!;
  return {
    relationship_type: 'related',
    display_order: 0,
    cta_label: ctaLabel,
    id: plan.id,
    template_key: plan.template_key,
    title: plan.title,
    subtitle: plan.subtitle,
    cover_image_url: plan.cover_image_url,
    total_chapters: plan.total_chapters,
    estimated_minutes: plan.estimated_minutes,
  };
}

function buildSections(contentId: string, seeds: DiscoverSectionSeed[]): ContentSection[] {
  return seeds.map((section, index) => ({
    id: `sec-${contentId.slice(0, 8)}-${index}`,
    content_id: contentId,
    order_index: index,
    title: section.title ?? null,
    body: section.body ?? null,
    image_url: section.image_url ?? null,
    image_public_id: null,
    image_alt_text: section.image_alt_text ?? null,
    image_caption: section.image_caption ?? null,
    metadata: { block_type: section.block_type },
    created_at: MOCK_TS,
    updated_at: MOCK_TS,
  }));
}

function buildSlides(contentId: string, seeds: DiscoverSlideSeed[]): ContentAsset[] {
  return seeds.map((slide, index) => ({
    id: `slide-${contentId.slice(0, 8)}-${index}`,
    content_id: contentId,
    asset_type: 'image',
    asset_role: DISCOVER_GALLERY_ASSET_ROLE,
    order_index: index,
    title: null,
    caption: slide.caption ?? null,
    alt_text: slide.alt_text ?? null,
    url: slide.url,
    public_id: null,
    provider: null,
    mime_type: 'image/webp',
    width: null,
    height: null,
    duration_seconds: null,
    metadata: {},
    created_at: MOCK_TS,
    updated_at: MOCK_TS,
  }));
}

export function buildDiscoverContent(seed: DiscoverContentSeed): ContentWithRelations {
  const id = MOCK_IDS.discover[seed.slug];
  const slug = seed.slug;
  const isPublished = seed.is_published !== false;
  const isArchived = Boolean(seed.is_archived);

  return {
    id,
    slug,
    content_type: seed.content_type,
    language: 'en',
    title: seed.title,
    subtitle: seed.subtitle ?? null,
    summary: seed.summary,
    body: null,
    cover_image_url: seed.cover_image_url,
    cover_image_public_id: null,
    author_id: mockAuthor.id,
    primary_verse_reference: null,
    bible_version: null,
    verse_text: null,
    duration_seconds: seed.duration_seconds ?? null,
    external_url: seed.external_url ?? null,
    is_published: isPublished && !isArchived,
    is_archived: isArchived,
    published_at: isPublished ? MOCK_TS : null,
    featured_rank: seed.featured_rank,
    browse_visible: true,
    metadata: { seed: true },
    created_at: MOCK_TS,
    updated_at: MOCK_TS,
    author: mockAuthor,
    assets: buildSlides(id, seed.slides ?? []),
    sections: buildSections(id, seed.sections ?? []),
    tags: [] as ContentTag[],
    related_plans: (seed.planLinks ?? []).map((link) =>
      relatedPlan(link.templateKey, link.ctaLabel ?? null),
    ),
  };
}

/** Two mock posts per Discover format (video, article, gallery). */
export const discoverContentSeeds: DiscoverContentSeed[] = [
  {
    slug: 'sabbath-rest-explained',
    content_type: 'video',
    title: 'What Sabbath rest actually means',
    subtitle: 'A short teaching on rhythm and trust',
    summary:
      'Why weekly rest is not laziness but trust — and how Jesus reframes the Sabbath for weary hearts.',
    cover_image_url: '/plans/covers/bible.webp',
    external_url: 'https://www.youtube.com/watch?v=7Y06NGtuOXc',
    duration_seconds: 612,
    featured_rank: 1,
    sections: [
      {
        block_type: 'paragraph',
        body: 'In this session we look at Exodus 20, Mark 2, and one practical habit for protecting a weekly pause.\n\nYou can read along with the Psalms for Anxious Nights plan if you want a gentle next step.',
      },
      {
        block_type: 'heading',
        title: 'Three questions to journal',
      },
      {
        block_type: 'paragraph',
        body: 'Where am I striving beyond my limits?\n\nWhat would I stop if I believed God is enough?\n\nWho needs my presence more than my productivity this week?',
      },
      {
        block_type: 'image',
        image_url: '/messages/backgrounds/message-card-bg-honey.webp',
        image_alt_text: 'Warm abstract background',
        image_caption: 'Pause before you plan the week.',
      },
    ],
    planLinks: [{ templateKey: 'psalms_for_anxiety', ctaLabel: 'Try the Psalms plan' }],
  },
  {
    slug: 'lectio-divina-basics',
    content_type: 'video',
    title: 'Lectio Divina in ten minutes',
    subtitle: 'Read, reflect, respond, rest',
    summary:
      'A guided introduction to slow Scripture reading — video walkthrough plus a printable rhythm you can repeat daily.',
    cover_image_url: '/messages/sample-card.webp',
    external_url: 'https://www.youtube.com/watch?v=9TEvW9y0n5s',
    duration_seconds: 540,
    featured_rank: 2,
    sections: [
      {
        block_type: 'paragraph',
        body: 'We practice four movements with Psalm 23. No special tools required; just your Bible and five quiet minutes.',
      },
    ],
    planLinks: [{ templateKey: 'bible_in_a_year', ctaLabel: 'Bible in a Year' }],
  },
  {
    slug: 'psalms-for-anxious-nights',
    content_type: 'essay',
    title: 'When worry keeps you awake',
    subtitle: 'Reading Psalms at night',
    summary:
      'Night anxiety is common. These three postures — breathe, pray, receive — open space for God’s comfort without fixing everything at once.',
    cover_image_url: '/plans/covers/ot.webp',
    featured_rank: 3,
    sections: [
      {
        block_type: 'paragraph',
        body: 'The Psalms do not pretend life is easy. They give us words when ours run out.\n\nStart with one short psalm. Read it twice. Notice a phrase that catches your attention. Tell God why it matters tonight.',
      },
      {
        block_type: 'heading',
        title: 'Psalm 4 — Lie down in peace',
      },
      {
        block_type: 'paragraph',
        body: 'David ends the psalm with “You alone, O Lord, make me dwell in safety.” That is not a command to feel calm; it is an invitation to entrust the night.',
      },
      {
        block_type: 'image',
        image_url: '/messages/backgrounds/message-card-bg-space.webp',
        image_alt_text: 'Calm night sky texture',
      },
      {
        block_type: 'heading',
        title: 'A two-minute night prayer',
      },
      {
        block_type: 'paragraph',
        body: 'Lord, I bring you what I cannot solve before morning. Guard my mind while I sleep. Amen.',
      },
    ],
    planLinks: [{ templateKey: 'psalms_for_anxiety' }],
  },
  {
    slug: 'jonah-reflection',
    content_type: 'essay',
    title: 'Running from mercy',
    subtitle: 'Notes on Jonah 1–2',
    summary:
      'Jonah’s story is not only about a fish. It is about how hard it is to accept that God’s compassion might include people we would avoid.',
    cover_image_url: '/plans/covers/nt.webp',
    featured_rank: 4,
    sections: [
      {
        block_type: 'paragraph',
        body: 'Jonah flees, sleeps, and is thrown into chaos. God saves him anyway.\n\nThe plant that shades him — and withers — shows how quickly we attach to comfort instead of mission.',
      },
      {
        block_type: 'heading',
        title: 'Chapter 1 — The storm',
      },
      {
        block_type: 'paragraph',
        body: 'Sailors pray; Jonah admits fault. Sometimes confession comes only when our escape routes fail.',
      },
    ],
    planLinks: [{ templateKey: 'jonah', ctaLabel: 'Read Jonah in 4 days' }],
  },
  {
    slug: 'parable-of-sower-cartoon',
    content_type: 'cartoon',
    title: 'The sower’s four soils',
    subtitle: 'Visual walkthrough',
    summary:
      'A slide gallery of the parable in Mark 4 — swipe through each soil and one question per panel.',
    cover_image_url: '/plans/covers/bible.webp',
    featured_rank: 5,
    sections: [
      {
        block_type: 'paragraph',
        body: 'Use the arrows to move panel by panel. After the gallery, pick one soil that feels most like your season and talk to God about it.',
      },
    ],
    slides: [
      {
        url: '/plans/covers/bible.webp',
        caption: 'The sower goes out to sow.',
        alt_text: 'Sower scattering seed',
      },
      {
        url: '/plans/covers/ot.webp',
        caption: 'Path — seed snatched away.',
        alt_text: 'Hard path soil',
      },
      {
        url: '/plans/covers/nt.webp',
        caption: 'Rocky ground — quick sprout, shallow roots.',
        alt_text: 'Rocky soil',
      },
      {
        url: '/messages/backgrounds/message-card-bg-honey.webp',
        caption: 'Good soil — fruit that lasts.',
        alt_text: 'Healthy soil',
      },
    ],
    planLinks: [{ templateKey: 'gospel_of_mark' }],
  },
  {
    slug: 'david-and-goliath-slides',
    content_type: 'cartoon',
    title: 'David & Goliath — five frames',
    subtitle: 'Courage is not the absence of fear',
    summary:
      'A simple five-panel retelling for families or small groups, with discussion prompts in the captions.',
    cover_image_url: '/messages/sample-card.webp',
    featured_rank: 6,
    sections: [
      {
        block_type: 'paragraph',
        body: 'After the slides, ask: What giant are you facing? Whose armor are you tempted to wear?',
      },
    ],
    slides: [
      {
        url: '/messages/sample-card.webp',
        caption: '1. The army freezes. Goliath taunts daily.',
        alt_text: 'Army and giant',
      },
      {
        url: '/plans/covers/ot.webp',
        caption: '2. David arrives with bread for his brothers.',
        alt_text: 'David arrives',
      },
      {
        url: '/plans/covers/bible.webp',
        caption: '3. “The battle is the Lord’s.”',
        alt_text: 'David speaks',
      },
      {
        url: '/messages/backgrounds/message-card-bg-space.webp',
        caption: '4. One stone. One faithful step.',
        alt_text: 'Stone and sling',
      },
      {
        url: '/messages/backgrounds/message-card-bg-honey.webp',
        caption: '5. God saves — not our bravado alone.',
        alt_text: 'Victory',
      },
    ],
    planLinks: [{ templateKey: 'life_of_david', ctaLabel: 'Life of David plan' }],
  },
];
