import {
  type ContentAuthor,
  type ContentBase,
  type ContentRelatedPlan,
  type ContentTag,
  type ContentWithRelations,
  parseContentLimit,
} from '@/lib/content';
import { sql } from '@/lib/db/postgres';
import {
  getCategoryLabel,
  getMessageTaxonomyPayload,
  resolveTagLabel,
  type MessageTagType,
} from '@/lib/message-taxonomy';
import { parseMessageMetadata } from '@/lib/message-metadata';

export interface PublicMessageRelatedPlan {
  id: string;
  templateKey: string;
  title: string;
  totalChapters: number | null;
  estimatedMinutes: number | null;
  ctaLabel: string | null;
}

export interface PublicMessageCard {
  id: string;
  slug: string;
  title: string;
  subtitle: string | null;
  summary: string | null;
  verseReference: string | null;
  verseText: string | null;
  translation: string | null;
  shortReflection: string | null;
  prayerText: string | null;
  primaryCategory: string;
  primaryCategoryLabel: string;
  situations: string[];
  situationLabels: string[];
  themeTags: string[];
  themeTagLabels: string[];
  bibleContextTags: string[];
  tone: string | null;
  toneLabel: string | null;
  shareIntents: string[];
  cardTemplateKey: string;
  shareImageUrl: string | null;
  coverImageUrl: string | null;
  isTodayEligible: boolean;
  relatedPlans: PublicMessageRelatedPlan[];
  messagesUrl: string;
}

export interface GetPublishedMessagesOptions {
  category?: string | null;
  situation?: string | null;
  tag?: string | null;
  tone?: string | null;
  q?: string | null;
  language?: string | null;
  limit?: number;
}

function normalizeLanguage(value?: string | null) {
  return (value?.trim().toLowerCase() || 'en').slice(0, 16);
}

function normalizeKey(value?: string | null) {
  const trimmed = value?.trim().toLowerCase();
  return trimmed ? trimmed : null;
}

function tagsByType(tags: ContentTag[]) {
  const grouped: Partial<Record<MessageTagType, string[]>> = {};
  for (const tag of tags) {
    const type = tag.type as MessageTagType;
    grouped[type] ??= [];
    grouped[type]!.push(tag.key);
  }
  return grouped;
}

function parseRpcMessageContent(value: unknown): ContentWithRelations | null {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return null;
  }

  const row = value as Record<string, unknown>;
  if (typeof row.id !== 'string' || typeof row.slug !== 'string') {
    return null;
  }

  const content = row as unknown as ContentBase;

  return {
    ...content,
    metadata: (content.metadata ?? {}) as Record<string, unknown>,
    author: (row.author as ContentAuthor | null) ?? null,
    assets: [],
    sections: [],
    tags: Array.isArray(row.tags) ? (row.tags as ContentTag[]) : [],
    related_plans: Array.isArray(row.related_plans)
      ? (row.related_plans as ContentRelatedPlan[])
      : [],
  };
}

export function mapContentToPublicMessage(content: ContentWithRelations): PublicMessageCard {
  const metadata = parseMessageMetadata(content.metadata);
  const grouped = tagsByType(content.tags);
  const primaryCategory = metadata.primaryCategory || grouped.category?.[0] || '';
  const situations = grouped.situation ?? [];
  const themeTags = grouped.theme ?? [];
  const bibleContextTags = grouped.bible_context ?? [];
  const tone = grouped.tone?.[0] ?? null;

  return {
    id: content.id,
    slug: content.slug,
    title: content.title,
    subtitle: content.subtitle,
    summary: content.summary,
    verseReference: content.primary_verse_reference,
    verseText: content.verse_text,
    translation: content.bible_version,
    shortReflection: metadata.shortReflection ?? content.summary,
    prayerText: metadata.prayerText ?? null,
    primaryCategory,
    primaryCategoryLabel: getCategoryLabel(primaryCategory),
    situations,
    situationLabels: situations.map((key) => resolveTagLabel('situation', key)),
    themeTags,
    themeTagLabels: themeTags.map((key) => resolveTagLabel('theme', key)),
    bibleContextTags,
    tone,
    toneLabel: tone ? resolveTagLabel('tone', tone) : null,
    shareIntents: metadata.shareIntents,
    cardTemplateKey: metadata.cardTemplateKey,
    shareImageUrl: content.cover_image_url,
    coverImageUrl: content.cover_image_url,
    isTodayEligible: metadata.isTodayEligible,
    relatedPlans: content.related_plans.map((plan) => ({
      id: plan.id,
      templateKey: plan.template_key,
      title: plan.title,
      totalChapters: plan.total_chapters,
      estimatedMinutes: plan.estimated_minutes,
      ctaLabel: plan.cta_label,
    })),
    messagesUrl: `/messages/${content.slug}`,
  };
}

export async function getPublishedMessages(options?: GetPublishedMessagesOptions) {
  const rows = (await sql`
    select mobile_message_list(
      ${normalizeLanguage(options?.language)}::text,
      ${normalizeKey(options?.category)}::text,
      ${normalizeKey(options?.situation)}::text,
      ${normalizeKey(options?.tag)}::text,
      ${normalizeKey(options?.tone)}::text,
      ${options?.q?.trim() || null}::text,
      ${options?.limit ?? parseContentLimit(null)}::int
    ) as payload
  `) as Array<{ payload: unknown }>;

  const payload = rows[0]?.payload;
  if (!Array.isArray(payload)) {
    return [];
  }

  return payload
    .map((row) => parseRpcMessageContent(row))
    .filter((content): content is ContentWithRelations => content != null)
    .map(mapContentToPublicMessage);
}

export async function getPublishedMessageBySlug(slug: string, language?: string | null) {
  const rows = (await sql`
    select mobile_message_detail(
      ${slug.trim()}::text,
      ${normalizeLanguage(language)}::text
    ) as payload
  `) as Array<{ payload: unknown }>;

  const content = parseRpcMessageContent(rows[0]?.payload);
  if (!content || content.content_type !== 'message') {
    return null;
  }

  return mapContentToPublicMessage(content);
}

export async function getPublishedMessagesByCategory(
  category: string,
  options?: Omit<GetPublishedMessagesOptions, 'category'>,
) {
  return getPublishedMessages({ ...options, category });
}

export function getMessageTaxonomy() {
  return getMessageTaxonomyPayload();
}

export { parseContentLimit as parseMessageLimit };
