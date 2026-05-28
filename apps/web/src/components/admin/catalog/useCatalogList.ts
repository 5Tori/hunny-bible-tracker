'use client';

import { useCallback, useState } from 'react';

import { adminFetch } from '@/lib/admin/client';

import { useAdminAuth } from '../hooks/use-admin-auth';

export function useCatalogList() {
  const { ensureSession, handleAdminResponse } = useAdminAuth();
  const [busyId, setBusyId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(
    async (url: string): Promise<unknown | null> => {
      setLoading(true);
      setError(null);
      const token = await ensureSession();
      if (!token) {
        setLoading(false);
        return null;
      }

      const response = await adminFetch(url);
      const ok = await handleAdminResponse(response);
      if (!ok) {
        setLoading(false);
        return null;
      }

      if (!response.ok) {
        setError('Unable to load data.');
        setLoading(false);
        return null;
      }

      const json = await response.json();
      setLoading(false);
      return json;
    },
    [ensureSession, handleAdminResponse],
  );

  const runPatch = useCallback(
    async (
      url: string,
      patch: Record<string, unknown>,
      options?: { errorMessage?: string },
    ): Promise<boolean> => {
      setError(null);
      const response = await adminFetch(url, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(patch),
      });

      const ok = await handleAdminResponse(response);
      if (!ok) return false;

      const body = await response.json().catch(() => ({}));
      if (!response.ok) {
        setError(
          typeof (body as { message?: string }).message === 'string'
            ? (body as { message: string }).message
            : options?.errorMessage ?? 'Update failed.',
        );
        return false;
      }
      return true;
    },
    [handleAdminResponse],
  );

  const runDelete = useCallback(
    async (url: string, options?: { errorMessage?: string }): Promise<boolean> => {
      setError(null);
      const response = await adminFetch(url, { method: 'DELETE' });
      const ok = await handleAdminResponse(response);
      if (!ok) return false;

      const body = await response.json().catch(() => ({}));
      if (!response.ok) {
        setError(
          typeof (body as { message?: string }).message === 'string'
            ? (body as { message: string }).message
            : options?.errorMessage ?? 'Delete failed.',
        );
        return false;
      }
      return true;
    },
    [handleAdminResponse],
  );

  return {
    busyId,
    setBusyId,
    error,
    setError,
    loading,
    setLoading,
    load,
    runPatch,
    runDelete,
  };
}
