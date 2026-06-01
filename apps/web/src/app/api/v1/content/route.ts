import { NextResponse } from 'next/server';

import {
  getPublishedContentsForBrowse,
  getPublishedContentsWithRelations,
  parseContentLimit,
  parseDiscoverOnlyQuery,
  parsePublishedContentSort,
} from '@/lib/content';
import { jsonWithPublicCache } from '@/lib/http/public-cache';
import { withApiTiming } from '@/lib/perf/api-timing';

export const GET = withApiTiming('GET /api/v1/content', async (req: Request) => {
  const { searchParams } = new URL(req.url);
  const sort = parsePublishedContentSort(searchParams.get('sort'));
  const detail = searchParams.get('detail');
  const discoverOnly = parseDiscoverOnlyQuery(searchParams.get('discoverOnly'));
  const options = {
    sort,
    type: searchParams.get('type'),
    language: searchParams.get('language'),
    tag: searchParams.get('tag'),
    limit: parseContentLimit(searchParams.get('limit')),
    discoverOnly,
  };

  if (detail === 'full') {
    const contents = await getPublishedContentsWithRelations(options);
    return NextResponse.json({ contents, sort, detail: 'full', discoverOnly });
  }

  const contents = await getPublishedContentsForBrowse(options);
  return jsonWithPublicCache({ contents, sort, detail: 'summary', discoverOnly });
});
