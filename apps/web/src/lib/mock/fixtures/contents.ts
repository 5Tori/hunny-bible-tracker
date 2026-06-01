import type { ContentWithRelations } from '@/lib/content';
import { isDiscoverContentType } from '@/lib/discover-content';
import {
  buildDiscoverContent,
  discoverContentSeeds,
} from '@/lib/mock/fixtures/discover-content-seeds';
import { buildMessageContent } from '@/lib/mock/fixtures/message-card-seed-builders';
import { handPickedMessageSeeds } from '@/lib/mock/fixtures/hand-picked-message-seeds';
import { importedMessageSeeds } from '@/lib/mock/fixtures/imported-message-seeds';

export type {
  MessageCardMetadataSeed,
  MessageCardSeed,
  MessageCardSeedTagSpec,
} from '@/lib/mock/fixtures/message-card-seed-builders';
export { buildMessageContent, messageCardTag } from '@/lib/mock/fixtures/message-card-seed-builders';

const messageSeeds = [...handPickedMessageSeeds, ...importedMessageSeeds];

export function buildInitialMockContents(): ContentWithRelations[] {
  return [
    ...messageSeeds.map(buildMessageContent),
    ...discoverContentSeeds.map(buildDiscoverContent),
  ];
}

/** Initial fixture snapshot; prefer `getMockContents()` from the mock store at runtime. */
export const mockContents: ContentWithRelations[] = buildInitialMockContents();

export function getMockContentByIdentifier(identifier: string) {
  const key = identifier.trim().toLowerCase();
  return (
    mockContents.find((item) => item.id === identifier || item.slug === key) ?? null
  );
}

export function getMockMessageContents() {
  return mockContents.filter((item) => item.content_type === 'message');
}

export function getMockBrowseContents(
  options?: {
    type?: string | null;
    language?: string | null;
    sort?: 'featured' | 'new';
    limit?: number;
    discoverOnly?: boolean;
  },
  source: ContentWithRelations[] = mockContents,
) {
  let rows = source.filter(
    (item) =>
      item.is_published &&
      !item.is_archived &&
      item.browse_visible &&
      (!options?.language || item.language === options.language) &&
      (!options?.discoverOnly || isDiscoverContentType(item.content_type)) &&
      (!options?.type || options.type === 'all' || item.content_type === options.type),
  );

  if (options?.sort === 'new') {
    rows = rows.sort(
      (a, b) =>
        new Date(b.published_at ?? b.updated_at).getTime() -
        new Date(a.published_at ?? a.updated_at).getTime(),
    );
  } else {
    rows = rows.sort(
      (a, b) => (a.featured_rank ?? 999) - (b.featured_rank ?? 999),
    );
  }

  return rows.slice(0, options?.limit ?? 48);
}
