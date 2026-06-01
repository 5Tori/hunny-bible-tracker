import { NextResponse } from 'next/server';

import { getPublishedContentByIdentifier } from '@/lib/content';
import { jsonWithPublicCache } from '@/lib/http/public-cache';
import { withApiTiming } from '@/lib/perf/api-timing';

export const GET = withApiTiming(
  'GET /api/v1/content/[identifier]',
  async (req: Request, context: { params: Promise<{ identifier: string }> }) => {
    const { identifier } = await context.params;
    const { searchParams } = new URL(req.url);
    const content = await getPublishedContentByIdentifier(identifier, searchParams.get('language'));

    if (!content) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }

    return jsonWithPublicCache({ content });
  },
);
