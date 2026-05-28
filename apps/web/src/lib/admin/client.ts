'use client';

import { getSupabaseBrowserClient } from '@/lib/supabase/client';

const ADMIN_TOKEN_KEY = 'hunny-admin-token';

export function getAdminToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(ADMIN_TOKEN_KEY);
}

export function setAdminToken(token: string) {
  if (typeof window === 'undefined') return;
  localStorage.setItem(ADMIN_TOKEN_KEY, token);
}

export function clearAdminToken() {
  if (typeof window === 'undefined') return;
  localStorage.removeItem(ADMIN_TOKEN_KEY);
}

/** Sync localStorage bearer from Supabase (refreshes access token when needed). */
export async function refreshAdminTokenFromSupabase(): Promise<void> {
  if (typeof window === 'undefined') return;
  const supabase = getSupabaseBrowserClient();
  const { data } = await supabase.auth.getSession();
  const token = data.session?.access_token;
  if (token) {
    setAdminToken(token);
  }
}

export async function getAdminTokenOrRefresh(): Promise<string | null> {
  await refreshAdminTokenFromSupabase();
  return getAdminToken();
}

export async function clearAdminSession(): Promise<void> {
  clearAdminToken();
  try {
    const supabase = getSupabaseBrowserClient();
    await supabase.auth.signOut();
  } catch {
    // ignore sign-out network errors
  }
}

export async function adminFetch(input: RequestInfo, init?: RequestInit) {
  await refreshAdminTokenFromSupabase();
  const token = getAdminToken();
  const headers = new Headers(init?.headers);

  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  return fetch(input, {
    ...init,
    headers,
    cache: 'no-store',
  });
}
