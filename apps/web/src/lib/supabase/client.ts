'use client';

import { createClient, type SupabaseClient } from '@supabase/supabase-js';

import { getPublicRuntimeConfig } from '@/lib/public-runtime-config';

let browserClient: SupabaseClient | null = null;

export function getSupabaseBrowserClient(): SupabaseClient {
  if (browserClient) return browserClient;

  const { supabaseUrl: url, supabaseAnonKey: anonKey } =
    getPublicRuntimeConfig();
  if (!url || !anonKey) {
    throw new Error(
      'NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY must be set',
    );
  }

  browserClient = createClient(url, anonKey, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
    },
  });

  return browserClient;
}
