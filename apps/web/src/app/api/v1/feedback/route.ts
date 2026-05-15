import { NextResponse } from 'next/server';

import {
  createFeedbackMessage,
  FeedbackValidationError,
} from '@/lib/feedback';

export async function POST(req: Request) {
  let body;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: 'invalid_json' }, { status: 400 });
  }

  try {
    const feedback = await createFeedbackMessage(body);
    return NextResponse.json({ feedback });
  } catch (error) {
    if (error instanceof FeedbackValidationError) {
      return NextResponse.json(
        { error: 'validation_error', message: error.message },
        { status: 400 },
      );
    }
    console.error('Feedback POST error:', error);
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}
