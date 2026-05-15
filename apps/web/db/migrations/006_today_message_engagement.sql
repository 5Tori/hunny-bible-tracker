alter table today_messages
  add column if not exists heart_count integer not null default 0,
  add column if not exists share_count integer not null default 0;

create index if not exists idx_today_messages_engagement
  on today_messages (heart_count desc, share_count desc);
