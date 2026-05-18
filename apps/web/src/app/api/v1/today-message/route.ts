import { NextResponse } from 'next/server';

import {
  getPublishedTodayMessage,
  TodayMessageBase,
  TodayMessageValidationError,
} from '@/lib/today-messages';

export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const date = searchParams.get('date') ?? undefined;
    const language = searchParams.get('language') ?? undefined;
    const message = await getPublishedTodayMessage({ date, language });
    return NextResponse.json({
      message: message ? withShareUrl(req, message) : null,
    });
  } catch (error) {
    if (error instanceof TodayMessageValidationError) {
      return NextResponse.json({ error: 'validation_error', message: error.message }, { status: 400 });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Public today-message GET error:', error);
    }
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}

function withShareUrl(req: Request, message: TodayMessageBase) {
  const origin =
    process.env.NEXT_PUBLIC_SITE_URL?.replace(/\/$/, '') ||
    new URL(req.url).origin;
  return {
    ...message,
    share_url: `${origin}/today-message/${message.publish_date}`,
  };
}
