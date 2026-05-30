import { Suspense } from 'react';

import AdminTodayMessageEditor from '@/components/admin/AdminTodayMessageEditor';

export default function NewTodayMessagePage() {
  return (
    <Suspense fallback={<p className="admin-muted">Loading message…</p>}>
      <AdminTodayMessageEditor />
    </Suspense>
  );
}
