import { NextResponse } from 'next/server';

import { jsonWithPublicCache } from '@/lib/http/public-cache';
import { getPublishedMessages, parseMessageLimit } from '@/lib/messages';
import { withApiTiming } from '@/lib/perf/api-timing';

export const GET = withApiTiming('GET /api/v1/messages', async (req: Request) => {
  const { searchParams } = new URL(req.url);

  const items = await getPublishedMessages({
    category: searchParams.get('category'),
    situation: searchParams.get('situation'),
    tag: searchParams.get('tag'),
    tone: searchParams.get('tone'),
    q: searchParams.get('q'),
    language: searchParams.get('language'),
    limit: parseMessageLimit(searchParams.get('limit')),
  });

  return jsonWithPublicCache({ items });
});
