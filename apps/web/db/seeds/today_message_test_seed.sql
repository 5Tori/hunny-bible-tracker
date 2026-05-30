-- Example Today Messages for closed testing.
-- Run after:
--   1. supabase/migrations/20260529120000_simplify_today_messages.sql
--   2. apps/web/db/seeds/content_test_seed.sql (for Mode B linked content)

-- Mode A — simple daily card (image + verse + hint, no linked content)
insert into today_messages (
  publish_date,
  language,
  verse_reference,
  bible_version,
  verse_text,
  hint_title,
  hint_summary,
  content_id,
  is_published,
  created_at,
  updated_at
)
values (
  current_date,
  'en',
  'Psalm 46:10',
  'NIV',
  'Be still, and know that I am God.',
  'A pause before the day',
  'Stillness is not empty time. It is room to remember who holds the day.',
  null,
  true,
  now(),
  now()
)
on conflict (publish_date, language) do update set
  verse_reference = excluded.verse_reference,
  bible_version = excluded.bible_version,
  verse_text = excluded.verse_text,
  hint_title = excluded.hint_title,
  hint_summary = excluded.hint_summary,
  content_id = excluded.content_id,
  is_published = excluded.is_published,
  updated_at = now();

-- Mode B — linked to Discover content + content_plan_links plans
insert into today_messages (
  publish_date,
  language,
  verse_reference,
  bible_version,
  verse_text,
  hint_title,
  hint_summary,
  content_id,
  is_published,
  created_at,
  updated_at
)
select
  current_date - 1,
  'en',
  'Philippians 4:6-7',
  'NIV',
  'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.',
  'Peace when you feel rushed',
  'Start with a short pause, then open the linked story and its reading plan.',
  c.id,
  true,
  now(),
  now()
from contents c
where c.slug = 'peace-when-you-feel-rushed'
  and c.is_published = true
  and c.is_archived = false
on conflict (publish_date, language) do update set
  verse_reference = excluded.verse_reference,
  bible_version = excluded.bible_version,
  verse_text = excluded.verse_text,
  hint_title = excluded.hint_title,
  hint_summary = excluded.hint_summary,
  content_id = excluded.content_id,
  is_published = excluded.is_published,
  updated_at = now();
