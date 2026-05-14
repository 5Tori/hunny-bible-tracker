import crypto from 'crypto';

import { sql } from '@/lib/db/neon';

export interface TodayMessageBase {
  id: string;
  publish_date: string;
  language: string;
  verse_reference: string;
  verse_text: string | null;
  message: string | null;
  image_url: string | null;
  image_public_id: string | null;
  is_published: boolean;
  created_at: string;
  updated_at: string;
}

export interface AdminTodayMessageInput {
  publish_date: string;
  language?: string | null;
  verse_reference: string;
  verse_text?: string | null;
  message?: string | null;
  image_url?: string | null;
  image_public_id?: string | null;
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

interface NormalizedAdminTodayMessageInput extends Omit<AdminTodayMessageInput, 'language'> {
  language: string;
}

function normalizeInput(input: AdminTodayMessageInput): NormalizedAdminTodayMessageInput {
  const publishDate = normalizeDate(input.publish_date);
  const verseReference = input.verse_reference.trim();

  if (!verseReference) {
    throw new TodayMessageValidationError('Verse reference is required.');
  }

  return {
    publish_date: publishDate,
    language: normalizeLanguage(input.language),
    verse_reference: verseReference,
    verse_text: emptyToNull(input.verse_text),
    message: emptyToNull(input.message),
    image_url: emptyToNull(input.image_url),
    image_public_id: emptyToNull(input.image_public_id),
    is_published: Boolean(input.is_published),
  };
}

export async function getAdminTodayMessages() {
  return (await sql`
    select * from today_messages
    order by publish_date desc, updated_at desc
  `) as TodayMessageBase[];
}

export async function getAdminTodayMessageById(id: string) {
  const rows = (await sql`
    select * from today_messages
    where id::text = ${id}
    limit 1
  `) as TodayMessageBase[];
  return rows[0] ?? null;
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
  await assertNoDuplicatePublishSlot(input.publish_date, input.language);
  const id = crypto.randomUUID();

  const rows = (await sql`
    insert into today_messages (
      id,
      publish_date,
      language,
      verse_reference,
      verse_text,
      message,
      image_url,
      image_public_id,
      is_published,
      created_at,
      updated_at
    ) values (
      ${id},
      ${input.publish_date},
      ${input.language},
      ${input.verse_reference},
      ${input.verse_text ?? null},
      ${input.message ?? null},
      ${input.image_url ?? null},
      ${input.image_public_id ?? null},
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
  await assertNoDuplicatePublishSlot(input.publish_date, input.language, id);

  const rows = (await sql`
    update today_messages set
      publish_date = ${input.publish_date},
      language = ${input.language},
      verse_reference = ${input.verse_reference},
      verse_text = ${input.verse_text ?? null},
      message = ${input.message ?? null},
      image_url = ${input.image_url ?? null},
      image_public_id = ${input.image_public_id ?? null},
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
    select * from today_messages
    where is_published = true
      and language = ${language}
      and publish_date <= ${date}::date
    order by publish_date desc, updated_at desc
    limit 1
  `) as TodayMessageBase[];

  return rows[0] ?? null;
}
