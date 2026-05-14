-- Run against existing Neon DBs (idempotent).
alter table plan_templates add column if not exists is_archived boolean not null default false;

create index if not exists idx_plan_templates_archived_published
  on plan_templates (is_archived, is_published, updated_at desc);
