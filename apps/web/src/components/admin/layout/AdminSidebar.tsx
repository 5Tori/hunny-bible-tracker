'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

import { ADMIN_NAV_ITEMS, isAdminNavActive } from '@/lib/admin/navigation';

type AdminSidebarProps = {
  onLogout: () => void;
};

export function AdminSidebar({ onLogout }: AdminSidebarProps) {
  const pathname = usePathname() ?? '';

  return (
    <aside className="admin-layout-nav">
      <p className="admin-layout-nav-title">Admin</p>
      <nav className="admin-nav" aria-label="Admin">
        <ul>
          {ADMIN_NAV_ITEMS.map((item) => (
            <li key={item.href}>
              <Link
                href={item.href}
                className={
                  isAdminNavActive(item.href, pathname)
                    ? 'admin-nav-link admin-nav-link-active'
                    : 'admin-nav-link'
                }
              >
                {item.label}
              </Link>
            </li>
          ))}
        </ul>
      </nav>
      <div className="admin-nav-footer">
        <button type="button" className="admin-nav-logout" onClick={onLogout}>
          Log out
        </button>
      </div>
    </aside>
  );
}
