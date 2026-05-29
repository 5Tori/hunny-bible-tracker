-- Seed: Psalms for Anxiety

begin;

delete from public.plan_templates where template_key = 'psalms_for_anxiety';

insert into public.plan_templates (
  id, template_key, title, subtitle, short_description, description,
  plan_type, testament_scope, difficulty, estimated_minutes, estimated_days, total_chapters,
  primary_book_key, primary_character, is_builtin, is_published, is_archived, featured_rank, browse_visible,
  created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111110004',
  'psalms_for_anxiety',
  'Psalms for Anxiety',
  'Selected Psalms',
  'Short psalms for worry, fear, and restless days.',
  'When life feels loud, these psalms offer honest words and steady hope. Read one chapter at a time and return whenever you need a quiet pause with God.',
  'devotional',
  'old_testament',
  'easy',
  4,
  12,
  12,
  'psalms',
  null,
  true,
  true,
  false,
  5,
  true,
  now(),
  now()
);

insert into public.plan_template_sections (
  id, plan_template_id, section_key, title, description, order_index, created_at, updated_at
) values
  (
    '11111111-1111-4111-8111-111111120401',
    '11111111-1111-4111-8111-111111110004',
    'comfort_and_rest',
    'Comfort and Rest',
    'Psalms of peace and refuge.',
    0,
    now(),
    now()
  ),
  (
    '11111111-1111-4111-8111-111111120402',
    '11111111-1111-4111-8111-111111110004',
    'honest_prayer',
    'Honest Prayer',
    'Psalms for pressure and fear.',
    1,
    now(),
    now()
  );

insert into public.plan_template_items (
  id, section_id, order_index, book_key, start_chapter, end_chapter, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111210401', '11111111-1111-4111-8111-111111120401', 0, 'psalms', 23, 23, now(), now()),
  ('11111111-1111-4111-8111-111111210402', '11111111-1111-4111-8111-111111120401', 1, 'psalms', 27, 27, now(), now()),
  ('11111111-1111-4111-8111-111111210403', '11111111-1111-4111-8111-111111120401', 2, 'psalms', 34, 34, now(), now()),
  ('11111111-1111-4111-8111-111111210404', '11111111-1111-4111-8111-111111120401', 3, 'psalms', 46, 46, now(), now()),
  ('11111111-1111-4111-8111-111111210405', '11111111-1111-4111-8111-111111120401', 4, 'psalms', 121, 121, now(), now()),
  ('11111111-1111-4111-8111-111111210406', '11111111-1111-4111-8111-111111120401', 5, 'psalms', 131, 131, now(), now()),
  ('11111111-1111-4111-8111-111111210407', '11111111-1111-4111-8111-111111120402', 0, 'psalms', 4, 4, now(), now()),
  ('11111111-1111-4111-8111-111111210408', '11111111-1111-4111-8111-111111120402', 1, 'psalms', 55, 55, now(), now()),
  ('11111111-1111-4111-8111-111111210409', '11111111-1111-4111-8111-111111120402', 2, 'psalms', 56, 56, now(), now()),
  ('11111111-1111-4111-8111-111111210410', '11111111-1111-4111-8111-111111120402', 3, 'psalms', 61, 61, now(), now()),
  ('11111111-1111-4111-8111-111111210411', '11111111-1111-4111-8111-111111120402', 4, 'psalms', 91, 91, now(), now()),
  ('11111111-1111-4111-8111-111111210412', '11111111-1111-4111-8111-111111120402', 5, 'psalms', 139, 139, now(), now());

insert into public.plan_tags (id, key, name, type, created_at)
values
  ('21111111-1111-4111-8111-111111110030', 'anxiety', 'Anxiety', 'situation', now()),
  ('21111111-1111-4111-8111-111111110031', 'peace', 'Peace', 'theme', now())
on conflict (key) do update set name = excluded.name, type = excluded.type;

insert into public.plan_template_tags (plan_template_id, tag_id)
select '11111111-1111-4111-8111-111111110004', id from public.plan_tags where key in ('anxiety', 'peace')
on conflict do nothing;

commit;
