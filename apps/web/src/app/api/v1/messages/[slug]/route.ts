import { NextResponse } from 'next/server';

import { jsonWithPublicCache } from '@/lib/http/public-cache';
import { getPublishedMessageBySlug } from '@/lib/messages';
import { withApiTiming } from '@/lib/perf/api-timing';

export const GET = withApiTiming(
  'GET /api/v1/messages/[slug]',
  async (req: Request, context: { params: Promise<{ slug: string }> }) => {
    const { slug } = await context.params;
    const { searchParams } = new URL(req.url);
    const message = await getPublishedMessageBySlug(slug, searchParams.get('language'));

    if (!message) {
      return NextResponse.json({ error: 'Message not found.' }, { status: 404 });
    }

    return jsonWithPublicCache({ message });
  },
);
