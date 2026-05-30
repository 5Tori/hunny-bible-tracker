import { NextResponse } from 'next/server';

import {
  getPublishedContentsWithRelations,
  parseContentLimit,
  parsePublishedContentSort,
} from '@/lib/content';
import { withApiTiming } from '@/lib/perf/api-timing';

export const GET = withApiTiming('GET /api/v1/content', async (req: Request) => {
  const { searchParams } = new URL(req.url);
  const sort = parsePublishedContentSort(searchParams.get('sort'));
  const contents = await getPublishedContentsWithRelations({
    sort,
    type: searchParams.get('type'),
    language: searchParams.get('language'),
    tag: searchParams.get('tag'),
    limit: parseContentLimit(searchParams.get('limit')),
  });

  return NextResponse.json({ contents, sort });
});
