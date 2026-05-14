import AdminTodayMessageEditor from '@/components/admin/AdminTodayMessageEditor';

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function EditTodayMessagePage({ params }: PageProps) {
  const { id } = await params;
  return <AdminTodayMessageEditor messageId={id} />;
}
