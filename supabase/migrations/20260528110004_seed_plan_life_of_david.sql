-- Seed: Life of David (selected chapters)

begin;

delete from public.plan_templates where template_key = 'life_of_david';

insert into public.plan_templates (
  id, template_key, title, subtitle, short_description, description,
  plan_type, testament_scope, difficulty, estimated_minutes, estimated_days, total_chapters,
  primary_book_key, primary_character, is_builtin, is_published, is_archived, featured_rank, browse_visible,
  created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111110005',
  'life_of_david',
  'Life of David',
  '1 Samuel & 2 Samuel highlights',
  'From shepherd boy to king — key chapters in David''s story.',
  'This plan follows David''s calling, trials, kingship, failure, and mercy through selected chapters in 1–2 Samuel. Read in your Bible and mark each chapter complete.',
  'character',
  'old_testament',
  'medium',
  4,
  17,
  17,
  '1_samuel',
  'David',
  true,
  true,
  false,
  7,
  true,
  now(),
  now()
);

insert into public.plan_template_sections (
  id, plan_template_id, section_key, title, description, order_index, created_at, updated_at
) values
  (
    '11111111-1111-4111-8111-111111120501',
    '11111111-1111-4111-8111-111111110005',
    'called',
    'Called',
    'Anointed and tested.',
    0,
    now(),
    now()
  ),
  (
    '11111111-1111-4111-8111-111111120502',
    '11111111-1111-4111-8111-111111110005',
    'before_the_throne',
    'Before the Throne',
    'In Saul''s court.',
    1,
    now(),
    now()
  ),
  (
    '11111111-1111-4111-8111-111111120503',
    '11111111-1111-4111-8111-111111110005',
    'on_the_run',
    'On the Run',
    'Years in the wilderness.',
    2,
    now(),
    now()
  ),
  (
    '11111111-1111-4111-8111-111111120504',
    '11111111-1111-4111-8111-111111110005',
    'king',
    'King',
    'David''s reign begins.',
    3,
    now(),
    now()
  ),
  (
    '11111111-1111-4111-8111-111111120505',
    '11111111-1111-4111-8111-111111110005',
    'mercy_and_repair',
    'Mercy and Repair',
    'Failure, lament, and hope.',
    4,
    now(),
    now()
  );

insert into public.plan_template_items (
  id, section_id, order_index, book_key, start_chapter, end_chapter, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111210501', '11111111-1111-4111-8111-111111120501', 0, '1_samuel', 16, 17, now(), now()),
  ('11111111-1111-4111-8111-111111210502', '11111111-1111-4111-8111-111111120502', 0, '1_samuel', 18, 20, now(), now()),
  ('11111111-1111-4111-8111-111111210503', '11111111-1111-4111-8111-111111120503', 0, '1_samuel', 21, 24, now(), now()),
  ('11111111-1111-4111-8111-111111210504', '11111111-1111-4111-8111-111111120504', 0, '2_samuel', 5, 7, now(), now()),
  ('11111111-1111-4111-8111-111111210505', '11111111-1111-4111-8111-111111120505', 0, '2_samuel', 11, 12, now(), now()),
  ('11111111-1111-4111-8111-111111210506', '11111111-1111-4111-8111-111111120505', 1, '2_samuel', 22, 24, now(), now());

insert into public.plan_tags (id, key, name, type, created_at)
values
  ('21111111-1111-4111-8111-111111110040', 'david', 'David', 'person', now())
on conflict (key) do update set name = excluded.name, type = excluded.type;

insert into public.plan_template_tags (plan_template_id, tag_id)
select '11111111-1111-4111-8111-111111110005', id from public.plan_tags where key = 'david'
on conflict do nothing;

commit;
