import { getPublicRuntimeConfigForInjection } from '@/lib/public-runtime-config';

/** Inlines public env for client bundles when NEXT_PUBLIC_* was not present at build time. */
export function PublicRuntimeConfigScript() {
  const config = getPublicRuntimeConfigForInjection();
  if (!config.offlineMode && (!config.supabaseUrl || !config.supabaseAnonKey)) {
    return null;
  }

  const payload = JSON.stringify(config).replace(/</g, '\\u003c');

  return (
    <script
      dangerouslySetInnerHTML={{
        __html: `window.__HUNNY_PUBLIC_CONFIG__=${payload};`,
      }}
    />
  );
}
