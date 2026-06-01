import crypto from 'crypto';

import { buildTodayMessageShareImageUrl } from '@/lib/cloudinary-share-url';
import { sql } from '@/lib/db/postgres';
import { getPublishedMessageBySlug } from '@/lib/messages';
import { parseMessageMetadata, resolveMessageDisplayContext } from '@/lib/message-metadata';
import { assertOnlineForWrites, isOfflineMode } from '@/lib/mock/mode';
import {
  mockGetAdminTodayMessageById,
  mockGetAdminTodayMessages,
  mockGetPublishedTodayMessage,
  mockGetPublishedTodayMessageByShareSlug,
} from '@/lib/mock/readers';
import { getSupabaseAdmin } from '@/lib/supabase/admin';

export interface TodayMessageBase {
  id: string;
  content_id: string | null;
  publish_date: string;
  language: string;
  verse_reference: string;
  bible_version: string | null;
  verse_text: string | null;
  image_url: string | null;
  image_public_id: string | null;
  share_image_url: string | null;
  share_image_public_id: string | null;
  hint_title: string | null;
  hint_summary: string | null;
  is_published: boolean;
  heart_count: number;
  share_count: number;
  created_at: string;
  updated_at: string;
}

export interface TodayMessageLinkedPlanSummary {
  id: string;
  template_key: string;
  title: string;
  total_chapters: number | null;
  estimated_minutes: number | null;
  cta_label: string | null;
}

export interface TodayMessageLinkedContentSummary {
  id: string;
  slug: string;
  content_type: string;
  title: string;
  /** Discover content only — message cards use `context`. */
  summary: string | null;
  /** Message card reflection copy from metadata.context. */
  context?: string | null;
  cover_image_url: string | null;
  related_plans: TodayMessageLinkedPlanSummary[];
  messages_url?: string | null;
  primary_category?: string | null;
  primary_category_label?: string | null;
  situations?: string[];
  theme_tags?: string[];
}

export type PublicTodayMessage = TodayMessageBase & {
  linked_content: TodayMessageLinkedContentSummary | null;
  context?: string | null;
  share_url?: string;
};

export interface AdminTodayMessageInput {
  content_id?: string | null;
  publish_date: string;
  language?: string | null;
  verse_reference: string;
  bible_version?: string | null;
  verse_text?: string | null;
  image_url?: string | null;
  image_public_id?: string | null;
  hint_title?: string | null;
  hint_summary?: string | null;
  is_published?: boolean;
}

export class TodayMessageValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'TodayMessageValidationError';
  }
}

function emptyToNull(value?: string | null) {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

function normalizeLanguage(value?: string | null) {
  return (value?.trim().toLowerCase() || 'en').slice(0, 16);
}

function normalizeDate(value: string) {
  const trimmed = value.trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(trimmed)) {
    throw new TodayMessageValidationError('Publish date must use YYYY-MM-DD format.');
  }
  return trimmed;
}

function normalizeOptionalUuid(value?: string | null, label = 'Value') {
  const trimmed = value?.trim();
  if (!trimmed) return null;
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(trimmed)) {
    throw new TodayMessageValidationError(`${label} must be a valid UUID.`);
  }
  return trimmed;
}

interface NormalizedAdminTodayMessageInput extends Omit<AdminTodayMessageInput, 'language'> {
  language: string;
}

function buildShareImageFields(input: NormalizedAdminTodayMessageInput) {
  const shareImageUrl = buildTodayMessageShareImageUrl({
    imagePublicId: input.image_public_id ?? null,
    verseText: input.verse_text ?? null,
    verseReference: input.verse_reference,
    bibleVersion: input.bible_version ?? null,
  });

  return {
    share_image_url: shareImageUrl,
    share_image_public_id: shareImageUrl ? input.image_public_id ?? null : null,
  };
}

