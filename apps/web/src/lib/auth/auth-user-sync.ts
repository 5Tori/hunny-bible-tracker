import type { User } from '@supabase/supabase-js';

import { getSupabaseAdmin } from '@/lib/supabase/admin';

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
  const now = new Date().toISOString();

  const { data, error } = await getSupabaseAdmin()
    .from('profiles')
    .upsert(
      {
        id: user.id,
        email,
        display_name: displayName,
        photo_url: photoUrl,
        email_verified: emailVerified,
        last_seen_at: now,
        updated_at: now,
      },
      { onConflict: 'id' },
    )
    .select(
      'id, email, display_name, photo_url, email_verified, created_at, updated_at, last_seen_at',
    )
    .single();

  if (error) {
    throw error;
  }

  return data;
}
