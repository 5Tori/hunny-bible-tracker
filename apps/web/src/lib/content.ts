import crypto from 'crypto';

import { sql } from '@/lib/db/neon';

type SqlLike = typeof sql;

export interface ContentAuthor {
  id: string;
  slug: string;
  display_name: string;
  bio: string | null;
  avatar_image_url: string | null;
  avatar_image_public_id: string | null;
  website_url: string | null;
  is_verified: boolean;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ContentBase {
  id: string;
  slug: string;
  content_type: string;
  language: string;
  title: string;
  subtitle: string | null;
  summary: string | null;
  body: string | null;
  cover_image_url: string | null;
  cover_image_public_id: string | null;
  author_id: string | null;
  primary_verse_reference: string | null;
  bible_version: string | null;
  verse_text: string | null;
  duration_seconds: number | null;
  external_url: string | null;
  is_published: boolean;
  is_archived: boolean;
  published_at: string | null;
  featured_rank: number | null;
  browse_visible: boolean;
  metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}

export interface ContentAsset {
  id: string;
  content_id: string;
  asset_type: string;
  asset_role: string;
  order_index: number;
  title: string | null;
  caption: string | null;
  alt_text: string | null;
  url: string;
  public_id: string | null;
  provider: string | null;
  mime_type: string | null;
  width: number | null;
  height: number | null;
  duration_seconds: number | null;
  metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}

export interface ContentSection {
  id: string;
  content_id: string;
  order_index: number;
  title: string | null;
  body: string | null;
  image_url: string | null;
  image_public_id: string | null;
  image_alt_text: string | null;
  image_caption: string | null;
  metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}

export interface ContentTag {
  id: string;
  type: string;
  key: string;
  name: string;
  description: string | null;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ContentRelatedPlan {
  relationship_type: string;
  display_order: number;
  cta_label: string | null;
  id: string;
  template_key: string;
  title: string;
  subtitle: string | null;
  cover_image_url: string | null;
  total_chapters: number | null;
  estimated_minutes: number | null;
}

export interface ContentWithRelations extends ContentBase {
  author: ContentAuthor | null;
  assets: ContentAsset[];
  sections: ContentSection[];
  tags: ContentTag[];
  related_plans: ContentRelatedPlan[];
}

export type PublishedContentSortMode = 'featured' | 'new';

export interface AdminContentInput {
  slug?: string | null;
  content_type: string;
  language?: string | null;
  title: string;
  subtitle?: string | null;
  summary?: string | null;
  body?: string | null;
  cover_image_url?: string | null;
  cover_image_public_id?: string | null;
  author_id?: string | null;
  author_display_name?: string | null;
  primary_verse_reference?: string | null;
  bible_version?: string | null;
  verse_text?: string | null;
  duration_seconds?: number | string | null;
  external_url?: string | null;
  is_published?: boolean;
  is_archived?: boolean;
  published_at?: string | null;
  featured_rank?: number | string | null;
  browse_visible?: boolean;
  metadata?: Record<string, unknown> | string | null;
  assets?: Array<{
    asset_type?: string | null;
    asset_role?: string | null;
    order_index?: number | string | null;
    title?: string | null;
    caption?: string | null;
    alt_text?: string | null;
    url: string;
    public_id?: string | null;
    provider?: string | null;
    mime_type?: string | null;
    width?: number | string | null;
    height?: number | string | null;
    duration_seconds?: number | string | null;
    metadata?: Record<string, unknown> | string | null;
  }>;
  sections?: Array<{
    order_index?: number | string | null;
    title?: string | null;
    body?: string | null;
    image_url?: string | null;
    image_public_id?: string | null;
    image_alt_text?: string | null;
    image_caption?: string | null;
    metadata?: Record<string, unknown> | string | null;
  }>;
  tags?: Array<{
    type?: string | null;
    key?: string | null;
    name: string;
    description?: string | null;
    sort_order?: number | string | null;
  }>;
  related_plan_ids?: string[];
  related_plans?: Array<{
    plan_template_id: string;
    relationship_type?: string | null;
    display_order?: number | string | null;
    cta_label?: string | null;
  }>;
}

export class ContentValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ContentValidationError';
  }
}

