import type { AdminContentListItem, ContentWithRelations } from '@/lib/content';
import type { AdminOverview } from '@/lib/admin/overview';
import {
  MESSAGE_PRIMARY_CATEGORIES,
  getCategoryLabel,
  resolveTagLabel,
} from '@/lib/message-taxonomy';
import { parseMessageEngagement } from '@/lib/message-engagement';
import { resolveMessageCardImages } from '@/lib/message-images';
import { parseMessageMetadata, resolveMessageDisplayContext } from '@/lib/message-metadata';
import type { GetPublishedMessagesOptions, PublicMessageCard } from '@/lib/messages';
import type { PlanTemplateBase, PlanTemplateWithRelations } from '@/lib/plans';
import type {
  PublicTodayMessage,
  TodayMessageBase,
  TodayMessageLinkedContentSummary,
} from '@/lib/today-messages';
import { mockAuthor } from '@/lib/mock/fixtures/author';
import { getMockBrowseContents } from '@/lib/mock/fixtures/contents';
import { getMockPlanByIdentifier, mockPlans, sortMockPlans } from '@/lib/mock/fixtures/plans';
import {
  getMockContentByIdentifier,
  getMockContents,
  getMockTodayMessageById,
  getMockTodayMessages,
} from '@/lib/mock/store';

function getMockMessageContents() {
  return getMockContents().filter((item) => item.content_type === 'message');
}

function normalizeKey(value?: string | null) {
  const trimmed = value?.trim().toLowerCase();
  return trimmed ? trimmed : null;
}

function normalizeSearch(value?: string | null) {
  const trimmed = value?.trim().toLowerCase();
  return trimmed ? trimmed : null;
}

function contentMatchesMessageFilters(
  content: ContentWithRelations,
  options?: GetPublishedMessagesOptions,
) {
  const language = (options?.language?.trim().toLowerCase() || 'en').slice(0, 16);
  if (content.language !== language) return false;

  const category = normalizeKey(options?.category);
  if (category && !content.tags.some((tag) => tag.type === 'category' && tag.key === category)) {
    const metadataCategory = parseMessageMetadata(content.metadata).primaryCategory;
    if (metadataCategory !== category) {
      return false;
    }
  }

  const situation = normalizeKey(options?.situation);
  if (
    situation &&
    !content.tags.some((tag) => tag.type === 'situation' && tag.key === situation)
  ) {
    return false;
  }

  const tone = normalizeKey(options?.tone);
  if (tone && !content.tags.some((tag) => tag.type === 'tone' && tag.key === tone)) {
    return false;
  }

  const tagFilter = normalizeKey(options?.tag);
  if (
    tagFilter &&
    !content.tags.some(
      (tag) =>
        (tag.type === 'theme' && tag.key === tagFilter) ||
        tag.name.toLowerCase() === tagFilter,
    )
  ) {
    return false;
  }

  const q = normalizeSearch(options?.q);
  if (q) {
    const metadata = parseMessageMetadata(content.metadata);
    const haystack = [
      content.title,
      content.primary_verse_reference ?? '',
      content.verse_text ?? '',
      metadata.context ?? '',
      metadata.hint ?? '',
      metadata.shortReflection ?? '',
      metadata.prayerText ?? '',
      ...metadata.searchAliases,
      ...content.tags.map((tag) => tag.name),
    ]
      .join(' ')
      .toLowerCase();
    if (!haystack.includes(q)) return false;
  }

  return true;
}

