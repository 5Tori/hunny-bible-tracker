import type {
  ContentAsset,
  ContentRelatedPlan,
  ContentSection,
  ContentTag,
  ContentWithRelations,
} from '@/lib/content';
import { mockAuthor } from '@/lib/mock/fixtures/author';
import {
  MOCK_MESSAGE_CARD_IMAGE,
  MOCK_MESSAGE_CARD_PUBLIC_ID,
} from '@/lib/mock/fixtures/assets';
import { MOCK_IDS, MOCK_TS } from '@/lib/mock/fixtures/ids';
import { getMockPlanByIdentifier } from '@/lib/mock/fixtures/plans';

export type MessageCardMetadataSeed = {
  primaryCategory: string;
  context: string;
  hint?: string;
  cardTemplateKey?: string;
  shareIntents?: string[];
  searchAliases?: string[];
  seed?: boolean;
};

export type MessageCardSeedTagSpec = {
  type: string;
  key: string;
  name: string;
  sortOrder?: number;
};

/** Mock seed for `content_type = message` cards. Title/summary are derived at build time. */
export type MessageCardSeed = {
  slug: keyof typeof MOCK_IDS.contents;
  verse: string;
  verseText: string;
  bibleVersion: string;
  featuredRank: number;
  metadata: MessageCardMetadataSeed;
  coverImageUrl?: string;
  coverImagePublicId?: string;
  /** Pre-rendered card (text baked in). Falls back to `coverImageUrl` when omitted. */
  compositeImageUrl?: string;
  compositeImagePublicId?: string;
  tags?: MessageCardSeedTagSpec[];
  planLinks?: Array<{ templateKey: keyof typeof MOCK_IDS.plans; ctaLabel?: string }>;
};

export function messageCardTag(
  type: string,
  key: string,
  name: string,
  sortOrder = 10,
): MessageCardSeedTagSpec {
  return { type, key, name, sortOrder };
}

function toContentTag(spec: MessageCardSeedTagSpec, contentId: string, index: number): ContentTag {
  return {
    id: `tag-${contentId.slice(0, 8)}-${index}`,
    type: spec.type,
    key: spec.key,
    name: spec.name,
    description: null,
    sort_order: spec.sortOrder ?? 10,
    is_active: true,
    created_at: MOCK_TS,
    updated_at: MOCK_TS,
  };
}

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

export function buildMessageContent(seed: MessageCardSeed): ContentWithRelations {
  const id = MOCK_IDS.contents[seed.slug];
  const tagSpecs = seed.tags ?? [];
  const coverImageUrl = seed.coverImageUrl ?? MOCK_MESSAGE_CARD_IMAGE;
  const coverImagePublicId = seed.coverImagePublicId ?? MOCK_MESSAGE_CARD_PUBLIC_ID;

  return {
    id,
    slug: seed.slug,
    content_type: 'message',
    language: 'en',
    title: seed.verse,
    subtitle: null,
    summary: null,
    body: null,
    cover_image_url: coverImageUrl,
    cover_image_public_id: coverImagePublicId,
    author_id: mockAuthor.id,
    primary_verse_reference: seed.verse,
    bible_version: seed.bibleVersion,
    verse_text: seed.verseText || null,
    duration_seconds: null,
    external_url: null,
    is_published: true,
    is_archived: false,
    published_at: MOCK_TS,
    featured_rank: seed.featuredRank,
    browse_visible: true,
    metadata: {
      cardTemplateKey: 'classic',
      shareIntents: ['for_self'],
      ...seed.metadata,
      ...(seed.compositeImageUrl
        ? {
            compositeImageUrl: seed.compositeImageUrl,
            compositeImagePublicId: seed.compositeImagePublicId,
          }
        : {}),
      seed: seed.metadata.seed ?? true,
    },
    created_at: MOCK_TS,
    updated_at: MOCK_TS,
    author: mockAuthor,
    assets: [] as ContentAsset[],
    sections: [] as ContentSection[],
    tags: tagSpecs.map((spec, index) => toContentTag(spec, id, index)),
    related_plans: (seed.planLinks ?? []).map((link) =>
      relatedPlan(link.templateKey, link.ctaLabel ?? null),
    ),
  };
}
