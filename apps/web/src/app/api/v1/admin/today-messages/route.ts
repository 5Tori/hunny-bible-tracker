import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import {
  createAdminTodayMessage,
  getAdminTodayMessages,
  TodayMessageValidationError,
} from '@/lib/today-messages';

export async function GET(req: Request) {
  try {
    await requireAdminUser(req);
    const messages = await getAdminTodayMessages();
    return NextResponse.json({ messages });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    console.error('Admin today messages GET error:', error);
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    await requireAdminUser(req);
    const body = await req.json();
    const message = await createAdminTodayMessage(body);
    return NextResponse.json({ message }, { status: 201 });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (error instanceof TodayMessageValidationError) {
      return NextResponse.json({ error: 'validation_error', message: error.message }, { status: 400 });
    }
    console.error('Admin today messages POST error:', error);
    return NextResponse.json({ error: 'bad_request', message: 'Unable to create today message.' }, { status: 400 });
  }
}
