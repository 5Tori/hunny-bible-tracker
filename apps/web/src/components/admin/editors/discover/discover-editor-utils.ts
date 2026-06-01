import type { AdminContentInput, ContentWithRelations } from '@/lib/content';
import {
  DISCOVER_GALLERY_ASSET_ROLE,
  filterNonEmptyDiscoverSections,
  isDiscoverContentType,
  isDiscoverGalleryAsset,
} from '@/lib/discover-content';

import {
  getDiscoverBlockType,
  migrateDiscoverBodyIntoSections,
  normalizeDiscoverSectionsForSave,
} from '@/lib/discover-blocks';

export function discoverSlugFromTitle(title: string) {
  return title
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

export const emptyDiscoverContent: AdminContentInput = {
  slug: '',
  content_type: 'essay',
  language: 'en',
  title: '',
  subtitle: '',
  summary: '',
  body: '',
  cover_image_url: '',
  cover_image_public_id: '',
  author_id: '',
  author_display_name: '',
  duration_seconds: null,
  external_url: '',
  is_published: false,
  is_archived: false,
  published_at: '',
  featured_rank: null,
  browse_visible: true,
  metadata: {},
  assets: [],
  sections: [],
  tags: [],
  related_plan_ids: [],
};

export function parseDiscoverNumber(value: string) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

export function toDateTimeLocal(value: string | null | undefined) {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';
  return date.toISOString().slice(0, 16);
}

export function fromDateTimeLocal(value: string) {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';
  return date.toISOString();
}

export function formatMetadataJson(value: unknown) {
  if (!value || typeof value !== 'object') return '';
  return JSON.stringify(value, null, 2);
}

export function mapDiscoverContentToForm(content: ContentWithRelations): AdminContentInput {
  return migrateDiscoverBodyIntoSections({
    slug: content.slug,
    content_type: content.content_type,
    language: content.language,
    title: content.title,
    subtitle: content.subtitle ?? '',
    summary: content.summary ?? '',
    body: content.body ?? '',
    cover_image_url: content.cover_image_url ?? '',
    cover_image_public_id: content.cover_image_public_id ?? '',
    author_id: content.author_id ?? '',
    author_display_name: content.author?.display_name ?? '',
    duration_seconds: content.duration_seconds,
    external_url: content.external_url ?? '',
    is_published: content.is_published,
    is_archived: content.is_archived,
    published_at: toDateTimeLocal(content.published_at),
    featured_rank: content.featured_rank,
    browse_visible: content.browse_visible !== false,
    metadata: content.metadata,
    assets: content.assets.map((asset) => ({
      asset_type: asset.asset_type,
      asset_role:
        isDiscoverGalleryAsset(asset.asset_role) || content.content_type === 'cartoon'
          ? DISCOVER_GALLERY_ASSET_ROLE
          : asset.asset_role,
      order_index: asset.order_index,
      title: asset.title ?? '',
      caption: asset.caption ?? '',
      alt_text: asset.alt_text ?? '',
      url: asset.url,
      public_id: asset.public_id ?? '',
      provider: asset.provider ?? '',
      mime_type: asset.mime_type ?? '',
      width: asset.width,
      height: asset.height,
      duration_seconds: asset.duration_seconds,
      metadata: asset.metadata,
    })),
    sections: content.sections.map((section) => {
      const mapped = {
        order_index: section.order_index,
        title: section.title ?? '',
        body: section.body ?? '',
        image_url: section.image_url ?? '',
        image_public_id: section.image_public_id ?? '',
        image_alt_text: section.image_alt_text ?? '',
        image_caption: section.image_caption ?? '',
        metadata: section.metadata,
      };
      const blockType = getDiscoverBlockType(mapped);
      return {
        ...mapped,
        metadata: {
          ...(section.metadata && typeof section.metadata === 'object' && !Array.isArray(section.metadata)
            ? section.metadata
            : {}),
          block_type: blockType,
        },
      };
    }),
    tags: content.tags.map((tag) => ({
      type: tag.type,
      key: tag.key,
      name: tag.name,
      description: tag.description ?? '',
      sort_order: tag.sort_order,
    })),
    related_plan_ids: content.related_plans.map((plan) => plan.id),
  });
}

export function prepareDiscoverPayload(
  content: AdminContentInput,
  metadataText: string,
): AdminContentInput {
  if (!isDiscoverContentType(content.content_type)) {
    throw new Error('Discover items must be Video, Article, or Cartoon category.');
  }

  const title = content.title?.trim() ?? '';
  const slug = discoverSlugFromTitle(title);
  if (!slug) {
    throw new Error('Title is required.');
  }

  let metadata: Record<string, unknown> = {};
  if (metadataText.trim()) {
    try {
      metadata = JSON.parse(metadataText) as Record<string, unknown>;
    } catch {
      throw new Error('Metadata must be valid JSON.');
    }
  }

  const galleryAssets = (content.assets ?? [])
    .filter((asset) => asset.url.trim())
    .map((asset, index) => ({
      ...asset,
      asset_role: asset.asset_role?.trim() || DISCOVER_GALLERY_ASSET_ROLE,
      order_index: asset.order_index ?? index,
    }));

  return {
    ...content,
    language: 'en',
    slug,
    body: null,
    published_at:
      typeof content.published_at === 'string'
        ? fromDateTimeLocal(content.published_at)
        : content.published_at,
    metadata,
    assets: galleryAssets,
    sections: filterNonEmptyDiscoverSections(normalizeDiscoverSectionsForSave(content.sections)),
    tags: (content.tags ?? []).filter((tag) => tag.name.trim()),
    primary_verse_reference: null,
    bible_version: null,
    verse_text: null,
  };
}
