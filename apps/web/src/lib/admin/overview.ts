import { sql } from '@/lib/db/postgres';
import { MESSAGE_PRIMARY_CATEGORIES } from '@/lib/message-taxonomy';
import { isOfflineMode } from '@/lib/mock/mode';
import { mockGetAdminOverview } from '@/lib/mock/readers';

export interface AdminOverviewMessageCounts {
  total: number;
  published: number;
  draft: number;
  archived: number;
}

export interface AdminOverviewPlanCounts {
  total: number;
  active: number;
  published: number;
  browseVisible: number;
  draft: number;
  archived: number;
}

export interface AdminOverviewTodayDay {
  date: string;
  status: 'published' | 'draft' | 'gap';
  messageId?: string;
  verseReference?: string;
}

export interface AdminOverviewCategoryCoverage {
  key: string;
  label: string;
  publishedCount: number;
}

export interface AdminOverview {
  messageCounts: AdminOverviewMessageCounts;
  planCounts: AdminOverviewPlanCounts;
  todaySchedule: {
    today: AdminOverviewTodayDay | null;
    nextSevenDays: AdminOverviewTodayDay[];
  };
  categoryCoverage: AdminOverviewCategoryCoverage[];
}

function formatDate(date: Date) {
  return date.toISOString().slice(0, 10);
}

function addDays(date: Date, days: number) {
  const next = new Date(date);
  next.setUTCDate(next.getUTCDate() + days);
  return next;
}

function toNumber(value: unknown) {
  if (typeof value === 'number') return value;
  if (typeof value === 'string') return Number(value) || 0;
  return 0;
}

function buildTodaySchedule(
  rows: Array<{
    id: string;
    publish_date: string;
    verse_reference: string;
    content_is_published: boolean | null;
  }>,
) {
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);

  const byDate = new Map<string, typeof rows>();
  for (const row of rows) {
    const bucket = byDate.get(row.publish_date) ?? [];
    bucket.push(row);
    byDate.set(row.publish_date, bucket);
  }

  const resolveDay = (date: string): AdminOverviewTodayDay => {
    const matches = byDate.get(date) ?? [];
    if (matches.length === 0) {
      return { date, status: 'gap' };
    }

    const published = matches.find((item) => item.content_is_published === true);
    const chosen = published ?? matches[0];
    return {
      date,
      status: chosen.content_is_published ? 'published' : 'draft',
      messageId: chosen.id,
      verseReference: chosen.verse_reference,
    };
  };

  const nextSevenDays: AdminOverviewTodayDay[] = [];
  for (let offset = 0; offset < 7; offset += 1) {
    nextSevenDays.push(resolveDay(formatDate(addDays(today, offset))));
  }

  return {
    today: nextSevenDays[0] ?? null,
    nextSevenDays,
  };
}

export async function getAdminOverview(): Promise<AdminOverview> {
  if (isOfflineMode()) {
    return mockGetAdminOverview();
  }

  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);
  const rangeStart = formatDate(today);
  const rangeEnd = formatDate(addDays(today, 6));

  const [messageStatsRows, categoryRows, todayRows, planStatsRows] = await Promise.all([
    sql`
      select
        count(*) filter (where content_type = 'message')::int as total,
        count(*) filter (
          where content_type = 'message' and is_published = true and is_archived = false
        )::int as published,
        count(*) filter (
          where content_type = 'message' and is_published = false and is_archived = false
        )::int as draft,
        count(*) filter (where content_type = 'message' and is_archived = true)::int as archived
      from contents
    `,
    sql`
      select category_key as key, count(distinct content_id)::int as count
      from (
        select
          c.id as content_id,
          coalesce(
            nullif(trim(c.metadata->>'primaryCategory'), ''),
            cat_tag.key
          ) as category_key
        from contents c
        left join lateral (
          select ct.key
          from content_tag_links ctl
          join content_tags ct on ct.id = ctl.tag_id and ct.type = 'category'
          where ctl.content_id = c.id
          order by ctl.created_at
          limit 1
        ) cat_tag on true
        where c.content_type = 'message'
          and c.is_published = true
          and c.is_archived = false
      ) published_messages
      where category_key is not null and category_key <> ''
      group by category_key
    `,
    sql`
      select tm.id, tm.publish_date, tm.verse_reference, c.is_published as content_is_published
      from today_messages tm
      left join contents c on c.id = tm.content_id
      where tm.publish_date >= ${rangeStart}
        and tm.publish_date <= ${rangeEnd}
      order by tm.publish_date asc, tm.updated_at desc
    `,
    sql`
      select
        count(*)::int as total,
        count(*) filter (where is_archived = false)::int as active,
        count(*) filter (where is_published = true and is_archived = false)::int as published,
        count(*) filter (
          where is_published = true and is_archived = false and browse_visible = true
        )::int as browse_visible,
        count(*) filter (where is_published = false and is_archived = false)::int as draft,
        count(*) filter (where is_archived = true)::int as archived
      from plan_templates
    `,
  ]);

  const messageStats = (messageStatsRows as Array<Record<string, unknown>>)[0];
  const planStats = (planStatsRows as Array<Record<string, unknown>>)[0];

  const countsByCategory = new Map<string, number>();
  for (const row of categoryRows as Array<{ key: string; count: number }>) {
    if (row.key) countsByCategory.set(row.key, toNumber(row.count));
  }

  return {
    messageCounts: {
      total: toNumber(messageStats?.total),
      published: toNumber(messageStats?.published),
      draft: toNumber(messageStats?.draft),
      archived: toNumber(messageStats?.archived),
    },
    planCounts: {
      total: toNumber(planStats?.total),
      active: toNumber(planStats?.active),
      published: toNumber(planStats?.published),
      browseVisible: toNumber(planStats?.browse_visible),
      draft: toNumber(planStats?.draft),
      archived: toNumber(planStats?.archived),
    },
    todaySchedule: buildTodaySchedule(
      todayRows as Array<{
        id: string;
        publish_date: string;
        verse_reference: string;
        content_is_published: boolean | null;
      }>,
    ),
    categoryCoverage: MESSAGE_PRIMARY_CATEGORIES.map((category) => ({
      key: category.key,
      label: category.label,
      publishedCount: countsByCategory.get(category.key) ?? 0,
    })),
  };
}
