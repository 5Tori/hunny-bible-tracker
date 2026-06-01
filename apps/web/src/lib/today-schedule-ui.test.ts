import { describe, expect, it } from 'vitest';

import {
  buildCalendarMonth,
  findTodaySlotForDate,
  listTodaySlotsForMonth,
  shiftMonthKey,
} from '@/lib/today-schedule-ui';
import type { TodayMessageBase } from '@/lib/today-messages';

function slot(partial: Partial<TodayMessageBase> & Pick<TodayMessageBase, 'id' | 'publish_date'>) {
  return {
    content_id: 'msg-1',
    language: 'en',
    is_published: true,
    is_archived: false,
    created_at: '2026-01-01T00:00:00.000Z',
    updated_at: '2026-01-01T00:00:00.000Z',
    ...partial,
  } as TodayMessageBase;
}

describe('today-schedule-ui', () => {
  it('lists slots for a month and language', () => {
    const messages = [
      slot({ id: 'a', publish_date: '2026-05-01' }),
      slot({ id: 'b', publish_date: '2026-05-15', language: 'ko' }),
      slot({ id: 'c', publish_date: '2026-06-01' }),
    ];

    expect(listTodaySlotsForMonth(messages, '2026-05', 'en').map((item) => item.id)).toEqual(['a']);
  });

  it('finds a slot by date and language', () => {
    const messages = [slot({ id: 'a', publish_date: '2026-05-10' })];
    expect(findTodaySlotForDate(messages, '2026-05-10', 'en')?.id).toBe('a');
    expect(findTodaySlotForDate(messages, '2026-05-10', 'ko')).toBeNull();
  });

  it('builds a calendar grid with padded weeks', () => {
    const messages = [
      slot({ id: 'a', publish_date: '2026-05-01', is_published: true }),
      slot({ id: 'b', publish_date: '2026-05-03', is_published: false }),
    ];
    const days = buildCalendarMonth('2026-05', messages, 'en');

    expect(days.length % 7).toBe(0);
    expect(days.filter((day) => day.inMonth)).toHaveLength(31);
    expect(days.find((day) => day.date === '2026-05-01')?.status).toBe('published');
    expect(days.find((day) => day.date === '2026-05-02')?.status).toBe('gap');
    expect(days.find((day) => day.date === '2026-05-03')?.status).toBe('draft');
  });

  it('uses linked card publish state when provided', () => {
    const messages = [slot({ id: 'a', publish_date: '2026-05-01', is_published: true })];
    const linked = new Map([
      [
        'msg-1',
        {
          id: 'msg-1',
          title: 'Card',
          slug: 'card',
          is_published: false,
        },
      ],
    ]);

    const days = buildCalendarMonth('2026-05', messages, 'en', linked);
    expect(days.find((day) => day.date === '2026-05-01')?.status).toBe('draft');
  });

  it('shifts month keys', () => {
    expect(shiftMonthKey('2026-05', 1)).toBe('2026-06');
    expect(shiftMonthKey('2026-01', -1)).toBe('2025-12');
  });
});
