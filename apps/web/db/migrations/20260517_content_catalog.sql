create table if not exists content_authors (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  display_name text not null,
  bio text,
  avatar_image_url text,
  avatar_image_public_id text,
  website_url text,
  is_verified boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (char_length(slug) between 1 and 120),
  check (char_length(display_name) between 1 and 160)
);

create index if not exists idx_content_authors_active_name
  on content_authors (is_active, display_name);

create index if not exists idx_content_authors_verified_active
  on content_authors (is_verified, is_active, display_name);

create table if not exists contents (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  content_type text not null,
  language text not null default 'en',
  title text not null,
  subtitle text,
  summary text,
  body text,
  cover_image_url text,
  cover_image_public_id text,
  author_id uuid references content_authors(id) on delete set null,
  primary_verse_reference text,
  bible_version text,
  verse_text text,
  duration_seconds integer,
  external_url text,
  is_published boolean not null default false,
  is_archived boolean not null default false,
  published_at timestamptz,
  featured_rank integer,
  browse_visible boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (content_type in ('message', 'video', 'essay', 'webtoon')),
  check (char_length(slug) between 1 and 160),
  check (char_length(title) between 1 and 240),
  check (duration_seconds is null or duration_seconds >= 0),
  check (jsonb_typeof(metadata) = 'object')
);

create index if not exists idx_contents_published_lookup
  on contents (is_published, is_archived, browse_visible, published_at desc);

create index if not exists idx_contents_type_published
  on contents (content_type, is_published, published_at desc);

create index if not exists idx_contents_featured
  on contents (browse_visible, featured_rank, published_at desc);

create index if not exists idx_contents_author
  on contents (author_id, published_at desc);

create table if not exists content_assets (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references contents(id) on delete cascade,
  asset_type text not null,
  asset_role text not null default 'body',
  order_index integer not null default 0,
  title text,
  caption text,
  alt_text text,
  url text not null,
  public_id text,
  provider text,
  mime_type text,
  width integer,
  height integer,
  duration_seconds integer,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (order_index >= 0),
  check (duration_seconds is null or duration_seconds >= 0),
  check (jsonb_typeof(metadata) = 'object')
);

create index if not exists idx_content_assets_content_order
  on content_assets (content_id, asset_role, order_index);

create table if not exists content_tags (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  key text not null,
  name text not null,
  description text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (type, key),
  check (char_length(type) between 1 and 80),
  check (char_length(key) between 1 and 120),
  check (char_length(name) between 1 and 160)
);

create index if not exists idx_content_tags_type_sort
  on content_tags (type, is_active, sort_order, name);

create table if not exists content_tag_links (
  content_id uuid not null references contents(id) on delete cascade,
  tag_id uuid not null references content_tags(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (content_id, tag_id)
);

create index if not exists idx_content_tag_links_tag
  on content_tag_links (tag_id, content_id);

create table if not exists content_plan_links (
  content_id uuid not null references contents(id) on delete cascade,
  plan_template_id uuid not null references plan_templates(id) on delete cascade,
  relationship_type text not null default 'related',
  display_order integer not null default 0,
  cta_label text,
  created_at timestamptz not null default now(),
  primary key (content_id, plan_template_id, relationship_type),
  check (display_order >= 0)
);

create index if not exists idx_content_plan_links_content_order
  on content_plan_links (content_id, display_order);

create index if not exists idx_content_plan_links_plan
  on content_plan_links (plan_template_id, content_id);

alter table today_messages
  add column if not exists content_id uuid references contents(id) on delete set null;

create index if not exists idx_today_messages_content
  on today_messages (content_id);
