-- Seed: The Story of Jonah (template_key `jonah` matches content_test_seed.sql links)

begin;

delete from public.plan_templates where template_key = 'jonah';

insert into public.plan_templates (
  id, template_key, title, subtitle, short_description, description,
  plan_type, testament_scope, difficulty, estimated_minutes, estimated_days, total_chapters,
  primary_book_key, primary_character, is_builtin, is_published, is_archived, featured_rank, browse_visible,
  created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111110006',
  'jonah',
  'The Story of Jonah',
  'Jonah 1–4',
  'A short story about running from mercy — and being pursued by it.',
  'Jonah is only four chapters, but it opens a surprising window into God''s heart for people we would rather avoid. Read one chapter at a time in your Bible.',
  'story',
  'old_testament',
  'easy',
  2,
  4,
  4,
  'jonah',
  'Jonah',
  true,
  true,
  false,
  2,
  true,
  now(),
  now()
);

insert into public.plan_template_sections (
  id, plan_template_id, section_key, title, description, order_index, created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111120601',
  '11111111-1111-4111-8111-111111110006',
  'main',
  'Jonah''s Story',
  'The book of Jonah.',
  0,
  now(),
  now()
);

insert into public.plan_template_items (
  id, section_id, order_index, book_key, start_chapter, end_chapter, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111210601', '11111111-1111-4111-8111-111111120601', 0, 'jonah', 1, 4, now(), now());

insert into public.plan_tags (id, key, name, type, created_at)
values
  ('21111111-1111-4111-8111-111111110050', 'jonah', 'Jonah', 'person', now()),
  ('21111111-1111-4111-8111-111111110051', 'mercy', 'Mercy', 'theme', now())
on conflict (key) do update set name = excluded.name, type = excluded.type;

insert into public.plan_template_tags (plan_template_id, tag_id)
select '11111111-1111-4111-8111-111111110006', id from public.plan_tags where key in ('jonah', 'mercy')
on conflict do nothing;

commit;