function mapMockContentToPublicMessage(content: ContentWithRelations): PublicMessageCard {
  const metadata = parseMessageMetadata(content.metadata);
  const grouped: Record<string, string[]> = {};
  for (const tag of content.tags) {
    grouped[tag.type] ??= [];
    grouped[tag.type]!.push(tag.key);
  }
  const primaryCategory = metadata.primaryCategory || grouped.category?.[0] || '';
  const situations = grouped.situation ?? [];
  const themeTags = grouped.theme ?? [];
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
    bibleContextTags: grouped.bible_context ?? [],
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

function linkedContentSummary(contentId: string | null): TodayMessageLinkedContentSummary | null {
  if (!contentId) return null;
  const content = getMockContents().find((item) => item.id === contentId);
  if (!content) return null;

  const messageContext =
    content.content_type === 'message' ? resolveMessageDisplayContext(content.metadata) : null;

  const base: TodayMessageLinkedContentSummary = {
    id: content.id,
    slug: content.slug,
    content_type: content.content_type,
    title: content.title,
    summary: content.content_type === 'message' ? null : content.summary,
    context: messageContext,
    cover_image_url: content.cover_image_url,
    related_plans: content.related_plans.map((plan) => ({
      id: plan.id,
      template_key: plan.template_key,
      title: plan.title,
      total_chapters: plan.total_chapters,
      estimated_minutes: plan.estimated_minutes,
      cta_label: plan.cta_label,
    })),
  };

  if (content.content_type === 'message') {
    const card = mapMockContentToPublicMessage(content);
    return {
      ...base,
      messages_url: card.messagesUrl,
      primary_category: card.primaryCategory,
      primary_category_label: card.primaryCategoryLabel,
      situations: card.situations,
      theme_tags: card.themeTags,
    };
  }

  return base;
}

function toPublicTodayMessage(message: TodayMessageBase): PublicTodayMessage {
  let hydrated = message;
  let context: string | null = null;

  if (message.content_id) {
    const content = getMockContents().find((item) => item.id === message.content_id);
    if (content) {
      const metadata = parseMessageMetadata(content.metadata);
      hydrated = {
        ...message,
        verse_reference: content.primary_verse_reference ?? message.verse_reference,
        bible_version: content.bible_version ?? message.bible_version,
        verse_text: content.verse_text ?? message.verse_text,
        image_url: content.cover_image_url ?? message.image_url,
        image_public_id: content.cover_image_public_id ?? message.image_public_id,
        hint_summary: metadata.hint ?? message.hint_summary,
      };
      context = resolveMessageDisplayContext(content.metadata);
    }
  }

  return {
    ...hydrated,
    context,
    linked_content: linkedContentSummary(hydrated.content_id),
  };
}

export function mockGetPublishedContentsForBrowse(options?: {
  sort?: 'featured' | 'new';
  type?: string | null;
  language?: string | null;
  limit?: number;
  discoverOnly?: boolean;
}) {
  return getMockBrowseContents(options, getMockContents()).map((content) => ({
    ...content,
    tags: [],
    assets: [],
    sections: [],
    related_plans: [],
  }));
}

export function mockGetPublishedContentsWithRelations(options?: {
  sort?: 'featured' | 'new';
  type?: string | null;
  language?: string | null;
  limit?: number;
}) {
  return getMockBrowseContents(options, getMockContents());
}

export function mockGetPublishedContentByIdentifier(identifier: string, language?: string | null) {
  const content = getMockContentByIdentifier(identifier);
  if (!content) return null;
  const lang = (language?.trim().toLowerCase() || 'en').slice(0, 16);
  if (content.language !== lang) return null;
  return content;
}

export function mockGetPublishedMessages(options?: GetPublishedMessagesOptions): PublicMessageCard[] {
  const limit = options?.limit ?? 48;
  return getMockMessageContents()
    .filter((content) => contentMatchesMessageFilters(content, options))
    .sort((a, b) => (a.featured_rank ?? 999) - (b.featured_rank ?? 999))
    .slice(0, limit)
    .map(mapMockContentToPublicMessage);
}

export function mockGetPublishedMessageBySlug(
  slug: string,
  language?: string | null,
): PublicMessageCard | null {
  const content = getMockContentByIdentifier(slug);
  if (!content || content.content_type !== 'message') return null;
  const lang = (language?.trim().toLowerCase() || 'en').slice(0, 16);
  if (content.language !== lang) return null;
  return mapMockContentToPublicMessage(content);
}

export function mockGetPublishedPlans(sort: 'featured' | 'new' | 'popular' = 'featured'): PlanTemplateBase[] {
  return sortMockPlans(sort);
}

export function mockGetPublishedPlansWithRelations(
  sort: 'featured' | 'new' | 'popular' = 'featured',
): PlanTemplateWithRelations[] {
  return sortMockPlans(sort);
}

export function mockGetPublishedPlanByIdentifier(identifier: string) {
  return getMockPlanByIdentifier(identifier);
}

function isTodaySlotLive(slot: TodayMessageBase) {
  if (!slot.content_id) return false;
  const content = getMockContents().find((item) => item.id === slot.content_id);
  return Boolean(content?.is_published && !content?.is_archived);
}

export function mockGetPublishedTodayMessage(options?: { date?: string; language?: string }) {
  const language = (options?.language?.trim().toLowerCase() || 'en').slice(0, 16);
  const date = options?.date?.trim() || new Date().toISOString().slice(0, 10);
  const rows = getMockTodayMessages()
    .filter(
      (item) =>
        item.language === language &&
        item.publish_date <= date &&
        isTodaySlotLive(item),
    )
    .sort((a, b) => b.publish_date.localeCompare(a.publish_date));
  const message = rows[0];
  return message ? toPublicTodayMessage(message) : null;
}

export function mockGetPublishedTodayMessageByShareSlug(slug: string, language = 'en') {
  const normalizedSlug = slug.trim();
  if (/^\d{4}-\d{2}-\d{2}$/.test(normalizedSlug)) {
    const message = getMockTodayMessages().find(
      (item) =>
        item.publish_date === normalizedSlug &&
        item.language === language &&
        isTodaySlotLive(item),
    );
    return message ? toPublicTodayMessage(message) : null;
  }

  const message = getMockTodayMessages().find((item) => item.id === normalizedSlug);
  return message && isTodaySlotLive(message) ? toPublicTodayMessage(message) : null;
}

export function mockGetAdminPlans() {
  return mockPlans.map(({ sections: _sections, tags: _tags, ...plan }) => plan);
}

export function mockGetAdminPlanById(id: string) {
  return getMockPlanByIdentifier(id);
}

export function mockGetAdminContentsList(options?: { contentType?: string }) {
  const rows = options?.contentType
    ? getMockContents().filter((item) => item.content_type === options.contentType)
    : getMockContents();

  return rows.map((item): AdminContentListItem => {
    const situations = item.tags.filter((tag) => tag.type === 'situation').map((tag) => tag.key);
    const themes = item.tags.filter((tag) => tag.type === 'theme').map((tag) => tag.key);

    return {
      id: item.id,
      slug: item.slug,
      content_type: item.content_type,
      language: item.language,
      title: item.title,
      summary: item.summary,
      primary_verse_reference: item.primary_verse_reference,
      cover_image_url: item.cover_image_url,
      is_published: item.is_published,
      is_archived: item.is_archived,
      metadata: item.metadata ?? {},
      updated_at: item.updated_at,
      related_plan_count: item.related_plans.length,
      situation_keys: situations,
      theme_keys: themes,
    };
  });
}

export function mockGetAdminContents(options?: { contentType?: string }) {
  const rows = options?.contentType
    ? getMockContents().filter((item) => item.content_type === options.contentType)
    : getMockContents();
  return rows;
}

export function mockGetAdminContentById(id: string) {
  return getMockContents().find((item) => item.id === id) ?? null;
}

export function mockGetAdminContentAuthors() {
  return [mockAuthor];
}

export function mockGetAdminTodayMessages() {
  return getMockTodayMessages();
}

export function mockGetAdminTodayMessageById(id: string) {
  return getMockTodayMessageById(id);
}

export function mockGetAdminOverview(): AdminOverview {
  const messages = getMockMessageContents();
  const todayRows = getMockTodayMessages();
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);

  const nextSevenDays = Array.from({ length: 7 }, (_, index) => {
    const date = new Date(today);
    date.setUTCDate(date.getUTCDate() + index);
    const iso = date.toISOString().slice(0, 10);
    const match = todayRows.find((row) => row.publish_date === iso);
    if (!match) return { date: iso, status: 'gap' as const };
    const linked = match.content_id
      ? getMockContents().find((item) => item.id === match.content_id)
      : null;
    const linkedVerse = linked?.primary_verse_reference ?? match.verse_reference;
    const live = linked ? linked.is_published && !linked.is_archived : false;
    return {
      date: iso,
      status: live ? ('published' as const) : ('draft' as const),
      messageId: match.id,
      verseReference: linkedVerse || match.verse_reference,
    };
  });

  const todayEntry = nextSevenDays[0] ?? null;

  return {
    messageCounts: {
      total: messages.length,
      published: messages.filter((item) => item.is_published).length,
      draft: messages.filter((item) => !item.is_published).length,
      archived: 0,
    },
    planCounts: {
      total: mockPlans.length,
      active: mockPlans.filter((item) => !item.is_archived).length,
      published: mockPlans.filter((item) => item.is_published && !item.is_archived).length,
      browseVisible: mockPlans.filter(
        (item) => item.is_published && !item.is_archived && item.browse_visible !== false,
      ).length,
      draft: mockPlans.filter((item) => !item.is_published && !item.is_archived).length,
      archived: mockPlans.filter((item) => item.is_archived).length,
    },
    todaySchedule: {
      today: todayEntry,
      nextSevenDays,
    },
    categoryCoverage: MESSAGE_PRIMARY_CATEGORIES.map((category) => ({
      key: category.key,
      label: category.label,
      publishedCount: messages.filter((item) => {
        const primary = String(item.metadata?.primaryCategory ?? '');
        return (
          primary === category.key ||
          item.tags.some((tag) => tag.type === 'category' && tag.key === category.key)
        );
      }).length,
    })),
  };
}
