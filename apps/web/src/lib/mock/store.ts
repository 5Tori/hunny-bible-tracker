import type {
  AdminContentInput,
  ContentAsset,
  ContentAuthor,
  ContentRelatedPlan,
  ContentSection,
  ContentTag,
  ContentWithRelations,
} from '@/lib/content';
import { ContentValidationError } from '@/lib/content';
import { isDiscoverContentType } from '@/lib/discover-content';
import { mockAuthor } from '@/lib/mock/fixtures/author';
import { buildInitialMockContents } from '@/lib/mock/fixtures/contents';
import { MOCK_TS } from '@/lib/mock/fixtures/ids';
import { getMockPlanByIdentifier, mockPlans } from '@/lib/mock/fixtures/plans';
import { buildMockTodayMessages } from '@/lib/mock/fixtures/today-messages';
import { validateMessageCardInput } from '@/lib/message-content-validation';
import { parseMessageEngagement, type MessageEngagementField } from '@/lib/message-engagement';
import { parseMessageMetadata } from '@/lib/message-metadata';
import type { AdminTodayMessageInput, TodayMessageBase } from '@/lib/today-messages';
import { TodayMessageValidationError } from '@/lib/today-messages';

let contents: ContentWithRelations[] = buildInitialMockContents().map(cloneContent);
let todayMessages: TodayMessageBase[] = buildMockTodayMessages().map(cloneTodayMessage);

function cloneContent(content: ContentWithRelations): ContentWithRelations {
  return structuredClone(content);
}

function cloneTodayMessage(message: TodayMessageBase): TodayMessageBase {
  return structuredClone(message);
}

