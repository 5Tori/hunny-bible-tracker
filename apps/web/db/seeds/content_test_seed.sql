-- Test content seed for Discover.
-- Run after apps/web/db/migrations/20260517_content_catalog.sql.

insert into content_authors (slug, display_name, bio, is_active, created_at, updated_at)
values (
  'hunny-team',
  'Hunny Team',
  'Short, approachable Bible reading guides from Hunny.',
  true,
  now(),
  now()
)
on conflict (slug) do update set
  display_name = excluded.display_name,
  bio = excluded.bio,
  is_active = true,
  updated_at = now();

insert into content_tags (type, key, name, sort_order, is_active, created_at, updated_at)
values
  ('topic', 'peace', 'Peace', 10, true, now(), now()),
  ('topic', 'prayer', 'Prayer', 20, true, now(), now()),
  ('situation', 'anxiety-fear', 'Anxiety & Fear', 10, true, now(), now()),
  ('person', 'jesus', 'Jesus', 10, true, now(), now()),
  ('book', 'mark', 'Mark', 10, true, now(), now()),
  ('format', 'quick', 'Quick', 10, true, now(), now())
on conflict (type, key) do update set
  name = excluded.name,
  sort_order = excluded.sort_order,
  is_active = true,
  updated_at = now();

insert into contents (
  slug,
  content_type,
  language,
  title,
  subtitle,
  summary,
  body,
  author_id,
  primary_verse_reference,
  bible_version,
  verse_text,
  duration_seconds,
  external_url,
  is_published,
  is_archived,
  published_at,
  featured_rank,
  browse_visible,
  metadata,
  created_at,
  updated_at
)
select
  seed.slug,
  seed.content_type,
  'en',
  seed.title,
  seed.subtitle,
  seed.summary,
  seed.body,
  author.id,
  seed.primary_verse_reference,
  seed.bible_version,
  seed.verse_text,
  seed.duration_seconds,
  seed.external_url,
  true,
  false,
  now(),
  seed.featured_rank,
  true,
  seed.metadata::jsonb,
  now(),
  now()
from (
  values
    (
      'peace-when-you-feel-rushed',
      'message',
      'A short pause for a rushed day',
      'Peace is often received one small pause at a time.',
      'Take one minute to slow down and return to God with your whole attention.',
      'Start with one honest breath. You do not need to solve the whole day before you pray.',
      'Psalm 46:10',
      'KJV',
      'Be still, and know that I am God.',
      90,
      null,
      10,
      '{"seed":true}'
    ),
    (
      'how-to-start-the-gospel-of-mark',
      'video',
      'How to start Mark',
      'A simple entry point into the life of Jesus.',
      'A short video-style guide for beginning the Gospel of Mark without pressure.',
      'Mark moves quickly. Read it like a series of vivid scenes: Jesus acts, people respond, and the question becomes personal.',
      'Mark 1:1',
      null,
      null,
      360,
      'https://example.com/videos/start-mark',
      20,
      '{"seed":true}'
    ),
    (
      'when-prayer-feels-small',
      'essay',
      'When prayer feels small',
      'Small prayers are still real prayers.',
      'An essay for days when your words feel too thin or tired.',
      'Prayer does not become faithful because it is long. Sometimes the honest sentence is the doorway back to God.',
      'Romans 8:26',
      null,
      null,
      480,
      null,
      30,
      '{"seed":true}'
    ),
    (
      'jonah-running-from-mercy',
      'webtoon',
      'Jonah: running from mercy',
      'A three-panel visual story starter.',
      'A webtoon-style introduction to Jonah and the surprising wideness of mercy.',
      'Jonah is not only a story about running away. It is a story about God pursuing both the prophet and the city.',
      'Jonah 1:3',
      null,
      null,
      240,
      null,
      40,
      '{"seed":true,"slides":3}'
    )
) as seed(
  slug,
  content_type,
  title,
  subtitle,
  summary,
  body,
  primary_verse_reference,
  bible_version,
  verse_text,
  duration_seconds,
  external_url,
  featured_rank,
  metadata
)
join content_authors author on author.slug = 'hunny-team'
on conflict (slug) do update set
  content_type = excluded.content_type,
  title = excluded.title,
  subtitle = excluded.subtitle,
  summary = excluded.summary,
  body = excluded.body,
  author_id = excluded.author_id,
  primary_verse_reference = excluded.primary_verse_reference,
  bible_version = excluded.bible_version,
  verse_text = excluded.verse_text,
  duration_seconds = excluded.duration_seconds,
  external_url = excluded.external_url,
  is_published = true,
  is_archived = false,
  published_at = excluded.published_at,
  featured_rank = excluded.featured_rank,
  browse_visible = true,
  metadata = excluded.metadata,
  updated_at = now();

