'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getRedirectResult, signInWithRedirect } from 'firebase/auth';
import type { User } from 'firebase/auth';
import { firebaseAuth, googleProvider } from '@/lib/firebase/client';

import { adminFetch, clearAdminSession, setAdminToken } from '@/lib/admin/client';

async function verifyAdminAndEnterDashboard(user: User, router: ReturnType<typeof useRouter>) {
  const token = await user.getIdToken();
  setAdminToken(token);

  const response = await adminFetch('/api/v1/admin/verify');

  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    await clearAdminSession();
    throw new Error(
      typeof body.message === 'string'
        ? body.message
        : typeof body.error === 'string'
          ? body.error
          : 'Unable to verify admin access.',
    );
  }

  router.push('/admin/plans');
}

export function AdminGoogleLoginButton() {
  const router = useRouter();
  const [bootDone, setBootDone] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Full-page redirect flow avoids signInWithPopup + window.closed, which COOP blocks on Vercel.
  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        const result = await getRedirectResult(firebaseAuth);
        if (cancelled) return;

        if (result?.user) {
          setBusy(true);
          setError(null);
          await verifyAdminAndEnterDashboard(result.user, router);
        }
      } catch (e) {
        if (!cancelled) {
          setError((e as Error).message || 'Sign-in error.');
        }
      } finally {
        if (!cancelled) {
          setBusy(false);
          setBootDone(true);
        }
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [router]);

  async function handleLogin() {
    setError(null);
    setBusy(true);
    try {
      await signInWithRedirect(firebaseAuth, googleProvider);
    } catch (loginError) {
      setError((loginError as Error).message || 'Login failed.');
      setBusy(false);
    }
  }

  return (
    <div>
      {error ? <div className="alert alert-error">{error}</div> : null}
      {!bootDone ? (
        <p className="muted" style={{ marginTop: 12 }}>
          Preparing sign-in…
        </p>
      ) : null}
      {bootDone ? (
        <button type="button" onClick={() => void handleLogin()} disabled={busy} className="admin-google-button">
          {busy ? 'Redirecting to Google…' : 'Continue with Google'}
        </button>
      ) : null}
    </div>
  );
}
