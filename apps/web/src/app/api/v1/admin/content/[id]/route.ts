import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import {
  ContentValidationError,
  deleteAdminContent,
  getAdminContentById,
  updateAdminContent,
} from '@/lib/content';

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function GET(req: Request, context: RouteContext) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const content = await getAdminContentById(id);
    if (!content) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }
    return NextResponse.json({ content });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Admin content GET error:', error);
    }
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}

export async function PUT(req: Request, context: RouteContext) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const body = await req.json();
    const content = await updateAdminContent(id, body);
    if (!content) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }
    return NextResponse.json({ content });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (error instanceof ContentValidationError) {
      return NextResponse.json({ error: 'validation_error', message: error.message }, { status: 400 });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Admin content PUT error:', error);
    }
    return NextResponse.json({ error: 'bad_request', message: 'Unable to update content.' }, { status: 400 });
  }
}

export async function DELETE(req: Request, context: RouteContext) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const ok = await deleteAdminContent(id);
    if (!ok) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }
    return NextResponse.json({ ok: true });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Admin content DELETE error:', error);
    }
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}
