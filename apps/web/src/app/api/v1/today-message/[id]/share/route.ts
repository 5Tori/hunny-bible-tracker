import { NextResponse } from 'next/server';

import { incrementTodayMessageShare } from '@/lib/today-messages';

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function POST(_req: Request, context: RouteContext) {
  const { id } = await context.params;
  try {
    const message = await incrementTodayMessageShare(id);
    if (!message) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }
    return NextResponse.json({
      message: {
        id: message.id,
        heart_count: message.heart_count,
        share_count: message.share_count,
      },
    });
  } catch (error) {
    console.error('Today message share error:', error);
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}
