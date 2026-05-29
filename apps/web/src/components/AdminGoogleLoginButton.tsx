'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import type { Session } from '@supabase/supabase-js';

import { adminFetch, clearAdminSession, setAdminToken } from '@/lib/admin/client';
import { getSupabaseBrowserClient } from '@/lib/supabase/client';

const OAUTH_RETURN_KEY = 'hunny-admin-oauth-return';

async function verifyAdminAndEnterDashboard(
  session: Session,
  router: ReturnType<typeof useRouter>,
) {
  setAdminToken(session.access_token);

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

  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        const supabase = getSupabaseBrowserClient();
        const expectingReturn =
          typeof window !== 'undefined' && sessionStorage.getItem(OAUTH_RETURN_KEY) === '1';

        const { data } = await supabase.auth.getSession();
        const session = data.session;

        if (cancelled) return;

        if (session?.user) {
          if (expectingReturn) {
            sessionStorage.removeItem(OAUTH_RETURN_KEY);
          }
          setBusy(true);
          setError(null);
          await verifyAdminAndEnterDashboard(session, router);
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
      const supabase = getSupabaseBrowserClient();
      const redirectTo = `${window.location.origin}/admin/login`;
      const { error: oauthError } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: { redirectTo },
      });
      if (oauthError) {
        throw oauthError;
      }
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
      {error ? <div className="admin-alert admin-alert-error">{error}</div> : null}
      {!bootDone ? (
        <p className="admin-muted" style={{ marginTop: 12 }}>
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
