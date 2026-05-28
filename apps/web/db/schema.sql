-- Hunny Bible Tracker server schema (Supabase).
-- Supabase Auth owns identity (auth.users). public.profiles stores app metadata behind Next.js API routes.
-- Prefer applying supabase/migrations/20260528000000_baseline.sql via Supabase CLI or dashboard.

create extension if not exists pgcrypto with schema extensions;

create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
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

create table if not exists user_reading_backups (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references profiles(id) on delete cascade,
  backup_version integer not null,
  payload_jsonb jsonb not null,
  payload_hash text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (auth_user_id),
  check (backup_version >= 1),
  check (jsonb_typeof(payload_jsonb) = 'object')
);

create index if not exists idx_user_reading_backups_updated
  on user_reading_backups (updated_at desc);

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
  check (content_type in ('message', 'video', 'essay', 'cartoon')),
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

create table if not exists today_messages (
  id uuid primary key default gen_random_uuid(),
  content_id uuid references contents(id) on delete set null,
  publish_date date not null,
  language text not null default 'en',
  verse_reference text not null,
  bible_version text,
  verse_text text,
  message text,
  image_url text,
  image_public_id text,
  share_image_url text,
  share_image_public_id text,
  hint_title text,
  hint_summary text,
  article_title text,
  article_body text,
  primary_related_plan_template_id uuid references plan_templates(id),
  is_published boolean not null default false,
  heart_count integer not null default 0,
  share_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (publish_date, language)
);

create index if not exists idx_today_messages_publish_lang
  on today_messages (language, publish_date desc);

create index if not exists idx_today_messages_published_lookup
  on today_messages (is_published, language, publish_date desc);

create index if not exists idx_today_messages_engagement
  on today_messages (heart_count desc, share_count desc);

create index if not exists idx_today_messages_related_plan
  on today_messages (primary_related_plan_template_id);

create index if not exists idx_today_messages_content
  on today_messages (content_id);

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
