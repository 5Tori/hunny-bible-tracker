-- Neon application schema.
-- Firebase Auth owns authentication; Neon remains the app data database.
--
-- Current active server scope:
--   - Verify Firebase users through API routes.
--   - Upsert server-side auth user profile rows.
--
-- Reading plan/progress sync tables are intentionally not defined here yet.
-- Before implementing sync, align the server schema with docs/DATA_MODEL.md.

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
