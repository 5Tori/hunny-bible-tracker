-- Reading-data sync foundation.
-- Firebase Auth owns identity; these rows are scoped to auth_users.
-- Mobile keeps writing locally first and uploads client UUIDs through API routes.

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
