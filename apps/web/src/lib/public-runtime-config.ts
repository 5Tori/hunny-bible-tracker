export type PublicRuntimeConfig = {
  supabaseUrl: string;
  supabaseAnonKey: string;
  cloudinaryCloudName: string;
};

declare global {
  interface Window {
    __HUNNY_PUBLIC_CONFIG__?: PublicRuntimeConfig;
  }
}

function fromProcessEnv(): PublicRuntimeConfig {
  return {
    supabaseUrl:
      process.env.NEXT_PUBLIC_SUPABASE_URL?.trim() ||
      process.env.SUPABASE_URL?.trim() ||
      '',
    supabaseAnonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.trim() || '',
    cloudinaryCloudName:
      process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME?.trim() ||
      process.env.CLOUDINARY_CLOUD_NAME?.trim() ||
      '',
  };
}

/** Client-safe public config — prefers runtime injection from the admin layout on Workers. */
export function getPublicRuntimeConfig(): PublicRuntimeConfig {
  if (typeof window !== 'undefined' && window.__HUNNY_PUBLIC_CONFIG__) {
    return window.__HUNNY_PUBLIC_CONFIG__;
  }
  return fromProcessEnv();
}

/** Server-only — reads Worker runtime vars (wrangler `vars`) for HTML injection. */
export function getPublicRuntimeConfigForInjection(): PublicRuntimeConfig {
  return fromProcessEnv();
}
