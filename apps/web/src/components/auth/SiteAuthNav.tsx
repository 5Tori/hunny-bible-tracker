'use client';

import Link from 'next/link';

import { useAuth } from '@/components/auth/AuthProvider';

const navLinkClass =
  'shrink-0 whitespace-nowrap rounded-lg px-3 py-2 text-neutral-600 transition hover:text-neutral-900';

const menuNavLinkClass =
  'block rounded-lg px-3 py-3 text-base text-neutral-800 transition hover:bg-neutral-50 hover:text-neutral-900';

interface SiteAuthNavProps {
  variant?: 'inline' | 'menu';
  onNavigate?: () => void;
}

export function SiteAuthNav({ variant = 'inline', onNavigate }: SiteAuthNavProps) {
  const { configured, loading, user, signOut } = useAuth();
  const linkClass = variant === 'menu' ? menuNavLinkClass : navLinkClass;
  const isMenu = variant === 'menu';

  if (!configured) {
    return null;
  }

  if (loading) {
    return (
      <span className={`${linkClass} ${isMenu ? '' : 'text-neutral-400'}`}>Account</span>
    );
  }

  if (user) {
    const content = (
      <>
        <Link href="/account" className={linkClass} onClick={onNavigate}>
          Account
        </Link>
        <button
          type="button"
          className={`${linkClass} w-full text-left`}
          onClick={() => {
            onNavigate?.();
            void signOut();
          }}
        >
          Sign out
        </button>
      </>
    );

    return isMenu ? <div className="flex flex-col gap-0.5">{content}</div> : content;
  }

  return (
    <Link href="/login" className={linkClass} onClick={onNavigate}>
      Sign in
    </Link>
  );
}
