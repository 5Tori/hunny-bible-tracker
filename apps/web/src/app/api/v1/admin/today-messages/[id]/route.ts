import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import {
  deleteAdminTodayMessage,
  getAdminTodayMessageById,
  TodayMessageValidationError,
  updateAdminTodayMessage,
} from '@/lib/today-messages';

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function GET(req: Request, context: RouteContext) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const message = await getAdminTodayMessageById(id);
    if (!message) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }
    return NextResponse.json({ message });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    console.error('Admin today message GET error:', error);
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}

export async function PUT(req: Request, context: RouteContext) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const body = await req.json();
    const message = await updateAdminTodayMessage(id, body);
    if (!message) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }
    return NextResponse.json({ message });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (error instanceof TodayMessageValidationError) {
      return NextResponse.json({ error: 'validation_error', message: error.message }, { status: 400 });
    }
    console.error('Admin today message PUT error:', error);
    return NextResponse.json({ error: 'bad_request', message: 'Unable to update today message.' }, { status: 400 });
  }
}

export async function DELETE(req: Request, context: RouteContext) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const message = await deleteAdminTodayMessage(id);
    if (!message) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }
    return NextResponse.json({ message });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    console.error('Admin today message DELETE error:', error);
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}
