import type { Metadata } from 'next';
import Link from 'next/link';

import { LoginForm } from '@/components/auth/LoginForm';
import { MarketingSection } from '@/components/marketing/ui/MarketingSection';
import { isAuthUiEnabled, isOfflineDemoAuthOnly } from '@/lib/auth/config';

export const metadata: Metadata = {
  title: 'Sign in',
  description: 'Sign in to Hunny Bible Tracker with Google.',
  alternates: { canonical: '/login' },
};

export default function LoginPage() {
  const authEnabled = isAuthUiEnabled();
  const demoOnly = isOfflineDemoAuthOnly();

  return (
    <MarketingSection className="!py-16 md:!py-24">
      <div className="mx-auto w-full max-w-md px-4">
        <p className="mkt-kicker">Account</p>
        <h1 className="mkt-heading mt-3 text-3xl">Sign in</h1>
        <p className="mkt-lead mt-4">
          {demoOnly
            ? 'Use a local demo account while testing messages offline. Saved messages sync to your account comes later.'
            : 'Use Google to save your progress and sync with the Hunny Bible Tracker app.'}
        </p>

        {authEnabled ? <LoginForm /> : null}

        <p className="mt-8 text-center text-sm text-neutral-500">
          <Link href="/" className="underline underline-offset-4 hover:text-neutral-800">
            Back to home
          </Link>
        </p>
      </div>
    </MarketingSection>
  );
}
