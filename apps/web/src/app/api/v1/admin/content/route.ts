import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import {
  ContentValidationError,
  createAdminContent,
  getAdminContents,
  getAdminContentsList,
} from '@/lib/content';

export async function GET(req: Request) {
  try {
    await requireAdminUser(req);
    const url = new URL(req.url);
    const contentType = url.searchParams.get('content_type')?.trim() || undefined;
    const view = url.searchParams.get('view')?.trim();

    if (view === 'summary') {
      const contents = await getAdminContentsList(contentType ? { contentType } : undefined);
      return NextResponse.json({ contents });
    }

    const contents = await getAdminContents(contentType ? { contentType } : undefined);
    return NextResponse.json({ contents });
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

export async function POST(req: Request) {
  try {
    await requireAdminUser(req);
    const body = await req.json();
    const content = await createAdminContent(body);
    return NextResponse.json({ content }, { status: 201 });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (error instanceof ContentValidationError) {
      return NextResponse.json({ error: 'validation_error', message: error.message }, { status: 400 });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Admin content POST error:', error);
    }
    return NextResponse.json({ error: 'bad_request', message: 'Unable to create content.' }, { status: 400 });
  }
}
