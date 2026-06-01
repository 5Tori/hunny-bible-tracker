'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

import { useAuth } from '@/components/auth/AuthProvider';
import { MarketingSection } from '@/components/marketing/ui/MarketingSection';

export default function AccountPage() {
  const router = useRouter();
  const { configured, loading, user, signOut } = useAuth();

  useEffect(() => {
    if (!loading && configured && !user) {
      router.replace('/login?next=/account');
    }
  }, [configured, loading, user, router]);

  if (!configured) {
    return null;
  }

  if (loading || !user) {
    return (
      <MarketingSection className="!py-16 md:!py-24">
        <div className="mx-auto w-full max-w-lg px-4">
          <p className="text-sm text-neutral-500">Loading your account…</p>
        </div>
      </MarketingSection>
    );
  }

  const displayName = user.name || user.email || 'Signed in';

  return (
    <MarketingSection className="!py-16 md:!py-24">
      <div className="mx-auto w-full max-w-lg px-4">
        <p className="mkt-kicker">Account</p>
        <h1 className="mkt-heading mt-3 text-3xl">{displayName}</h1>
        {user.email ? <p className="mt-2 text-sm text-neutral-600">{user.email}</p> : null}

        <div className="mt-8 space-y-4 rounded-2xl border border-neutral-200 bg-white p-6 text-sm text-neutral-700">
          <p>
            Your web account uses the same sign-in as the mobile app. Reading progress sync
            (backup and restore) is available in the app&apos;s Settings tab today.
          </p>
          <p className="text-neutral-500">
            Saved messages and more web features will connect to your account in upcoming
            updates.
          </p>
        </div>

        <div className="mt-8 flex flex-wrap gap-3">
          <button
            type="button"
            onClick={() => void signOut()}
            className="rounded-xl border border-neutral-200 px-4 py-2.5 text-sm font-medium text-neutral-800 transition hover:border-neutral-300"
          >
            Sign out
          </button>
          <Link
            href="/messages"
            className="rounded-xl bg-neutral-900 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-black"
          >
            Browse messages
          </Link>
        </div>
      </div>
    </MarketingSection>
  );
}
