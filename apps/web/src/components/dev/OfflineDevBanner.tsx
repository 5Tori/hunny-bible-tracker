import Link from 'next/link';

import { isOfflineMode } from '@/lib/mock/mode';

export function OfflineDevBanner() {
  if (!isOfflineMode()) {
    return null;
  }

  return (
    <div className="border-b border-amber-200 bg-amber-50 px-4 py-2 text-center text-sm text-amber-950">
      <strong>Local offline mode</strong> — mock messages &amp; catalog.{" "}
      <Link href="/login" className="font-medium underline underline-offset-2">
        Demo sign-in
      </Link>{" "}
      works without Supabase. Use{" "}
      <code className="rounded bg-amber-100 px-1.5 py-0.5 text-xs">pnpm web:dev:online</code>{" "}
      for Google auth + database.
    </div>
  );
}
