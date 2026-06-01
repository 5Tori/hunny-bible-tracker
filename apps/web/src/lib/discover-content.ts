export const DISCOVER_CONTENT_TYPES = ['video', 'essay', 'cartoon'] as const;

export type DiscoverContentType = (typeof DISCOVER_CONTENT_TYPES)[number];

export function isDiscoverContentType(value?: string | null): value is DiscoverContentType {
  const type = value?.trim().toLowerCase();
  return DISCOVER_CONTENT_TYPES.includes(type as DiscoverContentType);
}

export function discoverContentTypeLabel(type: string) {
  switch (type) {
    case 'video':
      return 'Video';
    case 'essay':
      return 'Article';
    case 'cartoon':
      return 'Cartoon';
    default:
      return type;
  }
}

/** Discover post category (stored as `content_type`: video | essay | cartoon). */
export const DISCOVER_CATEGORY_OPTIONS = [
  {
    value: 'video' as const,
    label: 'Video',
    description: 'YouTube or external video up top, with optional post content blocks below.',
  },
  {
    value: 'essay' as const,
    label: 'Article',
    description: 'Text-first post built from headings, paragraphs, and image blocks.',
  },
  {
    value: 'cartoon' as const,
    label: 'Cartoon',
    description: 'Slide-style image sequence with optional intro blocks.',
  },
] as const;

export const DISCOVER_GALLERY_ASSET_ROLE = 'slide';

export function isDiscoverGalleryAsset(role: string | null | undefined) {
  return (role ?? '').trim().toLowerCase() === DISCOVER_GALLERY_ASSET_ROLE;
}

export function filterNonEmptyDiscoverSections<
  T extends {
    title?: string | null;
    body?: string | null;
    image_url?: string | null;
  },
>(sections: T[] | undefined | null): T[] {
  return (sections ?? []).filter(
    (section) =>
      Boolean(section.title?.trim()) ||
      Boolean(section.body?.trim()) ||
      Boolean(section.image_url?.trim()),
  );
}

/** Admin Discover list row — no message-card fields (verse, taxonomy). */
export interface AdminDiscoverListItem {
  id: string;
  slug: string;
  content_type: DiscoverContentType | string;
  language: string;
  title: string;
  summary: string | null;
  cover_image_url: string | null;
  is_published: boolean;
  is_archived: boolean;
  metadata: Record<string, unknown>;
  updated_at: string;
  related_plan_count: number;
}
