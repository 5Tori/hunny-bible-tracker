-- Browse ordering & visibility (idempotent).
alter table plan_templates add column if not exists featured_rank integer;
alter table plan_templates add column if not exists browse_visible boolean not null default true;

create index if not exists idx_plan_templates_browse_featured
  on plan_templates (browse_visible, featured_rank, updated_at desc);
