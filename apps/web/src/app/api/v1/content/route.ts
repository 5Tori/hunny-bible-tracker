import { NextResponse } from 'next/server';

import {
  getPublishedContentsWithRelations,
  parseContentLimit,
  parsePublishedContentSort,
} from '@/lib/content';

export async function GET(req: Request) {
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
}
