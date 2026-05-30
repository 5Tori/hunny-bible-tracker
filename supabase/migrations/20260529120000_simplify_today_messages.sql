-- Simplify today_messages: remove legacy article body, direct plan link, and message fallback.
-- Plans flow through contents.content_plan_links; long copy lives in contents.

drop index if exists public.idx_today_messages_related_plan;

alter table public.today_messages
  drop column if exists article_title,
  drop column if exists article_body,
  drop column if exists primary_related_plan_template_id,
  drop column if exists message;
