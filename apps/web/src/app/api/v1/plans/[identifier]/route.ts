import { NextResponse } from 'next/server';

import { getPublishedPlanByIdentifier } from '@/lib/plans';

export async function GET(_req: Request, context: { params: Promise<{ identifier: string }> }) {
  const { identifier } = await context.params;
  const plan = await getPublishedPlanByIdentifier(identifier);

  if (!plan) {
    return NextResponse.json({ error: 'not_found' }, { status: 404 });
  }

  return NextResponse.json({ plan });
}
