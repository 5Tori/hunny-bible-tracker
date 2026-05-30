import { NextResponse } from 'next/server';

import { withApiTiming } from '@/lib/perf/api-timing';
import { getPublishedPlans, getPublishedPlansWithRelations, parsePublishedPlanSort } from '@/lib/plans';

export const GET = withApiTiming('GET /api/v1/plans', async (req: Request) => {
  const { searchParams } = new URL(req.url);
  const sort = parsePublishedPlanSort(searchParams.get('sort'));
  const detail = searchParams.get('detail');
  if (detail === 'summary') {
    const plans = await getPublishedPlans(sort);
    return NextResponse.json({ plans, sort, detail: 'summary' });
  }
  const plans = await getPublishedPlansWithRelations(sort);
  return NextResponse.json({ plans, sort });
});
