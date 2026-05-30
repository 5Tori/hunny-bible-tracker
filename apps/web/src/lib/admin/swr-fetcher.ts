import { adminFetch, clearAdminSession } from '@/lib/admin/client';

export class AdminSwrError extends Error {
  status: number;

  constructor(message: string, status: number) {
    super(message);
    this.name = 'AdminSwrError';
    this.status = status;
  }
}

export async function adminSwrFetcher<T>(url: string): Promise<T> {
  const response = await adminFetch(url);

  if (response.status === 401 || response.status === 403) {
    await clearAdminSession();
    if (typeof window !== 'undefined') {
      window.location.assign('/admin/login');
    }
    throw new AdminSwrError('Unauthorized', response.status);
  }

  if (!response.ok) {
    throw new AdminSwrError('Unable to load data.', response.status);
  }

  return response.json() as Promise<T>;
}
