import type { User } from '@supabase/supabase-js';

import { getSupabaseAdmin } from '@/lib/supabase/admin';

export async function verifySupabaseBearerToken(token: string): Promise<User> {
  const { data, error } = await getSupabaseAdmin().auth.getUser(token);
  if (error || !data.user) {
    throw error ?? new Error('Invalid Supabase access token');
  }
  return data.user;
}