async function resolveTodayMessageFieldsFromContent(contentId: string) {
  if (isOfflineMode()) {
    const { getMockContentById } = await import('@/lib/mock/store');
    const content = getMockContentById(contentId);
    if (!content) {
      throw new TodayMessageValidationError('Selected message card was not found.');
    }
    if (content.content_type !== 'message') {
      throw new TodayMessageValidationError('Today slots must link to a message card.');
    }
    const metadata = parseMessageMetadata(content.metadata);
    return {
      verse_reference: content.primary_verse_reference ?? '',
      bible_version: content.bible_version,
      verse_text: content.verse_text,
      image_url: content.cover_image_url,
      image_public_id: content.cover_image_public_id,
      hint_summary: metadata.hint ?? null,
      context: resolveMessageDisplayContext(content.metadata),
      is_published: content.is_published,
    };
  }

  const rows = (await sql`
    select
      content_type,
      is_published,
      primary_verse_reference,
      bible_version,
      verse_text,
      cover_image_url,
      cover_image_public_id,
      metadata
    from contents
    where id::text = ${contentId}
      and is_archived = false
    limit 1
  `) as Array<{
    content_type: string;
    is_published: boolean;
    primary_verse_reference: string | null;
    bible_version: string | null;
    verse_text: string | null;
    cover_image_url: string | null;
    cover_image_public_id: string | null;
    metadata: Record<string, unknown> | null;
  }>;

  const content = rows[0];
  if (!content) {
    throw new TodayMessageValidationError('Selected message card was not found.');
  }
  if (content.content_type !== 'message') {
    throw new TodayMessageValidationError('Today slots must link to a message card.');
  }

  const metadata = parseMessageMetadata(content.metadata);
  return {
    verse_reference: content.primary_verse_reference ?? '',
    bible_version: content.bible_version,
    verse_text: content.verse_text,
    image_url: content.cover_image_url,
    image_public_id: content.cover_image_public_id,
    hint_summary: metadata.hint ?? null,
    context: resolveMessageDisplayContext(content.metadata),
    is_published: content.is_published,
  };
}

async function normalizeInput(input: AdminTodayMessageInput): Promise<NormalizedAdminTodayMessageInput> {
  const publishDate = normalizeDate(input.publish_date);
  const contentId = normalizeOptionalUuid(input.content_id, 'Content');

  if (!contentId) {
    throw new TodayMessageValidationError('Select a message card for today.');
  }

  const fields = await resolveTodayMessageFieldsFromContent(contentId);

  if (fields.is_published && !fields.verse_text) {
    throw new TodayMessageValidationError('Linked message must include verse text to publish.');
  }

  return {
    publish_date: publishDate,
    language: normalizeLanguage(input.language),
    content_id: contentId,
    verse_reference: fields.verse_reference,
    bible_version: fields.bible_version,
    verse_text: fields.verse_text,
    image_url: fields.image_url,
    image_public_id: fields.image_public_id,
    hint_title: null,
    hint_summary: fields.hint_summary,
    is_published: fields.is_published,
  };
}

async function loadLinkedContentSummary(
  contentId: string | null,
): Promise<TodayMessageLinkedContentSummary | null> {
  if (!contentId) return null;

  if (isOfflineMode()) {
    const { getMockContentById } = await import('@/lib/mock/store');
    const content = getMockContentById(contentId);
    if (!content || !content.is_published || content.is_archived) return null;

    const messageContext = resolveMessageDisplayContext(content.metadata);

    const baseSummary: TodayMessageLinkedContentSummary = {
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
      const messageCard = await getPublishedMessageBySlug(content.slug, 'en');
      if (messageCard) {
        return {
          ...baseSummary,
          messages_url: messageCard.messagesUrl,
          primary_category: messageCard.primaryCategory,
          primary_category_label: messageCard.primaryCategoryLabel,
          situations: messageCard.situations,
          theme_tags: messageCard.themeTags,
        };
      }
    }

    return baseSummary;
  }

  const rows = (await sql`
    select
      c.id,
      c.slug,
      c.content_type,
      c.title,
      c.summary,
      c.metadata,
      c.cover_image_url,
      coalesce(
        json_agg(
          json_build_object(
            'id', pt.id,
            'template_key', pt.template_key,
            'title', pt.title,
            'total_chapters', pt.total_chapters,
            'estimated_minutes', pt.estimated_minutes,
            'cta_label', cpl.cta_label
          )
          order by cpl.display_order asc, pt.featured_rank asc nulls last, pt.updated_at desc
        ) filter (where pt.id is not null),
        '[]'::json
      ) as related_plans
    from contents c
    left join content_plan_links cpl on cpl.content_id = c.id
    left join plan_templates pt on pt.id = cpl.plan_template_id
      and pt.is_published = true
      and pt.is_archived = false
    where c.id = ${contentId}
      and c.is_published = true
      and c.is_archived = false
    group by c.id, c.slug, c.content_type, c.title, c.summary, c.metadata, c.cover_image_url
    limit 1
  `) as Array<{
    id: string;
    slug: string;
    content_type: string;
    title: string;
    summary: string | null;
    metadata: Record<string, unknown> | null;
    cover_image_url: string | null;
    related_plans: Array<{
      id: string;
      template_key: string;
      title: string;
      total_chapters: number | null;
      estimated_minutes: number | null;
      cta_label: string | null;
    }>;
  }>;

  const content = rows[0];
  if (!content) return null;

  const messageContext =
    content.content_type === 'message'
      ? resolveMessageDisplayContext(content.metadata)
      : null;

  const baseSummary: TodayMessageLinkedContentSummary = {
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
    const messageCard = await getPublishedMessageBySlug(content.slug, 'en');
    if (messageCard) {
      return {
        ...baseSummary,
        messages_url: messageCard.messagesUrl,
        primary_category: messageCard.primaryCategory,
        primary_category_label: messageCard.primaryCategoryLabel,
        situations: messageCard.situations,
        theme_tags: messageCard.themeTags,
      };
    }
  }

  return baseSummary;
}

