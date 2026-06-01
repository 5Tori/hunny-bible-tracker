'use client';

import type { ReactNode } from 'react';

import { AuthProvider } from '@/components/auth/AuthProvider';

/** Wraps public + browse routes so `SiteHeader` can use `useAuth`. */
export function PublicAuthShell({ children }: { children: ReactNode }) {
  return <AuthProvider>{children}</AuthProvider>;
}
