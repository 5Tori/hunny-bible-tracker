import 'server-only';

import { sql } from '@/lib/db/postgres';
import { isOfflineMode } from '@/lib/mock/mode';

import {
  parseMessageEngagement,
  type MessageEngagementCounts,
  type MessageEngagementField,
} from '@/lib/message-engagement';

export async function incrementMessageEngagement(
  slug: string,
  field: MessageEngagementField,
): Promise<MessageEngagementCounts | null> {
  const normalizedSlug = slug.trim().toLowerCase();
  if (!normalizedSlug) return null;

  if (isOfflineMode()) {
    const { mockIncrementMessageEngagement } = await import('@/lib/mock/store');
    return mockIncrementMessageEngagement(normalizedSlug, field);
  }

  const rows = (await sql`
    update contents
    set
      metadata = jsonb_set(
        coalesce(metadata, '{}'::jsonb),
        array[${field}]::text[],
        to_jsonb(
          coalesce((metadata->>${field})::int, 0) + 1
        ),
        true
      ),
      updated_at = now()
    where slug = ${normalizedSlug}
      and content_type = 'message'
      and is_published = true
      and is_archived = false
    returning metadata
  `) as Array<{ metadata: Record<string, unknown> | null }>;

  const metadata = rows[0]?.metadata;
  if (!metadata) return null;
  return parseMessageEngagement(metadata);
}
