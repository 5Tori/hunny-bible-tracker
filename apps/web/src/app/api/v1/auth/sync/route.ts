import { NextResponse } from 'next/server';

import { upsertFirebaseAuthUser } from '@/lib/auth/auth-user-sync';
import { verifyFirebaseBearerToken } from '@/lib/auth/verify-firebase-token';

export async function POST(req: Request) {
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
    return NextResponse.json({ user });
  } catch {
    return NextResponse.json({ error: 'sync_failed' }, { status: 500 });
  }
}
