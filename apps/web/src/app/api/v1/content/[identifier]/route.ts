import { NextResponse } from 'next/server';

import { getPublishedContentByIdentifier } from '@/lib/content';

export async function GET(req: Request, context: { params: Promise<{ identifier: string }> }) {
  const { identifier } = await context.params;
  const { searchParams } = new URL(req.url);
  const content = await getPublishedContentByIdentifier(identifier, searchParams.get('language'));

  if (!content) {
    return NextResponse.json({ error: 'not_found' }, { status: 404 });
  }

  return NextResponse.json({ content });
}
