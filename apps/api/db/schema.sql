-- Future Neon schema draft. The mobile app v0.1 is local-first and does not require this yet.

create table if not exists user_reading_plans (
  id uuid primary key,
  auth_user_id text not null,
  template_key text not null,
  title text not null,
  is_active boolean not null default true,
  last_opened_book_key text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_status text not null default 'synced'
);

create table if not exists plan_scope_chapters (
  id uuid primary key,
  plan_id uuid not null references user_reading_plans(id),
  book_key text not null,
  chapter_number int not null,
  order_index int not null,
  created_at timestamptz not null,
  unique(plan_id, book_key, chapter_number)
);

create table if not exists chapter_progress (
  id uuid primary key,
  auth_user_id text not null,
  plan_id uuid not null references user_reading_plans(id),
  book_key text not null,
  chapter_number int not null,
  is_completed boolean not null default false,
  completed_at timestamptz,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  unique(plan_id, book_key, chapter_number)
);

create table if not exists reading_activity (
  id uuid primary key,
  auth_user_id text not null,
  plan_id uuid not null references user_reading_plans(id),
  book_key text not null,
  chapter_number int not null,
  action text not null,
  activity_date date not null,
  timezone text not null,
  happened_at timestamptz not null,
  created_at timestamptz not null
);