insert into content_tag_links (content_id, tag_id, created_at)
select c.id, t.id, now()
from contents c
join (
  values
    ('peace-when-you-feel-rushed', 'topic', 'peace'),
    ('peace-when-you-feel-rushed', 'situation', 'anxiety-fear'),
    ('peace-when-you-feel-rushed', 'format', 'quick'),
    ('how-to-start-the-gospel-of-mark', 'person', 'jesus'),
    ('how-to-start-the-gospel-of-mark', 'book', 'mark'),
    ('when-prayer-feels-small', 'topic', 'prayer'),
    ('when-prayer-feels-small', 'format', 'quick'),
    ('jonah-running-from-mercy', 'topic', 'peace')
) as map(content_slug, tag_type, tag_key) on map.content_slug = c.slug
join content_tags t on t.type = map.tag_type and t.key = map.tag_key
on conflict (content_id, tag_id) do nothing;

insert into content_plan_links (
  content_id,
  plan_template_id,
  relationship_type,
  display_order,
  cta_label,
  created_at
)
select c.id, p.id, 'related', map.display_order, 'Start plan', now()
from contents c
join (
  values
    ('how-to-start-the-gospel-of-mark', 'gospel_of_mark', 0),
    ('peace-when-you-feel-rushed', 'psalms_for_anxiety', 0),
    ('jonah-running-from-mercy', 'jonah', 0)
) as map(content_slug, template_key, display_order) on map.content_slug = c.slug
join plan_templates p on p.template_key = map.template_key
on conflict (content_id, plan_template_id, relationship_type) do update set
  display_order = excluded.display_order,
  cta_label = excluded.cta_label;

delete from content_assets
where content_id in (
  select id from contents where slug = 'jonah-running-from-mercy'
);

insert into content_assets (
  content_id,
  asset_type,
  asset_role,
  order_index,
  title,
  caption,
  alt_text,
  url,
  provider,
  mime_type,
  metadata,
  created_at,
  updated_at
)
select
  c.id,
  'image',
  'slide',
  slide.order_index,
  slide.title,
  slide.caption,
  slide.alt_text,
  slide.url,
  'external',
  'image/svg+xml',
  '{"seed":true}'::jsonb,
  now(),
  now()
from contents c
join (
  values
    (
      0,
      'Jonah runs',
      'The prophet heads away from Nineveh.',
      'Simple placeholder slide for Jonah running away.',
      'https://placehold.co/900x1200/fff8df/111111.svg?text=Jonah+runs'
    ),
    (
      1,
      'A storm rises',
      'The sea interrupts the escape.',
      'Simple placeholder slide for the storm.',
      'https://placehold.co/900x1200/e7e2d8/111111.svg?text=A+storm+rises'
    ),
    (
      2,
      'Mercy waits',
      'God still moves toward the city.',
      'Simple placeholder slide for mercy waiting.',
      'https://placehold.co/900x1200/ffd500/111111.svg?text=Mercy+waits'
    )
) as slide(order_index, title, caption, alt_text, url)
  on c.slug = 'jonah-running-from-mercy';
