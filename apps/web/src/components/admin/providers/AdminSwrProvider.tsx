'use client';

import { SWRConfig } from 'swr';

import { adminSwrFetcher } from '@/lib/admin/swr-fetcher';

export function AdminSwrProvider({ children }: { children: React.ReactNode }) {
  return (
    <SWRConfig
      value={{
        fetcher: adminSwrFetcher,
        revalidateOnFocus: true,
        dedupingInterval: 5_000,
        keepPreviousData: true,
        shouldRetryOnError: (error) => {
          const status = (error as { status?: number }).status;
          return status !== 401 && status !== 403;
        },
      }}
    >
      {children}
    </SWRConfig>
  );
}
