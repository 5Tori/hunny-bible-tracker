import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import { getAdminContentsList } from '@/lib/content';

export async function GET(req: Request) {
  try {
    await requireAdminUser(req);
    const messages = await getAdminContentsList({ contentType: 'message' });
    return NextResponse.json({ messages });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Admin messages GET error:', error);
    }
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}