function slugify(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function emptyToNull(value?: string | null) {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

function resolveRelatedPlans(input: AdminContentInput): ContentRelatedPlan[] {
  const planIds = input.related_plan_ids ?? [];
  const plans: ContentRelatedPlan[] = [];

  for (const [index, planId] of planIds.entries()) {
    const plan =
      mockPlans.find((item) => item.id === planId) ?? getMockPlanByIdentifier(planId);
    if (!plan) continue;
    plans.push({
      relationship_type: 'related',
      display_order: index,
      cta_label: null,
      id: plan.id,
      template_key: plan.template_key,
      title: plan.title,
      subtitle: plan.subtitle,
      cover_image_url: plan.cover_image_url,
      total_chapters: plan.total_chapters,
      estimated_minutes: plan.estimated_minutes,
    });
  }

  return plans;
}

function buildTags(input: AdminContentInput, contentId: string): ContentTag[] {
  return (input.tags ?? []).map((tag, index) => ({
    id: `tag-${contentId.slice(0, 8)}-${index}`,
    type: slugify(tag.type || 'topic') || 'topic',
    key: slugify(tag.key || tag.name) || slugify(tag.name),
    name: tag.name.trim(),
    description: emptyToNull(tag.description),
    sort_order: Number(tag.sort_order) || index,
    is_active: true,
    created_at: MOCK_TS,
    updated_at: MOCK_TS,
  }));
}

function validateMessageInput(input: AdminContentInput) {
  const validationError = validateMessageCardInput({
    primary_verse_reference: input.primary_verse_reference,
    bible_version: input.bible_version,
    verse_text: input.verse_text,
    cover_image_url: input.cover_image_url,
    is_published: input.is_published,
  });
  if (validationError) {
    throw new ContentValidationError(validationError);
  }
}

function buildMessageContentFromInput(
  input: AdminContentInput,
  existing?: ContentWithRelations,
): ContentWithRelations {
  const verseReference = emptyToNull(input.primary_verse_reference);
  const title = emptyToNull(input.title) || verseReference;
  if (!title) throw new ContentValidationError('Title or verse reference is required.');

  const slug = slugify(input.slug || title);
  if (!slug) throw new ContentValidationError('Slug is required.');

  validateMessageInput(input);

  const duplicate = contents.find(
    (item) => item.slug === slug && item.id !== existing?.id,
  );
  if (duplicate) {
    throw new ContentValidationError('A content item already exists with this slug.');
  }

  const isArchived = Boolean(input.is_archived);
  const isPublished = Boolean(input.is_published) && !isArchived;
  const id = existing?.id ?? crypto.randomUUID();
  const author: ContentAuthor = mockAuthor;
  const now = new Date().toISOString();

  const metadataObject =
    typeof input.metadata === 'object' && input.metadata && !Array.isArray(input.metadata)
      ? input.metadata
      : {};

  return {
    id,
    slug,
    content_type: 'message',
    language: (input.language?.trim().toLowerCase() || 'en').slice(0, 16),
    title,
    subtitle: null,
    summary: null,
    body: null,
    cover_image_url: emptyToNull(input.cover_image_url),
    cover_image_public_id: emptyToNull(input.cover_image_public_id),
    author_id: emptyToNull(input.author_id) ?? author.id,
    primary_verse_reference: verseReference,
    bible_version: emptyToNull(input.bible_version)?.toUpperCase() ?? null,
    verse_text: emptyToNull(input.verse_text),
    duration_seconds: null,
    external_url: null,
    is_published: isPublished,
    is_archived: isArchived,
    published_at: isPublished ? existing?.published_at ?? now : null,
    featured_rank: Number(input.featured_rank) || null,
    browse_visible: input.browse_visible !== false,
    metadata: { ...metadataObject },
    created_at: existing?.created_at ?? now,
    updated_at: now,
    author,
    assets: [],
    sections: [],
    tags: buildTags(input, id),
    related_plans: resolveRelatedPlans(input),
  };
}

function buildDiscoverContentFromInput(
  input: AdminContentInput,
  existing?: ContentWithRelations,
): ContentWithRelations {
  const contentType = input.content_type?.trim().toLowerCase();
  if (!isDiscoverContentType(contentType)) {
    throw new ContentValidationError('Choose a valid discover content type.');
  }

  const title = emptyToNull(input.title);
  if (!title) throw new ContentValidationError('Title is required.');

  const slug = slugify(input.slug || title);
  if (!slug) throw new ContentValidationError('Slug is required.');

  const duplicate = contents.find(
    (item) => item.slug === slug && item.id !== existing?.id,
  );
  if (duplicate) {
    throw new ContentValidationError('A content item already exists with this slug.');
  }

  const isArchived = Boolean(input.is_archived);
  const isPublished = Boolean(input.is_published) && !isArchived;
  const id = existing?.id ?? crypto.randomUUID();
  const author: ContentAuthor = mockAuthor;
  const now = new Date().toISOString();
  const metadataObject =
    typeof input.metadata === 'object' && input.metadata && !Array.isArray(input.metadata)
      ? input.metadata
      : {};

  const sections: ContentSection[] = (input.sections ?? []).map((section, index) => ({
    id: `sec-${id.slice(0, 8)}-${index}`,
    content_id: id,
    order_index: Number(section.order_index) || index,
    title: emptyToNull(section.title),
    body: emptyToNull(section.body),
    image_url: emptyToNull(section.image_url),
    image_public_id: emptyToNull(section.image_public_id),
    image_alt_text: emptyToNull(section.image_alt_text),
    image_caption: emptyToNull(section.image_caption),
    metadata:
      typeof section.metadata === 'object' && section.metadata && !Array.isArray(section.metadata)
        ? section.metadata
        : {},
    created_at: existing?.sections[index]?.created_at ?? now,
    updated_at: now,
  }));

  const assets: ContentAsset[] = (input.assets ?? []).map((asset, index) => ({
    id: `asset-${id.slice(0, 8)}-${index}`,
    content_id: id,
    asset_type: emptyToNull(asset.asset_type) ?? 'image',
    asset_role: emptyToNull(asset.asset_role) ?? (contentType === 'cartoon' ? 'slide' : 'body'),
    order_index: Number(asset.order_index) || index,
    title: emptyToNull(asset.title),
    caption: emptyToNull(asset.caption),
    alt_text: emptyToNull(asset.alt_text),
    url: asset.url,
    public_id: emptyToNull(asset.public_id),
    provider: emptyToNull(asset.provider),
    mime_type: emptyToNull(asset.mime_type),
    width: Number(asset.width) || null,
    height: Number(asset.height) || null,
    duration_seconds: Number(asset.duration_seconds) || null,
    metadata:
      typeof asset.metadata === 'object' && asset.metadata && !Array.isArray(asset.metadata)
        ? asset.metadata
        : {},
    created_at: existing?.assets[index]?.created_at ?? now,
    updated_at: now,
  }));

  return {
    id,
    slug,
    content_type: contentType,
    language: (input.language?.trim().toLowerCase() || 'en').slice(0, 16),
    title,
    subtitle: emptyToNull(input.subtitle),
    summary: emptyToNull(input.summary),
    body: emptyToNull(input.body),
    cover_image_url: emptyToNull(input.cover_image_url),
    cover_image_public_id: emptyToNull(input.cover_image_public_id),
    author_id: emptyToNull(input.author_id) ?? author.id,
    primary_verse_reference: null,
    bible_version: null,
    verse_text: null,
    duration_seconds: Number(input.duration_seconds) || null,
    external_url: emptyToNull(input.external_url),
    is_published: isPublished,
    is_archived: isArchived,
    published_at: isPublished ? existing?.published_at ?? now : null,
    featured_rank: Number(input.featured_rank) || null,
    browse_visible: input.browse_visible !== false,
    metadata: { ...metadataObject },
    created_at: existing?.created_at ?? now,
    updated_at: now,
    author,
    assets,
    sections: sections.filter(
      (section) =>
        Boolean(section.title?.trim()) ||
        Boolean(section.body?.trim()) ||
        Boolean(section.image_url?.trim()),
    ),
    tags: buildTags(input, id),
    related_plans: resolveRelatedPlans(input),
  };
}

function buildContentFromInput(
  input: AdminContentInput,
  existing?: ContentWithRelations,
): ContentWithRelations {
  if (input.content_type === 'message') {
    return buildMessageContentFromInput(input, existing);
  }
  return buildDiscoverContentFromInput(input, existing);
}

export function getMockContents(): ContentWithRelations[] {
  return contents;
}

export function getMockContentById(id: string) {
  return contents.find((item) => item.id === id) ?? null;
}

export function getMockContentByIdentifier(identifier: string) {
  const key = identifier.trim().toLowerCase();
  return (
    contents.find((item) => item.id === identifier || item.slug === key) ?? null
  );
}

export function mockCreateContent(rawInput: AdminContentInput) {
  if (rawInput.content_type !== 'message' && !isDiscoverContentType(rawInput.content_type)) {
    throw new ContentValidationError('Unsupported content type for offline save.');
  }
  const content = buildContentFromInput(rawInput);
  contents = [...contents, content];
  return cloneContent(content);
}

export function mockUpdateContent(id: string, rawInput: AdminContentInput) {
  const existing = getMockContentById(id);
  if (!existing) return null;
  if (rawInput.content_type !== 'message' && !isDiscoverContentType(rawInput.content_type)) {
    throw new ContentValidationError('Unsupported content type for offline save.');
  }
  const content = buildContentFromInput(rawInput, existing);
  contents = contents.map((item) => (item.id === id ? content : item));
  return cloneContent(content);
}

export function mockDeleteContent(id: string) {
  const before = contents.length;
  contents = contents.filter((item) => item.id !== id);
  return contents.length < before;
}

export function mockIncrementMessageEngagement(
  slug: string,
  field: MessageEngagementField,
) {
  const key = slug.trim().toLowerCase();
  const index = contents.findIndex(
    (item) => item.slug === key && item.content_type === 'message',
  );
  if (index === -1) return null;

  const content = contents[index];
  const metadata = {
    ...(typeof content.metadata === 'object' && content.metadata ? content.metadata : {}),
  };
  const counts = parseMessageEngagement(metadata);
  const next = { ...counts, [field]: counts[field] + 1 };
  metadata.heartCount = next.heartCount;
  metadata.shareCount = next.shareCount;
  metadata.saveCount = next.saveCount;

  contents[index] = {
    ...content,
    metadata,
    updated_at: new Date().toISOString(),
  };

  return next;
}

export function getMockTodayMessages(): TodayMessageBase[] {
  return todayMessages;
}

export function getMockTodayMessageById(id: string) {
  return todayMessages.find((item) => item.id === id) ?? null;
}

function resolveTodayFieldsFromContent(contentId: string) {
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
    is_published: content.is_published,
  };
}

function normalizeTodayInput(input: AdminTodayMessageInput, existing?: TodayMessageBase) {
  const publishDate = input.publish_date?.trim();
  if (!publishDate) {
    throw new TodayMessageValidationError('Publish date is required.');
  }

  const contentId = emptyToNull(input.content_id);
  if (!contentId) {
    throw new TodayMessageValidationError('Select a message card for today.');
  }

  const fields = resolveTodayFieldsFromContent(contentId);

  if (fields.is_published && !fields.verse_text) {
    throw new TodayMessageValidationError('Linked message must include verse text to publish.');
  }

  const duplicate = todayMessages.find(
    (item) =>
      item.publish_date === publishDate &&
      item.language === (input.language?.trim().toLowerCase() || 'en').slice(0, 16) &&
      item.id !== existing?.id,
  );
  if (duplicate) {
    throw new TodayMessageValidationError(
      'A message already exists for this publish date and language.',
    );
  }

  const now = new Date().toISOString();

  return {
    id: existing?.id ?? crypto.randomUUID(),
    content_id: contentId,
    publish_date: publishDate,
    language: (input.language?.trim().toLowerCase() || 'en').slice(0, 16),
    verse_reference: fields.verse_reference,
    bible_version: fields.bible_version,
    verse_text: fields.verse_text,
    image_url: fields.image_url,
    image_public_id: fields.image_public_id,
    share_image_url: null,
    share_image_public_id: null,
    hint_title: null,
    hint_summary: fields.hint_summary,
    is_published: fields.is_published,
    heart_count: existing?.heart_count ?? 0,
    share_count: existing?.share_count ?? 0,
    created_at: existing?.created_at ?? now,
    updated_at: now,
  } satisfies TodayMessageBase;
}

export function mockCreateTodayMessage(input: AdminTodayMessageInput) {
  const message = normalizeTodayInput(input);
  todayMessages = [...todayMessages, message];
  return cloneTodayMessage(message);
}

export function mockUpdateTodayMessage(id: string, input: AdminTodayMessageInput) {
  const existing = getMockTodayMessageById(id);
  if (!existing) return null;
  const message = normalizeTodayInput(input, existing);
  todayMessages = todayMessages.map((item) => (item.id === id ? message : item));
  return cloneTodayMessage(message);
}

export function mockDeleteTodayMessage(id: string) {
  const existing = getMockTodayMessageById(id);
  if (!existing) return null;
  todayMessages = todayMessages.filter((item) => item.id !== id);
  return cloneTodayMessage(existing);
}

export function resetMockStore() {
  contents = buildInitialMockContents().map(cloneContent);
  todayMessages = buildMockTodayMessages().map(cloneTodayMessage);
}
