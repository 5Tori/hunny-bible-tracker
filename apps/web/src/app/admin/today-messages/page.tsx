import { Suspense } from 'react';

import AdminTodayMessagesPageClient from './AdminTodayMessagesPageClient';

export default function AdminTodayMessagesPage() {
  return (
    <Suspense fallback={<p className="admin-muted">Loading schedule…</p>}>
      <AdminTodayMessagesPageClient />
    </Suspense>
  );
}
