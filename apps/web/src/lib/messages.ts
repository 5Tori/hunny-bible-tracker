import {
  type ContentBase,
  type ContentTag,
  type ContentWithRelations,
  getPublishedContentByIdentifier,
  getPublishedContentListRelations,
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

function normalizeSearch(value?: string | null) {
  const trimmed = value?.trim();
  return trimmed ? `%${trimmed}%` : null;
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

async function hydratePublishedMessages(contents: ContentBase[]) {
  if (contents.length === 0) return [];

  const relationsByContentId = await getPublishedContentListRelations(contents);
  return contents.map((content) => {
    const relations = relationsByContentId.get(content.id) ?? {
      author: null,
      assets: [],
      sections: [],
      tags: [],
      relatedPlans: [],
    };
    const withRelations: ContentWithRelations = {
      ...content,
      author: relations.author,
      assets: relations.assets,
      sections: relations.sections,
      tags: relations.tags,
      related_plans: relations.relatedPlans,
    };
    return mapContentToPublicMessage(withRelations);
  });
}

export async function getPublishedMessages(options?: GetPublishedMessagesOptions) {
  const language = normalizeLanguage(options?.language);
  const category = normalizeKey(options?.category);
  const situation = normalizeKey(options?.situation);
  const tag = normalizeKey(options?.tag);
  const tone = normalizeKey(options?.tone);
  const q = normalizeSearch(options?.q);
  const limit = options?.limit ?? parseContentLimit(null);

  const contents = (await sql`
    select distinct c.* from contents c
    where c.content_type = 'message'
      and c.is_published = true
      and c.is_archived = false
      and c.browse_visible = true
      and c.language = ${language}
      and (${category}::text is null or exists (
        select 1 from content_tag_links ctl
        join content_tags ct on ct.id = ctl.tag_id
        where ctl.content_id = c.id
          and ct.type = 'category'
          and ct.key = ${category}
      ))
      and (${situation}::text is null or exists (
        select 1 from content_tag_links ctl
        join content_tags ct on ct.id = ctl.tag_id
        where ctl.content_id = c.id
          and ct.type = 'situation'
          and ct.key = ${situation}
      ))
      and (${tone}::text is null or exists (
        select 1 from content_tag_links ctl
        join content_tags ct on ct.id = ctl.tag_id
        where ctl.content_id = c.id
          and ct.type = 'tone'
          and ct.key = ${tone}
      ))
      and (${tag}::text is null or exists (
        select 1 from content_tag_links ctl
        join content_tags ct on ct.id = ctl.tag_id
        where ctl.content_id = c.id
          and (
            (ct.type = 'theme' and ct.key = ${tag})
            or lower(ct.name) = ${tag}
          )
      ))
      and (${q}::text is null or (
        c.title ilike ${q}
        or coalesce(c.subtitle, '') ilike ${q}
        or coalesce(c.summary, '') ilike ${q}
        or coalesce(c.primary_verse_reference, '') ilike ${q}
        or coalesce(c.verse_text, '') ilike ${q}
        or coalesce(c.metadata->>'shortReflection', '') ilike ${q}
        or coalesce(c.metadata->>'prayerText', '') ilike ${q}
        or exists (
          select 1
          from jsonb_array_elements_text(
            case
              when jsonb_typeof(c.metadata->'searchAliases') = 'array'
              then c.metadata->'searchAliases'
              else '[]'::jsonb
            end
          ) alias(value)
          where alias.value ilike ${q}
        )
        or exists (
          select 1 from content_tag_links ctl
          join content_tags ct on ct.id = ctl.tag_id
          where ctl.content_id = c.id
            and ct.name ilike ${q}
        )
      ))
    order by c.featured_rank asc nulls last, c.published_at desc nulls last, c.updated_at desc
    limit ${limit}
  `) as ContentBase[];

  return hydratePublishedMessages(contents);
}

export async function getPublishedMessageBySlug(slug: string, language?: string | null) {
  const content = await getPublishedContentByIdentifier(slug, language);
  if (!content || content.content_type !== 'message') return null;
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
