import type { Metadata } from 'next';

import '@/styles/admin.css';

import { AdminShell } from '@/components/admin/layout/AdminShell';
import { AdminSwrProvider } from '@/components/admin/providers/AdminSwrProvider';
import { PublicRuntimeConfigScript } from '@/components/PublicRuntimeConfigScript';

export const metadata: Metadata = {
  robots: {
    index: false,
    follow: false,
    googleBot: { index: false, follow: false },
  },
};

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="admin-app">
      <PublicRuntimeConfigScript />
      <AdminSwrProvider>
        <AdminShell>{children}</AdminShell>
      </AdminSwrProvider>
    </div>
  );
}
