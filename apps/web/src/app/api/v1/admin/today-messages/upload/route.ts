import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import { uploadTodayMessageImage } from '@/lib/cloudinary';

export async function POST(req: Request) {
  try {
    await requireAdminUser(req);
    const formData = await req.formData();
    const file = formData.get('file');

    if (!(file instanceof File)) {
      return NextResponse.json({ error: 'missing_file', message: 'Please choose an image file.' }, { status: 400 });
    }

    const asset = await uploadTodayMessageImage(file);
    return NextResponse.json({ asset });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }

    const message = error instanceof Error ? error.message : 'Upload failed.';
    const status = message.includes('Only image') || message.includes('smaller than') ? 400 : 500;
    return NextResponse.json({ error: 'upload_failed', message }, { status });
  }
}
