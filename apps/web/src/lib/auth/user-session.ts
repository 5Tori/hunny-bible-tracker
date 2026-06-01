'use client';

import {
  OFFLINE_MOCK_AUTH_TOKEN,
  isOfflineMockAuthToken,
} from '@/lib/auth/offline-mock-auth';
import { isPublicAuthConfigured } from '@/lib/auth/config';
import { isOfflineMode } from '@/lib/mock/mode';
import { getSupabaseBrowserClient } from '@/lib/supabase/client';

const USER_TOKEN_KEY = 'hunny-user-token';
const TOKEN_REFRESH_INTERVAL_MS = 60_000;

let lastTokenRefreshAt = 0;
let tokenRefreshPromise: Promise<void> | null = null;

export function getUserToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(USER_TOKEN_KEY);
}

export function setUserToken(token: string) {
  if (typeof window === 'undefined') return;
  localStorage.setItem(USER_TOKEN_KEY, token);
}

export function clearUserToken() {
  if (typeof window === 'undefined') return;
  localStorage.removeItem(USER_TOKEN_KEY);
}

export async function refreshUserTokenFromSupabase(): Promise<void> {
  if (typeof window === 'undefined') return;

  const now = Date.now();
  if (now - lastTokenRefreshAt < TOKEN_REFRESH_INTERVAL_MS) {
    return;
  }
  if (tokenRefreshPromise) {
    await tokenRefreshPromise;
    return;
  }

  tokenRefreshPromise = (async () => {
    const existing = getUserToken();
    if (isOfflineMode() && isOfflineMockAuthToken(existing)) {
      lastTokenRefreshAt = Date.now();
      return;
    }

    if (!isPublicAuthConfigured()) {
      clearUserToken();
      lastTokenRefreshAt = Date.now();
      return;
    }

    const supabase = getSupabaseBrowserClient();
    const { data } = await supabase.auth.getSession();
    const token = data.session?.access_token;
    if (token) {
      setUserToken(token);
    } else {
      clearUserToken();
    }
    lastTokenRefreshAt = Date.now();
  })();

  try {
    await tokenRefreshPromise;
  } finally {
    tokenRefreshPromise = null;
  }
}

export async function getUserTokenOrRefresh(): Promise<string | null> {
  await refreshUserTokenFromSupabase();
  return getUserToken();
}

export async function clearUserSession(): Promise<void> {
  clearUserToken();
  if (!isPublicAuthConfigured()) {
    return;
  }
  try {
    const supabase = getSupabaseBrowserClient();
    await supabase.auth.signOut();
  } catch {
    // ignore sign-out network errors
  }
}

export async function signInOfflineDemo(): Promise<void> {
  setUserToken(OFFLINE_MOCK_AUTH_TOKEN);
  await syncUserProfile();
}

export async function userFetch(input: RequestInfo, init?: RequestInit) {
  await refreshUserTokenFromSupabase();
  const token = getUserToken();
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

export async function syncUserProfile(): Promise<void> {
  const response = await userFetch('/api/v1/auth/sync', { method: 'POST' });
  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(
      typeof body.error === 'string' ? body.error : 'Unable to sync your account.',
    );
  }
}
