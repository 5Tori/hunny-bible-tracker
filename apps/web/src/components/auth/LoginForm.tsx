'use client';

import { Suspense } from 'react';

import { OfflineDemoSignInButton } from '@/components/auth/OfflineDemoSignInButton';
import { UserGoogleSignInButton } from '@/components/auth/UserGoogleSignInButton';
import {
  isOfflineDemoAuthOnly,
  isPublicAuthConfigured,
} from '@/lib/auth/config';
import { isOfflineMode } from '@/lib/mock/mode';

export function LoginForm() {
  const demoOnly = isOfflineDemoAuthOnly();
  const googleEnabled = isPublicAuthConfigured();
  const showDemo = isOfflineMode();

  return (
    <div className="mt-2">
      {googleEnabled && !demoOnly ? (
        <Suspense fallback={<p className="mt-6 text-sm text-neutral-500">Loading…</p>}>
          <UserGoogleSignInButton />
        </Suspense>
      ) : null}
      {showDemo ? (
        <>
          {googleEnabled && !demoOnly ? (
            <p className="my-4 text-center text-xs uppercase tracking-[0.12em] text-neutral-400">
              or
            </p>
          ) : null}
          <Suspense fallback={<p className="mt-6 text-sm text-neutral-500">Loading…</p>}>
            <OfflineDemoSignInButton />
          </Suspense>
        </>
      ) : null}
    </div>
  );
}
