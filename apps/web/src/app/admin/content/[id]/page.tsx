import AdminContentEditor from '@/components/admin/AdminContentEditor';

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function EditContentPage({ params }: PageProps) {
  const { id } = await params;
  return <AdminContentEditor contentId={id} />;
}
