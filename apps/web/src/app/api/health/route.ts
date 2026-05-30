import { NextResponse } from 'next/server';

import { withApiTiming } from '@/lib/perf/api-timing';
import { sql } from '@/lib/db/postgres';

export const GET = withApiTiming('GET /api/health', async () => {
  const base = {
    service: 'hunny-bible-tracker-web',
  };

  try {
    const rows = (await sql`select 1 as ok`) as Array<{ ok: number }>;
    return NextResponse.json({
      ok: true,
      db: rows[0]?.ok === 1,
      ...base,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'db_unreachable';
    console.error('Health check DB error:', message);
    return NextResponse.json(
      {
        ok: false,
        db: false,
        error: 'db_unreachable',
        ...base,
      },
      { status: 503 },
    );
  }
});