export async function toPublicTodayMessage(
  message: TodayMessageBase,
  options?: { shareUrl?: string },
): Promise<PublicTodayMessage> {
  let hydrated = message;
  let context: string | null = null;

  if (message.content_id) {
    const fields = await resolveTodayMessageFieldsFromContent(message.content_id);
    hydrated = {
      ...message,
      verse_reference: fields.verse_reference || message.verse_reference,
      bible_version: fields.bible_version ?? message.bible_version,
      verse_text: fields.verse_text ?? message.verse_text,
      image_url: fields.image_url ?? message.image_url,
      image_public_id: fields.image_public_id ?? message.image_public_id,
      hint_summary: fields.hint_summary ?? message.hint_summary,
    };
    context = fields.context;
  }

  const linked_content = await loadLinkedContentSummary(hydrated.content_id);
  return {
    ...hydrated,
    context,
    linked_content,
    ...(options?.shareUrl ? { share_url: options.shareUrl } : {}),
  };
}

export async function getAdminTodayMessages() {
  if (isOfflineMode()) {
    return mockGetAdminTodayMessages();
  }

  return (await sql`
    select *
    from today_messages
    order by publish_date desc, updated_at desc
  `) as TodayMessageBase[];
}

export async function getAdminTodayMessageById(id: string) {
  if (isOfflineMode()) {
    return mockGetAdminTodayMessageById(id);
  }

  const rows = (await sql`
    select *
    from today_messages
    where id::text = ${id}
    limit 1
  `) as TodayMessageBase[];
  return rows[0] ?? null;
}

export async function getPublishedTodayMessageById(id: string) {
  if (isOfflineMode()) {
    const message = mockGetAdminTodayMessageById(id);
    if (!message?.is_published) return null;
    return toPublicTodayMessage(message);
  }

  const rows = (await sql`
    select tm.*
    from today_messages tm
    join contents c on c.id = tm.content_id
    where tm.id::text = ${id}
      and c.is_published = true
      and c.is_archived = false
    limit 1
  `) as TodayMessageBase[];
  const message = rows[0];
  if (!message) return null;
  return toPublicTodayMessage(message);
}

export async function getPublishedTodayMessageByShareSlug(
  slug: string,
  language = 'en',
) {
  if (isOfflineMode()) {
    return mockGetPublishedTodayMessageByShareSlug(slug, language);
  }

  const normalizedSlug = slug.trim();
  if (/^\d{4}-\d{2}-\d{2}$/.test(normalizedSlug)) {
    const rows = (await sql`
      select tm.*
      from today_messages tm
      join contents c on c.id = tm.content_id
      where tm.publish_date = ${normalizedSlug}::date
        and tm.language = ${normalizeLanguage(language)}
        and c.is_published = true
        and c.is_archived = false
      limit 1
    `) as TodayMessageBase[];
    const message = rows[0];
    if (!message) return null;
    return toPublicTodayMessage(message);
  }

  return getPublishedTodayMessageById(normalizedSlug);
}

async function assertNoDuplicatePublishSlot(
  publishDate: string,
  language: string,
  excludeId?: string,
) {
  const dup = excludeId
    ? ((await sql`
        select id from today_messages
        where publish_date = ${publishDate}::date
          and language = ${language}
          and id::text <> ${excludeId}
        limit 1
      `) as Array<{ id: string }>)
    : ((await sql`
        select id from today_messages
        where publish_date = ${publishDate}::date and language = ${language}
        limit 1
      `) as Array<{ id: string }>);
  if (dup[0]) {
    throw new TodayMessageValidationError(
      'A message already exists for this publish date and language. Choose another date or language.',
    );
  }
}

