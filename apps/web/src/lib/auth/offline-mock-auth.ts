import type { PublicAuthUser } from '@/lib/auth/types';

/** Bearer token used for local offline demo sign-in (no Supabase). */
export const OFFLINE_MOCK_AUTH_TOKEN = 'hunny-offline-demo-session';

export const OFFLINE_MOCK_USER: PublicAuthUser = {
  sub: '00000000-0000-4000-8000-000000000099',
  email: 'demo@local.hunny',
  name: 'Demo Reader',
};

export function isOfflineMockAuthToken(token: string | null | undefined): boolean {
  return token === OFFLINE_MOCK_AUTH_TOKEN;
}
