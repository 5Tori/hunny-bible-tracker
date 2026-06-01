import type { ContentWithRelations } from '@/lib/content';
import { discoverSectionsForDisplay, getDiscoverBlockType } from '@/lib/discover-blocks';
import { isDiscoverContentType, type DiscoverContentType } from '@/lib/discover-content';

const DEFAULT_DESCRIPTION = 'Explore Scripture with Hunny Bible Tracker.';

export function isDiscoverPost(
  content: Pick<ContentWithRelations, 'content_type'>,
): content is ContentWithRelations & { content_type: DiscoverContentType } {
  return isDiscoverContentType(content.content_type);
}

/** SEO / Open Graph description from summary, subtitle, or first paragraph block. */
export function discoverContentDescription(
  content: Pick<ContentWithRelations, 'summary' | 'subtitle' | 'body' | 'sections'>,
  maxLength = 160,
): string {
  const summary = content.summary?.trim();
  if (summary) return summary.slice(0, maxLength);

  const subtitle = content.subtitle?.trim();
  if (subtitle) return subtitle.slice(0, maxLength);

  for (const section of discoverSectionsForDisplay(content)) {
    if (getDiscoverBlockType(section) === 'paragraph') {
      const text = section.body?.trim();
      if (text) return text.slice(0, maxLength);
    }
  }

  const legacyBody = content.body?.trim();
  if (legacyBody) return legacyBody.slice(0, maxLength);

  return DEFAULT_DESCRIPTION;
}

/** Card teaser is enough on the detail page when blocks carry the story. */
export function shouldShowDiscoverSummaryOnDetail(
  content: Pick<ContentWithRelations, 'summary' | 'sections' | 'body'>,
): boolean {
  if (!content.summary?.trim()) return false;
  const sections = discoverSectionsForDisplay(content);
  return sections.length === 0;
}

export function shouldShowDiscoverCoverOnDetail(
  content: Pick<ContentWithRelations, 'cover_image_url' | 'content_type'>,
  options: { hasYoutube: boolean; slideCount: number },
): boolean {
  if (!content.cover_image_url?.trim() || options.hasYoutube) return false;
  if (content.content_type === 'cartoon' && options.slideCount > 0) return false;
  return true;
}
