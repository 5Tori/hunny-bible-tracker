import type { Metadata } from 'next';

import '@/styles/admin.css';

import { AdminShell } from '@/components/admin/layout/AdminShell';

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
      <AdminShell>{children}</AdminShell>
    </div>
  );
}
