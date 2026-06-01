-- Discover content seed (6 items: video / essay / cartoon × 2).
-- Message cards live in message_cards_pilot_seed.sql — not here.
-- Run after plan catalog migrations and message taxonomy (optional tags).

insert into content_authors (slug, display_name, bio, is_verified, is_active, created_at, updated_at)
values (
  'hunny-team',
  'Hunny Team',
  'Short, approachable Bible reading guides from Hunny.',
  true,
  true,
  now(),
  now()
)
on conflict (slug) do update set
  display_name = excluded.display_name,
  bio = excluded.bio,
  is_verified = excluded.is_verified,
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
  duration_seconds,
  external_url,
  cover_image_url,
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
  null,
  author.id,
  seed.duration_seconds,
  seed.external_url,
  seed.cover_image_url,
  true,
  false,
  now(),
  seed.featured_rank,
  true,
  '{"seed":true}'::jsonb,
  now(),
  now()
from (
  values
    (
      'sabbath-rest-explained',
      'video',
      'What Sabbath rest actually means',
      'A short teaching on rhythm and trust',
      'Why weekly rest is not laziness but trust — and how Jesus reframes the Sabbath for weary hearts.',
      612,
      'https://www.youtube.com/watch?v=7Y06NGtuOXc',
      '/plans/covers/bible.webp',
      1
    ),
    (
      'lectio-divina-basics',
      'video',
      'Lectio Divina in ten minutes',
      'Read, reflect, respond, rest',
      'A guided introduction to slow Scripture reading — video walkthrough plus a printable rhythm you can repeat daily.',
      540,
      'https://www.youtube.com/watch?v=9TEvW9y0n5s',
      '/messages/sample-card.webp',
      2
    ),
    (
      'psalms-for-anxious-nights',
      'essay',
      'When worry keeps you awake',
      'Reading Psalms at night',
      'Night anxiety is common. These three postures — breathe, pray, receive — open space for God''s comfort without fixing everything at once.',
      null,
      null,
      '/plans/covers/ot.webp',
      3
    ),
    (
      'jonah-reflection',
      'essay',
      'Running from mercy',
      'Notes on Jonah 1–2',
      'Jonah''s story is not only about a fish. It is about how hard it is to accept that God''s compassion might include people we would avoid.',
      null,
      null,
      '/plans/covers/nt.webp',
      4
    ),
    (
      'parable-of-sower-cartoon',
      'cartoon',
      'The sower''s four soils',
      'Visual walkthrough',
      'A slide gallery of the parable in Mark 4 — swipe through each soil and one question per panel.',
      null,
      null,
      '/plans/covers/bible.webp',
      5
    ),
    (
      'david-and-goliath-slides',
      'cartoon',
      'David & Goliath — five frames',
      'Courage is not the absence of fear',
      'A simple five-panel retelling for families or small groups, with discussion prompts in the captions.',
      null,
      null,
      '/messages/sample-card.webp',
      6
    )
) as seed(
  slug,
  content_type,
  title,
  subtitle,
  summary,
  duration_seconds,
  external_url,
  cover_image_url,
  featured_rank
)
join content_authors author on author.slug = 'hunny-team'
on conflict (slug) do update set
  content_type = excluded.content_type,
  title = excluded.title,
  subtitle = excluded.subtitle,
  summary = excluded.summary,
  body = null,
  author_id = excluded.author_id,
  duration_seconds = excluded.duration_seconds,
  external_url = excluded.external_url,
  cover_image_url = excluded.cover_image_url,
  is_published = true,
  is_archived = false,
  published_at = coalesce(contents.published_at, now()),
  featured_rank = excluded.featured_rank,
  browse_visible = true,
  metadata = excluded.metadata,
  updated_at = now();

-- Sections (block_type in metadata)
delete from content_sections
where content_id in (
  select id from contents
  where slug in (
    'sabbath-rest-explained',
    'lectio-divina-basics',
    'psalms-for-anxious-nights',
    'jonah-reflection',
    'parable-of-sower-cartoon',
    'david-and-goliath-slides'
  )
);

insert into content_sections (
  content_id,
  order_index,
  title,
  body,
  image_url,
  image_alt_text,
  image_caption,
  metadata,
  created_at,
  updated_at
)
select c.id, s.order_index, s.title, s.body, s.image_url, s.image_alt_text, s.image_caption,
  jsonb_build_object('block_type', s.block_type, 'seed', true),
  now(), now()
