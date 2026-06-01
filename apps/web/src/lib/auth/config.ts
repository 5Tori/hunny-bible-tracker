import { isOfflineMode } from '@/lib/mock/mode';
import { getPublicRuntimeConfig } from '@/lib/public-runtime-config';

export function isPublicAuthConfigured(): boolean {
  const { supabaseUrl, supabaseAnonKey } = getPublicRuntimeConfig();
  return Boolean(supabaseUrl && supabaseAnonKey);
}

/** Sign-in UI + demo account in offline dev; Google OAuth when Supabase keys are set. */
export function isAuthUiEnabled(): boolean {
  return isPublicAuthConfigured() || isOfflineMode();
}

export function isOfflineDemoAuthOnly(): boolean {
  return isOfflineMode() && !isPublicAuthConfigured();
}
