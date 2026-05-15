'use client';

import { signOut } from 'firebase/auth';

import { firebaseAuth } from '@/lib/firebase/client';

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

/** Sync localStorage bearer from Firebase (refreshes ID token when expired or near expiry). */
export async function refreshAdminTokenFromFirebase(): Promise<void> {
  if (typeof window === 'undefined') return;
  await firebaseAuth.authStateReady();
  const user = firebaseAuth.currentUser;
  if (!user) return;
  const token = await user.getIdToken();
  setAdminToken(token);
}

/** Use after authStateReady so a persisted Firebase session repopulates the admin bearer without a new Google prompt. */
export async function getAdminTokenOrRefresh(): Promise<string | null> {
  await refreshAdminTokenFromFirebase();
  return getAdminToken();
}

export async function clearAdminSession(): Promise<void> {
  clearAdminToken();
  try {
    await signOut(firebaseAuth);
  } catch {
    // ignore sign-out network errors
  }
}

export async function adminFetch(input: RequestInfo, init?: RequestInit) {
  await refreshAdminTokenFromFirebase();
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
