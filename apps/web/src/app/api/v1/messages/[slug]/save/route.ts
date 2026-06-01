import { NextResponse } from 'next/server';

import { incrementMessageEngagement } from '@/lib/message-engagement-server';

interface RouteContext {
  params: Promise<{ slug: string }>;
}

export async function POST(_req: Request, context: RouteContext) {
  const { slug } = await context.params;
  try {
    const counts = await incrementMessageEngagement(slug, 'saveCount');
    if (!counts) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }
    return NextResponse.json({ counts });
  } catch (error) {
    console.error('Message save error:', error);
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}
