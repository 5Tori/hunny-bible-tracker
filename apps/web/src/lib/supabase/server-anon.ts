import { createClient, type SupabaseClient } from '@supabase/supabase-js';

let anonClient: SupabaseClient | null = null;

function resolveSupabaseUrl() {
  return (process.env.SUPABASE_URL ?? process.env.NEXT_PUBLIC_SUPABASE_URL)?.trim() ?? '';
}

function resolveSupabaseAnonKey() {
  return process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.trim() ?? '';
}

export function isSupabaseAnonConfigured() {
  return Boolean(resolveSupabaseUrl() && resolveSupabaseAnonKey());
}

/** Server-side anon client for public catalog RPC (no session cookies). */
export function getSupabaseAnonClient(): SupabaseClient {
  if (anonClient) return anonClient;

  const url = resolveSupabaseUrl();
  const anonKey = resolveSupabaseAnonKey();
  if (!url || !anonKey) {
    throw new Error('SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY must be set for catalog RPC reads');
  }

  anonClient = createClient(url, anonKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  return anonClient;
}
