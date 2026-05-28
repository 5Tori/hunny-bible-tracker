'use client';

import { useCallback } from 'react';
import { useRouter } from 'next/navigation';

import { clearAdminSession, getAdminTokenOrRefresh } from '@/lib/admin/client';

export function useAdminAuth() {
  const router = useRouter();

  const redirectToLogin = useCallback(() => {
    router.push('/admin/login');
  }, [router]);

  const ensureSession = useCallback(async (): Promise<string | null> => {
    const token = await getAdminTokenOrRefresh();
    if (!token) {
      redirectToLogin();
      return null;
    }
    return token;
  }, [redirectToLogin]);

  const handleAdminResponse = useCallback(
    async (response: Response): Promise<boolean> => {
      if (response.status === 401 || response.status === 403) {
        await clearAdminSession();
        redirectToLogin();
        return false;
      }
      return true;
    },
    [redirectToLogin],
  );

  const logout = useCallback(async () => {
    await clearAdminSession();
    redirectToLogin();
  }, [redirectToLogin]);

  return { ensureSession, handleAdminResponse, logout, redirectToLogin };
}
