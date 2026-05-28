import '@/styles/admin.css';

import { AdminShell } from '@/components/admin/layout/AdminShell';

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="admin-app">
      <AdminShell>{children}</AdminShell>
    </div>
  );
}
