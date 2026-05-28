'use client';

import { adminFetch } from '@/lib/admin/client';

export async function adminJson<T>(
  input: RequestInfo,
  init?: RequestInit,
): Promise<{ response: Response; data: T }> {
  const response = await adminFetch(input, init);
  const data = (await response.json().catch(() => ({}))) as T;
  return { response, data };
}

export async function adminUpload(
  url: string,
  file: File,
): Promise<{ response: Response; data: Record<string, unknown> }> {
  const formData = new FormData();
  formData.append('file', file);
  const response = await adminFetch(url, { method: 'POST', body: formData });
  const data = (await response.json().catch(() => ({}))) as Record<string, unknown>;
  return { response, data };
}
