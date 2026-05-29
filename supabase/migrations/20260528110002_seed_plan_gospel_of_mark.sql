-- Seed: Gospel of Mark

begin;

delete from public.plan_templates where template_key = 'gospel_of_mark';

insert into public.plan_templates (
  id, template_key, title, subtitle, short_description, description,
  plan_type, testament_scope, difficulty, estimated_minutes, estimated_days, total_chapters,
  primary_book_key, primary_character, is_builtin, is_published, is_archived, featured_rank, browse_visible,
  created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111110003',
  'gospel_of_mark',
  'Gospel of Mark',
  'Mark 1–16',
  'Meet Jesus through the fast-moving Gospel of Mark.',
  'Mark is a clear entry point into the New Testament. Read chapter by chapter and track your progress through Jesus'' ministry, teaching, and the road to the cross.',
  'guided_reading',
  'new_testament',
  'easy',
  6,
  16,
  16,
  'mark',
  'Jesus',
  true,
  true,
  false,
  6,
  true,
  now(),
  now()
);

insert into public.plan_template_sections (
  id, plan_template_id, section_key, title, description, order_index, created_at, updated_at
) values
  (
    '11111111-1111-4111-8111-111111120301',
    '11111111-1111-4111-8111-111111110003',
    'ministry_in_galilee',
    'Ministry in Galilee',
    'Mark 1–8',
    0,
    now(),
    now()
  ),
  (
    '11111111-1111-4111-8111-111111120302',
    '11111111-1111-4111-8111-111111110003',
    'path_to_jerusalem',
    'The Path to Jerusalem',
    'Mark 9–16',
    1,
    now(),
    now()
  );

insert into public.plan_template_items (
  id, section_id, order_index, book_key, start_chapter, end_chapter, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111210301', '11111111-1111-4111-8111-111111120301', 0, 'mark', 1, 8, now(), now()),
  ('11111111-1111-4111-8111-111111210302', '11111111-1111-4111-8111-111111120302', 0, 'mark', 9, 16, now(), now());

insert into public.plan_tags (id, key, name, type, created_at)
values
  ('21111111-1111-4111-8111-111111110020', 'gospel', 'Gospel', 'theme', now()),
  ('21111111-1111-4111-8111-111111110021', 'mark', 'Mark', 'book', now())
on conflict (key) do update set name = excluded.name, type = excluded.type;

insert into public.plan_template_tags (plan_template_id, tag_id)
select '11111111-1111-4111-8111-111111110003', id from public.plan_tags where key in ('gospel', 'mark')
on conflict do nothing;

commit;
