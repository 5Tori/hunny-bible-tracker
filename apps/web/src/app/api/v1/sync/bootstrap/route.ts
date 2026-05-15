import { NextResponse } from 'next/server';

import { upsertFirebaseAuthUser } from '@/lib/auth/auth-user-sync';
import { verifyFirebaseBearerToken } from '@/lib/auth/verify-firebase-token';
import { getReadingSyncBootstrap } from '@/lib/sync/reading-sync';

export async function GET(req: Request) {
  const auth = req.headers.get('authorization');
  if (!auth?.toLowerCase().startsWith('bearer ')) {
    return NextResponse.json({ error: 'missing_bearer' }, { status: 401 });
  }
  const token = auth.slice(7).trim();
  if (!token) {
    return NextResponse.json({ error: 'missing_token' }, { status: 401 });
  }

  let decoded;
  try {
    decoded = await verifyFirebaseBearerToken(token);
  } catch {
    return NextResponse.json({ error: 'invalid_token' }, { status: 401 });
  }

  try {
    const user = await upsertFirebaseAuthUser(decoded);
    const authUserId = user?.id;
    if (typeof authUserId !== 'string' || authUserId.length === 0) {
      return NextResponse.json({ error: 'auth_user_sync_failed' }, { status: 500 });
    }

    const result = await getReadingSyncBootstrap(authUserId);
    return NextResponse.json(result);
  } catch (error) {
    console.error('reading sync bootstrap failed', error);
    return NextResponse.json({ error: 'sync_bootstrap_failed' }, { status: 500 });
  }
}
