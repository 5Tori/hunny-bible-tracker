import type { AdminContentInput, ContentSection } from '@/lib/content';

export const DISCOVER_BLOCK_TYPES = ['heading', 'paragraph', 'image'] as const;

export type DiscoverBlockType = (typeof DISCOVER_BLOCK_TYPES)[number];

export type DiscoverBlockSectionLike = {
  title?: string | null;
  body?: string | null;
  image_url?: string | null;
  metadata?: Record<string, unknown> | unknown;
};

export type DiscoverSectionInput = NonNullable<AdminContentInput['sections']>[number];

export function isDiscoverBlockType(value: unknown): value is DiscoverBlockType {
  return (
    typeof value === 'string' &&
    DISCOVER_BLOCK_TYPES.includes(value.trim().toLowerCase() as DiscoverBlockType)
  );
}

export function discoverBlockTypeLabel(type: DiscoverBlockType) {
  switch (type) {
    case 'heading':
      return 'Heading';
    case 'paragraph':
      return 'Paragraph';
    case 'image':
      return 'Image';
    default:
      return type;
  }
}

export function getDiscoverBlockType(section: DiscoverBlockSectionLike): DiscoverBlockType {
  const raw = section.metadata;
  const fromMeta =
    raw && typeof raw === 'object' && !Array.isArray(raw)
      ? (raw as Record<string, unknown>).block_type
      : null;
  if (isDiscoverBlockType(fromMeta)) {
    return fromMeta.trim().toLowerCase() as DiscoverBlockType;
  }

  const hasImage = Boolean(section.image_url?.trim());
  const hasTitle = Boolean(section.title?.trim());
  const hasBody = Boolean(section.body?.trim());

  if (hasImage && !hasTitle && !hasBody) return 'image';
  if (hasTitle && !hasBody && !hasImage) return 'heading';
  if (hasBody && !hasImage) return 'paragraph';
  if (hasImage) return 'image';
  if (hasTitle) return 'heading';
  return 'paragraph';
}

export function withDiscoverBlockType(
  section: DiscoverSectionInput,
  blockType: DiscoverBlockType,
): DiscoverSectionInput {
  const metadata =
    section.metadata && typeof section.metadata === 'object' && !Array.isArray(section.metadata)
      ? { ...(section.metadata as Record<string, unknown>) }
      : {};

  return {
    ...section,
    metadata: { ...metadata, block_type: blockType },
  };
}

export function createDiscoverBlock(
  blockType: DiscoverBlockType,
  orderIndex: number,
): DiscoverSectionInput {
  return withDiscoverBlockType(
    {
      order_index: orderIndex,
      title: '',
      body: '',
      image_url: '',
      image_public_id: '',
      image_alt_text: '',
      image_caption: '',
      metadata: {},
    },
    blockType,
  );
}

export function applyDiscoverBlockTypeChange(
  section: DiscoverSectionInput,
  blockType: DiscoverBlockType,
): DiscoverSectionInput {
  const base = withDiscoverBlockType(section, blockType);

  switch (blockType) {
    case 'heading':
      return {
        ...base,
        body: '',
        image_url: '',
        image_public_id: '',
        image_alt_text: '',
        image_caption: '',
      };
    case 'paragraph':
      return {
        ...base,
        title: '',
        image_url: '',
        image_public_id: '',
        image_alt_text: '',
        image_caption: '',
      };
    case 'image':
      return { ...base, title: '', body: '' };
    default:
      return base;
  }
}

export function normalizeDiscoverSectionsForSave(
  sections: DiscoverSectionInput[] | undefined | null,
): DiscoverSectionInput[] {
  return (sections ?? []).map((section, index) =>
    withDiscoverBlockType({ ...section, order_index: index }, getDiscoverBlockType(section)),
  );
}

/** Legacy discover posts stored long-form copy in `body`; fold into a leading paragraph block. */
export function migrateDiscoverBodyIntoSections(form: AdminContentInput): AdminContentInput {
  const body = form.body?.trim();
  if (!body) {
    return { ...form, body: '' };
  }

  const leadingParagraph = createDiscoverBlock('paragraph', 0);
  leadingParagraph.body = body;

  const rest = (form.sections ?? []).map((section, index) => ({
    ...section,
    order_index: index + 1,
  }));

  return {
    ...form,
    body: '',
    sections: [leadingParagraph, ...rest],
  };
}

/** Unsaved legacy rows may still have `body`; show as a leading paragraph on the public page. */
export function discoverSectionsForDisplay(content: {
  body: string | null;
  sections: ContentSection[];
}): ContentSection[] {
  const body = content.body?.trim();
  if (!body) {
    return content.sections;
  }

  const legacyParagraph: ContentSection = {
    id: '__legacy_body__',
    content_id: '',
    order_index: -1,
    title: null,
    body,
    image_url: null,
    image_public_id: null,
    image_alt_text: null,
    image_caption: null,
    metadata: { block_type: 'paragraph' },
    created_at: '',
    updated_at: '',
  };

  return [legacyParagraph, ...content.sections].sort(
    (a, b) => (a.order_index ?? 0) - (b.order_index ?? 0),
  );
}
