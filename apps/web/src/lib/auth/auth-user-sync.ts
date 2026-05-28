import type { User } from '@supabase/supabase-js';

import { sql } from '@/lib/db/postgres';

function displayNameFromUser(user: User): string | null {
  const meta = user.user_metadata ?? {};
  const name = meta.full_name ?? meta.name;
  return typeof name === 'string' ? name : null;
}

function photoUrlFromUser(user: User): string | null {
  const meta = user.user_metadata ?? {};
  const url = meta.avatar_url ?? meta.picture;
  return typeof url === 'string' ? url : null;
}

export async function upsertSupabaseAuthUser(user: User) {
  const email = typeof user.email === 'string' ? user.email : null;
  const displayName = displayNameFromUser(user);
  const photoUrl = photoUrlFromUser(user);
  const emailVerified = Boolean(user.email_confirmed_at);

  const rows = (await sql`
    insert into profiles (
      id,
      email,
      display_name,
      photo_url,
      email_verified,
      last_seen_at,
      updated_at
    )
    values (
      ${user.id},
      ${email},
      ${displayName},
      ${photoUrl},
      ${emailVerified},
      now(),
      now()
    )
    on conflict (id)
    do update set
      email = excluded.email,
      display_name = excluded.display_name,
      photo_url = excluded.photo_url,
      email_verified = excluded.email_verified,
      last_seen_at = now(),
      updated_at = now()
    returning id, email, display_name, photo_url, email_verified, created_at, updated_at, last_seen_at
  `) as Array<Record<string, unknown>>;

  return rows[0];
}
