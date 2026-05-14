'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { signInWithPopup } from 'firebase/auth';
import { firebaseAuth, googleProvider } from '@/lib/firebase/client';

import { adminFetch, setAdminToken } from '@/lib/admin/client';

export function AdminGoogleLoginButton() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleLogin() {
    setError(null);
    setLoading(true);

    try {
      const result = await signInWithPopup(firebaseAuth, googleProvider);
      const token = await result.user.getIdToken();

      setAdminToken(token);

      const response = await adminFetch('/api/v1/admin/verify');

      if (!response.ok) {
        setAdminToken('');
        const body = await response.json().catch(() => ({}));
        throw new Error(body.message || body.error || 'Unable to verify admin access.');
      }

      router.push('/admin/plans');
    } catch (loginError) {
      setError((loginError as Error).message || 'Login failed.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div>
      {error ? <div className="alert alert-error">{error}</div> : null}
      <button type="button" onClick={handleLogin} disabled={loading} className="admin-google-button">
        {loading ? 'Signing in…' : 'Continue with Google'}
      </button>
    </div>
  );
}