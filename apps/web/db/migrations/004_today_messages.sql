-- Today’s Message manager (see docs/ADMIN_DASHBOARD.md and docs/DATA_MODEL.md).
create table if not exists today_messages (
  id uuid primary key default gen_random_uuid(),
  publish_date date not null,
  language text not null default 'en',
  verse_reference text not null,
  verse_text text,
  message text,
  image_url text,
  image_public_id text,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (publish_date, language)
);

create index if not exists idx_today_messages_publish_lang
  on today_messages (language, publish_date desc);

create index if not exists idx_today_messages_published_lookup
  on today_messages (is_published, language, publish_date desc);
