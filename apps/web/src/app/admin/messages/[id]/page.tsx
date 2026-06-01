import AdminMessageCardEditor from '@/components/admin/AdminMessageCardEditor';

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function EditMessageCardPage({ params }: PageProps) {
  const { id } = await params;
  return <AdminMessageCardEditor contentId={id} />;
}
