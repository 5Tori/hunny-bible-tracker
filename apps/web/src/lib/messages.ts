import {
  type ContentAuthor,
  type ContentBase,
  type ContentRelatedPlan,
  type ContentTag,
  type ContentWithRelations,
  parseContentLimit,
} from '@/lib/content';
import {
  fetchMessageDetailRpc,
  fetchMessageListRpc,
  isCatalogRpcAvailable,
} from '@/lib/catalog-rpc';
import { sql } from '@/lib/db/postgres';
import { isOfflineMode } from '@/lib/mock/mode';
import {
  mockGetPublishedMessageBySlug,
  mockGetPublishedMessages,
} from '@/lib/mock/readers';
import {
  getCategoryLabel,
  getMessageTaxonomyPayload,
  resolveTagLabel,
  type MessageTagType,
} from '@/lib/message-taxonomy';
import { parseMessageEngagement } from '@/lib/message-engagement';
import { resolveMessageCardImages } from '@/lib/message-images';
import { parseMessageMetadata, resolveMessageDisplayContext } from '@/lib/message-metadata';

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
  verseReference: string | null;
  verseText: string | null;
  translation: string | null;
  context: string | null;
  hint: string | null;
  /** @deprecated Use `context`. */
  shortReflection: string | null;
  /** @deprecated Use `hint`. */
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
  /** Base background image (live text overlay in UI). */
  coverImageUrl: string | null;
  /** Optional pre-rendered image with verse text baked in. */
  compositeImageUrl: string | null;
  /** Composite when set, otherwise `coverImageUrl`. */
  displayImageUrl: string | null;
  hasCompositeImage: boolean;
  heartCount: number;
  shareCount: number;
  saveCount: number;
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
  const context = resolveMessageDisplayContext(content.metadata);
  const hint = metadata.hint ?? metadata.prayerText ?? null;
  const engagement = parseMessageEngagement(content.metadata);
  const images = resolveMessageCardImages({
    coverImageUrl: content.cover_image_url,
    compositeImageUrl: metadata.compositeImageUrl,
  });

  return {
    id: content.id,
    slug: content.slug,
    title: content.title,
    subtitle: content.subtitle,
    verseReference: content.primary_verse_reference,
    verseText: content.verse_text,
    translation: content.bible_version,
    context,
    hint,
    shortReflection: context,
    prayerText: hint,
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
    shareImageUrl: images.displayImageUrl ?? content.cover_image_url,
    coverImageUrl: images.coverImageUrl,
    compositeImageUrl: images.compositeImageUrl,
    displayImageUrl: images.displayImageUrl,
    hasCompositeImage: images.hasCompositeImage,
    heartCount: engagement.heartCount,
    shareCount: engagement.shareCount,
    saveCount: engagement.saveCount,
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
  if (isOfflineMode()) {
    return mockGetPublishedMessages(options);
  }

  const payload = isCatalogRpcAvailable()
    ? await fetchMessageListRpc({
        language: options?.language,
        category: options?.category,
        situation: options?.situation,
        tag: options?.tag,
        tone: options?.tone,
        q: options?.q,
        limit: options?.limit ?? parseContentLimit(null),
      })
    : ((
        await sql`
          select mobile_message_list(
            ${normalizeLanguage(options?.language)}::text,
            ${normalizeKey(options?.category)}::text,
            ${normalizeKey(options?.situation)}::text,
            ${normalizeKey(options?.tag)}::text,
            ${normalizeKey(options?.tone)}::text,
            ${options?.q?.trim() || null}::text,
            ${options?.limit ?? parseContentLimit(null)}::int
          ) as payload
        `
      ) as Array<{ payload: unknown }>)[0]?.payload;

  if (!Array.isArray(payload)) {
    return [];
  }

  return payload
    .map((row) => parseRpcMessageContent(row))
    .filter((content): content is ContentWithRelations => content != null)
    .map(mapContentToPublicMessage);
}

export async function getPublishedMessageBySlug(slug: string, language?: string | null) {
  if (isOfflineMode()) {
    return mockGetPublishedMessageBySlug(slug, language);
  }

  const rpcPayload = isCatalogRpcAvailable()
    ? await fetchMessageDetailRpc(slug, language)
    : ((
        await sql`
          select mobile_message_detail(
            ${slug.trim()}::text,
            ${normalizeLanguage(language)}::text
          ) as payload
        `
      ) as Array<{ payload: unknown }>)[0]?.payload;

  const content = parseRpcMessageContent(rpcPayload);
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
