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

create table if not exists user_reading_plans (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references auth_users(id) on delete cascade,
  client_id text not null,
  client_local_user_id text,
  template_id uuid not null references plan_templates(id),
  title text not null,
  status text not null default 'active',
  subscribed_at timestamptz not null,
  started_at timestamptz,
  completed_at timestamptz,
  archived_at timestamptz,
  is_active boolean not null default true,
  last_opened_section_id text,
  last_opened_book_key text,
  client_created_at timestamptz,
  client_updated_at timestamptz,
  client_revision integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (auth_user_id, client_id)
);

create index if not exists idx_user_reading_plans_auth_updated
  on user_reading_plans (auth_user_id, updated_at desc);

create index if not exists idx_user_reading_plans_auth_status
  on user_reading_plans (auth_user_id, status, is_active);

create table if not exists user_plan_chapters (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references auth_users(id) on delete cascade,
  user_reading_plan_id uuid not null references user_reading_plans(id) on delete cascade,
  client_id text not null,
  client_user_plan_id text not null,
  section_id text not null,
  book_key text not null,
  chapter_number integer not null,
  order_index integer not null,
  client_created_at timestamptz,
  client_revision integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (auth_user_id, client_id),
  unique (user_reading_plan_id, book_key, chapter_number),
  check (chapter_number >= 1)
);

create index if not exists idx_user_plan_chapters_plan_order
  on user_plan_chapters (user_reading_plan_id, order_index);

create table if not exists chapter_progress_entries (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references auth_users(id) on delete cascade,
  user_reading_plan_id uuid not null references user_reading_plans(id) on delete cascade,
  client_id text not null,
  client_user_plan_id text not null,
  book_key text not null,
  chapter_number integer not null,
  is_completed boolean not null default false,
  completed_at timestamptz,
  client_updated_at timestamptz not null,
  client_revision integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (auth_user_id, client_id),
  unique (auth_user_id, user_reading_plan_id, book_key, chapter_number),
  check (chapter_number >= 1)
);

create index if not exists idx_chapter_progress_plan_completed
  on chapter_progress_entries (user_reading_plan_id, is_completed);

create table if not exists reading_activities (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references auth_users(id) on delete cascade,
  user_reading_plan_id uuid not null references user_reading_plans(id) on delete cascade,
  client_id text not null,
  client_user_plan_id text not null,
  book_key text not null,
  chapter_number integer not null,
  action text not null,
  activity_date date not null,
  timezone text not null,
  happened_at timestamptz not null,
  client_created_at timestamptz,
  client_revision integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (auth_user_id, client_id),
  unique (
    auth_user_id,
    user_reading_plan_id,
    book_key,
    chapter_number,
    activity_date,
    action
  ),
  check (chapter_number >= 1)
);

create index if not exists idx_reading_activities_auth_date
  on reading_activities (auth_user_id, activity_date desc);

create table if not exists plan_completion_events (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references auth_users(id) on delete cascade,
  user_reading_plan_id uuid not null references user_reading_plans(id) on delete cascade,
  client_id text not null,
  client_user_plan_id text not null,
  template_id uuid not null references plan_templates(id),
  completion_number integer not null,
  completed_at timestamptz not null,
  client_created_at timestamptz,
  client_revision integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (auth_user_id, client_id),
  unique (user_reading_plan_id),
  check (completion_number >= 1)
);

create index if not exists idx_plan_completion_events_auth_completed
  on plan_completion_events (auth_user_id, completed_at desc);

create table if not exists sync_states (
  auth_user_id uuid primary key references auth_users(id) on delete cascade,
  last_push_at timestamptz,
  last_bootstrap_at timestamptz,
  last_client_revision integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
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
  bible_version text,
  verse_text text,
  message text,
  image_url text,
  image_public_id text,
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
