import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import { getAdminOverview } from '@/lib/admin/overview';

export async function GET(req: Request) {
  try {
    await requireAdminUser(req);
    const overview = await getAdminOverview();
    return NextResponse.json({ overview });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Admin overview GET error:', error);
    }
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}
