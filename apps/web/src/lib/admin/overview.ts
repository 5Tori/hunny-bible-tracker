import { sql } from '@/lib/db/postgres';
import { MESSAGE_CATEGORIES } from '@/lib/message-taxonomy';

export interface AdminOverviewMessageCounts {
  total: number;
  published: number;
  draft: number;
  todayEligible: number;
  archived: number;
}

export interface AdminOverviewPlanCounts {
  total: number;
  active: number;
  published: number;
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
  rows: Array<{ id: string; publish_date: string; verse_reference: string; is_published: boolean }>,
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

    const published = matches.find((item) => item.is_published);
    const chosen = published ?? matches[0];
    return {
      date,
      status: chosen.is_published ? 'published' : 'draft',
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
        count(*) filter (
          where content_type = 'message'
            and is_archived = false
            and coalesce((metadata->>'isTodayEligible')::boolean, true) = true
        )::int as today_eligible,
        count(*) filter (where content_type = 'message' and is_archived = true)::int as archived
      from contents
    `,
    sql`
      select
        metadata->>'primaryCategory' as key,
        count(*)::int as count
      from contents
      where content_type = 'message'
        and is_published = true
        and is_archived = false
        and coalesce(metadata->>'primaryCategory', '') <> ''
      group by metadata->>'primaryCategory'
    `,
    sql`
      select id, publish_date, verse_reference, is_published
      from today_messages
      where publish_date >= ${rangeStart}
        and publish_date <= ${rangeEnd}
      order by publish_date asc, updated_at desc
    `,
    sql`
      select
        count(*)::int as total,
        count(*) filter (where is_archived = false)::int as active,
        count(*) filter (where is_published = true and is_archived = false)::int as published,
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
      todayEligible: toNumber(messageStats?.today_eligible),
      archived: toNumber(messageStats?.archived),
    },
    planCounts: {
      total: toNumber(planStats?.total),
      active: toNumber(planStats?.active),
      published: toNumber(planStats?.published),
      archived: toNumber(planStats?.archived),
    },
    todaySchedule: buildTodaySchedule(
      todayRows as Array<{ id: string; publish_date: string; verse_reference: string; is_published: boolean }>,
    ),
    categoryCoverage: MESSAGE_CATEGORIES.map((category) => ({
      key: category.key,
      label: category.label,
      publishedCount: countsByCategory.get(category.key) ?? 0,
    })),
  };
}
