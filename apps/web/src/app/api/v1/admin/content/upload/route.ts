import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import { uploadContentImage } from '@/lib/cloudinary';

export async function POST(req: Request) {
  try {
    await requireAdminUser(req);
    const form = await req.formData();
    const file = form.get('file');
    if (!(file instanceof File)) {
      return NextResponse.json({ error: 'missing_file' }, { status: 400 });
    }
    const asset = await uploadContentImage(file);
    return NextResponse.json({ asset });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Admin content upload error:', error);
    }
    return NextResponse.json(
      {
        error: 'upload_failed',
        message: error instanceof Error ? error.message : 'Upload failed.',
      },
      { status: 400 },
    );
  }
}
