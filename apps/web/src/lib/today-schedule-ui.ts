import type { TodayMessageBase } from '@/lib/today-messages';

export type TodayScheduleDayStatus = 'gap' | 'draft' | 'published';

export interface TodayScheduleDay {
  date: string;
  inMonth: boolean;
  status: TodayScheduleDayStatus;
  slot: TodayMessageBase | null;
}

export interface LinkedMessageSummary {
  id: string;
  title: string;
  slug: string;
  cover_image_url?: string | null;
  is_published: boolean;
}

function formatUtcDate(date: Date) {
  return date.toISOString().slice(0, 10);
}

export function getUtcTodayIso() {
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);
  return formatUtcDate(today);
}

export function parseMonthKey(monthKey: string) {
  const match = /^(\d{4})-(\d{2})$/.exec(monthKey.trim());
  if (!match) return null;
  const year = Number(match[1]);
  const month = Number(match[2]) - 1;
  if (!Number.isFinite(year) || !Number.isFinite(month) || month < 0 || month > 11) {
    return null;
  }
  return { year, month };
}

export function monthKeyFromDate(isoDate: string) {
  return isoDate.slice(0, 7);
}

export function shiftMonthKey(monthKey: string, delta: number) {
  const parsed = parseMonthKey(monthKey);
  if (!parsed) return monthKeyFromDate(getUtcTodayIso());
  const date = new Date(Date.UTC(parsed.year, parsed.month + delta, 1));
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, '0')}`;
}

export function formatMonthLabel(monthKey: string) {
  const parsed = parseMonthKey(monthKey);
  if (!parsed) return monthKey;
  const date = new Date(Date.UTC(parsed.year, parsed.month, 1));
  return new Intl.DateTimeFormat('en-US', {
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  }).format(date);
}

export function findTodaySlotForDate(
  messages: TodayMessageBase[],
  date: string,
  language = 'en',
): TodayMessageBase | null {
  return messages.find((item) => item.publish_date === date && item.language === language) ?? null;
}

export function resolveTodaySlotStatus(
  slot: TodayMessageBase | null,
  linked?: Pick<LinkedMessageSummary, 'is_published'> | null,
): TodayScheduleDayStatus {
  if (!slot) return 'gap';
  const cardPublished = linked?.is_published ?? slot.is_published;
  return cardPublished ? 'published' : 'draft';
}

export function listTodaySlotsForMonth(
  messages: TodayMessageBase[],
  monthKey: string,
  language = 'en',
): TodayMessageBase[] {
  return messages
    .filter((item) => item.language === language && item.publish_date.startsWith(`${monthKey}-`))
    .sort((a, b) => a.publish_date.localeCompare(b.publish_date));
}

export function buildCalendarMonth(
  monthKey: string,
  messages: TodayMessageBase[],
  language = 'en',
  linkedByContentId?: Map<string, LinkedMessageSummary>,
): TodayScheduleDay[] {
  const parsed = parseMonthKey(monthKey);
  if (!parsed) return [];

  const { year, month } = parsed;
  const firstDay = new Date(Date.UTC(year, month, 1));
  const daysInMonth = new Date(Date.UTC(year, month + 1, 0)).getUTCDate();
  const startOffset = firstDay.getUTCDay();

  const cells: TodayScheduleDay[] = [];

  for (let index = 0; index < startOffset; index += 1) {
    const date = new Date(firstDay);
    date.setUTCDate(date.getUTCDate() - (startOffset - index));
    cells.push({
      date: formatUtcDate(date),
      inMonth: false,
      status: 'gap',
      slot: null,
    });
  }

  for (let day = 1; day <= daysInMonth; day += 1) {
    const date = formatUtcDate(new Date(Date.UTC(year, month, day)));
    const slot = findTodaySlotForDate(messages, date, language);
    const linked = slot?.content_id ? linkedByContentId?.get(slot.content_id) ?? null : null;
    cells.push({
      date,
      inMonth: true,
      status: resolveTodaySlotStatus(slot, linked),
      slot,
    });
  }

  while (cells.length % 7 !== 0) {
    const lastDate = new Date(`${cells[cells.length - 1]!.date}T00:00:00.000Z`);
    lastDate.setUTCDate(lastDate.getUTCDate() + 1);
    cells.push({
      date: formatUtcDate(lastDate),
      inMonth: false,
      status: 'gap',
      slot: null,
    });
  }

  return cells;
}

export function todaySlotDisplayLabel(
  slot: TodayMessageBase | null,
  linked: LinkedMessageSummary | null,
) {
  if (linked?.title) return linked.title;
  if (slot?.verse_reference) return slot.verse_reference;
  return 'Scheduled';
}

export const CALENDAR_WEEKDAY_LABELS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'] as const;
