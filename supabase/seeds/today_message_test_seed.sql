-- Today's Message slots for closed testing.
-- Run after message_cards_pilot_seed.sql (Message Card must exist first).
--
-- Model (latest): today_messages.content_id → Message Card only.
-- Verse / image / hint are denormalized from the linked card (same as Admin save).

insert into today_messages (
  publish_date,
  language,
  verse_reference,
  bible_version,
  verse_text,
  image_url,
  image_public_id,
  hint_title,
  hint_summary,
  content_id,
  is_published,
  created_at,
  updated_at
)
select
  current_date,
  'en',
  coalesce(c.primary_verse_reference, ''),
  c.bible_version,
  c.verse_text,
  c.cover_image_url,
  c.cover_image_public_id,
  null,
  nullif(trim(coalesce(c.metadata->>'hint', c.metadata->>'prayerText', '')), ''),
  c.id,
  c.is_published,
  now(),
  now()
from contents c
where c.slug = 'when-your-mind-feels-crowded'
  and c.content_type = 'message'
  and c.is_archived = false
on conflict (publish_date, language) do update set
  verse_reference = excluded.verse_reference,
  bible_version = excluded.bible_version,
  verse_text = excluded.verse_text,
  image_url = excluded.image_url,
  image_public_id = excluded.image_public_id,
  hint_title = excluded.hint_title,
  hint_summary = excluded.hint_summary,
  content_id = excluded.content_id,
  is_published = excluded.is_published,
  updated_at = now();

-- Yesterday slot — second Message Card (calendar / RPC history smoke)
insert into today_messages (
  publish_date,
  language,
  verse_reference,
  bible_version,
  verse_text,
  image_url,
  image_public_id,
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
  coalesce(c.primary_verse_reference, ''),
  c.bible_version,
  c.verse_text,
  c.cover_image_url,
  c.cover_image_public_id,
  null,
  nullif(trim(coalesce(c.metadata->>'hint', c.metadata->>'prayerText', '')), ''),
  c.id,
  c.is_published,
  now(),
  now()
from contents c
where c.slug = 'when-tomorrow-feels-heavy'
  and c.content_type = 'message'
  and c.is_archived = false
on conflict (publish_date, language) do update set
  verse_reference = excluded.verse_reference,
  bible_version = excluded.bible_version,
  verse_text = excluded.verse_text,
  image_url = excluded.image_url,
  image_public_id = excluded.image_public_id,
  hint_title = excluded.hint_title,
  hint_summary = excluded.hint_summary,
  content_id = excluded.content_id,
  is_published = excluded.is_published,
  updated_at = now();
