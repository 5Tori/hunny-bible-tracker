import { NextResponse } from 'next/server';

import { upsertSupabaseAuthUser } from '@/lib/auth/auth-user-sync';
import { verifySupabaseBearerToken } from '@/lib/auth/verify-supabase-token';

export async function POST(req: Request) {
  const auth = req.headers.get('authorization');
  if (!auth?.toLowerCase().startsWith('bearer ')) {
    return NextResponse.json({ error: 'missing_bearer' }, { status: 401 });
  }
  const token = auth.slice(7).trim();
  if (!token) {
    return NextResponse.json({ error: 'missing_token' }, { status: 401 });
  }

  let user;
  try {
    user = await verifySupabaseBearerToken(token);
  } catch {
    return NextResponse.json({ error: 'invalid_token' }, { status: 401 });
  }

  try {
    const profile = await upsertSupabaseAuthUser(user);
    return NextResponse.json({ user: profile });
  } catch {
    return NextResponse.json({ error: 'sync_failed' }, { status: 500 });
  }
}
