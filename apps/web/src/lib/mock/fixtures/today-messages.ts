import type { TodayMessageBase } from '@/lib/today-messages';
import { MOCK_IDS, MOCK_TS } from '@/lib/mock/fixtures/ids';

function utcDateOffset(days: number) {
  const date = new Date();
  date.setUTCHours(0, 0, 0, 0);
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}

export function buildMockTodayMessages(): TodayMessageBase[] {
  return [
    {
      id: MOCK_IDS.todayToday,
      content_id: MOCK_IDS.contents['john-1-1-3'],
      publish_date: utcDateOffset(0),
      language: 'en',
      verse_reference: '',
      bible_version: null,
      verse_text: null,
      image_url: null,
      image_public_id: null,
      share_image_url: null,
      share_image_public_id: null,
      hint_title: null,
      hint_summary: null,
      is_published: true,
      heart_count: 0,
      share_count: 0,
      created_at: MOCK_TS,
      updated_at: MOCK_TS,
    },
  ];
}
