-- Seed: Samuel's Early Life (1 Samuel 1–3)

begin;

delete from public.plan_templates where template_key = 'samuels_early_life';

insert into public.plan_templates (
  id, template_key, title, subtitle, short_description, description,
  plan_type, testament_scope, difficulty, estimated_minutes, estimated_days, total_chapters,
  primary_book_key, primary_character, is_builtin, is_published, is_archived, featured_rank, browse_visible,
  created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111110008',
  'samuels_early_life',
  'Samuel''s Childhood',
  '1 Samuel 1–3',
  'Listening, calling, and God''s quiet faithfulness.',
  'Before Samuel became a prophet, he was a boy who learned to hear God in a noisy world. Read three short chapters at your own pace.',
  'story',
  'old_testament',
  'easy',
  4,
  3,
  3,
  '1_samuel',
  'Samuel',
  true,
  true,
  false,
  4,
  true,
  now(),
  now()
);

insert into public.plan_template_sections (
  id, plan_template_id, section_key, title, description, order_index, created_at, updated_at
) values (
  '11111111-1111-4111-8111-111111120801',
  '11111111-1111-4111-8111-111111110008',
  'main',
  'Samuel''s Early Years',
  '1 Samuel 1–3.',
  0,
  now(),
  now()
);

insert into public.plan_template_items (
  id, section_id, order_index, book_key, start_chapter, end_chapter, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111210801', '11111111-1111-4111-8111-111111120801', 0, '1_samuel', 1, 3, now(), now());

insert into public.plan_tags (id, key, name, type, created_at)
values
  ('21111111-1111-4111-8111-111111110060', 'samuel', 'Samuel', 'person', now())
on conflict (key) do update set name = excluded.name, type = excluded.type;

insert into public.plan_template_tags (plan_template_id, tag_id)
select '11111111-1111-4111-8111-111111110008', id from public.plan_tags where key = 'samuel'
on conflict do nothing;

commit;
