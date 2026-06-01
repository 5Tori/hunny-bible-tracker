import 'server-only';

import { sql } from '@/lib/db/postgres';
import {
  type AdminDiscoverListItem,
  isDiscoverContentType,
} from '@/lib/discover-content';
import { isOfflineMode } from '@/lib/mock/mode';
import { getMockContents } from '@/lib/mock/store';

export async function getAdminDiscoverContentsList(options?: {
  contentType?: string;
}): Promise<AdminDiscoverListItem[]> {
  if (isOfflineMode()) {
    const typeFilter = options?.contentType?.trim().toLowerCase();
    return getMockContents()
      .filter((item) => isDiscoverContentType(item.content_type))
      .filter((item) => !typeFilter || item.content_type === typeFilter)
      .map((item) => ({
        id: item.id,
        slug: item.slug,
        content_type: item.content_type,
        language: item.language,
        title: item.title,
        summary: item.summary,
        cover_image_url: item.cover_image_url,
        is_published: item.is_published,
        is_archived: item.is_archived,
        metadata: item.metadata ?? {},
        updated_at: item.updated_at,
        related_plan_count: item.related_plans.length,
      }));
  }

  const typeFilter = options?.contentType?.trim().toLowerCase();
  const filterByType = typeFilter && isDiscoverContentType(typeFilter);

  const rows = filterByType
    ? ((await sql`
        select
          c.id,
          c.slug,
          c.content_type,
          c.language,
          c.title,
          c.summary,
          c.cover_image_url,
          c.is_published,
          c.is_archived,
          c.metadata,
          c.updated_at,
          coalesce(pc.related_plan_count, 0)::int as related_plan_count
        from contents c
        left join (
          select content_id, count(*)::int as related_plan_count
          from content_plan_links
          group by content_id
        ) pc on pc.content_id = c.id
        where c.content_type = ${typeFilter}
        order by c.updated_at desc
      `) as AdminDiscoverListItem[])
    : ((await sql`
        select
          c.id,
          c.slug,
          c.content_type,
          c.language,
          c.title,
          c.summary,
          c.cover_image_url,
          c.is_published,
          c.is_archived,
          c.metadata,
          c.updated_at,
          coalesce(pc.related_plan_count, 0)::int as related_plan_count
        from contents c
        left join (
          select content_id, count(*)::int as related_plan_count
          from content_plan_links
          group by content_id
        ) pc on pc.content_id = c.id
        where c.content_type in ('video', 'essay', 'cartoon')
        order by c.updated_at desc
      `) as AdminDiscoverListItem[]);

  return rows.map((row) => ({
    ...row,
    metadata: row.metadata ?? {},
    related_plan_count: Number(row.related_plan_count) || 0,
  }));
}
