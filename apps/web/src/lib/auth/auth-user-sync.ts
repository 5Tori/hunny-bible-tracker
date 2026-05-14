import type { DecodedIdToken } from 'firebase-admin/auth';

import { sql } from '@/lib/db/neon';

export async function upsertFirebaseAuthUser(token: DecodedIdToken) {
  const email = typeof token.email === 'string' ? token.email : null;
  const name = typeof token.name === 'string' ? token.name : null;
  const picture = typeof token.picture === 'string' ? token.picture : null;

  const rows = (await sql`
    insert into auth_users (
      firebase_uid,
      email,
      display_name,
      photo_url,
      email_verified,
      last_seen_at,
      updated_at
    )
    values (
      ${token.uid},
      ${email},
      ${name},
      ${picture},
      ${Boolean(token.email_verified)},
      now(),
      now()
    )
    on conflict (firebase_uid)
    do update set
      email = excluded.email,
      display_name = excluded.display_name,
      photo_url = excluded.photo_url,
      email_verified = excluded.email_verified,
      last_seen_at = now(),
      updated_at = now()
    returning id, firebase_uid, email, display_name, photo_url, email_verified, created_at, updated_at, last_seen_at
  `) as Array<Record<string, unknown>>;
  return rows[0];
}
