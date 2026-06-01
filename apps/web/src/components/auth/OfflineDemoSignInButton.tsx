'use client';

import { useRouter, useSearchParams } from 'next/navigation';
import { useState } from 'react';

import { signInOfflineDemo } from '@/lib/auth/user-session';

function safeNextPath(value: string | null): string {
  if (!value || !value.startsWith('/') || value.startsWith('//')) {
    return '/account';
  }
  return value;
}

export function OfflineDemoSignInButton() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const nextPath = safeNextPath(searchParams.get('next'));
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleDemoSignIn() {
    setBusy(true);
    setError(null);
    try {
      await signInOfflineDemo();
      router.replace(nextPath);
    } catch (e) {
      setError((e as Error).message || 'Demo sign-in failed.');
      setBusy(false);
    }
  }

  return (
    <div>
      {error ? (
        <p className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
          {error}
        </p>
      ) : null}
      <button
        type="button"
        onClick={() => void handleDemoSignIn()}
        disabled={busy}
        className="mt-6 w-full rounded-xl bg-neutral-900 px-5 py-3 text-sm font-medium text-white transition hover:bg-black disabled:opacity-60"
      >
        {busy ? 'Signing in…' : 'Continue as demo account'}
      </button>
      <p className="mt-3 text-center text-xs text-neutral-500">
        Local offline mode — no Google or database required.
      </p>
    </div>
  );
}
