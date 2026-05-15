create table if not exists feedback_messages (
  id uuid primary key default gen_random_uuid(),
  category text not null,
  message text not null,
  contact_email text,
  signed_in_email text,
  source text not null default 'mobile_settings',
  app_version text,
  platform text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  check (category in ('bug', 'idea', 'other')),
  check (char_length(message) between 1 and 1000)
);

create index if not exists idx_feedback_messages_created
  on feedback_messages (created_at desc);

create index if not exists idx_feedback_messages_category_created
  on feedback_messages (category, created_at desc);
