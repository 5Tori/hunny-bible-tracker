import { NextResponse } from 'next/server';

import { getPublishedPlansWithRelations, parsePublishedPlanSort } from '@/lib/plans';

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const sort = parsePublishedPlanSort(searchParams.get('sort'));
  const plans = await getPublishedPlansWithRelations(sort);
  return NextResponse.json({ plans, sort });
}
