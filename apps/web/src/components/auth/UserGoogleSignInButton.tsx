'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import type { Session } from '@supabase/supabase-js';

import { syncUserProfile, setUserToken } from '@/lib/auth/user-session';
import { getSupabaseBrowserClient } from '@/lib/supabase/client';

const OAUTH_RETURN_KEY = 'hunny-user-oauth-return';

function safeNextPath(value: string | null): string {
  if (!value || !value.startsWith('/') || value.startsWith('//')) {
    return '/account';
  }
  return value;
}

async function completeUserSignIn(session: Session, nextPath: string, router: ReturnType<typeof useRouter>) {
  setUserToken(session.access_token);
  await syncUserProfile();
  router.replace(nextPath);
}

export function UserGoogleSignInButton() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const nextPath = safeNextPath(searchParams.get('next'));
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
          await completeUserSignIn(session, nextPath, router);
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
  }, [router, nextPath]);

  async function handleLogin() {
    setError(null);
    setBusy(true);
    try {
      if (typeof window !== 'undefined') {
        sessionStorage.setItem(OAUTH_RETURN_KEY, '1');
      }
      const supabase = getSupabaseBrowserClient();
      const redirectTo = `${window.location.origin}/login?next=${encodeURIComponent(nextPath)}`;
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
      {error ? (
        <p className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
          {error}
        </p>
      ) : null}
      {!bootDone ? (
        <p className="mt-4 text-sm text-neutral-500">Preparing sign-in…</p>
      ) : (
        <button
          type="button"
          onClick={() => void handleLogin()}
          disabled={busy}
          className="mt-6 w-full rounded-xl bg-neutral-900 px-5 py-3 text-sm font-medium text-white transition hover:bg-black disabled:opacity-60"
        >
          {busy ? 'Redirecting to Google…' : 'Continue with Google'}
        </button>
      )}
    </div>
  );
}
