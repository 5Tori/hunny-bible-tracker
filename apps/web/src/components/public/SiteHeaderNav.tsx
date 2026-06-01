'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';

import { SiteAuthNav } from '@/components/auth/SiteAuthNav';
import { AndroidTesterCta } from '@/components/public/AndroidTesterCta';
import { BrandLogo } from '@/components/public/BrandLogo';

const navLinkClass =
  'shrink-0 whitespace-nowrap rounded-lg px-3 py-2 text-neutral-600 transition hover:text-neutral-900';

const mobileNavLinkClass =
  'block rounded-lg px-3 py-3.5 text-lg text-neutral-900 transition hover:bg-neutral-50';

const primaryLinks = [
  { href: '/today', label: 'Today' },
  { href: '/messages', label: 'Messages' },
  { href: '/discover', label: 'Discover' },
  { href: '/plans', label: 'Plans' },
] as const;

function MenuIcon({ open }: { open: boolean }) {
  return (
    <svg
      viewBox="0 0 24 24"
      aria-hidden
      className="h-5 w-5"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
    >
      {open ? (
        <path d="M6 6l12 12M18 6L6 18" strokeLinecap="round" />
      ) : (
        <>
          <path d="M4 7h16M4 12h16M4 17h16" strokeLinecap="round" />
        </>
      )}
    </svg>
  );
}

export function SiteHeaderNav() {
  const [open, setOpen] = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (!open) return undefined;

    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setOpen(false);
    };

    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    window.addEventListener('keydown', onKeyDown);

    return () => {
      document.body.style.overflow = previousOverflow;
      window.removeEventListener('keydown', onKeyDown);
    };
  }, [open]);

  function closeMenu() {
    setOpen(false);
  }

  const mobileMenu =
    open && mounted
      ? createPortal(
          <div
            className="fixed inset-0 z-[100] flex flex-col bg-white md:hidden"
            role="dialog"
            aria-modal="true"
            aria-label="Site menu"
          >
            <div className="flex h-16 shrink-0 items-center justify-between border-b border-neutral-200 px-6">
              <Link
                href="/"
                className="flex items-center"
                onClick={closeMenu}
              >
                <BrandLogo className="h-7 w-auto shrink-0" />
              </Link>
              <button
                type="button"
                className="flex h-10 w-10 items-center justify-center rounded-lg text-neutral-700 transition hover:bg-neutral-100"
                aria-label="Close menu"
                onClick={closeMenu}
              >
                <MenuIcon open />
              </button>
            </div>

            <nav
              id="site-mobile-nav"
              aria-label="Main"
              className="flex min-h-0 flex-1 flex-col overflow-y-auto px-6 py-6"
            >
              <div className="flex flex-col gap-1">
                {primaryLinks.map((link) => (
                  <Link
                    key={link.href}
                    href={link.href}
                    className={mobileNavLinkClass}
                    onClick={closeMenu}
                  >
                    {link.label}
                  </Link>
                ))}
              </div>

              <div className="mt-6 border-t border-neutral-200 pt-6">
                <SiteAuthNav variant="menu" onNavigate={closeMenu} />
              </div>

              <div className="mt-auto border-t border-neutral-200 pt-6">
                <AndroidTesterCta
                  variant="header"
                  className="inline-flex w-full items-center justify-center rounded-xl bg-neutral-900 px-4 py-3.5 text-sm font-medium text-white transition hover:bg-black"
                />
              </div>
            </nav>
          </div>,
          document.body,
        )
      : null;

  return (
    <>
      <nav
        className="hidden shrink-0 flex-nowrap items-center gap-0.5 text-sm md:flex"
        aria-label="Main"
      >
        {primaryLinks.map((link) => (
          <Link key={link.href} href={link.href} className={navLinkClass}>
            {link.label}
          </Link>
        ))}
        <SiteAuthNav />
        <AndroidTesterCta variant="header" />
      </nav>

      <button
        type="button"
        className="flex h-10 w-10 items-center justify-center rounded-lg text-neutral-700 transition hover:bg-neutral-100 md:hidden"
        aria-label={open ? 'Close menu' : 'Open menu'}
        aria-expanded={open}
        aria-controls="site-mobile-nav"
        onClick={() => setOpen((value) => !value)}
      >
        <MenuIcon open={open} />
      </button>

      {mobileMenu}
    </>
  );
}
