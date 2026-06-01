import AdminDiscoverContentEditor from '@/components/admin/AdminDiscoverContentEditor';

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function EditDiscoverContentPage({ params }: PageProps) {
  const { id } = await params;
  return <AdminDiscoverContentEditor contentId={id} />;
}
