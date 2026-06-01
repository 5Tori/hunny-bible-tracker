import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import { getAdminDiscoverContentsList } from '@/lib/discover-content.server';

export async function GET(req: Request) {
  try {
    await requireAdminUser(req);
    const url = new URL(req.url);
    const contentType = url.searchParams.get('content_type')?.trim() || undefined;
    const items = await getAdminDiscoverContentsList(
      contentType ? { contentType } : undefined,
    );
    return NextResponse.json({ items });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Admin discover GET error:', error);
    }
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}
