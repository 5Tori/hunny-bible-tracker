import { NextResponse } from 'next/server';

import { sql } from '@/lib/db/postgres';
import { withApiTiming } from '@/lib/perf/api-timing';

export const GET = withApiTiming('GET /api/health', async (req: Request) => {
  const base = {
    service: 'hunny-bible-tracker-web',
  };
  const checkDb = new URL(req.url).searchParams.get('db') === '1';

  if (!checkDb) {
    return NextResponse.json({
      ok: true,
      ...base,
    });
  }

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
