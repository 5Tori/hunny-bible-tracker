'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { onIdTokenChanged } from 'firebase/auth';

import { firebaseAuth } from '@/lib/firebase/client';
import { clearAdminToken, setAdminToken } from '@/lib/admin/client';

const NAV_ITEMS = [
  { href: '/admin/plans', label: 'Plan catalog' },
  { href: '/admin/plans/new', label: 'New plan' },
  { href: '/admin/today-messages', label: 'Today messages' },
  { href: '/admin/today-messages/new', label: 'New today message' },
] as const;

function isNavActive(href: string, pathname: string) {
  if (href === '/admin/plans') {
    if (pathname === '/admin/plans') return true;
    if (pathname.startsWith('/admin/plans/') && pathname !== '/admin/plans/new') {
      return true;
    }
    return false;
  }
  if (href === '/admin/plans/new') return pathname === '/admin/plans/new';
  if (href === '/admin/today-messages') {
    if (pathname === '/admin/today-messages') return true;
    if (pathname.startsWith('/admin/today-messages/') && pathname !== '/admin/today-messages/new') {
      return true;
    }
    return false;
  }
  if (href === '/admin/today-messages/new') return pathname === '/admin/today-messages/new';
  return false;
}

export function AdminChrome({ children }: { children: React.ReactNode }) {
  const pathname = usePathname() ?? '';

  useEffect(() => {
    if (pathname === '/admin/login') return undefined;
    const unsub = onIdTokenChanged(firebaseAuth, async (user) => {
      if (user) {
        setAdminToken(await user.getIdToken());
      } else {
        clearAdminToken();
      }
    });
    return () => unsub();
  }, [pathname]);

  if (pathname === '/admin/login') {
    return <>{children}</>;
  }

  return (
    <div className="admin-layout">
      <aside className="admin-layout-nav" aria-label="Admin">
        <p className="admin-layout-nav-title">Admin</p>
        <nav className="admin-nav">
          <ul>
            {NAV_ITEMS.map((item) => {
              const active = isNavActive(item.href, pathname);
              return (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    className={active ? 'admin-nav-link admin-nav-link-active' : 'admin-nav-link'}
                    aria-current={active ? 'page' : undefined}
                  >
                    {item.label}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>
        <div className="admin-nav-footer">
          <Link href="/" className="admin-nav-link admin-nav-link-muted">
            ← Back to site
          </Link>
        </div>
      </aside>
      <div className="admin-layout-main">{children}</div>
    </div>
  );
}
