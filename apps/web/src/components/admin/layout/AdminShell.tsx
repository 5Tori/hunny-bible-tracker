'use client';

import { useEffect } from 'react';
import { usePathname } from 'next/navigation';

import { clearAdminToken, setAdminToken } from '@/lib/admin/client';
import { isAdminShellRoute } from '@/lib/admin/navigation';
import { getSupabaseBrowserClient } from '@/lib/supabase/client';

import { useAdminAuth } from '../hooks/use-admin-auth';
import { AdminSidebar } from './AdminSidebar';

export function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname() ?? '';
  const { logout } = useAdminAuth();
  const showShell = isAdminShellRoute(pathname);

  useEffect(() => {
    if (pathname === '/admin/login') return undefined;
    const supabase = getSupabaseBrowserClient();
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.access_token) {
        setAdminToken(session.access_token);
      } else {
        clearAdminToken();
      }
    });
    return () => subscription.unsubscribe();
  }, [pathname]);

  if (!showShell) {
    return <>{children}</>;
  }

  return (
    <div className="admin-layout">
      <AdminSidebar onLogout={() => void logout()} />
      <div className="admin-layout-main">
        <div className="admin-page">{children}</div>
      </div>
    </div>
  );
}
