'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getRedirectResult, signInWithRedirect } from 'firebase/auth';
import type { User } from 'firebase/auth';
import { firebaseAuth, googleProvider } from '@/lib/firebase/client';

import { adminFetch, clearAdminSession, setAdminToken } from '@/lib/admin/client';

/** Set before signInWithRedirect so we can recover the session after OAuth if getRedirectResult is null (e.g. React Strict Mode remount). */
const OAUTH_RETURN_KEY = 'hunny-admin-oauth-return';

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

  // Full-page redirect flow (no popup / COOP issues).
  // Strict Mode runs this effect twice; the first getRedirectResult may be "consumed" on the aborted
  // mount, so we also read firebaseAuth.currentUser when we know we just returned from Google.
  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        const expectingReturn =
          typeof window !== 'undefined' && sessionStorage.getItem(OAUTH_RETURN_KEY) === '1';

        const cred = await getRedirectResult(firebaseAuth);
        let user: User | null = cred?.user ?? null;

        if (!user && expectingReturn) {
          await firebaseAuth.authStateReady();
          user = firebaseAuth.currentUser;
        }

        if (cancelled) return;

        if (user) {
          if (expectingReturn) {
            sessionStorage.removeItem(OAUTH_RETURN_KEY);
          }
          setBusy(true);
          setError(null);
          await verifyAdminAndEnterDashboard(user, router);
        } else if (expectingReturn) {
          sessionStorage.removeItem(OAUTH_RETURN_KEY);
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
      if (typeof window !== 'undefined') {
        sessionStorage.setItem(OAUTH_RETURN_KEY, '1');
      }
      await signInWithRedirect(firebaseAuth, googleProvider);
    } catch (loginError) {
      if (typeof window !== 'undefined') {
        sessionStorage.removeItem(OAUTH_RETURN_KEY);
      }
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