from contents c
join (
  values
    ('sabbath-rest-explained', 0, 'paragraph', null,
      'In this session we look at Exodus 20, Mark 2, and one practical habit for protecting a weekly pause.' || E'\n\n' ||
      'You can read along with the Psalms for Anxious Nights plan if you want a gentle next step.',
      null, null, null),
    ('sabbath-rest-explained', 1, 'heading', 'Three questions to journal', null, null, null, null),
    ('sabbath-rest-explained', 2, 'paragraph', null,
      'Where am I striving beyond my limits?' || E'\n\n' ||
      'What would I stop if I believed God is enough?' || E'\n\n' ||
      'Who needs my presence more than my productivity this week?',
      null, null, null),
    ('sabbath-rest-explained', 3, 'image', null, null,
      '/messages/backgrounds/message-card-bg-honey.webp',
      'Warm abstract background', 'Pause before you plan the week.'),
    ('lectio-divina-basics', 0, 'paragraph', null,
      'We practice four movements with Psalm 23. No special tools required; just your Bible and five quiet minutes.',
      null, null, null),
    ('psalms-for-anxious-nights', 0, 'paragraph', null,
      'The Psalms do not pretend life is easy. They give us words when ours run out.' || E'\n\n' ||
      'Start with one short psalm. Read it twice. Notice a phrase that catches your attention. Tell God why it matters tonight.',
      null, null, null),
    ('psalms-for-anxious-nights', 1, 'heading', 'Psalm 4 — Lie down in peace', null, null, null, null),
    ('psalms-for-anxious-nights', 2, 'paragraph', null,
      'David ends the psalm with “You alone, O Lord, make me dwell in safety.” That is not a command to feel calm; it is an invitation to entrust the night.',
      null, null, null),
    ('psalms-for-anxious-nights', 3, 'image', null, null,
      '/messages/backgrounds/message-card-bg-space.webp',
      'Calm night sky texture', null),
    ('psalms-for-anxious-nights', 4, 'heading', 'A two-minute night prayer', null, null, null, null),
    ('psalms-for-anxious-nights', 5, 'paragraph', null,
      'Lord, I bring you what I cannot solve before morning. Guard my mind while I sleep. Amen.',
      null, null, null),
    ('jonah-reflection', 0, 'paragraph', null,
      'Jonah flees, sleeps, and is thrown into chaos. God saves him anyway.' || E'\n\n' ||
      'The plant that shades him — and withers — shows how quickly we attach to comfort instead of mission.',
      null, null, null),
    ('jonah-reflection', 1, 'heading', 'Chapter 1 — The storm', null, null, null, null),
    ('jonah-reflection', 2, 'paragraph', null,
      'Sailors pray; Jonah admits fault. Sometimes confession comes only when our escape routes fail.',
      null, null, null),
    ('parable-of-sower-cartoon', 0, 'paragraph', null,
      'Use the arrows to move panel by panel. After the gallery, pick one soil that feels most like your season and talk to God about it.',
      null, null, null),
    ('david-and-goliath-slides', 0, 'paragraph', null,
      'After the slides, ask: What giant are you facing? Whose armor are you tempted to wear?',
      null, null, null)
) as s(slug, order_index, block_type, title, body, image_url, image_alt_text, image_caption)
  on c.slug = s.slug;

-- Cartoon slides
delete from content_assets
where content_id in (
  select id from contents
  where slug in ('parable-of-sower-cartoon', 'david-and-goliath-slides')
);

insert into content_assets (
  content_id,
  asset_type,
  asset_role,
  order_index,
  caption,
  alt_text,
  url,
  mime_type,
  metadata,
  created_at,
  updated_at
)
select c.id, 'image', 'slide', s.order_index, s.caption, s.alt_text, s.url, 'image/webp',
  '{"seed":true}'::jsonb, now(), now()
from contents c
join (
  values
    ('parable-of-sower-cartoon', 0, 'The sower goes out to sow.', 'Sower scattering seed', '/plans/covers/bible.webp'),
    ('parable-of-sower-cartoon', 1, 'Path — seed snatched away.', 'Hard path soil', '/plans/covers/ot.webp'),
    ('parable-of-sower-cartoon', 2, 'Rocky ground — quick sprout, shallow roots.', 'Rocky soil', '/plans/covers/nt.webp'),
    ('parable-of-sower-cartoon', 3, 'Good soil — fruit that lasts.', 'Healthy soil', '/messages/backgrounds/message-card-bg-honey.webp'),
    ('david-and-goliath-slides', 0, '1. The army freezes. Goliath taunts daily.', 'Army and giant', '/messages/sample-card.webp'),
    ('david-and-goliath-slides', 1, '2. David arrives with bread for his brothers.', 'David arrives', '/plans/covers/ot.webp'),
    ('david-and-goliath-slides', 2, '3. “The battle is the Lord’s.”', 'David speaks', '/plans/covers/bible.webp'),
    ('david-and-goliath-slides', 3, '4. One stone. One faithful step.', 'Stone and sling', '/messages/backgrounds/message-card-bg-space.webp'),
    ('david-and-goliath-slides', 4, '5. God saves — not our bravado alone.', 'Victory', '/messages/backgrounds/message-card-bg-honey.webp')
) as s(slug, order_index, caption, alt_text, url)
  on c.slug = s.slug;

-- Related plans
insert into content_plan_links (
  content_id,
  plan_template_id,
  relationship_type,
  display_order,
  cta_label,
  created_at
)
select c.id, p.id, 'related', 0, map.cta_label, now()
from contents c
join (
  values
    ('sabbath-rest-explained', 'psalms_for_anxiety', 'Try the Psalms plan'),
    ('lectio-divina-basics', 'bible_in_a_year', 'Bible in a Year'),
    ('psalms-for-anxious-nights', 'psalms_for_anxiety', null),
    ('jonah-reflection', 'jonah', 'Read Jonah in 4 days'),
    ('parable-of-sower-cartoon', 'gospel_of_mark', null),
    ('david-and-goliath-slides', 'life_of_david', 'Life of David plan')
) as map(content_slug, template_key, cta_label) on map.content_slug = c.slug
join plan_templates p on p.template_key = map.template_key
on conflict (content_id, plan_template_id, relationship_type) do update set
  cta_label = excluded.cta_label,
  display_order = excluded.display_order;
