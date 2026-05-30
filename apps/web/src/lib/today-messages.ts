import crypto from 'crypto';

import { buildTodayMessageShareImageUrl } from '@/lib/cloudinary-share-url';
import { sql } from '@/lib/db/postgres';

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
  summary: string | null;
  cover_image_url: string | null;
  related_plans: TodayMessageLinkedPlanSummary[];
}

export type PublicTodayMessage = TodayMessageBase & {
  linked_content: TodayMessageLinkedContentSummary | null;
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

function normalizeInput(input: AdminTodayMessageInput): NormalizedAdminTodayMessageInput {
  const publishDate = normalizeDate(input.publish_date);
  const verseReference = input.verse_reference.trim();
  const verseText = emptyToNull(input.verse_text);
  const isPublished = Boolean(input.is_published);

  if (!verseReference) {
    throw new TodayMessageValidationError('Verse reference is required.');
  }

  if (isPublished && !verseText) {
    throw new TodayMessageValidationError('Verse text is required to publish.');
  }

  return {
    publish_date: publishDate,
    language: normalizeLanguage(input.language),
    verse_reference: verseReference,
    bible_version: emptyToNull(input.bible_version)?.toUpperCase() ?? null,
    verse_text: verseText,
    image_url: emptyToNull(input.image_url),
    image_public_id: emptyToNull(input.image_public_id),
    hint_title: emptyToNull(input.hint_title),
    hint_summary: emptyToNull(input.hint_summary),
    content_id: normalizeOptionalUuid(input.content_id, 'Content'),
    is_published: isPublished,
  };
}

async function loadLinkedContentSummary(
  contentId: string | null,
): Promise<TodayMessageLinkedContentSummary | null> {
  if (!contentId) return null;

  const rows = (await sql`
    select
      c.id,
      c.slug,
      c.content_type,
      c.title,
      c.summary,
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
    group by c.id, c.slug, c.content_type, c.title, c.summary, c.cover_image_url
    limit 1
  `) as Array<{
    id: string;
    slug: string;
    content_type: string;
    title: string;
    summary: string | null;
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

  return {
    id: content.id,
    slug: content.slug,
    content_type: content.content_type,
    title: content.title,
    summary: content.summary,
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
}

export async function toPublicTodayMessage(
  message: TodayMessageBase,
  options?: { shareUrl?: string },
): Promise<PublicTodayMessage> {
  const linked_content = await loadLinkedContentSummary(message.content_id);
  return {
    ...message,
    linked_content,
    ...(options?.shareUrl ? { share_url: options.shareUrl } : {}),
  };
}

export async function getAdminTodayMessages() {
  return (await sql`
    select *
    from today_messages
    order by publish_date desc, updated_at desc
  `) as TodayMessageBase[];
}

export async function getAdminTodayMessageById(id: string) {
  const rows = (await sql`
    select *
    from today_messages
    where id::text = ${id}
    limit 1
  `) as TodayMessageBase[];
  return rows[0] ?? null;
}

export async function getPublishedTodayMessageById(id: string) {
  const rows = (await sql`
    select *
    from today_messages
    where id::text = ${id}
      and is_published = true
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
  const normalizedSlug = slug.trim();
  if (/^\d{4}-\d{2}-\d{2}$/.test(normalizedSlug)) {
    const rows = (await sql`
      select *
      from today_messages
      where publish_date = ${normalizedSlug}::date
        and language = ${normalizeLanguage(language)}
        and is_published = true
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
  const input = normalizeInput(rawInput);
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
  const input = normalizeInput(rawInput);
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
  const rows = (await sql`
    delete from today_messages
    where id::text = ${id}
    returning *
  `) as TodayMessageBase[];

  return rows[0] ?? null;
}

export async function getPublishedTodayMessage(options?: { date?: string; language?: string }) {
  const language = normalizeLanguage(options?.language);
  const rawDate = options?.date?.trim();
  const date = rawDate ? normalizeDate(rawDate) : new Date().toISOString().slice(0, 10);

  const rows = (await sql`
    select *
    from today_messages
    where is_published = true
      and language = ${language}
      and publish_date <= ${date}::date
    order by publish_date desc, updated_at desc
    limit 1
  `) as TodayMessageBase[];

  const message = rows[0];
  if (!message) return null;
  return toPublicTodayMessage(message);
}

export async function incrementTodayMessageHeart(id: string) {
  const rows = (await sql`
    update today_messages
    set heart_count = heart_count + 1,
        updated_at = now()
    where id::text = ${id}
      and is_published = true
    returning *
  `) as TodayMessageBase[];
  return rows[0] ?? null;
}

export async function incrementTodayMessageShare(id: string) {
  const rows = (await sql`
    update today_messages
    set share_count = share_count + 1,
        updated_at = now()
    where id::text = ${id}
      and is_published = true
    returning *
  `) as TodayMessageBase[];
  return rows[0] ?? null;
}