export function parsePublishedContentSort(value: string | null | undefined): PublishedContentSortMode {
  if (value === 'new') return 'new';
  return 'featured';
}

export function parseContentLimit(value: string | null | undefined) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) return 20;
  return Math.min(Math.max(Math.floor(parsed), 1), 50);
}

function emptyToNull(value?: string | null) {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

function slugify(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function normalizeLanguage(value?: string | null) {
  return (value?.trim().toLowerCase() || 'en').slice(0, 16);
}

function normalizeContentType(value?: string | null) {
  const type = emptyToNull(value)?.toLowerCase();
  if (type === 'message' || type === 'video' || type === 'essay' || type === 'cartoon') return type;
  return null;
}

function normalizeNullableNumber(value?: number | string | null) {
  if (value === undefined || value === null || value === '') return null;
  const parsed = typeof value === 'string' ? Number(value) : value;
  if (!Number.isFinite(parsed)) return null;
  return Math.floor(parsed);
}

function normalizeJsonObject(value?: Record<string, unknown> | string | null) {
  if (!value) return {};
  if (typeof value !== 'string') return value;
  const trimmed = value.trim();
  if (!trimmed) return {};
  try {
    const parsed = JSON.parse(trimmed);
    if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
      return parsed as Record<string, unknown>;
    }
  } catch {
    throw new ContentValidationError('Metadata must be a valid JSON object.');
  }
  throw new ContentValidationError('Metadata must be a valid JSON object.');
}

function normalizePublishedAt(value?: string | null) {
  const raw = emptyToNull(value);
  if (!raw) return null;
  const date = new Date(raw);
  if (Number.isNaN(date.getTime())) {
    throw new ContentValidationError('Published date must be a valid date.');
  }
  return date.toISOString();
}

function normalizeInput(input: AdminContentInput) {
  const title = input.title?.trim();
  if (!title) throw new ContentValidationError('Title is required.');

  const contentType = normalizeContentType(input.content_type);
  if (!contentType) {
    throw new ContentValidationError('Choose a valid content type.');
  }

  const slug = slugify(input.slug || title);
  if (!slug) throw new ContentValidationError('Slug is required.');

  const isArchived = Boolean(input.is_archived);
  const isPublished = Boolean(input.is_published) && !isArchived;
  const publishedAt = isPublished
    ? normalizePublishedAt(input.published_at) ?? new Date().toISOString()
    : normalizePublishedAt(input.published_at);

  const tags = (input.tags ?? [])
    .map((tag) => {
      const name = tag.name.trim();
      const type = slugify(tag.type || 'topic') || 'topic';
      const key = slugify(tag.key || name);
      if (!name || !key) return null;
      return {
        type,
        key,
        name,
        description: emptyToNull(tag.description),
        sort_order: normalizeNullableNumber(tag.sort_order) ?? 0,
      };
    })
    .filter((tag): tag is NonNullable<typeof tag> => Boolean(tag));

  const assets = (input.assets ?? [])
    .map((asset, index) => {
      const url = emptyToNull(asset.url);
      if (!url) return null;
      return {
        asset_type: emptyToNull(asset.asset_type) ?? 'image',
        asset_role: emptyToNull(asset.asset_role) ?? 'body',
        order_index: normalizeNullableNumber(asset.order_index) ?? index,
        title: emptyToNull(asset.title),
        caption: emptyToNull(asset.caption),
        alt_text: emptyToNull(asset.alt_text),
        url,
        public_id: emptyToNull(asset.public_id),
        provider: emptyToNull(asset.provider),
        mime_type: emptyToNull(asset.mime_type),
        width: normalizeNullableNumber(asset.width),
        height: normalizeNullableNumber(asset.height),
        duration_seconds: normalizeNullableNumber(asset.duration_seconds),
        metadata: normalizeJsonObject(asset.metadata),
      };
    })
    .filter((asset): asset is NonNullable<typeof asset> => Boolean(asset));

  const sections = (input.sections ?? [])
    .map((section, index) => {
      const body = emptyToNull(section.body);
      const title = emptyToNull(section.title);
      const imageUrl = emptyToNull(section.image_url);
      const imagePublicId = emptyToNull(section.image_public_id);
      const imageAltText = emptyToNull(section.image_alt_text);
      const imageCaption = emptyToNull(section.image_caption);
      const metadata = normalizeJsonObject(section.metadata);
      return {
        order_index: normalizeNullableNumber(section.order_index) ?? index,
        title,
        body,
        image_url: imageUrl,
        image_public_id: imagePublicId,
        image_alt_text: imageAltText,
        image_caption: imageCaption,
        metadata,
      };
    });

  const relatedPlansFromIds = (input.related_plan_ids ?? [])
    .map((planTemplateId, index) => ({
      plan_template_id: planTemplateId,
      relationship_type: 'related',
      display_order: index,
      cta_label: null,
    }));

  const relatedPlans = (input.related_plans?.length ? input.related_plans : relatedPlansFromIds)
    .map((plan, index) => {
      const planTemplateId = emptyToNull(plan.plan_template_id);
      if (!planTemplateId) return null;
      return {
        plan_template_id: planTemplateId,
        relationship_type: slugify(plan.relationship_type || 'related') || 'related',
        display_order: normalizeNullableNumber(plan.display_order) ?? index,
        cta_label: emptyToNull(plan.cta_label),
      };
    })
    .filter((plan): plan is NonNullable<typeof plan> => Boolean(plan));

  return {
    slug,
    content_type: contentType,
    language: normalizeLanguage(input.language),
    title,
    subtitle: emptyToNull(input.subtitle),
    summary: emptyToNull(input.summary),
    body: contentType === 'essay' ? null : emptyToNull(input.body),
    cover_image_url: emptyToNull(input.cover_image_url),
    cover_image_public_id: emptyToNull(input.cover_image_public_id),
    author_id: emptyToNull(input.author_id),
    author_display_name: emptyToNull(input.author_display_name),
    primary_verse_reference: emptyToNull(input.primary_verse_reference),
    bible_version: emptyToNull(input.bible_version)?.toUpperCase() ?? null,
    verse_text: emptyToNull(input.verse_text),
    duration_seconds: normalizeNullableNumber(input.duration_seconds),
    external_url: emptyToNull(input.external_url),
    is_published: isPublished,
    is_archived: isArchived,
    published_at: publishedAt,
    featured_rank: normalizeNullableNumber(input.featured_rank),
    browse_visible: input.browse_visible !== false,
    metadata: normalizeJsonObject(input.metadata),
    assets,
    sections: contentType === 'essay' ? sections : [],
    tags,
    related_plans: relatedPlans,
  };
}

function normalizeTag(value?: string | null) {
  return emptyToNull(value)?.toLowerCase() ?? null;
}

async function getContentRelations(content: ContentBase) {
  const author = content.author_id
    ? ((await sql`
        select * from content_authors
        where id = ${content.author_id}
        limit 1
      `) as ContentAuthor[])[0] ?? null
    : null;

  const assets = (await sql`
    select * from content_assets
    where content_id = ${content.id}
    order by asset_role asc, order_index asc, created_at asc
  `) as ContentAsset[];

  const sections = (await sql`
    select * from content_sections
    where content_id = ${content.id}
    order by order_index asc, created_at asc
  `) as ContentSection[];

  const tags = (await sql`
    select t.* from content_tags t
    join content_tag_links ctl on ctl.tag_id = t.id
    where ctl.content_id = ${content.id}
    order by t.type asc, t.sort_order asc, t.name asc
  `) as ContentTag[];

  const relatedPlans = (await sql`
    select
      cpl.relationship_type,
      cpl.display_order,
      cpl.cta_label,
      pt.id,
      pt.template_key,
      pt.title,
      pt.subtitle,
      pt.cover_image_url,
      pt.total_chapters,
      pt.estimated_minutes
    from content_plan_links cpl
    join plan_templates pt on pt.id = cpl.plan_template_id
    where cpl.content_id = ${content.id}
      and pt.is_published = true
      and pt.is_archived = false
    order by cpl.display_order asc, pt.featured_rank asc nulls last, pt.updated_at desc
  `) as ContentRelatedPlan[];

  return { author, assets, sections, tags, relatedPlans };
}

async function resolveAuthorId(
  input: ReturnType<typeof normalizeInput>,
) {
  if (input.author_id) return input.author_id;
  if (!input.author_display_name) return null;

  const slug = slugify(input.author_display_name);
  await sql`
    insert into content_authors (
      slug,
      display_name,
      is_active,
      created_at,
      updated_at
    ) values (
      ${slug},
      ${input.author_display_name},
      true,
      now(),
      now()
    )
    on conflict (slug) do update set
      display_name = excluded.display_name,
      is_active = true,
      updated_at = now()
  `;
  const rows = (await sql`
    select id from content_authors
    where slug = ${slug}
    limit 1
  `) as Array<{ id: string }>;
  return rows[0]?.id ?? null;
}

function buildAssetQueries(contentId: string, assets: ReturnType<typeof normalizeInput>['assets'], txn: SqlLike) {
  return assets.map((asset) => txn`
    insert into content_assets (
      content_id,
      asset_type,
      asset_role,
      order_index,
      title,
      caption,
      alt_text,
      url,
      public_id,
      provider,
      mime_type,
      width,
      height,
      duration_seconds,
      metadata,
      created_at,
      updated_at
    ) values (
      ${contentId},
      ${asset.asset_type},
      ${asset.asset_role},
      ${asset.order_index},
      ${asset.title},
      ${asset.caption},
      ${asset.alt_text},
      ${asset.url},
      ${asset.public_id},
      ${asset.provider},
      ${asset.mime_type},
      ${asset.width},
      ${asset.height},
      ${asset.duration_seconds},
      ${asset.metadata},
      now(),
      now()
    )
  `);
}

function buildSectionQueries(contentId: string, sections: ReturnType<typeof normalizeInput>['sections'], txn: SqlLike) {
  return sections.map((section) => txn`
    insert into content_sections (
      content_id,
      order_index,
      title,
      body,
      image_url,
      image_public_id,
      image_alt_text,
      image_caption,
      metadata,
      created_at,
      updated_at
    ) values (
      ${contentId},
      ${section.order_index},
      ${section.title},
      ${section.body},
      ${section.image_url},
      ${section.image_public_id},
      ${section.image_alt_text},
      ${section.image_caption},
      ${section.metadata},
      now(),
      now()
    )
  `);
}

function buildTagQueries(contentId: string, tags: ReturnType<typeof normalizeInput>['tags'], txn: SqlLike) {
  const queries: unknown[] = [];
  tags.forEach((tag) => {
    queries.push(txn`
      insert into content_tags (
        type,
        key,
        name,
        description,
        sort_order,
        is_active,
        created_at,
        updated_at
      ) values (
        ${tag.type},
        ${tag.key},
        ${tag.name},
        ${tag.description},
        ${tag.sort_order},
        true,
        now(),
        now()
      )
      on conflict (type, key) do update set
        name = excluded.name,
        description = excluded.description,
        sort_order = excluded.sort_order,
        is_active = true,
        updated_at = now()
    `);
    queries.push(txn`
      insert into content_tag_links (content_id, tag_id, created_at)
      select ${contentId}, id, now()
      from content_tags
      where type = ${tag.type} and key = ${tag.key}
      on conflict (content_id, tag_id) do nothing
    `);
  });
  return queries;
}

function buildRelatedPlanQueries(
  contentId: string,
  relatedPlans: ReturnType<typeof normalizeInput>['related_plans'],
  txn: SqlLike,
) {
  return relatedPlans.map((plan) => txn`
    insert into content_plan_links (
      content_id,
      plan_template_id,
      relationship_type,
      display_order,
      cta_label,
      created_at
    ) values (
      ${contentId},
      ${plan.plan_template_id},
      ${plan.relationship_type},
      ${plan.display_order},
      ${plan.cta_label},
      now()
    )
    on conflict (content_id, plan_template_id, relationship_type) do update set
      display_order = excluded.display_order,
      cta_label = excluded.cta_label
  `);
}

function hydrateContent(
  content: ContentBase,
  relations: Awaited<ReturnType<typeof getContentRelations>>,
): ContentWithRelations {
  return {
    ...content,
    author: relations.author,
    assets: relations.assets,
    sections: relations.sections,
    tags: relations.tags,
    related_plans: relations.relatedPlans,
  };
}

export async function getPublishedContents(options?: {
  sort?: PublishedContentSortMode;
  type?: string | null;
  language?: string | null;
  tag?: string | null;
  limit?: number;
}) {
  const contentType = normalizeContentType(options?.type);
  const language = normalizeLanguage(options?.language);
  const tag = normalizeTag(options?.tag);
  const limit = options?.limit ?? 20;

  if (options?.sort === 'new') {
    return (await sql`
      select distinct c.* from contents c
      left join content_tag_links ctl on ctl.content_id = c.id
      left join content_tags ct on ct.id = ctl.tag_id
      where c.is_published = true
        and c.is_archived = false
        and c.browse_visible = true
        and c.language = ${language}
        and (${contentType}::text is null or c.content_type = ${contentType})
        and (${tag}::text is null or ct.key = ${tag} or lower(ct.name) = ${tag})
      order by c.published_at desc nulls last, c.updated_at desc
      limit ${limit}
    `) as ContentBase[];
  }

  return (await sql`
    select distinct c.* from contents c
    left join content_tag_links ctl on ctl.content_id = c.id
    left join content_tags ct on ct.id = ctl.tag_id
    where c.is_published = true
      and c.is_archived = false
      and c.browse_visible = true
      and c.language = ${language}
      and (${contentType}::text is null or c.content_type = ${contentType})
      and (${tag}::text is null or ct.key = ${tag} or lower(ct.name) = ${tag})
    order by c.featured_rank asc nulls last, c.published_at desc nulls last, c.updated_at desc
    limit ${limit}
  `) as ContentBase[];
}

export async function getPublishedContentsWithRelations(options?: {
  sort?: PublishedContentSortMode;
  type?: string | null;
  language?: string | null;
  tag?: string | null;
  limit?: number;
}) {
  const contents = await getPublishedContents(options);
  return await Promise.all(
    contents.map(async (content) => {
      const relations = await getContentRelations(content);
      return hydrateContent(content, relations);
    }),
  );
}

export async function getPublishedContentByIdentifier(identifier: string, language?: string | null) {
  const normalizedIdentifier = identifier.trim();
  const normalizedLanguage = normalizeLanguage(language);
  const rows = (await sql`
    select * from contents
    where is_published = true
      and is_archived = false
      and browse_visible = true
      and language = ${normalizedLanguage}
      and (id::text = ${normalizedIdentifier} or slug = ${normalizedIdentifier})
    limit 1
  `) as ContentBase[];
  const content = rows[0];
  if (!content) return null;
  const relations = await getContentRelations(content);
  return hydrateContent(content, relations);
}

export async function getAdminContents() {
  const contents = (await sql`
    select * from contents
    order by updated_at desc
  `) as ContentBase[];
  return await Promise.all(
    contents.map(async (content) => {
      const relations = await getContentRelations(content);
      return hydrateContent(content, relations);
    }),
  );
}

export async function getAdminContentById(id: string) {
  const rows = (await sql`
    select * from contents
    where id::text = ${id}
    limit 1
  `) as ContentBase[];
  const content = rows[0];
  if (!content) return null;
  const relations = await getContentRelations(content);
  return hydrateContent(content, relations);
}

export async function getAdminContentAuthors() {
  return (await sql`
    select * from content_authors
    order by is_active desc, display_name asc
  `) as ContentAuthor[];
}

export async function createAdminContent(rawInput: AdminContentInput) {
  const input = normalizeInput(rawInput);
  const existing = (await sql`
    select id from contents where slug = ${input.slug} limit 1
  `) as Array<{ id: string }>;
  if (existing[0]) {
    throw new ContentValidationError('A content item already exists with this slug.');
  }

  const contentId = crypto.randomUUID();
  const authorId = await resolveAuthorId(input);

  await sql.transaction((txn: SqlLike) => [
    txn`
      insert into contents (
        id,
        slug,
        content_type,
        language,
        title,
        subtitle,
        summary,
        body,
        cover_image_url,
        cover_image_public_id,
        author_id,
        primary_verse_reference,
        bible_version,
        verse_text,
        duration_seconds,
        external_url,
        is_published,
        is_archived,
        published_at,
        featured_rank,
        browse_visible,
        metadata,
        created_at,
        updated_at
      ) values (
        ${contentId},
        ${input.slug},
        ${input.content_type},
        ${input.language},
        ${input.title},
        ${input.subtitle},
        ${input.summary},
        ${input.body},
        ${input.cover_image_url},
        ${input.cover_image_public_id},
        ${authorId},
        ${input.primary_verse_reference},
        ${input.bible_version},
        ${input.verse_text},
        ${input.duration_seconds},
        ${input.external_url},
        ${input.is_published},
        ${input.is_archived},
        ${input.published_at},
        ${input.featured_rank},
        ${input.browse_visible},
        ${input.metadata},
        now(),
        now()
      )
    `,
    ...buildAssetQueries(contentId, input.assets, txn),
    ...buildSectionQueries(contentId, input.sections, txn),
    ...buildTagQueries(contentId, input.tags, txn),
    ...buildRelatedPlanQueries(contentId, input.related_plans, txn),
  ] as any);

  return await getAdminContentById(contentId);
}

export async function updateAdminContent(id: string, rawInput: AdminContentInput) {
  const input = normalizeInput(rawInput);
  const duplicate = (await sql`
    select id from contents
    where slug = ${input.slug} and id::text <> ${id}
    limit 1
  `) as Array<{ id: string }>;
  if (duplicate[0]) {
    throw new ContentValidationError('A content item already exists with this slug.');
  }

  const authorId = await resolveAuthorId(input);

  await sql.transaction((txn: SqlLike) => [
    txn`
      update contents set
        slug = ${input.slug},
        content_type = ${input.content_type},
        language = ${input.language},
        title = ${input.title},
        subtitle = ${input.subtitle},
        summary = ${input.summary},
        body = ${input.body},
        cover_image_url = ${input.cover_image_url},
        cover_image_public_id = ${input.cover_image_public_id},
        author_id = ${authorId},
        primary_verse_reference = ${input.primary_verse_reference},
        bible_version = ${input.bible_version},
        verse_text = ${input.verse_text},
        duration_seconds = ${input.duration_seconds},
        external_url = ${input.external_url},
        is_published = ${input.is_published},
        is_archived = ${input.is_archived},
        published_at = ${input.published_at},
        featured_rank = ${input.featured_rank},
        browse_visible = ${input.browse_visible},
        metadata = ${input.metadata},
        updated_at = now()
      where id::text = ${id}
    `,
    txn`delete from content_assets where content_id::text = ${id}`,
    txn`delete from content_sections where content_id::text = ${id}`,
    txn`delete from content_tag_links where content_id::text = ${id}`,
    txn`delete from content_plan_links where content_id::text = ${id}`,
    ...buildAssetQueries(id, input.assets, txn),
    ...buildSectionQueries(id, input.sections, txn),
    ...buildTagQueries(id, input.tags, txn),
    ...buildRelatedPlanQueries(id, input.related_plans, txn),
  ] as any);

  return await getAdminContentById(id);
}

export async function deleteAdminContent(id: string) {
  const deleted = (await sql`
    delete from contents
    where id::text = ${id}
    returning id
  `) as Array<{ id: string }>;
  return deleted.length > 0;
}
