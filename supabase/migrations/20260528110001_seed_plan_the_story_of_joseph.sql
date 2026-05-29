-- Seed: The Story of Joseph (Genesis 37–50)

begin;

delete from public.plan_templates where template_key = 'the_story_of_joseph';

insert into public.plan_templates (
  id, template_key, title, subtitle, short_description, description,
  plan_type, testament_scope, difficulty, estimated_minutes, estimated_days, total_chapters,
  primary_book_key, primary_character, is_builtin, is_published, is_archived, featured_rank, browse_visible,
  created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111110002',
  'the_story_of_joseph',
  'The Story of Joseph',
  'Genesis 37–50',
  'A short story of dreams, exile, and reconciliation.',
  'Follow Joseph from the pit to the palace. Read one chapter at a time in your own Bible and mark your progress as the story unfolds.',
  'story',
  'old_testament',
  'easy',
  5,
  14,
  14,
  'genesis',
  'Joseph',
  true,
  true,
  false,
  1,
  true,
  now(),
  now()
);

insert into public.plan_template_sections (
  id, plan_template_id, section_key, title, description, order_index, created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111120002',
  '11111111-1111-4111-8111-111111110002',
  'main',
  'Joseph''s Story',
  'Genesis 37 through 50.',
  0,
  now(),
  now()
);

insert into public.plan_template_items (
  id, section_id, order_index, book_key, start_chapter, end_chapter, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111210002', '11111111-1111-4111-8111-111111120002', 0, 'genesis', 37, 50, now(), now());

insert into public.plan_tags (id, key, name, type, created_at)
values
  ('21111111-1111-4111-8111-111111110010', 'joseph', 'Joseph', 'person', now()),
  ('21111111-1111-4111-8111-111111110011', 'forgiveness', 'Forgiveness', 'theme', now())
on conflict (key) do update set name = excluded.name, type = excluded.type;

insert into public.plan_template_tags (plan_template_id, tag_id)
select '11111111-1111-4111-8111-111111110002', id from public.plan_tags where key in ('joseph', 'forgiveness')
on conflict do nothing;

commit;
