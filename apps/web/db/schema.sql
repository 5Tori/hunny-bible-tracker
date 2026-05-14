-- Hunny Bible Tracker server schema.
-- Firebase Auth owns identity. Neon stores app metadata behind Next.js API routes.

create extension if not exists pgcrypto;

create table if not exists auth_users (
  id uuid primary key default gen_random_uuid(),
  firebase_uid text not null unique,
  email text,
  display_name text,
  photo_url text,
  email_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_seen_at timestamptz
);

create table if not exists plan_templates (
  id uuid primary key default gen_random_uuid(),
  template_key text not null unique,
  title text not null,
  subtitle text,
  short_description text,
  description text,
  cover_image_url text,
  cover_image_public_id text,
  plan_type text,
  testament_scope text,
  difficulty text,
  estimated_minutes integer,
  estimated_days integer,
  total_chapters integer,
  primary_book_key text,
  primary_character text,
  is_builtin boolean not null default false,
  is_published boolean not null default false,
  is_archived boolean not null default false,
  featured_rank integer,
  browse_visible boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_plan_templates_published_updated
  on plan_templates (is_published, updated_at desc);

create index if not exists idx_plan_templates_archived_published
  on plan_templates (is_archived, is_published, updated_at desc);

create index if not exists idx_plan_templates_browse_featured
  on plan_templates (browse_visible, featured_rank, updated_at desc);

create table if not exists plan_template_sections (
  id uuid primary key default gen_random_uuid(),
  plan_template_id uuid not null references plan_templates(id) on delete cascade,
  section_key text not null,
  title text not null,
  description text,
  order_index integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (plan_template_id, section_key)
);

create index if not exists idx_plan_template_sections_plan_order
  on plan_template_sections (plan_template_id, order_index);

create table if not exists plan_template_items (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references plan_template_sections(id) on delete cascade,
  order_index integer not null default 0,
  book_key text not null,
  start_chapter integer not null default 1,
  end_chapter integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (start_chapter >= 1),
  check (end_chapter >= start_chapter)
);

create index if not exists idx_plan_template_items_section_order
  on plan_template_items (section_id, order_index);

create table if not exists plan_tags (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  name text not null,
  type text,
  created_at timestamptz not null default now()
);

create table if not exists plan_template_tags (
  plan_template_id uuid not null references plan_templates(id) on delete cascade,
  tag_id uuid not null references plan_tags(id) on delete cascade,
  primary key (plan_template_id, tag_id)
);

create table if not exists media_assets (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  public_id text not null,
  secure_url text not null,
  resource_type text,
  folder text,
  width integer,
  height integer,
  bytes integer,
  format text,
  created_at timestamptz not null default now()
);

create unique index if not exists idx_media_assets_provider_public_id
  on media_assets (provider, public_id);

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
