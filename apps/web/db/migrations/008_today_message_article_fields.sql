alter table today_messages
  add column if not exists hint_title text,
  add column if not exists hint_summary text,
  add column if not exists article_title text,
  add column if not exists article_body text,
  add column if not exists primary_related_plan_template_id uuid references plan_templates(id);

create index if not exists idx_today_messages_related_plan
  on today_messages (primary_related_plan_template_id);