export async function createAdminTodayMessage(rawInput: AdminTodayMessageInput) {
  const input = await normalizeInput(rawInput);
  if (isOfflineMode()) {
    const { mockCreateTodayMessage } = await import('@/lib/mock/store');
    return mockCreateTodayMessage(rawInput);
  }
  assertOnlineForWrites();
  const shareImage = buildShareImageFields(input);
  await assertNoDuplicatePublishSlot(input.publish_date, input.language);
  const id = crypto.randomUUID();

  const rows = (await sql`
    insert into today_messages (
      id,
      content_id,
      publish_date,
      language,
      verse_reference,
      bible_version,
      verse_text,
      image_url,
      image_public_id,
      share_image_url,
      share_image_public_id,
      hint_title,
      hint_summary,
      is_published,
      created_at,
      updated_at
    ) values (
      ${id},
      ${input.content_id ?? null},
      ${input.publish_date},
      ${input.language},
      ${input.verse_reference},
      ${input.bible_version ?? null},
      ${input.verse_text ?? null},
      ${input.image_url ?? null},
      ${input.image_public_id ?? null},
      ${shareImage.share_image_url},
      ${shareImage.share_image_public_id},
      ${input.hint_title ?? null},
      ${input.hint_summary ?? null},
      ${Boolean(input.is_published)},
      now(),
      now()
    )
    returning *
  `) as TodayMessageBase[];

  return rows[0] ?? null;
}

export async function updateAdminTodayMessage(id: string, rawInput: AdminTodayMessageInput) {
  const input = await normalizeInput(rawInput);
  if (isOfflineMode()) {
    const { mockUpdateTodayMessage } = await import('@/lib/mock/store');
    return mockUpdateTodayMessage(id, rawInput);
  }
  assertOnlineForWrites();
  const shareImage = buildShareImageFields(input);
  await assertNoDuplicatePublishSlot(input.publish_date, input.language, id);

  const rows = (await sql`
    update today_messages set
      content_id = ${input.content_id ?? null},
      publish_date = ${input.publish_date},
      language = ${input.language},
      verse_reference = ${input.verse_reference},
      bible_version = ${input.bible_version ?? null},
      verse_text = ${input.verse_text ?? null},
      image_url = ${input.image_url ?? null},
      image_public_id = ${input.image_public_id ?? null},
      share_image_url = ${shareImage.share_image_url},
      share_image_public_id = ${shareImage.share_image_public_id},
      hint_title = ${input.hint_title ?? null},
      hint_summary = ${input.hint_summary ?? null},
      is_published = ${Boolean(input.is_published)},
      updated_at = now()
    where id::text = ${id}
    returning *
  `) as TodayMessageBase[];

  return rows[0] ?? null;
}

export async function deleteAdminTodayMessage(id: string) {
  if (isOfflineMode()) {
    const { mockDeleteTodayMessage } = await import('@/lib/mock/store');
    return mockDeleteTodayMessage(id);
  }
  assertOnlineForWrites();
  const rows = (await sql`
    delete from today_messages
    where id::text = ${id}
    returning *
  `) as TodayMessageBase[];

  return rows[0] ?? null;
}

export async function getPublishedTodayMessage(options?: { date?: string; language?: string }) {
  if (isOfflineMode()) {
    return mockGetPublishedTodayMessage(options);
  }

  const language = normalizeLanguage(options?.language);
  const rawDate = options?.date?.trim();
  const date = rawDate ? normalizeDate(rawDate) : new Date().toISOString().slice(0, 10);

  const rows = (await sql`
    select tm.*
    from today_messages tm
    join contents c on c.id = tm.content_id
    where c.is_published = true
      and c.is_archived = false
      and tm.language = ${language}
      and tm.publish_date <= ${date}::date
    order by tm.publish_date desc, tm.updated_at desc
    limit 1
  `) as TodayMessageBase[];

  const message = rows[0];
  if (!message) return null;
  return toPublicTodayMessage(message);
}

export async function incrementTodayMessageHeart(id: string) {
  return incrementTodayMessageEngagement(id, 'heart_count');
}

export async function incrementTodayMessageShare(id: string) {
  return incrementTodayMessageEngagement(id, 'share_count');
}

async function incrementTodayMessageEngagement(
  id: string,
  counter: 'heart_count' | 'share_count',
) {
  const admin = getSupabaseAdmin();
  const { data: existing, error: readError } = await admin
    .from('today_messages')
    .select('*')
    .eq('id', id)
    .eq('is_published', true)
    .maybeSingle();

  if (readError) {
    console.error(`Today message ${counter} read failed`, readError);
    throw readError;
  }
  if (!existing) return null;

  const currentCount =
    typeof existing[counter] === 'number' ? existing[counter] : 0;
  const { data: updated, error: writeError } = await admin
    .from('today_messages')
    .update({
      [counter]: currentCount + 1,
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
    .select('*')
    .single();

  if (writeError) {
    console.error(`Today message ${counter} write failed`, writeError);
    throw writeError;
  }

  return updated as TodayMessageBase;
}
