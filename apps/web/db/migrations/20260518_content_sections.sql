create table if not exists content_sections (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references contents(id) on delete cascade,
  order_index integer not null default 0,
  title text,
  body text,
  image_url text,
  image_public_id text,
  image_alt_text text,
  image_caption text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (order_index >= 0),
  check (jsonb_typeof(metadata) = 'object')
);

create index if not exists idx_content_sections_content_order
  on content_sections (content_id, order_index);
