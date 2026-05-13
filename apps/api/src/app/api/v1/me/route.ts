import { NextResponse } from 'next/server';

import { verifyNeonAuthBearerToken } from '@/lib/auth/verify-neon-jwt';

export async function GET(req: Request) {
  const auth = req.headers.get('authorization');
  if (!auth?.toLowerCase().startsWith('bearer ')) {
    return NextResponse.json({ error: 'missing_bearer' }, { status: 401 });
  }
  const token = auth.slice(7).trim();
  if (!token) {
    return NextResponse.json({ error: 'missing_token' }, { status: 401 });
  }
  try {
    const payload = await verifyNeonAuthBearerToken(token);
    return NextResponse.json({
      user: {
        sub: String(payload.sub ?? ''),
        email: typeof payload.email === 'string' ? payload.email : null,
        name: typeof payload.name === 'string' ? payload.name : null,
      },
    });
  } catch {
    return NextResponse.json({ error: 'invalid_token' }, { status: 401 });
  }
}
