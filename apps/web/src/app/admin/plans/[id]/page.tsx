'use client';

import { useParams } from 'next/navigation';

import AdminPlanEditor from '@/components/admin/AdminPlanEditor';

export default function AdminEditPlanPage() {
  const params = useParams();
  const planId = typeof params?.id === 'string' ? params.id : undefined;
  return <AdminPlanEditor planId={planId} />;
}
