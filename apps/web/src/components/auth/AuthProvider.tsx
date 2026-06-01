'use client';

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

import { isAuthUiEnabled, isPublicAuthConfigured } from '@/lib/auth/config';
import { isOfflineMockAuthToken } from '@/lib/auth/offline-mock-auth';
import { isOfflineMode } from '@/lib/mock/mode';
import type { PublicAuthUser } from '@/lib/auth/types';
import {
  clearUserSession,
  getUserToken,
  refreshUserTokenFromSupabase,
  setUserToken,
  userFetch,
} from '@/lib/auth/user-session';
import { getSupabaseBrowserClient } from '@/lib/supabase/client';

type AuthContextValue = {
  configured: boolean;
  loading: boolean;
  user: PublicAuthUser | null;
  refreshUser: () => Promise<void>;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

async function fetchCurrentUser(): Promise<PublicAuthUser | null> {
  const response = await userFetch('/api/v1/me');
  if (response.status === 401) return null;
  if (!response.ok) {
    throw new Error('Unable to load your account.');
  }
  const body = (await response.json()) as { user?: PublicAuthUser };
  return body.user ?? null;
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const authEnabled = isAuthUiEnabled();
  const [loading, setLoading] = useState(authEnabled);
  const [user, setUser] = useState<PublicAuthUser | null>(null);

  const refreshUser = useCallback(async () => {
    if (!authEnabled) {
      setUser(null);
      setLoading(false);
      return;
    }

    try {
      if (isOfflineMode() && isOfflineMockAuthToken(getUserToken())) {
        const profile = await fetchCurrentUser();
        setUser(profile);
        return;
      }

      if (!isPublicAuthConfigured()) {
        setUser(null);
        return;
      }

      const supabase = getSupabaseBrowserClient();
      const { data } = await supabase.auth.getSession();
      const session = data.session;
      if (!session?.access_token) {
        setUser(null);
        return;
      }
      setUserToken(session.access_token);
      const profile = await fetchCurrentUser();
      setUser(profile);
    } catch {
      setUser(null);
    } finally {
      setLoading(false);
    }
  }, [authEnabled]);

  useEffect(() => {
    void refreshUser();
  }, [refreshUser]);

  useEffect(() => {
    if (!isPublicAuthConfigured()) return;

    const supabase = getSupabaseBrowserClient();
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.access_token) {
        setUserToken(session.access_token);
        void refreshUserTokenFromSupabase().then(() => fetchCurrentUser().then(setUser));
      } else if (!isOfflineMockAuthToken(getUserToken())) {
        setUser(null);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const signOut = useCallback(async () => {
    await clearUserSession();
    setUser(null);
  }, []);

  const value = useMemo(
    () => ({
      configured: authEnabled,
      loading,
      user,
      refreshUser,
      signOut,
    }),
    [authEnabled, loading, user, refreshUser, signOut],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
