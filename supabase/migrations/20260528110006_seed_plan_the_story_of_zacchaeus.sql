-- Seed: The Story of Zacchaeus (Luke 19)

begin;

delete from public.plan_templates where template_key = 'the_story_of_zacchaeus';

insert into public.plan_templates (
  id, template_key, title, subtitle, short_description, description,
  plan_type, testament_scope, difficulty, estimated_minutes, estimated_days, total_chapters,
  primary_book_key, primary_character, is_builtin, is_published, is_archived, featured_rank, browse_visible,
  created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111110007',
  'the_story_of_zacchaeus',
  'The Story of Zacchaeus',
  'Luke 19',
  'One chapter about seeing Jesus — and being seen by him.',
  'Zacchaeus climbs a tree to catch a glimpse of Jesus and receives far more than he expected. Read Luke 19 in your Bible and mark the chapter complete.',
  'story',
  'new_testament',
  'easy',
  6,
  1,
  1,
  'luke',
  'Zacchaeus',
  true,
  true,
  false,
  3,
  true,
  now(),
  now()
);

insert into public.plan_template_sections (
  id, plan_template_id, section_key, title, description, order_index, created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111120701',
  '11111111-1111-4111-8111-111111110007',
  'main',
  'Zacchaeus',
  'Luke 19.',
  0,
  now(),
  now()
);

insert into public.plan_template_items (
  id, section_id, order_index, book_key, start_chapter, end_chapter, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111210701', '11111111-1111-4111-8111-111111120701', 0, 'luke', 19, 19, now(), now());

insert into public.plan_tags (id, key, name, type, created_at)
values
  ('21111111-1111-4111-8111-111111110070', 'jesus', 'Jesus', 'person', now())
on conflict (key) do update set name = excluded.name, type = excluded.type;

insert into public.plan_template_tags (plan_template_id, tag_id)
select '11111111-1111-4111-8111-111111110007', id from public.plan_tags where key = 'jesus'
on conflict do nothing;

commit;
